Config = {}
Config.Locale                     = 'en' -- Locale used in config
Config.FrontCruiseSpeedControl = 11 -- Key to set front speed crusier on
Config.CruiserControl = 10 -- Key to set Crusier On
Config.OpenCarMenu = 344 -- Key to open Main (control menu)
Config.minimalCrusierSpeed = 10 -- Minimal speed (in kmh) to turn Cruiser On
Config.OnlyJob = false -- Job restriction
Config.Jobs = { -- If you have job restriction, this is the jobs they would have access
  'police',
  'mechanic',
  'sheriff'
}
