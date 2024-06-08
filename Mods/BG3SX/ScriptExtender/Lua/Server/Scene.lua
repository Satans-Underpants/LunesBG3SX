----------------------------------------------------------------------------------------
--
--                               For handling Scenes
--
----------------------------------------------------------------------------------------

Scene = {}
Scene.__index = Scene

-- CONSTRUCTOR
--------------------------------------------------------------

---@param rootposition  table   - table of x,y,z coordinates
---@param rotation      table   - table with x,y,z,w 
---@param actors        table   - table of all actors in a scene
function Scene:new(rootposition, rotation, actors)
    local instance      = setmetatable({
        rootposition    = rootposition,
        rotation        = rotation,
        actors          = actors
    }, Scene)
    return instance
end


-- VARIABLES
--------------------------------------------------------------

-- key = Scene scene
-- value = Content content
local savedScenes = {}


-- GETTERS AND SETTERS
--------------------------------------------------------------

--@return savedTables
function Scene:getSavedScenes()
    return savedScenes
end


-- METHODS
--------------------------------------------------------------