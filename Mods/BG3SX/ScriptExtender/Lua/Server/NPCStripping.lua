----------------------------------------------------------------------------------------------------
-- 
--                        NPC Stripping/Redressing and Genital Application/Removal
-- 
----------------------------------------------------------------------------------------------------

ORIGINS = {
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = "Wyll",
    ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = "ShadowHeart",
    ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = "Laezel",
    ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = "Astarion",
    ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = "Gale",
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = "Jaheira",
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = "Minsc",
    ["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = "Karlach",
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = "Minthara",
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = "Halsin",
}



----------------------------------------------------------------------------------------------------
-- 
-- 									Shorthands and Helpers
-- 
----------------------------------------------------------------------------------------------------


-- remove a  slot form VisualResources
-- @param       - items: list of current items in the slots
-- @parma       - slotsToRemove (set)
---return       - the modified Slot (table)
local function removeItemsBySlots(items, slotsToRemove)

    local newItems = {}
    for _, item in ipairs(items) do
        if not slotsToRemove[item.Slot] then
            table.insert(newItems, item)
        end
    end
    return newItems
end


-- NPCs don't have CharacterCreationStats
function IsNPC(uuid)
    local E = GetPropertyOrDefault(Ext.Entity.Get(uuid),"CharacterCreationStats", nil)

    if E then
        return false
    else
        return true
    end
end


-- get index by item directly
function getIndex(list, item)
    for i, object in ipairs(list) do
        if object == item then
            return i
        end
    end
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
function getVisualResourceID(uuid)
   local vrID = Ext.Entity.Get(uuid).ServerCharacter.Template.CharacterVisualResourceID
   return vrID
end


 -- get Slots (contain body, hair, gloves, tails etc.)
 -- serialize them because else they expire
 -- @param           - uuid of the NPC
 ---return           - Slots (Table)
function serializeVisualSetSlots(uuid)
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
function saveVisualSet_Slots(uuid)
    local slots = serializeVisualSetSlots(uuid)
    local entry = {uuid = uuid, slots = slots}
    table.insert(OriginalTemplates, entry)
    -- _D(slots)
end



 -- get a Slot for the naked NPC [race dependant]
 -- @param           - uuid of the NPC
 ---return           - Slots (Table)
function getNakedTemplate(uuid)

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

 -- strip the NPC -> exchange/Delete Slots
 -- @param           - uuid of NPC
function stripNPC(uuid)
    local naked = getNakedTemplate(uuid)
    Ext.Resource.Get(getVisualResourceID(uuid),"CharacterVisual").VisualSet.Slots = naked
end

 -- redress the NPC (give original template)
 -- @param           - some param
 ---return           - list of player uuids 
function redress(uuid)

    local dressed

    for _,entry in pairs(OriginalTemplates) do


        if entry.uuid == uuid then
            dressed = entry.slots
            Ext.Resource.Get(getVisualResourceID(uuid),"CharacterVisual").VisualSet.Slots = dressed
            table.remove(OriginalTemplates, getIndex(OriginalTemplates, entry))

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
function giveGenitals(uuid)
    

    local spells = {"Vanilla_Vulva", "Vanilla_Flaccid"}
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
    local newGenital = getNextGenital(spell, uuid)
    Osi.AddCustomVisualOverride(uuid, newGenital)

end


 -- remove the genital
 -- @param           - uuid of the NPC
function removeGenitals(uuid)
    local genital = getCurrentGenital(uuid)
    Osi.RemoveCustomVisualOvirride(uuid, genital) 
end


-- TODO

 -- When removing helmer slots, NPCs don't have hair anymore
 -- @param           - uuid of the NPC
-- TODO function giveHair for helmet havers
function addHairIfNecessary(uuid)
    
end


----------------------------------------------------------------------------------------------------
--  
-- 								    	Event Listener
-- 
----------------------------------------------------------------------------------------------------


-- TODO - instead access pairData
local sexPairs = {}

-- Sex
Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)

	if spell == "AskForSex" and IsNPC(target) then

		local pair = {caster = caster; target = target}
		table.insert(sexPairs, pair)

        saveVisualSet_Slots(target)
        stripNPC(target)
        giveGenitals(target)
        addHairIfNecessary(target)

	end
end)


-- Ending Sex
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)

	if spell == "zzzEndSex" then

		local target = ""
		for _, pairs in ipairs(sexPairs) do
			if pairs.caster == caster then
				target = pairs.target
			end
		end

        if target ~= "" and IsNPC(target) then
            _P("Is NPC ", target)
            removeGenitals(target)
            redress(target)
            -- Remove Hair if necessary? 
            sexPairs[caster] = nil

        end

	end
end)