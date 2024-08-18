----------------------------------------------------------------------------------------
--
--                               For handling Effects
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------


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
        Osi.ScreenFadeTo(entity, 0.1, 0.1, "ScreenFade")
        Ext.Timer.WaitFor(duration, function()
            clearFade(entity)
        end)
    end
end


-- Triggers an effect on an entity
---@param entity any
---@param effect any
function Effect:Trigger(entity, effect)
    Osi.ApplyStatus(entity, effect, 1)
end