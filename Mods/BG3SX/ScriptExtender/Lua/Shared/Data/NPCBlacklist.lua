Data.NPCBlacklist = { -- Here we just want uuid's of NPCs
    
}

-- Checks if an entity is part of our blacklisted NPC table
---@param uuid string   - UUID of an entity
function Entity:IsBlacklistedNPC(uuid)
    for _,blackListedNPC in pairs (Data.NPCBlacklist) do
        if blackListedNPC == uuid then
            return true
        end
    end
    return false
end