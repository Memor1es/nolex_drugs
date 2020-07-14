ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local started = false
local displayed = false
local progress = 0
local CurrentVehicle 
local pause = false
local selection = 0
local quality = 0
local LastCar

local ingridientsRun = false
local LabSetup = false
local CurrentZone = nil

local IngridientsLocations = {
	Patareid = {
		Pos = {x = 4.304,y = 6466.657,z = 30.425},
	},

	AceStone = {
		Pos = {x = 2676.82,y = 3513.29,z = 51.712},
	},

	Powder = {
		Pos = {x = 900.241,y = -2537.254,z = 27.285},
	}
}

RegisterNetEvent('nolex_drugs:stop')
AddEventHandler('nolex_drugs:stop', function()
	started = false
	FreezeEntityPosition(LastCar, false)
end)

RegisterNetEvent('nolex_drugs:stopfreeze')
AddEventHandler('nolex_drugs:stopfreeze', function(id)
	FreezeEntityPosition(id, false)
end)

RegisterNetEvent('nolex_drugs:startprod')
AddEventHandler('nolex_drugs:startprod', function()
	DisplayHelpText("~g~Starting production")
	started = true
	FreezeEntityPosition(CurrentVehicle,true)
	displayed = false

	print('Started Meth production')

	SetPedIntoVehicle(PlayerPedId(), CurrentVehicle, 3)
	SetVehicleDoorOpen(CurrentVehicle, 2)
end)

RegisterNetEvent('nolex_drugs:blowup')
AddEventHandler('nolex_drugs:blowup', function(posx, posy, posz)
	AddExplosion(posx, posy, posz + 2,23, 20.0, true, false, 1.0, true)

	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Wait(1)
		end
	end

	SetPtfxAssetNextCall("core")
	local fire = StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", posx, posy, posz-0.8 , 0.0, 0.0, 0.0, 0.8, false, false, false, false)

	Wait(6000)

	StopParticleFxLooped(fire, 0)
end)


RegisterNetEvent('nolex_drugs:smoke')
AddEventHandler('nolex_drugs:smoke', function(posx, posy, posz, bool)
	if bool == 'a' then

		if not HasNamedPtfxAssetLoaded("core") then
			RequestNamedPtfxAsset("core")
			while not HasNamedPtfxAssetLoaded("core") do
				Wait(1)
			end
		end

		SetPtfxAssetNextCall("core")

		local smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", posx, posy, posz + 1.7, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
		SetParticleFxLoopedAlpha(smoke, 0.8)
		SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)

		Wait(22000)

		StopParticleFxLooped(smoke, 0)

	else
		StopParticleFxLooped(smoke, 0)
	end
end)

RegisterCommand("meth", function()
	local playerPed = PlayerPedId()

	if IsPedInAnyVehicle(playerPed) then
	
		local CurrentVehicle = GetVehiclePedIsUsing(PlayerPedId())
		local car = GetVehiclePedIsIn(playerPed, false)

		local model = GetEntityModel(CurrentVehicle)
		local modelName = GetDisplayNameFromVehicleModel(model)
		
		if modelName == 'JOURNEY' and car then

			if GetPedInVehicleSeat(car, -1) == playerPed then
				WarMenu.OpenMenu("methLab")
			end

		end

	end
end)

AddEventHandler("nolex_drugs:HasEnteredMarker", function(zone)
	if zone == 'Patareid' then
		CurrentZone = 'PatareidLoc'
	elseif zone == 'AceStone' then
		CurrentZone = 'AceStoneLoc'
	elseif zone == 'Powder' then
		CurrentZone = 'PowderLoc'
	end
end)

AddEventHandler("nolex_drugs:HasLeftMarker", function()
	CurrentZone = nil
end)


local ingridentsID = "ingridientsRun"

local location = ''
local hasEnteredMarker = false

Citizen.CreateThread(function()

	WarMenu.CreateMenu("methLab", "Meth Lab")
	WarMenu.SetMenuX("methLab", 0.75)
	WarMenu.SetMenuY("methLab", 0.25)

	while true do

		if WarMenu.IsMenuOpened("methLab") then

			if WarMenu.Button("Setup Lap") then
				WarMenu.CloseMenu()
				local playerPed = PlayerPedId()
				TaskLeaveVehicle(playerPed, GetVehiclePedIsIn(playerPed), 0)
				Wait(2500)

				local vehicle = ESX.Game.GetClosestVehicle()
				TaskTurnPedToFaceEntity(playerPed, vehicle, 1000)

				Wait(1000)

				if DoesEntityExist(vehicle) then
					TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
					Wait(8000)
					TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_HAMMERING', 0, true)
					Wait(8000)
					TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
					Wait(8000)
					ClearPedTasksImmediately(playerPed)
					
					if LabSetup == false then
						LabSetup = true
					else
						LabSetup = false
					end
				end
			end

			if LabSetup then
				if WarMenu.Button("Ingirdient List") then
					if ingridientsRun == false then
						ingridientsRun = true
						exports['mythic_notify']:PersistentAlert('start', ingridentsID, 'inform', "Sa otsid vajaliku kraami!", { ['background-color'] = '#8A2BE2' })

						Citizen.CreateThread(function()
							while ingridientsRun do
								local coords = GetEntityCoords(PlayerPedId())

								for k,v in pairs(IngridientsLocations) do
									if Vdist(coords, v.Pos.x, v.Pos.y, v.Pos.z) < 15 then
										DrawMarker(25, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 0, 200, false, true, 2, false, nil, nil, false)
						
										if Vdist(coords, v.Pos.x, v.Pos.y, v.Pos.z) < 1.5 then
											isInMarker, location = true, k
										else
											isInMarker, location = false, k
										end
									end

															
						
									if (isInMarker and not hasEnteredMarker) then
										hasEnteredMarker = true
										TriggerEvent("nolex_drugs:HasEnteredMarker", k)
									end
							
									if (not isInMarker and hasEnteredMarker) then
										hasEnteredMarker = false
										TriggerEvent("nolex_drugs:HasLeftMarker")
									end
								end
						
								Wait(0)
							end
						end)
					else
						ingridientsRun = false
						exports['mythic_notify']:PersistentAlert('end', ingridentsID)
					end
				elseif WarMenu.Button("Cook") then
					ESX.TriggerServerCallback('nolex_drugs:HasIngridients', function(result)
						if result then
							local coords = GetEntityCoords(PlayerPedId())
							TriggerServerEvent('nolex_drugs:make', coords)
						else
							exports['mythic_notify']:SendAlert('error', 'Sul ei ole cookimse jaoks asju!')
						end
					end)
				end
			end
			WarMenu.Display()
		end

		Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		print(ingridientsRun, LabSetup, CurrentZone)
		Wait(1000)
	end
end)

local CurrentZoneLabel = ''

Citizen.CreateThread(function()
	while true do
		if CurrentZone ~= nil then
			if IsControlJustReleased(0, 38) then
				local playerPed = PlayerPedId()

				if CurrentZone == 'PatareidLoc' then
					CurrentZoneLabel = 'Sa korjad partareisid!'
					itemName = 'meth_lithium'
				elseif CurrentZone == 'AceStoneLoc' then
					CurrentZoneLabel = 'Sa korjad AceStone-i!'
					itemName = 'meth_acetone'
				elseif CurrentZone == 'PowderLoc' then
					CurrentZoneLabel = 'Sa korjad Meth Powder-i!'
					itemName = 'meth_powder'
				end

				exports['mythic_progbar']:Progress({
					name = "unique_action_name",
					duration = 15000,
					label = CurrentZoneLabel,
					useWhileDead = false,
					canCancel = true,
					controlDisables = {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					},
					animation = {
						animDict = "amb@prop_human_bum_bin@idle_a",
						anim = "idel_a",
						flags = 0,
					},
				}, function(cancelled)
					if not cancelled then
						TriggerServerEvent("nolex_drugs:giveItem", itemName, 5)
					end
				end)
			end
		end
		Wait(0)
	end
end)