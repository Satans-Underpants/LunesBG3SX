    -----------------------------------------------------------------------------------------------------------------------------------------
                                                ---- Entity Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)
        if spell == "BlockStripping" then
            Osi.RemoveStatus(target, "BG3SX_BlockStripping")
            Osi.ApplyStatus(target, "BG3SX_BlockStripping", -1)
        elseif spell == "RemoveStrippingBlock" then
            Osi.RemoveStatus(target, "BG3SX_BlockStripping")
        end
    end)