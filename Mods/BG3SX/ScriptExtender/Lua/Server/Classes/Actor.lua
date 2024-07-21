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

---@param parent            string  - uuid of Entity that the proxy is based on
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
        oldEquipment     = Entity:GetEquipment(parent),
        isStripped       = Entity:HasEquipment(parent),
        position         = {},
        rotation         = {},
        currentAnimation = "",
        uuid             = "",
        visual           = "",
        equipment        = {},
        armour           = {},
    }, Actor)
    local scene = Scene:FindSceneByEntity(parent) -- Warning: Don't create scene reference in actor metatable or dumps of a scene will infinite loop
    instance.position = scene.rootPosition
    instance.uuid = Osi.CreateAt(Osi.GetTemplate(parent), instance.position.x, instance.position.y, instance.position.z, 1, 0, "")

    initialize(instance)

    return instance
end

-- Destroy()
--------------------------------------------------------------

-- TODO: Might remove the function and just call Osi.RequestDeleteTemporary in Scene:Destroy() instead
-- Cleans up the actor and removes it from a scene
function Actor:Destroy()
    -- Osi.StopAnimation(self.uuid, 1)
    -- Osi.TeleportToPosition(self.uuid, 0,0,0) -- hide from viewer
    -- Osi.SetOnStage(self.uuid, 0) -- to disable AI
    Osi.RequestDeleteTemporary(self.uuid)

    -- I disabled stripping the entity/parent and only unequip the actor now
    -- if Entity:HasEquipment(self.parent) then -- Requip everything which may have been removed during scene initialization
    --     Entity:Redress(self.parent, self.oldArmourSet, self.oldEquipment)
    -- end

    -- Scene.lua now destroys element in saved actors table
end


-- Visuals
--------------------------------------------------------------

--- Gets parent entities looks including attachments like Wylls Horns
---@return lookTemplate string   - uuid - The looks of a parent entity
function Actor:GetLooks()
    local visTemplate = Entity:TryGetEntityValue(self.parent, nil, {"GameObjectVisual", "RootTemplateId"})
    --"RootTemplateId" : "7ea87604-e604-4a6d-a7ac-b7b2f293c000"
    --"VisualTemplate" : "3773c64c-c5a9-9baf-1b85-6bee029ee044"
    local origTemplate = Entity:TryGetEntityValue(self.parent, nil, {"OriginalTemplate", "OriginalTemplate"})
    local looksTemplate = self.parent

    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    if visTemplate then
        if origTemplate then
            if origTemplate ~= visTemplate then
                _P("CHECK 1")
                _P("VisualTemplate: ", visTemplate)
                _P("OriginalTempalte: ", origTemplate)
                looksTemplate = visTemplate
            end
        else -- It's Tav?
            -- For Tavs, copy the look of visTemplate only if they are polymorphed or have AppearanceOverride component (under effect of "Appearance Edit Enhanced" mod)
            if Osi.HasAppliedStatusOfType(self.parent, "POLYMORPHED") == 1 or self.parent.AppearanceOverride then
                _P("CHECK 2")
                looksTemplate = visTemplate
            end
        end
    end
    _P("CHECK 3")
    _P("Returning looksTemplate: ", looksTemplate)
    return looksTemplate
    --return self.parent
end


function Actor:CopyEntityAppearanceOverrides()
    

    if Entity:TryCopyEntityComponent(self.parent, self.uuid, "AppearanceOverride") then
        -- Type is special Appearance Edit Enhanced thing?
        Entity:TryCopyEntityComponent(self.parent, self.uuid, "GameObjectVisual")
        if self.uuid.GameObjectVisual and self.uuid.GameObjectVisual.Type ~= 2 then
            self.uuid.GameObjectVisual.Type = 2
            self.uuid:Replicate("GameObjectVisual")
        elseif not self.uuid.GameObjectVisual then
            _P("[BG3SX][Actor.lua] Trying to create Actor for entity without GameObjectVisual Component.")
            _P("[BG3SX][Actor.lua] This can happen with some scenery NPC's.")
            _P("[BG3SX][Actor.lua] Safeguards have been put in place, nothing will break. Please end the Scene and choose another target.")
        end
    end
end


-- TODO - for some reason Sex mod breaks the disguise spell?????????
-- TODO - maybe combine CopyEntityAppearanceOverride Check and NPC warning to the Erection function
-- TODO - Make sections within into their own functions
-- TODO - Change type from 2 back to original type since it screws with other game stuff 
-- https://discord.com/channels/1211056047784198186/1211069623835828345/1262896149962952936
function Actor:TransformAppearance()
    
    -- Get Looks
    ----------------------------------------------------------------------------
    self:CopyEntityAppearanceOverrides()
    local looksTemplate = self:GetLooks()
    Osi.Transform(self.uuid, looksTemplate, "8ec4cf19-e98e-465e-8e46-eba3a6204a39") -- Stripped


    -- Get Equipment
    ----------------------------------------------------------------------------
    local isStripper = Sex:IsStripper(self.parent)
    if not isStripper then
        self:DressActor()
    end
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
        --_D(self.equipment)
        self.armour = currentArmorSet
        --_D(self.armour)
    end
end


--- Dresses an actor based on which equipment/armour (vanity slots) have been saved on it (BG3SX_StrippingBlock)
function Actor:DressActor()
    local parentArmour = Osi.GetArmourSet(self.parent)
    local parentEquipment = Entity:GetEquipment(self.parent)
    -- Apparently there is a function to equip an ArmourSet directly but not Equipment
    Osi.SetArmourSet(self.uuid, parentArmour) -- Equips a set of possibly copied armour
    for _, item in pairs(parentEquipment) do -- Equips every item found in possibly copied equipment table
        local itemTemplate = Osi.GetTemplate(item)

        Osi.TemplateAddTo(itemTemplate, self.uuid, 1)

        -- Adding item to inventory takes some time. Cannot be retrieved without delay
        Ext.Timer.WaitFor(200, function() 
            local copiedItem = Osi.GetItemByTemplateInInventory(itemTemplate, self.uuid) 

            Entity:TryCopyEntityComponent(item, copiedItem, "ItemDye")
            Osi.Equip(self.uuid, copiedItem)        
        end)
        
        --local item = Osi.GetItemByTemplateInInventory(Osi.GetTemplate(itemData), self.parent)
        --if item then
        --    -- Copy the dye applied to the source item
        --    Entity:TryCopyEntityComponent(itemData.SourceItem, item, "ItemDye")
        --    
        --    Osi.Equip(self.uuid, item)
        --    table.insert(self.equipment, item)
        --else
        --    if item == nil then
        --        item = "nil"
        --        _P("[SexActor.lua] Actor:DressActor - Couldn't find an item of template ","'nil'"," on the actor")
        --    else
        --        _P("[SexActor.lua] Actor:DressActor - Couldn't find an item of template " .. item .. " on the actor")
        --    end
        --end
    end


    Event:new("BG3SX_ActorDressed", {self.uuid, self.equipment})

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

    -- TODO: Maybe re-enable - Disabled while testing new Osi.Transform rule to see if we can trim this
    ---------------------------------------------------
    -- TODO: Currently parent entitiy never gets stripped if they don't have the block enabled
    -- Copy and dress actor like the parent entity
    -- self:CopyEquipmentFromParent()
    -- if Osi.HasActiveStatus(self.parent, "BG3SX_StrippingBlock") == 0 then
    --     Effect:Trigger(self.parent, "DARK_JUSTICIAR_VFX")
    -- end
    -- if self.equipment then
    --     self:DressActor()
    -- end

    Event:new("BG3SX_ActorCreated", self)
end

-- Set ups the actor like  detaching them from the group etc.
initialize = function(self)
    Event:new("BG3SX_ActorInit", self) -- MOD EVENT - Events.
    
    Osi.SetDetached(self.uuid, 1)
    Osi.ApplyStatus(self.uuid, "BG3SX_SEXACTOR", -1) -- Gives them facial animations
    Entity:ToggleWalkThrough(self.uuid)
    -- Entity:ToggleMovement(self.uuid) -- TODO: fix this
    Osi.AddBoosts(self.uuid, "ActionResourceBlock(Movement)", "", "")

    -- Copy Voice component to the proxy because Osi.CreateAtObject does not do this and we want the actor to play vocals
    Entity:TryCopyEntityComponent(self.parent, self.uuid, "Voice")

    -- self:CopyEquipmentFromParent()

    -- Applies a shapeshift rule transform based on StrippingBlock being applied on the parent
    self:TransformAppearance()

    -- This fixes the white Shadowheart going back to her original black hair as a proxy.
    Entity:TryCopyEntityComponent(self.parent, self.uuid, "MaterialParameterOverride")

    Entity:CopyDisplayName(self.parent, self.uuid) -- Keep since shapeshiftrule doesn't actually handle this correctly
    
    Event:new("BG3SX_ActorCreated", self)
    
    -- Re-enable finalizeSetup(self) with a delay if it creates problems
    -------------------------------------
    -- Ext.Timer.WaitFor(200, finalizeSetup(self))
    -------------------------------------
end