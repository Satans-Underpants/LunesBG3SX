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
        genital          = Genital:GetCurrentGenital(parent),
        autoErection     = UserSettings:GetAutoErection(parent),
        oldArmourSet     = Osi.GetArmourSet(parent),
        oldEquipment     = Entity:UnequipAll(parent),
        isStripped       = Entity:HasEquipment(parent),
        position          = {},
        rotation         = {},
        currentAnimation = "",
        uuid             = Osi.CreateAtObject(Osi.GetTemplate(parent), parent, 1, 0, "", 1),
        visual           = "",
        equipment        = {},
        armour           = {},
    }, Actor)
    -- Somehow can't set rootPosition/rotation within the instance, it poops itself trying to do this - rootPosition.x, rootPosition.y, rootPosition.z = Osi.GetPosition(entities[1])
    instance.position.x, instance.position.y, instance.position.z = Osi.GetPosition(parent)
    instance.rotation.x, instance.rotation.y, instance.rotation.z = Osi.GetRotation(parent)

    initialize(instance) -- Automatically calls the Itinitialize function on creation

    return instance
end

-- METHODS
--------------------------------------------------------------



-- META
--------------------------------------------------------------

-- Cleans up the actor
function Actor:Destroy()

    Osi.StopAnimation(self.uuid, 1)
    Osi.TeleportToPosition(self.uuid, 0,0,0) -- hide from viewer
    Osi.SetOnStage(self.uuid, 0) -- to disable AI
    Osi.RequestDeleteTemporary(self.uuid)

    -- Scene.lua now destroys element in saved actors table
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
function Actor:GetLooks(parent)
    --_P("DUMP PARENT 1")
    --_D(parent)
    local visTemplate = Entity:TryGetEntityValue(parent, nil, {"GameObjectVisual", "RootTemplateId"})
    local origTemplate = Entity:TryGetEntityValue(parent, nil, {"OriginalTemplate", "OriginalTemplate"})

    local lookTemplate = parent
    --_P("DUMP LOOKTEMPLATE 1")
    --_D(lookTemplate)
    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    if visTemplate then
        -- _P("Has visTemplate")
        if origTemplate then
            -- _P("Has origTemplate")
            if origTemplate ~= visTemplate then
                lookTemplate = visTemplate
                --_P("DUMP LOOKTEMPLATE 2")
                --_D(lookTemplate)
            end
        elseif origTemplate == nil then -- It's Tav?
            -- _P("origTemplate == nil")
            -- For Tavs, copy the look of visTemplate only if they are polymorphed or have AppearanceOverride component (under effect of "Appearance Edit Enhanced" mod)
            if Osi.HasAppliedStatusOfType(parent, "POLYMORPHED") == 1 or parent.AppearanceOverride then
                lookTemplate = visTemplate
                --_P("DUMP LOOKTEMPLATE 3")
                --_D(lookTemplate)
            end
        end
    end
    -- _P(lookTemplate)
    return lookTemplate
end


--- Copies the equipment from the parent entity to the actor
function Actor:CopyEquipmentFromParent()
    local currentArmorSet = Osi.GetArmourSet(self.parent)

    local copySlots = {}
    if currentArmorSet == 0 then -- "Normal" armour set
        copySlots = { "Boots", "Breast", "Cloak", "Gloves", "Amulet", "MeleeMainHand", "MeleeOffHand", "RangedMainHand", "RangedOffHand", "MusicalInstrument" }

        -- If the actor has "Hide Helmet" option off in the inventory...
        if Entity:TryGetEntityValue(self.parent, nil, {"ServerCharacter", "PlayerData", "HelmetOption"}) ~= 0 then
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
            Osi.TemplateAddTo(gearTemplate, self.uuid, 1, 0)
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
    Osi.SetArmourSet(self.uuid, self.oldArmourSet) -- Equips a set of possibly copied armour

    --_D(self.oldEquipment)
    for _, itemData in pairs(self.oldEquipment) do -- Equips every item found in possibly copied equipment table
        local item = Osi.GetItemByTemplateInInventory(itemData, self.uuid)
        if item then
            -- Copy the dye applied to the source item
            TryCopyEntityComponent(itemData.SourceItem, item, "ItemDye")

            Osi.Equip(self.uuid, item)
            table.insert(self.equipment, item)
        else
            -- _P("[SexActor.lua] Actor:DressActor: couldn't find an item of template " .. itemTemplate .. " in the proxy")
        end
    end

    -- Ext.Net.BroadcastMessage("BG3SX_ActorDressed", Ext.Json.Stringify({self, self.equipment})) -- SE EVENT
    Event:new("BG3SX_ActorDressed", {self.uuid, self.equipment}) -- MOD EVENT - Events.lua

    -- self.armour = nil
    -- self.equipment = nil
end


-- MAIN METHODS
--------------------------------------------------------------


-- Finalizing setup function after a delay in Actor:Setup()
local function finalizeSetup(self)

    -- Support for the looks brought by Resculpt spell from "Appearance Edit Enhanced" mod.
    if Entity:TryCopyEntityComponent(self.parent, self.uuid, "AppearanceOverride") then
        -- Type is special Appearance Edit Enhanced thing?
        if self.uuid.GameObjectVisual and self.uuid.GameObjectVisual.Type ~= 2 then
            self.uuid.GameObjectVisual.Type = 2
            self.uuid:Replicate("GameObjectVisual")
        end
    end

    -- Copy actor's display name to proxy (mostly for Tavs)
    Entity:TryCopyEntityComponent(self.parent, self.uuid, "DisplayName")

    -- TODO: Currently parent entitiy never gets stripped if they don't have the block enabled
    -- Copy and dress actor like the parent entity
    self:CopyEquipmentFromParent()
    if Osi.HasActiveStatus(self.parent, "BG3SX_ToggleStrippingBlock") == 0 then
        Effect:Trigger(self.parent, "DARK_JUSTICIAR_VFX")
    end
    if self.equipment then
        self:DressActor()
    end

    disableActorMovement(self.parent)

    -- Ext.Net.BroadcastMessage("BG3SX_ActorCreated", Ext.Json.Stringify(self)) -- SE EVENT
    Event:new("BG3SX_ActorCreated", self) -- MOD EVENT - Events.lua

end



-- Set ups the actor like  detaching them from the group etc.
initialize = function(self)

    -- Ext.Net.BroadcastMessage("BG3SX_ActorInit", Ext.Json.Stringify(self)) -- SE EVENT
    Event:new("BG3SX_ActorInit", self) -- MOD EVENT - Events.
    -- _D(self)

    Osi.Transform(self.uuid, Actor:GetLooks(self.parent), "296bcfb3-9dab-4a93-8ab1-f1c53c6674c9")
    self.visual = self.uuid.OriginalTemplate
    Osi.SetDetached(self.uuid, 1)
    disableActorMovement(self.uuid)

    -- Copy Voice component to the proxy because Osi.CreateAtObject does not do this and we want the proxy to play vocals
    Entity:TryCopyEntityComponent(self.parent, self.uuid, "Voice")

    -- Copy MaterialParameterOverride component if present.
    -- This fixes the white Shadowheart going back to her original black hair as a proxy.
    Entity:TryCopyEntityComponent(self.parent, self.uuid, "MaterialParameterOverride")

    Osi.ApplyStatus(self.uuid, "BG3SX_SEXACTOR", -1)

    -- Wait for 0.2 seconds for everything to finalize, then call the last step of the finalize function
    Ext.Timer.WaitFor(200, finalizeSetup(self))

end


