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
    
    -- _P("[BG3SX][Effects.lua] - Effect:Fade - clearFade - ScreenFade cleared for ", entity)
end


-- Fades the screen black (e.g. during Setup of a Scene)
---@param entity    string  - The affected entities UUID
---@param duration  Time    - The time the fade is active
function Effect:Fade(entity, duration)
    if Entity:IsPlayable(entity) then
        Osi.ScreenFadeTo(entity, 0.1, 0.1, "ScreenFade") -- Might need to rename string to "AnimFade"
        --Ext.Timer.WaitFor(duration ,clearFade(entity))

        -- _P("[BG3SX][Effects.lua] - Effect:Fade - ScreenFade started for ", entity)

        Ext.Timer.WaitFor(duration, function()
            clearFade(entity)
        end)
    end
end

-- TODO: Maybe - If there are Fade duration problems, try using this code to delay the Fade duration per actor getting scaled
-- local scaledEntites = {}
-- for _, entity in self.entities do
--     table.insert(scaledEntites, Entity:PurgeBodyScaleStatuses(entity))
-- end
-- if (#scaledEntites > 0) and setupDelay < BODY_SCALE_DELAY then
--     setupDelay = BODY_SCALE_DELAY -- Give some time for the bodies to go back to their normal scale
-- end
-- local casterScaled = Entity:PurgeBodyScaleStatuses(pairData.CasterData)
-- local targetScaled = Entity:PurgeBodyScaleStatuses(pairData.TargetData)
-- Osi.ObjectTimerLaunch(caster, "PairedSexFade.End", setupDelay + 800) -- Instead of Osi.ObjectTimerLaunch use the one below - Ext.Timer.WaitFor
-- Ext.Timer.WaitFor(setupDelay - 200, function() Effect:Fade(entity) end)


--- func desc
---@param entity any
---@param effect any
function Effect:Trigger(entity, effect)
    Osi.ApplyStatus(entity, effect, 1)

    -- _P("[BG3SX][Effects.lua] - Effect:Trigger - Effect ", effect, " added to ", entity)
end