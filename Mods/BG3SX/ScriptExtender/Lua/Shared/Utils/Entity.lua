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

local availableAnimations = {}

-- METHODS
--------------------------------------------------------------

-- Sets an entities available custom animations
---@param uuid      string  - The entity UUID to check
function Entity:SetAvailableAnimations(uuid, animations)
    availableAnimations[uuid] = animations
end

-- Returns an entities available animations
---@param uuid      string  - The entity UUID to check
---@return          table   - Returns a saved table of animations
function Entity:GetAvailableAnimations(uuid)
    return availableAnimations[uuid]
end


-- Entity Movement
-----------------------------

-- Blocks the actors movement
---@param entity string  - uuid of entity
function Entity:ToggleMovement(entity)
    if Osi.HasAppliedStatus(entity, "ActionResourceBlock(Movement)") == 1 then
        Osi.RemoveBoosts(entity, "ActionResourceBlock(Movement)", 0, "", "")
    else
        Osi.AddBoosts(entity, "ActionResourceBlock(Movement)", "", "")
    end
end


-- Toggles WalkTrough
---@param entity string  - uuid of entity
function Entity:ToggleWalkThrough(entity)
    if Osi.HasAppliedStatus(entity, "CanWalkThrough(true)") then
        Osi.AddBoosts(entity, "CanWalkThrough(false)", "", "")
    else
        Osi.AddBoosts(entity, "CanWalkThrough(true)", "", "")
    end
end


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
        if Entity:TryGetEntityValue(uuid, nil, {"GameObjectVisual", "RootTemplateId"}) == "7bb034aa-d355-4973-9b61-4d83cf29d510" then
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
    if Entity:GetEquipment(uuid) then
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
    -- Return default value if unknown (modded) bodyshape
    return "Med"
end


-- NPCs don't have CharacterCreationStats
function Entity:IsNPC(uuid)
    local E = Helper:GetPropertyOrDefault(Ext.Entity.Get(uuid),"CharacterCreationStats", nil)
    if E then
        return false
    else
        return true
    end
end


-- Functions
-------------------------------

-- TODO: Description
---@param entityArg any
local function resolveEntityArg(entityArg)
    if entityArg and type(entityArg) == "string" then
        local e = Ext.Entity.Get(entityArg)
        if not e then
            -- _P("[BG3SX][Entity.lua] resolveEntityArg: failed resolve entity from string '" .. entityArg .. "'")
        end
        return e
    end

    return entityArg
end


--- Tries to copy an entities component to another entity
---@param uuid_1    string          - Source Entities UUID
---@param uuid_2    string          - Target Entities UUID
---@param componentName string      - Component to copy
function Entity:TryCopyEntityComponent(uuid_1, uuid_2, componentName)
    local srcEntity = Ext.Entity.Get(uuid_1)
    local trgEntity = Ext.Entity.Get(uuid_2)

    -- Find source component
    srcEntity = resolveEntityArg(srcEntity)
    if not srcEntity then
        return false
    end
    local srcComponent = srcEntity[componentName]
    if not srcComponent then
        return false
    end

    -- Find dest component or create if not existing
    trgEntity = resolveEntityArg(trgEntity)
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
            _P("[BG3SX][Entity.lua] - TryCopyEntityComponent, with component: " .. componentName)
            _P("[BG3SX][Entity.lua] - Serialization fail")
            _P("[BG3SX][Entity.lua] - Result: " .. serializeResult)
            return false
        end
    end

    if componentName ~= "ServerIconList" and componentName ~= "ServerDisplayNameList" and componentName ~= "ServerItem" then
        trgEntity:Replicate(componentName)
    end

    return true
end


-- TODO: Remove this old function
-- Tries to get the value of an entities component
---@param uuid      string      - The entity UUID to check
---@param component Component   - The Component to get the value from
---@param field1    Field       - Field1 to check
---@param field2    Field       - Field2 to check
---@param field3    Field       - Field3 to check
---@return          Value       - Returns the value of a field within a component
---@example
-- local helmetIsInvisible = Entity:TryGetEntityValue(entity, "ServerCharacter", "PlayerData", "HelmetOption")
-- _P(helmetIsInvisible) -- Should return either 0 or 1
-- Its essentially like using Ext.Entity.Get(entity).ServerCharacter.PlayerData.HelmetOption
-- function Entity:TryGetEntityValue(uuid, component, field1, field2, field3)
--     local entity = Ext.Entity.Get(uuid)
--     local v, doStop
    
--     v = resolveEntityArg(entity)
--     if not v then
--         return nil
--     end

--     function GetFieldValue(obj, field)
--         if not field then
--             return obj, true
--         end
--         local newObj = obj[field]
--         return newObj, (newObj == nil)
--     end

--     v, doStop = GetFieldValue(v, component)
--     if doStop then
--         return v
--     end

--     v, doStop = GetFieldValue(v, field1)
--     if doStop then
--         return v
--     end

--     v, doStop = GetFieldValue(v, field2)
--     if doStop then
--         return v
--     end

--     v, doStop = GetFieldValue(v, field3)
--     return v
-- end


-- Tries to get the value of an entities component
---@param uuid                  string      - The entity UUID to check
---@param previousComponent     value       - component of previous iteration
---@param components            table       - Sorted list of component path
---@return                      Value       - Returns the value of a field within a component
---@example
-- Entity:TryGetEntityValue("UUID", nil, {"ServerCharacter, "PlayerData", "HelmetOption"})
-- nil as previousComponent on first call because it iterates over this parameter during recursion
function Entity:TryGetEntityValue(uuid, previousComponent, components)
    local entity = Ext.Entity.Get(uuid)
    if #components == 1 then -- End of recursion
        if not previousComponent then
            local value = Helper:GetPropertyOrDefault(entity, components[1], nil)
            return value
        else
            local value = Helper:GetPropertyOrDefault(previousComponent, components[1], nil)
            return value
        end
    end

    local currentComponent
    if not previousComponent then -- Recursion
        currentComponent = Helper:GetPropertyOrDefault(entity, components[1], nil)
        -- obscure cases
        if not currentComponent then
            return nil
        end
    else
        currentComponent = Helper:GetPropertyOrDefault(previousComponent, components[1], nil)
    end

    table.remove(components, 1)

    -- Return the result of the recursive call
    return Entity:TryGetEntityValue(uuid, currentComponent, components)
end


-- Unequips all equipment from an entity
---@param uuid          string  - The entity UUID to unequip
---@return oldEquipment table   - Collection of every previously equipped item
function Entity:UnequipAll(uuid)
    Osi.SetArmourSet(uuid, 0)
    
    local oldEquipment = {}
    for _, slotName in ipairs(EQ_SLOTS) do
        local gearPiece = Osi.GetEquippedItem(uuid, slotName)
        if gearPiece then
            Osi.LockUnequip(gearPiece, 0)
            Osi.Unequip(uuid, gearPiece)
            oldEquipment[#oldEquipment+1] = gearPiece
        end
    end
    return oldEquipment
end

-- Gets a table of equipped items
---@param uuid              string  - The entity UUID to unequip
---@return currentEquipment table   - Collection of every equipped items
function Entity:GetEquipment(uuid)    
    local currentEquipment = {}
    for _, slotName in ipairs(EQ_SLOTS) do
        local gearPiece = Osi.GetEquippedItem(uuid, slotName)
        if gearPiece then
            currentEquipment[#currentEquipment+1] = gearPiece
        end
    end
    return currentEquipment
end


-- Re-equips all equipment of an entity
---@param entity      string      - The entity UUID to equip
---@param armorset  ArmorSet    - The entities prior armorset
function Entity:Redress(entity, oldArmourSet, oldEquipment)
    Osi.SetArmourSet(entity, oldArmourSet)
    for _, item in ipairs(oldEquipment) do
        Osi.Equip(entity, item)
    end
    oldArmourSet = nil
    oldEquipment = nil
end


-- Scales the entity
---@param uuid  string  - The entity UUID to scale
---@param value float   - The value to increase or decrease the entity scale with
function Entity:Scale(uuid, value)
    local entity = Ext.Entity.Get(uuid)
    if entity.GameObjectVisual then  -- Safeguard against someone trying scale Scenery NPCs
        entity.GameObjectVisual.Scale = value
        entity:Replicate("GameObjectVisual")
    end
end


-- TODO: Save them and reapply them back when a scene is destroyed
-- Removes any random status effects an eneity might have that manipulate scaling
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


-- Bodytype/race specific animations
--------------------------------------------------------------

-- returns bodytype and bodyshape of entity
--@param character string - uuid
--@param bt int           - bodytype  [0,1]
--@param bs int           - bodyshape [0,1]
local function getBody(character)

    -- Get the properties for the character
    local E = Helper:GetPropertyOrDefault(Ext.Entity.Get(character),"CharacterCreationStats", nil)
    local bt =  Ext.Entity.Get(character).BodyType.BodyType
    local bs = 0

    if E then
        bs = E.BodyShape
    end

    return bt, bs

end


-- returns the cc bodytype based on entity bodytype/bodyshape
--@param bodytype  int   - 0 or 1
--@param bodyshape int   - 0 or 1
--@param cc_bodytype int - [1,2,3,4]
local function getCCBodyType(bodytype, bodyshape)
    for _, entry in pairs(CC_BODYTYPE) do
        if (entry.type == bodytype) and (entry.shape == bodyshape) then
            return entry.cc
        end 
    end
end


-- returns race of character - if modded, return human
--@param character string - uuid
--@return race     string - uuid
local function getRace(character)

    local raceTags = Ext.Entity.Get(character):GetAllComponents().ServerRaceTag.Tags

    local race
    for _, tag in pairs(raceTags) do
        if RACETAGS[tag] then
            race = GetKey(RACES, RACETAGS[tag])
            break
        end
    end

    -- fallback for modded races - mark them as humanoid
    if not RACES[race] then
        race = "0eb594cb-8820-4be6-a58d-8be7a1a98fba"
    end

    return race

end


-- use a helper object and Osi to make an entity rotate
---@param uuid string
---@return helper uuid - Helper object that the entity can later look towards with Osi.SteerTo
function Entity:SaveEntityRotation(uuid)

    local entityPosition = {}
    entityPosition.x,entityPosition.y,entityPosition.z = Osi.GetPosition(uuid)
    local entityRotation = {}
    entityRotation.x,entityRotation.y,entityRotation.z = Osi.GetRotation(uuid)
    local entityDegree = Math:DegreeToRadian(entityRotation.y)

    local distanceAwayFromEntity = 1 -- Can be changed
    local x = entityPosition.x + (distanceAwayFromEntity * math.cos(entityDegree))
    local y = entityPosition.y + (distanceAwayFromEntity * math.sin(entityDegree))
    local z = entityPosition.z

    -- Creates and returns the helper object spawned at a distance based on entity rotation to store it to later steer towards
    local helper = Osi.CreateAt("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", x, y, z, 0, 0, "")
    return helper
end

-- Finds the angle degree of an entity based on position difference to a target
---@param entity string - The entities uuid
---@param target string - The targets uuid
function Entity:FindAngleToTarget(entity, target)
    local entityPos = {}
    local targetPos = {}
    entityPos.y, entityPos.x,entityPos.z = Osi.GetPosition(entity)
    targetPos.y, targetPos.x,targetPos.z = Osi.GetPosition(target)
    local dif = {
        y = entityPos.y - targetPos.y,
        x = entityPos.x - targetPos.x,
        z = entityPos.z - targetPos.z,  
    }
    local degree = math.atan(dif.y, dif.x)
    return degree
end

-- use a helper object and Osi to make an entity rotate
---@param entity uuid
---@param helper uuid - helper object 
function Entity:RotateEntity(uuid, helper)
    Osi.SteerTo(uuid, helper, 1)
end


-- Transcribed from LaughingLeader
-- Written by Focus
-- Updated to actually work by Skiz
-- Clears an entities action queue
---@param character any
function Entity:ClearActionQueue(character)
    Osi.FlushOsirisQueue(character)
    Osi.CharacterMoveTo(character, character, "Walking", "")
end

-- Toggles companions moving back to their camp positions or staying put
---@param entity any
function Entity:ToggleCampFlag(entity)
    if Osi.GetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity) == 1 then
        Osi.ClearFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity)
    else
        Osi.SetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity, 0,0)
    end
end
function Entity:HasCampFlag(entity)
    if Osi.GetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity) == 1 then
        return true
    end
end


function Entity:CopyDisplayName(entityToCopyFrom, targetEntity)
    local name = Osi.GetDisplayName(entityToCopyFrom)
    local trName = Ext.Loca.GetTranslatedString(name)
    Osi.SetStoryDisplayName(targetEntity, trName)
end


-- Returns the allowed animations for a character (based on whether they are an Origin, bodytype [and maybe race - waiting for test results])
---@param character any
local function getAllowedAnimations(character)
    -- General works for everyone. Origins get their special ones + general
    -- Everyone else gets General

    local allowedAnimations
    local generics = ANIMATIONS["any"]

    -- Origin animations
    for uuid, animationList in pairs(ANIMATIONS) do
        if uuid == character then
            allowedAnimations = Concat(generics, animationList)
        end
    end

    -- Tavs etc
    if allowedAnimations == nil then
        allowedAnimations = generics
    end


    local bt, bs = getBody(character)
    local cc_bodytype = getCCBodyType(bt, bs)
    local race = getRace(character)

    -- some animations are bodytype & race locked
    if prayingAllowed(cc_bodytype, race) then
        allowedAnimations = Concat(allowedAnimations, ANIMATIONS["pray"])
    end

    if thinkingAllowed(cc_bodytype, race) then
        allowedAnimations = Concat(allowedAnimations, ANIMATIONS["think"])
    end

    return allowedAnimations

end




-- gives shapeshifted entity a visual (like CCAV)
-- character string - UUID
-- visual string    - UUID
function Entity:GiveShapeshiftedVisual(character, visual)

    
    entity = Ext.Entity.Get(character)        

    -- usually this component never exists. AAE creates one too
    if (not Entity.AppearanceOverride) then
        entity:CreateComponent("AppearanceOverride") -- instead iof timers subscribe to entity component
    end
        
    visuals = {}
    -- Eralyne figured out that type has to be 2 for changes to be visible.
    -- We do not know why
    entity.GameObjectVisual.Type = 2

    _P("Overriding visuals of ", character)

    for _, entry in pairs(entity.AppearanceOverride.Visual.Visuals) do
        _P("inserting ", visual)
        table.insert(visuals,entry)
    end



    visuals = {visual}


    _P("visuals to be added ")
    _D(visuals)



    _P("Visuals before adding")
    _D(entity.AppearanceOverride.Visual.Visuals)

   
    table.insert(visuals, visual)
    entity.AppearanceOverride.Visual.Visuals = visuals
    entity:Replicate("AppearanceOverride")
    entity:Replicate("GameObjectVisual") 

    _P("Visuals after adding")
    _D(entity.AppearanceOverride.Visual.Visuals)


    
end

