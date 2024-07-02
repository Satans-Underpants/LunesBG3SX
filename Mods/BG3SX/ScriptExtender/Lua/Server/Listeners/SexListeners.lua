-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Sex Listener ----
-----------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)

    _P("[BG3SX SexListeners] Spell used on target ", spell)

    -- Checks to see if the name of the spell used matches any of the setup spells in SexAnimations.lua
    for _, spellData in pairs(STARTSEXSPELLS) do
        if spell == spellData.AnimName then
            Sex:StartSexSpellUsed(caster, {target}, spellData) -- Checks which spell it was and initiates a scene

            -- Ext.Net.BroadcastMessage("BG3SX_SexStartSpellUsed", Ext.Json.Stringify({caster, target, spellData})) -- SE EVENT
            Event:new("BG3SX_SexStartSpellUsed", {caster, target, spellData}) -- MOD EVENT
            break
        end
    end
end)



Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)  
    _P("[BG3SX SexListeners] Spell used ", spell)
    
    -- For changing positions
    for _, animationData in pairs(ANIMATIONS) do
        if spell == animationData.AnimName then
            _P("[BG3SX SexListeners] Corresponding Animname ", animationData.AnimName)
            Sex:PlayAnimation(caster, animationData)
            
            -- Ext.Net.BroadcastMessage("BG3SX_SexAnimationChange", Ext.Json.Stringify({caster, animationData})) -- SE EVENT
            Event:new("BG3SX_SexAnimationChange", {caster, animationData}) -- MOD EVENT
            break
        end
    end
end)