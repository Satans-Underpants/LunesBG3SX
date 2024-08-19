-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Sex Listener ----
-----------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
    -- Checks to see if the name of the spell used matches any of the setup spells in SexAnimations.lua
    if Entity:IsWhitelisted(caster) and Entity:IsWhitelisted(target) then
        for _,spellData in pairs(STARTSEXSPELLS) do
            if spell == spellData.AnimName then
                Ext.Timer.WaitFor(200, function() -- Wait for erections
                    Sex:StartSexSpellUsed(caster, {target}, spellData)
                end)
                
                Ext.ModEvents.BG3SX.SexStartSpellUsed:Throw({caster, target, spellData})
                break
            end
        end
    end
end)

Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)  
    -- For changing positions
    for _, animationData in pairs(ANIMATIONS) do
        if spell == animationData.AnimName then
            local scene = Scene:FindSceneByEntity(caster)
            -- _P("[BG3SX SexListeners] Corresponding Animname ", animationData.AnimName)
            scene:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
            Sex:PlayAnimation(caster, animationData)
    
            Ext.ModEvents.BG3SX.SexAnimationChange:Throw({caster, animationData})
            break
        end
    end
end)