----------------------------------------------------------------------------------------
--
--                               For handling Entities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------
Entity = {}
Entity.__index = Entity


-- Variables
--------------------------------------------------------------


-- METHODS
--------------------------------------------------------------

-- Return Status
-------------------------------

--- Checks if entity is playable (PC or companion)
---@param uuid      string  - The entity UUID to check
---@return          boolean - Returns either 1 or 0
function Entity:IsPlayable(uuid)
    return Osi.IsTagged(uuid, "PLAYABLE_25bf5042-5bf6-4360-8df8-ab107ccb0d37") == 1
end


-- TODO swap out gender check to genital check when Genitals.lua TODO has been completed about giving polymorphed characters genitals
--- Checks if the entity has a penis as genital
---@param uuid      string  - The entity UUID to check
---@return          boolean - Returns either 1 or 0
function Entity:HasPenis(uuid)
    -- If entity is polymorphed (e.g., Disguise Self spell)
    if Osi.HasAppliedStatusOfType(uuid, "POLYMORPHED") == 1 then
        -- As of hotfix #17, "Femme Githyanki" disguise has a dick.
        if Entity:TryGetEntityValue(uuid, "GameObjectVisual", "RootTemplateId") == "7bb034aa-d355-4973-9b61-4d83cf29d510" then
            return true
        end

        return Osi.GetGender(uuid, 1) ~= "Female"
    end

    -- Entities seem to have GENITAL_PENIS/GENITAL_VULVA ONLY if they are player chars or companions who can actually join the party.
    -- NPCs never get the tags. "Future" companions don't have them too.
    -- E.g., Halsin in Act 1 has no GENITAL_PENIS, he gets it only when his story allows him to join the active party in Act 2.
    if Entity:IsPlayable(uuid) then
        if Osi.IsTagged(uuid, "GENITAL_PENIS_d27831df-2891-42e4-b615-ae555404918b") == 1 then
            return true
        end

        if Osi.IsTagged(uuid, "GENITAL_VULVA_a0738fdf-ca0c-446f-a11d-6211ecac3291") == 1 then
            return false
        end
    end

    -- Fallback for NPCs, "future" companions, etc.
    return Osi.IsTagged(uuid, "FEMALE_3806477c-65a7-4100-9f92-be4c12c4fa4f") ~= 1
end


-- Check if an entity has any equipment equipped
---@param uuid      string  - The entity UUID to check
---@return          bool    - Returns either true or false
function Entity:HasEquipment(uuid)
    local entity = Ext.Entity.Get(uuid)
    if entity.GearSet then
        return true
    end
    return false
end


-- Return Component
-------------------------------

--- Get an entities bodyshape
---@param   uuid    string  - The entity uuid to check
---@return          string  - The entities bodyshape UUID | Can be found in EntityScale.lua
function Entity:GetBodyShape(uuid)
    local entity = Ext.Entity.Get(uuid)
    local equipmentRace = (entity.ServerCharacter.Template.EquipmentRace)
    for bodyShape, bodyID in pairs(BODYSHAPES) do
        if bodyID == equipmentRace then
            return bodyShape
        end
    end
    -- return default value if unknown (modded) bodyshape
    -- _P("[ActorScale.lua] Failed BodyType check on actor: ", actor)
    return BODYSHAPES['HumanMale']
end


--- Get the heightclass associated with a given entities bodyshape
---@param   uuid    string      - The entity UUID to check
---@return          HeightClass - The bodyshapes heightclass | Can be found in EntityScale.lua
function Entity:GetHeightClass(uuid)
    local entityBodyShape = Entity:GetBodyShape(uuid)
    for bodyShape, heightclass in pairs(ACTORHEIGHTS) do
        if bodyShape == entityBodyShape then
            return heightclass
        end
    end
    -- return default value if unknown (modded) bodyshape
    -- _P("[ActorScale.lua] Failed Height check on actor: ", entityBodyShape)
    return "Med"
end


-- Functions
-------------------------------

--- func desc
---@param entityArg any
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


--- Tries to copy an entities component to another entity
---@param uuid_1    string          - Source Entities UUID
---@param uuid_2    string          - Target Entities UUID
---@param componentName Component   - Component to copy
function Entity:TryCopyEntityComponent(uuid_1, uuid_2, componentName)
    local srcEntity = Ext.Entity.Get(uuid_1)
    local trgEntity = Ext.Entity.Get(uuid_2)

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
    trgEntity = ResolveEntityArg(trgEntity)
    if not trgEntity then
        return false
    end

    local dstComponent = trgEntity[componentName]
    if not dstComponent then
        trgEntity:CreateComponent(componentName)
        dstComponent = trgEntity[componentName]
    end

    -- Copy stuff
    if componentName == "ServerItem" then
        for k, v in pairs(srcComponent) do
            if k ~= "Template" and k ~= "OriginalTemplate" then
                Helper:TryToReserializeObject(dstComponent[k], v)
            end
        end
    else
        local serializeResult = Helper:TryToReserializeObject(srcComponent, dstComponent)
        if serializeResult then
            -- _P("[BG3SX.lua] TryCopyEntityComponent, component '" .. componentName .. "': serialization fail:")
            -- _P("[BG3SX.lua]     " .. serializeResult)
        end
    end

    if componentName ~= "ServerIconList" and componentName ~= "ServerDisplayNameList" and componentName ~= "ServerItem" then
        trgEntity:Replicate(componentName)
    end

    return true
end


-- Tries to get the value of an entities component
---@param uuid      string      - The entity UUID to check
---@param component Component   - The Component to get the value from
---@param field1    Field       - Field1 to check
---@param field2    Field       - Field2 to check
---@param field3    Field       - Field3 to check
---@return          Value       - Returns the value of a field within a component
---@example
-- local helmetIsInvisible = Entity:TryGetEntityValue(entity, "ServerCharacter", "PlayerData", "HelmetOption")
-- print(helmetIsInvisible) -- Should return either 0 or 1
-- This is all akin to doing Ext.Entity.Get(entity).ServerCharacter.PlayerData.HelmetOption
function Entity:TryGetEntityValue(uuid, component, field1, field2, field3)
    local entity = Ext.Entity.Get(uuid)
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


-- Unequips all equipment and armour (vanity slots) from an entity
---@param uuid  string  - The entity UUID to unequip
function Entity:UnequipAll(uuid)
    local entity = Ext.Entity.Get(uuid)
    entity.OldArmourSet = Osi.GetArmourSet(entity)
    Osi.SetArmourSet(entity, 1)
    
    local currentEquipment = {}
    for _, slotName in ipairs(EQ_SLOTS) do
        local gearPiece = Osi.GetEquippedItem(entity, slotName)
        if gearPiece then
            Osi.LockUnequip(gearPiece, 0)
            Osi.Unequip(entity, gearPiece)
            currentEquipment[#currentEquipment+1] = gearPiece
        end
    end
    entity.GearSet = currentEquipment
end


-- Re-equips all equipment of an entity
---@param uuid      string      - The entity UUID to equip
---@param armorset  ArmorSet    - The entities prior armorset
function Entity:Redress(uuid, armorSet)
    local entity = Ext.Entity.Get(uuid)

    Osi.SetArmourSet(entity, armorSet)

    for _, item in ipairs(entity.GearSet) do
        Osi.Equip(entity, item)
    end
    entity.GearSet = nil
end


-- Scales the entity
---@param uuid  string  - The entity UUID to scale
---@param value float   - The value to increase or decrease the entity scale with
function Entity:Scale(uuid, value)
    uuid.GameObjectVisual.Scale = value
    uuid:Replicate("GameObjectVisual")
end

--- func desc
---@param uuid  string  - The entity UUID to purge bodyscale statuses from
function Entity:PurgeBodyScaleStatuses(entity)
    local result = false

    if entity.CameraScaleDown then
        -- Need to purge all statuses affecting the body scale that could expire during sex,
        -- especially if we're going to scale the body down to bring the camera closer.
        for _, status in ipairs(BODY_SCALE_STATUSES) do
            if Osi.HasAppliedStatus(entity, status) == 1 then
                local statusToRemove = status
                if status == "MAG_GIANT_SLAYER_LEGENDARY_ENLRAGE" then
                    statusToRemove = "ALCH_ELIXIR_ENLARGE"
                end
                Osi.RemoveStatus(entity, statusToRemove, "")
                result = true
            end
        end
    end

    return result
end