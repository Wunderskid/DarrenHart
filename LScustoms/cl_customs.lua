-- cl_customs.lua
-- Gemaakt door Wunderskid (DJ Hart)

local ESX = nil
local isMenuOpen = false
local inCustomsZone = false
local currentVehicle = nil
local vehicleClass = nil
local currentMods = {}

-- Configuratie
local Config = {
    LSCustomsLocations = {
        vector3(-337.0, -136.0, 39.0),
        vector3(732.5, -1088.8, 22.0),
        vector3(-1155.0, -2007.0, 13.0)
    },
    MarkerType = 27,
    MarkerColor = {r = 0, g = 255, b = 0, a = 120},
    MarkerSize = vector3(2.0, 2.0, 1.0),
    RepairCost = 1500,
    WashCost = 250,
    Blip = {
        Enable = true,
        Sprite = 72,
        Color = 4,
        Scale = 0.8,
        Name = "Los Santos Customs"
    },
    Prices = {
        engine = {2500, 5500, 12500},
        brakes = {2500, 5500},
        suspension = {2500, 5500, 12500, 17500},
        transmission = {2500, 5500, 12500},
        armor = {25000, 35000, 50000},
        turbo = 15000
    },
    ModIndices = {
        ['engine'] = 11,
        ['brakes'] = 12,
        ['suspension'] = 15,
        ['transmission'] = 13,
        ['armor'] = 16,
        ['turbo'] = 18
    }
}

-- ESX Initialisatie
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Main menu creatie
function CreateCustomsMenu()
    local mainMenu = ESX.UI.Menu.CloseAll()
    local elements = {
        {label = _U('engine'), value = 'engine'},
        {label = _U('brakes'), value = 'brakes'},
        {label = _U('suspension'), value = 'suspension'},
        {label = _U('transmission'), value = 'transmission'},
        {label = _U('armor'), value = 'armor'},
        {label = _U('turbo'), value = 'turbo_toggle'},
        {label = _U('repair'), value = 'repair'},
        {label = _U('clean'), value = 'clean'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ls_customs_main', {
        title = _U('menu_title'),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local currentData = data.current.value
        if currentData == 'repair' then
            RepairVehicle()
        elseif currentData == 'clean' then
            CleanVehicle()
        elseif currentData == 'turbo_toggle' then
            ToggleTurbo()
        else
            OpenModCategory(data.current.value)
        end
    end, function(data, menu)
        menu.close()
        isMenuOpen = false
    end)
end

-- Mod categorie submenu
function OpenModCategory(category)
    local elements = {}
    local priceConfig = Config.Prices[category]
    local maxMods = GetNumVehicleMods(currentVehicle, Config.ModIndices[category])

    for i = 1, maxMods do
        local modPrice = priceConfig[i] or priceConfig[#priceConfig]
        local modName = GetLabelText(GetModTextLabel(currentVehicle, Config.ModIndices[category], i - 1))
        
        table.insert(elements, {
            label = ('%s - $%s'):format(modName, ESX.Math.GroupDigits(modPrice)),
            price = modPrice,
            modIndex = i - 1,
            category = category
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ls_customs_category', {
        title = _U(category),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        ESX.TriggerServerCallback('ls_customs:purchaseMod', function(success)
            if success then
                SetVehicleMod(currentVehicle, Config.ModIndices[data.current.category], data.current.modIndex, false)
                UpdateVehicleMods()
                ESX.ShowNotification(_U('purchase_success'))
            else
                ESX.ShowNotification(_U('not_enough_money'))
            end
        end, data.current.price)
    end, function(data, menu)
        menu.close()
    end)
end

-- Voertuig reparatie
function RepairVehicle()
    ESX.TriggerServerCallback('ls_customs:purchaseMod', function(success)
        if success then
            SetVehicleFixed(currentVehicle)
            SetVehicleDeformationFixed(currentVehicle)
            ESX.ShowNotification(_U('vehicle_repaired'))
        else
            ESX.ShowNotification(_U('not_enough_money'))
        end
    end, Config.RepairCost)
end

-- Voertuig schoonmaken
function CleanVehicle()
    ESX.TriggerServerCallback('ls_customs:purchaseMod', function(success)
        if success then
            SetVehicleDirtLevel(currentVehicle, 0.0)
            ESX.ShowNotification(_U('vehicle_cleaned'))
        else
            ESX.ShowNotification(_U('not_enough_money'))
        end
    end, Config.WashCost)
end

-- Turbo toggle
function ToggleTurbo()
    local hasTurbo = IsToggleModOn(currentVehicle, 18)
    local price = Config.Prices.turbo

    ESX.TriggerServerCallback('ls_customs:purchaseMod', function(success)
        if success then
            ToggleVehicleMod(currentVehicle, 18, not hasTurbo)
            ESX.ShowNotification(hasTurbo and _U('turbo_removed') or _U('turbo_added'))
        else
            ESX.ShowNotification(_U('not_enough_money'))
        end
    end, price)
end

-- Update voertuig mods
function UpdateVehicleMods()
    currentMods = ESX.Game.GetVehicleProperties(currentVehicle)
end

-- Check zone
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local isInCustomsZone = false

        for _, location in ipairs(Config.LSCustomsLocations) do
            if #(coords - location) < 20.0 then
                isInCustomsZone = true
                break
            end
        end

        inCustomsZone = isInCustomsZone
        if inCustomsZone then
            if Config.Blip.Enable then
                CreateBlip()
            end
        end
    end
end)

-- Marker drawing
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if inCustomsZone then
            for _, location in ipairs(Config.LSCustomsLocations) do
                DrawMarker(Config.MarkerType, location.x, location.y, location.z,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                            Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                            false, true, 2, false, nil, nil, false)
                
                if IsControlJustReleased(0, 38) then -- E key
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vehicle ~= 0 then
                        currentVehicle = vehicle
                        vehicleClass = GetVehicleClass(currentVehicle)
                        if vehicleClass ~= 13 and vehicleClass ~= 14 and vehicleClass ~= 15 and vehicleClass ~= 16 then
                            UpdateVehicleMods()
                            CreateCustomsMenu()
                            isMenuOpen = true
                        else
                            ESX.ShowNotification(_U('invalid_vehicle'))
                        end
                    else
                        ESX.ShowNotification(_U('no_vehicle'))
                    end
                end
            end
        end
    end
end)

-- Server callbacks
RegisterNetEvent('ls_customs:installMod')
AddEventHandler('ls_customs:installMod', function()
    UpdateVehicleMods()
end)

-- Blips aanmaken
function CreateBlip()
    for _, location in ipairs(Config.LSCustomsLocations) do
        local blip = AddBlipForCoord(location)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.Name)
        EndTextCommandSetBlipName(blip)
    end
end