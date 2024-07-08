-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Entity Functions ----
------------------------------------------------------------------------------------------------------------------------------------------
local nonStrippers = {}
Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)
    if spell == "BG3SX_ToggleStripping" then
        if #nonStrippers > 0 then
            for i, nonStripper in ipairs(nonStrippers) do
                if nonStripper == target then
                    table.remove(nonStrippers, i)
                    _P("STRIPPER DETECTED")
                end
            end
        else
            table.insert(nonStrippers, target)
            _P("Added to nonstrippers")
        end
    end
end)
function Sex:GetNonStrippers()
    return nonStrippers
end

-- if Osi.HasActiveStatus(target, "BG3SX_StrippingBlock") == 1 then
--     Osi.RemoveStatus(target, "BG3SX_StrippingBlock")
--     _P("Removed")
-- else
--     _P("applied")
--     Osi.ApplyStatus(target, "BG3SX_StrippingBlock", -1)
-- end