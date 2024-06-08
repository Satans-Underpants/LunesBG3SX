----------------------------------------------------------------------------------------
--
--                               For handling Helpers
--
----------------------------------------------------------------------------------------

Helper = {}
Helper.__index = Helper

-- CONSTRUCTOR
--------------------------------------------------------------

-- ---@param name string
-- ---@param parent node
-- ---@param children list
-- ---@param IDContext string
-- ---@param bullet boolean
-- function Node:new(name, parent, children, IDContext, bullet)
--     local instance = setmetatable({
--         name = name,
--         parent = parent,
--         children = children,
--         IDContext = IDContext,
--         bullet = bullet,
--     }, Node)
--     return instance
-- end


-- VARIABLES
--------------------------------------------------------------

-- key = Helper helper
-- value = Content content
local savedHelpers = {}


-- GETTERS AND SETTERS
--------------------------------------------------------------

--@return savedTables
function Helper:getSavedHelpers()
    return savedHelpers
end


-- METHODS
--------------------------------------------------------------

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





--- Retrieves the value of a specified property from an object or returns a default value if the property doesn't exist.
-- @param obj           The object from which to retrieve the property value.
-- @param propertyName  The name of the property to retrieve.
-- @param defaultValue  The default value to return if the property is not found.
-- @return              The value of the property if found; otherwise, the default value.
function GetPropertyOrDefault(obj, propertyName, defaultValue)
    local success, value = pcall(function() return obj[propertyName] end)
    if success then
        return value or defaultValue
    else
        return defaultValue
    end
end

-- Function to clean the prefix and return only the ID
function CleanPrefix(fullString)
    -- Use pattern matching to extract the ID part
    local id = fullString:match(".*_(.*)")
    return id
end



-- Function to check if not all values are false
function NotAllFalse(data)
    for _, value in pairs(data) do
        if value then
            return true
        end
    end
    return false
end




---comment
---@param uuid Guid
---@return Entity?
function _GE(uuid)
    if uuid then
        return Ext.Entity.Get(uuid)
    else
        return nil
    end
end

---comment
---@param entity ItemEntity|CharacterEntity
---@return Guid|nil
function EntityToUuid(entity)
    return Ext.Entity.HandleToUuid(entity)
end



---Try its best to get the RT of something
---@param item GUIDSTRING?
---@return GameObjectTemplate?
function GetRootTemplateData(item)
    if item then
        return Template.GetRootTemplate(GUID(Osi.GetTemplate(item)))
    else
        DFprint("Couldn't get RT for item %s", item)
    end
end


---Clear existing armour visuals to prepare for copy
---@param RT GameObjectTemplate
function ClearVisuals(RT)
    RT.Equipment.Visuals = {}
    RT.Equipment.Slot = {}
    -- entity.ServerItem.Template.Equipment.Visuals = {}
    -- entity.ServerItem.Template.Equipment.Slot = {}
    -- for index, visuals in pairs(entity.ServerItem.Template.Equipment.Visuals) do
    --     entity.ServerItem.Template.Equipment.Visuals[index] = nil
    -- end
end


---Apply visuals from table
---@param RT GameObjectTemplate
---@param table table
---@param slots table
function ApplyVisualsFromTable(RT, table, slots)
    if table and RT then
        for index, subtable in pairs(table) do
            --RT.Equipment.Visuals[index] = Table.DeepCopy(subtable)
            RT.Equipment.Visuals[index] = Table.DeepCopy(subtable)
        end
    end
    if slots and RT then
        for index, slot in pairs(slots) do
            RT.Equipment.Slot[index] = slot
        end
    end
end


---Prints a debug message to the console and logs it if logging is enabled.
---@param content any The content of the error message to be printed and logged.
---@param textColor? number The ANSI color code for the text. Defaults to blue if not provided.
function BasicDebug(content, textColor)
    BasicPrint(content, "DEBUG", textColor)
end


--- Copy visuals from armour source to target
---@param target GUIDSTRING|ItemEntity?
---@param source GUIDSTRING|ItemEntity?
function CopyVisuals(cmd, target, source)


    target = "13f8f1db-bcbc-4689-e8a6-692df7316c11"
    source = "a26572c0-ff16-700a-44bc-000d9388aa8a"
    _P("Target ", target)
    _P("source ", source)
    if not target and not source then return end
    local targetEntity = type(target) == "string" and _GE(target) or target
    local sourceEntity = type(source) == "string" and _GE(source) or source
    ---@cast targetEntity ItemEntity
    ---@cast sourceEntity ItemEntity

    if targetEntity and sourceEntity then
        -- local sourceVisuals = sourceEntity.ServerItem.Template.Equipment.Visuals
        -- local sourceSlots = sourceEntity.ServerItem.Template.Equipment.Slot
        local sourceUUID = EntityToUuid(sourceEntity)
        local sourceRT = GetRootTemplateData(sourceUUID)
        local targetUUID = EntityToUuid(targetEntity)
        local targetRT = GetRootTemplateData(targetUUID)
        local sourceVisuals = sourceRT and sourceRT.Equipment.Visuals
        local sourceSlots = sourceRT and sourceRT.Equipment.Slot

        if targetEntity.ServerItem and targetEntity.ServerItem.Template and sourceVisuals and sourceSlots and targetRT then
            local serializedSourceVisualsCopy = Ext.Types.Serialize(sourceVisuals)
            local serializedSourceSlotsCopy = Ext.Types.Serialize(sourceSlots)
            ClearVisuals(targetRT)
            ApplyVisualsFromTable(targetRT, serializedSourceVisualsCopy, serializedSourceSlotsCopy)
            BasicDebug("Serialized source visuals copy: ")
            BasicDebug(serializedSourceVisualsCopy)
        end
    end
end






function DelayedCall(ms, func, param1, param2)
    if ms == 0 then func(param1, param2) return end
    local Time = 0
    local handler
    handler = Ext.Events.Tick:Subscribe(function(e)
    Time = Time + e.Time.DeltaTime * 1000
    _P(Time)
        if (Time >= ms) then
            _P("Calling function ", func, " ", param1, " ", param2)
            func(param1, param2)
            Ext.Events.Tick:Unsubscribe(handler)
        end
    end)
end