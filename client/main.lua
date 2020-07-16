local motor = true
local neons = true
local cruiserOn = false
local forwardspeed = false
local forwardvehiclespeed = 0

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterCommand("carmenu", function (src, args, raw)
	local player = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(player,false)	
	if (IsPedSittingInAnyVehicle(player)) then
   		OpenVehicleControlsMenu()
	else
		ESX.ShowNotification(_U('not_inveh'))
	end
end, false)

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(0)
		if IsControlJustReleased(1, Config.OpenCarMenu) then
			local player = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(player,false)	
			if (IsPedSittingInAnyVehicle(player)) then
    				OpenVehicleControlsMenu()
			else
				ESX.ShowNotification(_U('not_inveh'))
			end
		end
		if IsControlJustReleased(1, Config.CruiserControl) then
			local player = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(player,false)
			if (IsPedSittingInAnyVehicle(player)) and GetPedInVehicleSeat(vehicle, -1) then
				local vehicleSpeed = GetEntitySpeed(vehicle)
				local kmh = (vehicleSpeed * 3.6)
				if cruiserOn then
					cruiserOn = false
					SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
					ESX.ShowNotification(_U('cruiser_off'))
				elseif not cruiserOn then
					if kmh >= Config.minimalCrusierSpeed then
						cruiserOn = true
						SetEntityMaxSpeed(vehicle, vehicleSpeed)
						ESX.ShowNotification(_U('crusier_on', ESX.Math.Round(kmh)))
					else
						ESX.ShowNotification(_U('not_required_speed', Config.minimalCrusierSpeed))
					end
				end
			else
				ESX.ShowNotification(_U('not_driver'))
			end
		end
		if IsControlJustReleased(1, Config.FrontCruiseSpeedControl) then
			local player = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(player,false)
			if (IsPedSittingInAnyVehicle(player)) and GetPedInVehicleSeat(vehicle, -1) then
				local vehicleSpeed = GetEntitySpeed(vehicle)
				local kmh = (vehicleSpeed * 3.6)
				if forwardspeed then
					forwardspeed = false
					ESX.ShowNotification(_U('forw_crusier_odd'))
				elseif not forwardspeed then
					forwardspeed = true
					forwardvehiclespeed = vehicleSpeed
					ESX.ShowNotification(_U('crusier_on', kmh))
				end
			else
				ESX.ShowNotification(_U('not_driver'))
			end
		end
		if IsControlPressed(1, 32) or IsControlPressed(1, 33) or IsControlPressed(1, 55) then
			if forwardspeed then
				forwardspeed = false
				ESX.ShowNotification(_U('forw_crusier_odd'))
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(500)
		if forwardspeed then
			local player = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(player,false)
			if not IsEntityInAir(vehicle) then
				SetVehicleForwardSpeed(vehicle, forwardvehiclespeed)
			elseif IsEntityInAir(vehicle) then
				forwardspeed = false
				ESX.ShowNotification(_U('forw_crusier_odd'))
			end
		end
	end
end)

function OpenVehicleControlsMenu()
local elements = {
	{label = _U('extras'), value = 'extras'},
	{label = _U('engine'), value = 'motor'},
	{label = _('open_close'), value = 'open_close'},
	{label = _('windows'), value = 'windows'},
	{label = _U('neons'), value = 'neons'},
	{label = _U('lights'), value = 'lights'},
}	

	local player = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(player,false)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_controls', {
			title    = _U('vehicle_control'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'extras' then
				OpenVehicleExtrasMenu()
			elseif data.current.value == 'motor' then
				if motor then
					motor = false
					SetVehicleEngineOn(vehicle, false, false, false)
				elseif not motor then
					motor = true
					SetVehicleEngineOn(vehicle, true, false, false)
				end
				while (motor == false) do
					SetVehicleUndriveable(vehicle,true)
					Citizen.Wait(0)
				end
			elseif data.current.value == 'open_close' then
				OtevritZavritAuto()
			elseif data.current.value == 'windows' then
				SpravaOkenek()
			elseif data.current.value == 'neons' then
				if neons then
					neons = false
					DisableVehicleNeonLights(vehicle, false, false, false)
				elseif not neons then
					neons = true
					DisableVehicleNeonLights(vehicle, true, false, false)
				end	
			elseif data.current.value == 'lights' then
				LightsMenu()
			end			
		end, function(data, menu)
			menu.close()
		end)
end

local fronleftdoors = false
local frontrightdoors = false
local backleftdoors = false
local backrightdoors = false
local trunk = false
local hood = false
function OtevritZavritAuto()
	local elements = {
	{label = _U('fronleftdoors'), value = 'fronleftdoors'},
	{label = _U('frontrightdoors'), value = 'frontrightdoors'},
	{label = _U('backleftdoors'), value = 'backleftdoors'},
	{label = _U('backrightdoors'), value = 'backrightdoors'},
	{label = _U('alldoorsopen'), value = 'alldoorsopen'},
	{label = _U('alldoorsclose'), value = 'alldoorsclose'},
	{label = _U('trunk'), value = 'trunk'},
	{label = _U('hood'), value = 'hood'},
	}	

	local player = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(player,false)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_controls_doors', {
			title    = _U('vehicle_control'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'fronleftdoors' then
				if not fronleftdoors then
					fronleftdoors = true
					SetVehicleDoorOpen(vehicle, 0, false)
				elseif fronleftdoors then
					fronleftdoors = false
					SetVehicleDoorShut(vehicle, 0, false)
				end
			elseif data.current.value == 'frontrightdoors' then
				if not frontrightdoors then
					frontrightdoors = true
					SetVehicleDoorOpen(vehicle, 1, false)
				elseif frontrightdoors then
					frontrightdoors = false
					SetVehicleDoorShut(vehicle, 1, false)
				end
			elseif data.current.value == 'backleftdoors' then
				if not backleftdoors then
					backleftdoors = true
					SetVehicleDoorOpen(vehicle, 2, false)
				elseif backleftdoors then
					backleftdoors = false
					SetVehicleDoorShut(vehicle, 2, false)
				end
			elseif data.current.value == 'backrightdoors' then
				if not backrightdoors then
					backrightdoors = true
					SetVehicleDoorOpen(vehicle, 3, false)
				elseif backrightdoors then
					backrightdoors = false
					SetVehicleDoorShut(vehicle, 3, false)
				end
			elseif data.current.value == 'trunk' then
				if not trunk then
					trunk = true
					SetVehicleDoorOpen(vehicle, 5, false)
				elseif trunk then
					trunk = false
					SetVehicleDoorShut(vehicle, 5, false)
				end
			elseif data.current.value == 'hood' then
				if not hood then
					hood = true
					SetVehicleDoorOpen(vehicle, 4, false)
				elseif hood then
					hood = false
					SetVehicleDoorShut(vehicle, 4, false)
				end	
			elseif data.current.value == 'alldoorsopen' then
				fronleftdoors = true
				frontrightdoors = true
				backleftdoors = true
				backrightdoors = true
				trunk = true
				hood = true
				SetVehicleDoorOpen(vehicle, 0, false)
				SetVehicleDoorOpen(vehicle, 1, false)
				SetVehicleDoorOpen(vehicle, 2, false)
				SetVehicleDoorOpen(vehicle, 3, false)
				SetVehicleDoorOpen(vehicle, 4, false)
				SetVehicleDoorOpen(vehicle, 5, false)
			elseif data.current.value == 'alldoorsclose' then
				fronleftdoors = false
				frontrightdoors = false
				backleftdoors = false
				backrightdoors = false
				trunk = false
				hood = false
				SetVehicleDoorsShut(vehicle)															
			end
		end, function(data, menu)
			menu.close()
		end)
end
local leftfrontwindows = true
local rightfrontwindows = true
local leftbackwindow = true
local rightbackwindow = true
function SpravaOkenek()
	local elements = {
	{label = _U('leftfrontwindows'), value = 'leftfrontwindows'},
	{label = _U('rightfrontwindows'), value = 'rightfrontwindows'},
	{label = _U('leftbackwindow'), value = 'leftbackwindow'},
	{label = _U('rightbackwindow'), value = 'rightbackwindow'},
	{label = _U('windowsdown'), value = 'windowsdown'},
	{label = _U('windowsup'), value = 'windowsup'},
	}	
	local player = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(player,false)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_controls_komponents', {
			title    = _U('vehicle_control'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'leftfrontwindows' then
				if not leftfrontwindows then
					leftfrontwindows = true
					RollUpWindow(vehicle, 0, false)
				elseif leftfrontwindows then
					leftfrontwindows = false
					RollDownWindow(vehicle, 0, false)
				end
			elseif data.current.value == 'rightfrontwindows' then
				if not rightfrontwindows then
					rightfrontwindows = true
					RollUpWindow(vehicle, 1, false)
				elseif rightfrontwindows then
					rightfrontwindows = false
					RollDownWindow(vehicle, 1, false)
				end
			elseif data.current.value == 'leftbackwindow' then
				if not leftbackwindow then
					leftbackwindow = true
					RollUpWindow(vehicle, 2, false)
				elseif leftbackwindow then
					leftbackwindow = false
					RollDownWindow(vehicle, 2, false)
				end
			elseif data.current.value == 'rightbackwindow' then
				if not rightbackwindow then
					rightbackwindow = true
					RollUpWindow(vehicle, 3, false)
				elseif rightbackwindow then
					rightbackwindow = false
					RollDownWindow(vehicle, 3, false)
				end
			elseif data.current.value == 'windowsdown' then
				leftfrontwindows = true
				rightfrontwindows = true
				leftbackwindow = true
				rightbackwindow = true
				RollDownWindows(vehicle)
			elseif data.current.value == 'windowsup' then
				leftfrontwindows = false
				rightfrontwindows = false
				leftbackwindow = false
				rightbackwindow = false
				RollUpWindow(vehicle, 0, false)
				RollUpWindow(vehicle, 1, false)
				RollUpWindow(vehicle, 2, false)
				RollUpWindow(vehicle, 3, false)
			end
		end, function(data, menu)
			menu.close()
		end)
end

local interiorlights = false
local frontlights = true
function LightsMenu()
	local elements = {
	{label = _U('interiorlights'), value = 'interiorlights'},
	{label = _U('frontlights'), value = 'frontlights'},
	}	
	local player = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(player,false)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_controls_lights', {
			title    = _U('vehicle_control'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'interiorlights' then
				if not interiorlights then
					interiorlights = true
					SetVehicleInteriorlight(vehicle, true)
				elseif interiorlights then
					interiorlights = false
					SetVehicleInteriorlight(vehicle, false)
				end
			elseif data.current.value == 'frontlights' then
				if not frontlights then
					frontlights = true
					SetVehicleLights(vehicle, true)
				elseif frontlights then
					frontlights = false
					SetVehicleLights(vehicle, false)
				end
			end
		end, function(data, menu)
			menu.close()
		end)
end

function OpenVehicleExtrasMenu()
	local ped = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(ped)
	local elements = {}
	for x = 0, 20 do
		if DoesExtraExist(vehicle, x) then
			if IsVehicleExtraTurnedOn(vehicle, x) then
				table.insert(elements, {label = 'EXTRA '..x.." <FONT color='green'>ON</FONT>", value = x})
			elseif not IsVehicleExtraTurnedOn(vehicle, x) then
				table.insert(elements, {label = 'EXTRA '..x.." <FONT color='red'>OFF</FONT>", value = x})
			end
		end
	end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_extras', {
			title    = _U('extras'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			for x = 0, 20 do
				if data.current.value == x then
					if IsVehicleExtraTurnedOn(vehicle, x) then
						SetVehicleExtra(vehicle, x, 1)
						ESX.UI.Menu.CloseAll()
						OpenVehicleExtrasMenu()
					elseif not IsVehicleExtraTurnedOn(vehicle, x) then
						SetVehicleExtra(vehicle, x, 0)
						ESX.UI.Menu.CloseAll()
						OpenVehicleExtrasMenu()
					end
				end
			end
		end, function(data, menu)
			menu.close()
		end)

end