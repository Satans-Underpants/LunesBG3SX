
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
        AddMainSexSpells(actor)
        AddGenitalIfHasNone(actor)
    end)

    ------------------------------------------------------------------------------------------------------------------------------------------
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

-- Returns true if actor is playable (a PC or a companion)
function ActorIsPlayable(actor)
    return Osi.IsTagged(actor, "PLAYABLE_25bf5042-5bf6-4360-8df8-ab107ccb0d37") == 1
end

function ActorHasPenis(actor)
    -- If actor is polymorphed (e.g., Disguise Self spell)
    if Osi.HasAppliedStatusOfType(actor, "POLYMORPHED") == 1 then
        -- As of hotfix #17, "Femme Githyanki" disguise has a dick.
        if TryGetEntityValue(actor, "GameObjectVisual", "RootTemplateId") == "7bb034aa-d355-4973-9b61-4d83cf29d510" then
            return true
        end

        return Osi.GetGender(actor, 1) ~= "Female"
    end

    -- Actors seem to have GENITAL_PENIS/GENITAL_VULVA only if they are player chars or companions who can actually join the party.
    -- NPCs never get the tags. "Future" companions don't have them too.
    -- E.g., Halsin in Act 1 has no GENITAL_PENIS, he gets it only when his story allows him to join the active party in Act 2.
    if ActorIsPlayable(actor) then
        if Osi.IsTagged(actor, "GENITAL_PENIS_d27831df-2891-42e4-b615-ae555404918b") == 1 then
            return true
        end

        if Osi.IsTagged(actor, "GENITAL_VULVA_a0738fdf-ca0c-446f-a11d-6211ecac3291") == 1 then
            return false
        end
    end

    -- Fallback for NPCs, "future" companions, etc.
    return Osi.IsTagged(actor, "FEMALE_3806477c-65a7-4100-9f92-be4c12c4fa4f") ~= 1
end

function AddMainSexSpells(actor)
    -- Add "Start Sex" and "Sex Options" spells only if actor is PLAYABLE or HUMANOID or FIEND, and is not a child (KID)
    if (ActorIsPlayable(actor)
        or Osi.IsTagged(actor, "HUMANOID_7fbed0d4-cabc-4a9d-804e-12ca6088a0a8") == 1 
        or Osi.IsTagged(actor, "FIEND_44be2f5b-f27e-4665-86f1-49c5bfac54ab") == 1)
        and Osi.IsTagged(actor, "KID_ee978587-6c68-4186-9bfc-3b3cc719a835") == 0
    then
        TryAddSpell(actor, "StartSexContainer")
        TryAddSpell(actor, "SexOptions")
        TryAddSpell(actor, "Change_Genitals")
        TryAddSpell(actor, "BG3SXOptions")
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

-- Get the value of a sub-field in entity if the entity has that sub-field.
-- Args:
--     entity: entity object or UUID string.
--     component, field1, field2, ...: string names of the fields. Any typo in the names results in an error in the SE console.
-- Returns: the value of the sub-field if it exists, otherwise nil.
-- Example:
--     -- Get actor.ServerCharacter.PlayerData.HelmetOption value...
--     TryGetEntityValue(actor, "ServerCharacter", "PlayerData", "HelmetOption")
function TryGetEntityValue(entity, component, field1, field2, field3)
    local v, doStop
    

    v = ResolveEntityArg(entity)
    if not v then
        return nil
    end

    function GetFieldValue(obj, field)
        if not field then
            return obj, true
        end
        local newObj = obj[field]
        return newObj, (newObj == nil)
    end

    v, doStop = GetFieldValue(v, component)
    if doStop then
        return v
    end

    v, doStop = GetFieldValue(v, field1)
    if doStop then
        return v
    end

    v, doStop = GetFieldValue(v, field2)
    if doStop then
        return v
    end

    v, doStop = GetFieldValue(v, field3)
    return v
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

-- Copy entity component componentName from srcEntity to dstEntity if it exists.
-- Args:
--     srcEntity, dstEntity: entity object or UUID string.
--     componentName: string name of the component to copy.
-- Returns: true if the component is successfully copied, false if srcEntity does not have componentName component, srcEntity or dstEntity is nil, etc.
function TryCopyEntityComponent(srcEntity, dstEntity, componentName)
    -- Find source component
    srcEntity = ResolveEntityArg(srcEntity)
    if not srcEntity then
        return false
    end

    local srcComponent = srcEntity[componentName]
    if not srcComponent then
        return false
    end

    -- Find dest component
    dstEntity = ResolveEntityArg(dstEntity)
    if not dstEntity then
        return false
    end

    local dstComponent = dstEntity[componentName]
    if not dstComponent then
        dstEntity:CreateComponent(componentName)
        dstComponent = dstEntity[componentName]
    end

    -- Copy stuff
    if componentName == "ServerItem" then
        for k, v in pairs(srcComponent) do
            if k ~= "Template" and k ~= "OriginalTemplate" then
                TryToReserializeObject(dstComponent[k], v)
            end
        end
    else
        local serializeResult = TryToReserializeObject(srcComponent, dstComponent)
        if serializeResult then
            -- _P("[BG3SX.lua] TryCopyEntityComponent, component '" .. componentName .. "': serialization fail:")
            -- _P("[BG3SX.lua]     " .. serializeResult)
        end
    end

    if componentName ~= "ServerIconList" and componentName ~= "ServerDisplayNameList" and componentName ~= "ServerItem" then
        dstEntity:Replicate(componentName)
    end

    return true
end
