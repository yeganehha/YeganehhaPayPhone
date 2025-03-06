local phoneModels = {
    'p_phonebox_01b_s',
    'p_phonebox_02_s',
    'prop_phonebox_01a',
    'prop_phonebox_01b',
    'prop_phonebox_01c',
    'prop_phonebox_02',
    'prop_phonebox_03',
    'prop_phonebox_04'
}
local isOnCall = false
local registeredPhones = {}
local soundId = nil
local isRingPhoneRun = false
local ringSoudId = {}

RegisterNetEvent('YeganehhaPayPhone:registerPhone')
AddEventHandler('YeganehhaPayPhone:registerPhone', function(phoneNumber, data)
  Config.FixePhone[phoneNumber] = data
  if ( Config.FixePhone[phoneNumber].isCallRecipient == false and ringSoudId[phoneNumber] ~= nil) then
    StopSound(ringSoudId[phoneNumber])
    ReleaseSoundId(ringSoudId[phoneNumber])
    ReleaseNamedScriptAudioBank("ASSASSINATION_MULTI")
    ringSoudId[phoneNumber] = nil
  end
  if ( Config.FixePhone[phoneNumber].isCallRecipient == true) then
    ringPhons()
  end
end)

RegisterNetEvent('YeganehhaPayPhone:answer')
AddEventHandler('YeganehhaPayPhone:answer', function(callID, sourceNumber , RecipientNumber)
    isOnCall = true
    if Config.UseMumbleVoIP then
        exports["mumble-voip"]:SetCallChannel(callID)
    elseif Config.UsePmaVoice then
        exports["pma-voice"]:SetCallChannel(callID)
    else
        NetworkSetVoiceChannel(callID)
        NetworkSetTalkerProximity(0.0)
    end
    if soundId ~= nil then
        StopSound(soundId)
        ReleaseSoundId(soundId)
        ReleaseNamedScriptAudioBank("ASSASSINATION_MULTI")
        soundId = nil
    end
end)
RegisterNetEvent('YeganehhaPayPhone:reject')
AddEventHandler('YeganehhaPayPhone:reject', function()
    if soundId ~= nil then
        StopSound(soundId)
        ReleaseSoundId(soundId)
        ReleaseNamedScriptAudioBank("ASSASSINATION_MULTI")
        soundId = nil
    end
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "ui",
        toggle = false,
        phoneNumber = '',
        brand = Config.PayPhoneBrand,
    })
    if ( isOnCall == true ) then
        if Config.UseMumbleVoIP then
            exports["mumble-voip"]:SetCallChannel(0)
        elseif Config.UsePmaVoice then
            exports["pma-voice"]:SetCallChannel(0)
        else
            Citizen.InvokeNative(0xE036A705F989E049)
            NetworkSetTalkerProximity(2.5)
        end
    end
    isOnCall = false
end)


AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    for numebr, data in pairs(Config.FixePhone) do
        Config.FixePhone[numebr].isBussy = false
        Config.FixePhone[numebr].isCaller = false
        Config.FixePhone[numebr].isCallRecipient = false
        Config.FixePhone[numebr].callID = nil
        Config.FixePhone[numebr].callerSourceID = nil
        Config.FixePhone[numebr].callRecipientSourceID = nil
        Config.FixePhone[numebr].callingPhonNumber = nil
        if ( Config.FixePhone[numebr].rangeOfRing == nil )  then
            Config.FixePhone[numebr].rangeOfRing = Config.RangeOfRing
        end
    end

    Citizen.CreateThread(function()
        if not Config.AutoFindPayPhones then return end
        while true do
          local playerPed = GetPlayerPed(-1)
          local coords = GetEntityCoords(playerPed)
          for _, model in pairs(phoneModels) do
            local closestPhone = GetClosestObjectOfType(coords, 25.0, model, false)
            if closestPhone ~= 0 and not registeredPhones[closestPhone] then
              local numebr = getPhoneEntityNumber(closestPhone)
              registeredPhones[closestPhone] = true
            end
          end
          Citizen.Wait(1000)
        end
    end)

    exports['qb-target']:AddTargetModel(phoneModels, {
        options = {
            {
                type = "client",
                event = "YeganehhaPayPhone:openKeyPad",
                icon = "fas fa-phone",
                label = "Use PayPhone",
                price = 0,
                canInteract = function(entity)
                    local num = getPhoneEntityNumber(entity)
                    if ( Config.FixePhone[num] ~= nil ) then
                        return Config.FixePhone[num].isBussy == false
                    end
                    return true
                end,
            },
            {
                type = "client",
                event = "YeganehhaPayPhone:pickupIncomingCall",
                icon = "fas fa-phone",
                label = "Pick Up",
                price = 0,
                canInteract = function(entity)
                    local num = getPhoneEntityNumber(entity)
                    if ( Config.FixePhone[num] ~= nil ) then
                        return Config.FixePhone[num].isCallRecipient
                    end
                    return false
                end,
            },
            {
                type = "client",
                event = "YeganehhaPayPhone:hangupIncomingCall",
                icon = "fas fa-phone",
                label = "Hang Up",
                price = 0,
                canInteract = function(entity)
                    local num = getPhoneEntityNumber(entity)
                    if ( Config.FixePhone[num] ~= nil ) then
                        return Config.FixePhone[num].isCallRecipient
                    end
                    return false
                end,
            },
        },
        distance = 2.5,
    })
end)


AddEventHandler('YeganehhaPayPhone:openKeyPad', function(data)
    local entity = GetEntityCoords(data.entity)
    print(entity)
    print(getPhoneEntityNumber(data.entity))
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "ui",
        toggle = true,
        phoneNumber = getPhoneEntityNumber(data.entity),
        brand = Config.PayPhoneBrand,
    })
    SetCursorLocation(0.9, 0.75)
end)


function getPhoneEntityNumber(entity)
    local phoneCoords = GetEntityCoords(entity)
    local number = ('0%.3s%.3s%.3s'):format(math.abs(phoneCoords.x*100), math.abs(phoneCoords.y * 100), math.abs(phoneCoords.z *100))
    if Config.ReplaceNumber[number] ~= nil then
        number = Config.ReplaceNumber[number]
    end
    if not Config.FixePhone[number] then
        --local phoneName =  GetStreetNameFromHashKey(GetStreetNameAtCoord(phoneCoords))
        local phoneName =  'Test'
        TriggerServerEvent('YeganehhaPayPhone:registerPhone', number, phoneCoords , phoneName )
    end
    print(json.encode(number) , number)
    return number
end

RegisterNUICallback('dial', function(data)
    if soundId == nil then
        soundId = GetSoundId()
    end
    RequestScriptAudioBank("ASSASSINATION_MULTI")
    PlaySoundFrontend(
        soundId,
        'Phone_Ring_Loop',
        'DLC_Security_Payphone_Hits_General_Sounds',
        false
    )
    TriggerServerEvent('YeganehhaPayPhone:startCall', data.number ,  data.myNumber)
    cb()
end)


RegisterNUICallback('exit', function(data)
    TriggerServerEvent('YeganehhaPayPhone:reject')
    cb()
end)

AddEventHandler('YeganehhaPayPhone:hangupIncomingCall', function(data)
    TriggerServerEvent('YeganehhaPayPhone:reject')
end)



function ringPhons()
	Citizen.CreateThread(function()
        if ( isRingPhoneRun == false) then
            local playerPed = PlayerPedId()
            local haveActiveRing = true
            while haveActiveRing do
                isRingPhoneRun = true
                haveActiveRing = false
                local playerCoords = GetEntityCoords(playerPed)
                for numebr, data in pairs(Config.FixePhone) do
                    if ( Config.FixePhone[numebr].isCallRecipient == true ) then
                        haveActiveRing = true
					    local distance = #(playerCoords - Config.FixePhone[numebr].coords)
                        if ( distance <=  Config.FixePhone[numebr].rangeOfRing + 0.01 and ringSoudId[numebr] == nil) then
                            ringSoudId[numebr] = GetSoundId()
                            RequestScriptAudioBank("ASSASSINATION_MULTI")
                            SetVariableOnSound(ringSoudId[numebr], "Volume", 5)
                            SetVariableOnSound(ringSoudId[numebr], "DistanceAttentuation", 10)
                            PlaySoundFromCoord(ringSoudId[numebr], 'Phone_Ring_Loop', Config.FixePhone[numebr].coords, 'DLC_Security_Payphone_Hits_General_Sounds', false , Config.FixePhone[numebr].rangeOfRing , false)
                        end
                        if ( distance >  Config.FixePhone[numebr].rangeOfRing + 0.01 and ringSoudId[numebr] ~= nil) then
                            StopSound(ringSoudId[numebr])
                            ReleaseSoundId(ringSoudId[numebr])
                            ReleaseNamedScriptAudioBank("ASSASSINATION_MULTI")
                            ringSoudId[numebr] = nil
                        end
                    end
                end 
                Citizen.Wait(500)           
            end
            isRingPhoneRun = false;
        end
	end)
end



AddEventHandler('YeganehhaPayPhone:pickupIncomingCall', function(data)
    local entity = data.entity
    print(entity)
    local number = getPhoneEntityNumber(entity)
    print(number)
    if ( ringSoudId[numebr] ~= nil) then
        print(ringSoudId[numebr])
        StopSound(ringSoudId[numebr])
        ReleaseSoundId(ringSoudId[numebr])
        ReleaseNamedScriptAudioBank("ASSASSINATION_MULTI")
        ringSoudId[numebr] = nil
    end
    TriggerServerEvent('YeganehhaPayPhone:answer', number)
end)
