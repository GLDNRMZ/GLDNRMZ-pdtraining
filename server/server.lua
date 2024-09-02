local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('lb-pdtraining:server:checkfunds', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local balance = Player.Functions.GetMoney(Config.MoneyType)

    if Config.CheckBalance and balance < Config.Cost then
        local errorMessage = "You don't have enough " .. Config.MoneyType .. " to pay the Medic!"
        if Config.MoneyType == 'bank' then
            errorMessage = "You don't have enough money in your bank to pay the Medic!"
        elseif Config.MoneyType == 'cash' then
            errorMessage = "You don't have enough cash to pay the Medic!"
        end
        TriggerClientEvent('QBCore:Notify', src, errorMessage, "error")
        return
    end

    TriggerClientEvent('lb-pdtraining:reviveplayer', src)
end)

QBCore.Functions.CreateCallback('random_grandma:attemptGrandmaPayment', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.CheckBalance then
        cb(Player.Functions.RemoveMoney(Config.MoneyType, Config.Cost))
    else
        cb(true)
    end
end)

local CurrentCops = 0

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('lb-pdtraining:server:start')
AddEventHandler('lb-pdtraining:server:start', function()
    if CurrentCops >= Config.MinimumMethJobPolice then
        -- Notify all clients to spawn guards and civilians
        TriggerClientEvent('lb-pdtraining:client:start', -1)
        QBCore.Functions.Notify("Neutralize the threats. Watch out for civilians.", 'info')
    else
        QBCore.Functions.Notify("You cannot do this right now.", 'error')
    end
end)

RegisterNetEvent('lb-pdtraining:server:restart')
AddEventHandler('lb-pdtraining:server:restart', function()
    -- Notify all clients to restart the event
    TriggerClientEvent('lb-pdtraining:client:restart', -1)
end)

RegisterNetEvent('lb-pdtraining:server:stop')
AddEventHandler('lb-pdtraining:server:stop', function()
    -- Notify all clients to stop the event
    TriggerClientEvent('lb-pdtraining:client:stop', -1)
end)

