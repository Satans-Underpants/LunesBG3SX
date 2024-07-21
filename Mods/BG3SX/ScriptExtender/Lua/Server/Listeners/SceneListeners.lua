-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Scene Functions ----
------------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(caster, x, y, z, spell, spellType, spellElement, storyActionID)
    local location = {x = x, y = y, z = z}
    if spell == "BG3SX_ChangeSceneLocation" then
        Scene:MoveSceneToLocation(caster, location)
    end

    if spell == "BG3SX_RotateScene" then
        Scene:RotateScene(caster, location)
    end
end)

Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)

    if spell == "BG3SX_SwitchPlaces" then
        -- TODO: Find a way to make this dynamic and not hardcoded to only switch actor[1] and actor[2]
        -- Sex:SwitchPlaces(caster) -- bundle all of this in a new function instead to handle place switching
        local scene = Scene:FindSceneByEntity(caster)
        local savedActor = scene.actors[1]

        Event:new("BG3SX_SceneSwitchPlacesBefore", scene.actors) -- MOD EVENT
        scene.actors[1] = scene.actors[2]
        scene.actors[2] = savedActor
        Event:new("BG3SX_SceneSwitchPlacesAfter", scene.actors) -- MOD EVENT

        scene:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
        Sex:PlayAnimation(caster, scene.currentAnimation)
    end

    if spell == "BG3SX_ChangeCameraHeight" then
        Sex:ChangeCameraHeight(caster)
    end
    
    if spell == "BG3SX_StopAction" then
        local scene = Scene:FindSceneByEntity(caster)
        scene:Destroy()
    end
end)