

-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Sex Listener ----
-----------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
    -- Checks to see if the name of the spell used matches any of the setup spells in SexAnimations.lua
    -- _P("---------------------StartSexSpell used Whitelist Check---------------------")
    if Data.StartSexSpells[spell] then
        if Entity:IsWhitelisted(caster) and Entity:IsWhitelisted(target) then
            Ext.Timer.WaitFor(200, function() -- Wait for erections
                Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells[spell])
            end)
            Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells[spell]})
        end
    end

end)

Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)  
    -- For changing positions
    if Data.Animations[spell] then
        local scene = Scene:FindSceneByEntity(caster)
        -- _P("[BG3SX SexListeners] Corresponding Animname ", animationData.AnimName)
        scene:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
        Sex:PlayAnimation(caster, Data.Animations[spell])

        Ext.ModEvents.BG3SX.SexAnimationChange:Throw({caster = caster, animData = Data.Animations[spell]})
    end
end)