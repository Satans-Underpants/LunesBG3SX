------------------------------------
        -- Mod Events --
------------------------------------

-- Available Events to listen to:
------------------------------------------------------------------------------------------------------------------------------------------------
-- "Channel" (Event Name)                                   - Payload Info                              - Where it Triggers

Ext.RegisterModEvent("BG3SX", "SexStartSpellUsed")          --({caster, target, spellData})             - SexListeners.lua
Ext.RegisterModEvent("BG3SX", "SexAnimationChange")         --({caster, animationData})                 - SexListeners.lua
Ext.RegisterModEvent("BG3SX", "SceneInit")                  --(newScene)                                - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneCreated")               --(newScene)                                - Scene.lua
Ext.RegisterModEvent("BG3SX", "ActorInit")                  --(newActor)                                - Actor.lua
Ext.RegisterModEvent("BG3SX", "ActorCreated")               --(newActor)                                - Actor.lua
Ext.RegisterModEvent("BG3SX", "AnimationChange")            --(newAnimation)                            - Animation.lua
Ext.RegisterModEvent("BG3SX", "SoundChange")                --(newSound)                                - Sound.lua
Ext.RegisterModEvent("BG3SX", "SceneMove")                  --({scene, oldLocation, newlocation})       - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneSwitchPlacesBefore")    --(scene.actors)                            - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneSwitchPlacesAfter")     --(scene.actors)                            - Scene.lua
Ext.RegisterModEvent("BG3SX", "CameraHeightChange")         --(entity)                                  - Sex.lua
-- [NYI] Ext.RegisterModEvent("BG3SX", "EntityStripped")             --({entity, strippedEquipment, remainingEquipment})    - Actor.lua
Ext.RegisterModEvent("BG3SX", "ActorDressed")               --({actor, equipmentTable})                 - Actor.lua
Ext.RegisterModEvent("BG3SX", "GenitalChange")              --({entity, newGenital})                    - Genital.lua


-- To subscribe to events:
-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Ext.ModEvents.BG3SX.Channel:Subscribe(function (payload) ... end)

-- Example:
-- -----------------------------------------------------------------
-- Ext.ModEvents.BG3SX.SceneInit:Subscribe(function (payload)
--     _P("SceneInit received with PayLoad: ")
--     _D(payload)
-- end)

-- Or check ModEventsTester.lua