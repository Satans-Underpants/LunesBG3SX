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

----------------------------------------------------------------------------------------------------
-- 
-- 										   Sex Setup
-- 
----------------------------------------------------------------------------------------------------


--- Strips an actor of an entity
---@param scene Scene
---@param entity uuid
function Sex:PairedSexStrip(scene, entity)

    -- for _, actor in scene.actors do
    --     if actor.parent == entity do 
    --         Osi.ApplyStatus(actor, "PASSIVE_WILDMAGIC_MAGICRETRIBUTION_DEFENDER", 1)
    --         Entity:UnequipAll(actor)
    --     end
    -- end


    Osi.ApplyStatus(entity, "PASSIVE_WILDMAGIC_MAGICRETRIBUTION_DEFENDER", 1)
    Entity:UnequipAll(entity)
end


local additionalSexSpells = {
    "BG3SX_StopAction",
    "BG3SX_SwitchPlaces",
    "BG3SX_ChangeSceneLocation",
    "BG3SX_ChangeCameraHeight"
}           
-- Adds additional sex spells for an entity
---@param entity    string  - The entity UUID to give additional spells to
local function addAdditionalSexSpells(entity)
    local spellCount = 1

    for _,spell in pairs(additionalSexSpells) do
        if spell == "BG3SX_SwitchPlaces" then
            local sceneType = Sex:DetermineSceneType(entity)
            if not sceneType == "MasturbateFemale" or not sceneType == "MasturbateMale" then
                Ext.Timer.WaitFor(spellCount*200, function()
                Osi.AddSpell(entity, spell)
                spellCount = spellCount+1)
            end 
        else
            Ext.Timer.WaitFor(spellCount*200, function()
                Osi.AddSpell(entity, spell)
                spellCount = spellCount+1)
        end
    end
end

-- Determines the scene type based on how many entities and penises are involved
---@param  scene Scene       - The scene to check
---@return sceneType string 
function Sex:DetermineSceneType(scene)
    local involvedEntities = 0
    local penises = 0
    for _, entity in pairs(scene.entities) do
        involvedEntities = involvedEntities+1
        if Entity:HasPenis(entity) then
            penises = penises+1
    end
    for _,entry in SCENETYPES do
        if involvedEntities == entry.involvedEntities and penises == entry.penises then
            return entry.sceneType
        end
    end   
end

-- Give the entities the correct spells based on amount of entities and penises in the scene
-- Also add spells that everyone gets like end sex
---@param scene Scene   - The scene the function should get executed for
function Sex:InitSexSpells(scene)
    local sceneType = Sex:DetermineSceneType(scene)

    for _, entity in pairs(scene.entities) do -- For each entity involved
        if Entity:IsPlayable(entity) then -- Check if they are playable to not do this with NPCs
            
            for _, entry in SCENETYPES do
                if sceneType == entry.sceneType then
                    Osi.AddSpell(entity, entry.container) -- Add correct spellcontainer based on sceneType
                end
            end

            addAdditionalSexSpells(entity)
        end
    end
end


--- Adds the main sex spells to an entity
---@param entity    string  - The entities UUID
function Sex:AddMainSexSpells(entity)
    -- Add "Start Sex" and "Sex Options" spells only if entity is PLAYABLE or HUMANOID or FIEND, and is not a child (KID)
    if (Entity:IsPlayable(entity)
        or Osi.IsTagged(entity, "HUMANOID_7fbed0d4-cabc-4a9d-804e-12ca6088a0a8") == 1 
        or Osi.IsTagged(entity, "FIEND_44be2f5b-f27e-4665-86f1-49c5bfac54ab") == 1)
        and Osi.IsTagged(entity, "KID_ee978587-6c68-4186-9bfc-3b3cc719a835") == 0
    then
        Osi.AddSpell(entity, "BG3SX_MainContainer")
        Osi.AddSpell(entity, "BG3SX_ChangeGenitals")
        Osi.AddSpell(entity, "BG3SX_Options")
    end
end

--- Handles the StartSexSpellUsed Event by starting new animations based on spell used
---@param caster            string  - The casters UUID
---@param target            string  - The targets UUID
---@param animationData     table   - The animation data to use
function Sex:StartSexSpellUsed(caster, target, animationData)
    if animationData then
        Scene:new({caster, target})
        Sex:PlayAnimation(caster, animationData)
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 										   Sex Options
-- 
----------------------------------------------------------------------------------------------------

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


-- Animations
--------------------------------------------------------------

local function playAnimationAndSound(actor, animationData, position)
    local animation
    if position == "Top" then
        animation = animationData.FallbackTopAnimationID
        Animation:new(actor, animationData, animation)
        Sound:new(actor, animationData.SoundTop, animationData.Duration, animationData.Duration)
    elseif position == "Bottom" then
        animation = animationData.FallbackTopAnimationID
        Animation:new(actor, animationData, animationData.FallbackBottomAnimationID)
        Sound:new(actor, animationData.SoundBottom, animationData.Duration, animationData.Duration)
    end
    local payload
    Ext.Net.BroadcastMessage("BG3SX_AnimationChange", actor, animtiona)
    Ext.Net.BroadcastMessage("BG3SX_SoundChange", actor)
end

-- Start new animations and sound for the actors of a scene
---@param entity    Entity  - 
---@param animProperties any
function Sex:PlayAnimation(entity, animProperties)
    local scene = Scene:FindSceneByEntity(entity)
    local sceneType = Sex:DetermineSceneType(scene)

    
    if sceneType == "MasturbateFemale" or sceneType == "MasturbateMale"
        playAnimationAndSound(scene.actors[1], animationData, "Bottom")

    elseif sceneType == "Lesbian" or sceneType == "Gay"
        playAnimationAndSound(scene.actor[1], animationData, "Top")
        playAnimationAndSound(scene.actor[2], animationData, "Bottom")

    elseif sceneType == "Straight"
        local actor1 = scene.actors[1]
        local actor2 = scene.actors[2]
            -- In case of actor1 not being male, swap them around to still assign correct animations
            if not Entity:HasPenis(scene.actors[1].parent) -- Swap them around in case actor is not mal
                actor2 = actor1
                actor2 = scene.actors[1]
            end
        playAnimationAndSound(actor1, animationData, "Top")
        playAnimationAndSound(actor2, animationData, "Bottom")
        
    elseif sceneType == "FFF"

    elseif sceneType == "FFM"

    elseif sceneType == "MMF"

    elseif sceneType == "MMM"
    end
end


--
---@param actorData any
function Sex:SexAnimationStartTimer(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_SexAnimationStart", 1) -- Event_SexAnimationStart does not exist
end


--
---@param actorData any
function Sex:EndSexSceneTimer(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_EndSexScene", 1) -- Event_EndSexScene does not exist
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






--- func desc
---@param pairData any
function Sex:UpdateAvailableAnimations(pairData)
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


-- To know what to write here check the timer listeners with 
-- the correcponsing timer name





-- TODO - we have a TerminatePairedAnimation and a StopPairedAnimation -> see whats up with that
Sex:FinishSex(scene)
    TerminatePairedAnimation(pairData)
    table.remove(AnimationPairs, pairIndex)
end


-- TODO - might fit better to anim
Sex:AnimStart(scene)
    Scene:FinalizeSetup(pairData.CasterData, pairData.ProxyData)
    PlayPairedAnimation(pairData)
    Osi.SetDetached(pairData.Caster, 0)
end


        


------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- 										Spell Handling
-- 
----------------------------------------------------------------------------------------------------

-- Removes the sex spells on an entity when scene has ended
---@param entity    Entity  - The entity uuid to remove the spells from
local function removeSexPositionSpells(entity) -- entity
    Osi.RemoveSpell(entity, "StraightAnimationsContainer")
    Osi.RemoveSpell(entity, "LesbianAnimationsContainer")
    Osi.RemoveSpell(entity, "GayAnimationsContainer")
    Osi.RemoveSpell(entity, "FemaleMasturbationContainer")
    Osi.RemoveSpell(entity, "MaleMasturbationContainer")
    Osi.RemoveSpell(entity, "BG3SX_StopAction")
    Osi.RemoveSpell(entity, "BG3SX_StopMasturbating")
    Osi.RemoveSpell(entity, "BG3SX_ChangeCameraHeight")
    Osi.RemoveSpell(entity, "BG3SX_ChangeSceneLocation")
    Osi.RemoveSpell(entity, "BG3SX_SwitchPlaces")
end