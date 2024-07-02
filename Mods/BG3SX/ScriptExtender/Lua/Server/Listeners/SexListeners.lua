-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Sex Listener ----
-----------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
    -- Checks to see if the name of the spell used matches any of the setup spells in SexAnimations.lua
    for _, spellData in ipairs(STARTSEXSPELLS) do
        if spell == spellData.AnimName then
            Sex:StartSexSpellUsed(caster, {target}, spellData) -- Checks which spell it was and initiates a scene

            -- Ext.Net.BroadcastMessage("BG3SX_SexStartSpellUsed", Ext.Json.Stringify({caster, target, spellData})) -- SE EVENT
            Event:new("BG3SX_SexStartSpellUsed", {caster, target, spellData}) -- MOD EVENT
        end
    end

    -- For changing positions
    for _, animationData in ipairs(ANIMATIONS) do
        if spell == animationData.AnimName then
            Sex:PlayAnimation(caster, animationData)
            
            -- Ext.Net.BroadcastMessage("BG3SX_SexAnimationChange", Ext.Json.Stringify({caster, animationData})) -- SE EVENT
            Event:new("BG3SX_SexAnimationChange", {caster, animationData}) -- MOD EVENT
        end
    end
end)