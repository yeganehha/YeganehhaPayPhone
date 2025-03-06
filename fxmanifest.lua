fx_version 'cerulean'
game 'gta5'

description 'stand a lone gang system'
version '0.0.0.1'
author 'Erfan Ebrahimi'
url 'http://erfanebrahimi.ir'



server_scripts {
	'config.lua',
	'Shared/*.lua',
	'Server/*.lua',
}

client_scripts {
	'config.lua',
	'Shared/*.lua',
	'Client/*.lua',
}
files {
    'NUI/index.html',
    'NUI/script.js',
    'NUI/style.css',
    'NUI/tones.js'
}

lua54 'yes'

dependency {
    'qb-target',
}