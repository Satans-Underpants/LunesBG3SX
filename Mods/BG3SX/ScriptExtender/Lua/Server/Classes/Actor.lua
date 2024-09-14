----------------------------------------------------------------------------------------
--
--                               For handling Actors (Proxies)
--
----------------------------------------------------------------------------------------

local initialize

-- CONSTRUCTOR
--------------------------------------------------------------

-- TODO: Check if some of these parameters can be removed/might be unused
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
        autoErection     = Ext.Entity.Get(parent).Vars.BG3SX_AutoErection == 1,
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
    Osi.RequestDeleteTemporary(self.uuid) -- Why waste time say lot word when few word to trick

    -- This may be needed again whenever we strip the entity again because we might have moved away from actors
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
    --"RootTemplateId" : "7ea87604-e604-4a6d-a7ac-b7b2f293c000" -- Keep these for quick debug if Wyll ever breaks again ;_;
    --"VisualTemplate" : "3773c64c-c5a9-9baf-1b85-6bee029ee044"
    local visTemplate = Entity:TryGetEntityValue(self.parent, nil, {"GameObjectVisual", "RootTemplateId"})
    local origTemplate = Entity:TryGetEntityValue(self.parent, nil, {"OriginalTemplate", "OriginalTemplate"})
    local looksTemplate = self.parent

    local parentEntity = Ext.Entity.Get(self.parent)

    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    if visTemplate then
        if origTemplate then
            if origTemplate ~= visTemplate then
                looksTemplate = visTemplate
            end
        else -- Else it might be Tav
            -- For Tavs, copy the look of visTemplate only if they are polymorphed 
            if Osi.HasAppliedStatusOfType(self.parent, "POLYMORPHED") == 1 then
                looksTemplate = visTemplate
            -- or have AppearanceOverride component (under effect of "Appearance Edit Enhanced" mod)
            elseif parentEntity.AppearanceOverride then
                SatanPrint(GLOBALDEBUG, "is resculpted")
                looksTemplate = visTemplate
            end
        end
    end
    return looksTemplate
end


function Actor:CopyEntityAppearanceOverrides()
    local entity = Ext.Entity.Get(self.uuid)
    if Entity:TryCopyEntityComponent(self.parent, self.uuid, "AppearanceOverride") then
        -- Type is special Appearance Edit Enhanced thing?
        Entity:TryCopyEntityComponent(self.parent, self.uuid, "GameObjectVisual")
        if entity.GameObjectVisual and entity.GameObjectVisual.Type ~= 0 then
            entity.GameObjectVisual.Type = 0
            entity:Replicate("GameObjectVisual")
        elseif not entity.GameObjectVisual then
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
    -- Osi.Transform(self.uuid, looksTemplate, "296bcfb3-9dab-4a93-8ab1-f1c53c6674c9") -- Invoke Duplicity

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
        
        -- TODO: Check if this might still be needed at some point
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

    Ext.ModEvents.BG3SX.ActorDressed:Throw({uuid = self.uuid, eq = self.equipment})

    -- self.armour = nil
    -- self.equipment = nil
end

----------------------------------------------------------------------------------------------------
-- 
-- 									 Actor initilization
-- 
----------------------------------------------------------------------------------------------------

-- Set ups the actor like  detaching them from the group etc.
initialize = function(self)
    Ext.ModEvents.BG3SX.ActorInit:Throw({self.uuid})
    
    Osi.SetDetached(self.uuid, 1)
    Osi.ApplyStatus(self.uuid, "BG3SX_SEXACTOR", -1) -- Marks them for SweatySex and IdleExpressions - TODO: Change those mods to just get an entities actor and do their thing without the boost
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
    
    Ext.ModEvents.BG3SX.ActorCreated:Throw({self})
end