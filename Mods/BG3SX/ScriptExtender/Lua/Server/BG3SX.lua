
-- Runs every time a save is loaded --
function OnSessionLoaded()
    ------------------------------------------------------------------------------------------------------------------------------------------
                                                 ---- Setup Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
        local party = Osi.DB_PartyMembers:Get(nil)
        for i = #party, 1, -1 do
            AddMainSexSpells(party[i][1])
            AddGenitalIfHasNone(party[i][1])
        end
    end)


    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(actor)

        if string.find(actor, "CharacterCreationDummy") == nil then
            AddMainSexSpells(actor)
            AddGenitalIfHasNone(actor)
        end
        
    end)


    -----------------------------------------------------------------------------------------------------------------------------------------
                                                ---- Animation Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    -- Typical Spell Use --
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
        -- Checks to see if the name of the spell used matches any of the Spells in the AnimationPacks
        for _, table in ipairs(StartSexSpells) do
            if table.AnimName == spell then
                SexSpellUsed(caster, target, table)
                break
            end
        end
    end)
    
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)
        if spell == "BlockStripping" then
            Osi.RemoveStatus(target, "BLOCK_STRIPPING")  
            Osi.ApplyStatus(target, "BLOCK_STRIPPING", -1)  
        elseif spell == "RemoveStrippingBlock" then
            Osi.RemoveStatus(target, "BLOCK_STRIPPING")  
        end
    end)

    Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(caster, x, y, z, spell, spellType, spellElement, storyActionID)
        if spell == "ChangeLocationPaired" then
            MovePairedSceneToLocation(caster, x,y,z)
        end
        if spell == "ChangeLocationSolo" then
            MoveSoloSceneToLocation(caster, x,y,z)
        end
    end)

    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
        if spell == "CameraHeight" then
            ChangeCameraHeight(caster)
        end
    end)
end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

Ext.Events.GameStateChanged:Subscribe(function(e)
    if e.FromState == "Running" and e.ToState == "Save" then
        TerminateAllSoloAnimations()
        TerminateAllPairedAnimations()
    end
end)

function SexSpellUsed(caster, target, animProperties)
    if animProperties then
        if animProperties["Type"] == "Solo" then
            StartSoloAnimation(caster, animProperties)
        elseif animProperties["Type"] == "Paired" then
            StartPairedAnimation(caster, target, animProperties)
        end
    end
end

function TryAddSpell(actor, spellName)
    if Osi.HasSpell(actor, spellName) == 0 then
        Osi.AddSpell(actor, spellName)
        return true
    end
    return false
end

function TryRemoveSpell(actor, spellName)
    if Osi.HasSpell(actor, spellName) == 1 then
        Osi.RemoveSpell(actor, spellName)
        return true
    end
    return false
end



function AddMainSexSpells(actor)
    -- Add "Start Sex" and "Sex Options" spells only if actor is PLAYABLE or HUMANOID or FIEND, and is not a child (KID)
    if (EntityIsPlayable(actor)
        or Osi.IsTagged(actor, "HUMANOID_7fbed0d4-cabc-4a9d-804e-12ca6088a0a8") == 1 
        or Osi.IsTagged(actor, "FIEND_44be2f5b-f27e-4665-86f1-49c5bfac54ab") == 1)
        and Osi.IsTagged(actor, "KID_ee978587-6c68-4186-9bfc-3b3cc719a835") == 0
    then
        TryAddSpell(actor, "StartSexContainer")
        TryAddSpell(actor, "Change_Genitals")
        TryAddSpell(actor, "BG3SXOptions")
        -- we switched to another spell
        TryRemoveSpell(actor, "SexOptions")
    end
end


-------------------------------------------------------------------------------
          -- ENTITY UTILITIES --
-------------------------------------------------------------------------------

local function ResolveEntityArg(entityArg)
    if entityArg and type(entityArg) == "string" then
        local e = Ext.Entity.Get(entityArg)
        if not e then
            -- _P("[BG3SX.lua] ResolveEntityArg: failed resolve entity from string '" .. entityArg .. "'")
        end
        return e
    end

    return entityArg
end

-- Dump an entity to a text file.
-- Args:
--     entity: entity object or UUID string.
--     outfile: Optional string file name. Ext.IO.SaveFile throws an error if 'outfile' is a full path.
-- If 'outfile' arg is omitted, then the output files gets an auto-generated name with an index: entity1.txt, entity2.txt...
-- The file is created in ...\AppData\Local\Larian Studios\Baldur's Gate 3\Script Extender folder.
local DumpEntityCounter = 1

function DumpEntity(entity, outfile)
    entity = ResolveEntityArg(entity)
    if entity then
        if not outfile then
            outfile = "entity" .. DumpEntityCounter .. ".txt"
            DumpEntityCounter = DumpEntityCounter + 1
        end
        Ext.IO.SaveFile(outfile, Ext.DumpExport(entity:GetAllComponents()))
    end
end

-- Credit: Yoinked from Morbyte (Norbyte?)
function TryToReserializeObject(srcObject, dstObject)
    local serializer = function()
        local serialized = Ext.Types.Serialize(srcObject)
        Ext.Types.Unserialize(dstObject, serialized)
    end

    local ok, err = xpcall(serializer, debug.traceback)
    if not ok then
        return err
    end

    return nil
end