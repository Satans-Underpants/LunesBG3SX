-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Scene Functions ----
------------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(caster, x, y, z, spell, spellType, spellElement, storyActionID)
    local location = {x,y,z}
    if spell == "BG3SX_ChangeSceneLocation" then
        local scene = Scene:FindSceneByEntity(caster)
        -- Ext.Net.BroadcastMessage("BG3SX_SceneSwitchPlacesBefore", Ext.Json.Stringify({scene.actors})) -- SE EVENT
        Event:new("BG3SX_SceneSwitchPlacesBefore", Ext.Json.Stringify({scene.actors})) -- MOD EVENT

        Scene:MoveSceneToLocation(caster, location)
        Sex:PlayAnimation(caster, scene.currentAnimation) -- Plays the prior to teleport selected animation again

        -- Ext.Net.BroadcastMessage("BG3SX_SceneSwitchPlacesAfter", Ext.Json.Stringify({scene.actors})) -- SE EVENT
        Event:new("BG3SX_SceneSwitchPlacesAfter", Ext.Json.Stringify({scene.actors})) -- MOD EVENT
    end
end)

Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
    if spell == "BG3SX_ChangeCameraHeight" then
        Sex:ChangeCameraHeight(caster)
    end
    
    if spell == "BG3SX_StopAction" then
        local scene = Scene:FindSceneByEntity(caster)
        scene:Destroy()
    end
end)