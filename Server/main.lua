
local PhoneInfo = {}
local AppelsEnCours = {}
local callID = 10
RegisterServerEvent('YeganehhaPayPhone:registerPhone')
AddEventHandler('YeganehhaPayPhone:registerPhone', function(phoneNumber, phoneCoords , phoneName)
	Config.FixePhone[phoneNumber] = {
        name = phoneName,
        coords = phoneCoords,
        isBussy = false,
        isCaller = false,
        isCallRecipient = false,
        rangeOfRing = Config.RangeOfRing,
        callID = nil,
        callerSourceID = nil,
        callRecipientSourceID = nil,
        callingPhonNumber = nil
    }
	TriggerClientEvent('YeganehhaPayPhone:registerPhone', -1, phoneNumber, Config.FixePhone[phoneNumber])
end)


RegisterServerEvent('YeganehhaPayPhone:startCall')
AddEventHandler('YeganehhaPayPhone:startCall', function(source, phoneNumber , sourceNumber)
    if Config.FixePhone[phoneNumber] ~= nil and Config.FixePhone[sourceNumber] ~= nil then
        local hidden = string.sub(phoneNumber, 1, 1) == '#'
        if hidden == true then
            phoneNumber = string.sub(phoneNumber, 2)
        end
        local sourcePlayer = tonumber(source)
        Config.FixePhone[sourceNumber].isBussy = true 
        Config.FixePhone[sourceNumber].isCaller = true 
        Config.FixePhone[sourceNumber].isCallRecipient = false
        Config.FixePhone[sourceNumber].callID = nil
        Config.FixePhone[sourceNumber].callerSourceID = sourcePlayer
        Config.FixePhone[sourceNumber].callRecipientSourceID = nil
        Config.FixePhone[sourceNumber].callingPhonNumber = phoneNumber
        Config.FixePhone[phoneNumber].isBussy = true 
        Config.FixePhone[phoneNumber].isCaller = false 
        Config.FixePhone[phoneNumber].isCallRecipient = true
        Config.FixePhone[phoneNumber].callID = nil
        Config.FixePhone[phoneNumber].callerSourceID = sourcePlayer
        Config.FixePhone[phoneNumber].callRecipientSourceID = nil
        Config.FixePhone[phoneNumber].callingPhonNumber = nil
        TriggerClientEvent('YeganehhaPayPhone:registerPhone', -1, sourceNumber, Config.FixePhone[sourceNumber])
        TriggerClientEvent('YeganehhaPayPhone:registerPhone', -1, phoneNumber, Config.FixePhone[phoneNumber])
        Citizen.CreateThread(function()
            Citizen.Wait(15000)
            if ( Config.FixePhone[phoneNumber].callRecipientSourceID == nil ) then
                rejectCall(sourceNumber , phoneNumber)
            end
        end)
    end
end)

RegisterServerEvent('YeganehhaPayPhone:answer')
AddEventHandler('YeganehhaPayPhone:answer', function(source, phoneNumber)
    local sourceNumber = nil
    for numebr, data in pairs(Config.FixePhone) do
        if ( data.callingPhonNumber == phoneNumber) then
            sourceNumber = numebr
        end
    end
    if Config.FixePhone[phoneNumber] ~= nil and sourceNumber ~= nil and  Config.FixePhone[sourceNumber] ~= nil then
        callID = callID + 1
        Config.FixePhone[sourceNumber].callID = callID
        Config.FixePhone[phoneNumber].callID = callID
        Config.FixePhone[sourceNumber].callRecipientSourceID =  tonumber(source)
        Config.FixePhone[phoneNumber].callRecipientSourceID =  tonumber(source)
        TriggerClientEvent('YeganehhaPayPhone:answer', source, callID , sourceNumber , phoneNumber)
        TriggerClientEvent('YeganehhaPayPhone:answer', Config.FixePhone[sourceNumber].callerSourceID, callID, sourceNumber , phoneNumber)
    end
end)

RegisterServerEvent('YeganehhaPayPhone:reject')
AddEventHandler('YeganehhaPayPhone:reject', function (source)
    local sourceNumber = nil 
    local phoneNumber = nil
    for numebr, data in pairs(Config.FixePhone) do
        if ( data.callerSourceID == tonumber(source)) then
            sourceNumber = numebr
        end
        if ( data.callRecipientSourceID == tonumber(source)) then
            phoneNumber = numebr
        end
    end
    rejectCall(sourceNumber , phoneNumber)
end)

function rejectCall(sourceNumber , phoneNumber)
    if phoneNumber ~= nil and Config.FixePhone[phoneNumber] ~= nil and sourceNumber ~= nil and Config.FixePhone[sourceNumber] ~= nil then
        TriggerClientEvent('YeganehhaPayPhone:reject', Config.FixePhone[sourceNumber].callerSourceID)
        TriggerClientEvent('YeganehhaPayPhone:reject', Config.FixePhone[sourceNumber].callerSourceID)
        Config.FixePhone[sourceNumber].isBussy = false 
        Config.FixePhone[sourceNumber].isCaller = false 
        Config.FixePhone[sourceNumber].isCallRecipient = false
        Config.FixePhone[sourceNumber].callID = nil
        Config.FixePhone[sourceNumber].callerSourceID = nil
        Config.FixePhone[sourceNumber].callRecipientSourceID = nil
        Config.FixePhone[sourceNumber].callingPhonNumber = nil
        Config.FixePhone[phoneNumber].isBussy = false 
        Config.FixePhone[phoneNumber].isCaller = false 
        Config.FixePhone[phoneNumber].isCallRecipient = false
        Config.FixePhone[phoneNumber].callID = nil
        Config.FixePhone[phoneNumber].callerSourceID = nil
        Config.FixePhone[phoneNumber].callRecipientSourceID = nil
        Config.FixePhone[phoneNumber].callingPhonNumber = nil
        TriggerClientEvent('YeganehhaPayPhone:registerPhone', -1, sourceNumber, Config.FixePhone[sourceNumber])
        TriggerClientEvent('YeganehhaPayPhone:registerPhone', -1, phoneNumber, Config.FixePhone[phoneNumber])
    end
end