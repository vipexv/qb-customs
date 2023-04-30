local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local Initialized = false
local InsideShop = nil

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
        header = 'Max Modifications',
        txt = 'Install all performance modifications!',
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
    },
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
        debugPoly = true,
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
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    SetVehicleEngineHealth(vehicle, 1000)
    SetVehicleFixed(vehicle)
    exports['qb-menu']:openMenu(vehOptions)
end)

RegisterNetEvent('qb-customs:client:performanceMods', function()
    exports['qb-menu']:openMenu(upgradesMenu)
end)

RegisterNetEvent('qb-customs:client:cosmeticMods', function()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    exports['qb-menu']:openMenu(vehOptions)
end)

RegisterNetEvent('qb-customs:client:performanceOptions', function(data)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if data.upgradeType == 'engine' then
        local engineMenu = {}
        for i = 0, GetNumVehicleMods(vehicle, 11) do
            local engineItem = {
                header = 'Engine Level: '..i,
                txt = 'Install level '..i..' engine!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'engine',
                        upgradeIndex = i
                    }
                }
            }
            engineMenu[#engineMenu+1] = engineItem
            engineMenu[#engineMenu+1] = {
                header = 'Back',
                txt = 'Return to previous menu!',
                icon = "fa-solid fa-arrow-left",
                params = {
                    event = 'qb-customs:client:performanceMods',
                }
            }
        end
        exports['qb-menu']:openMenu(engineMenu, true)
    elseif data.upgradeType == 'brakes' then
        local brakesMenu = {}
        for i=0, GetNumVehicleMods(vehicle, 12) do
            local brakesItem = {
                header = 'Brakes Level: '..i,
                txt = 'Install level '..i..' brakes!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'brakes',
                        upgradeIndex = i
                    }
                }
            }
            brakesMenu[#brakesMenu+1] = brakesItem
            brakesMenu[#brakesMenu+1] = {
                header = 'Back',
                txt = 'Return to previous menu!',
                icon = "fa-solid fa-arrow-left",
                params = {
                    event = 'qb-customs:client:performanceMods',
                }
            }
        end
        exports['qb-menu']:openMenu(brakesMenu, true)
    elseif data.upgradeType == 'transmission' then
        local transmissionMenu = {}
        for i=0, GetNumVehicleMods(vehicle, 13) do
            local transmissionItem = {
                header = 'Transmission Level: '..i,
                txt = 'Install level '..i..' transmission!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'transmission',
                        upgradeIndex = i
                    }
                }
            }
            transmissionMenu[#transmissionMenu+1] = transmissionItem
            transmissionMenu[#transmissionMenu+1] = {
                header = 'Back',
                txt = 'Return to previous menu!',
                icon = "fa-solid fa-arrow-left",
                params = {
                    event = 'qb-customs:client:performanceMods',
                }
            }
        end
        exports['qb-menu']:openMenu(transmissionMenu, true)
    elseif data.upgradeType == 'suspension' then
        local suspensionMenu = {}
        for i=0, GetNumVehicleMods(vehicle, 14) do
            local suspensionItem = {
                header = 'Suspension Level: '..i,
                txt = 'Install level '..i..' suspension!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'suspension',
                        upgradeIndex = i
                    }
                }
            }
            suspensionMenu[#suspensionMenu+1] = suspensionItem
            suspensionMenu[#suspensionMenu+1] = {
                header = 'Back',
                txt = 'Return to previous menu!',
                icon = "fa-solid fa-arrow-left",
                params = {
                    event = 'qb-customs:client:performanceMods',
                }
            }
        end
        exports['qb-menu']:openMenu(suspensionMenu, true)
    elseif data.upgradeType == 'turbo' then
        local turbo = IsToggleModOn(vehicle, 18)
        if turbo then
            ToggleVehicleMod(vehicle, 18, false)
            QBCore.Functions.Notify('Turbo has been removed', 'error')
        else
            ToggleVehicleMod(vehicle, 18, true)
            QBCore.Functions.Notify('Turbo has been installed', 'success')
        end
        exports['qb-menu']:openMenu(upgradesMenu)
    elseif data.upgradeType == 'armor' then
        local armorMenu = {}
        for i = 0, GetNumVehicleMods(vehicle, 16) do
            local armorItem = {
                header = 'Armor Level: '..i,
                txt = 'Install level '..i..' armor!',
                icon = "fa-solid fa-wrench",
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'armor',
                        upgradeIndex = i
                    }
                }
            }
            armorMenu[#armorMenu+1] = armorItem
            armorMenu[#armorMenu+1] = {
                header = 'Back',
                txt = 'Return to previous menu!',
                icon = "fa-solid fa-arrow-left",
                params = {
                    event = 'qb-customs:client:performanceMods',
                }
            }
        end
        exports['qb-menu']:openMenu(armorMenu, true)
    elseif data.upgradeType == 'maxMods' then
        local performanceModIndices = { 11, 12, 13, 15, 16 }
        local max
        SetVehicleModKit(vehicle, 0)
        for _, modType in ipairs(performanceModIndices) do
            max = GetNumVehicleMods(vehicle, tonumber(modType)) - 1
            SetVehicleMod(vehicle, modType, max, false)
        end
        ToggleVehicleMod(vehicle, 18, true)
        exports['qb-menu']:openMenu(upgradesMenu)
    end
end)

RegisterNetEvent('qb-customs:client:install', function(data)
    QBCore.Functions.TriggerCallback('qb-customs:server:install', function(success)
        if success then
            QBCore.Functions.Notify('Performance upgrade installed!', 'success')
        else
            QBCore.Functions.Notify('Not enough money!', 'error')
        end
    end, InsideShop, data)
end)