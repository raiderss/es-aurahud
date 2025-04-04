PlayerStress = {}
Framework = GetFramework()
Citizen.Await(Framework)
Callback = (Config.Framework == "ESX" or Config.Framework == "NewESX") and Framework.RegisterServerCallback or Framework.Functions.CreateCallback
Players = (Config.Framework == "ESX" or Config.Framework == "NewESX") and Framework.GetPlayers() or Framework.Functions.GetPlayers()
NitroVeh = {}
stressData = {}

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    for _ in pairs(GetPlayers()) do
        TriggerClientEvent('HudPlayerLoad', -1)
        Wait(74)
    end
end)

Callback('Player', function(source, cb)
    local count = #Players
    local xPlayer, job, cash, ping
    local isESX = Config.Framework == "ESX" or Config.Framework == "NewESX"
    
    xPlayer = isESX and Framework.GetPlayerFromId(source) or Framework.Functions.GetPlayer(source)
    if not xPlayer then return end
    
    job = isESX and xPlayer.job.label .. " " .. xPlayer.job.name or xPlayer.PlayerData.job.label .. " " .. xPlayer.PlayerData.job.name
    cash = isESX and xPlayer.getMoney() or xPlayer.PlayerData.money.cash
    ping = GetPlayerPing(source)
    
    cb(count, job, cash, ping)
end)

if Config.Framework == "ESX" or Config.Framework == "NewESX" then
    RegisterCommand(Config.Refresh, function(source)
        TriggerClientEvent('HudPlayerLoad', source)
    end)

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(src)
        Wait(1000)
        TriggerClientEvent('HudPlayerLoad', src)
    end)
else
    Framework = exports["qb-core"]:GetCoreObject()

    RegisterCommand(Config.Refresh, function(source)
        TriggerClientEvent('HudPlayerLoad', source)
    end)

    RegisterNetEvent('QBCore:Server:OnPlayerLoaded')
    AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
        TriggerClientEvent('HudPlayerLoad', source)
    end)
end

RegisterServerEvent('RemoveNitroItem')
AddEventHandler('RemoveNitroItem', function(Plate)
    local isESX = Config.Framework == "ESX" or Config.Framework == "NewESX"
    if isESX then
        Framework.GetPlayerFromId(source).removeInventoryItem(Config.NitroItem, 1)
    else
        Framework.Functions.GetPlayer(source).Functions.RemoveItem(Config.NitroItem, 1)
    end
    
    if Plate then
        NitroVeh[Plate] = 100
        TriggerClientEvent('UpdateData', -1, NitroVeh, Plate)
    end
end)

RegisterServerEvent('UpdateNitro')
AddEventHandler('UpdateNitro', function(Plate, Get)
    if Plate and NitroVeh[Plate] then
        NitroVeh[Plate] = Get
        TriggerClientEvent('UpdateData', -1, NitroVeh)
    end
end)

RegisterNetEvent('SetStress', function(amount)
    local isESX = Config.Framework == "ESX" or Config.Framework == "NewESX"
    local Player = isESX and Framework.GetPlayerFromId(source) or Framework.Functions.GetPlayer(source)
    if not Player then return end
    
    local JobName = isESX and Player.job.label or Player.PlayerData.job.label
    local ID = isESX and Player.identifier or Player.PlayerData.citizenid
    
    if Config.DisablePoliceStress and JobName == 'police' then return end
    if not PlayerStress[ID] then PlayerStress[ID] = 0 end
    
    local newStress = math.min(math.max(PlayerStress[ID] + amount, 0), 100)
    PlayerStress[ID] = newStress
    TriggerClientEvent('UpdateStress', source, PlayerStress[ID])
end)

Citizen.CreateThread(function()
    Citizen.Wait(3500)
    UsableItem = (Config.Framework == "ESX" or Config.Framework == "NewESX") and Framework.RegisterUsableItem or Framework.Functions.CreateUseableItem
    UsableItem(Config.NitroItem, function(source)
        TriggerClientEvent('SetupNitro', source)
    end)
end)

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local identifier = GetIdentifier(src)
    if IsWhitelisted(src) then return end
    
    local newStress = math.min(math.max((tonumber(stressData[identifier]) or 0) + amount, 0), 100)
    stressData[identifier] = newStress
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local identifier = GetIdentifier(src)
    local newStress = math.min(math.max((tonumber(stressData[identifier]) or 0) - amount, 0), 100)
    stressData[identifier] = newStress
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
end)

function IsWhitelisted(source)
    local isESX = Config.Framework == 'ESX' or Config.Framework == 'NewESX'
    local player = isESX and Framework.GetPlayerFromId(source) or Framework.Functions.GetPlayer(source)
    if not player then return false end
    
    local jobName = isESX and player.job.name or player.PlayerData.job.name
    for _, v in pairs(Config.StressWhitelistJobs) do
        if jobName == v then return true end
    end
    return false
end

function GetIdentifier(source)
    local isESX = Config.Framework == "ESX" or Config.Framework == "NewESX"
    if isESX then
        local xPlayer = Framework.GetPlayerFromId(tonumber(source))
        return xPlayer and xPlayer.getIdentifier() or "0"
    else
        local Player = Framework.Functions.GetPlayer(tonumber(source))
        return Player and Player.PlayerData.citizenid or "0"
    end
end
