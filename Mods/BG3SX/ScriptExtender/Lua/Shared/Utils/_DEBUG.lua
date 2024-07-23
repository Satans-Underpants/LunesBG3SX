-- UNUSED ChatGPT stuff
-- TODO: Create proper debug class

local DEBUG = {}

-- Function to print debug messages
---@param source    string  - The file it comes from
---@param message   string  - The message to print
function DEBUG:_P(source, message)
    _P("[" .. source .. "] [DEBUG] " .. tostring(message))
end

-- Function to print warnings
---@param source    string  - The file it comes from
---@param message   string  - The message to print
function DEBUG:warn(source, message)
    _P("[" .. source .. "] [WARNING] " .. tostring(message))
end

-- Function to print errors
---@param source    string  - The file it comes from
---@param message   string  - The message to print
function DEBUG:error(source, message)
    _P("[" .. source .. "] [ERROR] " .. tostring(message))
end

-- Function to dump tables (data structures)
---@param source    string  - The file it comes from
---@param table     table   - The table to dump
function DEBUG:dump(source, table, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\n"
    indent = indent + 2 
    for k, v in pairs(table) do
        toprint = toprint .. string.rep(" ", indent)
        if type(v) == "table" then
            toprint = toprint .. k .. " = " .. DEBUG.dump(source, v, indent + 2) .. "\n"
        else
            toprint = toprint .. k .. " = " .. tostring(v) .. "\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return "[" .. source .. "] [DUMP] " .. toprint
end

return DEBUG