----------------------------------------------------------------------------------------
--
--                               For handling Sound functionalities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

Sound = {}
Sound.__index = Sound

-- Sound
--------------------------------------------------------------

--
---@param actor any
function Sex:StopVocals(actor)
    Sound:PlaySound(actor)
end


--
---@param actor         Actor
---@param minRepeatTime Time
---@param maxRepeatTime Time
function Sound:PlaySound(actor, soundTable, minRepeatTime, maxRepeatTime)
    if sound then
        Osi.PlaySound(actor, soundTable[math.random(1, #soundTable)]) -- Plays a random entry of moaning sounds on an actor
    end
    -- Will be an infinite loop because it calls itself, need another way to handle it
    -- Ext.Timer.WaitFor(math.random(minRepeatTime, maxRepeatTime), Sound:PlaySound(actor, minRepeatTime, maxRepeatTime))
end