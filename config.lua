Config = {}

-- Job identifier
Config.JobName = 'fire_rescue'

-- Define fire types
Config.FireTypes = {
  wildfire = {
    label         = 'Wildfire',
    autoSpawn     = true,
    minInterval   = 15 * 60 * 1000,
    maxInterval   = 30 * 60 * 1000,
    radius        = 25.0,
    dispatchCode  = '10-01',
    dispatchMsg   = 'Wildland Fire',
    sprite        = 436,
    color         = 1,
    locations     = {
      vector3(215.0, -1643.0, 29.7),
      vector3(1200.0, 2490.0, 38.0),
      vector3(-500.0, -200.0, 38.0),
    },
  },
  vehicle = {
    label         = 'Vehicle Fire',
    autoSpawn     = false,
    radius        = 10.0,
    dispatchCode  = '10-02',
    dispatchMsg   = 'Car on Fire',
    sprite        = 225,
    color         = 5,
    locations     = {
      vector3(-100.0, -1000.0, 28.0),
    },
  },
  structure = {
    label         = 'Structure Fire',
    autoSpawn     = false,
    radius        = 30.0,
    dispatchCode  = '10-03',
    dispatchMsg   = 'Building Fire',
    sprite        = 89,
    color         = 46,
    locations     = {
      vector3(400.0, -980.0, 29.0),
    },
  },
  dumpster = {
    label         = 'Dumpster Fire',
    autoSpawn     = false,
    radius        = 8.0,
    dispatchCode  = '10-04',
    dispatchMsg   = 'Dumpster Fire',
    sprite        = 318,
    color         = 1,
    locations     = {
      vector3(50.0, -1800.0, 28.0),
    },
  },
}

Config.NotifyIcon = 'fas fa-fire-extinguisher'
Config.NotifyTitle = 'Fire Rescue'
Config.NotifyDuration = 5000
-- Hose uses configuration (spray actions per hose)
Config.HoseUses = 100

-- Helper to get a random location for a fire type
function Config:GetRandomLocation(typeName)
  local t = self.FireTypes[typeName]
  if not t then return nil end
  return t.locations[math.random(#t.locations)]
end
