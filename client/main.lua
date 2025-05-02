-- client/main.lua
local job = Config.JobName
local activeVehicleFires = {}

-- Spawn a fire of the given type at coords
local function SpawnFire(typeName, coords)
    local cfg = Config.FireTypes[typeName]
    if not cfg then return end

    if typeName == 'vehicle' then
        -- spawn a random vehicle and set it ablaze
        local models = { 'vstr', 'blista', 'asea', 'panto' }
        local model = models[math.random(#models)]
        RequestModel(GetHashKey(model))
        while not HasModelLoaded(GetHashKey(model)) do Citizen.Wait(0) end

        local veh = CreateVehicle(GetHashKey(model), coords.x, coords.y, coords.z, math.random(0, 360), true, false)
        SetVehicleOnGroundProperly(veh)
        SetVehicleEngineOn(veh, false, true, true)
        StartEntityFire(veh)
        activeVehicleFires[veh] = true
        SetModelAsNoLongerNeeded(GetHashKey(model))
    else
        StartScriptFire(coords.x, coords.y, coords.z, cfg.radius, true)
    end

    -- PS-Dispatch alert
    exports['ps-dispatch']:CustomAlert({
        coords        = coords,
        message       = cfg.dispatchMsg,
        dispatchCode  = cfg.dispatchCode,
        description   = cfg.dispatchMsg,
        radius        = cfg.radius,
        sprite        = cfg.sprite,
        color         = cfg.color,
        scale         = 1.0,
        length        = 300,
        recipientList = { job },
    })

    -- optional: internal notify
    TriggerServerEvent('prp-fire_rescue:server:notifyNewFire', typeName, coords)
end

-- Auto-spawn loop for each fire type
for typeName, cfg in pairs(Config.FireTypes) do
    if cfg.autoSpawn then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(math.random(cfg.minInterval, cfg.maxInterval))
                local loc = Config:GetRandomLocation(typeName)
                if loc then SpawnFire(typeName, loc) end
            end
        end)
    end
end

-- Commands
RegisterCommand('startfire', function(_, args)
    local typeName = args[1] and args[1]:lower()
    if not Config.FireTypes[typeName] then
        return exports['qbx_core']:Notify('Usage: /startfire <wildfire|vehicle|structure|dumpster> [idx]', 'error')
    end
    if not exports.qbx_core:HasPrimaryGroup(job) then
        return exports['qbx_core']:Notify('You must be on duty as Fire Rescue.', 'error')
    end
    local idx = tonumber(args[2])
    local coords = idx and Config.FireTypes[typeName].locations[idx] or GetEntityCoords(PlayerPedId())
    SpawnFire(typeName, coords)
end, false)

RegisterCommand('stopfires', function()
    if not exports.qbx_core:HasPrimaryGroup(job) then
        return exports['qbx_core']:Notify('You must be on duty as Fire Rescue.', 'error')
    end
    RemoveAllScriptFires()
    exports['qbx_core']:Notify('All fires extinguished client-side.', 'success')
end, false)
