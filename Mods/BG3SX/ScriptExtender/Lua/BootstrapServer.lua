------------------------------------
        -- Init Classes --
------------------------------------

-- Initialize Debug Class
Ext.Require("Server/Classes/_DEBUG.lua")
Ext.Require("Server/Classes/Event.lua")
Ext.Require("Server/Classes/SubscriberTest.lua")

-- Initialize Data
Ext.Require("Data/SexAnimations.lua")
Ext.Require("Data/BodyLibrary.lua")
Ext.Require("Data/EntityScale.lua")
Ext.Require("Data/Equipment.lua")
Ext.Require("Data/Statuses.lua")
Ext.Require("Data/Origins.lua")
Ext.Require("Data/Sounds.lua")
Ext.Require("Data/Spells.lua")
Ext.Require("Data/SceneTypes.lua")

-- Initialize Utilities
Ext.Require("Utils/Math.lua")
Ext.Require("Utils/Table.lua")
Ext.Require("Utils/Entity.lua")
Ext.Require("Utils/Helper.lua")
-- Ext.Require("Utils/UIHelper.lua") - [NYI]

-- Sex
Ext.Require("Server/Classes/Sex/Genital.lua")
Ext.Require("Server/Classes/Sex/NPCStripping.lua")
Ext.Require("Server/Classes/Sex/Sex.lua")

-- Initialize General Classes
Ext.Require("Server/Classes/Effect.lua")
Ext.Require("Server/Classes/Sound.lua")
Ext.Require("Server/Classes/Animation.lua")
Ext.Require("Server/Classes/Actor.lua")
Ext.Require("Server/Classes/Scene.lua")

-- Ext.Require("Server/Classes/Spells.lua") - [NYI]
-- Ext.Require("Server/Classes/Objects.lua") - [NYI]


-- Initialize Main Class and Usersettings
Ext.Require("Server/Classes/Main.lua")
Ext.Require("Server/Classes/UserSettings.lua")

-- Initialize Listeners
Ext.Require("Server/Listeners/GenitalListeners.lua")
Ext.Require("Server/Listeners/EntityListeners.lua")
Ext.Require("Server/Listeners/SceneListeners.lua")
Ext.Require("Server/Listeners/SexListeners.lua")


_P("[BG3SX] - BootstrapServer.lua Initialized")


-- TODO: ModVariables are not prefered anymore - Use Ext.Mod.GetMod(moduuid) to then use a mods functions instead like this: TheMod.Class:Function or TheMod.Class.Variable or TheMod.Class.TABLE
-- Create several _DEBUG messages for each function

------------------------------------
        -- Mod Net Events --
------------------------------------

-- Please check the very bottom of the Event.lua file on how to subscribe to event channels
-- Channel is a "string"(payload needs Ext.Json.Stringify(payLoad))
-- "Channel"(payload)                                                         - Payload Info                              - Where it Triggers

-- "BG3SX_SexStartSpellUsed"({caster, target, spellData})                     - spellData = Entry of STARTSEXSPELLS{}     - SexListeners.lua
-- "BG3SX_SexAnimationChange"({caster, animationData})                        - animationData = Entry of ANIMATIONS{}     - SexListeners.lua
-- "BG3SX_SceneInit"(newScene)                                                - Scene:new(instance)                       - Scene.lua
-- "BG3SX_SceneCreated"(newScene)                                             - Scene:new(instance) - Fully initialized   - Scene.lua
-- "BG3SX_ActorInit"(newActor)                                                - Actor:new(instance)                       - Actor.lua
-- "BG3SX_ActorCreated"(newActor)                                             - Actor:new(instance) - Fully initialized   - Actor.lua
-- "BG3SX_AnimationChange"(newAnimation)                                      - Animation:new(instance)                   - Animations.lua
-- "BG3SX_SoundChange"(newSound)                                              - Sound:new(instance)                       - Sounds.lua
-- "BG3SX_SceneTeleport"({scene, oldLocation, newlocation})                   -                                           - Scene.lua
-- "BG3SX_SceneSwitchPlacesBefore"(scene.actors)                              - List of actors before change              - Scene.lua
-- "BG3SX_SceneSwitchPlacesAfter"(scene.actors)                               - List of actors after change               - Scene.lua
-- "BG3SX_CameraHeightChange"(entity)                                         -                                           - Sex.lua
-- [NYI] "BG3SX_EntityStripped"({entity, strippedEquipment, remainingEquipment})    -                                           - Actor.lua
-- "BG3SX_ActorDressed"({actor, equipmentTable})                              -                                           - Actor.lua
-- "BG3SX_GenitalChange"({entity, newGenital})                                -                                           - Genitals.lua





------------------------------------
        -- Mod Variables --
------------------------------------

-- Ext.Vars.RegisterUserVariable("ActorData", {
--     Server = true,
--     Client = true, 
--     SyncToClient = true
-- })

-- Ext.Vars.RegisterUserVariable("PairData", {
--     Server = true,
--     Client = true, 
--     SyncToClient = true
-- })

-- Ext.Vars.RegisterUserVariable("SoloData", {
--     Server = true,
--     Client = true, 
--     SyncToClient = true
-- })