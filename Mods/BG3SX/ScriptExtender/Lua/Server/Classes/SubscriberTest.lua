---@diagnostic disable: missing-parameter
Event:Subscribe(function(e)
    if e.Channel then
        _P("-------------------EVENT RECIEVED-------------------")
        _P(e.Channel)
        --_D(e.Payload)
    end
end)









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