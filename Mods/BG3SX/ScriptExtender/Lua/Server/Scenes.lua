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
    table.insert(SAVEDSCENES, self)

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
-- 							TODO - SWITCH ALL OSI TIMERS WITH EXT TIMERS
-- 
----------------------------------------------------------------------------------------------------



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
    Osi.RemoveSpell(entity, "ChangeSceneLocation")
    Osi.RemoveSpell(entity, "ChangeSceneLocation")
    Osi.RemoveSpell(entity, "zzSwitchPlaces")
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Start
-- 
----------------------------------------------------------------------------------------------------


-- Sets an entities start location before possibly getting teleported during a scene for an easy reset on Scene:Destroy() with getStartLocation
---@param entity string - UUID of the entity 
local function setStartLocation(entity)
    local position = Osi.GetPosition(entity)
    local rotation = Osi.GetRotation(entity)
    table.insert(startLocations, {entity = entity, position = position, rotation = rotation})
end

-- Gets an entities start location for a location reset of an entity on Scene:Destroy()
---@param entity    string  - UUID of the entity 
---@return          table   - The entities position
---@return          table   - The entities rotation
local function getStartLocation(entity)
    for _, entry in startLocations do
        if entry.entity == entity then
            return entry.position, entry.rotation
        end
    end
end



-- copies the components of a parent entity to the proxy
-- the proxy is the entity used in sex
--- func desc
---@param actorData any
---@param proxyData any
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
    disableActorMovement(actorData.Proxy)
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




--- func desc
---@param actorData any
---@param proxyData any
function Scene:FinalizeSetup(actorData, proxyData)
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

    disableActorMovement(actorData.Actor)
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
            Sex:StopVocals(actorData)

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
end





----------------------------------------------------------------------------------------------------
-- 
-- 								  Main functions
-- 
----------------------------------------------------------------------------------------------------




-- Initializes the actor
---@param self instance - "self" to actually be applied to the Actor:new instance
initialize = function(self)
    
    -- Iterate over every entity thats involved in a new scene
    for _, entity in pairs(self.entities) do

        setStartLocation(entity) -- Save start location of each entity to later teleport them back
        removeSexPositionSpells(entity) -- Removes any random position spells they still might have

        -- Create a new actor for each entity involved in the scene
        table.insert(self.actors, Actor:new(entity))

        -- Scale entity for camera
        -- TODO - rewrite TryGetEntityValue to take a table instead of multiple strings
        local startScale = Entity:TryGetEntityValue(entity, "GameObjectVisual", "Scale", nil, nil)
        table.insert(self.entityScales, {entity = entity, scale = startScale})
        Entity:Scale(self.entity, 0.5)

        -- Make entity untargetable and detached from party to stop party members from following
        Osi.SetDetached(entity, 1)
        Osi.DetachFromPartyGroup(entity)

        -- Remove the main spells
        Osi.RemoveSpell(entity, "BG3SXContainer")
        Osi.RemoveSpell(entity, "Change_Genitals")
        Osi.RemoveSpell(entity, "BG3SXOptions")

        -- Clear FLAG_COMPANION_IN_CAMP to prevent companions from teleporting to their tent while all this is happening
        if Osi.GetFlag(FLAG_COMPANION_IN_CAMP, entity) == 1 then
            Osi.ClearFlag(FLAG_COMPANION_IN_CAMP, entity)
        end


        -- Save the entities body heightclass for animation matching
        local entityBodyShape = Entity:GetBodyShape(entity)
        local entityHeightClass = Entity:GetHeightClass(entity)
        
        -- probably need a delay for setup
        Sex:StartSex(entityHeightClass)
    end
end





----------------------------------------------------------------------------------------------------
-- 
-- 								          Sex
-- 
----------------------------------------------------------------------------------------------------

--- func desc
---@param : any
function Scene:StartPairedScene(caster, target, animProperties)
    -- Always create a proxy for targets if they are PCs or companions or some temporary party members. 
    -- It fixes the moan sounds for companions and prevents animation reset on these characters' selection in the party.
    local targetNeedsProxy = (Entity:IsPlayable(target) or Osi.IsPartyMember(target, 1) == 1)

    local pairData = {
        Caster = caster,
        CasterData = SexActor_Init(caster, true, "SexVocalCaster", animProperties),
        Target = target,
        TargetData = SexActor_Init(target, true, "SexVocalTarget", animProperties), -- targetNeedsProxy
        AnimationActorHeights = "",
        AnimProperties = animProperties,
        SwitchPlaces = false,
    }

    local casterScaled = Entity:PurgeBodyScaleStatuses(pairData.CasterData)
    local targetScaled = Entity:PurgeBodyScaleStatuses(pairData.TargetData)

    Sex:UpdateAvailableAnimations(pairData)

    AnimationPairs[#AnimationPairs + 1] = pairData

    local setupDelay = 400

    if pairData.CasterData.Strip or pairData.TargetData.Strip then
        if pairData.CasterData.Strip then
            Osi.ApplyStatus(caster, "DARK_JUSTICIAR_VFX", 1)
        end
        if pairData.TargetData.Strip then
            Osi.ApplyStatus(target, "DARK_JUSTICIAR_VFX", 1)
        end
        Osi.ObjectTimerLaunch(caster, "PairedSexStrip", 600)
        setupDelay = 2000
    end

    if (casterScaled or targetScaled) and setupDelay < BODY_SCALE_DELAY then
        setupDelay = BODY_SCALE_DELAY -- Give some time for the bodies to go back to their normal scale
    end
    
    if pairData.AnimProperties["Fade"] == true then
        Osi.ObjectTimerLaunch(caster, "PairedSexFade.Start", setupDelay - 200)
        Osi.ObjectTimerLaunch(caster, "PairedSexFade.End", setupDelay + 800)
        Osi.ObjectTimerLaunch(target, "PairedSexFade.Start", setupDelay - 200)
        Osi.ObjectTimerLaunch(target, "PairedSexFade.End", setupDelay + 800)
    end

    Osi.ObjectTimerLaunch(caster, "PairedSexSetup", setupDelay)

    -- Add sex control spells to the caster
    Sex:InitSexSpells(pairData)
    Sex:RegisterCasterSexSpell(pairData, pairData.AnimContainer)
    if pairData.CasterData.HasPenis == pairData.TargetData.HasPenis then
        Sex:RegisterCasterSexSpell(pairData, "zzSwitchPlaces")
    end
    Sex:RegisterCasterSexSpell(pairData, "ChangeSceneLocation")
    if pairData.CasterData.CameraScaleDown then
        Sex:RegisterCasterSexSpell(pairData, "CameraHeight")
    end
    Sex:RegisterCasterSexSpell(pairData, "zzzEndSex")
    AddPairedCasterSexSpell(pairData)
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
function MovePairedSceneToLocation(actor, x, y, z)
    local pairIndex = FindPairIndexByActor(actor)
    if pairIndex < 1 then
        return
    end
    local pairData = AnimationPairs[pairIndex]

    Scene:MoveSceneToLocation(x, y, z, pairData.CasterData, pairData.TargetData)
end



---@param pairData any
function StopPairedAnimation(pairData)
    Osi.ObjectTimerCancel(pairData.Caster, "PairedSexFade.Start")
    Osi.ObjectTimerCancel(pairData.Caster, "PairedSexFade.End")
    Osi.ObjectTimerCancel(pairData.Target, "PairedSexFade.Start")
    Osi.ObjectTimerCancel(pairData.Target, "PairedSexFade.End")

    Osi.ScreenFadeTo(pairData.Caster, 0.1, 0.1, "AnimFade")
    Osi.ScreenFadeTo(pairData.Target, 0.1, 0.1, "AnimFade")

    Osi.ObjectTimerLaunch(pairData.Caster, "FinishSex", 200)
    Osi.ObjectTimerLaunch(pairData.Caster, "PairedSexFade.End", 2500)
    Osi.ObjectTimerLaunch(pairData.Target, "PairedSexFade.End", 2500)

    Sex:StopVocals(pairData.CasterData)
    Sex:StopVocals(pairData.TargetData)
end