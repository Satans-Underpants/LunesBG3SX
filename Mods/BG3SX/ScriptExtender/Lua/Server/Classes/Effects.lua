----------------------------------------------------------------------------------------
--
--                               For handling Effects
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

Effect = {}
Effect.__index = Effect

-- METHODS
--------------------------------------------------------------

-- Cancels a screen fadeout
---@param entity    string  - The affected entities UUID
local function clearFade(entity)
    Osi.ClearScreenFade(entity, 0.1, "ScreenFade", 0)
end


-- Fades the screen black (e.g. during Setup of a Scene)
---@param entity    string  - The affected entities UUID
---@param duration  Time    - The time the fade is active
function Effect:Fade(entity, duration)
    if Entity:IsPlayable(entity) then
        Osi.ScreenFadeTo(entity, 0.1, 0.1, "ScreenFade") -- Might need to rename string to "AnimFade"
        --Ext.Timer.WaitFor(duration ,clearFade(entity))

        Ext.Timer.WaiFor(duration, function()
            clearFade(entity)
        end
        )
    end
end


--- func desc
---@param entity any
---@param effect any
function Effect:Trigger(entity, effect)
    Osi.ApplyStatus(caster, effect, 1)
end