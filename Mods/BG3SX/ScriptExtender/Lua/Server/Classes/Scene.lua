----------------------------------------------------------------------------------------
--
--                               For handling Scenes
--
----------------------------------------------------------------------------------------

SAVEDSCENES = {}
Scene = {}
Scene.__index = Scene
local initialize

-- CONSTRUCTOR
--------------------------------------------------------------

---@param entities          table   - Table with Entitie uuids to use for a scene
---@param rootposition      table   - Table of x,y,z coordinates
---@param rotation          table   - Table with x,y,z,w 
---@param actors            table   - Table of all actors in a scene
---@param props             table   - Table of all props currently in a scene
---@param entityScales      table   - Saves the start entity scales
---@param startLocations    table   - Saves the start Locations (Position/Rotation) of each entity to teleport back to when scene is destroyed
---@param timerHandles      table   - Timer handles in case they have to be cancelled (failsave)
function Scene:new(entities)
    local instance      = setmetatable({
        entities        = entities,
        rootposition    = Osi.GetPosition(entities[1]),
        rotation        = Osi.GetRotation(entities[1]),
        actors          = {},
        props           = {},
        entityScales    = {},
        startLocations  = {}, -- Never changes to teleport back later
        timerHandles    = {},
    }, Scene)

    initialize(self) -- Automatically calls the Iinitialize function on creation
    

    return instance
end


-- CONSTANTS
--------------------------------------------------------------

local FLAG_COMPANION_IN_CAMP = "161b7223-039d-4ebe-986f-1dcd9a66733f"
local BODY_SCALE_DELAY = 2000


-- METHODS
--------------------------------------------------------------



----------------------------------------------------------------------------------------------------
-- 
-- 									    Getters and Setters
-- 
----------------------------------------------------------------------------------------------------


-- Sets an entities start location before possibly getting teleported during a scene for an easy reset on Scene:Destroy() with getStartLocation
---@param entity string - UUID of the entity 
local function setStartLocation(entity)
    local position = Osi.GetPosition(entity)
    local rotationHelper = Entity:SaveEntityRotation(uuid)

    table.insert(startLocations, {entity = entity, position = position, rotationHelper = rotation})
end

-- Gets an entities start location for a location reset of an entity on Scene:Destroy()
---@param entity    string  - UUID of the entity 
---@return          table   - The entities position
---@return          table   - The entities rotation
local function getStartLocation(entity)
    for _, entry in pairs(startLocations) do
        if entry.entity == entity then
            return entry.position, entry.rotationHelper
        end
    end
end


local function getEntityPosition(entity)
    for _, starotLoca in pairs(self.startLcations) do
        if entity == startLoca.entity then
            return startLoca.positon
        end
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Helper Functions
-- 
----------------------------------------------------------------------------------------------------


function Scene:StartAnimFade()
    Osi.ScreenFadeTo(actor, 0.1, 0.1, "AnimFade")
end


---@param entity uuid
function Scene:FindSceneByEntity(entityToSearch, savedScenes)
    for _, scene in pairs(savedScenes) do
        for _, entities in pairs(scene.entities) do
            for _, entity in pairs(entities) do
                if entityToSearch == entity then
                    return scene
                end
            end
        end
    else
        _P("[BG3SX][Scene.lua] - Scene:FindSceneByEntity - Entity not found in any scenes!")
        return nil
end


----------------------------------------------------------------------------------------------------
-- 
-- 										    Setup
-- 
----------------------------------------------------------------------------------------------------


-- Temporary teleport the original away a bit to give room for the proxy
---@param entity uuid
Scene:MakeSpace(entity)
  startPos = getEntityPosition(entity)
  Osi.TeleportToPosition(entity, startPos.x + 1.3, startPos.x.y, startPos.x.z + 1.3, "", 0, 0, 0, 0, 1)
end


-- Scale party members down so the camera would be closer to the action.
---@param entity uuid
Scene:SetCamera(entity)
   if Osi.IsPartyMember(entity, 0) == 1 then
    local curScale = Entity:TryGetEntityValue(entity, "GameObjectVisual", "Scale", nil, nil)
    if curScale then
        actorData.OldVisualScale = curScale
        entity.GameObjectVisual.Scale = 0.5
        entity:Replicate("GameObjectVisual")
    end
end

-- Scale entity for camera
---@param entity uuid
Scene:ScaleEntity(entity)
  local startScale = Entity:TryGetEntityValue(entity, {"GameObjectVisual", "Scale"})
  table.insert(self.entityScales, {entity = entity, scale = startScale})
  Entity:Scale(entity, 0.5)
end

-- After this is called, wait 400 ms
Scene:Setup()
    for _, entity in pairs(self.entities) do 
        Scene:MakeSpace(entity)
        Scene:SetCamera(entity)
        Scene:ScaleEntity(entity)
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 									 Object initilization
-- 
----------------------------------------------------------------------------------------------------


-- Initializes the actor
---@param self instance - "self" to actually be applied to the Actor:new instance
initialize = function(self)
    
    -- Iterate over every entity thats involved in a new scene
    for _, entity in pairs(self.entities) do

        setStartLocation(entity) -- Save start location of each entity to later teleport them back

        -- Create a new actor for each entity involved in the scene
        table.insert(self.actors, Actor:new(entity))  

        -- Make entity untargetable and detached from party to stop party members from following
        Osi.SetDetached(entity, 1)
        Osi.DetachFromPartyGroup(entity)

        -- Remove the main spells -- does nothing if they are already removed. We can just purge all animstart spells here
        Osi.RemoveSpell(entity, "BG3SX_MainContainer")
        Osi.RemoveSpell(entity, "BG3SX_ChangeGenitals")
        Osi.RemoveSpell(entity, "BG3SX_Options")

        -- Clear FLAG_COMPANION_IN_CAMP to prevent companions from teleporting to their tent while all this is happening
        if Osi.GetFlag(FLAG_COMPANION_IN_CAMP, entity) == 1 then
            Osi.ClearFlag(FLAG_COMPANION_IN_CAMP, entity)
        end

        -- Save the entities body heightclass for animation matching
        local entityBodyShape = Entity:GetBodyShape(entity)
        local entityHeightClass = Entity:GetHeightClass(entity)

        Scene:Setup(entity)

        Ext.WaitFor(400, function()
            Scene:FinalizeSetup())
        end
        
    end
end



----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Start
-- 
----------------------------------------------------------------------------------------------------


---@param actorData any
---@param proxyData any
function Scene:FinalizeSetup()

    for _, actor in pairs(self.actors) do

        -- Support for the looks brought by Resculpt spell from "Appearance Edit Enhanced" mod.
        if Entity:TryCopyEntityComponent(actor.parent, actor, "AppearanceOverride") then
            if actor.GameObjectVisual.Type ~= 2 then
                actor.GameObjectVisual.Type = 2
                actor:Replicate("GameObjectVisual")
            end
        end

        -- Copy actor's display name to proxy (mostly for Tavs)
        Entity:TryCopyEntityComponent(actor.parent, actor, "DisplayName")
        -- Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "CustomName")

        if #actor.equipment > 0 then
            actor:DressActor()
        end

        for _, startLocation in pairs(self.startLocations) do
            if actor.parent == startLocation.entity then
                Osi.TeleportToPosition(actor, startLocation.position.x, startLocation.position.y, startLocation.position.z, "", 0, 0, 0, 0, 1)
                Entity:RotateEntity(actor, startLocation.rotationHelper)
            end
        end

        Osi.SetVisible(actor.parent, 0)
        disableActorMovement(actor.parent)

    end

    table.insert(SAVEDSCENES, self)

end




----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Stop
-- 
----------------------------------------------------------------------------------------------------

-- Destroys a scene instance
function Scene:Destroy()
    if self.actors then
        -- Iterates over every saved actor for a given scene instance
        for _, actor in pairs(self.actors) do

            -- Teleport actors parent (the main entity) back to its startLocation
            local startLocation = getStartLocation(actor.parent)
            Osi.TeleportToPosition(actor.parent, startLocation.position.x, startLocation.position.y, startLocation.position.z)
            -- TODO: Osi.SteerTo(actor.parent, helper object which we need to create on scene creation,1)
            Osi.SetVisible(actor, 1)

            -- Requips everything which may have been removed during scene initialization
            if Entity:HasEquipment(actor.parent) then
                Entity:Redress(actor.parent)
            end

            -- Delete actor
            actor:Destroy()
        end
    end

    if self.entities then
        -- Iterates over every saved entity for a given scene instance
        for _, entity in pairs(self.entities) do
            -- Play recovery sound as substitue for orgasms
            Osi.PlaySound(entity, ORGASM_SOUNDS[math.random(1, #ORGASM_SOUNDS)])

            -- Unlocks movement
            Osi.RemoveBoosts(entity, "ActionResourceBlock(Movement)", 0, "", "")
    
            -- Sets scale back to a saved value during scene initialization
            local startScale
            for _, entry in self.entityScale do
                if entity == entry.entity then
                    startScale = entry.scale
                end
            end
            Entity:Scale(entity, startScale)

            
            -- Removes any spells given
            Sex:removeSexPositionSpells(entity)

            -- Readds the regular sex spells (StartSex, Options, ChangeGenitals)
            if Osi.IsPartyMember(entity) == 1 then
                Sex:AddMainSexSpells(entity)
            end

            -- Re-Sets the flag for companions in camp so they can move back to their tents
            if Ext.Entity.Get(entity).CampPresence ~= nil then
                Osi.SetFlag(FLAG_COMPANION_IN_CAMP, entity)
            end

            -- Re-attach entity to make it selectable again
            Osi.SetDetached(entity, 0)

            end
        end
    --Fire a timer to notify other mods that a scene has ended
    -- Sex:EndSexSceneTimer(actorData)
    -- Ext.Net.PostMessageToServer("BG3SX_EndSexScene","")

    -- Removes itself from SAVEDSCENES list
    for i,scene in ipairs(SAVEDSCENES) do
        if scene == self then
            table.remove(SAVEDSCENES, i)
        end
    end
end





----------------------------------------------------------------------------------------------------
-- 
-- 								  Main functions
-- 
----------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------
-- 
-- 								          Sex
-- 
----------------------------------------------------------------------------------------------------

--- func desc
---@param animProperties
function Scene:StartPairedScene(animProperties)
    -- Always create a proxy for targets if they are PCs or companions or some temporary party members. 
    -- It fixes the moan sounds for companions and prevents animation reset on these characters' selection in the party.
    --local targetNeedsProxy = (Entity:IsPlayable(target) or Osi.IsPartyMember(target, 1) == 1)

    -- local pairData = {
    --     Caster = caster,
    --     CasterData = SexActor_Init(caster, true, "SexVocalCaster", animProperties),
    --     Target = target,
    --     TargetData = SexActor_Init(target, true, "SexVocalTarget", animProperties), -- targetNeedsProxy
    --     AnimationActorHeights = "",
    --     AnimProperties = animProperties,
    --     SwitchPlaces = false,
    -- }

    local scaledEntites = {}

    for _, entity in self.entities do
        table.insert(scaledEntites, Entity:PurgeBodyScaleStatuses(entity))
    end

    -- local casterScaled = Entity:PurgeBodyScaleStatuses(pairData.CasterData)
    -- local targetScaled = Entity:PurgeBodyScaleStatuses(pairData.TargetData)

    Sex:UpdateAvailableAnimations(entities)

    AnimationPairs[#AnimationPairs + 1] = pairData -- TODO Check what this does

    local setupDelay = 2000

    for _, entity in self.entities do
        if Osi.HasActiveStatus(entity, "BG3SX_BlockStripping") == 0 then
            Effect:Trigger(entity, "DARK_JUSTICIAR_VFX")
            Ext.Timer.WaitFor(600, function() Sex:PairedSexStrip(self, entity) end)
        end
    end



    if (#scaledEntites > 0) and setupDelay < BODY_SCALE_DELAY then
        setupDelay = BODY_SCALE_DELAY -- Give some time for the bodies to go back to their normal scale
    end
    
    if pairData.AnimProperties["Fade"] == true then
        local startHandle = Ext.Timer.WaitFor(setupDelay - 200, function() Scene:StartAnimFade() end)
        --Osi.ObjectTimerLaunch(caster, "PairedSexFade.Start", setupDelay - 200)
        local endHandle = Ext.Timer.WaitFor(setupDelay + 800, function() Scene:StartAnimFade() end)
        --Osi.ObjectTimerLaunch(caster, "PairedSexFade.End", setupDelay + 800)
        --Osi.ObjectTimerLaunch(target, "PairedSexFade.Start", setupDelay - 200)
        --Osi.ObjectTimerLaunch(target, "PairedSexFade.End", setupDelay + 800)
        table.insert(self.timerHandles, startHandle)
        table.insert(self.timerHandles, endHandle)
    end

    --Osi.ObjectTimerLaunch(caster, "PairedSexSetup", setupDelay)
    Ext.Timer.WaitFor(setupDelay, function() Scene:PairedSexSetup() end)

    -- Add sex control spells to everyone
    Sex:InitSexSpells(self)
end



--- func desc
---@param entity any
---@param location any
function Scene:MoveSceneToLocation(entity, location)
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



--- func desc
---@param actor any
---@param x any
---@param y any
---@param z any
function Scene:MovePairedSceneToLocation(actor, x, y, z)
    local pairIndex = FindPairIndexByActor(actor)
    if pairIndex < 1 then
        return
    end
    local pairData = AnimationPairs[pairIndex]

    Scene:MoveSceneToLocation(x, y, z, pairData.CasterData, pairData.TargetData)
end



---@param pairData any
function Scene:StopPairedAnimation()
    for _, handle in self.timerHandles do
        Ext.Timer.Cancel(handle)
    end
    --Osi.ObjectTimerCancel(pairData.Caster, "PairedSexFade.Start")
    --Osi.ObjectTimerCancel(pairData.Caster, "PairedSexFade.End")
    --Osi.ObjectTimerCancel(pairData.Target, "PairedSexFade.Start")
    --Osi.ObjectTimerCancel(pairData.Target, "PairedSexFade.End")

    Osi.ScreenFadeTo(pairData.Caster, 0.1, 0.1, "AnimFade")
    Osi.ScreenFadeTo(pairData.Target, 0.1, 0.1, "AnimFade")

    Ext.Timer.WaitFor(200, function() Sex:FinishSex(scene))
    --Osi.ObjectTimerLaunch(pairData.Caster, "FinishSex", 200)
    Ext.Timer.WaitFor(2500, function() Sex:PairedSexFadeEnd(self.entities) end)
    --Osi.ObjectTimerLaunch(pairData.Caster, "PairedSexFade.End", 2500)
    --Osi.ObjectTimerLaunch(pairData.Target, "PairedSexFade.End", 2500)

    for _, entity in self.entities do
        Sex:StopVocals(entity)
    end
end