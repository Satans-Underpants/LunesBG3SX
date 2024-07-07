-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Entity Functions ----
------------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)
    if spell == "BG3SX_ToggleStripping" then
        if Osi.HasActiveStatus(target, "BG3SX_ToggleStrippingBlock") then
            Osi.RemoveStatus(target, "BG3SX_ToggleStrippingBlock")
        else
            Osi.ApplyStatus(target, "BG3SX_ToggleStrippingBlock", -1)
        end
    end
end)