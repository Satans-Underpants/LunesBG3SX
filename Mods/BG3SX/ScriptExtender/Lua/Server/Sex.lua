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

--- Handles the SexSpellUsed Event by starting new animations based on spell used
---@param caster            string  - The casters UUID
---@param target            string  - The targets UUID
---@param animProperties    table   - The animation properites to use
function Sex:SexSpellUsed(caster, target, animProperties)

    if animProperties then
        Scene:new({caster, target})

        -- dunno if we should move animProperties over to the scene as well, to store which animation is supposed to be placed right now
    end




    -- vvvvvvvvvvv old stuff vvvvvvvvvvv

    -- if animProperties then
    --     if animProperties["Type"] == "Solo" then
    --         StartSoloAnimation(caster, animProperties)
    --     elseif animProperties["Type"] == "Paired" then
    --         Scene:StartPairedScene(caster, target, animProperties)
    --     end
    -- end
end

--- Adds the main sex spells to an entity
---@param entity    string - The entities UUID
function Sex:AddMainSexSpells(entity)
    -- Add "Start Sex" and "Sex Options" spells only if entity is PLAYABLE or HUMANOID or FIEND, and is not a child (KID)
    if (Entity:IsPlayable(entity)
        or Osi.IsTagged(entity, "HUMANOID_7fbed0d4-cabc-4a9d-804e-12ca6088a0a8") == 1 
        or Osi.IsTagged(entity, "FIEND_44be2f5b-f27e-4665-86f1-49c5bfac54ab") == 1)
        and Osi.IsTagged(entity, "KID_ee978587-6c68-4186-9bfc-3b3cc719a835") == 0
    then
        Osi.AddSpell(entity, "StartSexContainer")
        Osi.AddSpell(entity, "Change_Genitals")
        Osi.AddSpell(entity, "BG3SXOptions")
        -- we switched to another spell
        Osi.RemoveSpell(entity, "SexOptions")
    end
end


----------------------------------------------------------------------------------------------------
-- 
-- 										   Sex
-- 
----------------------------------------------------------------------------------------------------


-- Spells
--------------------------------------------------------------

-- Adds Sex spells for the caster
-- TODO: Add functionality to also add them to targets
---@param sceneData any
---@param casterData any
---@param timerName any
local function addSexSpells(entity)

    -- for _, entity in pairs(entities) do

        if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
            Osi.AddSpell(casterData.Actor, sceneData.CasterSexSpells[sceneData.NextCasterSexSpell])

            sceneData.NextCasterSexSpell = sceneData.NextCasterSexSpell + 1
            if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
                -- A pause greater than 0.1 sec between two (Try)AddSpell calls in needed 
                -- for the spells to appear in the hotbar exactly in the order they are added.
                -- Osi.ObjectTimerLaunch(casterData.Actor, timerName, 200)
                Ext.Timer.Waitfor(200) -- trigger sometimes
            end
        end
    -- end
end

-- Give the entities the correct spells based on amount of entities in the scene
-- Currently only masturbation and 2 people is supported
-- Also add spells that everyone gets like end sex
function Sex:InitSexSpells(scene)
    
    for _, entity in pairs(scene.entities) do

        addSexSpells(entity)

        -- entity.CasterSexSpells = {}
        -- entity.NextCasterSexSpell = 1

    end

end


-- Registers Sex spells to distribute
---@param sceneData any
---@param spellName any
function Sex:RegisterCasterSexSpell(sceneData, spellName)
    sceneData.CasterSexSpells[#sceneData.CasterSexSpells + 1] = spellName
end





-- Animations
--------------------------------------------------------------

-- Starts a Sex animation
---@param actorData any
---@param animProperties any
function Sex:StartAnimation(actorData, animProperties)
    Sex:StopVocalTimer(actorData)

    local animActor = actorData.Proxy or actorData.Actor
    if animProperties["Loop"] == true then
        -- _P("[SexActor.lua] Begin playing looping animation: ", actorData.Animation)
        Osi.PlayLoopingAnimation(animActor, "", actorData.Animation, "", "", "", "", "")
    else
        -- _P("[SexActor.lua] Begin playing animation: ", actorData.Animation)
        Osi.PlayAnimation(animActor, actorData.Animation)
    end

    if animProperties["Sound"] == true and #actorData.SoundTable >= 1 then
        Sex:StartVocalTimer(actorData, 600)
    end

    -- --Update the Persistent Variable on the actor so that other mods can use this
    -- local actorEntity = Ext.Entity.Get(actorData.Actor)
    -- actorEntity.Vars.ActorData = actorData

    --Fire a timer to notify other mods that an Animation has started or changed 
    Sex:SexAnimationStartTimer(actorData)
end


-- Sound
--------------------------------------------------------------

--
---@param actorData any
---@param time any
function Sex:StartVocalTimer(actorData, time)
    Osi.ObjectTimerLaunch(actorData.Actor, actorData.VocalTimerName, time)
end


--
---@param actorData any
function Sex:StopVocalTimer(actorData)
    Osi.ObjectTimerCancel(actorData.Actor, actorData.VocalTimerName)
end


--
---@param actorData any
---@param minRepeatTime any
---@param maxRepeatTime any
function Sex:PlayVocal(actorData, minRepeatTime, maxRepeatTime)
    if #actorData.SoundTable >= 1 then
        local soundActor = actorData.Proxy or actorData.Actor
        Osi.PlaySound(soundActor, actorData.SoundTable[math.random(1, #actorData.SoundTable)])
        Sex:StartVocalTimer(actorData, math.random(minRepeatTime, maxRepeatTime))
    end
end


--
---@param actorData any
function Sex:SexAnimationStartTimer(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_SexAnimationStart", 1)
end


--
---@param actorData any
function Sex:EndSexSceneTimer(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_EndSexScene", 1)
end

-- Enables or Disables getting the Role Switch spell for the lesbian/gay/straight UpdateAvailableAnimations check
local roleSwitch = 0
function Sex:EnableRoleSwitch()
    roleSwitch = 1
    return roleSwitch
end
function Sex:DisableRoleSwitch()
    roleSwitch = 0
    return roleSwitch
end


--
function Sex:MoveSceneToLocation(entity, location)
    for _, scene in pairs(SAVEDSCENES) do
        for _, entry in pairs(scene.entities) do
            if entity == entry then
                
            end
        end
    end

    local dx = newX - casterData.StartX
    local dy = newY - casterData.StartY
    local dz = newZ - casterData.StartZ
    
    -- Do nothing if the new location is too far from the caster's start position,
    -- so players would not abuse it to get to some "no go" places.
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


-- Updates available spells for all involved entities of a scene
---@param entities  Table   - Table of entities of a scene
function Sex:UpdateAvailableAnimations(entities)
    for i = 1, #entities, 2 do
        local entity1 = entities[i]
        local entity2 = entities[i + 1]

        local pair = {entity1, entity2}
        local topData = pair[1]
        local btmData = pair[2]

        if Entity:HasPenis(entity1) == false and Entity:HasPenis(entity2) == false then -- Both have vulva
            Entity:SetAvailableAnimations(entity1, "LesbianAnimationsContainer")
            Entity:SetAvailableAnimations(entity2, "LesbianAnimationsContainer")
        elseif Entity:HasPenis(entity1) == true and Entity:HasPenis(entity2) == true then -- Both have penis
            Entity:SetAvailableAnimations(entity1, "GayAnimationsContainer")
            Entity:SetAvailableAnimations(entity2, "GayAnimationsContainer")
        else -- One has penis, one has vulva
            Entity:SetAvailableAnimations(entity1, "StraightAnimationsContainer")
            Entity:SetAvailableAnimations(entity2, "StraightAnimationsContainer")
        end

        local switchRoles = 0 -- No role switch
        if Entity:HasPenis(entity1) == Entity:HasPenis(entity2) and pairData.SwitchPlaces then
            switchRoles = 1 -- Normal role switch
        elseif Entity:HasPenis(entity1) == false and Entity:HasPenis(entity2) then
            switchRoles = 2 -- Forced switch for FxM pair
        end
        if switchRoles ~= 0 then
            btmData, topData = topData, btmData
        end

        local topAnimation, btmAnimation
        local heightAnimation = pairData.AnimProperties[topData.HeightClass .. "Top_" .. btmData.HeightClass .. "Btm"]
        if heightAnimation then
            topAnimation = heightAnimation.Top
            btmAnimation = heightAnimation.Btm
        else
            topAnimation = pairData.AnimProperties.FallbackTopAnimationID
            btmAnimation = pairData.AnimProperties.FallbackBottomAnimationID
        end

        -- For the initial "standing hug" animation in a FxM pair do NOT revert top/bottom roles
        if switchRoles == 2 and topAnimation == "49d78660-5175-4ed2-9853-840bb58cf34a" and btmAnimation == "10fee5b7-d674-436c-994c-616e01efcb90" then
            switchRoles = 0
            btmData, topData = topData, btmData
        end

        topData.Animation  = topAnimation
        topData.SoundTable = pairData.AnimProperties.SoundTop
        btmData.Animation  = btmAnimation
        btmData.SoundTable = pairData.AnimProperties.SoundBottom

        -- Update the Persistent Variable on the entity so that other mods can use this
        local casterEnt = Ext.Entity.Get(topData)
        local targetEnt = Ext.Entity.Get(btmData)
        casterEnt.Vars.PairData = pairData
        targetEnt.Vars.PairData = pairData
    end
end











function Sex:UpdateAvailableAnimations(actors)
    for _, actor in pairs(actors) do
        


    end


    local topData = pairData.CasterData
    local btmData = pairData.TargetData

    if topData.HasPenis == false and btmData.HasPenis == false then
        pairData.AnimContainer = "LesbianAnimationsContainer"
    elseif topData.HasPenis == true and btmData.HasPenis == true then
        pairData.AnimContainer = "GayAnimationsContainer"
    else
        pairData.AnimContainer = "StraightAnimationsContainer"
    end

    local switchRoles = 0 -- No role switch
    if topData.HasPenis == btmData.HasPenis and pairData.SwitchPlaces then
        switchRoles = 1 -- Normal role switch
    elseif topData.HasPenis == false and btmData.HasPenis then
        switchRoles = 2 -- Forced switch for FxM pair
    end
    if switchRoles ~= 0 then
        btmData, topData = topData, btmData
    end

    local topAnimation, btmAnimation
    local heightAnimation = pairData.AnimProperties[topData.HeightClass .. "Top_" .. btmData.HeightClass .. "Btm"]
    if heightAnimation then
        topAnimation = heightAnimation.Top
        btmAnimation = heightAnimation.Btm
    else
        topAnimation = pairData.AnimProperties.FallbackTopAnimationID
        btmAnimation = pairData.AnimProperties.FallbackBottomAnimationID
    end

    -- For the initial "standing hug" animation in a FxM pair do NOT revert top/bottom roles
    if switchRoles == 2 and topAnimation == "49d78660-5175-4ed2-9853-840bb58cf34a" and btmAnimation == "10fee5b7-d674-436c-994c-616e01efcb90" then
        switchRoles = 0
        btmData, topData = topData, btmData
    end

    topData.Animation  = topAnimation
    topData.SoundTable = pairData.AnimProperties.SoundTop
    btmData.Animation  = btmAnimation
    btmData.SoundTable = pairData.AnimProperties.SoundBottom

    --Update the Persistent Variable on the actor so that other mods can use this
    local casterEnt = Ext.Entity.Get(pairData.Caster)
    local targetEnt = Ext.Entity.Get(pairData.Target)
    casterEnt.Vars.PairData = pairData
    targetEnt.Vars.PairData = pairData
end



















function Sex:TerminateAllScenes()
    for _, scene in pairs(SAVEDSCENES) do
        scene:Destroy()
    end
    SAVEDSCENES = {}
end