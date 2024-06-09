----------------------------------------------------------------------------------------
--
--                               For handling Spells
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

Spells = {}
Spells.__index = Spells

-- METHODS
--------------------------------------------------------------

--- Handles the SexSpellUsed Event by starting new animations based on spell used
---@param caster            string          - The casters UUID
---@param target            string          - The targets UUID
---@param animProperties    AnimProperties  - The animation properites to use
function Spells:SexSpellUsed(caster, target, animProperties)
    if animProperties then
        if animProperties["Type"] == "Solo" then
            StartSoloAnimation(caster, animProperties)
        elseif animProperties["Type"] == "Paired" then
            StartPairedAnimation(caster, target, animProperties)
        end
    end
end

--- Adds the main sex spells to an entity
---@param entity    string - The entities UUID
function Spells:AddMainSexSpells(entity)
    -- Add "Start Sex" and "Sex Options" spells only if entity is PLAYABLE or HUMANOID or FIEND, and is not a child (KID)
    if (Entity:IsPlayable(entity)
        or Osi.IsTagged(entity, "HUMANOID_7fbed0d4-cabc-4a9d-804e-12ca6088a0a8") == 1 
        or Osi.IsTagged(entity, "FIEND_44be2f5b-f27e-4665-86f1-49c5bfac54ab") == 1)
        and Osi.IsTagged(entity, "KID_ee978587-6c68-4186-9bfc-3b3cc719a835") == 0
    then
        Osi.AddSpell(entity, "StartSexContainer")
        Osi.AddSpell(entity, "Change_Genitals")
        Osi.AddSpell(entity, "BG3SXOptions")
        -- we switched to another spell
        Osi.RemoveSpell(entity, "SexOptions")
    end
end