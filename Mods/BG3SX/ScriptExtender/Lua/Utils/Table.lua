----------------------------------------------------------------------------------------
--
--                               For handling Tables
--
----------------------------------------------------------------------------------------

Table = {}
Table.__index = Table

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

-- key = Table table
-- value = Content content
local savedTables = {}


-- GETTERS AND SETTERS
--------------------------------------------------------------

--@return savedTables
function Table:getSavedTables()
    return savedTables
end


-- METHODS
--------------------------------------------------------------























--------------------------------------------------------------------------------------
--
--
--                                      USEFUL FUNCTIONS
--                 
--
---------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--                                      CONSTANTS
---------------------------------------------------------------------------------------------

-- Options for stringifying
STRINGIFY_OPTIONS = {
    StringifyInternalTypes = true,
    IterateUserdata = true,
    AvoidRecursion = true
    }

--------------------------------------------------------------------------------------------
--                                      METHODS
---------------------------------------------------------------------------------------------

-- Measures the true size of a table, considering both sequential and non-sequential keys
-- @param table table    -       table to count
-- @return int           -       size of the table
function TableSize(table)
    local count = 0
        for _ in pairs(table) do
        count = count + 1
    end
    return count
end


-- Perform a deep copy of a table - necessary when lifetime expires
--@param    orig table - orignial table
--@return   copy table - copied table
function DeepCopy(orig)
local copy = {}

    success, iterator = pcall(pairs, orig)
    if success == true and (type(orig) == "table" or type(orig) == "userdata") then

        for label, content in pairs(orig) do

        if content then
            copy[DeepCopy(tostring(label))] = DeepCopy(content)
        else
            copy[DeepCopy(label)] = "nil"
        end

    end

    if copy and (not #copy == 0) then
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    end

    else
        copy = orig
    end
        return copy
end


-- string.find but not case sensitive
--@param str1 string       - string 1 to compare
--@param str2 string       - string 2 to compare
function CaseInsensitiveSearch(str1, str2)
    str1 = string.lower(str1)
    str2 = string.lower(str2)
    local result = string.find(str1, str2, 1, true)
    return result ~= nil
end



-- TODO: concatenate function (copy from DOLL)
function Concat(tab1, tab2)

end




-- sorts a key, value pair table
function SortData(data)

    if type(data) == "table" or type(data) == "userdata" then
        local array = {}

        for key, value in pairs(data)do
        table.insert(array, {key = key, value = value})
        end

        table.sort(array, function(a, b)
            -- Convert keys to numbers for comparison
            local keyA, keyB = tonumber(a.key), tonumber(b.key)
            -- If conversion is successful, compare numerically
            if keyA and keyB then
                return keyA < keyB
            else
                -- If conversion fails, compare as strings
                return a.key < b.key
            end
        end)

        return array, data
    else
        return data, data
    end
end