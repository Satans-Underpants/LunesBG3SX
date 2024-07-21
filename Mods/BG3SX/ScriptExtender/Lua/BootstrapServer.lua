------------------------------------
        -- Init Classes --
------------------------------------

-- Just for it to not throw errors because it can't be loaded, will get removed later
-- Structure will probably be added to every single AnimationData
Ext.Require("Shared/Data/AnimHeightMatching.lua")

-- Initialize Debug and Events
Ext.Require("Shared/Utils/_DEBUG.lua")
Ext.Require("Shared/Data/EventSubscriber.lua") -- Global storage space for all event subscriber instances
Ext.Require("Shared/Utils/Event.lua")

-- Initialize Data
Ext.Require("Shared/Data/Sounds.lua") -- Initialize before AnimationData so it actually gets its soundTables
Ext.Require("Shared/Data/AnimationData.lua")
Ext.Require("Shared/Data/BodyLibrary.lua")
Ext.Require("Shared/Data/EntityScale.lua")
Ext.Require("Shared/Data/Equipment.lua")
Ext.Require("Shared/Data/Statuses.lua")
Ext.Require("Shared/Data/Origins.lua")
Ext.Require("Shared/Data/Spells.lua")
Ext.Require("Shared/Data/SceneTypes.lua")

-- Initialize Utilities
Ext.Require("Shared/Utils/Math.lua")
Ext.Require("Shared/Utils/Table.lua")
Ext.Require("Shared/Utils/Entity.lua")
Ext.Require("Shared/Utils/Helper.lua")
-- Ext.Require("Utils/UIHelper.lua") - [NYI]

-- Sex
Ext.Require("Server/Classes/Sex/Genital.lua")
Ext.Require("Server/Classes/Sex/NPCStripping.lua")
Ext.Require("Server/Classes/Sex/Sex.lua")
Ext.Require("Server/Classes/Sex/SexUserVars.lua")

-- Initialize General Classes
Ext.Require("Server/Classes/Effect.lua")
Ext.Require("Server/Classes/Sound.lua")
Ext.Require("Server/Classes/Animation.lua")
Ext.Require("Server/Classes/Actor.lua")
Ext.Require("Server/Classes/Scene.lua")
-- Ext.Require("Server/Classes/Spells.lua") - [NYI]
-- Ext.Require("Server/Classes/Objects.lua") - [NYI]
Ext.Require("Server/Classes/Main.lua")

-- Initialize Usersettings
Ext.Require("Shared/Utils/UserSettings.lua")

-- Initialize Listeners
Ext.Require("Server/Listeners/GenitalListeners.lua")
Ext.Require("Server/Listeners/EntityListeners.lua")
Ext.Require("Server/Listeners/SceneListeners.lua")
Ext.Require("Server/Listeners/SexListeners.lua")

------------------------------------
        -- Mod Events --
------------------------------------

-- Please check the very bottom of the Event.lua file on how to subscribe to events
-- Only works with Server context, not on clients


-- Available Events to listen to
------------------------------------------------------------------------------------------------------------------------------------------------
-- "Channel"(payload)                                                         - Payload Info                              - Where it Triggers

-- "BG3SX_SexStartSpellUsed"({caster, target, spellData})                     - spellData = Entry of STARTSEXSPELLS{}     - SexListeners.lua
-- "BG3SX_SexAnimationChange"({caster, animationData})                        - animationData = Entry of ANIMATIONS{}     - SexListeners.lua
-- "BG3SX_SceneInit"(newScene)                                                - Scene:new(instance)                       - Scene.lua
-- "BG3SX_SceneCreated"(newScene)                                             - Scene:new(instance) - Fully initialized   - Scene.lua
-- "BG3SX_ActorInit"(newActor)                                                - Actor:new(instance)                       - Actor.lua
-- "BG3SX_ActorCreated"(newActor)                                             - Actor:new(instance) - Fully initialized   - Actor.lua
-- "BG3SX_AnimationChange"(newAnimation)                                      - Animation:new(instance)                   - Animations.lua
-- "BG3SX_SoundChange"(newSound)                                              - Sound:new(instance)                       - Sounds.lua
-- "BG3SX_SceneMove"({scene, oldLocation, newlocation})             -                                           - Scene.lua
-- "BG3SX_SceneSwitchPlacesBefore"(scene.actors)                              - List of actors before change              - Scene.lua
-- "BG3SX_SceneSwitchPlacesAfter"(scene.actors)                               - List of actors after change               - Scene.lua
-- "BG3SX_CameraHeightChange"(entity)                                         -                                           - Sex.lua
-- [NYI] "BG3SX_EntityStripped"({entity, strippedEquipment, remainingEquipment})    -                                           - Actor.lua
-- "BG3SX_ActorDressed"({actor, equipmentTable})                              -                                           - Actor.lua
-- "BG3SX_GenitalChange"({entity, newGenital})                                -                                           - Genitals.lua




