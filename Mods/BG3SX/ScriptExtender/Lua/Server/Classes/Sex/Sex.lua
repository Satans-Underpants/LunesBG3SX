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
    _P("---------------------------------------------------------------------------------------------------")
    --_D(scene.entities)
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
    for _, spell in pairs(SEXSCENESPELLS) do
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
        --_P("---------------------------------ANIMATIONDATA--------------------------------")
        --_D(animationData)
        --newSound = Sound:new(actor, animationData.SoundTop, animationData.AnimLength)
        
    elseif position == "Bottom" then
        animation = animationData.FallbackTopAnimationID
        newAnimation = Animation:new(actor, animationData, animationData.FallbackBottomAnimationID)
        --_P("---------------------------------ANIMATIONDATA--------------------------------")
        --_D(animationData)
        if animationData.SoundBottom then
           -- newSound = Sound:new(actor, animationData.SoundBottom, animationData.AnimLength)
        else
            --newSound = Sound:new(actor, animationData.SoundTop, animationData.AnimLength)
        end
    end

    -- Ext.Net.BroadcastMessage("BG3SX_AnimationChange", Ext.Json.Stringify(newAnimation)) -- SE EVENT
    -- Ext.Net.BroadcastMessage("BG3SX_SoundChange", Ext.Json.Stringify(newSound)) -- SE EVENT
    Event:new("BG3SX_AnimationChange", newAnimation) -- MOD EVENT
    Event:new("BG3SX_SoundChange", newSound) -- MOD EVENT

    _P("[BG3SX][Sex.lua] Sex:PlayAnimation - playAnimationAndSound - Scene animation and sound change for actor: ", actor, " for animation table:")
    _D(animationData)
end


-- Determines which type of scene the entity is part of and assigns the appropriate animations and sounds to the actors involved
---@param entity         Entity  - The entity which used a new animation spell
---@param animationData  table   - The chosen animations data table
function Sex:PlayAnimation(entity, animationData)
    local scene = Scene:FindSceneByEntity(entity)
    local sceneType = Sex:DetermineSceneType(scene)
    scene.currentAnimation = animationData -- Saves the newly selected animationData table to the scene
    
    _P("[BG3SX][Sex.lua] - Sex:PlayAnimation - determines Scene to be of sceneType ", sceneType)
    if sceneType == "MasturbateFemale" or sceneType == "MasturbateMale" then
        playAnimationAndSound(scene.actors[1], animationData, "Bottom")
    elseif sceneType == "Lesbian" or sceneType == "Gay" then
       -- _D(scene.actors)
        playAnimationAndSound(scene.actors[1], animationData, "Top")
        playAnimationAndSound(scene.actors[2], animationData, "Bottom")
    elseif sceneType == "Straight" then
        local actor1 = scene.actors[1]
        local actor2 = scene.actors[2]
        -- In case of actor1 not being male, swap them around to still assign correct animations
        if not Entity:HasPenis(scene.actors[1].parent) then
            --_P("[BG3SX][Sex.lua] - Sex:PlayAnimation - scene.actors before setup switch")
          --  _D(scene.actors)

            actor2 = actor1
            actor2 = scene.actors[1]
            
            --_P("[BG3SX][Sex.lua] - Sex:PlayAnimation - scene.actors after setup switch")
            --_D(scene.actors)
        end
        playAnimationAndSound(actor1, animationData, "Top")
        playAnimationAndSound(actor2, animationData, "Bottom")
    elseif sceneType == "FFF" then

    elseif sceneType == "FFM" then

    elseif sceneType == "MMF" then

    elseif sceneType == "MMM" then

    end



    --for i=1,10000 do 
     --   _P("attempting masturbation for ",scene.actors[1].uuid)
     --   Osi.PlayAnimation(scene.actors[1].uuid, "fd91f2cc-e570-68dc-0473-2fae1ded6c0e") -- female masturbation
   -- end

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
        _P("----------------------------- [BG3SX][Sex.lua] - Sex:StartSexSpellUsed - Creating new scene -----------------------------")
        local sexHavers = {caster}

        for _,target in pairs(targets) do
            -- for masturbation caster == target
            if target ~= caster then
                table.insert(sexHavers, target)
                _P("ADDED " , target , " TO SEXHAVERS")
            end
        end

        scene = Scene:new(sexHavers)

        Sex:InitSexSpells(scene)
        Sex:PlayAnimation(caster, animationData)

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

    _P("[BG3SX][Sex.lua] - Sex:AddMainSexSpells executed for ", entity)
end


-- Adds additional sex spells for an entity
---@param entity    string  - The entity UUID to give additional spells to
local function addAdditionalSexOptions(entity)
    local scene = Scene:FindSceneByEntity(entity)
    local spellCount = 1
    for _,spell in pairs(ADDITIONALSEXOPTIONS) do
        -- If iteration lands on SwitchPlaces spell, check which scene type the entity is in and only add it if its not a solo one
        if spell == "BG3SX_SwitchPlaces" then
            local sceneType = Sex:DetermineSceneType(scene)
            if not sceneType == "MasturbateFemale" or not sceneType == "MasturbateMale" then
                _P("[BG3SX][Sex.lua] - addAdditionalSexOptions - Adding: ", spell, " for ", entity, " with delay of ", spellCount * 200)
                Ext.Timer.WaitFor(spellCount*200, function()
                    Osi.AddSpell(entity, spell)
                    _P("[BG3SX][Sex.lua] - addAdditionalSexOptions - ", spell, " for ", entity, " added")
                    spellCount = spellCount+1
                end)
            end
        else
            _P("[BG3SX][Sex.lua] - addAdditionalSexOptions - Adding: ", spell, " for ", entity, " with delay of ", spellCount * 200)
            Ext.Timer.WaitFor(spellCount*200, function()
                Osi.AddSpell(entity, spell)
                _P("[BG3SX][Sex.lua] - addAdditionalSexOptions - ", spell, " for ", entity, " added")
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

            addAdditionalSexOptions(entity)
        end
        _P("[BG3SX][Sex.lua] - Sex:InitSexSpells executed for ", entity)
    end
end


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

    -- Ext.Net.BroadcastMessage("BG3SX_CameraHeightChange", Ext.Json.Stringify(entity)) -- SE MOD
    Event:new("BG3SX_CameraHeightChange", entity) -- MOD EVENT

    _P("[BG3SX][Sex.lua] - Sex:ChangeCameraHeight for ", entity)
    
end

