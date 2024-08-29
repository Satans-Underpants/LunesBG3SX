-- Pre-Construct our classes so we can create functions in scripts that might not be loaded yet.
-- E.g. Shared/Data/RaceWhitelist.lua

-- Main Classes
Entity = {}
Entity.__index = Entity
Actor = {}
Actor.__index = Actor
Animation = {}
Animation.__index = Animation
Effect = {}
Effect.__index = Effect
Scene = {}
Scene.__index = Scene
Sound = {}
Sound.__index = Sound

-- Main Problem Child on why we did this
Data = {}
Data.__index = Data

-- BG3SX specific
Genital = {}
Genital.__index = Genital
Sex = {}
Sex.__index = Sex
SexUserVars = {}
SexUserVars.__index = Sex

-- Utils
Helper = {}
Helper.__index = Helper
Math = {}
Math.__index = Math
Table = {}
Table.__index = Table
UserSettings = {}
UserSettings.__index = UserSettings
Visual = {}
Visual.__index = Visual