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
---@param rootPosition      table   - Table of x,y,z coordinates
---@param rotation          table   - Table with x,y,z,w 
---@param actors            table   - Table of all actors in a scene
---@param currentAnimation  table   - Table of the current animation being played
---@param currentSounds     table   - Table of currently playing sounds
---@param props             table   - Table of all props currently in a scene
---@param entityScales      table   - Saves the start entity scales
---@param startLocations    table   - Saves the start Locations (Position/Rotation) of each entity to teleport back to when scene is destroyed
---@param timerHandles      table   - Timer handles in case they have to be cancelled (failsave)
function Scene:new(entities)
    local instance      = setmetatable({
        entities        = entities,
        rootPosition    = {},
        rotation        = {},
        startLocations  = {}, -- Should never change after initialize - Used to teleport everyone back on Scene:Destroy()
        entityScales    = {},
        actors          = {},
        currentAnimation= {},
        currentSounds   = {},
        timerHandles    = {},
        cameraZoom      = {},
        props           = {},
        switchPlaces    = "false",
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


-- CONSTANTS
--------------------------------------------------------------

local FLAG_COMPANION_IN_CAMP = "161b7223-039d-4ebe-986f-1dcd9a66733f"
-- local BODY_SCALE_DELAY = 2000 --  -- Not used anymore i think

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
function Scene:SetCamera(uuid)
    if Osi.IsPartyMember(uuid, 0) == 1 then
        entity = Ext.Entity.Get(uuid)
        local zoom = Entity:TryGetEntityValue(entity, nil, {"GameObjectVisual", "Scale"})
        if zoom then
            table.insert(self.cameraZoom, {entity = entity, zoom = zoom, previousZoom = previousZoom})
            for _,entry in pairs(self.cameraZoom) do
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
---@param self instance - "self" to actually be applied to the Actor:new instance
initialize = function(self)
    table.insert(SAVEDSCENES, self)
    Event:new("BG3SX_SceneInit", self)

    setStartLocations(self) -- Save start location of each entity to later teleport them back
    
    for _, entity in pairs(self.entities) do
        Entity:ToggleWalkThrough(entity) -- We do this before in a seperate loop to already be applied
    end

    -- Iterate over every entity thats involved in a new scene
    for _, entity in pairs(self.entities) do
        Osi.SetVisible(entity, 0)
        Entity:ToggleMovement(entity) -- TODO: Fix

        -- Could enable spawning of actor inside entity then spawn new actor
        table.insert(self.actors, Actor:new(entity))

        -- Make entity untargetable and detached from party to stop party members from following
        Osi.SetDetached(entity, 1)
        Osi.DetachFromPartyGroup(entity)

        -- Remove the main spells -- does nothing if they are already removed. We can just purge all animstart spells here
        -- _P("[BG3SX][Scene.lua] - Scene:new() - initialize - Remove Main Spells for ", entity, " during Scene")
        for _, spell in pairs(MAINSEXSPELLS) do  -- Configurable in Shared/Data/Spells.lua
            Osi.RemoveSpell(entity, spell)
        end

        -- Clear FLAG_COMPANION_IN_CAMP to prevent companions from teleporting to their tent while all this is happening
        if Osi.GetFlag(FLAG_COMPANION_IN_CAMP, entity) == 1 then
            Osi.ClearFlag(FLAG_COMPANION_IN_CAMP, entity)
        end

        -- TODO: Implement Animation Heightmatching
        -- Save the entities body heightclass for animation matching
        local entityBodyShape = Entity:GetBodyShape(entity)
        local entityHeightClass = Entity:GetHeightClass(entity)

        self:ScaleEntity(entity)
    end

    -- self:Setup()

    -- Re-enable finalizeScene(self) if it creates a problem, maybe even with delay
    -------------------------------------
    -- finalizeScene(self)
    -------------------------------------
    -- Then disable/delete anything else under this row
    
    -- Condensed finalizeScene(self)
    -- Play around with this loop to fix repositioning during scene creation
    for _, actor in ipairs(self.actors) do
        local startLocation = self.startLocations[1]
        Osi.TeleportToPosition(actor.uuid, startLocation.position.x, startLocation.position.y, startLocation.position.z)
        Entity:RotateEntity(actor.uuid, startLocation.rotationHelper)
    end
    Event:new("BG3SX_SceneCreated", self) -- MOD EVENT
end


----------------------------------------------------------------------------------------------------
-- 
-- 										During Scene
-- 
----------------------------------------------------------------------------------------------------


--- func desc
---@param entity any
---@param newLocation - x, y, z
function Scene:MoveSceneToLocation(entity, newLocation)
    local scene = Scene:FindSceneByEntity(entity)
    local oldLocation = scene.rootPosition -- Only used for Event:new payload

    for _, actor in ipairs(scene.actors) do

        -- Keep this in case we want to re-enable a max. distance to teleport
        ---------------------------------------------------------------------------------------
        -- Do nothing if the new location is too far from the caster's start position,
        -- so players would not abuse it to get to some "no no" places.
        -- local dx = newLocation.x - actor.position.x -- get the difference per axis
        -- local dy = newLocation.y - actor.position.y
        -- local dz = newLocation.z - actor.position.z
        -- if math.sqrt(dx * dx + dy * dy + dz * dz) >= 4 then -- if difference is greater than 4 units
        --     return
        -- end

        -- Move stuff
        Osi.TeleportToPosition(actor.uuid, newLocation.x, newLocation.y, newLocation.z)
        Osi.TeleportToPosition(actor.parent, newLocation.x, newLocation.y, newLocation.z)

        -- TODO - when we use props we probably want to "bind" them to a specific actor
            -- No they should all be located at rootlocation and animators would create an animation for them as well based on rootlocation
        -- Teleports all props of a scene to the new rootlocation
        if #scene.props > 0 then
            for _, prop in pairs(scene.props) do
                Osi.TeleportToPosition(prop, newLocation.x, newLocation.y, newLocation.z)
            end
        end
    end

    Sex:PlayAnimation(entity, scene.currentAnimation)

    scene.rootPosition = newLocation -- Always update rootPosition of a scene after changing it

    -- Ext.Net.BroadcastMessage("BG3SX_SceneTeleport", Ext.Json.Stringify({scene, oldLocation, newLocation})) -- SE EVENT
    Event:new("BG3SX_SceneMove", {scene, oldLocation, newLocation}) -- MOD EVENT

end


-- Rotates a scene by creating an invisible helper the actors can steer to
---@param caster any
---@param location any
function Scene:RotateScene(caster, location)
    local scene = Scene:FindSceneByEntity(caster)
    local helper = Osi.CreateAt("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", location.x, location.y, location.z, 0, 0, "")
    for _, actor in pairs(scene.actors) do
        Entity:ClearActionQueue(actor.uuid)
        Osi.SteerTo(actor.uuid, helper, 1) -- 1 = instant
    end
    Osi.RequestDeleteTemporary(helper)
    Sex:PlayAnimation(caster, scene.currentAnimation) -- Play the animation that played before again
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Stop
-- 
----------------------------------------------------------------------------------------------------

-- Destroys a scene instance
function Scene:Destroy()

    if self.entities then
        for _, entity in pairs(self.entities) do
            -- Effect:Fade(entity, 2000) -- 2sec Fadeout on scene termination
        end
    end

    self:CancelAllSoundTimers() -- Should cancel all sound timers to not infinite loop random new ones 

    if self.actors then

        -- TODO: Clean this up to basically only be actor:Destroy()
        -- Iterates over every saved actor for a given scene instance
        for _, actor in pairs(self.actors) do

            -- Gets the original locations per parent
            local startLocation
            for i, entry in ipairs(self.startLocations) do
                if entry.entity == actor.parent then
                    startLocation = entry
                end
            end
            -- Positioning
            Osi.TeleportToPosition(actor.parent, startLocation.position.x, startLocation.position.y, startLocation.position.z, "", 0, 0, 0, 0, 1)
            -- Entity:RotateEntity(actor.parent, startLocation.rotationHelper)

            Osi.SetVisible(actor.parent, 1) -- 1 visible, 0 invisible

            -- Requips everything which may have been removed during scene initialization
            if Entity:HasEquipment(actor.parent) then
                Entity:Redress(actor.parent, actor.oldArmourSet, actor.oldEquipment)
            end

            -- Delete actor
            actor:Destroy()
        end
    end

    -- TODO: Clean this up to also just be a Scene:ResetEntities() or something
    if self.entities then
        -- Iterates over every saved entity for a given scene instance
        for _, entity in pairs(self.entities) do
            -- Play recovery sound as substitue for orgasms
            -- TODO - change this to a generic sound for when we use this for non-sex instead

            Osi.PlaySound(entity, ORGASM_SOUNDS[math.random(1, #ORGASM_SOUNDS)])

            -- Unlocks movement
            Entity:ToggleMovement(entity)

            -- Sets scale back to a saved value during scene initialization
            local startScale
            for _, entry in pairs(self.entityScales) do
                if entity == entry.entity then
                    startScale = entry.scale
                end
            end

            Entity:Scale(entity, startScale)

            -- Removes any spells given
            Sex:RemoveSexSceneSpells(entity)

            -- Readds the regular sex spells (StartSex, Options, ChangeGenitals)
            if Osi.IsPartyMember(entity, 0) == 1 then
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

    Event:new("BG3SX_SceneDestroyed", self)

    -- Removes itself from SAVEDSCENES list
    for i,scene in ipairs(SAVEDSCENES) do
        if scene == self then
            table.remove(SAVEDSCENES, i)
        end
    end
end