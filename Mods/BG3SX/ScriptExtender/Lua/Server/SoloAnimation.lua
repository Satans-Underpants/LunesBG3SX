if not AnimationSolos then
    AnimationSolos = {}
end

--- func desc
---@param actor any
---@param animProperties any
function StartSoloAnimation(actor, animProperties) 
    local soloData = {
        Actor = actor,
        ActorData = SexActor_Init(actor, true, "SexVocal", animProperties),
        AnimProperties = animProperties,
        AnimContainer = "",
        AnimationProp = "",
    }

    local actorScaled = Entity:PurgeBodyScaleStatuses(soloData.ActorData)

    UpdateSoloAnimationVars(soloData)

    AnimationSolos[actor] = soloData

    local setupDelay = 400
    if actorScaled and setupDelay < BODY_SCALE_DELAY then
        setupDelay = BODY_SCALE_DELAY -- Give some time for the actor's body to go back to its normal scale
    end

    if animProperties["Fade"] == true then
        Osi.ObjectTimerLaunch(actor, "SoloSexFade.Start", setupDelay - 200)
        Osi.ObjectTimerLaunch(actor, "SoloSexFade.End", setupDelay + 800)
    end

    Osi.ObjectTimerLaunch(actor, "SoloSexSetup", setupDelay)

    -- Add sex control spells to the caster
    Sex:InitSexSpells(soloData)
    Sex:RegisterCasterSexSpell(soloData, soloData.AnimContainer)
    Sex:RegisterCasterSexSpell(soloData, "ChangeSceneLocation")
    if soloData.ActorData.CameraScaleDown then
        Sex:RegisterCasterSexSpell(soloData, "CameraHeight")
    end
    Sex:RegisterCasterSexSpell(soloData, "zzzStopMasturbating")
    AddSoloCasterSexSpell(soloData)
end


--- func desc
function SoloAnimationListeners()

    Ext.Osiris.RegisterListener("ObjectTimerFinished", 2, "after", function(actor, timer)

        ------------------------------------
                  -- FADE TIMERS --
        ------------------------------------

        if timer == "SoloSexFade.Start" then
            Osi.ScreenFadeTo(actor, 0.1, 0.1, "AnimFade")
            return
        end

        if timer == "SoloSexFade.End" then
            Osi.ClearScreenFade(actor, 0.1, "AnimFade", 0)
            return
        end

        ------------------------------------
               -- ANIMATION TIMERS --
        ------------------------------------

        local soloData = AnimationSolos[actor]
        if not soloData then
            return
        end

        if timer == "SoloSexSetup" then
            if soloData.ActorData.Strip then
                Entity:UnequipAll(soloData.ActorData)
            end
            soloData.ProxyData = Helper:CreateLocationMarker(soloData.Actor)
            SexActor_SubstituteProxy(soloData.ActorData, soloData.ProxyData)
            Osi.ObjectTimerLaunch(actor, "SoloAnimStart", 200)
            return
        end

        if timer == "SoloAnimStart" then
            SexActor_FinalizeSetup(soloData.ActorData, soloData.ProxyData)
            PlaySoloAnimation(soloData)
            Osi.SetDetached(soloData.Actor, 0)
            return
        end
        
        if timer == "SoloAnimTimeout" then
            StopSoloAnimation(soloData)
            return
        end

        if timer == "FinishMasturbating" then
            TerminateSoloAnimation(soloData)
            AnimationSolos[actor] = nil
            return
        end

        if timer == "SoloAddCasterSexSpell" then
            AddSoloCasterSexSpell(soloData)
            return
        end

        ------------------------------------
               -- SOUND TIMERS --
        ------------------------------------

        if timer == "SexVocal" then
            Sound:PlaySound(soloData.ActorData, 1500, 2500)
            return
        end
    end)

    ------------------------------------
            -- SPELL LISTENERS --
    ------------------------------------

    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
        local soloData = AnimationSolos[caster]
        if not soloData then
            return
        end

        if spell == "zzzStopMasturbating" then
            StopSoloAnimation(soloData)
        else
            for _, newAnim in ipairs(ANIMATIONDATA) do
                if newAnim.AnimName == spell then
                    soloData.AnimProperties = newAnim
                    UpdateSoloAnimationVars(soloData)
                    PlaySoloAnimation(soloData)
                    break
                end
            end
        end
    end)
end

Ext.Events.SessionLoaded:Subscribe(SoloAnimationListeners)


--- func desc
---@param soloData any
function PlaySoloAnimation(soloData)
    RemoveAnimationProp(soloData)
    SexActor_StartAnimation(soloData.ActorData, soloData.AnimProperties)
    CreateAnimationProp(soloData)

    -- Timeout timer
    local animTimeout = soloData.AnimProperties["AnimLength"] * 1000
    if animTimeout > 0 then
        Osi.ObjectTimerLaunch(soloData.Actor, "SoloAnimTimeout", animTimeout)
    else
        Osi.ObjectTimerCancel(soloData.Actor, "SoloAnimTimeout")
    end
end


--- func desc
---@param soloData any
function TerminateSoloAnimation(soloData)
    SexActor_Terminate(soloData.ActorData)
    RemoveAnimationProp(soloData)
    SexActor_TerminateProxyMarker(soloData.ProxyData)
end


--- func desc
function TerminateAllSoloAnimations()
    for _, soloData in pairs(AnimationSolos) do
        TerminateSoloAnimation(soloData)
    end
    AnimationSolos = {}
end


--- func desc
---@param soloData any
function StopSoloAnimation(soloData)
    Osi.ObjectTimerCancel(soloData.Actor, "SoloAnimTimeout")
    Osi.ObjectTimerCancel(soloData.Actor, "SoloSexFade.Start")
    Osi.ObjectTimerCancel(soloData.Actor, "SoloSexFade.End")

    Osi.ScreenFadeTo(soloData.Actor, 0.1, 0.1, "AnimFade")

    Osi.ObjectTimerLaunch(soloData.Actor, "FinishMasturbating", 200)
    Osi.ObjectTimerLaunch(soloData.Actor, "SoloSexFade.End", 2500)
    Sex:StopVocals(soloData.ActorData)
end


-- DATA TABLE
local PLAYER_SEX_SOUNDS = {
    "BreathLongExhaleOpen_PlayerCharacter_Cine",
    "BreathLongInhaleOpen_PlayerCharacter_Cine",
    "BreathShortInhaleOpen_PlayerCharacter_Cine",
    "LoveMoanClosed_PlayerCharacter_Cine",
    "LoveMoanOpen_PlayerCharacter_Cine"
}


--- func desc
---@param ( any
function UpdateSoloAnimationVars(soloData)
    local gender

    if soloData.ActorData.HasPenis then
        soloData.AnimContainer = "MaleMasturbationContainer"
        gender = "_Male"
        soloData.ActorData.Animation = soloData.AnimProperties['FallbackTopAnimationID']
    else
        soloData.AnimContainer = "FemaleMasturbationContainer"
        gender = "_Female"
        
        soloData.ActorData.Animation = soloData.AnimProperties['FallbackBottomAnimationID']
    end

    local filteredAnim = soloData.ActorData.HeightClass..gender

    if soloData.AnimProperties[filteredAnim] then
        soloData.ActorData.Animation = soloData.AnimProperties[filteredAnim]
    end
    soloData.ActorData.SoundTable = PLAYER_SEX_SOUNDS

    --Update the Persistent Variable on the actor so that other mods can use this
    local actorEnt = Ext.Entity.Get(soloData.Actor)
    actorEnt.Vars.SoloData = soloData
end


--- func desc
---@param soloData any
function CreateAnimationProp(soloData)
    local prop = soloData.AnimProperties["AnimObject"]
    if prop then
        soloData.AnimationProp = Osi.CreateAtObject(prop, soloData.ActorData.Proxy, 1, 0, "", 1)
    end
end


--- func desc
---@param soloData any
function RemoveAnimationProp(soloData)
    if soloData.AnimationProp then
        Osi.RequestDelete(soloData.AnimationProp)
        soloData.AnimationProp = nil
    end
end


--- func desc
---@param actor any
---@param x any
---@param y any
---@param z any
function MoveSoloSceneToLocation(actor, x, y, z)
    local soloData = AnimationSolos[actor]
    if soloData then
        Scene:MoveSceneToLocation(x, y, z, soloData.ActorData, nil, soloData.AnimationProp)
    end
end


--- func desc
---@param soloData any
function AddSoloCasterSexSpell(soloData)
    Sex:AddSexSpells(soloData, soloData.ActorData, "SoloAddCasterSexSpell")
end
