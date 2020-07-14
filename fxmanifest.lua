fx_version 'adamant'
game 'gta5'

client_scripts {
    "client/cl_meth.lua",
    "client/cl_weed.lua",
    '@warmenu/warmenu.lua'
}

server_scripts {
    "server/sv_meth.lua",
    "server/sv_weed.lua",
    '@mysql-async/lib/MySQL.lua'
}