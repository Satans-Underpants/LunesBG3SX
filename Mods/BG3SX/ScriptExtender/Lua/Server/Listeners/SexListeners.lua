  -----------------------------------------------------------------------------------------------------------------------------------------
                                                ---- Sex Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    -- Typical Spell Use --
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
        -- Checks to see if the name of the spell used matches any of the setup spells in SexAnimations.lua
        for _, table in ipairs(StartSexSpells) do
            if table.AnimName == spell then
                Sex:SexSpellUsed(caster, target, table) -- Checks which spell it was and initiates a scene
                break
            end
        end
    end)