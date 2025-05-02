-- server/server.lua
local job = Config.JobName

RegisterNetEvent('prp-fire_rescue:server:notifyNewFire', function(typeName, coords)
    local _, players = exports.qbx_core:GetDutyCountJob(job)
    for _, src in ipairs(players) do
        TriggerClientEvent('prp-fire_rescue:client:alertNewFire', src, typeName, coords)
    end
end)
