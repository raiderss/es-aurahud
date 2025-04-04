Config = {}

Config.Framework  = 'QBCore' -- QBCore or ESX or OLDQBCore -- NewESX

Config.Refresh = 'HudRefresh'

Config.SpeedLimitControl = 47


Config.StressChance = 0.1 -- Default: 10% -- Percentage Stress Chance When Shooting (0-1)
Config.MinimumStress = 50 -- Minimum Stress Level For Screen Shaking
Config.WhitelistedWeaponStress = {
    `weapon_petrolcan`,
    `weapon_hazardcan`,
    `weapon_fireextinguisher`
}


Config.MinimumSpeed = 10 -- Going Over This Speed Will Cause Stress
Config.MinimumSpeedUnbuckled = 50 -- Going Over This Speed Will Cause Stress
Config.DisablePoliceStress = true -- If true will disable stress for people with the police job

Config.GetVehFuel = function(Veh)
      return GetVehicleFuelLevel(Veh)-- exports["LegacyFuel"]:GetFuel(Veh)
end

Config.NitroItem = "nitrous" -- item to install nitro to a vehicle - noss
Config.NitroControl = "G"
Config.NitroForce = 40.0 -- Nitro force when player using nitro
Config.RemoveNitroOnpress = 2 -- Determines of how much you want to remove nitro when player press nitro key
Config.SeatbeltControl = 'k'  -- Control switch for seat belt (Players can change the key according to their wishes)


function GetFramework()
    local Get = nil
    if Config.Framework  == "ESX" then
        while Get == nil do
            TriggerEvent('esx:getSharedObject', function(Set) Get = Set end)
            Citizen.Wait(0)
        end
    end
    if Config.Framework  == "NewESX" then
        Get = exports['es_extended']:getSharedObject()
    end
    if Config.Framework  == "QBCore" then
        Get = exports["qb-core"]:GetCoreObject()
    end
    if Config.Framework  == "OldQBCore" then
        while Get == nil do
            TriggerEvent('QBCore:GetObject', function(Set) Get = Set end)
            Citizen.Wait(200)
        end
    end
    return Get
 end

 -- Stress Mechanics
Config.StressChance = 0.1  -- Default: 10% -- Percentage Stress Chance When Shooting (0-1)
Config.MinimumStress = 50  -- Minimum Stress Level For Screen Shaking
Config.WhitelistedWeaponStress = {
    `weapon_petrolcan`,
    `weapon_hazardcan`,
    `weapon_fireextinguisher`
}

-- Signal Control
Config.SignalControl = false
Config.RightSignalControl = 174  -- > : 174
Config.LeftSignalControl = 175  -- < : 175

-- Stress Mechanics Control
Config.UseStress = false  -- If you set this to false, the stress HUD will be removed
Config.StressWhitelistJobs = {  -- Add here jobs you want to disable stress
    'police', 'ambulance'
}

-- Stress Mechanics Increment
Config.AddStress = {
    ["on_shoot"] = {
        min = 1,
        max = 3,
        enable = true,
    },
    ["on_fastdrive"] = {
        min = 1,
        max = 3,
        enable = true,
    },
}

-- Stress Mechanics Decrement
Config.RemoveStress = {
    ["on_eat"] = {
        min = 5,
        max = 10,
        enable = true,
    },
    ["on_drink"] = {
        min = 5,
        max = 10,
        enable = true,
    },
    ["on_swimming"] = {
        min = 5,
        max = 10,
        enable = true,
    },
    ["on_running"] = {
        min = 5,
        max = 10,
        enable = true,
    },
}

-- Speed-Based Stress
Config.MinimumSpeed = 10  -- Going Over This Speed Will Cause Stress
Config.MinimumSpeedUnbuckled = 50  -- Going Over This Speed Will Cause Stress
Config.DisablePoliceStress = true  -- If true, will disable stress for people with the police job

-- Stress Intensity Levels
Config.Intensity = {
    [1] = {
        min = 50,
        max = 60,
        intensity = 1500,
    },
    [2] = {
        min = 60,
        max = 70,
        intensity = 2000,
    },
    [3] = {
        min = 70,
        max = 80,
        intensity = 2500,
    },
    [4] = {
        min = 80,
        max = 90,
        intensity = 2700,
    },
    [5] = {
        min = 90,
        max = 100,
        intensity = 3000,
    },
}

-- Stress Effect Interval
Config.EffectInterval = {
    [1] = {
        min = 50,
        max = 60,
        timeout = math.random(50000, 60000),
    },
    [2] = {
        min = 60,
        max = 70,
        timeout = math.random(40000, 50000),
    },
    [3] = {
        min = 70,
        max = 80,
        timeout = math.random(30000, 40000),
    },
    [4] = {
        min = 80,
        max = 90,
        timeout = math.random(20000, 30000),
    },
    [5] = {
        min = 90,
        max = 100,
        timeout = math.random(15000, 20000),
    },
}