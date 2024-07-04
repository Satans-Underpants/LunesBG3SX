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
        actors          = {},
        currentAnimation= {},
        currentSounds   = {},
        props           = {},
        entityScales    = {},
        startLocations  = {}, -- Never changes - Used to teleport everyone back on Scene:Destroy()
        timerHandles    = {},
        cameraZoom      = {}
    }, Scene)
    -- Somehow can't set rootPosition/rotation within the instance, it poops itself trying to do this - rootPosition.x, rootPosition.y, rootPosition.z = Osi.GetPosition(entities[1])
    instance.rootPosition.x, instance.rootPosition.y, instance.rootPosition.z = Osi.GetPosition(entities[1])
    instance.rotation.x, instance.rotation.y, instance.rotation.z = Osi.GetRotation(entities[1])
    --_P("ENTITIES DUMP")
    --_D(entities)

    -- for _,entity in pairs(instance.entities) do 
    --     Effect:Fade(entity, 2000) -- 2sec Fade duration on scene creation
    -- end
    
    -- Delay so user doesn't see setup
    Ext.Timer.WaitFor(1000, function() initialize(instance)end)

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
local function setStartLocations(scene)
    for _,entity in pairs(scene.entities) do
        local position = {}
        position.x, position.y, position.z = Osi.GetPosition(entity)
        --_D(position)
        local rotationHelper = Entity:SaveEntityRotation(entity)

        table.insert(scene.startLocations, {entity = entity, position = position, rotationHelper = rotationHelper})
    end
    -- _P("------------------STARTLOCATIONS-------------")
    --_D(scene.startLocations)
end

-- Gets an entities start location for a location reset of an entity on Scene:Destroy()
---@param entity    string  - UUID of the entity 
---@return          table   - The entities position
---@return          table   - The entities rotation
local function getStartLocation(scene, entity)
    --_D(scene.startLocations)
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

    -- _P("[BG3SX][Scene.lua] - Scene:RegisterNewSoundTimer - Current List of Timers:")
    --_D(self.timerHandles)
end
function Scene:CancelAllSoundTimers()
    for _,handle in pairs(self.timerHandles) do
        table.remove(self.timerHandles, handle)
        Ext.Timer.Cancel(handle)
    end
    -- _P("[BG3SX][Scene.lua] - Scene:CancelAllSoundTimers() - All SoundTimers canceled")
end


----------------------------------------------------------------------------------------------------
-- 
-- 										    Setup
-- 
----------------------------------------------------------------------------------------------------

-- Scale entity for camera
---@param entity uuid
function Scene:ScaleEntity(entity)

    -- _P("[BG3SX][Scene.lua] - Calling Try Get Entity Value")
    local startScale = Entity:TryGetEntityValue(entity, nil, {"GameObjectVisual", "Scale"})
    -- _P("Start Scale = " , startScale)
    table.insert(self.entityScales, {entity = entity, scale = startScale})
    -- _D(self.entityScales)
    Entity:Scale(entity, 0.5)

    -- _P("[BG3SX][Scene.lua] - Scene:ScaleEntity - ", entity, " scaled to 0.5")
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
-- function Scene:SetCamera(uuid)
--     if Osi.IsPartyMember(uuid, 0) == 1 then
--         entity = Ext.Entity.Get(uuid)
--         local zoom = Entity:TryGetEntityValue(entity, nil, {"GameObjectVisual", "Scale"})
--         if zoom then
--             table.insert(self.cameraZoom, {entity = entity, zoom = zoom, previousZoom = previousZoom})
--             for _,entry in pairs(self.cameraZoom) do
--             entity.GameObjectVisual.Scale = 0.5
--             entity:Replicate("GameObjectVisual")
--         end
--     end

--     -- _P("[BG3SX][Scene.lua] - Scene:SetCamera - For ", entity)
-- end

-- After this is called, wait 400 ms
-- function Scene:Setup()
--     for _, entity in pairs(self.entities) do
--         -- self:MakeSpace(entity)
--         -- self:SetCamera(entity)
--         self:ScaleEntity(entity)
--     end
--     -- _P("[BG3SX][Scene.lua] - Scene:Setup() finished")
-- end

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

        -- local startLocation = self.startLocations[1]

        --for _, startLocation in pairs(self.startLocations) do
            --_P("[BG3SX][Scene.lua] - finilizeScene(self) - iterating over startLocations ", startLocation)
           -- if actor.parent == startLocation.entity then
               -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - iterating over startLocations ", startLocation)
            
                -- Osi.TeleportToPosition(actor.uuid, startLocation.position.x, startLocation.position.y, startLocation.position.z)
                -- Entity:RotateEntity(actor.uuid, startLocation.rotationHelper)
           -- end
        --end

        -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - disableActorMovement for ", actor.parent)
        -- _P("[BG3SX][Scene.lua] - finilizeScene(self) - disableActorMovement - IS CURRENTLY MISSING AS A FUNCTION")
        --disableActorMovement(actor.parent)
    end

    if #self.entities >1 then
        local test = {}
        test.x, test.y, test.z = Osi.GetPosition(self.startLocations[1].rotationHelper)
        _D(test)
        -- Entity:SaveEntityRotation(self.actors[1])
        for i = 2, #self.actors do
            local actor = self.actors[i]
            local startLocation = self.startLocations[1]
            -- Osi.TeleportToPosition(actor.uuid, startLocation.position.x, startLocation.position.y, startLocation.position.z)
            -- Rotate all other actors in same direction as the first one
            Entity:RotateEntity(actor.uuid, startLocation.rotationHelper)
        end
    end

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

    -- _P("[BG3SX][Scene.lua] - initialize(self) - add new scene to list of SAVEDSCENES:")
    table.insert(SAVEDSCENES, self)
    --_D(SAVEDSCENES)
    
    -- Ext.Net.BroadcastMessage("BG3SX_SceneInit", Ext.Json.Stringify(self)) -- SE EVENT
    -- Event:new("BG3SX_SceneInit", self) -- MOD EVENT
    Event:new("BG3SX_SceneInit", self)
    -- _P("[BG3SX][Scene.lua] - Scene:new() - initialize")
    
    setStartLocations(self) -- Save start location of each entity to later teleport them back

    -- Iterate over every entity thats involved in a new scene
    local entityIteratedOverBefore
    local entityRemoved
    for _, entity in pairs(self.entities) do
        if entity == entityIteratedOverBefore then
            entityRemoved = entity
            break -- Safeguard check to not create another actor if entity may have been added twice into scene (e.g. masturbation (caster/target))
        else
            entityIteratedOverBefore = entity
        end
        
        -- _P("---------------New entity in the new scene----------------")

        Osi.SetVisible(entity, 0)
    
        -- Delay so user doesn't see setup

        -- Create a new actor for each entity involved in the scene
        -- _P("[BG3SX][Scene.lua] - Scene:new() - initialize - Actor:new( ", entity, " )")
        -- local actor = Actor:new(entity)
        table.insert(self.actors, Actor:new(entity))  
        
        -- Make entity untargetable and detached from party to stop party members from following
        Osi.SetDetached(entity, 1)
        Osi.DetachFromPartyGroup(entity)

        -- Remove the main spells -- does nothing if they are already removed. We can just purge all animstart spells here
        -- _P("[BG3SX][Scene.lua] - Scene:new() - initialize - Remove Main Spells for ", entity, " during Scene")
        for _, spell in pairs(ILLEGAL_DURING_ANIMATION_SPELLS) do
            Osi.RemoveSpell(entity, spell)
        end
        
        -- Clear FLAG_COMPANION_IN_CAMP to prevent companions from teleporting to their tent while all this is happening
        if Osi.GetFlag(FLAG_COMPANION_IN_CAMP, entity) == 1 then
            Osi.ClearFlag(FLAG_COMPANION_IN_CAMP, entity)
        end

        -- Save the entities body heightclass for animation matching
        -- TODO: Implement Animation Heightmatching
        local entityBodyShape = Entity:GetBodyShape(entity)
        local entityHeightClass = Entity:GetHeightClass(entity)

        -- Osi.TeleportToPosition(entity, actor.position.x, actor.position.y, actor.position.z, "", 0, 0, 0, 0, 0)
        self:ScaleEntity(entity)
        -- self:MakeSpace(entity)
    end

    if entityRemoved then
        table.remove(self.entities, entityRemoved)
    end

    -- _P("-----------------------------------------------------------")

    -- self:Setup()
    
    
    -- _P("[BG3SX][Scene.lua] - Scene:new() - initialize")
    finalizeScene(self)
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
    local oldLocation = scene.rootPosition

    -- _D(newLocation)
    -- _D(newLocation.x)
    for _, actor in ipairs(scene.actors) do
        -- oldLocation = actor.position
        
        -- Do nothing if the new location is too far from the caster's start position,
        -- so players would not abuse it to get to some "no no" places.
        -- local dx = newLocation.x - actor.position.x -- get the difference per axis
        -- local dy = newLocation.y - actor.position.y
        -- local dz = newLocation.z - actor.position.z
        -- if math.sqrt(dx * dx + dy * dy + dz * dz) >= 4 then -- if difference is greater than 4 units
        --     return
        -- end
        
        --Osi.SetDetached(casterData.Actor, 1)

        -- Move stuff
        Osi.TeleportToPosition(actor.uuid, newLocation.x, newLocation.y, newLocation.z)
        Osi.TeleportToPosition(actor.parent, newLocation.x, newLocation.y, newLocation.z)
        
        -- TODO - when we use props we probably want to "bind" them to a specific actor
        -- Teleports all props of a scene to the new rootlocation as well
        if #scene.props > 0 then
            for _, prop in pairs(scene.props) do
                Osi.TeleportToPosition(prop, newLocation.x, newLocation.y, newLocation.z)
            end
        end
    
        --Osi.SetDetached(casterData.Actor, 0)
        
    end

    scene.rootPosition = newLocation -- Always update rootPosition of a scene if it changes

    -- _P("--------------------------------------------------------------------")
    -- _P("[BG3SX][Scene.lua] - Scene:MoveSceneToLocation - Moving scene from:")
    --_D(oldLocation)
    -- _P("to")
    --_D(newLocation)
    -- _P("--------------------------------------------------------------------")

    -- Ext.Net.BroadcastMessage("BG3SX_SceneTeleport", Ext.Json.Stringify({scene, oldLocation, newLocation})) -- SE EVENT
    Event:new("BG3SX_SceneTeleport", {scene, oldLocation, newLocation}) -- MOD EVENT

end


----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Stop
-- 
----------------------------------------------------------------------------------------------------

-- Destroys a scene instance
function Scene:Destroy()

    -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - Initiating scene termination for scene:")
    --_D(self)

    if self.entities then
        for _, entity in pairs(self.entities) do  -- Initial entity for-loop solely for a Fadeout
            Effect:Fade(entity, 2000) -- 2sec Fadeout on scene termination
        end
    end

    self:CancelAllSoundTimers() -- Should cancel all sound timers to not infinite loop random new ones 

    if self.actors then
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
            -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - actor:Destroy() - Initiating actor termination for actor:")
            --_D(actor)
            actor:Destroy()
        end
    end

    if self.entities then
        -- Iterates over every saved entity for a given scene instance
        for _, entity in pairs(self.entities) do
            -- Play recovery sound as substitue for orgasms
            -- TODO - change this to a generic sound for when we use this for non-sex instead
            -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - Play Orgasm sound for ", entity)
            Osi.PlaySound(entity, ORGASM_SOUNDS[math.random(1, #ORGASM_SOUNDS)])

            -- Unlocks movement
            Osi.RemoveBoosts(entity, "ActionResourceBlock(Movement)", 0, "", "")
    
            -- Sets scale back to a saved value during scene initialization
            local startScale
            -- _D(self.entityScales)
            for _, entry in pairs(self.entityScales) do
                if entity == entry.entity then
                    startScale = entry.scale
                end
            end

            -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - Entity:Scale for ", entity)
            Entity:Scale(entity, startScale)

            -- Removes any spells given
            -- TODO and any other animation specific spells  
            -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - Sex:RemoveSexSceneSpells for ", entity)
            Sex:RemoveSexSceneSpells(entity)

            -- Readds the regular sex spells (StartSex, Options, ChangeGenitals)
            -- TODO: Add any other legal animation spells back in the future
            if Osi.IsPartyMember(entity, 0) == 1 then
                -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - Sex:AddMainSexSpells for ", entity)
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
            
            -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - Scene removed from SAVEDSCENES")
            -- _P("[BG3SX][Scene.lua] - Scene:Destroy() - SAVEDSCENES Current Status:")
            -- _D(SAVEDSCENES)
        end
    end
end