----------------------------------------------------------------------------------------
--
--                               For handling Sex functionalities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

Sex = {}
Sex.__index = Sex

-- METHODS
--------------------------------------------------------------

-- Changes the camera height by scaling an entity
-- Camera will zoom out on the entity which will look nicer on scene start
---@param entity string - uuid of the entity 
function Sex:ChangeCameraHeight(entity)
    if entity.GameObjectVisual.Scale == 0.5 then
        entity.GameObjectVisual.Scale = 0.05
        entity:Replicate("GameObjectVisual")
    elseif entity.GameObjectVisual.Scale ~= 0.5 then
        entity.GameObjectVisual.Scale = 0.5
        entity:Replicate("GameObjectVisual")
    end
end


----------------------------------------------------------------------------------------------------
-- 
-- 										   Sex
-- 
----------------------------------------------------------------------------------------------------


-- Starts the Sex animation
function Sex:StartAnimation(actorData, animProperties)
    SexActor_StopVocalTimer(actorData)

    local animActor = actorData.Proxy or actorData.Actor
    if animProperties["Loop"] == true then
        -- _P("[SexActor.lua] Begin playing looping animation: ", actorData.Animation)
        Osi.PlayLoopingAnimation(animActor, "", actorData.Animation, "", "", "", "", "")
    else
        -- _P("[SexActor.lua] Begin playing animation: ", actorData.Animation)
        Osi.PlayAnimation(animActor, actorData.Animation)
    end

    if animProperties["Sound"] == true and #actorData.SoundTable >= 1 then
        SexActor_StartVocalTimer(actorData, 600)
    end

    --Update the Persistent Variable on the actor so that other mods can use this
    local actorEntity = Ext.Entity.Get(actorData.Actor)
    actorEntity.Vars.ActorData = actorData

    --Fire a timer to notify other mods that an Animation has started or changed 
    SexEvent_SexAnimationStart(actorData)
end




function SexActor_StartVocalTimer(actorData, time)
    Osi.ObjectTimerLaunch(actorData.Actor, actorData.VocalTimerName, time)
end




function SexActor_StopVocalTimer(actorData)
    Osi.ObjectTimerCancel(actorData.Actor, actorData.VocalTimerName)
end



function SexActor_PlayVocal(actorData, minRepeatTime, maxRepeatTime)
    if #actorData.SoundTable >= 1 then
        local soundActor = actorData.Proxy or actorData.Actor
        Osi.PlaySound(soundActor, actorData.SoundTable[math.random(1, #actorData.SoundTable)])
        SexActor_StartVocalTimer(actorData, math.random(minRepeatTime, maxRepeatTime))
    end
end

function SexEvent_SexAnimationStart(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_SexAnimationStart", 1)
end

function SexEvent_EndSexScene(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_EndSexScene", 1)
end

-- TODO: Move the function to a separate SexScene.lua or something
function SexActor_MoveSceneToLocation(newX, newY, newZ, casterData, targetData, scenePropObject)
    -- Do nothing if the new location is too far from the caster's start position,
    -- so players would not abuse it to get to some "no go" places.
    local dx = newX - casterData.StartX
    local dy = newY - casterData.StartY
    local dz = newZ - casterData.StartZ
    if math.sqrt(dx * dx + dy * dy + dz * dz) >= 4 then
        return
    end

    -- Move stuff
    function TryMoveObject(obj)
        if obj then
            Osi.TeleportToPosition(obj, newX, newY, newZ)
        end
    end

    Osi.SetDetached(casterData.Actor, 1)

    TryMoveObject(casterData.Proxy)
    if targetData then
        TryMoveObject(targetData.Proxy)
    end
    TryMoveObject(scenePropObject)
    TryMoveObject(casterData.Actor)
    if targetData then
        TryMoveObject(targetData.Actor)
        Osi.CharacterMoveToPosition(targetData.Actor, newX, newY, newZ, "", "")
    end

    Osi.SetDetached(casterData.Actor, 0)
end
