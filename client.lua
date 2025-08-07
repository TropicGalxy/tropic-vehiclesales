local QBCore = exports['qb-core']:GetCoreObject()
local VEHICLES = {}
local inZone = false
local currentZone = nil

CreateThread(function()
    Wait(100)
    if Config.Framework == 'qbx' then
        VEHICLES = exports.qbx_core:GetVehiclesByName()
    elseif Config.Framework == 'qb' then
        VEHICLES = QBCore.Shared.Vehicles
    end
end)

for _, zone in pairs(Config.SellingZones) do
    if zone.blip then
        local blip = AddBlipForCoord(zone.coords)
        SetBlipSprite(blip, zone.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, zone.blip.scale)
        SetBlipColour(blip, zone.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local nearZone = nil

        for _, zone in pairs(Config.SellingZones) do
            local dist = #(coords - zone.coords)
            if dist < zone.radius then
                nearZone = zone
                break
            end
        end

        if nearZone and not inZone then
            inZone = true
            currentZone = nearZone
            lib.showTextUI('[E] Sell Vehicle')
        elseif not nearZone and inZone then
            inZone = false
            currentZone = nil
            lib.hideTextUI()
        end

        if inZone then
            sleep = 0 
            if IsControlJustReleased(0, 38) then
                TriggerEvent('tropic-vehiclesales:attemptSell')
                Wait(1000)
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('tropic-vehiclesales:attemptSell', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return end

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(veh))
    local model = GetEntityModel(veh)
    local vehicleName = GetDisplayNameFromVehicleModel(model):lower()
    local price = 0

    if VEHICLES[vehicleName] then
        local basePrice = VEHICLES[vehicleName].price or 0
        price = math.floor(basePrice * Config.SellPercent)
    end

    if price <= 0 then
        lib.notify({
            title = 'Error',
            description = 'This vehicle cannot be sold.',
            type = 'error'
        })
        return
    end

    local dialog = lib.alertDialog({
        header = 'Sell Vehicle',
        content = 'Do you want to sell your vehicle for **$' .. price .. '**?',
        centered = true,
        cancel = true
    })

    if dialog == 'confirm' then
        TriggerServerEvent('tropic-vehiclesales:sellVehicle', {
            plate = plate,
            price = price
        })
        DeleteVehicle(veh)
    end
end)
