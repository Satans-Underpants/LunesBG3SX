----------------------------------------------------------------------------------------------------
-- 
--                             Animation Playing Handling [Mostly Timer based]
-- 
----------------------------------------------------------------------------------------------------


-- CONSTRUCTOR
--------------------------------------------------------------

local playAnimation
function Animation:new(actor, animSpell)
    local instance = setmetatable({
        actor = actor,
        animationData = animSpell, -- The chosen animations data table
        animation = ""
    }, Animation)
   
    local hmInstance = animSpell.Heightmatching
    local scene = Scene:FindSceneByEntity(actor.parent)
    local hmAnim
    local hmAnim2
    if hmInstance then
        if #scene.actors == 1 then
            instance.animation = hmInstance:getAnimation(actor.parent)
        else
            hmAnim, hmAnim2 = hmInstance:getAnimation(scene.actors[1].parent, scene.actors[2].parent)
            if scene.actors[1].parent == instance.actor.parent then
                instance.animation = hmAnim
            elseif scene.actors[2].parent == instance.actor.parent then
                instance.animation = hmAnim2
            else
                _P("[BG3SX][Animation.lua] Something went wrong! Contact mod author! [Error 1]")
            end
        end
        playAnimation(instance) -- Automatically calls this function on creation

        return instance
    else
        _P("[BG3SX][Animation.lua] Something went wrong! Contact mod author! [Error 2]")
    end
end

----------------------------------------------------------------------------------------------------
-- 
--                                             Start 
-- 
----------------------------------------------------------------------------------------------------

-- Stops remaining Animation and plays a new one
---@param actor         Actor   - The actor to play the animation with
---@param animationData Table   - The chosen animations data table
---@param animation     string  - The actual animation to play because there could be multiple ("Top"/"Bottom")
playAnimation = function(self)
  --  Osi.PlayAnimation(self.actor.uuid, "") -- First, stop current animation on actor
    if self.animationData.Loop == true then
        -- _P("Playing ", self.animation, " for ", self.actor.parent)
        Osi.PlayLoopingAnimation(self.actor.uuid, "", self.animation, "", "", "", "", "")
    else
        Osi.PlayAnimation(self.actor.uuid, self.animation)
    end
    -- _P("[BG3SX][Animation.lua] - Animation:new() - playAnimation - Begin to play ", self.animation, " on ", self.actor.uuid)
end