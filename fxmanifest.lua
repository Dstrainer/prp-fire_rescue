fx_version 'cerulean'
game 'gta5'

name 'prp-fire_rescue'
description 'Fire & Rescue job (ambulance + firefighter) with multi-type fires, PS-Dispatch and hose integration (no inventory item)'
author 'DTrain'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/hose.lua',
    'client/alert.lua',
}

server_scripts {
    'server/server.lua',
}

dependencies{
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'qbx_core',
    'ps-dispatch'
}