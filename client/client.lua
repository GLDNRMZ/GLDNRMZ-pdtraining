local QBCore = exports['qb-core']:GetCoreObject()
local CurrentCops = 0
local methguards = {}

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerJob = QBCore.Functions.GetPlayerData().job
        StartJobPed()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    StartJobPed()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

function StartJobPed()
    if not DoesEntityExist(startboss) then
        RequestModel(Config.StartModel)
        while not HasModelLoaded(Config.StartModel) do
            Wait(0)
        end
        startboss = CreatePed(0, Config.StartModel, Config.StartCoords, false, false)

        SetEntityAsMissionEntity(startboss)
        SetPedFleeAttributes(startboss, 0, 0)
        SetBlockingOfNonTemporaryEvents(startboss, true)
        SetEntityInvincible(startboss, true)
        FreezeEntityPosition(startboss, true)
        loadAnimDict("amb@world_human_leaning@female@wall@back@holding_elbow@idle_a")
        TaskPlayAnim(startboss, "amb@world_human_leaning@female@wall@back@holding_elbow@idle_a", "idle_a", 8.0, 1.0, -1, 01, 0, 0, 0, 0)

        exports['qb-target']:AddTargetEntity(startboss, {
            options = {
                {
                    type = "client",
                    event = "lb-pdtraining:client:restart",
                    icon = "fa-regular fa-circle-play",
                    label = "Start Training Exercise",
                },
                {
                    type = "client",
                    event = "lb-pdtraining:client:stop",
                    icon = "fa-regular fa-circle-stop",
                    label = "Stop Training Exercise",
                },
            },
            distance = 1.5,
        })
    end
end

RegisterNetEvent('lb-pdtraining:client:restart')
AddEventHandler('lb-pdtraining:client:restart', function()
    ClearEntities()
    SpawnGuards()
    QBCore.Functions.Notify("Training event has been started.", "success")
end)

RegisterNetEvent('lb-pdtraining:client:stop')
AddEventHandler('lb-pdtraining:client:stop', function()
    ClearEntities()
    QBCore.Functions.Notify("Training event has ended.", "success")
end)

function ClearEntities()
    for _, guard in ipairs(methguards) do
        if DoesEntityExist(guard) then
            DeletePed(guard)
        end
    end
    methguards = {}
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(0)
    end
end

local guardPeds = {}

function SpawnGuards()
    for _, guard in ipairs(Config.GuardPeds) do
        local model = GetHashKey(guard.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        local guardPed = CreatePed(4, model, guard.coords.x, guard.coords.y, guard.coords.z, guard.heading, true, true)

        GiveWeaponToPed(guardPed, GetHashKey("weapon_pistol_mk2"), 250, false, true)
        
        SetPedCombatAttributes(guardPed, 46, true)  -- Disables blocking
        SetPedCombatAttributes(guardPed, 5, false) -- Disables melee combat
        SetPedCombatAttributes(guardPed, 1, false) -- Disables can use cover
        SetPedCombatAbility(guardPed, 0)           -- Lower combat ability
        SetPedCombatRange(guardPed, 0)             -- Lower combat range
        SetPedCombatMovement(guardPed, 1)          -- Lower combat movement

        SetPedFleeAttributes(guardPed, 0, false)   -- Disables fleeing

        SetPedRelationshipGroupHash(guardPed, GetHashKey("HATES_PLAYER")) 
        TaskCombatPed(guardPed, PlayerPedId(), 0, 16)

        table.insert(guardPeds, { ped = guardPed, blip = blip })
    end
end

grandma = {}

function GrandmaSit()
    loadAnimDict("amb@world_human_leaning@male@wall@back@hands_together@base")
    TaskPlayAnim(grandma, "amb@world_human_leaning@male@wall@back@hands_together@base", "base", 8.0, 1.0, -1, 01, 0, 0, 0, 0)
end

function SpawnGrandma()
    RequestModel(`s_m_m_paramedic_01`)
    while not HasModelLoaded(`s_m_m_paramedic_01`) do
        Wait(0)
    end

    grandma = CreatePed(0, `s_m_m_paramedic_01`, Config.Coords.x, Config.Coords.y, Config.Coords.z, Config.Coords.w, false, false)

    SetEntityAsMissionEntity(grandma)
    SetPedFleeAttributes(grandma, 0, 0)
    SetBlockingOfNonTemporaryEvents(grandma, true)
    SetEntityInvincible(grandma, true)
    FreezeEntityPosition(grandma, true)
    GrandmaSit()

    exports['qb-target']:AddTargetEntity(grandma, {
        options = {
            {
                type = "client",
                event = "lb-pdtraining:client:checks",
                icon = "fa-solid fa-house-medical",
                label = "Get Treated",
            },
        },
        distance = 2.5
    })
end

function DeleteGrandma()
    if DoesEntityExist(grandma) then
        DeletePed(grandma)
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SpawnGrandma()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    SpawnGrandma()
end)

RegisterNetEvent('lb-pdtraining:client:checks')
AddEventHandler('lb-pdtraining:client:checks', function()
    local ped = PlayerPedId()
    local player = PlayerId()

    if Config.CheckDead then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if PlayerData.metadata["inlaststand"] or PlayerData.metadata["isdead"] then
                TriggerServerEvent('lb-pdtraining:server:checkfunds')
            else
                QBCore.Functions.Notify("You are not downed or dead.", "error")
            end
        end)
    else
        TriggerServerEvent('lb-pdtraining:server:checkfunds')
    end
end)

RegisterNetEvent('lb-pdtraining:reviveplayer')
AddEventHandler('lb-pdtraining:reviveplayer', function(source)
    TaskStartScenarioInPlace(grandma, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
    QBCore.Functions.Progressbar("grandma", "The doctor is healing your wounds..", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        QBCore.Functions.TriggerCallback('random_grandma:attemptGrandmaPayment', function(hasPaid)
            if hasPaid then
                QBCore.Functions.Notify("You feel much better now.", "success")
                TriggerEvent('hospital:client:Revive')
                ClearPedTasks(PlayerPedId())
                ClearPedTasksImmediately(grandma)
                GrandmaSit()
            else
                QBCore.Functions.Notify("You're cooked.", "error")
                ClearPedTasks(PlayerPedId())
                ClearPedTasksImmediately(grandma)
                GrandmaSit()
            end
        end)
    end, function()
        ClearPedTasks(PlayerPedId())
        ClearPedTasksImmediately(grandma)
        GrandmaSit()
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeleteGrandma()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    DeleteGrandma()
end)
