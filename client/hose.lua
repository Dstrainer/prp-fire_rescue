-- client/hose.lua
local hoseActive = false
local hoseObj, usesLeft
local activeVehicleFires = {}  -- reference from main.lua, ensure global scope

-- Hose pickup on firetruck model
exports.ox_target:addModel({'firetruck'}, {
    distance = 2.5,
    options = {{
        name  = 'prp-hose-pickup',
        event = 'prp-fire_rescue:client:pickupHose',
        icon  = 'fas fa-fire-extinguisher',
        label = 'Grab Fire Hose',
    }},
})

-- Pickup handler
RegisterNetEvent('prp-fire_rescue:client:pickupHose', function()
    if hoseActive then
        lib.notify({type = 'error', description = 'You already have the hose!', tite = Config.NotifyTitle, icon = Config.NotifyIcon, duration = Config.NotifyDuration})
        return
    end
    if not exports.qbx_core:HasPrimaryGroup(Config.JobName) then
        lib.notify({ type = 'error', description = 'You must be on duty as Fire Rescue!', tite = Config.NotifyTitle, icon = Config.NotifyIcon, duration = Config.NotifyDuration})
        return
    end

    -- spawn & attach the hose prop
    local model = GetHashKey('prop_fire_hose')
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end

    hoseObj = CreateObject(model, 0, 0, 0, true, true, true)
    AttachEntityToEntity(hoseObj, PlayerPedId(),
        GetPedBoneIndex(PlayerPedId(), 57005),
        0.1, 0.0, 0.0,
        0.0, 180.0, 0.0,
        true, true, false, true, 1, true)

    usesLeft = Config.HoseUses
    hoseActive = true
    lib.notify({ type = 'success', description = ('Hose equipped. Uses left: %d'):format(usesLeft), tite = Config.NotifyTitle, icon = Config.NotifyIcon, duration = Config.NotifyDuration})
end)

-- Spray loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if hoseActive and IsControlJustReleased(0, 38) then
            if usesLeft <= 0 then
                lib.notify({ type = 'error', description = 'Hose empty!' })
                DetachEntity(hoseObj, true, true)
                DeleteEntity(hoseObj)
                hoseActive = false
            else
                UseParticleFxAssetNextCall('core')
                local ptfx = StartParticleFxLoopedAtCoord(
                    'ent_amb_fire_sp', GetEntityCoords(hoseObj),
                    0.0, 0.0, 0.0, 1.0, false, false, false, false)
                Citizen.Wait(500)
                StopParticleFxLooped(ptfx, 0)

                -- extinguish script fires
                local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
                local fx, fy, fz = table.unpack(GetClosestFirePos(px, py, pz))
                if fx then RemoveScriptFire(fx, fy, fz) end

                -- extinguish vehicle fires
                local veh = exports['ox_target']:GetClosestEntity({
                    coords = GetEntityCoords(PlayerPedId()),
                    radius = 10.0,
                    filter = function(e) return activeVehicleFires[e] end,
                })
                if veh and DoesEntityExist(veh) and IsEntityOnFire(veh) then
                    StopEntityFire(veh)
                    activeVehicleFires[veh] = nil
                end

                usesLeft = usesLeft - 1
                lib.notify({ type = 'inform', description = ('Sprayed! Uses left: %d'):format(usesLeft), tite = Config.NotifyTitle, icon = Config.NotifyIcon, duration = Config.NotifyDuration})    
            end
        end
    end
end)
