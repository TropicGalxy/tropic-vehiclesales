fx_version 'cerulean'
game 'gta5'

lua54 'yes'
author 'TropicGalxy'
description 'vehiclesales'
version '1.0'

shared_script 'config.lua'

server_scripts {
    'server.lua',
    '@oxmysql/lib/MySQL.lua'
}

client_scripts {
    '@ox_lib/init.lua', 
    'client.lua'
}

