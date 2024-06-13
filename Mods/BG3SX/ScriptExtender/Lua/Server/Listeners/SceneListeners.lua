    -----------------------------------------------------------------------------------------------------------------------------------------
                                                ---- Scene Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------



    Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(caster, x, y, z, spell, spellType, spellElement, storyActionID)
        local position = {x,y,z}
        if spell == "ChangeSceneLocation" then
            Scene:MoveSceneToLocation(caster, position)
        end
    end)

    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
        if spell == "CameraHeight" then
            Sex:ChangeCameraHeight(caster)
        end
    end)
