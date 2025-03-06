Config = {}

Config.AutoFindPayPhones = true -- Automatically add pay phones as they are found by their models.

Config.PayPhoneBrand  = "Yeganehha"
Config.RangeOfRing  = 8

Config.UsePmaVoice   = true -- PMA voice Resource (Recomended!) https://forum.cfx.re/t/release-voip-pma-voice-mumble-voip-alternative/1896255
Config.UseMumbleVoIP = false -- Use Frazzle's Mumble-VoIP Resource for some of the people who wanted it https://github.com/FrazzIe/mumble-voip

Config.ReplaceNumber = {}

Config.FixePhone = {
    ['911'] = { 
      name =  '911', 
      coords = vector3(441.2, -979.7, 30.580),
      rangeOfRing = 2
    },
  }