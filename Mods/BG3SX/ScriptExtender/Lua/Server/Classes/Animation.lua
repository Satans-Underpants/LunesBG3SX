----------------------------------------------------------------------------------------------------
-- 
--                             Animation Playing Handling [Mostly Timer based]
-- 
----------------------------------------------------------------------------------------------------


-- CONSTRUCTOR
--------------------------------------------------------------

Animation = {}
Animation.__index = Animation

local playAnimation
function Animation:new(actor, animationData, animation)
    local instance = setmetatable({
        actor = actor,
        animationData = animationData,
        animation = animation
    }, Animation)

    playAnimation(instance) -- Automatically calls this function on creation

    return instance
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
        Osi.PlayLoopingAnimation(self.actor.uuid, "", self.animation, "", "", "", "", "")
    else
        Osi.PlayAnimation(self.actor.uuid, self.animation)
    end
    -- _P("[BG3SX][Animation.lua] - Animation:new() - playAnimation - Begin to play ", self.animation, " on ", self.actor.uuid)
end