
local FLAG_COMPANION_IN_CAMP = "161b7223-039d-4ebe-986f-1dcd9a66733f"

local function RemoveSexPositionSpells(actor)
    TryRemoveSpell(actor, "StraightAnimationsContainer")
    TryRemoveSpell(actor, "LesbianAnimationsContainer")
    TryRemoveSpell(actor, "FemaleMasturbationContainer")
    TryRemoveSpell(actor, "MaleMasturbationContainer")
    TryRemoveSpell(actor, "zzzEndSex")
    TryRemoveSpell(actor, "zzzStopMasturbating")
    TryRemoveSpell(actor, "CameraHeight")
    TryRemoveSpell(actor, "ChangeLocationPaired")
    TryRemoveSpell(actor, "ChangeLocationSolo")
    TryRemoveSpell(actor, "zzSwitchPlaces")
end

local function BlockActorMovement(actor)
    Osi.AddBoosts(actor, "ActionResourceBlock(Movement)", "", "")
end

local ORGASM_SOUNDS = {
    "Player_Races_Voice_Combat_Recover",
    "Player_Races_Voice_Combat_Recover_Chance",
    "Player_Races_Voice_Combat_Recover_Cinematics",
    "Player_Races_Voice_Gen_Recover",
    "Player_Races_Voice_Gen_Recover_Cinematics"
}

BODY_SCALE_DELAY = 2000

local BODY_SCALE_STATUSES = {
    -- The list of statuses below was copied from OnApplyFunctors data of ALCH_ELIXIR_ENLARGE entry in
    -- <unpacked game data>/Gustav/Public/Honour/Stats/Generated/Data/Status_BOOST.txt
    "ENLARGE",
    "ENLARGE_DUERGAR",
    "REDUCE",
    "REDUCE_DUERGAR",
    "WYR_POTENTDRINK_SIZE_ENLARGE",
    "WYR_POTENTDRINK_SIZE_REDUCE",
    "MAG_COMBAT_QUARTERSTAFF_ENLARGE",
    "MAG_GIANT_SLAYER_LEGENDARY_ENLRAGE"
}


function SexActor_Init(actor, needsProxy, vocalTimerName, animProperties)
    local actorData = {
        Actor = actor,
        Proxy = nil,
        NeedsProxy = needsProxy,
        Animation = "",
        SoundTable = {},
        VocalTimerName = vocalTimerName,
        HasPenis = ActorHasPenis(actor),
        Strip = (animProperties["Strip"] == true and Osi.HasActiveStatus(actor, "BLOCK_STRIPPING") == 0),
        CameraScaleDown = (needsProxy and Osi.IsPartyMember(actor, 0) == 1),
    }

    actorData.BodyType = ActorScale_GetBodyType(actorData.Actor)
    actorData.HeightClass = ActorScale_GetHeightClass(actorData.BodyType)

    Osi.SetDetached(actor, 1)
    Osi.DetachFromPartyGroup(actor)

    TryRemoveSpell(actor, "StartSexContainer")
    RemoveSexPositionSpells(actor) -- Just in case

    -- Clear FLAG_COMPANION_IN_CAMP to prevent companions from teleporting to their tent while all this is happening
    if Osi.GetFlag(FLAG_COMPANION_IN_CAMP, actor) == 1 then
        Osi.ClearFlag(FLAG_COMPANION_IN_CAMP, actor)
        actorData.IsCompanionInCamp = true
    end

    return actorData
end

function SexActor_Terminate(actorData)
    if actorData.Proxy then
        -- Delete proxy
        Osi.StopAnimation(actorData.Proxy, 1)
        Osi.TeleportToPosition(actorData.Proxy, 0, 0, 0)
        Osi.SetOnStage(actorData.Proxy, 0) -- Disable AI, remove the model
        Osi.RequestDeleteTemporary(actorData.Proxy)
        actorData.Proxy = nil

        Osi.TeleportToPosition(actorData.Actor, actorData.StartX, actorData.StartY, actorData.StartZ)
        Osi.SetVisible(actorData.Actor, 1)
    else
        Osi.StopAnimation(actorData.Actor, 1)
    end

    -- Orgasm
    Osi.PlaySound(actorData.Actor, ORGASM_SOUNDS[math.random(1, #ORGASM_SOUNDS)])

    Osi.RemoveBoosts(actorData.Actor, "ActionResourceBlock(Movement)", 0, "", "")
    SexActor_StopVocalTimer(actorData)

    if actorData.OldVisualScale then
        local actorEntity = Ext.Entity.Get(actorData.Actor)
        actorEntity.GameObjectVisual.Scale = actorData.OldVisualScale
        actorEntity:Replicate("GameObjectVisual")
    end

    if SexActor_IsStripped(actorData) then
        SexActor_Redress(actorData)
    end

    RemoveSexPositionSpells(actorData.Actor)
    if Osi.IsPartyMember(actorData.Actor, 0) == 1 then
        AddMainSexSpells(actorData.Actor)
    end

    if actorData.IsCompanionInCamp then
        Osi.SetFlag(FLAG_COMPANION_IN_CAMP, actorData.Actor)
    end
    
    Osi.SetDetached(actorData.Actor, 0)

    --Fire a timer to notify other mods that a scene has ended
    SexEvent_EndSexScene(actorData)
end

function SexActor_PurgeBodyScaleStatuses(actorData)
    local result = false
    
    if actorData.CameraScaleDown or not actorData.NeedsProxy then
        -- Need to purge all statuses affecting the body scale that could expire during sex,
        -- especially if we're going to scale the body down to bring the camera closer.
        for _, status in ipairs(BODY_SCALE_STATUSES) do
            if Osi.HasAppliedStatus(actorData.Actor, status) == 1 then
                local statusToRemove = status
                if status == "MAG_GIANT_SLAYER_LEGENDARY_ENLRAGE" then
                    statusToRemove = "ALCH_ELIXIR_ENLARGE"
                end
                Osi.RemoveStatus(actorData.Actor, statusToRemove, "")
                result = true
            end
        end
    end

    return result
end

function SexActor_CreateProxyMarker(target)
    local proxyData = {}
    proxyData.MarkerX, proxyData.MarkerY, proxyData.MarkerZ = Osi.GetPosition(target)
    proxyData.Marker = Osi.CreateAtObject("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", target, 1, 0, "", 1)
    return proxyData
end

function SexActor_TerminateProxyMarker(proxyData)
    if proxyData then
        Osi.RequestDelete(proxyData.Marker)
    end
end

function SexActor_SubstituteProxy(actorData, proxyData)
    actorData.StartX, actorData.StartY, actorData.StartZ = Osi.GetPosition(actorData.Actor)

    if not actorData.NeedsProxy then
        return
    end

    -- Temporary teleport the original away a bit to give room for the proxy
    Osi.TeleportToPosition(actorData.Actor, actorData.StartX + 1.3, actorData.StartY, actorData.StartZ + 1.3, "", 0, 0, 0, 0, 1)

    local actorEntity = Ext.Entity.Get(actorData.Actor)

    actorData.Proxy = Osi.CreateAtObject(Osi.GetTemplate(actorData.Actor), proxyData.Marker, 1, 0, "", 1)

    -- Copy the actor's looks to the proxy (does not copy transforms)
    local lookTemplate = actorData.Actor
    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    local visTemplate = TryGetEntityValue(actorEntity, "GameObjectVisual", "RootTemplateId")
    local origTemplate = TryGetEntityValue(actorEntity, "OriginalTemplate", "OriginalTemplate")
    if visTemplate then
        if origTemplate then
            if origTemplate ~= visTemplate then
                lookTemplate = visTemplate
            end
        elseif origTemplate == nil then -- It's Tav?
            -- For Tavs, copy the look of visTemplate only if they are polymorphed or have AppearanceOverride component (under effect of "Appearance Edit Enhanced" mod)
            if Osi.HasAppliedStatusOfType(actorData.Actor, "POLYMORPHED") == 1 or actorEntity.AppearanceOverride then
                lookTemplate = visTemplate
            end
        end
    end
    Osi.Transform(actorData.Proxy, lookTemplate, "296bcfb3-9dab-4a93-8ab1-f1c53c6674c9")

    Osi.SetDetached(actorData.Proxy, 1)
    BlockActorMovement(actorData.Proxy)

    local proxyEntity = Ext.Entity.Get(actorData.Proxy)

    -- Copy Voice component to the proxy because Osi.CreateAtObject does not do this and we want the proxy to play vocals
    TryCopyEntityComponent(actorEntity, proxyEntity, "Voice")

    -- Copy MaterialParameterOverride component if present.
    -- This fixes the white Shadowheart going back to her original black hair as a proxy.
    TryCopyEntityComponent(actorEntity, proxyEntity, "MaterialParameterOverride")

    -- Copy actor's equipment to the proxy (it will be equipped later in SexActor_FinalizeSetup)
    if not SexActor_IsStripped(actorData) then
        SexActor_CopyEquipmentToProxy(actorData)
    end

    -- Scale party members down so the camera would be closer to the action.
    if actorData.CameraScaleDown then
        local curScale = TryGetEntityValue(actorEntity, "GameObjectVisual", "Scale")
        if curScale then
            actorData.OldVisualScale = curScale
            actorEntity.GameObjectVisual.Scale = 0.5
            actorEntity:Replicate("GameObjectVisual")
        end
    end
    Osi.ApplyStatus(actorData.Proxy, "SEX_ACTOR", -1)
end

function ChangeCameraHeight(actor)
    local actorEntity = Ext.Entity.Get(actor)
    local currentActorScale = TryGetEntityValue(actorEntity, "GameObjectVisual", "Scale")
    if currentActorScale == 0.5 then
        actorEntity.GameObjectVisual.Scale = 0.05
        actorEntity:Replicate("GameObjectVisual")
    elseif currentActorScale ~= 0.5 then
        actorEntity.GameObjectVisual.Scale = 0.5
        actorEntity:Replicate("GameObjectVisual")
    end
end

function SexActor_FinalizeSetup(actorData, proxyData)
    if actorData.Proxy then
        local actorEntity = Ext.Entity.Get(actorData.Actor)
        local proxyEntity = Ext.Entity.Get(actorData.Proxy)

        -- Support for the looks brought by Resculpt spell from "Appearance Edit Enhanced" mod.
        if TryCopyEntityComponent(actorEntity, proxyEntity, "AppearanceOverride") then
            if proxyEntity.GameObjectVisual.Type ~= 2 then
                proxyEntity.GameObjectVisual.Type = 2
                proxyEntity:Replicate("GameObjectVisual")
            end
        end

        -- Copy actor's display name to proxy (mostly for Tavs)
        TryCopyEntityComponent(actorEntity, proxyEntity, "DisplayName")
        -- TryCopyEntityComponent(actorEntity, proxyEntity, "CustomName")

        if actorData.CopiedEquipment then
            SexActor_DressProxy(actorData)
        end

        Osi.TeleportToPosition(actorData.Actor, proxyData.MarkerX, proxyData.MarkerY, proxyData.MarkerZ, "", 0, 0, 0, 0, 1)
        Osi.SetVisible(actorData.Actor, 0)
    end

    BlockActorMovement(actorData.Actor)
end

function SexActor_StartAnimation(actorData, animProperties)
    SexActor_StopVocalTimer(actorData)

    local animActor = actorData.Proxy or actorData.Actor
    if animProperties["Loop"] == true then
        Osi.PlayLoopingAnimation(animActor, "", actorData.Animation, "", "", "", "", "")
    else
        Osi.PlayAnimation(animActor, actorData.Animation)
    end

    if animProperties["Sound"] == true and #actorData.SoundTable >= 1 then
        SexActor_StartVocalTimer(actorData, 600)
    end
    
    --Update the Persistent Variable on the actor so that other mods can use this
    local actorEntity = Ext.Entity.Get(actorData.Actor)
    actorEntity.Vars.ActorData = actorData

    --Fire a timer to notify other mods that an Animation has started or changed 
    SexEvent_SexAnimationStart(actorData)
end

function SexActor_StartVocalTimer(actorData, time)
    Osi.ObjectTimerLaunch(actorData.Actor, actorData.VocalTimerName, time)
end

function SexActor_StopVocalTimer(actorData)
    Osi.ObjectTimerCancel(actorData.Actor, actorData.VocalTimerName)
end

function SexActor_PlayVocal(actorData, minRepeatTime, maxRepeatTime)
    if #actorData.SoundTable >= 1 then
        local soundActor = actorData.Proxy or actorData.Actor
        Osi.PlaySound(soundActor, actorData.SoundTable[math.random(1, #actorData.SoundTable)])
        SexActor_StartVocalTimer(actorData, math.random(minRepeatTime, maxRepeatTime))
    end
end

function SexEvent_SexAnimationStart(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_SexAnimationStart", 1)
end

function SexEvent_EndSexScene(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_EndSexScene", 1)
end

-- TODO: Move the function to a separate SexScene.lua or something
function SexActor_MoveSceneToLocation(newX, newY, newZ, casterData, targetData, scenePropObject)
    -- Do nothing if the new location is too far from the caster's start position,
    -- so players would not abuse it to get to some "no go" places.
    local dx = newX - casterData.StartX
    local dy = newY - casterData.StartY
    local dz = newZ - casterData.StartZ
    if math.sqrt(dx * dx + dy * dy + dz * dz) >= 4 then
        return
    end

    -- Move stuff
    function TryMoveObject(obj)
        if obj then
            Osi.TeleportToPosition(obj, newX, newY, newZ)
        end
    end

    Osi.SetDetached(casterData.Actor, 1)

    TryMoveObject(casterData.Proxy)
    if targetData then
        TryMoveObject(targetData.Proxy)
    end
    TryMoveObject(scenePropObject)
    TryMoveObject(casterData.Actor)
    if targetData then
        TryMoveObject(targetData.Actor)
        Osi.CharacterMoveToPosition(targetData.Actor, newX, newY, newZ, "", "")
    end

    Osi.SetDetached(casterData.Actor, 0)
end

-- TODO: Move the function to a separate SexScene.lua or something
function SexActor_InitCasterSexSpells(sceneData)
    sceneData.CasterSexSpells = {}
    sceneData.NextCasterSexSpell = 1
end

-- TODO: Move the function to a separate SexScene.lua or something
function SexActor_RegisterCasterSexSpell(sceneData, spellName)
    sceneData.CasterSexSpells[#sceneData.CasterSexSpells + 1] = spellName
end

-- TODO: Move the function to a separate SexScene.lua or something
function SexActor_AddCasterSexSpell(sceneData, casterData, timerName)
    if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
        TryAddSpell(casterData.Actor, sceneData.CasterSexSpells[sceneData.NextCasterSexSpell])

        sceneData.NextCasterSexSpell = sceneData.NextCasterSexSpell + 1
        if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
            -- A pause greater than 0.1 sec between two (Try)AddSpell calls in needed 
            -- for the spells to appear in the hotbar exactly in the order they are added.
            Osi.ObjectTimerLaunch(casterData.Actor, timerName, 200)
        end
    end
end


-------------------------------------------------------------------------------
          -- STRIPPING --
-------------------------------------------------------------------------------

local STRIP_SLOTS = { "Boots", "Breast", "Cloak", "Gloves", "Helmet", "Underwear", "VanityBody", "VanityBoots", "MeleeMainHand", "MeleeOffHand", "RangedMainHand", "RangedOffHand" }

function SexActor_IsStripped(actorData)
    if actorData.GearSet then
        return true
    end
    return false
end

function SexActor_Strip(actorData)
    actorData.OldArmourSet = Osi.GetArmourSet(actorData.Actor)
    Osi.SetArmourSet(actorData.Actor, 1)
    
    local currentEquipment = {}
    for _, slotName in ipairs(STRIP_SLOTS) do
        local gearPiece = Osi.GetEquippedItem(actorData.Actor, slotName)
        if gearPiece then
            Osi.LockUnequip(gearPiece, 0)
            Osi.Unequip(actorData.Actor, gearPiece)
            currentEquipment[#currentEquipment+1] = gearPiece
        end
    end
    actorData.GearSet = currentEquipment
end

function SexActor_Redress(actorData)
    Osi.SetArmourSet(actorData.Actor, actorData.OldArmourSet)

    for _, item in ipairs(actorData.GearSet) do
        Osi.Equip(actorData.Actor, item)
    end
    actorData.GearSet = nil
end

function SexActor_CopyEquipmentToProxy(actorData)
    local currentArmourSet = Osi.GetArmourSet(actorData.Actor)

    local copySlots = {}
    if currentArmourSet == 0 then -- "Normal" armour set
        copySlots = { "Boots", "Breast", "Cloak", "Gloves", "Amulet", "MeleeMainHand", "MeleeOffHand", "RangedMainHand", "RangedOffHand", "MusicalInstrument" }

        -- If the actor has "Hide Helmet" option off in the inventory...
        if TryGetEntityValue(actorData.Actor, "ServerCharacter", "PlayerData", "HelmetOption") ~= 0 then
            copySlots[#copySlots + 1] = "Helmet"
        end
    elseif currentArmourSet == 1 then -- "Vanity" armour set
        copySlots = { "Underwear", "VanityBody", "VanityBoots" }
    end

    local copiedEquipment = {}
    for _, slotName in ipairs(copySlots) do
        local gearPiece = Osi.GetEquippedItem(actorData.Actor, slotName)
        if gearPiece then
            local gearTemplate = Osi.GetTemplate(gearPiece)
            Osi.TemplateAddTo(gearTemplate, actorData.Proxy, 1, 0)
            copiedEquipment[#copiedEquipment + 1] = { Template = gearTemplate, SourceItem = gearPiece } 
        end
    end

    if #copiedEquipment > 0 then
        actorData.CopiedEquipment = copiedEquipment
        actorData.CopiedArmourSet = currentArmourSet
    end
end

function SexActor_DressProxy(actorData)
    Osi.SetArmourSet(actorData.Proxy, actorData.CopiedArmourSet)

    for _, itemData in ipairs(actorData.CopiedEquipment) do
        local item = Osi.GetItemByTemplateInInventory(itemData.Template, actorData.Proxy)
        if item then
            -- Copy the dye applied to the source item
            TryCopyEntityComponent(itemData.SourceItem, item, "ItemDye")

            Osi.Equip(actorData.Proxy, item)
        else
            _P("SexActor_DressProxy: couldn't find an item of template " .. itemTemplate .. " in the proxy")
        end
    end

    actorData.CopiedArmourSet = nil
    actorData.CopiedEquipment = nil
end
