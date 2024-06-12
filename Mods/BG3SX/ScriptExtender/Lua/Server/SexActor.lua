
local FLAG_COMPANION_IN_CAMP = "161b7223-039d-4ebe-986f-1dcd9a66733f"

local function removeSexPositionSpells(actor) -- entity
    Osi.RemoveSpell(actor, "StraightAnimationsContainer")
    Osi.RemoveSpell(actor, "LesbianAnimationsContainer")
    Osi.RemoveSpell(actor, "GayAnimationsContainer")
    Osi.RemoveSpell(actor, "FemaleMasturbationContainer")
    Osi.RemoveSpell(actor, "MaleMasturbationContainer")
    Osi.RemoveSpell(actor, "zzzEndSex")
    Osi.RemoveSpell(actor, "zzzStopMasturbating")
    Osi.RemoveSpell(actor, "CameraHeight")
    Osi.RemoveSpell(actor, "ChangeSceneLocation")
    Osi.RemoveSpell(actor, "ChangeSceneLocation")
    Osi.RemoveSpell(actor, "zzSwitchPlaces")
end

local function BlockActorMovement(actor)
    Osi.AddBoosts(actor, "ActionResourceBlock(Movement)", "", "")
end

BODY_SCALE_DELAY = 2000


function SexActor_Init(actor, needsProxy, vocalTimerName, animProperties)
    local actorData = {
        Actor = actor,
        Proxy = nil,
        NeedsProxy = needsProxy,
        Animation = "",
        SoundTable = {},
        VocalTimerName = vocalTimerName,
        HasPenis = Entity:HasPenis(actor),
        Strip = (animProperties["Strip"] == true and Osi.HasActiveStatus(actor, "BLOCK_STRIPPING") == 0),
        CameraScaleDown = (needsProxy and Osi.IsPartyMember(actor, 0) == 1),
    }

    actorData.BodyType = Entity:GetBodyShape(actorData.Actor)
    actorData.HeightClass = Entity:GetHeightClass(actorData.BodyType)

    Osi.SetDetached(actor, 1)
    Osi.DetachFromPartyGroup(actor)

    Osi.RemoveSpell(actor, "BG3SXContainer")
    Osi.RemoveSpell(actor, "Change_Genitals")
    Osi.RemoveSpell(actor, "BG3SXOptions")
    removeSexPositionSpells(actor) -- Just in case

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
    Sex:StopVocals(actorData)

    if actorData.OldVisualScale then
        local actorEntity = Ext.Entity.Get(actorData.Actor)
        actorEntity.GameObjectVisual.Scale = actorData.OldVisualScale
        actorEntity:Replicate("GameObjectVisual")
    end

    if Entity:HasEquipment(actorData) then
        Entity:Redress(actorData)
    end

    removeSexPositionSpells(actorData.Actor)
    if Osi.IsPartyMember(actorData.Actor, 0) == 1 then
        Sex:AddMainSexSpells(actorData.Actor)
    end

    if actorData.IsCompanionInCamp then
        Osi.SetFlag(FLAG_COMPANION_IN_CAMP, actorData.Actor)
    end
    
    Osi.SetDetached(actorData.Actor, 0)

    --Fire a timer to notify other mods that a scene has ended
    Sex:EndSexSceneTimer(actorData)
end

function Entity:PurgeBodyScaleStatuses(actorData)
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

function Helper:CreateLocationMarker(target)
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

    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
    local visTemplate = Entity:TryGetEntityValue(actorEntity, "GameObjectVisual", "RootTemplateId", nil, nil)
    local origTemplate = Entity:TryGetEntityValue(actorEntity, "OriginalTemplate", "OriginalTemplate",nil ,nil)
    
    actorData.Proxy = Osi.CreateAtObject(Osi.GetTemplate(actorData.Actor), proxyData.Marker, 1, 0, "", 1)

    -- Copy the actor's looks to the proxy (does not copy transforms)
    local lookTemplate = actorData.Actor
    -- If current GameObjectVisual template does not match the original actor's template, apply GameObjectVisual template to the proxy.
    -- This copies the horns of Wyll or the look of any Disguise Self spell applied to the actor. 
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
    Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "Voice")

    -- Copy MaterialParameterOverride component if present.
    -- This fixes the white Shadowheart going back to her original black hair as a proxy.
    Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "MaterialParameterOverride")

    -- Copy actor's equipment to the proxy (it will be equipped later in SexActor_FinalizeSetup)
    if not Entity:HasEquipment(actorData) then
        Actor:CopyEquipmentFromParent(actorData)
    end

    -- Scale party members down so the camera would be closer to the action.
    if actorData.CameraScaleDown then
        local curScale = Entity:TryGetEntityValue(actorEntity, "GameObjectVisual", "Scale", nil, nil)
        if curScale then
            actorData.OldVisualScale = curScale
            actorEntity.GameObjectVisual.Scale = 0.5
            actorEntity:Replicate("GameObjectVisual")
        end
    end
    Osi.ApplyStatus(actorData.Proxy, "SEX_ACTOR", -1)
end

function Sex:ChangeCameraHeight(actor)
    local actorEntity = Ext.Entity.Get(actor)
    local currentActorScale = Entity:TryGetEntityValue(actorEntity, "GameObjectVisual", "Scale", nil, nil)
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
        if Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "AppearanceOverride") then
            if proxyEntity.GameObjectVisual.Type ~= 2 then
                proxyEntity.GameObjectVisual.Type = 2
                proxyEntity:Replicate("GameObjectVisual")
            end
        end

        -- Copy actor's display name to proxy (mostly for Tavs)
        Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "DisplayName")
        -- Entity:TryCopyEntityComponent(actorEntity, proxyEntity, "CustomName")

        if actorData.CopiedEquipment then
            Actor:DressActor(actorData)
        end

        Osi.TeleportToPosition(actorData.Actor, proxyData.MarkerX, proxyData.MarkerY, proxyData.MarkerZ, "", 0, 0, 0, 0, 1)
        Osi.SetVisible(actorData.Actor, 0)
    end

    BlockActorMovement(actorData.Actor)
end

function SexActor_StartAnimation(actorData, animProperties)
    Sex:StopVocals(actorData)

    local animActor = actorData.Proxy or actorData.Actor
    if animProperties["Loop"] == true then
        -- _P("[SexActor.lua] Begin playing looping animation: ", actorData.Animation)
        Osi.PlayLoopingAnimation(animActor, "", actorData.Animation, "", "", "", "", "")
    else
        -- _P("[SexActor.lua] Begin playing animation: ", actorData.Animation)
        Osi.PlayAnimation(animActor, actorData.Animation)
    end

    if animProperties["Sound"] == true and #actorData.SoundTable >= 1 then
        Sex:StartVocals(actorData, 600)
    end
    
    --Update the Persistent Variable on the actor so that other mods can use this
    local actorEntity = Ext.Entity.Get(actorData.Actor)
    actorEntity.Vars.ActorData = actorData

    --Fire a timer to notify other mods that an Animation has started or changed 
    Sex:SexAnimationStartTimer(actorData)
end

function Sex:StartVocals(actorData, time)
    Osi.ObjectTimerLaunch(actorData.Actor, actorData.VocalTimerName, time)
end

function Sex:StopVocals(actorData)
    Osi.ObjectTimerCancel(actorData.Actor, actorData.VocalTimerName)
end

function Sound:PlaySound(actorData, minRepeatTime, maxRepeatTime)
    if #actorData.SoundTable >= 1 then
        local soundActor = actorData.Proxy or actorData.Actor
        Osi.PlaySound(soundActor, actorData.SoundTable[math.random(1, #actorData.SoundTable)])
        Sex:StartVocals(actorData, math.random(minRepeatTime, maxRepeatTime))
    end
end

function Sex:SexAnimationStartTimer(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_SexAnimationStart", 1)
end

function Sex:EndSexSceneTimer(actorData)
    Osi.ObjectTimerLaunch(actorData.Actor, "Event_EndSexScene", 1)
end

-- TODO: Move the function to a separate SexScene.lua or something
function Scene:MoveSceneToLocation(entity, location)
    -- Do nothing if the new location is too far from the caster's start position,
    -- so players would not abuse it to get to some "no go" places.
    for _, scene in pairs(SAVEDSCENES) do
        for _, entry in pairs(scene.entities) do
            if entity == entry then
                
            end
        end
    end
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
function Sex:InitSexSpells(sceneData)
    sceneData.CasterSexSpells = {}
    sceneData.NextCasterSexSpell = 1
end

-- TODO: Move the function to a separate SexScene.lua or something
function Sex:RegisterCasterSexSpell(sceneData, spellName)
    sceneData.CasterSexSpells[#sceneData.CasterSexSpells + 1] = spellName
end

-- TODO: Move the function to a separate SexScene.lua or something
function Sex:AddSexSpells(sceneData, casterData, timerName)
    if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
        Osi.AddSpell(casterData.Actor, sceneData.CasterSexSpells[sceneData.NextCasterSexSpell])

        sceneData.NextCasterSexSpell = sceneData.NextCasterSexSpell + 1
        if sceneData.NextCasterSexSpell <= #sceneData.CasterSexSpells then
            -- A pause greater than 0.1 sec between two (Try)AddSpell calls in needed 
            -- for the spells to appear in the hotbar exactly in the order they are added.
            Osi.ObjectTimerLaunch(casterData.Actor, timerName, 200)
        end
    end
end