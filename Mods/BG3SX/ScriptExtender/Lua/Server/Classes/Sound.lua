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

    playSound(instance) -- Automatically calls this function on creation

    return instance
end


-- Initialization
--------------------------------------------------------------

playSound = function(self)
    local scene = Scene:FindSceneByEntity(self.actor.parent)

    if scene then
        local minRepeatTime = self.duration - 200
        local maxRepeatTime = self.duration + 200
        Osi.PlaySound(self.actor.uuid, "") -- First, stop current sound

        local sound = self.soundTable[math.random(1, #self.soundTable)]
        Osi.PlaySound(self.actor.uuid, sound) -- Plays a random entry of sounds on an actor
        
        -- Will be an infinite loop until registered timer gets canceled on Scene:Destroy()
        local newSoundTimer = Ext.Timer.WaitFor(math.random(minRepeatTime, maxRepeatTime), function()
            for i = #scene.timerHandles, 1, -1 do
                local handle = scene.timerHandles[i]
                table.remove(scene.timerHandles, i)
            end
            -- _D(scene.timerHandles)
            playSound(self)
        end)
        scene:RegisterNewSoundTimer(newSoundTimer)
        -- _P("[BG3SX][Sound.lua] - Sound:new() - Begin to play ", sound, " on Actor ", self.actor.uuid)
    else
        -- _P("[BG3SX][Sound.lua] - Sound:new() - Scene does not exist anymore")
        -- This else situation can still happen when sound timers are running out after a scene got destroyed, tho we destroy everything and nothing should happen
    end
end