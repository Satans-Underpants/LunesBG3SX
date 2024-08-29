----------------------------------------------------------------------------------------------------
-- 
--                        NPC Stripping/Redressing and Genital Application/Removal
-- 
----------------------------------------------------------------------------------------------------

-- USE Entity:IsPlayable TO CHECK IF PLAYABLE

----------------------------------------------------------------------------------------------------
-- 
-- 									Shorthands and Helpers
-- 
----------------------------------------------------------------------------------------------------

-- TODO: See if we can reuse a bunch of Entity: functions
-- TODO - helper functions to UTILS

-- Remove a slot form VisualResources
---@param       - items: list of current items in the slots
---@param       - slotsToRemove (set)
---@return       - the modified Slot (table)
local function removeItemsBySlots(items, slotsToRemove)
    local newItems = {}
    for _, item in ipairs(items) do
        if not slotsToRemove[item.Slot] then
            table.insert(newItems, item)
        end
    end
    return newItems
end


----------------------------------------------------------------------------------------------------
-- 
-- 							    		XML Handling
-- 				     read information saved in xml files from game
-- 
----------------------------------------------------------------------------------------------------

 -- Map of uuids and their original ResourceVisual Templates
local OriginalTemplates = {}


 -- get VisualResourceID from uuid
 -- @param            - uuid of the NPC
 ---return            - VisualResourceID
local function getVisualResourceID(uuid)
   local vrID = Ext.Entity.Get(uuid).ServerCharacter.Template.CharacterVisualResourceID
   return vrID
end


 -- get Slots (contain body, hair, gloves, tails etc.)
 -- serialize them because else they expire
 -- @param           - uuid of the NPC
 ---return           - Slots (Table)
local function serializeVisualSetSlots(uuid)
    local visualSet = Ext.Resource.Get(getVisualResourceID(uuid), "CharacterVisual").VisualSet.Slots
    local serializedSlots = {}
    for _, slot in ipairs(visualSet) do
        -- Only copy the data you need, and ensure it's in a Lua-friendly format
        table.insert(serializedSlots, {Bone = slot.Bone, Slot = slot.Slot, VisualResource = slot.VisualResource})
    end
    return serializedSlots
end


 -- save Slots (contain body, hair, gloves, tails etc.)
 -- @param           - uuid of the NPC
 ---return           - Slots (Table)
local function saveVisualSet_Slots(uuid)
    local slots = serializeVisualSetSlots(uuid)
    local entry = {uuid = uuid, slots = slots}
    table.insert(OriginalTemplates, entry)
end



 -- get a Slot for the naked NPC [race dependant]
 -- @param           - uuid of the NPC
 ---return           - Slots (Table)
local function getNakedTemplate(uuid)
    local currentTemplate = serializeVisualSetSlots(uuid)

    -- list of slots to be removed 
    -- TODO add when necessary as there does not seem to be a list 
    local TOBEREMOVED = {
        ["Footwear"] = true,
        ["Body"] = true,
        ["Gloves"] = true,
        ["Cloak"] = true,
        ["Underwear"] = true
    }
    local newTemplate = removeItemsBySlots(currentTemplate, TOBEREMOVED)
    return newTemplate

end

----------------------------------------------------------------------------------------------------
-- 
-- 								    	Transformations
-- 
----------------------------------------------------------------------------------------------------

-- Strip the NPC -> exchange/Delete Slots
---@param uuid  string  -UUID of NPC
local function stripNPC(uuid)
    local naked = getNakedTemplate(uuid)
    local resource = getVisualResourceID(uuid)
    Ext.Resource.Get(resource,"CharacterVisual").VisualSet.Slots = naked

    local payload = {naked = naked, resource = resource}
    Ext.ModEvents.BG3SX.NPCStrip:Throw(payload)
end


-- Redress the NPC (give original template)
---@param uuid  string  -UUID of NPC
---@return           - list of player uuids 
local function redress(uuid)
    local dressed
    for _,entry in pairs(OriginalTemplates) do
        if entry.uuid == uuid then
            dressed = entry.slots
            local resource = getVisualResourceID(uuid)
            Ext.Resource.Get(resource,"CharacterVisual").VisualSet.Slots = dressed
            table.remove(OriginalTemplates, Table:GetIndex(OriginalTemplates, entry))

            local payload = {dressed = dressed, resource = resource}
            Ext.ModEvents.BG3SX.NPCDress:Throw(payload)
            return
        end
    end
end


----------------------------------------------------------------------------------------------------
--  
-- 								    	Genitals
-- 
----------------------------------------------------------------------------------------------------

-- TODO - add support for saving favourite genitals

-- give NPCs genitals
-- @param           - uuid of the NPC
local function giveGenitals(uuid)
    local spells = {"BG3SX_VanillaVulva", "BG3SX_VanillaFlaccid"}
    local spell

    -- Create Slot for genitals
    Ext.Entity.Get(uuid):CreateComponent("CharacterCreationAppearance")
    -- 0 = penis, 1 = vagina [This assumes that everyone is cis]
    local bodyType =  Ext.Entity.Get(uuid).BodyType.BodyType
    if bodyType == 1 then
        spell = spells[1]
    else
        spell = spells[2]
    end

    -- Transform genitals
    local newGenital = Genital:GetNextGenital(spell, uuid)
    Osi.AddCustomVisualOverride(uuid, newGenital)
end


-- Remove the genital
-- @param           - uuid of the NPC
local function removeGenitals(uuid)
    local genital = Genital:GetCurrentGenital(uuid)
    Osi.RemoveCustomVisualOvirride(uuid, genital) 
end


-- TODO: function giveHair for helmet havers
-- When removing helmer slots, NPCs don't have hair anymore
-- @param           - uuid of the NPC
local function addHairIfNecessary(uuid)
end

----------------------------------------------------------------------------------------------------
--  
-- 								    	Event Listener
-- 
----------------------------------------------------------------------------------------------------

-- TODO - NPcs have a flaccid and erect on sex start
-- TODO - instead access pairData
local sexPairs = {}

-- Sex
Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
	if spell == "BG3SX_AskForSex" and Entity:IsNPC(target) and Entity:IsWhitelisted(target) then
		local pair = {caster = caster; target = target}
		table.insert(sexPairs, pair)
        saveVisualSet_Slots(target)
        stripNPC(target)
        giveGenitals(target)
        addHairIfNecessary(target)
        Ext.Timer.WaitFor(100, function() 
            -- remove the flaccid penis, else they suffer from double dicks (flaccid + erect)
            if Entity:HasPenis(target) then
                removeGenitals(target)
            end
        end)
	end
end)


-- Ending Sex
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
	if spell == "BG3SX_StopAction" then
		local target = ""
        for i, pair in ipairs(sexPairs) do
            if pair.caster == caster then
                target = pair.target
                table.remove(sexPairs, i)
                break
            end
        end
        if target ~= "" and Entity:IsNPC(target) then
            removeGenitals(target)
            redress(target)
            -- Remove Hair if necessary? 
        end
	end
end)