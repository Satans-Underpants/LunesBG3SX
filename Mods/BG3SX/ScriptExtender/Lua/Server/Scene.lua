----------------------------------------------------------------------------------------
--
--                               For handling Scenes
--
----------------------------------------------------------------------------------------

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
function Scene:new(entities)
    local instance      = setmetatable({
        entities        = entities,
        rootposition    = Osi.GetPosition(entities[1]),
        rotation        = Osi.GetRotation(entities[1]),
        actors          = {},
        props           = {},
        entityScales    = {},
        startLocations  = {} -- Never changes to teleport back later
    }, Scene)

    initialize(self) -- Automatically calls the Itinitialize function on creation

    return instance
end

-- CONSTANTS
--------------------------------------------------------------

local FLAG_COMPANION_IN_CAMP = "161b7223-039d-4ebe-986f-1dcd9a66733f"
local BODY_SCALE_DELAY = 2000


-- METHODS
--------------------------------------------------------------



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
    Osi.RemoveSpell(entity, "zzzEndSex")
    Osi.RemoveSpell(entity, "zzzStopMasturbating")
    Osi.RemoveSpell(entity, "CameraHeight")
    Osi.RemoveSpell(entity, "ChangeLocationPaired")
    Osi.RemoveSpell(entity, "ChangeLocationSolo")
    Osi.RemoveSpell(entity, "zzSwitchPlaces")
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Start
-- 
----------------------------------------------------------------------------------------------------


-- Sets an entities start location before possibly getting teleported during a scene for an easy reset on Scene:Destroy() with getStartLocation
---@param entity string - uuid of the entity 
local function setStartLocation(entity)
    local position = Osi.GetPosition(entity)
    local rotation = Osi.GetRotation(entity)
    table.insert(startLocations, {entity = entity, position = position, rotation = rotation})
end


-- Gets an entities start location for a location reset of an entity on Scene:Destroy()
---@param entity string - uuid of the entity 
local function getStartLocation(entity)
    for _, entry in startLocations do
        if entry.entity == entity then
            return entry.position, entry.rotation
        end
    end
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
            Osi.TeleportToPosition(actor.parent, startLocation.position.x, startLocation.position.y, startLocation.position.y)
            Osi.SetVisible(actor, 1)

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
            SexActor_StopVocalTimer(actorData)

            -- Sets scale back to a saved value during scene initialization
            local startScale
            for _, entry in self.entityScale do
                if entity == entry.entity then
                    startScale = entry.scale
                end
            end
            Entity:Scale(entity, startScale)

            -- Requips everything which may have been removed during scene initialization
            if Entity:HasEquipment(actorData) then
                Entity:Redress(actorData)
            end

            -- Removes any spells given
            removeSexPositionSpells(entity)

            -- Readds the regular sex spells (StartSex, Options, ChangeGenitals)
            if Osi.IsPartyMember(entity) == 1 then
                Spells:AddMainSexSpells(entity)
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
    -- SexEvent_EndSexScene(actorData)
    -- Ext.Net.PostMessageToServer("BG3SX_EndSexScene","")
end



-- copies the components of a parent entity to the proxy
-- the proxy is the entity used in sex
function Scene:SubstituteProxy(actorData, proxyData)
    actorData.StartX, actorData.StartY, actorData.StartZ = Osi.GetPosition(actorData.Actor)

    if not actorData.NeedsProxy then
        return
    end

    -- Temporary teleport the original away a bit to give room for the proxy
    Osi.TeleportToPosition(actorData.Actor, actorData.StartX + 1.3, actorData.StartY, actorData.StartZ + 1.3, "", 0, 0, 0, 0, 1)

    local actorEntity = Ext.Entity.Get(actorData.Actor)

    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    local visTemplate = Entity:TryGetEntityValue(actorEntity, "GameObjectVisual", "RootTemplateId", nil, nil)
    local origTemplate = Entity:TryGetEntityValue(actorEntity, "OriginalTemplate", "OriginalTemplate",nil ,nil)

    actorData.Proxy = Osi.CreateAtObject(Osi.GetTemplate(actorData.Actor), proxyData.Marker, 1, 0, "", 1)

    -- Copy the actor's looks to the proxy (does not copy transforms)
    local lookTemplate = actorData.Actor
    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    if visTemplate then
        if origTemplate then
            if origTemplate ~= visTemplate then
                lookTemplate = visTemplate
            end
        elseif origTemplate == nil then -- It's Tav?
            -- For Tavs, copy the look of visTemplate only if they are polymorphed or have AppearanceOverride component (under effect of "Appearance Edit Enhanced" mod)
            if Osi.HasAppliedStatusOfType(actorData.Actor, "POLYMORPHED") == 1 or actorEntity.AppearanceOverride then
                lookTemplate = visTemplate
            end
        end
    end

    --[[ Osi.Transform(actorData.Proxy, lookTemplate, "296bcfb3-9dab-4a93-8ab1-f1c53c6674c9")

    Osi.SetDetached(actorData.Proxy, 1)
    BlockActorMovement(actorData.Proxy)
 ]]
    local proxyEntity = Ext.Entity.Get(actorData.Proxy)

    -- Copy Voice component to the proxy because Osi.CreateAtObject does not do this and we want the proxy to play vocals
  --[[   Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "Voice")

    -- Copy MaterialParameterOverride component if present.
    -- This fixes the white Shadowheart going back to her original black hair as a proxy.
    Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "MaterialParameterOverride") ]]

    -- Copy actor's equipment to the proxy (it will be equipped later in SexActor_FinalizeSetup)
    if not Entity:HasEquipment(actorData) then
        Actor:CopyEquipmentFromParent(actorData)
    end

    -- Scale party members down so the camera would be closer to the action.
    if actorData.CameraScaleDown then
        local curScale = Entity:TryGetEntityValue(actorEntity, "GameObjectVisual", "Scale", nil, nil)
        if curScale then
            actorData.OldVisualScale = curScale
            actorEntity.GameObjectVisual.Scale = 0.5
            actorEntity:Replicate("GameObjectVisual")
        end
    end
   -- Osi.ApplyStatus(actorData.Proxy, "SEX_ACTOR", -1)
end



function SexActor_FinalizeSetup(actorData, proxyData)
    if actorData.Proxy then
        local actorEntity = Ext.Entity.Get(actorData.Actor)
        local proxyEntity = Ext.Entity.Get(actorData.Proxy)

        -- Support for the looks brought by Resculpt spell from "Appearance Edit Enhanced" mod.
        if Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "AppearanceOverride") then
            if proxyEntity.GameObjectVisual.Type ~= 2 then
                proxyEntity.GameObjectVisual.Type = 2
                proxyEntity:Replicate("GameObjectVisual")
            end
        end

        -- Copy actor's display name to proxy (mostly for Tavs)
        Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "DisplayName")
        -- Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "CustomName")

        if actorData.CopiedEquipment then
            Actor:DressActor(actorData)
        end

        Osi.TeleportToPosition(actorData.Actor, proxyData.MarkerX, proxyData.MarkerY, proxyData.MarkerZ, "", 0, 0, 0, 0, 1)
        Osi.SetVisible(actorData.Actor, 0)
    end

    BlockActorMovement(actorData.Actor)
end




-- TODO: Move the function to a separate SexScene.lua or something
function Scene:InitSexSpells()
    -- give the entities the correct spells based on amount of entities in the scene
    -- currently only masturbation and 2 people is supported
    -- also add spells that everyone gets like end sex

    -- self.entities for loop to give each entity spells

    sceneData.CasterSexSpells = {}
    sceneData.NextCasterSexSpell = 1
end

-- TODO: Move the function to a separate SexScene.lua or something
function SexActor_RegisterCasterSexSpell(sceneData, spellName)
    sceneData.CasterSexSpells[#sceneData.CasterSexSpells + 1] = spellName
end

-- TODO: Move the function to a separate SexScene.lua or something
function SexActor_AddCasterSexSpell(sceneData, casterData, timerName)
    if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
        Osi.AddSpell(casterData.Actor, sceneData.CasterSexSpells[sceneData.NextCasterSexSpell])

        sceneData.NextCasterSexSpell = sceneData.NextCasterSexSpell + 1
        if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
            -- A pause greater than 0.1 sec between two (Try)AddSpell calls in needed 
            -- for the spells to appear in the hotbar exactly in the order they are added.
            Osi.ObjectTimerLaunch(casterData.Actor, timerName, 200)
        end
    end
end



----------------------------------------------------------------------------------------------------
-- 
-- 								  Main functions
-- 
----------------------------------------------------------------------------------------------------




-- Initializes the actor
---@param self instance - "self" to actually be applied to the Actor:new instance
initialize = function(self)
    for _, entity in pairs(self.entities) do

        setStartLocation(entity)
        removeSexPositionSpells(entity)

        -- Create a new actor for each entity involved in the scene
        table.insert(self.actors, actorActor:new(entity))

        -- Scale entity for camera
        -- TODO - rewrite TryGetEntityValue to take a table instead of multiple strings
        local startScale = Entity:TryGetEntityValue(entity, "GameObjectVisual", "Scale", nil, nil)
        table.insert(self.entityScales, {entity = entity, scale = startScale})
        Entity:Scale(self.entity, 0.5)

        
        

        -- Make entity untargetable and detached from party to stop party members from following
        Osi.SetDetached(entity, 1)
        Osi.DetachFromPartyGroup(entity)

        -- Remove the main spells
        Osi.RemoveSpell(entity, "StartSexContainer")
        Osi.RemoveSpell(entity, "Change_Genitals")
        Osi.RemoveSpell(entity, "BG3SXOptions")
        removeSexPositionSpells(entity) -- Just in case

        -- Clear FLAG_COMPANION_IN_CAMP to prevent companions from teleporting to their tent while all this is happening
        if Osi.GetFlag(FLAG_COMPANION_IN_CAMP, entity) == 1 then
            Osi.ClearFlag(FLAG_COMPANION_IN_CAMP, entity)
        end



        local entityBodyShape = Entity:GetBodyShape(entity)
        local entityHeightClass = Entity:GetHeightClass(entity)
        
        -- probably need a delay for setup
        Sex:StartSex(entityHeightClass)
    end
end