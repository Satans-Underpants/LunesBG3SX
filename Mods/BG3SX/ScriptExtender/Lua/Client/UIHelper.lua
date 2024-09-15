
UIHelper = {}
UIHelper.__index = UIHelper

-- function adapted from Aahz  https://www.nexusmods.com/baldursgate3/mods/9832

---Gets a table of entity uuid's for current party
---@return table<string>|nil
function UIHelper:GetCurrentParty()
    local party = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
    local partyMembers = {}
    for _,partyMember in pairs(party) do
        local uuid = Ext.Entity.HandleToUuid(partyMember)
        if uuid ~= nil then
            table.insert(partyMembers, uuid)
        end
    end
    return partyMembers
end