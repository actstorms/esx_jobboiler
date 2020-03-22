resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
description 'Boilerplate for jobs'
server_scripts {
    '@es_extended/locale.lua',
    'server/main.lua',
    'locales/no.lua'
}
client_scripts {
    '@es_extended/locale.lua',
    'client/main.lua',
    'locales/no.lua',
    'config.lua'
}

dependencies {
	'es_extended',
	'esx_billing'
}