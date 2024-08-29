----------------------------------------------------------------------------------------
--
--                               For handling Scenes
--
----------------------------------------------------------------------------------------

Data.SavedScenes = {}

local initialize

-- CONSTRUCTOR
--------------------------------------------------------------

-- Todo: Check if it requires cleanup of unused parameters
---@param entities          table   - Table with entity uuids to use for a scene
---@param rootPosition      table   - Table of x,y,z coordinates
---@param rotation          table   - Table with x,y,z,w 
---@param startLocations    table   - Saves the start locations (Position/Rotation) of each entity to teleport back to when scene is destroyed
---@param entityScales      table   - Saves the start entity scales
---@param actors            table   - Table of all actors in a scene
---@param currentAnimation  table   - Table of the current animation being played
---@param currentSounds     table   - Table of currently playing sounds
---@param timerHandles      table   - Timer handles in case they have to be cancelled (failsave)
---@param cameraZoom        table   - Unused - Was intended to store previous zoom levels per entity - handled differently now
---@param props             table   - Table of all props currently in a scene
---@param switchPlaces      boolean - Boolean for PlayAnimation to check if actors have been switched - TODO: need a cleaner way to handle this
---@param campFlags         table   - Table of entities with campflags applied before scene to reapply on Destroy() - Ignore those who didn't - PleaseStay Mod compatibility
---@paran summons           table   - Table of summons saved per involved entity
function Scene:new(entities)
    local instance      = setmetatable({
        entities        = entities,
        rootPosition    = {},
        rotation        = {},
        startLocations  = {}, -- NEVER change this after initialize - Used to teleport everyone back on Scene:Destroy()
        entityScales    = {},
        actors          = {},
        currentAnimation= {},
        currentSounds   = {},
        timerHandles    = {},
        cameraZoom      = {},
        props           = {},
        campFlags       = {},
        summons         = {},
    }, Scene)

    -- Somehow can't set rootPosition/rotation within the metatable construction, it poops itself trying to do this - rootPosition.x, rootPosition.y, rootPosition.z = Osi.GetPosition(entities[1])
    instance.rootPosition.x, instance.rootPosition.y, instance.rootPosition.z = Osi.GetPosition(entities[1])
    instance.rotation.x, instance.rotation.y, instance.rotation.z = Osi.GetRotation(entities[1])

    initialize(instance)

    return instance
end


----------------------------------------------------------------------------------------------------
-- 
-- 									    Getters and Setters
-- 
----------------------------------------------------------------------------------------------------

-- Sets an entities start location before possibly getting teleported during a scene for an easy reset on Scene:Destroy() with getStartLocation
---@param entity string - UUID of the entity 
local function setStartLocations(scene)
    for _,entity in pairs(scene.entities) do
        local position = {}
        position.x, position.y, position.z = Osi.GetPosition(entity)
        local rotationHelper = Entity:SaveEntityRotation(entity)

        table.insert(scene.startLocations, {entity = entity, position = position, rotationHelper = rotationHelper})
    end
end


-- TODO: Actually use it - we currently just call the table manually every time
-- Gets an entities start location for a location reset of an entity on Scene:Destroy()
---@param entity    string  - UUID of the entity 
---@return          table   - The entities position
---@return          table   - The entities rotation
local function getStartLocation(scene, entity)
    for _, entry in pairs(scene.startLocations) do
        if entry.entity == entity then
            return entry.position, entry.rotationHelper
        end
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Helper Functions
-- 
----------------------------------------------------------------------------------------------------

-- Goes through every currently running scene until it finds the entityToSearch
---@param entityToSearch uuid
function Scene:FindSceneByEntity(entityToSearch)
    for i, scene in ipairs(Data.SavedScenes) do
        for _, entity in pairs(scene.entities) do
            if entityToSearch == entity then
                return scene
            end
        end
    end
    -- _P("[BG3SX][Scene.lua] - Scene:FindSceneByEntity - Entity not found in any existing scenes! This shouldn't happen anymore. Contact mod author about what you did.")
end


-- Campflag Management
-----------------------------------------------------

local function saveCampFlags(self)
    for _,entity in pairs(self.entities) do
        if Osi.GetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity) == 1 then
            table.insert(self.campFlags, entity)
        end
    end
end
function Scene:ToggleCampFlags(entity)
    for _,flagEntity in pairs(self.campFlags) do
        if entity == flagEntity then
            Entity:ToggleCampFlag(entity)
        end
    end
end


-- SceneTimer Management - Currently only SoundTimer
-----------------------------------------------------

function Scene:RegisterNewSoundTimer(newSoundTimer)
    table.insert(self.timerHandles, newSoundTimer)
end
function Scene:CancelAllSoundTimers()
    for i = #self.timerHandles, 1, -1 do
        local handle = self.timerHandles[i]
        table.remove(self.timerHandles, i)
        Ext.Timer.Cancel(handle)
    end
    if #self.timerHandles > 0 then
        _P("[BG3SX][Scene.lua] - Scene:CancelAllSoundTimers() - This shouldn't happen anymore, please contact mod author about timerHandles being buggy again")
    end
end


-- Summons/Follower Management
-----------------------------------------------------

-- TODO: See if we can squish it a bit
-- Toggles visibility of all summons of entities involved in a scene
function Scene:ToggleSummonVisibility()
    if #self.summons > 0 then
        -- _P("Setting summon entries visible")
        for _,entry in pairs(self.summons) do
            local entity = entry.entity
            local summon = entry.summon
            local startLocation
            for _,locationEntry in pairs(self.startLocations) do
                -- _D(self.startLocations)
                -- _P(locationEntry.entity)
                -- _P(entity.Uuid.EntityUuid)
                local locationEntity = Ext.Entity.Get(locationEntry.entity)

                if locationEntity.Uuid.EntityUuid == entity.Uuid.EntityUuid then
                    -- _P("iteration entity == entity")
                    startLocation = locationEntry
                    -- _D(startLocation)
                end
            end
            Osi.SetDetached(summon.Uuid.EntityUuid, 0)
            Osi.SetVisible(summon.Uuid.EntityUuid, 1)
            Entity:ToggleWalkThrough(summon.Uuid.EntityUuid)
            Osi.RemoveBoosts(summon.Uuid.EntityUuid, "ActionResourceBlock(Movement)", 0, "", "")
            Osi.TeleportToPosition(summon.Uuid.EntityUuid, startLocation.position.x, startLocation.position.y, startLocation.position.z, "", 0, 0, 0, 0, 1)
        end
        self.summons = {}
    else
        -- _P("Setting summons invisible and adding them to scene.summons")
        local partymembers = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
        for _,entry in pairs(self.entities) do
            local entity = Ext.Entity.Get(entry)
            for _,potentialSummon in pairs(partymembers) do
                if potentialSummon.IsSummon then
                    local summon = potentialSummon
                    local summoner = summon.IsSummon.field_20 -- or field_8 - of of them might be owner and the other one the summoner
                    -- _P("Entity: ", entity, " with uuid: ", entity.Uuid.EntityUuid)
                    -- _P("Summon: ", summon, " with uuid: ", summon.Uuid.EntityUuid)
                    -- _P("Summoner: ", summoner, " with uuid: ", summoner.Uuid.EntityUuid)
                    if summoner.Uuid.EntityUuid == entity.Uuid.EntityUuid then
                        -- _P("Making ", summon.Uuid.EntityUuid, " invisible")
                        Osi.SetDetached(summon.Uuid.EntityUuid, 1)
                        Osi.SetVisible(summon.Uuid.EntityUuid, 0)
                        Entity:ToggleWalkThrough(summon.Uuid.EntityUuid)
                        Osi.AddBoosts(summon.Uuid.EntityUuid, "ActionResourceBlock(Movement)", "", "")
                        table.insert(self.summons, {entity = entity, summon = summon})
                    end
                end
            end
        end
    end
end

-- vvvvvv Keep this for whenever IsSummon is replicatable vvvvvv

-- Whenever we can replicate the owner fields we may be able to reuse this party and just replicate the IsSummon component after swapping out the owner
-- local partymembers = Osi.DB_Players:Get(nil)
-- local everyone = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
-- _P("-----------------------------------------------------")
-- _D(partymembers)

-- _P("---------------------------")
-- for _, entity in ipairs(everyone) do
--     if entity.IsSummon then
--         _P(entity.Uuid.EntityUuid)
--         _D(entity.IsSummon)
--         _P(entity.IsSummon.Owner_M)
--         local owner = entity.IsSummon.Owner_M
--         _P("owner_m: ", owner.Uuid.EntityUuid)
--         local field20 = entity.IsSummon.field_20
--         _P("field_20: ", field20.Uuid.EntityUuid)
--         local field8 = entity.IsSummon.field_8
--         _P("field_8: ", field8.Uuid.EntityUuid)

--         local newOwner = Ext.Entity.Get(partymembers[1][1])
--         _P("newOwner: ", newOwner.Uuid.EntityUuid)

--         entity.IsSummon.field_20 = newOwner
--         _P("field_20: ", field20.Uuid.EntityUuid)
--         entity:Replicate("IsSummon")
--         _P("field_20: ", field20.Uuid.EntityUuid)
--         Osi.SetVisible(entity.Uuid.EntityUuid, 0)
--     end
-- end
-- _P("-----------------------------------------------------")

-- ^^^^^^ Keep this for whenever IsSummon is replicatable ^^^^^^


-- Prop Management
-----------------------------------------------------
function Scene:CreateProps()
    if self.currentAnimation.Props then
        for _,animDataProp in pairs(self.currentAnimation.Props) do
            local sceneProp = Osi.CreateAt(animDataProp, self.rootPosition.x, self.rootPosition.y, self.rootPosition.z, 1, 0, "")
            Osi.SetMovable(sceneProp,0)
            table.insert(self.props, sceneProp)
        end
    end
end
function Scene:DestroyProps()
    if #self.props > 0 then
        -- _D(self.props)
        for i,sceneProp in ipairs(self.props) do
            -- _D(sceneProp)
            Osi.RequestDelete(sceneProp) -- Check if we need Osi.RequestDeleteTemporary
            table.remove(self.props, i)
            -- _D(self.props)
        end
    end
end
-- Scale Management
-----------------------------------------------------

-- Scale entity for camera
---@param entity uuid
function Scene:ScaleEntity(entity)
    local startScale = Entity:TryGetEntityValue(entity, nil, {"GameObjectVisual", "Scale"})
    table.insert(self.entityScales, {entity = entity, scale = startScale})
    Entity:Scale(entity, 0.5)
end

----------------------------------------------------------------------------------------------------
-- 
-- 									 Scene initilization
-- 
----------------------------------------------------------------------------------------------------

-- Initializes the actor
---@param self instance - The scene instance
initialize = function(self)
    table.insert(Data.SavedScenes, self)
    Ext.ModEvents.BG3SX.SceneInit:Throw(self)

    setStartLocations(self) -- Save start location of each entity to later teleport them back
    saveCampFlags(self) -- Saves which entities had campflags applied before
    self:ToggleSummonVisibility() -- Toggles summon visibility and collision - on Scene:Destroy() it also teleports them back to start location

    -- We do this before in a seperate loop to already apply this to all entities before actors are spawned one by one
    for _, entity in pairs(self.entities) do
        Osi.AddBoosts(entity, "ActionResourceBlock(Movement)", "", "") -- Blocks movement
        Osi.SetDetached(entity, 1)              -- Make entity untargetable
        Osi.DetachFromPartyGroup(entity)        -- Detach from party to stop party members from following
        --self:DetachSummons(entity) -- TODO: Add something to handle summon/follower movement here
        Osi.SetVisible(entity, 0)               -- 0 = Invisible
        Entity:ToggleWalkThrough(entity)        -- To prevent interactions with other entities even while invisible and untargetable
        self:ToggleCampFlags(entity)            -- Toggles camp flags so companions don't return to tents
        Sex:RemoveMainSexSpells(entity)         -- Removes the regular sex spells
    end

    for _, entity in pairs(self.entities) do
        table.insert(self.actors, Actor:new(entity))
        self:ScaleEntity(entity) -- After creating the actor to not create one with a smaller scale
    end

    for _, actor in ipairs(self.actors) do
        local startLocation = self.startLocations[1]
        -- Osi.TeleportToPosition(actor.uuid, startLocation.position.x, startLocation.position.y, startLocation.position.z) -- now handled correctly in actor initialization
        Entity:RotateEntity(actor.uuid, startLocation.rotationHelper)
    end

    Ext.ModEvents.BG3SX.SceneCreated:Throw(self)
end


----------------------------------------------------------------------------------------------------
-- 
-- 										During Scene
-- 
----------------------------------------------------------------------------------------------------

-- Teleports any entity/actor/props to a new location
---@param entity        uuid    - The caster of the spell and entity to check which scene belongs to them
---@param newLocation   table   - The new location
function Scene:MoveSceneToLocation(entity, newLocation)
    local scene = Scene:FindSceneByEntity(entity)
    local oldLocation = scene.rootPosition -- Only used for Event payload
    scene.rootPosition = newLocation -- Always update rootPosition of a scene after changing it

    for _, actor in ipairs(scene.actors) do

        -- Keep this in case we want to re-enable a maximum allowed distance to teleport
        ---------------------------------------------------------------------------------------
        -- Do nothing if the new location is too far from the caster's start position,
        -- so players would not abuse it to get to some "no no" places.
        -- local dx = newLocation.x - actor.position.x -- get the difference per axis
        -- local dy = newLocation.y - actor.position.y
        -- local dz = newLocation.z - actor.position.z
        -- if math.sqrt(dx * dx + dy * dy + dz * dz) >= 4 then -- if difference is greater than 4 units
        --     return
        -- end
        ---------------------------------------------------------------------------------------

        Osi.TeleportToPosition(actor.uuid, newLocation.x, newLocation.y, newLocation.z)
        Osi.TeleportToPosition(actor.parent, newLocation.x, newLocation.y, newLocation.z)
        if #scene.props > 0 then
            for _, prop in pairs(scene.props) do
                Osi.TeleportToPosition(prop, newLocation.x, newLocation.y, newLocation.z)
            end
        end
    end

    scene:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
    Sex:PlayAnimation(entity, scene.currentAnimation) -- Play prior animation again

    Ext.ModEvents.BG3SX.SceneMove:Throw({scene, oldLocation, newLocation})
end


-- Rotates a scene by creating an invisible helper the actors can steer to
---@param caster any
---@param location any
function Scene:RotateScene(caster, location)
    local scene = Scene:FindSceneByEntity(caster)
    local helper = Osi.CreateAt("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", location.x, location.y, location.z, 0, 0, "")
    for _, actor in pairs(scene.actors) do
        Entity:ClearActionQueue(actor.uuid) -- Clears any stuff the actor might be stuck on
        Osi.SteerTo(actor.uuid, helper, 1) -- 1 = instant
    end
    Osi.RequestDeleteTemporary(helper) -- Deletes the rotationHelper after rotating

    scene:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
    Sex:PlayAnimation(caster, scene.currentAnimation) -- Play prior animation again
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Stop
-- 
----------------------------------------------------------------------------------------------------

-- Handles the generic stuff to reset on an entity on Scene:Destroy()
local function sceneEntityReset(entity)
    local scene = Scene:FindSceneByEntity(entity)
    local startLocation
    local startScale

    -- Getting old position and scale
    for i, entry in ipairs(scene.startLocations) do
        if entry.entity == entity then
            startLocation = entry
        end
    end
    for _, entry in pairs(scene.entityScales) do
        if entity == entry.entity then
            startScale = entry.scale
        end
    end

    Osi.TeleportToPosition(entity, startLocation.position.x, startLocation.position.y, startLocation.position.z, "", 0, 0, 0, 0, 1)
    Entity:RotateEntity(entity, startLocation.rotationHelper) -- Rotate the entity back to what it was looking at prior to the scene
    Entity:Scale(entity, startScale) -- Sets the entity scale back to its original
    Osi.RemoveBoosts(entity, "ActionResourceBlock(Movement)", 0, "", "") -- Unlocks movement

    scene:ToggleCampFlags(entity) -- Toggles camp flags so companions return to tents IF they had them before
    
    -- Re-attach entity to make it selectable again
    Osi.SetDetached(entity, 0)
    Osi.SetVisible(entity, 1)
end


-- Destroys a scene instance
function Scene:Destroy()
    for _, entity in pairs(self.entities) do -- Go over this seperately so it already is applied to every entity before the other stuff happens
        -- Effect:Fade(entity, 2000) -- 2sec Fadeout on scene termination
    end

    self:CancelAllSoundTimers()
    self:DestroyProps()
    self:ToggleSummonVisibility()

    for _, actor in pairs(self.actors) do
        actor:Destroy()
    end

    for _, entity in pairs(self.entities) do
        sceneEntityReset(entity)
        
        Osi.PlaySound(entity, Data.Sounds.Orgasm[math.random(1, #Data.Sounds.Orgasm)]) -- TODO - change this to a generic sound for when we use this for non-sex instead

        Sex:RemoveSexSceneSpells(entity) -- Removes any spells given for the scene
        if Osi.IsPartyMember(entity, 0) == 1 then
            Sex:AddMainSexSpells(entity) -- Readds the regular sex spells (StartSex, Options, ChangeGenitals)
        end
    end
    
    Ext.ModEvents.BG3SX.SceneDestroyed:Throw(self)

    for i,scene in ipairs(Data.SavedScenes) do
        if scene == self then
            table.remove(Data.SavedScenes, i)
        end
    end
end