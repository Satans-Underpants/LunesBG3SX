


----------------------------------------------------------------------------------------------------
-- 
-- 									Dynamic Genital Modification
-- 
----------------------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------


-- Saved genitals for better performance
local allGenitals = {}
local setVanillaVulvas = {}
local setVanillaPenises = {}
local setFunErections = {}

-- Setters
local function setAllGenitals(genitals)
	allGenitals = genitals 
end 
local function setVanillaVulvas(vulvas)
	setVanillaVulvas = vulvas
end
local function setVanillaPenises(penises)
	setVanillaPenises = penises
end
local function setFunErections(erections)
	setFunErections = erections
end
local function setAdditionalGenitals(genitals)
	additionalGenitals = genitals
end

-- Getters
local function getAllGenitals()
	return allGenitals
end
local function getVanillaVulvas()
	return setVanillaVulvas
end
local function getVanillaPenises()
	return setVanillaPenises
end
local function getFunErections()
	return setFunErections
end
local function getAdditionalGenitals()
	return additionalGenitals
end

----------------------------------------------------------------------------------------------------
-- 
-- 									XML Handling
-- 				 	Read information saved in xml files from game
-- 
----------------------------------------------------------------------------------------------------

-- Get all CharacterCreationAppearaceVisuals of type Private Parts loaded in the game
---@return	allGenitals	- list of CharacterCreationAppearaceVisual IDs for all genitals
local function collectAllGenitals()
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


-- Get all vanilla genitals of specific type
---@param TYPE	string	- Type of genital to get
---@param default	any	- TODO
---@return result		- Table of requested genitals
local function getVanillaGenitals(TYPE, default)
    local tableToSearch = (TYPE == "PENIS" and PENIS) or (TYPE == "VULVA" and VULVA)
    if not tableToSearch then
		_P("[BG3SX][Genital.lua] - getVanillaGenitals(TYPE, default) - Invalid type specified. Please use 'PENIS', 'VULVA'.")
        return {}
    end

    local result = {}
    for _, entry in ipairs(tableToSearch) do -- Collect all genitalIDs from the selected table
        if default and entry.name == "Default" then
            table.insert(result, entry.genitalID)
        elseif not default and entry.name ~= "Default" then
            table.insert(result, entry.genitalID)
        end
    end
    return result
end


-- Collect all available MrFunSize erections bundled with the mod
---@return result - Table of MrFunSize erections
local function collectFunErections()
    local result = {}
    for _, entry in ipairs(FUNERECTION) do -- Collect all genitalIDs from the selected table
        table.insert(result, entry.genitalID)
    end
    return result
end


-- Get Mod Specific Genitals
-- Mostly unfinished for now - if Norbyte implements a way to get Mod ID from genitals it can be simplified a lot
---@param modName string	- ModName (FolderName)
---@return modGenitals		- Table of CharacterCreationAppearaceVisual IDs genitals
local function getModGenitals(modName)
    local allGenitals = getAllGenitals()
	local modGenitals = {}
    for _, genital in pairs(allGenitals) do -- Rens Aasimar contains a Vulva without a linked VisualResource which might cause problems since it outputs nil
        local visualResource = Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual").VisualResource
		local resource = Ext.Resource.Get(visualResource, "Visual") -- Visualbank
	    local sourceFile = Helper:GetPropertyOrDefault(resource, "SourceFile", nil)
		if sourceFile then 
			if Helper:StringContains(sourceFile, modName) then
				table.insert(modGenitals, genital)
			end
		end
    end

    -- Failsafe for CC
	local additionalGenitals = getAdditionalGenitals(allGenitals)
	for _, genital in ipairs(additionalGenitals) do
		table.insert(modGenitals, genital)
	end
    return modGenitals
end


-- All genitals that are not part of "Vanilla" BG3SX
---@return additionalGenitals	- Table of CharacterCreationAppearaceVisual IDs genitals htat are not part of Vanilla or MrFunSizeErections
function getAdditionalGenitals(allGenitals)
    -- Default genitals that come with BG3SX
    local setVanilla = {
        Table:ListToSet(getVanillaGenitals("VULVA", false)),
        Table:ListToSet(getVanillaGenitals("PENIS", false)),
        Table:ListToSet(getVanillaGenitals("VULVA", true)),
        Table:ListToSet(getVanillaGenitals("PENIS", true)),
        Table:ListToSet(getFunErections())
    }

    local additionalGenitals = {}
    for _, genital in ipairs(allGenitals) do -- Filter allGenitals to find additional genitals
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


-- TODO: Check if this can be removed
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
-- 			if Helper:StringContains(modName, race) then
--                 _P("Error: Mod name matches a race name, which suggests improper directory structure.")
-- 				_P("Error: Spell will be added to \"Other Genitals\"")
--                 return "BG3SX_OtherGenitals"
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
local function purgeObjectSpells()
    for _, spell in pairs(Ext.Stats.GetStats("SpellData")) do
        -- If ContainerSpells exists, the spell is a container
        if Ext.Stats.Get(spell).ContainerSpells and spell == "BG3SX_ChangeGenitals" then
            local container = Ext.Stats.Get(spell)
            container.ContainerSpells = ""
            container:Sync()
        end
    end
end


-- TODO - this would make FunErections a requirement - can we add it directly to the mod? 
-- Then refractor the code, instead of SimpleErections we might scan for BG3SX instead
-- Adds base spells to Change Genitals - Vanilla Vula, Vanilla Flaccid, Erections
function Genital:InitializeChangeGenitals()
	local baseSpells = {"BG3SX_VanillaVulva", "BG3SX_VanillaFlaccid", "BG3SX_SimpleErections", "BG3SX_OtherGenitals"}
	local container = Ext.Stats.Get("BG3SX_ChangeGenitals")

	for _,spell in pairs(baseSpells) do 
		local spellsInContainer = container.ContainerSpells
		container.ContainerSpells = spellsInContainer..";" .. spell
		container:Sync()
	end
end


-- TODO: 3rd party support Assigns Spells/Containers based on available penises
-- TODO - the rest of this code can be repursposed for when we switch to UI implementation


-- Add Genital containers - Vanilla & MrFunSize are always added
function Genital:Initialize()
    purgeObjectSpells() -- Purge all Containers (this solves a lot of issues)
	Genital:InitializeChangeGenitals() -- Initialize Genitals that are always added

	-- Default gentials that come with BG3SX
	setAllGenitals(collectAllGenitals())
	setVanillaVulvas(getVanillaGenitals("VULVA"))
	setVanillaPenises(getVanillaGenitals("PENIS"))
	setFunErections(collectFunErections())

	local modGenitals = {}
	-- Filter allGenitals to find additional genitals
	for _, genital in ipairs(allGenitals) do
		if not setVanillaVulvas[genital] and not setVanillaPenises[genital] and not setFunErections[genital] then
				table.insert(modGenitals, genital)
		end
	end

	setAdditionalGenitals = modGenitals

	-- TODO - will be moved to UI, thus the uselessness 
	local spell = "BG3SX_OtherGenitals"
	local container = Ext.Stats.Get("BG3SX_ChangeGenitals")
	local spellsInContainer = container.ContainerSpells
	container.ContainerSpells = spellsInContainer..";" .. spell
	container:Sync()
end

----------------------------------------------------------------------------------------------------
-- 
-- 									Genitals
-- 
----------------------------------------------------------------------------------------------------

-- Return whether an race is allowed to have genitals - added by modders requests
---@param uuid	string	- uuid of entity that will receive the genital
---@return bool			- True/False
local function raceAllowedToHaveGenitals(uuid)
	local race = Entity:TryGetEntityValue(uuid, nil, {"CharacterCreationStats", "Race"})
	local name = ""	

	if race then
		for _,entry in pairs(MODDED_RACES) do
			if entry.uuid == race then
				name = entry.name
			end
		end

		-- These have been added due to requests from modders
		-- TODO: Create Whitelist for modders to manually add their races to so we don't have to do this
		if not ((name == "CatBug") or (name == "Imp") or (name == "Mephit")) then
			return true
		end
	else
		-- If NPC etc.
		return true
	end
end


-- TODO: Check parameters (why is spell listed for the example?)
-- Get all allowed genitals for entity (Ex: all vulva for human)
---@param spell					- Name of the spell by which the genitals are filtered (vulva, penis, erection)
---@param uuid string 	    	- uuid of entity that will receive the genital
---@return permittedGenitals	- Table of IDs of CharacterCreationAppearaceVisuals
local function getPermittedGenitals(uuid)
	local permittedGenitals = {}
	local allGenitals = getAllGenitals()

	-- Get the properties for the character
	local E = Helper:GetPropertyOrDefault(Ext.Entity.Get(uuid),"CharacterCreationStats", nil)
	local bt =  Ext.Entity.Get(uuid).BodyType.BodyType
	local bs = 0
	if E then
		bs = E.BodyShape
	end

	-- NPCs only have race tags
	local raceTags = Entity:TryGetEntityValue(uuid, nil, {"ServerRaceTag", "Tags"})
	local race
	for _, tag in pairs(raceTags) do
		if RACETAGS[tag] then
			race = Table:GetKey(RACES, RACETAGS[tag])
			break
		end
	end

	-- Failsafe for modded races - assign human race
	-- TODO - add support for modded genitals for modded races
	if not RACES[race] then
		_P("[BG3SX][Genital.lua] You are currently not using a default currently, some genitals may be misaligned.")
		-- _P(race, " is not Vanilla and does not have a Vanilla parent, " ..  
		-- " these custom races are currently not supported")
		-- _P("using default human genitals")
		race = "0eb594cb-8820-4be6-a58d-8be7a1a98fba"
	end

	-- Special Cases
	-- Specific Githzerai feature (T3 and T4 are not strong, but normal)
	local bodyShapeOverride = false

	if Table:Contains(raceTags, "7fa93b80-8ba5-4c1d-9b00-5dd20ced7f67") then
		bodyShapeOverride = true
	end

	-- Halsin is special boy
	if uuid == "S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323" then
		race = "0eb594cb-8820-4be6-a58d-8be7a1a98fba"
	end

	-- Get genitals with same stats
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


-- TODO: Check parameters (why does spell have 2 lines?)
-- Get genitals filteres by used spell (ex: only vulvas, only erections)
-- @param spell						- Name of the spell by which the genitals are filtered (vulva, penis, erection)
-- 									- spell Name has to be the same as Mod folder name
---@param listOfGenitals	table	- List of genital Ids prefiltered by race/body
---@return filteredGenitals			- List of IDs of CharacterCreationAppearaceVisuals
local function getFilteredGenitals(spell, listOfGenitals)
	local filteredGenitals = {}
	local spellGenitals = {}

	-- Vanilla Spells
	if spell == "BG3SX_VanillaVulva" then
		spellGenitals = getVanillaVulvas()
	elseif spell == "BG3SX_VanillaFlaccid" then
		spellGenitals = getVanillaPenises()
	-- Modded Dicks (including MrFunSize)	
	elseif spell == "BG3SX_SimpleErections" then
		spellGenitals = getFunErections()
	-- Modded Dicks		
	else
		spellGenitals = getModGenitals(spell)
	end
	if not spellGenitals then
		_P("[BG3SX][Genital.lua] Error, spell not configured correctly, cannot get genitals")
		return
	end

	-- Only keep genitals that are in both filtered (race/body) and Mod
    for _, genital in ipairs(listOfGenitals) do
        if Table:Contains(spellGenitals, genital) then
            table.insert(filteredGenitals, genital)
        end
    end
	return filteredGenitals
end


-- TODO - Currently resets on Saveload. Make into uservariable
-- Allows to cycle through a list of genitals instead of choosing a random one
local genitalChoice = {}

-- Choose random genital from selection (Ex: random vulva from vulva a - c)
---@param spell	string		- Name of the spell by which the genitals are filtered (vulva, penis, erection)
---@param uuid	string 		- uuid of entity that will receive the genital
---@return selectedGenital	- ID of CharacterCreationAppearaceVisual
function Genital:GetNextGenital(spell, uuid)
    local permittedGenitals = getPermittedGenitals(uuid)
    local filteredGenitals = getFilteredGenitals(spell, permittedGenitals)

	if  not filteredGenitals then
        -- _P("[BG3SX] No " , spell , " genitals available after filtering for this entity.")
        return nil
    else
		if genitalChoice.uuid == uuid and genitalChoice.spell == spell then
			-- Increment the index, wrap around if necessary
			genitalChoice.index = (genitalChoice.index % #filteredGenitals) + 1
		else
			genitalChoice = {uuid = uuid, spell = spell, index = 1}
		end

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
---@param uuid 	    - uuid of entity that has a genital
---@return visual	- ID of CharacterCreationAppearaceVisual
function Genital:GetCurrentGenital(uuid)
	local entity = Ext.Entity.Get(uuid)
	local allGenitals = getAllGenitals()
	local ccAppearance =  Helper:GetPropertyOrDefault(entity, "CharacterCreationAppearance", nil)
	-- _P("[BG3SX][Genital.lua] - Genital:GetCurrentGenital - ccAppearance = ", ccAppearance)

	local characterVisuals
	if ccAppearance then
		characterVisuals = Helper:GetPropertyOrDefault(ccAppearance, "Visuals", nil)
		-- _P("[BG3SX][Genital.lua] - Genital:GetCurrentGenital - characterVisuals = ", characterVisuals)
	end
	-- local characterVisuals =  Ext.Entity.Get(uuid):GetAllComponents().CharacterCreationAppearance.Visuals
	
	if characterVisuals then
		for _, visual in pairs(characterVisuals)do
			if Table:Contains(allGenitals, visual) then
				-- _P("[BG3SX][Genital.lua] - Genital:GetCurrentGenital - visual to be returned = ", visual)
			return visual
			end
		end
	end
end


-- Override the current genital with the new one
---@param newGenital	string	- UUID of CharacterCreationAppearaceVisual of type PrivateParts
---@param uuid			string	- UUID of entity that will receive the genital
function Genital:OverrideGenital(newGenital, uuid)
	-- _P("Overriding genital")
	if raceAllowedToHaveGenitals(uuid) then
		-- _P("[BG3SX][Genital.lua] - Genital:OverrideGenital for uuid: ", uuid)
		local currentGenital = Genital:GetCurrentGenital(uuid)
		-- _P("[BG3SX][Genital.lua] - Genital:OverrideGenital - currentGenital = ", currentGenital)

		-- Origins don't have genitals - We have to add one before we can remove it
		-- if currentGenital and not (currentGenital == newGenital) then
		-- 	-- Note: This is not a typo, It's actually called Ovirride
		-- 	Osi.RemoveCustomVisualOvirride(uuid, currentGenital) 
		-- end

		if newGenital then
			-- _P("[BG3SX][Genital.lua] - Genital:OverrideGenital - newGenital exists = ", newGenital)
			if currentGenital then
				-- _P("[BG3SX][Genital.lua] - Genital:OverrideGenital - currentGenital exists = ", currentGenital, "RemoveCustomVisualOvirride triggered")
				Osi.RemoveCustomVisualOvirride(uuid, currentGenital) 
			else
				-- _P("[BG3SX][Genital.lua] - Genital:OverrideGenital - currentGenital does not exist")
			end
			-- _P("Adding ", newGenital)
			Ext.Timer.WaitFor(100, function()
				-- _P("[BG3SX][Genital.lua] - Genital:OverrideGenital - Timer triggered for AddCustomVisualOverrider")
				Osi.AddCustomVisualOverride(uuid, newGenital)
			end)
		end
		Ext.ModEvents.BG3SX.GenitalChange:Throw({uuid, newGenital})
	end


	-- Shapeshifted entities have to be handled separately

	-- TODO - this will probably stack genitals on continued spell usage, also implement "removeshapeshiftedvisual"
	-- and "switch shapeshiftedvisual" from deleted commit (Skiz local copy)

	-- TODO - this works once, then switches back to his canon penis - appearanceoverride seems to get yeeted 

	-- TODO - for shapeshifted their "original" genitals return on sex ( vulva Wyll gets a floppy penis )

	if (Ext.Entity.Get(uuid).GameObjectVisual.Type == 4) then 
		-- print("Is Shapeshifted")
		Entity:SwitchShapeshiftedVisual(uuid, newGenital, "Private Parts")
	end
end


-- Add a genital to a non NPC if they do not have one (only penises)
---@param uuid string	- uuid of entity that will receive the genital
function Genital:AddGenitalIfHasNone(uuid)
	-- _P("[BG3SX][Genital.lua] - AddGenitalIfHasNone")

	if raceAllowedToHaveGenitals(uuid) then
		if (Osi.IsTagged(uuid, "HUMANOID_7fbed0d4-cabc-4a9d-804e-12ca6088a0a8") == 1
		or Osi.IsTagged(uuid, "FIEND_44be2f5b-f27e-4665-86f1-49c5bfac54ab") == 1)
		and Osi.IsTagged(uuid, "KID_ee978587-6c68-4186-9bfc-3b3cc719a835") == 0 then
			-- _P("[BG3SX][Genital.lua] - AddGenitalIfHasNone triggered with uuid: ", uuid)
			if Entity:HasPenis(uuid) and not Genital:GetCurrentGenital(uuid) then
				-- _P("[BG3SX][Genital.lua] - ActorHasPenis and not getCurrentGenital - AddCustomVisualOverride triggered")
				Osi.AddCustomVisualOverride(uuid, Genital:GetNextGenital("BG3SX_VanillaFlaccid", uuid))
				-- _P("[BG3SX][Genital.lua] - getNextGenital = ", getNextGenital("BG3SX_VanillaFlaccid", uuid))
			end
		end
	end
end


-- TODO - NPC Genitals broken -- call correct NPC function 


-- Give an actor in the scene an erection (if they have a penis)
---@param uuid	string	-The character to give an erection to
function Genital:GiveErection(uuid)
	-- print("Give erection to character")
	local visual = Genital:GetNextGenital("BG3SX_SimpleErections", uuid)
	-- _P("penis ", visual)
	local entity = Ext.Entity.Get(uuid)
	local autoerection = Entity:TryGetEntityValue(uuid, nil, {"Vars", "BG3SX_AutoErection"})
	
	-- TODO - Even when this evaluates to false they still get an erection - probably has to be called sooner

	-- print("has penis ? ", Entity:HasPenis(uuid))
	-- print("autoerection ", entity.Vars.BG3SX_AutoErection)

	if Entity:HasPenis(uuid) and ((autoerection == nil) or (entity.Vars.BG3SX_AutoErection == 1)) then
		-- _P("Autoerection allowed for ", uuid)

		-- TODO: Learn what Types there are
		-- 4 may be Shapeshift - May need to change if we learn about other types -- NPC Type 2?
		-- For any shapeshifted parent
		if (entity.GameObjectVisual.Type == 4) then 
			-- print("Is SHapeshifted")
			Ext.Timer.WaitFor(200, function()
				Entity:GiveShapeshiftedVisual(uuid, visual)
			end)
		-- non -shapeshifted? 	
		else
			--  For any non-shapeshifted parent and NPC (NPC if slightly changed)
		    --	might work for NPCs, I give them a genital slot after all - maybe their copy does not have one though
		    --	but it should be copied?

			--This fails during sex but works for masturbation
			Genital:OverrideGenital(visual, uuid)
			-- _P("Adding erection to ", uuid)
		end
	else
		-- print("Autoerection not allowed")
		-- TODO : NPC Handler
	end
end

-- TODO - we have to remove the old genital before adding the erection
-- Check by using horsecocks 

-- in that ase we can check whether a visual is a genital by repurpisung a DOLL function

-- Give an actor in the scene an erection (if they have a penis)
---@param actor	Actor	-The actor to give an erection to
function Genital:GiveErectionToActor(actor)
	-- print("Give erection to actor")
	local parent = actor.parent
	local visual = Genital:GetNextGenital("BG3SX_SimpleErections", parent)
	-- _P("penis ", visual)
	local parentEntity = Ext.Entity.Get(actor.parent)
	local autoerection = Entity:TryGetEntityValue(parent, nil, {"Vars", "BG3SX_AutoErection"})
	
	-- TODO - even when this evaluates to false they still get an erection - probably has to be called sooner

	-- print("has penis ? ", Entity:HasPenis(parent))
	-- print("autoerection ", parentEntity.Vars.BG3SX_AutoErection)
	if Entity:HasPenis(parent) and ((autoerection == nil) or (parentEntity.Vars.BG3SX_AutoErection == 1)) then
		-- _P("Autoerection allowed for ", parent)

		-- TODO: Learn what Types there are
		-- 4 may be Shapeshift - May need to change if we learn about other types -- NPC Type 2?
		-- For any shapeshifted parent
		if (parentEntity.GameObjectVisual.Type == 4) then 
			-- print("Is SHapeshifted")
			Ext.Timer.WaitFor(200, function()
				Entity:SwitchShapeshiftedVisual(actor.uuid, visual, "Private Parts")
			--Entity:GiveShapeshiftedVisual(actor.uuid, visual)
			end)
		-- non -shapeshifted? 	
		else
			-- print ("Not shapeshifted. Type = ", parentEntity.GameObjectVisual.Type)
			--  For any non-shapeshifted parent and NPC (NPC if slightly changed)
		    --	might work for NPCs, I give them a genital slot after all - maybe their copy does not have one though
		    --	but it should be copied?

			--THis fails during sex but works for masturbation
			--Genital:OverrideGenital(visual, actor.uuid)
			--_P("Adding erection to ", actor.uuid)
		end
	else
		-- print("Autoerection not allowed")
		-- TODO : NPC Handler
	end
end


---@param actor	Actor	-The actor to give an erection to
function Genital:GiveGenitalsToActor(actor)
	-- print("Give vulva to actor")
	local parent = actor.parent
	local visual = Genital:GetCurrentGenital(parent)
	-- _P("genital ", visual)
	local parentEntity = Ext.Entity.Get(actor.parent)
	if (parentEntity.GameObjectVisual.Type == 4) then 
		-- print("Is SHapeshifted")
		Ext.Timer.WaitFor(200, function()
			Entity:GiveShapeshiftedVisual(actor.uuid, visual)
		end)
	end
end