    -----------------------------------------------------------------------------------------------------------------------------------------
                                                ---- Entity Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)
        if spell == "BlockStripping" then
            Osi.RemoveStatus(target, "BLOCK_STRIPPING")
            Osi.ApplyStatus(target, "BLOCK_STRIPPING", -1)
        elseif spell == "RemoveStrippingBlock" then
            Osi.RemoveStatus(target, "BLOCK_STRIPPING")
        end
    end)