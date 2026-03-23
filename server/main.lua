-- Store active jail data in memory for faster access
local ActiveJails = {}

-- Database initialization using oxmysql
CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `admin_jail` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `identifier` VARCHAR(60) NOT NULL UNIQUE,
            `time_remaining` INT NOT NULL,
            `reason` VARCHAR(255) NOT NULL,
            `jailed_by` VARCHAR(60) NOT NULL,
            `jailed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    print('^2[Admin Jail]^0 Database table initialized')
    
    -- Load all active jails from database into memory
    local results = MySQL.query.await('SELECT identifier, time_remaining, reason, jailed_by FROM admin_jail WHERE time_remaining > 0')
    if results then
        for _, row in ipairs(results) do
            ActiveJails[row.identifier] = {
                timeRemaining = row.time_remaining,
                reason = row.reason,
                jailedBy = row.jailed_by
            }
        end
        print(('^2[Admin Jail]^0 Loaded %d active jail(s) from database'):format(#results))
    end
    
    -- Apply jail to online players on resource start
    Wait(2000)
    local allPlayers = ESX.GetExtendedPlayers()
    for _, xPlayer in ipairs(allPlayers) do
        local jailData = ActiveJails[xPlayer.identifier]
        if jailData then
            TriggerClientEvent('adminjail:client:applyJail', xPlayer.source, jailData.timeRemaining, jailData.reason)
            
            if Config.UseRoutingBucket then
                SetPlayerRoutingBucket(xPlayer.source, Config.JailBucket)
            end
            
            print(('^2[Admin Jail]^0 Re-applied jail to %s (%d minutes remaining)'):format(xPlayer.getName(), jailData.timeRemaining))
        end
    end
end)

-- Helper: Check if player has admin permission
local function HasPermission(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    for _, group in ipairs(Config.AdminGroups) do
        if xPlayer.getGroup() == group then
            return true
        end
    end
    return false
end

-- Helper: Get player name
local function GetPlayerName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getName()
    end
    return 'Unknown'
end

-- Helper: Send Discord log
local function SendDiscordLog(logType, data)
    if Config.DiscordWebhook == '' then return end
    
    local embed = {}
    
    if logType == 'jail' then
        embed = {
            {
                ['title'] = 'Admin Jail System Logs',
                ['description'] = '**Sent To Prison**',
                ['color'] = 15158332, -- Red
                ['fields'] = {
                    {
                        ['name'] = 'Player ID',
                        ['value'] = '```' .. data.targetId .. '```',
                        ['inline'] = false
                    },
                    {
                        ['name'] = 'Player Name',
                        ['value'] = '```' .. data.targetName .. '```',
                        ['inline'] = false
                    },
                    {
                        ['name'] = 'Time (in Seconds)',
                        ['value'] = '```' .. (data.time * 60) .. '```',
                        ['inline'] = false
                    },
                    {
                        ['name'] = 'Reason',
                        ['value'] = '```' .. data.reason .. '```',
                        ['inline'] = false
                    },
                    {
                        ['name'] = 'Staff Member',
                        ['value'] = '```' .. data.adminName .. '```',
                        ['inline'] = false
                    }
                },
                ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
            }
        }
    elseif logType == 'release' then
        embed = {
            {
                ['title'] = 'Admin Jail System Logs',
                ['description'] = '**Released From Prison**',
                ['color'] = 3066993, -- Green
                ['fields'] = {
                    {
                        ['name'] = 'Player ID',
                        ['value'] = '```' .. data.targetId .. '```',
                        ['inline'] = false
                    },
                    {
                        ['name'] = 'Player Name',
                        ['value'] = '```' .. data.targetName .. '```',
                        ['inline'] = false
                    },
                    {
                        ['name'] = 'Staff Member',
                        ['value'] = '```' .. data.adminName .. '```',
                        ['inline'] = false
                    }
                },
                ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
            }
        }
    end
    
    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Jail a player
local function JailPlayer(targetId, time, reason, adminId)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then return false, 'Player not found' end
    
    local identifier = xTarget.identifier
    local adminName = GetPlayerName(adminId)
    local targetName = GetPlayerName(targetId)
    
    -- Save to database
    MySQL.prepare.await('INSERT INTO admin_jail (identifier, time_remaining, reason, jailed_by) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE time_remaining = VALUES(time_remaining), reason = VALUES(reason), jailed_by = VALUES(jailed_by)', {
        identifier, time, reason, adminName
    })
    
    -- Store in memory
    ActiveJails[identifier] = {
        timeRemaining = time,
        reason = reason,
        jailedBy = adminName
    }
    
    -- Apply jail to player
    TriggerClientEvent('adminjail:client:applyJail', targetId, time, reason)
    
    -- Set routing bucket if enabled
    if Config.UseRoutingBucket then
        SetPlayerRoutingBucket(targetId, Config.JailBucket)
    end
    
    -- Notifications
    lib.notify(targetId, {
        title = 'Admin Jail',
        description = ('You have been jailed for %d minutes.\nReason: %s'):format(time, reason),
        type = 'error',
        duration = 10000
    })
    
    lib.notify(adminId, {
        title = 'Admin Jail',
        description = ('Jailed %s for %d minutes'):format(targetName, time),
        type = 'success'
    })
    
    -- Discord log
    SendDiscordLog('jail', {
        targetId = targetId,
        targetName = targetName,
        time = time,
        reason = reason,
        adminName = adminName
    })
    
    return true, 'Player jailed successfully'
end

-- Release a player
local function ReleasePlayer(targetId, adminId)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then return false, 'Player not found' end
    
    local identifier = xTarget.identifier
    local adminName = adminId and GetPlayerName(adminId) or 'System'
    local targetName = GetPlayerName(targetId)
    
    -- Remove from database
    MySQL.prepare.await('DELETE FROM admin_jail WHERE identifier = ?', { identifier })
    
    -- Remove from memory
    ActiveJails[identifier] = nil
    
    -- Release player
    TriggerClientEvent('adminjail:client:release', targetId)
    
    -- Reset routing bucket
    if Config.UseRoutingBucket then
        SetPlayerRoutingBucket(targetId, 0)
    end
    
    -- Notifications
    lib.notify(targetId, {
        title = 'Admin Jail',
        description = 'You have been released from jail',
        type = 'success'
    })
    
    if adminId then
        lib.notify(adminId, {
            title = 'Admin Jail',
            description = ('Released %s from jail'):format(targetName),
            type = 'success'
        })
    end
    
    -- Discord log
    SendDiscordLog('release', {
        targetId = targetId,
        targetName = targetName,
        adminName = adminName
    })
    
    return true, 'Player released successfully'
end

-- Load player jail when ESX player data is loaded
RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.identifier
    
    CreateThread(function()
        Wait(1000) -- Small delay to ensure everything is ready
        
        -- Check if already loaded in memory (from resource start)
        local jailData = ActiveJails[identifier]
        if jailData then
            TriggerClientEvent('adminjail:client:applyJail', playerId, jailData.timeRemaining, jailData.reason)
            
            if Config.UseRoutingBucket then
                SetPlayerRoutingBucket(playerId, Config.JailBucket)
            end
            
            print(('^2[Admin Jail]^0 Applied jail to %s on join (%d minutes remaining)'):format(xPlayer.getName(), jailData.timeRemaining))
            return
        end
        
        -- Otherwise check database
        local result = MySQL.query.await('SELECT time_remaining, reason, jailed_by FROM admin_jail WHERE identifier = ?', { identifier })
        
        if result and result[1] then
            local data = result[1]
            ActiveJails[identifier] = {
                timeRemaining = data.time_remaining,
                reason = data.reason,
                jailedBy = data.jailed_by
            }
            
            TriggerClientEvent('adminjail:client:applyJail', playerId, data.time_remaining, data.reason)
            
            if Config.UseRoutingBucket then
                SetPlayerRoutingBucket(playerId, Config.JailBucket)
            end
            
            print(('^2[Admin Jail]^0 Applied jail to %s on join (%d minutes remaining)'):format(xPlayer.getName(), data.time_remaining))
        end
    end)
end)

-- Time countdown system
CreateThread(function()
    while true do
        Wait(Config.TimeTickRate)
        
        for identifier, data in pairs(ActiveJails) do
            -- Only decrement time for online players
            local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
            if xPlayer then
                local src = xPlayer.source
                data.timeRemaining = data.timeRemaining - 1
                
                -- Update database
                MySQL.prepare('UPDATE admin_jail SET time_remaining = ? WHERE identifier = ?', {
                    data.timeRemaining, identifier
                })
                
                -- Update their UI
                TriggerClientEvent('adminjail:client:updateTime', src, data.timeRemaining)
                
                -- Release if time is up
                if data.timeRemaining <= 0 then
                    ReleasePlayer(src, nil)
                end
            end
        end
    end
end)

-- Commands
lib.addCommand(Config.Commands.jail, {
    help = 'Jail a player',
    params = {
        { name = 'id', type = 'playerId', help = 'Player ID' },
        { name = 'time', type = 'number', help = 'Time in minutes' },
        { name = 'reason', type = 'string', help = 'Reason for jail' }
    }
}, function(source, args)
    if not HasPermission(source) then
        return lib.notify(source, {
            title = 'Admin Jail',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
    end
    
    local success, message = JailPlayer(args.id, args.time, args.reason, source)
    if not success then
        lib.notify(source, {
            title = 'Admin Jail',
            description = message,
            type = 'error'
        })
    end
end)

lib.addCommand(Config.Commands.unjail, {
    help = 'Release a player from jail',
    params = {
        { name = 'id', type = 'playerId', help = 'Player ID' }
    }
}, function(source, args)
    if not HasPermission(source) then
        return lib.notify(source, {
            title = 'Admin Jail',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
    end
    
    local success, message = ReleasePlayer(args.id, source)
    if not success then
        lib.notify(source, {
            title = 'Admin Jail',
            description = message,
            type = 'error'
        })
    end
end)

lib.addCommand(Config.Commands.jailtime, {
    help = 'Check your remaining jail time'
}, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local jailData = ActiveJails[xPlayer.identifier]
    if jailData then
        lib.notify(source, {
            title = 'Admin Jail',
            description = ('Time remaining: %d minutes\nReason: %s'):format(jailData.timeRemaining, jailData.reason),
            type = 'info'
        })
    else
        lib.notify(source, {
            title = 'Admin Jail',
            description = 'You are not jailed',
            type = 'info'
        })
    end
end)

lib.addCommand(Config.Commands.panel, {
    help = 'Open admin jail panel'
}, function(source)
    if not HasPermission(source) then
        return lib.notify(source, {
            title = 'Admin Jail',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
    end
    
    TriggerClientEvent('adminjail:client:openPanel', source)
end)

-- NUI Callbacks
RegisterNetEvent('adminjail:server:getPlayers', function()
    local src = source
    if not HasPermission(src) then return end
    
    local players = ESX.GetExtendedPlayers()
    local playerList = {}
    
    for _, xPlayer in ipairs(players) do
        local jailData = ActiveJails[xPlayer.identifier]
        table.insert(playerList, {
            id = xPlayer.source,
            name = xPlayer.getName(),
            identifier = xPlayer.identifier,
            isJailed = jailData ~= nil,
            timeRemaining = jailData and jailData.timeRemaining or 0,
            reason = jailData and jailData.reason or ''
        })
    end
    
    TriggerClientEvent('adminjail:client:receivePlayerList', src, playerList)
end)

RegisterNetEvent('adminjail:server:jailPlayer', function(data)
    local src = source
    if not HasPermission(src) then return end
    
    JailPlayer(data.playerId, data.time, data.reason, src)
    
    -- Refresh player list for the admin
    Wait(100)
    local players = ESX.GetExtendedPlayers()
    local playerList = {}
    
    for _, xPlayer in ipairs(players) do
        local jailData = ActiveJails[xPlayer.identifier]
        table.insert(playerList, {
            id = xPlayer.source,
            name = xPlayer.getName(),
            identifier = xPlayer.identifier,
            isJailed = jailData ~= nil,
            timeRemaining = jailData and jailData.timeRemaining or 0,
            reason = jailData and jailData.reason or ''
        })
    end
    
    TriggerClientEvent('adminjail:client:receivePlayerList', src, playerList)
end)

RegisterNetEvent('adminjail:server:releasePlayer', function(playerId)
    local src = source
    if not HasPermission(src) then return end
    
    ReleasePlayer(playerId, src)
    
    -- Refresh player list for the admin
    Wait(100)
    local players = ESX.GetExtendedPlayers()
    local playerList = {}
    
    for _, xPlayer in ipairs(players) do
        local jailData = ActiveJails[xPlayer.identifier]
        table.insert(playerList, {
            id = xPlayer.source,
            name = xPlayer.getName(),
            identifier = xPlayer.identifier,
            isJailed = jailData ~= nil,
            timeRemaining = jailData and jailData.timeRemaining or 0,
            reason = jailData and jailData.reason or ''
        })
    end
    
    TriggerClientEvent('adminjail:client:receivePlayerList', src, playerList)
end)
