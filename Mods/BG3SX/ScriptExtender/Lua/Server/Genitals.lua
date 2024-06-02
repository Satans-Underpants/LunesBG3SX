----------------------------------------------------------------------------------------------------
-- 
-- 	Dynamic Genital Modification -  based on MrFunSize's implementation of Genitals [Folder Structure]
-- 
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 
-- 									Shorthands and Helpers
-- 
----------------------------------------------------------------------------------------------------
--- Checks if an item is present in a list.
-- @param list table	- The table to be searched.
-- @param item any		- The item to search for in the table.
-- @return bool 		- Returns true if the item is found, otherwise returns false.
local function contains(list, item)
    for i, object in ipairs(list) do
        if object == item then
            return true
        end
    end
    return false
end


-- Checks if the substring 'sub' is present within the string 'str'.
-- @param str string 	-  The string to search within.
-- @param sub string 	- The substring to look for.
-- @return bool			- Returns true if 'sub' is found within 'str', otherwise returns false.
local function stringContains(str, sub)
    -- Make the comparison case-insensitive
    str = str:lower()
    sub = sub:lower()
    return (string.find(str, sub, 1, true) ~= nil)
end

-- Helper function to convert a list to a set
-- @param list 		- the list to be converted
-- @return 			- set from list
local function listToSet(list)
    local set = {}
    for _, v in ipairs(list) do
        set[v] = true
    end
    return set
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


-- for maps
local function getKey(map, item)
    for key, object in pairs(map) do
        if object == item then
            return key
        end
    end
    return nil
end
----------------------------------------------------------------------------------------------------
-- 
-- 									XML Handling
-- 				 read information saved in xml files from game
-- 
----------------------------------------------------------------------------------------------------

-- Get all CharacterCreationAppearaceVisuals of type Private Parts loaded in the game
---return 				- list of CharacterCreationAppearaceVisual IDs for all genitals
local function getAllGenitals()
	local allGenitals = {}
	local allCCAV = Ext.StaticData.GetAll("CharacterCreationAppearanceVisual")
	for _, CCAV in pairs(allCCAV)do
		local contents = Ext.StaticData.Get(CCAV, "CharacterCreationAppearanceVisual")
		local slotName = contents.SlotName
		if slotName and slotName == "Private Parts" then
			table.insert(allGenitals, CCAV)
		end
	end
	return allGenitals
end

local function getVanillaGenitals(TYPE, default)
    local tableToSearch = (TYPE == "PENIS" and PENIS) or (TYPE == "VULVA" and VULVA)

    if not tableToSearch then
        -- print("Invalid type specified. Please use 'PENIS', 'VULVA'.")
        return {}
    end

    local result = {}

    -- Collect all genitalIDs from the selected table
    for _, entry in ipairs(tableToSearch) do
        if default and entry.name == "Default" then
            table.insert(result, entry.genitalID)
        elseif not default and entry.name ~= "Default" then
            table.insert(result, entry.genitalID)
        end
    end

    return result
end

-- Get Mod Specific Genitals
--@param            - ModName (FolderName)
---return           - list of CharacterCreationAppearaceVisual IDs genitals
local function getModGenitals(modName)
	-- _P("[Genitals.lua] -------------------------------------------------------")
	-- _P("[Genitals.lua] - getModGenitals for ", modName)
    local modGenitals = {}
    local allGenitals = getAllGenitals()
	local genitalIndex = 1
	-- _P("[Genitals.lua] - Now iterating over every Genital to find :")
    for _, genital in pairs(allGenitals) do -- Rens Aasimar contains a Vulva without a linked VisualResource which might cause problems since it outputs nil
		-- _P("[Genitals.lua] -------------------------------------------------------")
		-- _P("[Genitals.lua] - Checking Entry " .. genitalIndex .. " Genital: ", genital)
        local visualResource = Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual").VisualResource
		-- _P("[Genitals.lua] - Genitals Visualresource: ", visualResource)

		-- local displayName = Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual").DisplayName.Handle.Handle
		-- local name = Ext.Loca.GetTranslatedString(displayName)
		-- _P("[Genitals.lua] - DisplayName is: ", name)
		
		local resource = Ext.Resource.Get(visualResource, "Visual") -- Visualbank
		-- _P("[Genitals.lua] - That resources VisualBank:  ", resource)

       -- local sourceFile = Ext.Resource.Get(visualResource, "Visual").SourceFile
	   local sourceFile = GetPropertyOrDefault(resource, "SourceFile", nil)
		-- _P("[Genitals.lua] - The VisualBanks SourceFile: ", sourceFile)
		if sourceFile then 
			if stringContains(sourceFile, modName) then
				-- _P("[Genitals.lua] - Adding current Genital to list of modGenitals since SourceFile path contains ", modName)
				table.insert(modGenitals, genital)
				-- _D(Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual")) -- Dump of the added Genital
			end
		end

		-- if resource == nil then
			-- _P("[Genitals.lua] -------------------------------------------------------")
			-- _P("[Genitals.lua] -------------------------------------------------------")
			-- _D(Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual"))
			-- _P("[Genitals.lua] -------------------------------------------------------")
			-- _P("[Genitals.lua] -------------------------------------------------------")
		-- end

		genitalIndex = genitalIndex+1
    end

    -- Failsafe for CC
    if modName ~= "SimpleErections" then
		-- _P("[Genitals.lua] -------------------------------------------------------")
		-- _P("[Genitals.lua] - FAILSAVE TRIGGERED")
		-- _P("[Genitals.lua] -------------------------------------------------------")
        local additionalGenitals = getAdditionalGenitals(allGenitals)
        for _, genital in ipairs(additionalGenitals) do
            table.insert(modGenitals, genital)
        end
    end

    if #modGenitals == 0 then
        -- print("No genitals found for this mod")
    end

    return modGenitals
end

-- All genital that are not part of "Vanilla" BG3SX
---return 			- list of CharacterCreationAppearaceVisual IDs genitals htat are not part of Vanilla or MrFunSizeErections
function getAdditionalGenitals(allGenitals)
    -- Default genitals that come with BG3SX
    local setVanilla = {
        listToSet(getVanillaGenitals("VULVA", false)),
        listToSet(getVanillaGenitals("PENIS", false)),
        listToSet(getVanillaGenitals("VULVA", true)),
        listToSet(getVanillaGenitals("PENIS", true)),
        listToSet(getModGenitals("SimpleErections"))
    }

    local additionalGenitals = {}
    -- Filter allGenitals to find additional genitals
    for _, genital in ipairs(allGenitals) do
        local isUnique = true
        for _, set in ipairs(setVanilla) do
            if set[genital] then
                isUnique = false
                break
            end
        end
        if isUnique then
            table.insert(additionalGenitals, genital)
        end
    end
    return additionalGenitals
end


-- Get Mod that genital belongs to
--@param  			- genital ID
---return 			- Name of Mod (Folder Name)

-- local function getModByGenital(genital)

-- 	local visualResource = Ext.StaticData.Get(genital,"CharacterCreationAppearanceVisual").VisualResource
-- 	local sourceFile = Ext.Resource.Get(visualResource,"Visual").SourceFile

-- 	-- Use string.match to capture the required part of the path
-- 	-- Pattern explanation:
-- 	-- [^/]+ captures one or more characters that are not a slash (greedily matching as much as possible).
-- 	-- The pattern captures the fourth folder from the end by skipping three sets of "anything followed by a slash" sequences.
-- 	local modName = string.match(sourceFile, ".-([^/]+)/[^/]+/[^/]+/[^/]+$")

-- 	-- Quick error handling in case author places modfile too low
-- 	-- Check if value from RACES is contained within modName

-- 	if modName then
--         for _, race in pairs(RACES) do
-- 			if stringContains(modName, race) then
--                 print("Error: Mod name matches a race name, which suggests improper directory structure.")
-- 				print("Error: Spell will be added to \"Other Genitals\"")
--                 return "Other_Genitals"
--             end
--         end
--     end

-- 	return modName
-- end


----------------------------------------------------------------------------------------------------
-- 
-- 										Spell Handling
-- 
----------------------------------------------------------------------------------------------------



-- Delete all spells from container "Change Genitals"
function purgeObjectSpells()

    for _, spell in pairs(Ext.Stats.GetStats("SpellData")) do

        -- If ContainerSpells exists, the spell is a container
        if Ext.Stats.Get(spell).ContainerSpells and spell == "Change_Genitals" then
            local container = Ext.Stats.Get(spell)
            container.ContainerSpells = ""
            container:Sync()
        end
    end
end

-- TODO - this would make FunErections a requirement - can we add it directly to the mod? 
-- Then refractor the code, instead of SimpleErections we might scan for BG3SX instead
-- Adds base spells to Change Genitals - Vanilla Vula, Vanilla Flaccid, Erections
function InitializeChangeGenitals()

	local baseSpells = {"Vanilla_Vulva","Vanilla_Flaccid","SimpleErections", "Other_Genitals"}

	local container = (Ext.Stats.Get("Change_Genitals"))

	for _,spell in pairs(baseSpells) do 
		local spellsInContainer = container.ContainerSpells
		container.ContainerSpells = spellsInContainer..";" .. spell
		container:Sync()
	end
	
end


-- TODO: 3rd party support Assigns Spells/Containers based on available penises
-- TODO - the rest of this code can be repursposed for when we switch to UI implementation

-- Add Genital containers - Vanilla & MrFunSize are always added
function OnSessionLoaded()

	-- _P("ADDING GENITAL SPELLS ")

    -- Purge all Containers (this solves a lot of issues)
    purgeObjectSpells()

	-- Initialize Genitals that are always added
	InitializeChangeGenitals()

	-- Default gentials that come with BG3SX
	local allGenitals = getAllGenitals()
	local setVanillaVulvas = listToSet(getVanillaGenitals("VULVA"))
	local setVanillaPenises = listToSet(getVanillaGenitals("PENIS"))
	local setFunErections = listToSet(getModGenitals("SimpleErections"))

	local additionalGenitals = {}

	-- Filter allGenitals to find additional genitals
	for _, genital in ipairs(allGenitals) do
		if not setVanillaVulvas[genital] and not setVanillaPenises[genital] and not setFunErections[genital] then
				table.insert(additionalGenitals, genital)
		end
	end

	-- TODO - will be moved to UI, thus the uselessness 
	local spell = "Other_Genitals"
	local container = (Ext.Stats.Get("Change_Genitals"))
	local spellsInContainer = container.ContainerSpells
	container.ContainerSpells = spellsInContainer..";" .. spell
	container:Sync()
end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

----------------------------------------------------------------------------------------------------
-- 
-- 									Genitals
-- 
----------------------------------------------------------------------------------------------------


-- Get allowed race based on input race (modded races support)
-- @param originalRace		- actual race of the entity
---return 					- raceOverride in case of unsupported modded race / race
---return           		- bodyshapeOverride in case of modded race / bodyshape
function getRaceAndBody(originalRace)

	local bodyShapeOverride = false
	local race = originalRace
	
	-- Check for supported modded races
	for _, allowedRace in ipairs(MODDED_RACES) do
		if allowedRace.uuid == race then

			print(allowedRace.name, " is a supported race")
			-- if modded race uses the body of vanilla, choose that
			if allowedRace.useDefault then
				race = allowedRace.default
				print(allowedRace.name, " will use ", allowedRace.defaultName ," presets ")
			end

			-- choose different bodyshape preset [for now has to be manually configured]
			if (allowedRace.bs3) or allGenitals.bs4 then
				bodyShapeOverride = true
				-- print("Using bodyshape override")
			end

		else
			-- print(race, " is not supported using default human genitals")
			race = "0eb594cb-8820-4be6-a58d-8be7a1a98fba"
		end
	end

	return race, bodyShapeOverride
end


-- TODO : test Githzerai again

-- Get all allowed genitals for entity (Ex: all vulva for human)
-- @param spell		- Name of the spell by which the genitals are filtered (vulva, penis, erection)
-- @param uuis 	    - uuid of entity that will receive the genital
---return 			- List of IDs of CharacterCreationAppearaceVisuals
local function getPermittedGenitals(uuid)

	local permittedGenitals = {}

	-- Get entities body
	local allGenitals = getAllGenitals()

	-- Get the properties for the character
	local E = GetPropertyOrDefault(Ext.Entity.Get(uuid),"CharacterCreationStats", nil)
	local bt =  Ext.Entity.Get(uuid).BodyType.BodyType
	local bs = 0

	if E then
		bs = E.BodyShape
	end


	-- NPCs only have race tags
	local raceTags = Ext.Entity.Get(uuid):GetAllComponents().ServerRaceTag.Tags

	local race
	for _, tag in pairs(raceTags) do
		if RACETAGS[tag] then
			race = getKey(RACES, RACETAGS[tag])
			break
		end
	end

	-- failsafe for modded races - assign human race
	-- TODO - add support for modded genitals for modded races

	local bodyShapeOverride = false

	if not RACES[race] then
		-- print(race, " is not Vanilla, checking for supported custom races")

		race, bodyShapeOverride = getRaceAndBody(originalRace)
	end

	-- Halsin is special boy
	if uuid == "S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323" then
		race = "0eb594cb-8820-4be6-a58d-8be7a1a98fba"
	end

	-- get genitals with same stats
	for _, genital in pairs(allGenitals) do

		local G = Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual")

		-- bodyshape overrides for modded races - TODO: find a better way to do this
		if bodyShapeOverride then
			bs = 0
		end
		
		if (bt == G.BodyType) and (bs == G.BodyShape) and (race == G.RaceUUID) then
			table.insert(permittedGenitals, genital)
		end
	end

	return permittedGenitals
end


-- Get genitals filteres by used spell (ex: only vulvas, only erections)
-- @param spell					- Name of the spell by which the genitals are filtered (vulva, penis, erection)
-- 								- spell Name has to be the same as Mod folder name
-- @param listOfGenitals 	    - List of genital Ids prefiltered by race/body
---return 						- List of IDs of CharacterCreationAppearaceVisuals
local function getFilteredGenitals(spell, listOfGenitals)

	local filteredGenitals = {}
	local spellGenitals = {}

	-- Vanilla Spells
	if spell == "Vanilla_Vulva" then
		spellGenitals = getVanillaGenitals("VULVA")
	elseif spell == "Vanilla_Flaccid" then
		spellGenitals = getVanillaGenitals("PENIS")
	-- Modded Dicks (including MrFunSize)	
	else 
		spellGenitals = getModGenitals(spell)
	end

	if not spellGenitals then
		-- _P("[BG3SX] Error, spell not configured correctly, cannot get genitals")
		return
	end

	-- only keep genitals that are in both filtered (race/body) and Mod
    for _, genital in ipairs(listOfGenitals) do
        if contains(spellGenitals, genital) then
            table.insert(filteredGenitals, genital)
        end
    end

	return filteredGenitals
end



-- TODO - Halsin is special, give him human genitals

-- TODO - currently resets on Saveload. Make into uservariable
-- allows to cycle through a list of genitals instead of choosing a random one
local genitalChoice = {}

-- Choose random genital from selection (Ex: random vulva from vulva a - c)
-- @param spell		- Name of the spell by which the genitals are filtered (vulva, penis, erection)
-- @param uuid 	    - uuid of entity that will receive the genital
---return 			- ID of CharacterCreationAppearaceVisual
function getNextGenital(spell, uuid)

	-- TODO - Shart only has 2 vulvas to choose from instead of 3 after filtering for defailts: issue in the lib? 
    local permittedGenitals = getPermittedGenitals(uuid)
    local filteredGenitals = getFilteredGenitals(spell, permittedGenitals)

    if genitalChoice.uuid == uuid and genitalChoice.spell == spell then
        -- Increment the index, wrap around if necessary
        genitalChoice.index = (genitalChoice.index % #filteredGenitals) + 1
    else
        genitalChoice = {uuid = uuid, spell = spell, index = 1}
    end

    if #filteredGenitals == 0 then
        -- print("[BG3SX] No " , spell , " genitals available after filtering for this entity.")
        return nil
    else
        local selectedGenital = filteredGenitals[genitalChoice.index]
        return selectedGenital
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 									Transformations
-- 
----------------------------------------------------------------------------------------------------

-- Get the current genital of the entity
-- @param uuid 	    - uuid of entity that has a genital
---return 			- ID of CharacterCreationAppearaceVisual
function getCurrentGenital(uuid)
	local allGenitals = getAllGenitals()
	local characterVisuals =  Ext.Entity.Get(uuid):GetAllComponents().CharacterCreationAppearance.Visuals

	
	for _, visual in pairs(characterVisuals)do
		if contains(allGenitals, visual) then
		return visual
		end
	end
end


-- Override the current genital with the new one
-- @param newGenital	- ID of CharacterCreationAppearaceVisual of type PrivateParts
-- @param uuid 	     	- uuid of entity that will receive the genital
function overrideGenital(newGenital, uuid)
	local currentGenital = getCurrentGenital(uuid)

	-- Origins don't have genitals - We have to add one before we can remove it
	if currentGenital and not (currentGenital == newGenital) then
		-- Note: This is not a typo, It's actually called Ovirride
		Osi.RemoveCustomVisualOvirride(uuid, currentGenital) 
	end
	if newGenital then
		Osi.AddCustomVisualOverride(uuid, newGenital)
	end
end

-- Add a genital to a non NPC if they do not have one (only penises)
-- @param uuid              - uuid of entity that will receive the genital
function AddGenitalIfHasNone(uuid)
    if ActorHasPenis(uuid) and not getCurrentGenital(uuid) then
        Osi.AddCustomVisualOverride(uuid, getNextGenital("Vanilla_Flaccid", uuid))
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 									Event Listener
-- 
----------------------------------------------------------------------------------------------------

-- TODO - move to UI 

-- Genital changing
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_) 

-- If UI is used then use UI listener instead

-- Check wether spell is in container Change Genitals
local containerID = Ext.Stats.Get(spell).SpellContainerID

	if containerID == "Change_Genitals" then
	-- Transform genitals
		local newGenital = getNextGenital(spell, caster)
		overrideGenital(newGenital, caster)
	end
end)



-- Settings - move to UI
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_) 

	-- If UI is used then use UI listener instead
	
	if spell == "Auto_Erections" then
		SetAutoErection(1)
		-- _P("Automatic Erections activated")
	elseif spell == "Manual_Erections" then
		SetAutoErection(0)
		-- _P("Automatic Erections deactivated")
	end
end)

----------------------------------------------------------------------------------------------------
-- 
-- 									Automatic Erections Assigning
-- 								  Only MrFunSize supported for now
--
----------------------------------------------------------------------------------------------------


-- TODO - timers might be better, but we'll need to implement a way to receive
-- pairData in other classes, also I hate timers 

-- Ext.Osiris.RegisterListener("ObjectTimerFinished", 2, "after", function(actor, timer)
-- 	if timer == "PairedSexFade.Start" then
-- 		print("Sex Start")
-- 	end 
-- end)


-- TODO - instead access pairData
local sexPairs = {}


-- Sex
Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)

	local autoErections = GetAutoErection()
	if (autoErections == 1) and (spell == "AskForSex")  then

	
			local casterGenital = getCurrentGenital(caster)
			local targetGenital

			if not IsNPC(target) then
				targetGenital = getCurrentGenital(target)
			end
	
			local pair = {caster = caster; casterGenital = casterGenital; target = target, targetGenital = targetGenital}
			table.insert(sexPairs, pair)
	
			if ActorHasPenis(caster) then
				Osi.UseSpell(caster, "SimpleErections", caster)		
			end
	
			if ActorHasPenis(target) then
				Osi.UseSpell(target, "SimpleErections", target)		
			end
	end
end)


-- Ending Sex
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _) 


	local autoErections = GetAutoErection()


	if (autoErections == 1) and (spell == "zzzEndSex") then

		local prevGenCaster = ""
		local prevGenTarget = ""
		local target = ""
		for _, pairs in ipairs(sexPairs) do
			if pairs.caster == caster then
				target = pairs.target
				prevGenCaster = pairs.casterGenital
				prevGenTarget = pairs.targetGenital
			end
		end


		if caster and prevGenCaster then
			overrideGenital(prevGenCaster, caster)
		end

		if target and prevGenTarget then
			overrideGenital(prevGenTarget, target)
		end


		sexPairs[caster] = nil
		
	end
end)


local masturbators = {}

-- Masturbation
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _) 


	local autoErections = GetAutoErection()

	if (autoErections == 1) and (spell == "StartMasturbation") then

		-- Save previous genitals
		local casterGenital = getCurrentGenital(caster)

		local masturbator = {caster = caster; casterGenital = casterGenital}
		table.insert(masturbators, masturbator)

		if ActorHasPenis(caster) then
			Osi.UseSpell(caster, "SimpleErections", caster)	
		end	
	end

	if (autoErections == 1) and spell =="zzzStopMasturbating" then

		local previousGenital = ""
		for _, masturbator in ipairs(masturbators) do
			if masturbator.caster == caster then
				previousGenital= masturbator.casterGenital
			end
		end

		if previousGenital then
			overrideGenital(previousGenital, caster)
		end

		masturbators[caster] = nil
	end
end)










--  -- Read in spells and uuid
--  for _,genital in pairs(additionalGenitals)do

-- 	local modName = getModByGenital(genital)
-- 	-- failsafe in case genitals don't have the correct structure
-- 	if not (modName == "Other_Genitals") then

-- 	local spellsInContainer = container.ContainerSpells
-- 	print(spellsInContainer)

-- 	-- only add spell if it isn't already in container
-- 	if modName and string.find(spellsInContainer, modName, 1, true) == nil then   
-- 		print("[BG3SX] Adding", modName," to chosen container.")

-- 		-- If it already exists, just add it (I don't know how to delete spells,except for reloading the game)
-- 		if not Ext.Stats.Get(modName) then
-- 			print("Creating spell, ", modName)
-- 			-- TODO - backup plan is to do the same thing focus did for miraculous dyes and create dummy entries that will be changed
-- 			createSpell(modName)
-- 		else
-- 			print(modName, " already exists as spell")
-- 		end
		
-- 		container.ContainerSpells = spellsInContainer..";" .. modName
-- 		container:Sync()
-- 		print(container.ContainerSpells)
-- 	end
-- end
-- end






-- function createSpell(modName)


-- 	function AddCustomSpell(character)
		
-- 	local newSpell = Ext.Stats.Create(modName, "SpellData", "Template")
-- 	newSpell:Sync()
		
-- 	-- I don't know why delay
-- -- DelayCall(600, 
-- -- function() 
-- -- 	local baseSpell = Ext.Stats.Get("Container_Spell")
-- -- 	local containerList = baseSpell.ContainerSpells
-- -- 	containerList = containerList .. ";New_Spell_Name"
-- -- 	baseSpell.ContainerSpells = containerList
-- -- 	baseSpell:Sync()
-- -- 	_P("containerList: " .. containerList)
-- -- 	if Osi.HasSpell(character, 'Container_Spell') ~= 0 then
-- -- 		Osi.RemoveSpell(character, 'Container_Spell', 1)
-- -- 	end
-- -- 	Osi.AddSpell(character, 'Container_Spell', 0, 1) 
-- -- end
-- -- )
-- end





	-- -- Create spell
	-- local spell = Ext.Stats.Create(modName, "SpellData")
	-- spell.SpellType = "Shout"
	-- --spell.SpellProperties = "GROUND"
	-- spell.SpellProperties = "CanNotUse"
	-- spell.SpellContainerID = "Change_Genitals"
	-- spell.Icon = "WPN_HUM_Salami_A"
	-- spell.DisplayName = "" -- TODO - change, se if we can either create one or pull one from the mod
	-- spell.Description = ""
	-- spell.TargetConditions = ""
	-- spell.PrepareSound = "Instrument_Bard_Silence"
	-- spell.CastSound = "Instrument_Bard_Silence"
	-- spell.TargetSound = "Instrument_Bard_Silence"
	-- spell.SpellFlags = "ImmediateCast"
	-- spell.SpellFlags = "IsLinkedSpellContainer"
	-- spell.AIFlags = "CanNotUse"

	-- ??????? Crashes
	-- Ext.Stats.Get(modName):Sync()

	
	--end













