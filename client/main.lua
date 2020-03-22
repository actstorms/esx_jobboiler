
ESX              = nil
local IsDead,CurrentAction,LastZone, CurrentAction, CurrentActionMsg
local   HasAlreadyEnteredMarker = false
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local isInMarker              = false
local isInPublicMarker        = false
local hintIsShowed            = false
local PlayerData = {}


Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function (xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function (job)
	ESX.PlayerData.job = job
end)

AddEventHandler('boiler:hasEnteredMarker', function(zone)
    if zone == 'BossActions' then
		CurrentAction     = 'menu_boss_actions'
		CurrentActionMsg  = _U('boss_menu')
		CurrentActionData = {}
      end
      if zone == 'Vehicles' then
		CurrentAction     = 'boiler_garage_action'
		CurrentActionMsg  = _U('garage_menu')
		CurrentActionData = {}
      end
      if zone == 'VehicleDeleters' then
  
		local playerPed = GetPlayerPed(-1)
  
		if IsPedInAnyVehicle(playerPed,  false) then
  
		  local vehicle = GetVehiclePedIsIn(playerPed,  false)
  
		  CurrentAction     = 'delete_vehicle'
		  CurrentActionMsg  = _U('put_veh')
		  CurrentActionData = {vehicle = vehicle}
		end
  
	  end
  end)
  AddEventHandler('boiler:hasExitedMarker', function(zone)
  
    CurrentAction = nil
    ESX.UI.Menu.CloseAll()

end)
-- Arbeids meny
function boilerMenu()
    local elements = {}
    table.insert(elements, {label = _U('give_bill'),    value = 'billing'})
    ESX.UI.Menu.CloseAll()
  
	ESX.UI.Menu.Open(
	  'default', GetCurrentResourceName(), 'boiler_menu_action',
	  {
		title    = "Boiler",
		align    = 'top-right',
		elements = elements
	  },
	  function(data, menu)
  
		if data.current.value == 'billing' then
		  OpenBilling()
		end
	  end,
	  function(data, menu)
  
		menu.close()
  
	  end
	)
  end
-- Billing 
function OpenBilling()
    ESX.UI.Menu.Open(
      'dialog', GetCurrentResourceName(), 'billing',
      {
        title = _U('bill_amount')
      },
      function(data, menu)
      
        local amount = tonumber(data.value)
        local player, distance = ESX.Game.GetClosestPlayer()
  
        if player ~= -1 and distance <= 3.0 then
  
          menu.close()
          if amount == nil then
              ESX.ShowNotification(_U('invalid_amount'))
          else
              TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_boiler', "Bill", amount)
          end
  
        else
            ESX.ShowNotification(_U('no_near'))
        end
  
      end,
      function(data, menu)
          menu.close()
      end
    )
  end
-- Draw marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'boiler' then
			local playerCoords = GetEntityCoords(PlayerPedId())
			local isInMarker, letSleep, currentZone = false, true

			for k,v in pairs(Config.zones) do
				local distance = #(playerCoords - v.Coords)

				if v.Type ~= -1 and distance < 100.0 then
					letSleep = false
					DrawMarker(v.Type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, nil, nil, false)
				end

				if distance < v.Size.x then
					isInMarker, currentZone, letSleep = true, k, false
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker, lastZone = true, currentZone
				TriggerEvent('boiler:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('boiler:hasExitedMarker', lastZone)
			end

			if letSleep then
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)
--Vehc
function VehicleSpawnerMenu()
    local vehicles = Config.zones.Vehicles
    local elements = {}
    table.insert(elements, {label = "car",value = 'baller'})
    ESX.UI.Menu.CloseAll()
  
	ESX.UI.Menu.Open(
	  'default', GetCurrentResourceName(), 'boiler_garage_action',
	  {
		title    = _U('garage'),
		align    = 'top-right',
		elements = elements
	  },
      function(data, menu)
        local model = data.current.value
        local vehicle = GetClosestVehicle(vehicles.SpawnPoint.x,  vehicles.SpawnPoint.y,  vehicles.SpawnPoint.z,  3.0,  0,  71)
        ESX.Game.SpawnVehicle(model, {
            x = vehicles.SpawnPoint.x,
            y = vehicles.SpawnPoint.y,
            z = vehicles.SpawnPoint.z
          }, vehicles.Heading, function(vehicle)
            SetVehicleDirtLevel(vehicle, 0)
          end)
          ESX.ShowNotification(_U('car_spawn'))
	  end,
	  function(data, menu)
  
		menu.close()
  
	  end
	)
  end
-- Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if CurrentAction ~= nil then
          SetTextComponentFormat('STRING')
          AddTextComponentString(CurrentActionMsg)
          DisplayHelpTextFromStringLabel(0, 0, 1, -1)
          if IsControlJustReleased(0,  38) then
              if CurrentAction == 'menu_boss_actions'  then
                  TriggerEvent('esx_society:openBossMenu', 'boiler', function(data, menu)
                      menu.close()
                  end, {wash = false})
                end
                if CurrentAction == 'boiler_garage_action' then
                    VehicleSpawnerMenu()
                end
                if CurrentAction == 'delete_vehicle' then
                    ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
                end 
                CurrentAction = nil  
            end
        end
        -- Work menu
        if IsControlJustReleased(0, 167) and IsInputDisabled(0) and not IsDead and  ESX.PlayerData.job and ESX.PlayerData.job.name == 'boiler' then
            boilerMenu()
        end
    end
end)
-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(1360.3791, -706.4277, 70.69)

	SetBlipSprite (blip, 76)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.9)
	SetBlipColour (blip, 81)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Boiler')
	EndTextCommandSetBlipName(blip)
end)