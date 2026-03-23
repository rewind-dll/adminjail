-- Jail state
local isJailed = false
local jailTime = 0
local jailReason = ''

-- Apply jail to player
RegisterNetEvent('adminjail:client:applyJail', function(time, reason)
    isJailed = true
    jailTime = time
    jailReason = reason
    
    -- Teleport to jail
    local ped = PlayerPedId()
    SetEntityCoords(ped, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, false, false, false, false)
    SetEntityHeading(ped, Config.JailLocation.w)
    
    -- Remove weapons
    RemoveAllPedWeapons(ped, true)
    
    -- Close inventory if open
    if exports.ox_inventory then
        exports.ox_inventory:closeInventory()
    end
    
    -- Show jail timer UI
    if Config.ShowJailTimer then
        NUI.SendMessage('setJailStatus', { jailed = true, remaining = time, reason = reason })
    end
    
    lib.notify({
        title = 'Admin Jail',
        description = ('You have been jailed for %d minutes'):format(time),
        type = 'error',
        duration = 5000
    })
end)

-- Release player from jail
RegisterNetEvent('adminjail:client:release', function()
    isJailed = false
    jailTime = 0
    jailReason = ''
    
    -- Teleport to release location
    local ped = PlayerPedId()
    SetEntityCoords(ped, Config.ReleaseLocation.x, Config.ReleaseLocation.y, Config.ReleaseLocation.z, false, false, false, false)
    SetEntityHeading(ped, Config.ReleaseLocation.w)
    
    -- Hide jail timer UI
    if Config.ShowJailTimer then
        NUI.SendMessage('setJailStatus', { jailed = false, remaining = 0, reason = '' })
    end
    
    lib.notify({
        title = 'Admin Jail',
        description = 'You have been released from jail',
        type = 'success',
        duration = 5000
    })
end)

-- Update jail time
RegisterNetEvent('adminjail:client:updateTime', function(time)
    jailTime = time
    if Config.ShowJailTimer then
        NUI.SendMessage('setJailStatus', { jailed = true, remaining = time, reason = jailReason })
    end
end)

-- Open admin panel
RegisterNetEvent('adminjail:client:openPanel', function()
    -- Request player list from server
    TriggerServerEvent('adminjail:server:getPlayers')
end)

-- Receive player list and open/update panel
RegisterNetEvent('adminjail:client:receivePlayerList', function(players)
    -- Filter to only jailed players for the new UI
    local jailedPlayers = {}
    for _, player in ipairs(players) do
        if player.isJailed then
            table.insert(jailedPlayers, {
                id = player.id,
                name = player.name,
                remaining = player.timeRemaining,
                reason = player.reason
            })
        end
    end
    
    if NUI.IsOpen() then
        -- Update existing panel with refresh event
        NUI.SendMessage('refresh', jailedPlayers)
    else
        -- Open panel with initial data
        NUI.Open({ players = jailedPlayers })
    end
end)

-- Jail enforcement thread
CreateThread(function()
    while true do
        Wait(0)
        
        if isJailed then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local jailCoords = vector3(Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z)
            local distance = #(coords - jailCoords)
            
            -- Keep player within jail radius (instant check)
            if distance > Config.JailRadius then
                SetEntityCoords(ped, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, false, false, false, false)
                SetEntityHeading(ped, Config.JailLocation.w)
                SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
                lib.notify({
                    title = 'Admin Jail',
                    description = 'You cannot leave the jail area',
                    type = 'error'
                })
            end
            
            -- Check if player is in water and teleport back
            if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) then
                SetEntityCoords(ped, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, false, false, false, false)
                SetEntityHeading(ped, Config.JailLocation.w)
                lib.notify({
                    title = 'Admin Jail',
                    description = 'Swimming is not allowed while jailed',
                    type = 'error'
                })
            end
            
            -- Remove weapons if player somehow gets one
            if IsPedArmed(ped, 7) then
                RemoveAllPedWeapons(ped, true)
            end
        else
            Wait(500)
        end
    end
end)

-- Disable controls when jailed
if Config.DisableControls then
    CreateThread(function()
        while true do
            Wait(0)
            
            if isJailed then
                for _, control in ipairs(Config.DisabledControls) do
                    DisableControlAction(0, control, true)
                end
            else
                Wait(500)
            end
        end
    end)
end

-- Block ox_inventory while jailed
AddEventHandler('ox_inventory:disarm', function()
    if isJailed then
        lib.notify({
            title = 'Admin Jail',
            description = 'You cannot access inventory while jailed',
            type = 'error'
        })
        return false
    end
end)

-- Block inventory opening
CreateThread(function()
    while true do
        Wait(1000)
        
        if isJailed then
            -- Block ox_inventory by closing it
            if exports.ox_inventory then
                exports.ox_inventory:closeInventory()
            end
        else
            Wait(2000)
        end
    end
end)

-- NUI Callbacks
RegisterNuiCallback('jailPlayer', function(data, cb)
    -- Transform data from UI format to server format
    TriggerServerEvent('adminjail:server:jailPlayer', {
        playerId = data.targetId,
        time = data.duration,
        reason = data.reason
    })
    cb(true)
end)

RegisterNuiCallback('unjailPlayer', function(data, cb)
    TriggerServerEvent('adminjail:server:releasePlayer', data.targetId)
    cb(true)
end)

RegisterNuiCallback('getJailedPlayers', function(_, cb)
    -- Request player list and return jailed players only
    -- The response will come via receivePlayerList event
    TriggerServerEvent('adminjail:server:getPlayers')
    cb({})
end)

RegisterNuiCallback('close', function(_, cb)
    NUI.Close()
    cb('ok')
end)
