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
function Sound:new(scene, soundTable, duration)
    local instance      = setmetatable({
        scene = scene,
        soundTable = soundTable,
    }, Animation)

    playSound()

    return instance
end

-- Sound
--------------------------------------------------------------

--
---@param actor         Actor   - The actor to play it on
---@param soundTable    Table   - A list of sounds to use
---@param minRepeatTime Time    - Minimum Repeat Time
---@param maxRepeatTime Time    - Maximum Repeat Time
playSound = function()
    local minRepeatTime = duration - 200
    local maxRepeatTime = duration + 200
    Osi.PlaySound(self.actor, "") -- First, stop current sound
    Osi.PlaySound(self.actor, self.soundTable[math.random(1, #self.soundTable)]) -- Plays a random entry of moaning sounds on an actor
    
    -- Will be an infinite loop because it calls itself, need another way to handle it
    Ext.Timer.WaitFor(math.random(minRepeatTime, maxRepeatTime), function()
        playSound(self.actor, self.soundTable, self.duration))
    end
end