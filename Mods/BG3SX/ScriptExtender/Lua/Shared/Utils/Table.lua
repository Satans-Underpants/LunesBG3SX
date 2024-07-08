----------------------------------------------------------------------------------------
--
--                               For handling Tables
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

Table = {}
Table.__index = Table


-- METHODS
--------------------------------------------------------------

-- Checks if an item is present in a list.
---@param list  table	- The table to be searched.
---@param item  any		- The item to search for in the table.
---@return      bool    - Returns true if the item is found, otherwise returns false.
function Table:Contains(list, item)
    for i, object in ipairs(list) do
        if object == item then
            return true
        end
    end
    return false
end


-- Helper function to convert a list to a set
---@param list  table   - The list to be converted
---@return 		table	- Set from list
function Table:ListToSet(list)
    local set = {}
    for _, v in ipairs(list) do
        set[v] = true
    end
    return set
end


-- For Maps
-- Get Key by searchItem
function Table:GetKey(map, searchItem)
    for key, object in pairs(map) do
        if object == searchItem then
            return key
        end
    end
    return nil
end
-- For Lists
-- Get Index by searchItem
function Table:GetIndex(list, searchItem)
    for i, object in ipairs(list) do
        if object == searchItem then
            return i
        end
    end
end


-- Measures the true size of a table, considering both sequential and non-sequential keys
---@param table table   - Table to count
---@return      int     - Size of the table
function Table:TableSize(table)
    local count = 0
        for _ in pairs(table) do
        count = count + 1
    end
    return count
end


-- Important METHODS
--------------------------------------------------------------

-- Perform a deep copy of a table - necessary when lifetime expires
---@param orig  table - Original table
---@return      table - Copied table
function Table:DeepCopy(orig)
local copy = {}
    success, iterator = pcall(pairs, orig)
    if success == true and (type(orig) == "table" or type(orig) == "userdata") then

        for label, content in pairs(orig) do

        if content then
            copy[Table:DeepCopy(tostring(label))] = Table:DeepCopy(content)
        else
            copy[Table:DeepCopy(label)] = "nil"
        end

    end

    if copy and (not #copy == 0) then
        setmetatable(copy, Table:DeepCopy(getmetatable(orig)))
    end

    else
        copy = orig
    end
        return copy
end


-- string.find but not case sensitive
---@param str1  string  - String 1 to compare
---@param str2  string  - String 2 to compare
function Table:CaseInsensitiveSearch(str1, str2)
    str1 = string.lower(str1)
    str2 = string.lower(str2)
    local result = string.find(str1, str2, 1, true)
    return result ~= nil
end


-- Concatenate 2 tables into one
---@param t1    table               - First Table
---@param t2    table               - Second Table
---@return 		concatenatedTable   - Returns both Tables as a single new one
function Table:ConcatenateTables(t1, t2)
    local result = {}
    for i = 1, #t1 do
        result[#result + 1] = t1[i]
    end
    for i = 1, #t2 do
        result[#result + 1] = t2[i]
    end
    return result
end


-- Sorts a key, value pair table
---@param data  table - The data table to sort
function Table:SortData(data)
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