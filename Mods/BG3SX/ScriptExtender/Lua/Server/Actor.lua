----------------------------------------------------------------------------------------
--
--                               For handling Actors (Proxies)
--
----------------------------------------------------------------------------------------

Actor = {}
Actor.__index = Actor

-- CONSTRUCTOR
--------------------------------------------------------------

---@param parent            Entity  - entity that the proxy is based on
---@param genital           string  - visual (uuid) of the actors genital
---@param isStripped        bool    - whether actor is stripped of their clothes
---@param position          table   - table of x,y,z coordinates
---@param rotation          table   - table with x,y,z,w 
---@param currentAnimation  string  - uuid of animation being player
---@param visual            string  - uuid of a visual template
---@param equipment         table   - table of uuids of equipments
---@param armour             table   - table of uuids of armour (Vanity Slots)
function Actor:new(parent, genital, isStripped, position, rotation, currentAnimation, visual, equipment, armour)
    local instance       = setmetatable({
        parent           = parent,
        genital          = genital,
        isStripped       = isStripped,
        positon          = position,
        rotation         = rotation,
        currentAnimation = currentAnimation,
        entity           = Osi.CreateAtObject(Osi.GetTemplate(parent), Osi.GetPosition(parent), 1, 0, "", 1),
        visual           = "",
        equipment        = equipment,
        armour            = armour
    }, Actor)
    return instance
end



-- VARIABLES
--------------------------------------------------------------

-- key = Actor actor
-- value = Content content
-- local savedActors = {}




-- GETTERS AND SETTERS
--------------------------------------------------------------

--@return savedTables
-- function Actor:getSavedActors()
--     return savedActors
-- end


-- METHODS
--------------------------------------------------------------

local function blockActorMovement(entity)
    Osi.AddBoosts(entity, "ActionResourceBlock(Movement)", "", "")
end

local function finalizeSetup(self)

    -- Support for the looks brought by Resculpt spell from "Appearance Edit Enhanced" mod.
    if Entity:TryCopyEntityComponent(self.parent, self.entity, "AppearanceOverride") then
        -- Type is special Appearance Edit Enhanced thing?
        if self.entity.GameObjectVisual.Type ~= 2 then
            self.entity.GameObjectVisual.Type = 2
            self.entity:Replicate("GameObjectVisual")
        end
    end

    -- Copy actor's display name to proxy (mostly for Tavs)
    Entity:TryCopyEntityComponent(self.parent, self.entity, "DisplayName")

    if self.equipment then
        Actor:DressActor()
    end

    blockActorMovement(self.parent)
end

-- MAIN METHODS
--------------------------------------------------------------


-- Set ups the actor like  detaching them from the group etc.
function Actor:Setup()

    Osi.Transform(self.entity, Entity:GetLookTemplate(self.parent), "296bcfb3-9dab-4a93-8ab1-f1c53c6674c9")
    self.visual = self.entity.OriginalTemplate
    Osi.SetDetached(self.entity, 1)
    blockActorMovement(self.entity)

    -- Copy Voice component to the proxy because Osi.CreateAtObject does not do this and we want the proxy to play vocals
    Entity:TryCopyEntityComponent(self.parent, self.entity, "Voice")

    -- Copy MaterialParameterOverride component if present.
    -- This fixes the white Shadowheart going back to her original black hair as a proxy.
    Entity:TryCopyEntityComponent(self.parent, self.entity, "MaterialParameterOverride")

    Osi.ApplyStatus(self.entity, "SEX_ACTOR", -1)

    -- Wait for 4 seconds for everything to finalize, then call the last step of the finalize function
    Ext.Timer.WaitFor(200, finalizeSetup(self))

end



-- Cleans up the actor
function Actor:Destroy()

    Osi.StopAnimation(self.entity, 1)
    Osi.TeleportToPosition(self.entity, 0,0,0)
    Osi.SetOnStage(self.entity, 0) -- to diable AI
    Osi.RequestDeleteTemporary(self.entity)

    -- Then destroy element from Scene.lua saved actors table
    
end






function Actor:CopyEquipmentFromParent()
    local currentArmorSet = Osi.GetArmorSet(self.parent)

    local copySlots = {}
    if currentArmorSet == 0 then -- "Normal" armour set
        copySlots = { "Boots", "Breast", "Cloak", "Gloves", "Amulet", "MeleeMainHand", "MeleeOffHand", "RangedMainHand", "RangedOffHand", "MusicalInstrument" }

        -- If the actor has "Hide Helmet" option off in the inventory...
        if Entity:TryGetEntityValue(self.parent, "ServerCharacter", "PlayerData", "HelmetOption") ~= 0 then
            copySlots[#copySlots + 1] = "Helmet"
        end
    elseif currentArmorSet == 1 then -- "Vanity" armour set
        copySlots = { "Underwear", "VanityBody", "VanityBoots" }
    end

    local copiedEquipment = {}
    for _, slotName in ipairs(copySlots) do
        local gearPiece = Osi.GetEquippedItem(self.parent, slotName)
        if gearPiece then
            local gearTemplate = Osi.GetTemplate(gearPiece)
            Osi.TemplateAddTo(gearTemplate, self.entity, 1, 0)
            copiedEquipment[#copiedEquipment + 1] = { Template = gearTemplate, SourceItem = gearPiece } 
        end
    end

    if #copiedEquipment > 0 then
        self.equipment = copiedEquipment
        self.armour = currentArmorSet
    end
end

function Actor:DressActor()
    Osi.SetArmourSet(self.entity, self.armour)

    for _, itemData in ipairs(self.CopiedEquipment) do
        local item = Osi.GetItemByTemplateInInventory(itemData.Template, self.entity)
        if item then
            -- Copy the dye applied to the source item
            TryCopyEntityComponent(itemData.SourceItem, item, "ItemDye")

            Osi.Equip(self.entity, item)
        else
            -- _P("[SexActor.lua] SexActor_DressProxy: couldn't find an item of template " .. itemTemplate .. " in the proxy")
        end
    end

    self.CopiedArmourSet = nil
    self.CopiedEquipment = nil
end