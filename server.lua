local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('tropic-vehiclesales:sellVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local plate = QBCore.Shared.Trim(vehicleData.plate)
    local price = tonumber(vehicleData.price)

    if not plate or not price or price <= 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'Invalid vehicle or price.',
            type = 'error'
        })
        return
    end

    MySQL.query('SELECT * FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if result[1] and result[1].citizenid == Player.PlayerData.citizenid then
            MySQL.execute('DELETE FROM player_vehicles WHERE plate = ?', {plate})
            Player.Functions.AddMoney('bank', price, 'vehicle-sell')
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Success',
                description = 'Vehicle sold for $' .. price,
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Error',
                description = 'You do not own this vehicle.',
                type = 'error'
            })
        end
    end)
end)
