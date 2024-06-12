-- DEBUG.lua
local DEBUG = {}

-- Function to print debug messages
function DEBUG.print(source, message)
    print("[" .. source .. "] [DEBUG] " .. tostring(message))
end

-- Function to print warnings
function DEBUG.warn(source, message)
    print("[" .. source .. "] [WARNING] " .. tostring(message))
end

-- Function to print errors
function DEBUG.error(source, message)
    print("[" .. source .. "] [ERROR] " .. tostring(message))
end

-- Function to dump tables (data structures)
function DEBUG.dump(source, table, indent)
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