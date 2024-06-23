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
function Animation:new(actor, animationData, animation) animation
    local instance      = setmetatable({
        actor = actor,
        animationData = animationData,
        animation = animation
    }, Animation)

    playAnimation()

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
playAnimation = function()
    Osi.PlayAnimation(self.actor, "") -- First, stop current animation on actor
    if self.animationData.Loop == true then
        Osi.PlayLoopingAnimation(self.actor, "", self.animation, "", "", "", "", "")
    else
        Osi.PlayAnimation(self.actor, self.animation)
        end
    end
end



----------------------------------------------------------------------------------------------------
-- 
--                                              End
-- 
----------------------------------------------------------------------------------------------------