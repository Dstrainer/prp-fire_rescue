-- client/alert.lua
RegisterNetEvent('prp-fire_rescue:client:alertNewFire', function(typeName, coords)
    local cfg = Config.FireTypes[typeName]
    if not cfg then return end

    lib.notify({
        title       = Config.NotifyTitle,
        description = ('New %s at [%.1f, %.1f]'):format(cfg.label, coords.x, coords.y),
        type        = 'inform',
        duration    = 8000,
        icon        = Config.NotifyIcon,
    })

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, cfg.sprite)
    SetBlipColour(blip, cfg.color)
    SetBlipRoute(blip, true)
    Citizen.SetTimeout(120000, function() RemoveBlip(blip) end)
end)
