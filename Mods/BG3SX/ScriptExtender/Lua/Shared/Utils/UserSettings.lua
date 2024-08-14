----------------------------------------------------------------------------------------------------
-- 
-- 			                        		User Settings
-- 
----------------------------------------------------------------------------------------------------


UserSettings = {}
UserSettings.__index = UserSettings


----------------------------------------------------------------------------------------------------
-- 
-- 			                        		Choices
-- 
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- 
-- 			                        	Getters/Setters
-- 
----------------------------------------------------------------------------------------------------

-- Gets all variables
--- @return     - table with all values
local function getVariables()
    return allVariables
end



----------------------------------------------------------------------------------------------------
-- 
-- 			                           JSON TEMPLATE
-- 
----------------------------------------------------------------------------------------------------

local filename = "BG3SX_Settings.json"

----------------------------------------------------------------------------------------------------
-- 
-- 			                        Saving the settings
-- 
----------------------------------------------------------------------------------------------------

-- Save user choices in Settings file
local function saveSettings()
    -- TODO - build content

    Ext.IO.SaveFile(filename, content)
end


----------------------------------------------------------------------------------------------------
-- 
-- 			                        Loading the Settings
-- 
----------------------------------------------------------------------------------------------------

-- Load user settings and update variables
local function loadSettings()
    -- If there is no json. instantiate default values and create savefile
end


----------------------------------------------------------------------------------------------------
-- 
-- 			                        Default Settings
-- 
----------------------------------------------------------------------------------------------------

-- Create new SaveFile with default values
local function instantiateDefaultSettings()
    Genital:SetAutoErection(1)
end


----------------------------------------------------------------------------------------------------
-- 
-- 			                        Event Listeners
-- 
----------------------------------------------------------------------------------------------------

-- TODO - move to UI 

-- Save user settings when they are changed
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(_, spell, spellType, _, _) 
    -- TODO - call save - check if it's a setting (container)
end)


-- Load user settings on level started
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_,_) 
    -- loadSettings()
end)

------------------------------------------------------
-- Yoinked from Fallens "Mark books as read"
-- TODO - look trough when not hungry anymore

local CONFIG = {
    data = {},
    path = filename
}

-- -- Load configuration from the file or initialize with default values
-- function CONFIG:load()
--     -- Attempt to load configuration from file
--     local fileConfig = JSON.LuaTableFromFile(self.path) or {}

--     -- Check if the configuration file was empty or non-existent
--     if next(fileConfig) == nil then
--         -- Initialize with default values if the file configuration is empty
--         self.data = default_config_tbl
--         self.__configChanged = true  -- Mark as changed to trigger save operation
--     else
--         -- Use the loaded configuration
--         self.data = fileConfig
--     end

--     -- Save configuration if there were changes
--     if self.__configChanged then
--         self:save()
--     end
-- end

-- -- Save the configuration to a file
-- function CONFIG:save()
--     -- Only save if there have been changes to the configuration
--     if self.__configChanged then
--         JSON.LuaTableToFile(self.data, self.path)
--         self.__configChanged = false  -- Reset change flag after saving
--         Basic_P("Config saved to " .. self.path)  -- Log message confirming save
--     end
-- end

-- -- Initialize and load the configuration
-- function CONFIG:init()
--     self:load()  -- Load existing config or create new one
--     -- Additional initialization can be performed here if necessary
-- }

-- -- Initialize the configuration on script execution
-- CONFIG:init()

-- TODO - Subscribe to Event Handlers