local speedBuffer, velBuffer, pauseActive, isCarHud, stress, speedMultiplier  = {0.0,0.0}, {}, false, false, 0, Config.DefaultSpeedUnit == "kmh" and 2.23694 or 2.6
Framework = nil
Framework = GetFramework()
Citizen.Await(Framework)
Callback = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.TriggerServerCallback or Framework.Functions.TriggerCallback
Player = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.GetPlayerData() or Framework.Functions.GetPlayerData()
local oldData = { players = 0, job = "", cash = 0 }

local function getPlayerData()
   local framework = Config.Framework
   if framework == "ESX" or framework == "NewESX" then
       return Framework.GetPlayerData()
   end
   return Framework.Functions.GetPlayerData()
end

local function updatePlayerData()
   PlayerData = getPlayerData()
end

AddEventHandler('onResourceStart', function(resourceName)
   if GetCurrentResourceName() == resourceName then
       updatePlayerData()
   end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function()
   updatePlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', updatePlayerData)




local display = false

function SetDisplay(bool)
   display = bool
   SetNuiFocus(bool, bool)
end

RegisterNUICallback(
"exit",
function(data)
   SetDisplay(false)
end
)


local currentState = false

local function toggleState()
  currentState = not currentState
  return currentState
end





local lastFuelUpdate = 0
function getFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        LastFuel = math.floor(Config.GetVehFuel(vehicle))
    end
    return LastFuel
end

Citizen.CreateThread(function()
while true do
   Citizen.Wait(1)
   HideHudComponentThisFrame(6) -- VEHICLE_NAME
   HideHudComponentThisFrame(7) -- AREA_NAME
   HideHudComponentThisFrame(8) -- VEHICLE_CLASS
   HideHudComponentThisFrame(9) -- STREET_NAME
   HideHudComponentThisFrame(3) -- CASH
   HideHudComponentThisFrame(4) -- MP_CASH
   DisplayAmmoThisFrame(false)
end
end)


Citizen.CreateThread(function()
   local playerPed
   while true do
      Citizen.Wait(1000)
      playerPed = PlayerPedId()
      SendNUIMessage({ action = 'ARMOR', armor = GetPedArmour(playerPed) })
      Citizen.Wait(2500)
   end
end)


local seatbeltOn = false
local speedBuffer = {nil, nil}
local velBuffer = {nil, nil}

function Fwv(entity)
   local hr = GetEntityHeading(entity) + 90.0
   if hr < 0.0 then hr = 360.0 + hr end
   hr = hr * 0.0174533
   return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

RegisterKeyMapping('seatbelt', 'Toggle Seatbelt', 'keyboard', Config.SeatbeltControl)

RegisterCommand('seatbelt', function()
   local playerPed = PlayerPedId()
   if IsPedInAnyVehicle(playerPed, false) then
      local class = GetVehicleClass(GetVehiclePedIsUsing(playerPed))
      if class ~= 8 and class ~= 13 and class ~= 14 then
         if seatbeltOn then
            -- If you want, you can put a notification belt removed information:
         else
            -- If you want, you can put a notification belt buckled information:
         end
         seatbeltOn = not seatbeltOn
      end
   end
end, false)

Citizen.CreateThread(function()
   while true do
      local playerPed = PlayerPedId()
      local Veh = GetVehiclePedIsIn(playerPed, false)
      local isCarHud = true -- Replace as per your context.

      if isCarHud then
         if seatbeltOn then DisableControlAction(0, 75) end
         speedBuffer[2] = speedBuffer[1]
         speedBuffer[1] = GetEntitySpeed(Veh)

         velBuffer[2] = velBuffer[1]
         velBuffer[1] = GetEntityVelocity(Veh)

         if speedBuffer[2] and GetEntitySpeedVector(Veh, true).y > 1.0  and speedBuffer[1] > 15 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
            if not seatbeltOn then
               local co = GetEntityCoords(playerPed)
               local fw = Fwv(playerPed)
               SetEntityCoords(playerPed, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
               SetEntityVelocity(playerPed, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
               Wait(500)
               SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
               seatbeltOn = false
            end
         end
      else
         Wait(3000)
      end
      Wait(0)
   end
end)

Citizen.CreateThread(function()
   while true do
       Citizen.Wait(1)
       local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
       if vehicle ~= 0 then
           if IsControlJustReleased(0, Config.LeftSignalControl) then
               if GetVehicleIndicatorLights(vehicle) == 3 or GetVehicleIndicatorLights(vehicle) == 2 then
                   SetVehicleIndicatorLights(vehicle, 0, false)
               elseif GetVehicleIndicatorLights(vehicle) == 0 or  GetVehicleIndicatorLights(vehicle) == 1 then
                   SetVehicleIndicatorLights(vehicle, 0, true)
               end
           end
           if IsControlJustReleased(0, Config.RightSignalControl) then
               if GetVehicleIndicatorLights(vehicle) == 1 or GetVehicleIndicatorLights(vehicle) == 3 then
                   SetVehicleIndicatorLights(vehicle, 1, false)
               elseif GetVehicleIndicatorLights(vehicle) == 0 or  GetVehicleIndicatorLights(vehicle) == 2 then
                   SetVehicleIndicatorLights(vehicle, 1, true)
               end
           end
       end
   end
end)

local isSpeedLimited = false
local speedLimitMps = 50 / 3.6 

Citizen.CreateThread(function()
   while true do
       local ped = PlayerPedId()
       local vehicle = GetVehiclePedIsIn(ped, false)

       if IsPedInVehicle(ped, vehicle, true) then
           Citizen.Wait(0) 
           if IsControlJustReleased(0, Config.SpeedLimitControl) then
               if isSpeedLimited then
                   SetEntityMaxSpeed(vehicle, 1000.0)
               else
                   SetEntityMaxSpeed(vehicle, speedLimitMps)
               end
               isSpeedLimited = not isSpeedLimited
           end
           SendNUIMessage({ action = 'SPEEDLMT', variable = isSpeedLimited })
       else
           Citizen.Wait(500)
       end
   end
end)

Citizen.CreateThread(function()
   while true do
      Citizen.Wait(1)
      HideHudComponentThisFrame(6) -- VEHICLE_NAME
      HideHudComponentThisFrame(7) -- AREA_NAME
      HideHudComponentThisFrame(8) -- VEHICLE_CLASS
      HideHudComponentThisFrame(9) -- STREET_NAME
      HideHudComponentThisFrame(3) -- CASH
      HideHudComponentThisFrame(4) -- MP_CASH
      DisplayAmmoThisFrame(false)
   end
end)

local LastData = {
   Speed = 0,
   Rpm = 0,
   Fuel = 0,
   Engine = false,
   Signal = -1,
   Light = false
}

Citizen.CreateThread(function()
   while true do
       Citizen.Wait(100)
       local ped = PlayerPedId()
       local vehicle = GetVehiclePedIsIn(ped, false)
       if IsPedInVehicle(ped, vehicle, true) then
           local LightVal, LightLights, LightHighlights = GetVehicleLightsState(vehicle)
           local Light = LightLights == 1 or LightHighlights == 1
           local Speed, Rpm, Fuel, Engine, Signal, Seatbelt = GetEntitySpeed(vehicle), GetVehicleCurrentRpm(vehicle), getFuelLevel(vehicle), GetIsVehicleEngineRunning(vehicle), GetVehicleIndicatorLights(vehicle), getSeatbeltStatus()
           SendNUIMessage({ action = 'SETCARHUD', variable = true })
           DisplayRadar(true)
           if LastData.Speed ~= Speed or LastData.Rpm ~= Rpm or LastData.Fuel ~= Fuel or LastData.Engine ~= Engine or LastData.Signal ~= Signal or LastData.Light ~= Light then
               SendNUIMessage({
                   action = 'CAR',
                   speed = math.floor(Speed * 3.6),
                   rpm = math.ceil(Rpm * 240),
                   fuel = Fuel,
                   engine = engineHealth,
                   state = Light,
                   seatbelt = Seatbelt,
                   signal = Signal,
                   type = Config.DefaultSpeedUnit,
                   gear = GetVehicleCurrentGear(vehicle)
               })
               LastData.Speed, LastData.Rpm, LastData.Fuel, LastData.Engine, LastData.Signal, LastData.Light = Speed, Rpm, Fuel, Engine, Signal, Light
           end
       else
           SendNUIMessage({ action = 'NOT' })
           DisplayRadar(false)
           Citizen.Wait(500)
       end
   end
end)

function getSeatbeltStatus() 
      return seatbeltOn
end


Citizen.CreateThread(function()
while true do
   Citizen.Wait(650)
   if IsPauseMenuActive() and not pauseActive then
      pauseActive = true
      SendNUIMessage({
         action = 'EXIT',
         args = false
      })
   end
   if not IsPauseMenuActive() and pauseActive then
      pauseActive = false
      SendNUIMessage({
         action = 'EXIT',
         args = true
      })
   end
end
end)


Citizen.CreateThread(function()
   if Config.Time == "game" then 
      while true do
         Citizen.Wait(1000) 
         
         local hour = GetClockHours() 
         local minute = GetClockMinutes() 
         local day = GetClockDayOfMonth()
         local month = GetClockMonth() 
         local year = GetClockYear()

         local formattedHour = string.format("%02d", hour)
         local formattedMinute = string.format("%02d", minute)
         -- local datetime = formattedHour .. ":" .. formattedMinute .. ", " .. day .. "/" .. month .. "/" .. year
         local datetime = formattedHour .. ":" .. formattedMinute

         SendNUIMessage({
            action = "GET_TIME",
            date = datetime
         })
      end
   end
end)


Citizen.CreateThread(function()
      while true do
         Citizen.Wait(5000) 
         Callback('Player', function(players, job, cash, ping)
            if players ~= oldData.players or job ~= oldData.job or cash ~= oldData.cash or ping ~= oldData.ping then
               SendNUIMessage({ action = 'DATA', count = players, job = job, cash = cash, ping = ping}) 
               oldData.players = players
               oldData.job = job
               oldData.cash = cash
               oldData.ping = ping
            end
         end, GetPlayerServerId(PlayerId())) 
   end
end)




if Config.Framework == "ESX" or Config.Framework == "NewESX" then

   RegisterNetEvent('HudPlayerLoad')
   AddEventHandler('HudPlayerLoad', function(source)
   Citizen.Wait(2000)

   Callback('Player', function(players, job, cash, ping)
      if players ~= oldData.players or job ~= oldData.job or cash ~= oldData.cash or ping ~= oldData.ping then
         SendNUIMessage({ action = 'DATA', count = players, job = job, cash = cash, ping = ping}) 
         oldData.players = players
         oldData.job = job
         oldData.cash = cash
         oldData.ping = ping
      end
   end, source) 

   AddEventHandler('esx_status:onTick', function(data)
   local hunger, thirst
   for i = 1, #data do
      if data[i].name == 'thirst' then
         thirst = math.floor(data[i].percent)
      elseif data[i].name == 'hunger' then
         hunger = math.floor(data[i].percent)
      end
   end
   SendNUIMessage({ action = 'STATUS', hunger = hunger, thirst = thirst }) 
   end) 
   end)

       
   RegisterNetEvent("esx_status:onTick")
   AddEventHandler("esx_status:onTick", function(data)
   for _,v in pairs(data) do
      if v.name == "hunger" then
         SendNUIMessage({
            action = "HUNGER",
            hunger = v.percent
         })
      elseif v.name == "THİRST" then
         SendNUIMessage({
            action = "thirst",
            thirst = v.percent
         })
      end
   end
   end)
   RegisterNetEvent('esx_status:update')
   AddEventHandler('esx_status:update', function(data)
   for _,v in pairs(data) do
      if v.name == "HUNGER" then
         SendNUIMessage({
            action = "hunger",
            thirst = v.pencent
         })
      elseif v.name == "THİRST" then
         SendNUIMessage({
            action = "thirst",
            thirst = v.pencent
         })
      end
   end
   end)
   

elseif Config.Framework == 'QBCore' or Config.Framework == 'OLDQBCore' then

   local function handleStatus(hunger, thirst)
      hunger = math.min(math.ceil(hunger), 100)
      thirst = math.min(math.ceil(thirst), 100)
      print(hunger, thirst)
      SendNUIMessage({
         action = "STATUS",
         hunger = hunger,
         thirst = thirst
      })
   end
   
   RegisterNetEvent('HudPlayerLoad')
   AddEventHandler('HudPlayerLoad', function(source)
      Citizen.Wait(2000)
      handleStatus(PlayerData.metadata["hunger"], PlayerData.metadata["thirst"])
      Callback('Player', function(players, job, cash, ping)
         if players ~= oldData.players or job ~= oldData.job or cash ~= oldData.cash or ping ~= oldData.ping then
            SendNUIMessage({ action = 'DATA', count = players, job = job, cash = cash, ping = ping}) 
            oldData.players = players
            oldData.job = job
            oldData.cash = cash
            oldData.ping = ping
         end
      end, source) 
   end)

   RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
      handleStatus(newHunger, newThirst)
   end)




end

Citizen.CreateThread(function()
   while true do
      Citizen.Wait(1000)
      local playerPed = PlayerPedId()
      local health = GetEntityHealth(playerPed)
      local val = health - 100
      if GetEntityModel(playerPed) == `mp_f_freemode_01` then val = (health + 25) - 100 end
      SendNUIMessage({action = 'HEALTH', health = val})
   end
end)







Citizen.CreateThread(function()
local wait, LastOxygen
while true do
   local Player = PlayerId()
   local newoxygen = GetPlayerSprintStaminaRemaining(Player)
   if IsPedInAnyVehicle(PlayerPed) then wait = 2100 end
   if LastOxygen ~= newoxygen then
      wait = 125
      if IsEntityInWater(PlayerPed) then
         oxygen = GetPlayerUnderwaterTimeRemaining(Player) * 10
      else
         oxygen = 100 - GetPlayerSprintStaminaRemaining(Player)
      end
      LastOxygen = newoxygen
      SendNUIMessage({
         action = 'OXYGEN',
         oxygen = math.ceil(oxygen),
      })
   else
      wait = 1850
   end
   Citizen.Wait(wait)
end
end)

--
local particles = {}
local vehicles2 = {}
local particles2 = {}
--


local vehiclePlate = nil

Citizen.CreateThread(function()
while true do
   Citizen.Wait(100)
   local ped = PlayerPedId()
   local vehicle = GetVehiclePedIsIn(ped, false)
   local plate = GetVehicleNumberPlateText(vehicle)
   if vehicle ~= 0 and plate ~= nil and plate == vehiclePlate then
      CurrentNossValue = NitroVeh[plate]
      SendNUIMessage({
         action = 'UPDATE_NOSS',
         noss = math.ceil(CurrentNossValue)
      })
   else
      SendNUIMessage({
         action = 'UPDATE_NOSS',
         noss = 0
      })
   end
end
end)

RegisterNetEvent('SetupNitro')
AddEventHandler('SetupNitro', function()
local Vehicle = GetVehicleInDirection()
vehiclePlate = GetVehicleNumberPlateText(Vehicle)
   if IsPedSittingInAnyVehicle(PlayerPed) then
      -- Soon
   else
      if Vehicle ~= nil and DoesEntityExist(Vehicle) and IsPedOnFoot(PlayerPed) then
         TaskStartScenarioInPlace(PlayerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
         Citizen.SetTimeout(5500, function()
         ClearPedTasksImmediately(PlayerPed)
         TriggerServerEvent('RemoveNitroItem', GetVehicleNumberPlateText(Vehicle))
         end)
      else
         -- Soon
      end
   end
end)

Citizen.CreateThread(function()
   if Config.RemoveStress["on_swimming"].enable then
      while true do
         Citizen.Wait(10000)
         if IsPedSwimming(playerPed) then
            local val = math.random(Config.RemoveStress["on_swimming"].min, Config.RemoveStress["on_swimming"].max)
            TriggerServerEvent('hud:server:RelieveStress', val)
         end
      end
   end
   end)
   
   Citizen.CreateThread(function()
   if Config.RemoveStress["on_running"].enable then
      while true do
         Citizen.Wait(10000)
         if IsPedRunning(playerPed) then
            local val = math.random(Config.RemoveStress["on_running"].min, Config.RemoveStress["on_running"].max)
            TriggerServerEvent('hud:server:RelieveStress', val)
         end
      end
   end
   end)
   
   Citizen.CreateThread(function() -- Speeding
   if Config.AddStress["on_fastdrive"].enable  then
      while true do
         local ped = PlayerPedId() -- corrected line
         if IsPedInAnyVehicle(ped, false) then
            local speed = GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * 15
            local stressSpeed = 110
            if speed >= stressSpeed then
               TriggerServerEvent('hud:server:GainStress', math.random(Config.AddStress["on_fastdrive"].min, Config.AddStress["on_fastdrive"].max))
            end
         end
         Wait(10000)
      end
   end
   end)
   
   
   CreateThread(function() -- Shooting
   if Config.AddStress["on_shoot"].enable  then
      while true do
         local ped = playerPed
         local weapon = GetSelectedPedWeapon(ped)
         if weapon ~= `WEAPON_UNARMED` then
            if IsPedShooting(ped) then
               if math.random() < 0.15 and not IsWhitelistedWeaponStress(weapon) then
                  TriggerServerEvent('hud:server:GainStress', math.random(Config.AddStress["on_shoot"].min, Config.AddStress["on_shoot"].max))
               end
            end
         else
            Wait(900)
         end
         Wait(8)
      end
   
   end
   
   end)
   
   function IsWhitelistedWeaponStress(weapon)
      if weapon then
         for _, v in pairs(Config.WhitelistedWeaponStress) do
            if weapon == v then
               return true
            end
         end
      end
      return false
   end
   
   Citizen.CreateThread(function() -- Shooting
   if Config.AddStress["on_shoot"].enable  then
      while true do
         local ped = PlayerPedId()
         local weapon = GetSelectedPedWeapon(ped)
         if weapon ~= GetHashKey('WEAPON_UNARMED') then
            if IsPedShooting(ped) then
               if math.random() < 0.15 and not IsWhitelistedWeaponStress(weapon) then
                  TriggerServerEvent('hud:server:GainStress', math.random(Config.AddStress["on_shoot"].min, Config.AddStress["on_shoot"].max))
               end
            end
         else
            Wait(900)
         end
         Wait(8)
      end
   end
   end)
   
   Citizen.CreateThread(function()
   while true do
      local ped = PlayerPedId()
      if tonumber(stress) >= 100 then
         local ShakeIntensity = GetShakeIntensity(stress)
         local FallRepeat = math.random(2, 4)
         local RagdollTimeout = (FallRepeat * 1750)
         ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
         SetFlash(0, 0, 500, 3000, 500)
   
         if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
            SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
         end
   
         Wait(500)
         for i=1, FallRepeat, 1 do
            Wait(750)
            DoScreenFadeOut(200)
            Wait(1000)
            DoScreenFadeIn(200)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 200, 750, 200)
         end
      end
   
      if stress >= 50 then
         local ShakeIntensity = GetShakeIntensity(stress)
         ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
         SetFlash(0, 0, 500, 2500, 500)
      end
      Wait(GetEffectInterval(stress))
   end
   end)
   
   
   function GetShakeIntensity(stresslevel)
      local retval = 0.05
      local Intensity = {
         ["shake"] = {
            [1] = {
               min = 50,
               max = 60,
               intensity = 0.12,
            },
            [2] = {
               min = 60,
               max = 70,
               intensity = 0.17,
            },
            [3] = {
               min = 70,
               max = 80,
               intensity = 0.22,
            },
            [4] = {
               min = 80,
               max = 90,
               intensity = 0.28,
            },
            [5] = {
               min = 90,
               max = 100,
               intensity = 0.32,
            },
         }
      }
      for k, v in pairs(Intensity['shake']) do
         if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.intensity
            break
         end
      end
      return retval
   end
   
   function GetEffectInterval(stresslevel)
      local EffectInterval = {
         [1] = {
            min = 50,
            max = 60,
            timeout = math.random(14000, 15000)
         },
         [2] = {
            min = 60,
            max = 70,
            timeout = math.random(12000, 13000)
         },
         [3] = {
            min = 70,
            max = 80,
            timeout = math.random(10000, 11000)
         },
         [4] = {
            min = 80,
            max = 90,
            timeout = math.random(8000, 9000)
         },
         [5] = {
            min = 90,
            max = 100,
            timeout = math.random(6000, 7000)
         }
      }
      local retval = 10000
      for k, v in pairs(EffectInterval) do
         if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.timeout
            break
         end
      end
      return retval
   end
   
   RegisterNetEvent('hud:client:UpdateStress', function(newStress)
   stress = newStress
   SendNUIMessage({
      action = 'STRESS',
      stress = math.ceil(newStress) * 3,
   })
   end)
   
   RegisterNetEvent('esx_basicneeds:onEat')
   AddEventHandler('esx_basicneeds:onEat', function()
   if Config.RemoveStress["on_eat"].enable then
      local val = math.random(Config.RemoveStress["on_eat"].min, Config.RemoveStress["on_eat"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   
   RegisterNetEvent('consumables:client:Eat')
   AddEventHandler('consumables:client:Eat', function()
   if Config.RemoveStress["on_eat"].enable then
      local val = math.random(Config.RemoveStress["on_eat"].min, Config.RemoveStress["on_eat"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   
   
   RegisterNetEvent('consumables:client:Drink')
   AddEventHandler('consumables:client:Drink', function()
   if Config.RemoveStress["on_drink"].enable then
      local val = math.random(Config.RemoveStress["on_drink"].min, Config.RemoveStress["on_drink"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   RegisterNetEvent('consumables:client:DrinkAlcohol')
   AddEventHandler('consumables:client:DrinkAlcohol', function()
   if Config.RemoveStress["on_drink"].enable then
      local val = math.random(Config.RemoveStress["on_drink"].min, Config.RemoveStress["on_drink"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   
   RegisterNetEvent('devcore_needs:client:StartEat')
   AddEventHandler('devcore_needs:client:StartEat', function()
   if Config.RemoveStress["on_eat"].enable then
      local val = math.random(Config.RemoveStress["on_eat"].min, Config.RemoveStress["on_eat"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   RegisterNetEvent('devcore_needs:client:DrinkShot')
   AddEventHandler('devcore_needs:client:DrinkShot', function()
   if Config.RemoveStress["on_drink"].enable then
      local val = math.random(Config.RemoveStress["on_drink"].min, Config.RemoveStress["on_drink"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   
   RegisterNetEvent('devcore_needs:client:StartDrink')
   AddEventHandler('devcore_needs:client:StartDrink', function()
   if Config.RemoveStress["on_drink"].enable then
      local val = math.random(Config.RemoveStress["on_drink"].min, Config.RemoveStress["on_drink"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   
   RegisterNetEvent('esx_optionalneeds:onDrink')
   AddEventHandler('esx_optionalneeds:onDrink', function()
   if Config.RemoveStress["on_drink"].enable then
      local val = math.random(Config.RemoveStress["on_drink"].min, Config.RemoveStress["on_drink"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   
   
   RegisterNetEvent('esx_basicneeds:onDrink')
   AddEventHandler('esx_basicneeds:onDrink', function()
   if Config.RemoveStress["on_drink"].enable then
      local val = math.random(Config.RemoveStress["on_drink"].min, Config.RemoveStress["on_drink"].max)
      TriggerServerEvent('hud:server:RelieveStress', val)
   end
   end)
   
   AddEventHandler('esx:onPlayerDeath', function()
   TriggerServerEvent('hud:server:RelieveStress', 10000)
   end)
   
   RegisterNetEvent('hospital:client:RespawnAtHospital')
   AddEventHandler('hospital:client:RespawnAtHospital', function()
   TriggerServerEvent('hud:server:RelieveStress', 10000)
   end)
   
   Citizen.CreateThread(function()
   if Config.RemoveStress["on_swimming"].enable then
      while true do
         Citizen.Wait(10000)
         if IsPedSwimming(playerPed) then
            local val = math.random(Config.RemoveStress["on_swimming"].min, Config.RemoveStress["on_swimming"].max)
            TriggerServerEvent('hud:server:RelieveStress', val)
         end
      end
   end
   end)
   
   Citizen.CreateThread(function()
   if Config.RemoveStress["on_running"].enable then
      while true do
         Citizen.Wait(10000)
         if IsPedRunning(playerPed) then
            local val = math.random(Config.RemoveStress["on_running"].min, Config.RemoveStress["on_running"].max)
            TriggerServerEvent('hud:server:RelieveStress', val)
         end
      end
   end
   end)
   -------------------------------- AAAAAAAAAAA ARABAM STRESS SEVIYOM CIFT KALE STRESSSSSSSSSSSSSSS --------------------------------------------------------


RegisterNetEvent('UpdateData')
AddEventHandler('UpdateData', function(Get)
NitroVeh = Get
end)

local isSpeedLimited = false 
local speedLimitKmh = 50.0 
local maxSpeedMps = 300.0 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustReleased(0, 38) then -- 38: "E" tuşunun scancode değeri
            local playerPed = GetPlayerPed(-1) -- Oyuncuyu al
            local vehicle = GetVehiclePedIsIn(playerPed, false) -- Oyuncunun aracını al

            if vehicle and DoesEntityExist(vehicle) then -- Eğer araç varsa ve araç geçerli bir entity ise
                if isSpeedLimited then
                    SetEntityMaxSpeed(vehicle, maxSpeedMps) -- Hız sınırlamasını kaldır

                    SendNUIMessage({
                     action = 'GET_SPEEDLMT',
                     limit = false
                    })

                else

                  SendNUIMessage({
                     action = 'GET_SPEEDLMT',
                     limit = true
                  })

                    local speedMps = speedLimitKmh / 3.6 
                    SetEntityMaxSpeed(vehicle, speedMps) 
                end

                isSpeedLimited = not isSpeedLimited 
            end
        end
    end
end)

Citizen.CreateThread(function()
   while true do
       Citizen.Wait(500) 

       local playerPed = GetPlayerPed(-1) 
       local vehicle = GetVehiclePedIsIn(playerPed, false) 
       local anyDoorOpen = false
       if vehicle and DoesEntityExist(vehicle) then 
           local vehicleClass = GetVehicleClass(vehicle) 
           if vehicleClass == 0 or vehicleClass == 1 or vehicleClass == 2 or vehicleClass == 7 or vehicleClass == 6 then 
               for i = 0, 5 do 
                   local doorAngleRatio = GetVehicleDoorAngleRatio(vehicle, i) 
                   if doorAngleRatio > 0.1 then
                       anyDoorOpen = true
                     SendNUIMessage({
                        action = 'GET_DOOR',
                        door = anyDoorOpen -- Eğer herhangi bir kapı açıksa "true", aksi takdirde "false"
                     })
                   end
               end
           end
       end
   end
end)





function GetVehicleInDirection()
   PlayerPed = PlayerPedId()
   local playerCoords = GetEntityCoords(PlayerPed)
   local inDirection  = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.0, 5.0, 0.0)
   local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, PlayerPed, 0)
   local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

   if hit == 1 and GetEntityType(entityHit) == 2 then
      return entityHit
   end

   return nil
end


RegisterKeyMapping('nitros', 'Toggle Nitro', 'keyboard', Config.NitroControl)

local isPressing = false
RegisterCommand('nitros', function()
local playerPed = PlayerPedId()
local vehicle = GetVehiclePedIsIn(playerPed, false)
local plate = GetVehicleNumberPlateText(vehicle)

if vehicle == 0 or NitroVeh[plate] == nil or tonumber(NitroVeh[plate]) <= 0 then
   return
end

isPressing = not isPressing
SetVehicleNitroBoostEnabled(vehicle, isPressing)
SetVehicleLightTrailEnabled(vehicle, isPressing)
SetVehicleNitroPurgeEnabled(vehicle, isPressing)
SetVehicleEnginePowerMultiplier(vehicle, isPressing and 55.0 or 1.0)

if isPressing then
   Citizen.CreateThread(function()
   while isPressing and GetPedInVehicleSeat(vehicle, -1) == playerPed do
      Citizen.Wait(400)
      NitroVeh[plate] = math.max(0, NitroVeh[plate] - Config.RemoveNitroOnpress)
      if tonumber(NitroVeh[plate]) <= 0 then
         isPressing = false
         SetVehicleNitroBoostEnabled(vehicle, false)
         SetVehicleLightTrailEnabled(vehicle, false)
         SetVehicleNitroPurgeEnabled(vehicle, false)
         SetVehicleEnginePowerMultiplier(vehicle, 1.0)
         TriggerServerEvent('UpdateNitro', plate, NitroVeh[plate])
         break
      end
   end
   end)
else
   TriggerServerEvent('UpdateNitro', plate, NitroVeh[plate])
end
end)


function CreateVehicleExhaustBackfire(vehicle, scale)
   local exhaustNames = {
      "exhaust",    "exhaust_2",  "exhaust_3",  "exhaust_4",
      "exhaust_5",  "exhaust_6",  "exhaust_7",  "exhaust_8",
      "exhaust_9",  "exhaust_10", "exhaust_11", "exhaust_12",
      "exhaust_13", "exhaust_14", "exhaust_15", "exhaust_16"
   }

   for _, exhaustName in ipairs(exhaustNames) do
      local boneIndex = GetEntityBoneIndexByName(vehicle, exhaustName)

      if boneIndex ~= -1 then
         local pos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
         local off = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)

         UseParticleFxAssetNextCall('core')
         StartParticleFxNonLoopedOnEntity('veh_backfire', vehicle, off.x, off.y, off.z, 0.0, 0.0, 0.0, scale, false, false, false)
      end
   end
end

function CreateVehiclePurgeSpray(vehicle, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale)
   UseParticleFxAssetNextCall('core')
   return StartParticleFxLoopedOnEntity('ent_sht_steam', vehicle, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, false, false, false)
end

function CreateVehicleLightTrail(vehicle, bone, scale)
   UseParticleFxAssetNextCall('core')
   local ptfx = StartParticleFxLoopedOnEntityBone('veh_light_red_trail', vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, bone, scale, false, false, false)
   SetParticleFxLoopedEvolution(ptfx, "speed", 1.0, false)
   return ptfx
end

function StopVehicleLightTrail(ptfx, duration)
   Citizen.CreateThread(function()
   local startTime = GetGameTimer()
   local endTime = GetGameTimer() + duration
   while GetGameTimer() < endTime do
      Citizen.Wait(0)
      local now = GetGameTimer()
      local scale = (endTime - now) / duration
      SetParticleFxLoopedScale(ptfx, scale)
      SetParticleFxLoopedAlpha(ptfx, scale)
   end
   StopParticleFxLooped(ptfx)
   end)
end

function IsVehicleLightTrailEnabled(vehicle)
   return vehicles2[vehicle] == true
end

function SetVehicleLightTrailEnabled(vehicle, enabled)
   if IsVehicleLightTrailEnabled(vehicle) == enabled then
      return
   end

   if enabled then
      local ptfxs = {}

      local leftTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_l"), 1.0)
      local rightTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_r"), 1.0)

      table.insert(ptfxs, leftTrail)
      table.insert(ptfxs, rightTrail)

      vehicles2[vehicle] = true
      particles2[vehicle] = ptfxs
   else
      if particles2[vehicle] and #particles2[vehicle] > 0 then
         for _, particleId in ipairs(particles2[vehicle]) do
            StopVehicleLightTrail(particleId, 500)
         end
      end

      vehicles2[vehicle] = nil
      particles2[vehicle] = nil
   end
end
function SetVehicleNitroBoostEnabled(vehicle, enabled)


   if IsPedInVehicle(PlayerPedId(), vehicle) then
      SetNitroBoostScreenEffectsEnabled(enabled)
   end

   SetVehicleBoostActive(vehicle, enabled)
end
function IsVehicleNitroPurgeEnabled(vehicle)
   return NitroVeh[vehicle] == true
end
function SetVehicleNitroPurgeEnabled(vehicle, enabled)
   if IsVehicleNitroPurgeEnabled(vehicle) == enabled then
      return
   end
   if enabled then
      local bone = GetEntityBoneIndexByName(vehicle, 'bonnet')
      local pos = GetWorldPositionOfEntityBone(vehicle, bone)
      local off = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)
      local ptfxs = {}

      for i=0,3 do
         local leftPurge = CreateVehiclePurgeSpray(vehicle, off.x - 0.5, off.y + 0.05, off.z, 40.0, -20.0, 0.0, 0.5)
         local rightPurge = CreateVehiclePurgeSpray(vehicle, off.x + 0.5, off.y + 0.05, off.z, 40.0, 20.0, 0.0, 0.5)

         table.insert(ptfxs, leftPurge)
         table.insert(ptfxs, rightPurge)
      end

      NitroVeh[vehicle] = true
      particles[vehicle] = ptfxs
   else
      if particles[vehicle] and #particles[vehicle] > 0 then
         for _, particleId in ipairs(particles[vehicle]) do
            StopParticleFxLooped(particleId)
         end
      end

      NitroVeh[vehicle] = nil
      particles[vehicle] = nil
   end
end
function SetNitroBoostScreenEffectsEnabled(enabled)
   if enabled then
      StartScreenEffect('RaceTurbo', 0, false)
      SetTimecycleModifier('rply_motionblur')
      ShakeGameplayCam('SKY_DIVING_SHAKE', 0.30)
      TriggerServerEvent("InteractSound_SV:PlayOnSource", "nitro", 0.5)
   else
      StopScreenEffect('RaceTurbo')
      StopGameplayCamShaking(true)
      SetTransitionTimecycleModifier('default', 0.35)
   end
end

Citizen.CreateThread(function()
   local x, y = GetActiveScreenResolution()
 
   local minimap = RequestScaleformMovie("minimap")
   local defaultAspectRatio = x/y -- Don't change this.
   local resolutionX, resolutionY = GetActiveScreenResolution()
   local aspectRatio = resolutionX/resolutionY
   local minimapOffset = 0.0087
 
   if aspectRatio > defaultAspectRatio then
     minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.008
   end
 
   RequestStreamedTextureDict("squaremap", false)
 
   while not HasStreamedTextureDictLoaded("squaremap") do
     Wait(150)
   end
 
   SetMinimapClipType(0)
   AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
   AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
   -- 0.0 = nav symbol and icons left
   -- 0.1638 = nav symbol and icons stretched
   -- 0.216 = nav symbol and icons raised up
   SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
 
   -- icons within map
   SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
 
   -- -0.01 = map pulled left
   -- 0.025 = map raised up
   -- 0.262 = map stretched
   -- 0.315 = map shorten
   SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.002 + minimapOffset, 0.0243, 0.2589, 0.278)

 
   SetBlipAlpha(GetNorthRadarBlip(), 0)
   SetRadarBigmapEnabled(true, false)
   SetMinimapClipType(0)
   Wait(0)
   SetRadarBigmapEnabled(false, false)
 
   BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
   Wait(50)
   ScaleformMovieMethodAddParamInt(3)
   EndScaleformMovieMethod()
end)




-- Minimap update
CreateThread(function()
while true do
   SetRadarBigmapEnabled(false, false)
   SetRadarZoom(1000)
   SetBigmapActive(false, false)
   Wait(4)
end
end)
