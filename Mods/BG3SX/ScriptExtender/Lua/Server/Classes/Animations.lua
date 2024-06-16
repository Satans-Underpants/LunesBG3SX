----------------------------------------------------------------------------------------------------
-- 
-- 							Animation Playing Handling [Mostly Timer based]
-- 
----------------------------------------------------------------------------------------------------


-- CONSTRUCTOR
--------------------------------------------------------------

function Animation:new()
    local instance      = setmetatable({
    }, Animation)

    return instance
end



----------------------------------------------------------------------------------------------------
-- 
-- 							                Start 
-- 
----------------------------------------------------------------------------------------------------


--- func desc
---@param pairData any
function PlayAnimation(sceneActors, animation)

    for _, actor in pairs(sceneActors) do
        SexActor_StartAnimation(sceneActors.uuid, animation)
    end

    -- TODO - figure out what this does
    -- Timeout timer
    local animTimeout = animation["AnimLength"] * 1000
    if animTimeout > 0 then
        Osi.ObjectTimerLaunch(sceneActors[1].uuid, "PairedAnimTimeout", animTimeout)
    else
        Osi.ObjectTimerCancel(sceneActors[1].uuid, "", "PairedAnimTimeout")
    end
end


----------------------------------------------------------------------------------------------------
-- 
-- 							                 End
-- 
----------------------------------------------------------------------------------------------------



