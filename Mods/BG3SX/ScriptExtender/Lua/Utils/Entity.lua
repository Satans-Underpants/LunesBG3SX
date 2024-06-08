----------------------------------------------------------------------------------------
--
--                               For handling Entities
--
----------------------------------------------------------------------------------------

Entity = {}
Entity.__index = Entity

-- CONSTRUCTOR
--------------------------------------------------------------


-- VARIABLES
--------------------------------------------------------------

-- key = Entity entity
-- value = Content content
local savedEntities = {}



local visTemplate = TryGetEntityValue(actorEntity, "GameObjectVisual", "RootTemplateId")
local origTemplate = TryGetEntityValue(actorEntity, "OriginalTemplate", "OriginalTemplate")

local lookTemplate = Entity
-- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
-- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
if visTemplate then
    if origTemplate then
        if origTemplate ~= visTemplate then
            lookTemplate = visTemplate
        end
    elseif origTemplate == nil then -- It's Tav?
        -- For Tavs, copy the look of visTemplate only if they are polymorphed or have AppearanceOverride component (under effect of "Appearance Edit Enhanced" mod)
        if Osi.HasAppliedStatusOfType(actorData.Actor, "POLYMORPHED") == 1 or actorEntity.AppearanceOverride then
            lookTemplate = visTemplate
        end
    end
end


-- GETTERS AND SETTERS
--------------------------------------------------------------

--@return savedTables
function Entity:getSavedEntities(entity)
    return savedEntities
end


-- METHODS
--------------------------------------------------------------


function Entity:GetLookTemplate(entity)
    return lookTemplate
end








-- returns entity uuid from userdata
--@param mouseover userdata 
--@return uuid     string
function getUUIDFromUserdata(mouseover)
    local entity = mouseover.Inner.Inner[1].GameObject
    if entity ~= nil then
        return Ext.Entity.HandleToUuid(entity)
    else
        _P("[Utils.lua] - getUUIDFromUserdata(mouseover) - Not an entity!")
    end
end






local function RemoveSexPositionSpells(actor) -- entity
    TryRemoveSpell(actor, "StraightAnimationsContainer")
    TryRemoveSpell(actor, "LesbianAnimationsContainer")
    TryRemoveSpell(actor, "GayAnimationsContainer")
    TryRemoveSpell(actor, "FemaleMasturbationContainer")
    TryRemoveSpell(actor, "MaleMasturbationContainer")
    TryRemoveSpell(actor, "zzzEndSex")
    TryRemoveSpell(actor, "zzzStopMasturbating")
    TryRemoveSpell(actor, "CameraHeight")
    TryRemoveSpell(actor, "ChangeLocationPaired")
    TryRemoveSpell(actor, "ChangeLocationSolo")
    TryRemoveSpell(actor, "zzSwitchPlaces")
end

-- Returns true if actor is playable (a PC or a companion)
function EntityIsPlayable(actor)
    return Osi.IsTagged(actor, "PLAYABLE_25bf5042-5bf6-4360-8df8-ab107ccb0d37") == 1
end

function EntityHasPenis(actor)
    -- If entity is polymorphed (e.g., Disguise Self spell)
    if Osi.HasAppliedStatusOfType(actor, "POLYMORPHED") == 1 then
        -- As of hotfix #17, "Femme Githyanki" disguise has a dick.
        if TryGetEntityValue(actor, "GameObjectVisual", "RootTemplateId") == "7bb034aa-d355-4973-9b61-4d83cf29d510" then
            return true
        end

        return Osi.GetGender(actor, 1) ~= "Female"
    end

    -- Entities seem to have GENITAL_PENIS/GENITAL_VULVA only if they are player chars or companions who can actually join the party.
    -- NPCs never get the tags. "Future" companions don't have them too.
    -- E.g., Halsin in Act 1 has no GENITAL_PENIS, he gets it only when his story allows him to join the active party in Act 2.
    if EntityIsPlayable(actor) then
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


--
function Entity:GetBodyShape(entity)
    local equipmentRace = (entity.ServerCharacter.Template.EquipmentRace)
    for bodyShape, bodyID in pairs(BODYSHAPES) do
        if bodyID == equipmentRace then
            return bodyType
        end
    end
    -- return default value if unknown (modded) bodyshape
    -- _P("[ActorScale.lua] Failed BodyType check on actor: ", actor)
    return BODYSHAPES['HumanMale']
end


-- 
function Entity:GetHeightClass(entityBodyShape)
    for bodyShape, height in pairs(ACTORHEIGHTS) do
        if bodyShape == entityBodyShape then
            return height
        end
    end
    -- return default value if unknown (modded) bodyshape
    -- _P("[ActorScale.lua] Failed Height check on actor: ", entityBodyShape)
    return "Med"
end



-- Copy entity component componentName from srcEntity to dstEntity if it exists.
-- Args:
--     srcEntity, dstEntity: entity object or UUID string.
--     componentName: string name of the component to copy.
-- Returns: true if the component is successfully copied, false if srcEntity does not have componentName component, srcEntity or dstEntity is nil, etc.
function Entity:TryCopyEntityComponent(srcEntity, dstEntity, componentName)
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



-- Get the value of a sub-field in entity if the entity has that sub-field.
-- Args:
--     entity: entity object or UUID string.
--     component, field1, field2, ...: string names of the fields. Any typo in the names results in an error in the SE console.
-- Returns: the value of the sub-field if it exists, otherwise nil.
-- Example:
--     -- Get actor.ServerCharacter.PlayerData.HelmetOption value...
--     TryGetEntityValue(actor, "ServerCharacter", "PlayerData", "HelmetOption")
function Entity:TryGetEntityValue(entity, component, field1, field2, field3)
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


function Entity:HasEquipment(entity)
    if entity.GearSet then
        return true
    end
    return false
end


function Entity:UnequipAll(entity)
    entity.OldArmourSet = Osi.GetArmourSet(entity)
    Osi.SetArmourSet(entity, 1)
    
    local currentEquipment = {}
    for _, slotName in ipairs(STRIP_SLOTS) do
        local gearPiece = Osi.GetEquippedItem(entity, slotName)
        if gearPiece then
            Osi.LockUnequip(gearPiece, 0)
            Osi.Unequip(entity, gearPiece)
            currentEquipment[#currentEquipment+1] = gearPiece
        end
    end
    entity.GearSet = currentEquipment
end

function Entity:Redress(entity, armorSet)
    Osi.SetArmourSet(entity, armorSet)

    for _, item in ipairs(entity.GearSet) do
        Osi.Equip(entity, item)
    end
    entity.GearSet = nil
end