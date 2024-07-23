----------------------------------------------------------------------------------------
--
--                               For handling Helpers
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

Helper = {}
Helper.__index = Helper

-- Options
--------------------------------------------------------------

-- Options for stringifying
STRINGIFY_OPTIONS = {
    StringifyInternalTypes = true,
    IterateUserdata = true,
    AvoidRecursion = true
    }

-- METHODS
--------------------------------------------------------------

-- TODO: Check if that even works
-- Generates a new UUID
function Helper:GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end


-- Checks if a number is even
---@param n int - The number to check
---@example
-- for i = 1, 10 do
--    if isEven(i) then
--        _P(i .. " is even")
--    else
--        _P(i .. " is odd")
--    end
-- end
function Helper:isEven(n)
    return n % 2 == 0
end


-- Checks if a number is odd
---@param n int - The number to check
function Helper:isOdd(n)
    return n % 2 ~= 0
end


--Credit: Yoinked from Morbyte (Norbyte?)
-- TODO: Description
---@param srcObject any
---@param dstObject any
function Helper:TryToReserializeObject(srcObject, dstObject)
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


-- Function to clean the prefix and return only the ID
---@return string   - UUID
function Helper:CleanPrefix(fullString)
    -- Use pattern matching to extract the ID part
    local id = fullString:match(".*_(.*)")
    return id
end


-- Function to check if not all values are false
function Helper:NotAllFalse(data)
    for _, value in pairs(data) do
        if value then
            return true
        end
    end
    return false
end


-- Checks if the substring 'sub' is present within the string 'str'.
---@param str string 	- The string to search within.
---@param sub string 	- The substring to look for.
---@return bool			- Returns true if 'sub' is found within 'str', otherwise returns false.
function Helper:StringContains(str, sub)
    -- Make the comparison case-insensitive
    str = str:lower()
    sub = sub:lower()
    return (string.find(str, sub, 1, true) ~= nil)
end


-- Retrieves the value of a specified property from an object or returns a default value if the property doesn't exist.
---@param obj           - The object from which to retrieve the property value.
---@param propertyName  - The name of the property to retrieve.
---@param defaultValue  - The default value to return if the property is not found.
---@return value        - The value of the property if found; otherwise, the default value.
function Helper:GetPropertyOrDefault(obj, propertyName, defaultValue)
    local success, value = pcall(function() return obj[propertyName] end)
    if success then
        return value or defaultValue
    else
        return defaultValue
    end
end


-- Creates a helper object to later find a position with
---@param uuid  string  - The UUID to create a Marker for
---@return      entity  - The Marker entity (invisible, save with a new name or in a table to use)
function Helper:CreateLocationMarker(uuid)
    local Marker = {}
    Marker.x, Marker.y, Marker.z = Osi.GetPosition(uuid)
    -- returns GUIDstring
    Marker.obj = Osi.CreateAtObject("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", uuid, 1, 0, "", 1)
    return Marker
end


-- Destroys a marker
---@param marker    string  - The Marker UUID to destroy 
function Helper:DestroyMarker(marker)
    Osi.RequestDelete(marker)
end


-- Credit to FallenStar  https://github.com/FallenStar08/SharedCode
-- Slightly modified version
---@return goodies  - Table of all summons, avatars and Origins
function Helper:GetEveryoneThatIsRelevant()
    local goodies = {}
    local avatarsDB = Osi.DB_Avatars:Get(nil)
    local originsDB = Osi.DB_Origins:Get(nil)
    local summonsDB = Osi.DB_PlayerSummons:Get(nil)

    for _, avatar in pairs(avatarsDB) do
        goodies[#goodies + 1] = avatar[1]
    end

    for _, origin in pairs(originsDB) do
        goodies[#goodies + 1] = origin[1]
    end

    for _, summon in pairs(summonsDB) do
        goodies[#goodies + 1] = summon[1]
    end

    return goodies
end


-- Returns a table of all summons/followers
---@return PlayerSummons    - Table of player summons
function Helper:GetPlayerSummons()
    return Osi.DB_PlayerSummons:Get(nil)
end