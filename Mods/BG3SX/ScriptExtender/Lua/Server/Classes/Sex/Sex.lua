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

-- General
--------------------------------

-- Terminates all running scenes
function Sex:TerminateAllScenes()
    for _, scene in pairs(SAVEDSCENES) do
        scene:Destroy()
    end
    SAVEDSCENES = {}
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
    end
    for _,entry in pairs(SCENETYPES) do
        if involvedEntities == entry.involvedEntities and penises == entry.penises then
            return entry.sceneType
        end
    end
end


-- Removes the sex spells on an entity when scene has ended
---@param entity    Entity  - The entity uuid to remove the spells from
function Sex:RemoveSexSceneSpells(entity)
    for _, spell in pairs(SEXSCENESPELLS) do -- Configurable in Shared/Data/Spells.lua
     Osi.RemoveSpell(entity, spell)
    end
end


-- Animations
--------------------------------

-- TODO: Add Height Check
-- Plays the appropriate animation and sound for a given actor based on their position in a scene.
-- @param actor         Actor   - The actor to play an animation and sound on
-- @param animationData table   - The chosen animations data table
-- @param position      string  - Specifies the actor's position (either "Top" or "Bottom") to determine the correct animation and sound
local function playAnimationAndSound(actor, animationData, position)
    local animation
    local newAnimation
    local newSound
    if position == "Top" then
        animation = animationData.FallbackTopAnimationID
        newAnimation = Animation:new(actor, animationData, animation) 
        newSound = Sound:new(actor, animationData.SoundTop, animationData.AnimLength)       
    elseif position == "Bottom" then
        animation = animationData.FallbackTopAnimationID
        newAnimation = Animation:new(actor, animationData, animationData.FallbackBottomAnimationID)
        if animationData.SoundBottom then
            newSound = Sound:new(actor, animationData.SoundBottom, animationData.AnimLength)
        else
            newSound = Sound:new(actor, animationData.SoundTop, animationData.AnimLength)
        end
    end

    Event:new("BG3SX_AnimationChange", newAnimation)
    Event:new("BG3SX_SoundChange", newSound)
end


-- Determines which type of scene the entity is part of and assigns the appropriate animations and sounds to the actors involved
---@param entity         Entity  - The entity which used a new animation spell
---@param animationData  table   - The chosen animations data table
function Sex:PlayAnimation(entity, animationData)
    local scene = Scene:FindSceneByEntity(entity)
    local sceneType = Sex:DetermineSceneType(scene)
    if sceneType == "MasturbateFemale" then
        playAnimationAndSound(scene.actors[1], animationData, "Bottom")

    elseif sceneType == "MasturbateMale" then
        playAnimationAndSound(scene.actors[1], animationData, "Top")

    elseif sceneType == "Lesbian" or sceneType == "Gay" then
        playAnimationAndSound(scene.actors[1], animationData, "Top")
        playAnimationAndSound(scene.actors[2], animationData, "Bottom")

    elseif sceneType == "Straight" then -- Handle this in a different way to enable actor swapping even for straight animations
        local actor1 = scene.actors[1]
        local actor2 = scene.actors[2]
        -- In case of actor1 not being male, swap them around to still assign correct animations
        if not Entity:HasPenis(scene.actors[1].parent) then
            actor1 = scene.actors[2]
            actor2 = scene.actors[1]
        end
        playAnimationAndSound(actor1, animationData, "Top")
        playAnimationAndSound(actor2, animationData, "Bottom")
        
    elseif sceneType == "FFF" then

    elseif sceneType == "FFM" then

    elseif sceneType == "MMF" then

    elseif sceneType == "MMM" then

    end

    if animationData ~= scene.currentAnimation then
        -- Since animation is not the same as before save the new animationData table to the scene to use for prop management, teleporting or rotating
        scene.currentAnimation = animationData
        scene:DestroyProps() -- Props rely on scene.currentAnimation
        scene:CreateProps()
    end
end


----------------------------------------------------------------------------------------------------
-- 
-- 										   Sex Setup
-- 
----------------------------------------------------------------------------------------------------

--- Handles the StartSexSpellUsed Event by starting new animations based on spell used
---@param caster            string  - The caster UUID
---@param targets           table   - The targets UUIDs
---@param animationData     table   - The animation data to use
function Sex:StartSexSpellUsed(caster, targets, animationData)
    local scene
    if animationData then
        -- _P("----------------------------- [BG3SX][Sex.lua] - Creating new scene -----------------------------")
        local sexHavers = {caster}

        for _,target in pairs(targets) do
            if target ~= caster then -- To not add caster twice if it might also be the target
                table.insert(sexHavers, target)
            end
        end

        for _,involved in pairs(sexHavers) do
            Effect:Fade(involved, 666)
        end

        -- Delay the rest as well, since scene initilization is delayed for 1 second to avoid user seeing behind the scenes stuff
        local function haveSex()
            scene = Scene:new(sexHavers)
            
            -- TODO - works for masturbation but not for sex
            for _, actor in pairs(scene.actors) do
                print("giving erection to ", actor.parent , "`s clone ", actor.uuid)
                Genital:GiveErection(actor)
            end

            Sex:InitSexSpells(scene)
            Sex:PlayAnimation(caster, animationData)
        end
        Ext.Timer.WaitFor(333, function() haveSex() end)
    end
end


--- Adds the main sex spells to an entity
---@param entity    string  - The entities UUID
function Sex:AddMainSexSpells(entity)
    if (Entity:IsPlayable(entity)
        or Osi.IsTagged(entity, "HUMANOID_7fbed0d4-cabc-4a9d-804e-12ca6088a0a8") == 1
        or Osi.IsTagged(entity, "FIEND_44be2f5b-f27e-4665-86f1-49c5bfac54ab") == 1)
        and Osi.IsTagged(entity, "KID_ee978587-6c68-4186-9bfc-3b3cc719a835") == 0
    then
        for _, spell in pairs(MAINSEXSPELLS) do -- Configurable in Shared/Data/Spells.lua
            Osi.AddSpell(entity, spell)
        end
    end
end
function Sex:RemoveMainSexSpells(entity)
    for _, spell in pairs(MAINSEXSPELLS) do  -- Configurable in Shared/Data/Spells.lua
        Osi.RemoveSpell(entity, spell)
    end
end


-- Adds additional sex spells for an entity
---@param entity    string  - The entity UUID to give additional spells to
local function addAdditionalSexActions(entity)
    local scene = Scene:FindSceneByEntity(entity)
    local spellCount = 1
    for _,spell in pairs(ADDITIONALSEXACTIONS) do  -- Configurable in Shared/Data/Spells.lua
        -- If iteration lands on SwitchPlaces spell, check which scene type the entity is in and only add it if its not a solo one
        if spell == "BG3SX_SwitchPlaces" then
            local sceneType = Sex:DetermineSceneType(scene)
            if not (sceneType == "MasturbateFemale" or sceneType == "MasturbateMale" or sceneType == "Straight") then
                Ext.Timer.WaitFor(spellCount * 200, function()
                    Osi.AddSpell(entity, spell)
                    spellCount = spellCount + 1
                end)
            end            
        else
            Ext.Timer.WaitFor(spellCount*200, function()
                Osi.AddSpell(entity, spell)
                spellCount = spellCount+1
            end)
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

            for _, entry in pairs(SCENETYPES) do
                if sceneType == entry.sceneType then
                    Osi.AddSpell(entity, entry.container) -- Add correct spellcontainer based on sceneType
                end
            end

            addAdditionalSexActions(entity)
        end
    end
end


-- UNUSED
--- Strips an actor of an entity
---@param scene Scene
---@param entity uuid
function Sex:PairedSexStrip(scene, entity)
    for _, actor in scene.actors do
        if actor.parent == entity then
            Osi.ApplyStatus(actor, "PASSIVE_WILDMAGIC_MAGICRETRIBUTION_DEFENDER", 1)
            Entity:UnequipAll(actor)
        end
    end
end



-- Checks an uuid against the nonStripper table in EntityListeners.lua
---@param uuid any
function Sex:IsStripper(uuid)
    
    if Osi.HasActiveStatus(uuid, "BG3SX_BLOCK_STRIPPING_BOOST") == 1 then
        print("Has status ", uuid)
        return false
    else
        return true
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
function Sex:ChangeCameraHeight(uuid)
    local entity = Ext.Entity.Get(uuid)
    local currentEntityScale = Entity:TryGetEntityValue(uuid, nil, {"GameObjectVisual", "Scale"})

    -- floating point shenanigangs
    if entity.GameObjectVisual then -- Safeguard against someone trying to create a scene with Scenery NPCs
        if currentEntityScale > 0.99 and currentEntityScale < 1.01 then
            entity.GameObjectVisual.Scale = 0.5
        elseif currentEntityScale > 0.49 and currentEntityScale < 0.51 then
            entity.GameObjectVisual.Scale = 0.05
        elseif currentEntityScale > 0.04 and currentEntityScale < 0.06 then
            entity.GameObjectVisual.Scale = 1.0
        end
        entity:Replicate("GameObjectVisual")
    end

    Event:new("BG3SX_CameraHeightChange", entity) -- MOD EVENT   
end