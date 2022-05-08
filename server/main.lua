ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_vehiclelock:requestPlayerCars', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles al LEFT OUTER JOIN shared_vehicles an ON an.owner = al.owner AND an.plate = al.plate WHERE al.owner = @owner AND al.plate = @plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)

ESX.RegisterServerCallback('esx_vehiclelock:GiveKeys', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('INSERT INTO shared_vehicles (owner,plate) VALUES (@owner, @identifier)',{
		['@owner'] = xPlayer.identifier, ['@plate'] = plate
	}, function(affectedRows)
		cb(affectedRows[1] ~= nil)
	end)
end)
