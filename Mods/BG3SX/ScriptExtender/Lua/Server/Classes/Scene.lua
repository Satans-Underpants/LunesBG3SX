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
        switchPlaces    = "false",
        campFlags       = {},
    }, Scene)

    -- Somehow can't set rootPosition/rotation within the instance, it poops itself trying to do this - rootPosition.x, rootPosition.y, rootPosition.z = Osi.GetPosition(entities[1])
    instance.rootPosition.x, instance.rootPosition.y, instance.rootPosition.z = Osi.GetPosition(entities[1])
    instance.rotation.x, instance.rotation.y, instance.rotation.z = Osi.GetRotation(entities[1])

    for _,entity in pairs(instance.entities) do
        -- Effect:Fade(entity, 2000) -- 2sec Fade duration on scene creation
    end

    -- Delay so user doesn't see setup during fadeout
    -- Ext.Timer.WaitFor(1000, function() initialize(instance)end)
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


local function getEntityPosition(scene, entity)
    for _, entry in pairs(scene.startLocations) do
        if entity == entry.entity then
            return entry.position
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
    for i, scene in ipairs(SAVEDSCENES) do
        for _, entity in pairs(scene.entities) do
            if entityToSearch == entity then
                return scene
            end
        end
    end
    _P("[BG3SX][Scene.lua] - Scene:FindSceneByEntity - Entity not found in any existing scenes! Returning nil")
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


-- SceneTimer Management
-----------------------------------------------------

function Scene:RegisterNewSoundTimer(newSoundTimer)
    table.insert(self.timerHandles, newSoundTimer)
end
function Scene:CancelAllSoundTimers()
    for _,handle in pairs(self.timerHandles) do
        table.remove(self.timerHandles, handle)
        Ext.Timer.Cancel(handle)
    end
end


-- Summons/Follower Management
-----------------------------------------------------
function Scene:DetachSummons()
    local summons = Helper:GetPlayerSummons()
    -- Maybe need to create an entity entry in self.summons here first
    for _,summon in pairs(summons) do
        -- table.insert(self.summons, summon) Save in new instance.table as new entries per summon per each entity
        Osi.AddBoosts(summon, "ActionResourceBlock(Movement)", "", "")
    end
end


function Scene:AttachAllSummons()
end


----------------------------------------------------------------------------------------------------
-- 
-- 										    Setup
-- 
----------------------------------------------------------------------------------------------------

-- Scale entity for camera
---@param entity uuid
function Scene:ScaleEntity(entity)
    local startScale = Entity:TryGetEntityValue(entity, nil, {"GameObjectVisual", "Scale"})
    table.insert(self.entityScales, {entity = entity, scale = startScale})
    Entity:Scale(entity, 0.5)
end

-- Disabled the remaining setup functions because we already iterate over every entity in a scene and currently only use Scene:ScaleEntity(entity)
--------------------------------------------

-- Temporary teleport the original away a bit to give room for the proxy
---@param entity uuid
function Scene:MakeSpace(entity)
     local startPos = getEntityPosition(self, entity)
     Osi.TeleportToPosition(entity, startPos.x + 1.3, startPos.y, startPos.z + 1.3, "", 0, 0, 0, 0, 1)
 end


-- Scale party members down so the camera would be closer to the action.
---@param uuid uuid
function Scene:SetCamera(uuid)  -- TODO: PREVIOUSZOOM NOT DECLARED - should be something like previous entity scale
    if Osi.IsPartyMember(uuid, 0) == 1 then
        local entity = Ext.Entity.Get(uuid)
        local zoom = Entity:TryGetEntityValue(entity, nil, {"GameObjectVisual", "Scale"})
        local previousZoom
        if zoom then
            table.insert(self.cameraZoom, {entity = entity, zoom = zoom, previousZoom = previousZoom})
            for _,entity in pairs(self.cameraZoom) do
                entity.GameObjectVisual.Scale = 0.5
                entity:Replicate("GameObjectVisual")
            end
        end
    end

    -- _P("[BG3SX][Scene.lua] - Scene:SetCamera - For ", entity)
end

-- After this is called, wait 400 ms
function Scene:Setup()
    for _, entity in pairs(self.entities) do
        -- self:MakeSpace(entity)
        -- self:SetCamera(entity)
        self:ScaleEntity(entity)
    end
    -- _P("[BG3SX][Scene.lua] - Scene:Setup() finished")
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Start
-- 
----------------------------------------------------------------------------------------------------


---@param self Scene
local function finalizeScene(self)
    for _, actor in pairs(self.actors) do

        -- Support for the looks brought by Resculpt spell from "Appearance Edit Enhanced" mod.
        -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - Entity:TryCopyEntityComponent - AppearanceOverride")
        if Entity:TryCopyEntityComponent(actor.parent, actor.uuid, "AppearanceOverride") then
            if actor.uuid.GameObjectVisual and actor.uuid.GameObjectVisual.Type ~= 2 then
                actor.uuid.GameObjectVisual.Type = 2
                actor:Replicate("GameObjectVisual")
            elseif not actor.uuid.GameObjectVisual then
                _P("[BG3SX][Scene.lua] Trying to create Actor for entity without GameObjectVisual Component.")
                _P("[BG3SX][Scene.lua] This can happen with some scenery NPC's.")
                _P("[BG3SX][Scene.lua] Safeguards have been put in place, nothing will break. Please end the Scene and choose another target.")
            end
        end


        -- Copy actor's display name to proxy (mostly for Tavs)
        -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - Entity:TryCopyEntityComponent - DisplayName")
        Entity:TryCopyEntityComponent(actor.parent, actor.uuid, "DisplayName")
        -- Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "CustomName")

        -- if #actor.equipment > 0 then
        --     _P("[BG3SX][Scene.lua] - finilizeScene(self) - actor:DressActor()")          -- Already used per Actor:new in its initialize function
        --     actor:DressActor()
        -- end

        -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - Teleport and rotate every actor to actor.parent startlocation")

        local startLocation = self.startLocations[1]

        --for _, startLocation in pairs(self.startLocations) do
            --_P("[BG3SX][Scene.lua] - finilizeScene(self) - iterating over startLocations ", startLocation)
           -- if actor.parent == startLocation.entity then
               -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - iterating over startLocations ", startLocation)

                Osi.TeleportToPosition(actor.uuid, startLocation.position.x, startLocation.position.y, startLocation.position.z)
                Entity:RotateEntity(actor.uuid, startLocation.rotationHelper)
           -- end
        --end

        -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - disableActorMovement for ", actor.parent)
        -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - disableActorMovement - IS CURRENTLY MISSING AS A FUNCTION")
        --disableActorMovement(actor.parent)
    end

    -- if #self.actors >1 then
    --     for i = 2, #self.actors do
    --         local actor = self.actors[i]
    --         local startLocation = self.startLocations[1]
    --         Osi.TeleportToPosition(actor.uuid, startLocation.position.x, startLocation.position.y, startLocation.position.z)
    --         Entity:RotateEntity(actor.uuid, startLocation.rotationHelper)
    --     end
    -- end

    -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - Scene Created:")
    -- table.insert(SAVEDSCENES, self)
    --_D(SAVEDSCENES)

    -- Ext.Net.BroadcastMessage("BG3SX_SceneCreated", Ext.Json.Stringify(self)) -- SE EVENT
    Event:new("BG3SX_SceneCreated", self) -- MOD EVENT

end

----------------------------------------------------------------------------------------------------
-- 
-- 									 Scene initilization
-- 
----------------------------------------------------------------------------------------------------


-- Initializes the actor
---@param self instance - The scene instance
initialize = function(self)
    table.insert(SAVEDSCENES, self)
    Event:new("BG3SX_SceneInit", self)

    setStartLocations(self) -- Save start location of each entity to later teleport them back
    saveCampFlags(self) -- Saves which entities had campflags applied before

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
        
        local entityBodyShape = Entity:GetBodyShape(entity)         -- TODO: Implement Animation Heightmatching
        local entityHeightClass = Entity:GetHeightClass(entity)     -- Save the entities body heightclass for animation matching
    end

    for _, entity in pairs(self.entities) do
        table.insert(self.actors, Actor:new(entity))
        self:ScaleEntity(entity) -- After creating the actor to not create one with a smaller scale
    end

    -- self:Setup()

    -- Re-enable finalizeScene(self) if it creates a problem, maybe even with delay
    -------------------------------------
    -- finalizeScene(self)
    -------------------------------------
    -- Then disable/delete anything else under this row

    -- Condensed finalizeScene(self)
    for _, actor in ipairs(self.actors) do
        local startLocation = self.startLocations[1]
        -- Osi.TeleportToPosition(actor.uuid, startLocation.position.x, startLocation.position.y, startLocation.position.z) -- now handled correctly in actor initialization
        Entity:RotateEntity(actor.uuid, startLocation.rotationHelper)
    end
    Event:new("BG3SX_SceneCreated", self) -- MOD EVENT
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
    local oldLocation = scene.rootPosition -- Only used for Event:new payload
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

        Osi.TeleportToPosition(actor.uuid, newLocation.x, newLocation.y, newLocation.z)
        Osi.TeleportToPosition(actor.parent, newLocation.x, newLocation.y, newLocation.z)
        if #scene.props > 0 then
            for _, prop in pairs(scene.props) do
                Osi.TeleportToPosition(prop, newLocation.x, newLocation.y, newLocation.z)
            end
        end
    end

    Sex:PlayAnimation(entity, scene.currentAnimation) -- Play prior animation again

    Event:new("BG3SX_SceneMove", {scene, oldLocation, newLocation}) -- MOD EVENT
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

    scene:ToggleCampFlags(entity) -- Toggles camp flags so companions return to tents if they had them before
    
    -- Re-attach entity to make it selectable again
    Osi.SetDetached(entity, 0)
    Osi.SetVisible(entity, 1) -- 1 visible, 0 invisible
end


-- Destroys a scene instance
function Scene:Destroy()

    self:CancelAllSoundTimers()
    for _, entity in pairs(self.entities) do -- Go over this seperately so it already is applied to every entity before the other stuff happens
        -- Effect:Fade(entity, 2000) -- 2sec Fadeout on scene termination
    end

    for _, actor in pairs(self.actors) do
        actor:Destroy()
    end

    for _, entity in pairs(self.entities) do
        sceneEntityReset(entity)
        
        -- Play recovery sound as substitue for orgasms
        Osi.PlaySound(entity, ORGASM_SOUNDS[math.random(1, #ORGASM_SOUNDS)]) -- TODO - change this to a generic sound for when we use this for non-sex instead

        -- Removes any spells given for the scene
        Sex:RemoveSexSceneSpells(entity)

        -- Readds the regular sex spells (StartSex, Options, ChangeGenitals)
        if Osi.IsPartyMember(entity, 0) == 1 then
            Sex:AddMainSexSpells(entity)
        end

    end
    
    Event:new("BG3SX_SceneDestroyed", self)

    for i,scene in ipairs(SAVEDSCENES) do
        if scene == self then
            table.remove(SAVEDSCENES, i)
        end
    end
end