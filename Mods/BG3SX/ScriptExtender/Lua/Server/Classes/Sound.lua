----------------------------------------------------------------------------------------
--
--                               For handling Sound functionalities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

Sound = {}
Sound.__index = Sound

local playSound

-- Creates a new sound instance on an actor
---@param actor         Actor   - The actor to play it on
---@param soundTable    Table   - A list of sounds to use
---@param minRepeatTime Time    - Minimum Repeat Time
---@param maxRepeatTime Time    - Maximum Repeat Time
function Sound:new(actor, soundTable, duration)
    local instance      = setmetatable({
        actor = actor,
        soundTable = soundTable,
        duration = duration
    }, Animation)

    playSound(self) -- Automatically calls this function on creation

    return instance
end

-- Sound
--------------------------------------------------------------


playSound = function(self)
    local scene = Scene:FindSceneByEntity(self.actor.parent)
    local minRepeatTime = self.duration - 200
    local maxRepeatTime = self.duration + 200
    
    Osi.PlaySound(self.actor, "") -- First, stop current sound

    local sound = self.soundTable[math.random(1, #self.soundTable)]
    Osi.PlaySound(self.actor, sound) -- Plays a random entry of sounds on an actor
    
    -- Will be an infinite loop until registered timer gets canceled on Scene:Destroy()
    local newSoundTimer = Ext.Timer.WaitFor(math.random(minRepeatTime, maxRepeatTime), function()
        playSound(self)
    end)

    scene:RegisterNewSoundTimer(newSoundTimer)

    _P("[BG3SX][Sounds.lua] - Sound:new() - playSound - Begin to play ", sound, " on ", self.actor)
end