fx_version 'cerulean'
game 'gta5'

author 'rewind.dll'
description 'Admin Jail System with Persistent Storage'
version '1.2.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/**/*'
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib'
}
