ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
TriggerEvent('esx_phone:registerNumber', 'boiler',"boiler", true, true)
TriggerEvent('esx_society:registerSociety', 'boiler', 'boiler', 'society_boiler', 'society_boiler', 'society_advokat', {type = 'public'})