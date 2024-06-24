----------------------------------------------------------------------------------------
--
--                               For handling Actors (Proxies)
--
----------------------------------------------------------------------------------------

Actor = {}
Actor.__index = Actor
local initialize

-- CONSTRUCTOR
--------------------------------------------------------------

---@param parent            Entity  - Entity that the proxy is based on
---@param genital           string  - Visual (UUID) of the actors genital
---@param autoErection      bool    - Whether auto erections are currently enabled or not
---@param isStripped        bool    - Whether actor is stripped of their clothes
---@param position          table   - Table of x,y,z coordinates
---@param rotation          table   - Table with x,y,z,w 
---@param currentAnimation  string  - UUID of animation being player
---@param uuid              string  - UUID of the actor
---@param visual            string  - UUID of a visual template
---@param equipment         table   - Table of UUIDs of equipments
---@param armour            table   - Table of UUIDs of armour (Vanity Slots)
function Actor:new(parent)
    local instance       = setmetatable({
        parent           = parent,
        genital          = Genitals:GetCurrentGenital(parent),
        autoErection     = UserSettings:GetAutoErection(parent),
        isStripped       = Entity:HasEquipment(parent),
        positon          = Osi.GetPosition(parent),
        rotation         = Osi.GetRotation(parent),
        currentAnimation = "",
        uuid             = Osi.CreateAtObject(Osi.GetTemplate(parent), self.position, 1, 0, "", 1),
        visual           = "",
        equipment        = {},
        armour           = {},
    }, Actor)

    initialize(self) -- Automatically calls the Itinitialize function on creation

    return instance
end

-- METHODS
--------------------------------------------------------------



-- META
--------------------------------------------------------------


-- Cleans up the actor
function Actor:Destroy()

    Osi.StopAnimation(self.entity, 1)
    Osi.TeleportToPosition(self.entity, 0,0,0) -- hide from viewer
    Osi.SetOnStage(self.entity, 0) -- to disable AI
    Osi.RequestDeleteTemporary(self.entity)


    -- Then destroy element from Scene.lua saved actors table
    
end

-- Helpers
--------------------------------------------------------------




-- Actor Movement
--------------------------------------------------------------


-- Blocks the actors movement
---@param entity string  - uuid of entity
local function disableActorMovement(entity)
    Osi.AddBoosts(entity, "ActionResourceBlock(Movement)", "", "")
end

-- Unlocks movement
---@param entity string  - uuid of entity
local function enableActorMovement(entity)
    Osi.RemoveBoosts(entity, "ActionResourceBlock(Movement)", 0, "", "")
end


-- Visuals
--------------------------------------------------------------

--- Gets parent entities looks including attachments like Wylls Horns
---@return lookTemplate string   - uuid - The looks of a parent entity
function Actor:GetLooks()
    local visTemplate = Entity:TryGetEntityValue(self.parent, "GameObjectVisual", "RootTemplateId", nil, nil)
    local origTemplate = Entity:TryGetEntityValue(self.parent, "OriginalTemplate", "OriginalTemplate", nil, nil)

    local lookTemplate = self.parent
    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    if visTemplate then
        if origTemplate then
            if origTemplate ~= visTemplate then
                lookTemplate = visTemplate
            end
        elseif origTemplate == nil then -- It's Tav?
            -- For Tavs, copy the look of visTemplate only if they are polymorphed or have AppearanceOverride component (under effect of "Appearance Edit Enhanced" mod)
            if Osi.HasAppliedStatusOfType(self.parent, "POLYMORPHED") == 1 or self.parent.AppearanceOverride then
                lookTemplate = visTemplate
            end
        end
    end
    return lookTemplate
end


--- Copies the equipment from the parent entity to the actor
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


--- Dresses an actor based on which equipment/armour (vanity slots) have been saved on it (BG3SX_ToggleStrippingBlock)
function Actor:DressActor()
    -- Apparently there is a function to equip an ArmourSet directly but not Equipment
    Osi.SetArmourSet(self.entity, self.armour) -- Equips a set of possibly copied armour

    for _, itemData in ipairs(self.equipment) do -- Equips every item found in possibly copied equipment table
        local item = Osi.GetItemByTemplateInInventory(itemData.Template, self.entity)
        if item then
            -- Copy the dye applied to the source item
            TryCopyEntityComponent(itemData.SourceItem, item, "ItemDye")

            Osi.Equip(self.entity, item)
        else
            -- _P("[SexActor.lua] Actor:DressActor: couldn't find an item of template " .. itemTemplate .. " in the proxy")
        end
    end

    Ext.Net.BroadcastMessage("BG3SX_ActorDressed", Ext.Json.Stringify({self, self.equipment})) -- MOD EVENT

    self.armour = nil
    self.equipment = nil
end


-- MAIN METHODS
--------------------------------------------------------------


-- Finalizing setup function after a delay in Actor:Setup()
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

    -- TODO: Currently parent entitiy never gets stripped if they don't have the block enabled
    -- Copy and dress actor like the parent entity
    Actor:CopyEquipmentFromParent(self.parent)
    if Osi.HasActiveStatus(entity, "BG3SX_ToggleStrippingBlock") == 0 then
        Effect:Trigger(self.parent, "DARK_JUSTICIAR_VFX")
    end
    if self.equipment then
        Actor:DressActor()
    end

    disableActorMovement(self.parent)

    Ext.Net.BroadcastMessage("BG3SX_ActorCreated", Ext.Json.Stringify(self)) -- MOD EVENT

end



-- Set ups the actor like  detaching them from the group etc.
initialize = function(self)

    Ext.Net.BroadcastMessage("BG3SX_ActorInit", Ext.Json.Stringify(self)) -- MOD EVENT

    Osi.Transform(self.entity, Actor:GetLooks(), "296bcfb3-9dab-4a93-8ab1-f1c53c6674c9")
    self.visual = self.entity.OriginalTemplate
    Osi.SetDetached(self.entity, 1)
    disableActorMovement(self.entity)

    -- Copy Voice component to the proxy because Osi.CreateAtObject does not do this and we want the proxy to play vocals
    Entity:TryCopyEntityComponent(self.parent, self.entity, "Voice")

    -- Copy MaterialParameterOverride component if present.
    -- This fixes the white Shadowheart going back to her original black hair as a proxy.
    Entity:TryCopyEntityComponent(self.parent, self.entity, "MaterialParameterOverride")

    Osi.ApplyStatus(self.entity, BG3SX_SEXACTOR, -1)

    -- Wait for 0.2 seconds for everything to finalize, then call the last step of the finalize function
    Ext.Timer.WaitFor(200, finalizeSetup(self))

end


