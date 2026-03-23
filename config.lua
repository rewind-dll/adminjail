Config = {}

-- Permissions
Config.AdminGroups = {
    'admin',
    'superadmin',
    'mod'
}

-- Jail Location
Config.JailLocation = vector4(1641.94, 2570.35, 45.56, 270.0) -- Bolingbroke Penitentiary
Config.JailRadius = 100.0 -- Radius in which jailed players must stay

-- Release Location
Config.ReleaseLocation = vector4(425.13, -979.56, 30.71, 90.0) -- Mission Row PD

-- Control Settings
Config.DisableControls = true
Config.DisabledControls = {
    -- Combat
    24,  -- Attack
    25,  -- Aim
    37,  -- Weapon Wheel
    47,  -- Detonate
    58,  -- Enter Vehicle
    68,  -- Vehicle Aim
    69,  -- Vehicle Attack
    70,  -- Vehicle Fly Attack
    91,  -- Drive Forward (Vehicle)
    92,  -- Drive Backward (Vehicle)
    
    -- Phone & Menu
    289, -- Phone
    170, -- Interaction Menu
    
    -- Vehicle Controls
    59,  -- Vehicle Exit
    71,  -- Vehicle Accelerate
    72,  -- Vehicle Brake
    75,  -- Exit Vehicle
}

-- Commands
Config.Commands = {
    jail = 'adminjail',
    unjail = 'adminjailrelease',
    jailtime = 'adminjailtime',
    panel = 'adminjailpanel'
}

-- Discord Webhook (optional)
Config.DiscordWebhook = '' -- Leave empty to disable

-- Routing Bucket (isolate jailed players)
Config.UseRoutingBucket = true
Config.JailBucket = 999

-- Time Settings
Config.TimeTickRate = 60000 -- Update jail time every 60 seconds (1 minute)

-- UI Settings
Config.ShowJailTimer = true -- Show timer UI for jailed players
