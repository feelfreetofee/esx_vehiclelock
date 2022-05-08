ESX = nil

local isRunningWorkaround = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- function StartWorkaroundTask()
	-- if isRunningWorkaround then
		-- return
	-- end

	-- local timer = 0
	-- local playerPed = PlayerPedId()
	-- isRunningWorkaround = true

	-- while timer < 100 do
		-- Citizen.Wait(0)
		-- timer = timer + 1

		-- local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

		-- if DoesEntityExist(vehicle) then
			-- local lockStatus = GetVehicleDoorLockStatus(vehicle)

			-- if lockStatus == 4 then
				-- ClearPedTasks(playerPed)
			-- end
		-- end
	-- end

	-- isRunningWorkaround = false
-- end

function LockLights(veh)
	SetVehicleLights(veh, 2)
	SetVehicleIndicatorLights(GetVehicle(), 1, true)
	SetVehicleIndicatorLights(GetVehicle(), 0, true)
	Wait (200)
	SetVehicleLights(veh, 0)
	SetVehicleIndicatorLights(GetVehicle(), 1, false)
	SetVehicleIndicatorLights(GetVehicle(), 0, false)
	Wait (200)
	SetVehicleLights(veh, 2)
	SetVehicleIndicatorLights(GetVehicle(), 1, true)
	SetVehicleIndicatorLights(GetVehicle(), 0, true)
	Wait (400)
	SetVehicleLights(veh, 0)
	SetVehicleIndicatorLights(GetVehicle(), 1, false)
	SetVehicleIndicatorLights(GetVehicle(), 0, false)
end


function ToggleVehicleLock()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle

	-- Citizen.CreateThread(function()
		-- StartWorkaroundTask()
	-- end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		return
	end

	ESX.TriggerServerCallback('esx_vehiclelock:requestPlayerCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)
			
			local dict = "anim@mp_player_intmenu@key_fob@"
			PlaySoundFrontend(-1, "BUTTON", "MP_PROPERTIES_ELEVATOR_DOORS", 1)
			RequestAnimDict(dict)
			while not HasAnimDictLoaded(dict) do
				Citizen.Wait(0)
			end
			TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
			LockLights(vehicle)

			if lockStatus == 1 then -- unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)

				TriggerEvent('chat:addMessage', { args = { _U('message_title'), _U('message_locked') } })
			elseif lockStatus == 2 then -- locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)

				TriggerEvent('chat:addMessage', { args = { _U('message_title'), _U('message_unlocked') } })
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

RegisterKeyMapping("lockvehicle", 'Lock/Unlock Vehicles', "keyboard", "Y")

RegisterCommand("lockvehicle", function()
	ToggleVehicleLock()
end)

RegisterCommand("givekeys", function(args)
	GiveKeys(args[1], args[2])
end)

function GiveKeys(target, plate)
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	ESX.TriggerServerCallback('esx_vehiclelock:GiveKeys', function(worked)

		if worked then
			
		TriggerEvent('chat:addMessage', { args = { 'ole', 'tus huevos' } })

		end

	end, plate)
end