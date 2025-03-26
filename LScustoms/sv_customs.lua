-- sv_customs.lua
-- Gemaakt door Wunderskid (DJ Hart)

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ls_customs:purchaseMod', function(source, cb, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        cb(true)
    else
        cb(false)
    end
end)