local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local Initialized = false
local InsideShop = nil

-- Functions

local function comma_value(amount)
    local formatted = amount
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

local function GetVehiclePrice(vehicle)
    local hash = GetEntityModel(vehicle)
    for _,v in pairs(QBCore.Shared.Vehicles) do
        if v.hash == hash then
            return v.price * 0.1
        end
    end
end

local function GetModPrice(vehicle, modType, index)
    if not index then
        if Config.Pricing['type'] == 'fixed' then
            return comma_value(Config.Pricing['fixed'][modType])
        else
            return comma_value(math.floor(GetVehiclePrice(vehicle) * Config.Pricing['variable'][modType]))
        end
    end
    if Config.Pricing['type'] == 'fixed' then
        return comma_value(Config.Pricing['fixed'][modType][tostring(index)])
    else
        return comma_value(math.floor(GetVehiclePrice(vehicle) * Config.Pricing['variable'][modType][tostring(index)]))
    end
end

-- Menu

local vehHeaderMenu = {
    {
        header = 'Customize Vehicle',
        txt = 'Give your vehicle a new look!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:showVehOptions'
        }
    }
}

local vehOptions = {
    {
        header = 'Repair Vehicle',
        txt = 'Make your vehicle good as new!',
        icon = "fa-solid fa-screwdriver-wrench",
        params = {
            event = 'qb-customs:client:repairVehicle'
        }
    },
    {
        header = 'View Upgrades',
        txt = 'Browse vehicle performance mods!',
        icon = "fa-solid fa-gears",
        params = {
            event = 'qb-customs:client:performanceMods'
        }
    },
    {
        header = 'View Customizations',
        txt = 'Browse vehicle cosmetic mods!',
        icon = "fa-solid fa-cart-shopping",
        params = {
            event = 'qb-customs:client:cosmeticMods'
        }
    }
}

local upgradesMenu = {
    {
        header = 'Armor',
        txt = 'Upgrade/downgrade armor on your vehicle!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:performanceOptions',
            args = {
                upgradeType = 'armor'
            }
        }
    },
    {
        header = 'Brakes',
        txt = 'Upgrade/downgrade brakes on your vehicle!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:performanceOptions',
            args = {
                upgradeType = 'brakes'
            }
        }
    },
    {
        header = 'Engine',
        txt = 'Upgrade/downgrade engine on your vehicle!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:performanceOptions',
            args = {
                upgradeType = 'engine'
            }
        }
    },
    {
        header = 'Suspension',
        txt = 'Upgrade/downgrade suspension on your vehicle!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:performanceOptions',
            args = {
                upgradeType = 'suspension'
            }
        }
    },
    {
        header = 'Transmission',
        txt = 'Upgrade/downgrade transmission on your vehicle!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:performanceOptions',
            args = {
                upgradeType = 'transmission'
            }
        }
    },
    {
        header = 'Turbo',
        txt = 'Install/remove a turbo on your vehicle!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:performanceOptions',
            args = {
                upgradeType = 'turbo'
            }
        }
    },
    {
        header = 'Max Mods',
        txt = 'Install all performance upgrades!',
        icon = "fa-solid fa-wrench",
        params = {
            event = 'qb-customs:client:performanceOptions',
            args = {
                upgradeType = 'maxMods'
            }
        }
    },
    {
        header = 'Back',
        txt = 'Return to previous menu!',
        icon = "fa-solid fa-arrow-left",
        params = {
            event = 'qb-customs:client:showVehOptions',
        }
    }
}

-- Map Blips

Citizen.CreateThread(function()
    for _, v in pairs(Config.Shops) do
        if v['showBlip'] then
            local blip = AddBlipForCoord(v['blipCoords'])
            SetBlipSprite(blip, v['blipSprite'])
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.6)
            SetBlipColour(blip, v['blipColor'])
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v['shopLabel'])
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Zone Setup

exports('IsInsideShop', function() -- Exports for other resources to open menu
    return InsideShop
end)

local function CreateZones(shopZone, name)
    local zone = PolyZone:Create(shopZone, {
        name = name,
        minZ = shopZone.minZ,
        maxZ = shopZone.maxZ,
        debugPoly = false,
    })

    zone:onPlayerInOut(function(isPointInside)
        if isPointInside and IsPedInAnyVehicle(PlayerPedId(), false) then
            InsideShop = name
            if Config.UseRadial then
                exports['qb-radialmenu']:AddOption({
                    id = 'customs',
                    title = 'Customize',
                    icon = 'screwdriver-wrench',
                    type = 'client',
                    event = 'qb-customs:client:showVehOptions',
                    shouldClose = true
                }, 'customs')
            else
                exports['qb-menu']:showHeader(vehHeaderMenu)
            end
        else
            InsideShop = nil
            if Config.UseRadial then
                exports['qb-radialmenu']:RemoveOption('customs')
            else
                exports['qb-menu']:closeMenu()
            end
        end
    end)
end

local function Init()
    Initialized = true
    CreateThread(function()
        for name, shop in pairs(Config.Shops) do
            CreateZones(shop['zone']['shape'], name)
        end
    end)
end

-- Handler

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if not Initialized then Init() end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if next(PlayerData) ~= nil and not Initialized then
        PlayerData = QBCore.Functions.GetPlayerData()
        Init()
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

-- Event

RegisterNetEvent('qb-customs:client:showVehOptions', function()
    if InsideShop then
        exports['qb-menu']:openMenu(vehOptions)
    end
end)

RegisterNetEvent('qb-customs:client:repairVehicle', function()
    QBCore.Functions.TriggerCallback('qb-customs:server:checkMoney', function(success)
        if success then
            local vehicle = GetVehiclePedIsUsing(PlayerPedId())
            SetVehicleEngineHealth(vehicle, 1000)
            SetVehicleFixed(vehicle)
            TriggerEvent('QBCore:Notify', 'Your vehicle has been repaired', 'success')
            exports['qb-menu']:openMenu(vehOptions)
        else
            QBCore.Functions.Notify('Not enough money!', 'error')
            exports['qb-menu']:openMenu(vehOptions)
        end
    end, Config.Pricing['repair'])
end)

RegisterNetEvent('qb-customs:client:performanceMods', function()
    exports['qb-menu']:openMenu(upgradesMenu)
end)

RegisterNetEvent('qb-customs:client:cosmeticMods', function() -- TO DO
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if GetVehicleModKit(vehicle) ~= 0 then SetVehicleModKit(vehicle, 0) end
    exports['qb-menu']:openMenu(vehOptions)
end)

RegisterNetEvent('qb-customs:client:performanceOptions', function(data)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if GetVehicleModKit(vehicle) ~= 0 then SetVehicleModKit(vehicle, 0) end
    if data.upgradeType == 'engine' then
        local engineMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 11) - 1 do
            local header = 'Engine Level: '..i
            if i == -1 then header = 'Engine Level: Stock' end
            if GetVehicleMod(vehicle, 11) == i then header = header..' (Installed)' end
            local price = GetModPrice(vehicle, 'engine', i)
            local engineItem = {
                header = header,
                txt = 'Install level '..i..' engine for $'..price..'!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'engine',
                        modType = 11,
                        upgradeIndex = i,
                        price = price
                    }
                }
            }
            engineMenu[#engineMenu+1] = engineItem
        end
        engineMenu[#engineMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:performanceMods',
            }
        }
        exports['qb-menu']:openMenu(engineMenu, true)
    elseif data.upgradeType == 'brakes' then
        local brakesMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 12) - 1 do
            local header = 'Brakes Level: '..i
            if i == -1 then header = 'Brakes Level: Stock' end
            if GetVehicleMod(vehicle, 12) == i then header = header..' (Installed)' end
            local price = GetModPrice(vehicle, 'brakes', i)
            local brakesItem = {
                header = header,
                txt = 'Install level '..i..' brakes for $'..price..'!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'brakes',
                        modType = 12,
                        upgradeIndex = i,
                        price = price
                    }
                }
            }
            brakesMenu[#brakesMenu+1] = brakesItem
        end
        brakesMenu[#brakesMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:performanceMods',
            }
        }
        exports['qb-menu']:openMenu(brakesMenu, true)
    elseif data.upgradeType == 'transmission' then
        local transmissionMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 13) - 1 do
            local header = 'Transmission Level: '..i
            if i == -1 then header = 'Transmission Level: Stock' end
            if GetVehicleMod(vehicle, 13) == i then header = header..' (Installed)' end
            local price = GetModPrice(vehicle, 'transmission', i)
            local transmissionItem = {
                header = header,
                txt = 'Install level '..i..' transmission for $'..price..'!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'transmission',
                        modType = 13,
                        upgradeIndex = i,
                        price = price
                    }
                }
            }
            transmissionMenu[#transmissionMenu+1] = transmissionItem
        end
        transmissionMenu[#transmissionMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:performanceMods',
            }
        }
        exports['qb-menu']:openMenu(transmissionMenu, true)
    elseif data.upgradeType == 'suspension' then
        local suspensionMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 15) - 1 do
            local header = 'Suspension Level: '..i
            if i == -1 then header = 'Suspension Level: Stock' end
            if GetVehicleMod(vehicle, 15) == i then header = header..' (Installed)' end
            local price = GetModPrice(vehicle, 'suspension', i)
            local suspensionItem = {
                header = header,
                txt = 'Install level '..i..' suspension for $'..price..'!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'suspension',
                        modType = 15,
                        upgradeIndex = i,
                        price = price
                    }
                }
            }
            suspensionMenu[#suspensionMenu+1] = suspensionItem
        end
        suspensionMenu[#suspensionMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:performanceMods',
            }
        }
        exports['qb-menu']:openMenu(suspensionMenu, true)
    elseif data.upgradeType == 'armor' then
        local armorMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 16) - 1 do
            local header = 'Armor Level: '..i
            if i == -1 then header = 'Armor Level: Stock' end
            if GetVehicleMod(vehicle, 16) == i then header = header..' (Installed)' end
            local price = GetModPrice(vehicle, 'armor', i)
            local armorItem = {
                header = header,
                txt = 'Install level '..i..' armor for $'..price..'!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'armor',
                        modType = 16,
                        upgradeIndex = i,
                        price = price
                    }
                }
            }
            armorMenu[#armorMenu+1] = armorItem
        end
        armorMenu[#armorMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:performanceMods',
            }
        }
        exports['qb-menu']:openMenu(armorMenu, true)
    elseif data.upgradeType == 'turbo' then
        local turbo = IsToggleModOn(vehicle, 18)
        local price = GetModPrice(vehicle, 'turbo')
        if turbo then
            ToggleVehicleMod(vehicle, 18, false)
            QBCore.Functions.Notify('Turbo has been removed', 'error')
        else
            QBCore.Functions.TriggerCallback('qb-customs:server:checkMoney', function(success)
                if success then
                    ToggleVehicleMod(vehicle, 18, true)
                    QBCore.Functions.Notify('Turbo has been installed', 'success')
                else
                    QBCore.Functions.Notify('Not enough money!', 'error')
                end
            end, price)
        end
        exports['qb-menu']:openMenu(upgradesMenu)
    elseif data.upgradeType == 'maxMods' then
        local price = GetModPrice(vehicle, 'max')
        QBCore.Functions.TriggerCallback('qb-customs:server:checkMoney', function(success)
            if success then
                local performanceModIndices = { 11, 12, 13, 15, 16 }
                local max
                for _, modType in ipairs(performanceModIndices) do
                    max = GetNumVehicleMods(vehicle, tonumber(modType)) - 1
                    SetVehicleMod(vehicle, modType, max, false)
                end
                ToggleVehicleMod(vehicle, 18, true)
                QBCore.Functions.Notify('All performance upgrades installed!', 'success')
            else
                QBCore.Functions.Notify('Not enough money!', 'error')
            end
        end, price)
        exports['qb-menu']:openMenu(upgradesMenu)
    end
end)

RegisterNetEvent('qb-customs:client:install', function(data)
    QBCore.Functions.TriggerCallback('qb-customs:server:checkMoney', function(success)
        if success then
            local vehicle = GetVehiclePedIsUsing(PlayerPedId())
            local upgradeIndex = data.upgradeIndex
            local modType = data.modType
            SetVehicleMod(vehicle, modType, upgradeIndex, false)
            QBCore.Functions.Notify('Performance upgrade installed!', 'success')
        else
            QBCore.Functions.Notify('Not enough money!', 'error')
        end
    end, data.price)
    exports['qb-menu']:openMenu(upgradesMenu)
end)