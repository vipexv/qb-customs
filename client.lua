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

-- Plate/Wheel Options need to be Done.
local cosmeticOptions = {
    {
        header = 'Spoilers',
        txt = 'Change the spoiler on your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'spoilers'
            }
        }
    },
    {
        header = 'Rear Bumpers',
        txt = 'Customize the rear bumpers of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'rear_bumpers'
            }
        }
    },
        {
        header = 'Front Bumpers',
        txt = 'Customize the Front bumpers of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'front_bumpers'
            }
        }
    },

    {
        header = 'Skirts',
        txt = 'Add or change the side skirts of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'skirts'
            }
        }
    },
    {
        header = 'Exhaust',
        txt = 'Upgrade or modify the exhaust system of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'exhaust'
            }
        }
    },
    {
        header = 'Grille',
        txt = 'Change the front grille of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'grille'
            }
        }
    },
    {
        header = 'Hood',
        txt = 'Modify or replace the hood of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'hood'
            }
        }
    },
    {
        header = 'Roof',
        txt = 'Customize the roof of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'roof'
            }
        }
    },
    {
        header = 'Wheels',
        txt = 'Change the wheels and rims of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'wheels'
            }
        }
    },
    {
        header = 'Plate',
        txt = 'Customize the license plate of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'plate'
            }
        }
    },
    {
        header = 'Window Tint',
        txt = 'Change the window tint of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'windowTint'
            }
        }
    },
    {
        header = 'Lights',
        txt = 'Upgrade or modify the lights of your vehicle!',
        icon = "fa-solid fa-paint-roller",
        params = {
            event = 'qb-customs:client:cosmeticOptions',
            args = {
                optionType = 'lights'
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

    local tintOptions = {
        {
            header = 'No Tint',
            txt = 'Remove window tint from your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 0
                }
            }
        },
        {
            header = 'Light Smoke',
            txt = 'Apply light smoke window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 1
                }
            }
        },
        {
            header = 'Dark Smoke',
            txt = 'Apply dark smoke window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 2
                }
            }
        },
        {
            header = 'Limo',
            txt = 'Apply limo window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 3
                }
            }
        },
        {
            header = 'Green',
            txt = 'Apply green window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 4
                }
            }
        },
        {
            header = 'Blue',
            txt = 'Apply blue window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 5
                }
            }
        },
        {
            header = 'Red',
            txt = 'Apply red window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 6
                }
            }
        },
        {
            header = 'Yellow',
            txt = 'Apply yellow window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 7
                }
            }
        },
        {
            header = 'Black',
            txt = 'Apply black window tint to your vehicle!',
            icon = "fa-solid fa-sun",
            params = {
                event = 'qb-customs:client:applyTint',
                args = {
                    tintLevel = 8
                }
            }
        },
        {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
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

RegisterNetEvent('qb-customs:client:cosmeticMods', function() -- TO DO
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if GetVehicleModKit(vehicle) ~= 0 then SetVehicleModKit(vehicle, 0) end
    exports['qb-menu']:openMenu(cosmeticOptions)
end)

RegisterNetEvent('qb-customs:client:cosmeticOptions', function(data)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if data.optionType == 'spoilers' then
        local spoilersMenu = {}
        for i = -1, GetNumVehicleMods(vehicle, 0) do
            local header = 'Spoiler Type: ' .. i
            local price = Config.Pricing['cosmetics']['spoiler']
            if i == -1 then
                header = 'Spoiler Type: Stock'
                price = 0
            end
            local spoilerItem = {
                header = header,
                txt = 'Install Level ' .. i .. ' Spoiler for $' .. price .. '!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'spoilers',
                        modType = 0,
                        upgradeIndex = i,
                        price = price
                    }
                }
            }
            spoilersMenu[#spoilersMenu + 1] = spoilerItem
        end
        spoilersMenu[#spoilersMenu + 1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(spoilersMenu, true)
    elseif data.optionType == 'front_bumpers' then
        local bumpersMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 1) do
            local header = 'Front Bumper Type: '..i
            local price = Config.Pricing['cosmetics']['front_bumper']
            if i == -1 then
            header = 'Front Bumper Type: Stock' 
            price = 0    
            end
            if GetVehicleMod(vehicle, 1) == i then header = header..' (Installed)' end
            local bumperItem = {
                header = header,
                price = price,
                txt = 'Install Level ' ..i.. ' Front Bumper for $'..price..'!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'front_bumpers',
                        modType = 1,
                        upgradeIndex = i,
                        price = price
                    }
              }
            }
            bumpersMenu[#bumpersMenu + 1] = bumperItem
        end
        bumpersMenu[#bumpersMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(bumpersMenu, true)
    elseif data.optionType == 'rear_bumpers' then
        local bumpersMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 2) do
            local header = 'Rear Bumper Type: '..i
            local price = Config.Pricing['cosmetics']['rear_bumper']
            if i == -1 then 
            header = 'Rear Bumper Type: Stock' 
            price = 0
            end
            if GetVehicleMod(vehicle, 2) == i then header = header..' (Installed)' end
            local bumperItem = {
                header = header,
                price = price,
                txt = 'Install Level ' ..i.. ' Rear Bumper for $'..price..'!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'rear_bumpers',
                        modType = 2,
                        upgradeIndex = i,
                        price = price
                    }
              }
            }
            bumpersMenu[#bumpersMenu + 1] = bumperItem
        end
        bumpersMenu[#bumpersMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(bumpersMenu, true)
     elseif data.optionType == 'skirts' then
        local skirtsMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 3) do
            local header = 'Skirts Type: '..i
            local price = Config.Pricing['cosmetics']['skirts']
            if i == -1 then 
                header = 'Skirts Type: Stock'
                price = 0
            end
            if GetVehicleMod(vehicle, 3) == i then header = header..' (Installed)' end
            local skirtsItem = {
                header = header,
                price = price,
                txt = 'Install Level ' ..i.. ' Skirts for $'..price..'!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'skirts',
                        modType = 3,
                        upgradeIndex = i,
                        price = price
                    }
              }
            }
            skirtsMenu[#skirtsMenu + 1] = skirtsItem
        end
        skirtsMenu[#skirtsMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(skirtsMenu, true)
       elseif data.optionType == 'exhaust' then
        local exhaustMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 4) do
            local header = 'Exhaust Type: '..i
            local price = Config.Pricing['cosmetics']['exhaust']
            if i == -1 then 
            header = 'Exhaust Type: Stock'
            price = 0 
            end
            if GetVehicleMod(vehicle, 4) == i then header = header..' (Installed)' end
            local exhaustItem = {
                header = header,
                price = price,
                txt = 'Install Level ' ..i.. ' Exhaust for $'..price..'!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'skirts',
                        modType = 4,
                        upgradeIndex = i,
                        price = price
                    }
              }
            }
            exhaustMenu[#exhaustMenu + 1] = exhaustItem
        end
        exhaustMenu[#exhaustMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(exhaustMenu, true)
     elseif data.optionType == 'grille' then
        local grilleMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 6) do
            local header = 'Grille Type: '..i
            local price = Config.Pricing['cosmetics']['grille']
            if i == -1 then 
                header = 'Grille Type: Stock'
                price = 0
            end
            if GetVehicleMod(vehicle, 6) == i then header = header..' (Installed)' end
            local grilleItem = {
                header = header,
                price = price,
                txt = 'Install Level ' ..i.. ' Grille for $'..price..'!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'grille',
                        modType = 6,
                        upgradeIndex = i,
                        price = price
                    }
              }
            }
            grilleMenu[#grilleMenu + 1] = grilleItem
        end
        grilleMenu[#grilleMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(grilleMenu, true)
     elseif data.optionType == 'hood' then
        local hoodMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 7) do
            local header = 'Hood Type: '..i
            local price = Config.Pricing['cosmetics']['hood']
            if i == -1 then 
                header = 'Hood Type: Stock'
                price = 0
            end
            if GetVehicleMod(vehicle, 7) == i then header = header..' (Installed)' end
            local hoodItem = {
                header = header,
                price = price,
                txt = 'Install Level ' ..i.. ' Hood for $'..price..'!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'hood',
                        modType = 7,
                        upgradeIndex = i,
                        price = price
                    }
              }
            }
            hoodMenu[#hoodMenu + 1] = hoodItem
        end
        hoodMenu[#hoodMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(hoodMenu, true)
    elseif data.optionType == 'roof' then
        local roofMenu = {}
        for i=-1, GetNumVehicleMods(vehicle, 10) do
            local header = 'Roof Type: '..i
            local price = Config.Pricing['cosmetics']['roof']
            if i == -1 then 
                header = 'Roof Type: Stock'
                price = 0
            end
            if GetVehicleMod(vehicle, 10) == i then header = header..' (Installed)' end
            local roofItem = {
                header = header,
                price = price,
                txt = 'Install Level ' ..i.. ' Roof for $'..price..'!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'skirts',
                        modType = 10,
                        upgradeIndex = i,
                        price = price
                    }
              }
            }
            roofMenu[#roofMenu + 1] = roofItem
        end
        roofMenu[#roofMenu+1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(roofMenu, true)
     elseif data.optionType == 'windowTint' then
     exports['qb-menu']:openMenu(tintOptions, true)
         elseif data.optionType == 'wheels' then
        local wheelsMenu = {}
        for i = -1, GetNumVehicleMods(vehicle, 23) do
            local header = 'Wheels Type: ' .. i
            local price = Config.Pricing['cosmetics']['wheels']
            if i == -1 then
                header = 'Wheels Type: Stock'
                price = 0
            end
            local wheelsItem = {
                header = header,
                txt = 'Install Level ' .. i .. ' Wheels for $' .. price .. '!',
                icon = 'fa-solid fa-wrench',
                params = {
                    event = 'qb-customs:client:install',
                    args = {
                        upgradeType = 'wheels',
                        modType = 23,
                        upgradeIndex = i,
                        price = price
                    }
                }
            }
            wheelsMenu[#wheelsMenu + 1] = wheelsItem
        end
        wheelsMenu[#wheelsMenu + 1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(wheelsMenu, true)
    elseif data.optionType == 'lights' then
        local price = Config.Pricing['cosmetics']['lights']
    local xenonMenu = {
        {
            header = 'Toggle Xenon Lights On',
            txt = 'Turn Xenon Lights On | Price: $'..price,
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'toggleMod',
                    modType = 22,
                    state = true,
                    price = price
                }
            }
        },
         {
            header = 'Toggle Xenon Lights Off',
            txt = 'Turn Xenon Lights Off | Price: Free',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'toggleMod',
                    modType = 22,
                    state = false,
                    price = 0
                }
            }
        }
    }
        xenonMenu[#xenonMenu + 1] = {
            header = 'Back',
            txt = 'Return to previous menu!',
            icon = "fa-solid fa-arrow-left",
            params = {
                event = 'qb-customs:client:cosmeticMods',
            }
        }
        exports['qb-menu']:openMenu(xenonMenu, true)
elseif data.optionType == 'plate' then
    price = Config.Pricing['cosmetics']['plates']
    local plateMenu = {
        {
            header = 'Blue on White 1',
            txt = 'Change Plate to Blue on White 1',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'plate',
                    modType = 0,
                    upgradeIndex = 0,
                    price = price
                }
            }
        },
        {
            header = 'Blue on White',
            txt = 'Change Plate to Blue on White 2',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'plate',
                    modType = 0,
                    upgradeIndex = 0,
                    price = price
                }
            }
        },
        {
            header = 'Yellow On Black',
            txt = 'Change Plate to Blue on White 3',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'plate',
                    modType = 0,
                    upgradeIndex = 1,
                    price = price
                }
            }
        },
        {
            header = 'Yellow on Blue',
            txt = 'Change Plate to Yellow on Black',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'plate',
                    modType = 0,
                    upgradeIndex = 2,
                    price = price
                }
            }
        },
        {
            header = 'Blue on White 2',
            txt = 'Change Plate to Yellow on Blue',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'plate',
                    modType = 0,
                    upgradeIndex = 3,
                    price = price
                }
            }
        },
        {
            header = 'Blue on White 3',
            txt = 'Change Plate to Blue on White 5',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'plate',
                    modType = 0,
                    upgradeIndex = 4,
                    price = price
                }
            }
        },
        {
            header = 'Yankton',
            txt = 'Change Plate to Yankton',
            icon = 'fa-solid fa-car',
            params = {
                event = 'qb-customs:client:install',
                args = {
                    upgradeType = 'plate',
                    modType = 0,
                    upgradeIndex = 5,
                    price = price
                }
            }
        }
    }

    plateMenu[#plateMenu + 1] = {
        header = 'Back',
        txt = 'Return to previous menu!',
        icon = "fa-solid fa-arrow-left",
        params = {
            event = 'qb-customs:client:cosmeticMods',
        }
    }

    exports['qb-menu']:openMenu(plateMenu, true)

    end
end)

RegisterNetEvent('qb-customs:client:performanceMods', function()
    exports['qb-menu']:openMenu(upgradesMenu)
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
            if data.upgradeType == 'toggleMod' then
                 local state = IsToggleModOn(vehicle, data.modType)
                 ToggleVehicleMod(vehicle, data.modType, data.state)
            end
            if data.upgradeType == 'plate' then
                SetVehicleNumberPlateTextIndex(vehicle, data.upgradeIndex)
            else
            local upgradeIndex = data.upgradeIndex
            local modType = data.modType
            SetVehicleMod(vehicle, modType, upgradeIndex, false)
            QBCore.Functions.Notify('Upgrade installed!', 'success')
            end
        else
            QBCore.Functions.Notify('Not enough money!', 'error')
        end
    end, data.price)
    exports['qb-menu']:openMenu(vehOptions)
end)

RegisterNetEvent('qb-customs:client:applyTint', function(data)
    QBCore.Functions.TriggerCallback('qb-customs:server:checkMoney', function(success)
        if success then
            local vehicle = GetVehiclePedIsUsing(PlayerPedId())
            local tintLevel = data.tintLevel
            SetVehicleWindowTint(vehicle, tintLevel)
        end
    end, Config.Pricing['cosmetics']['windowTints'])
end)

RegisterNetEvent('qb-customs:client:toggleMod', function(data)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    ToggleVehicleMod(vehicle, data.mod, data.state)
end)