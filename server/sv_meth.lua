ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("nolex_drugs:HasIngridients", function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer ~= nil then
		if xPlayer.getInventoryItem("meth_acetone").count >= 5 and xPlayer.getInventoryItem("meth_lithium").count >= 5 and xPlayer.getInventoryItem("meth_powder").count >= 5 then
			cb(true)
		else
			cb(false)
		end
	end
end)

RegisterServerEvent('nolex_drugs:make')
AddEventHandler('nolex_drugs:make', function(posx, posy, posz)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	

	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		TriggerClientEvent('nolex_drugs:smoke', xPlayers[i], posx, posy, posz, 'a') 
	end
end)

RegisterServerEvent('nolex_drugs:finish')
AddEventHandler('nolex_drugs:finish', function(qualtiy)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	local rnd = math.random(-5, 5)

	xPlayer.addInventoryItem('meth', math.floor(qualtiy / 2) + rnd)
end)

RegisterServerEvent('nolex_drugs:giveItem')
AddEventHandler('nolex_drugs:giveItem', function(itemName, itemCount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if xPlayer.canCarryItem(itemName, itemCount) then
		xPlayer.addInventoryItem(itemName, itemCount)
		TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = 'Sa said '..itemCount..'x '..xPlayer.getInventoryItem(itemName).label..'!', length = 3500, style = { ['background-color'] = '#8A2BE2'} })
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'Sul ei ole inventuuris ruumi!', length = 3500})
	end
end)