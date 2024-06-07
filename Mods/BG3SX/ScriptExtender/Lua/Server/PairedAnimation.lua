if not AnimationPairs then
    AnimationPairs = {}
end

function StartPairedAnimation(caster, target, animProperties)
    -- Always create a proxy for targets if they are PCs or companions or some temporary party members. 
    -- It fixes the moan sounds for companions and prevents animation reset on these characters' selection in the party.
    local targetNeedsProxy = (ActorIsPlayable(target) or Osi.IsPartyMember(target, 1) == 1)

    local pairData = {
        Caster = caster,
        CasterData = SexActor_Init(caster, true, "SexVocalCaster", animProperties),
        Target = target,
        TargetData = SexActor_Init(target, true, "SexVocalTarget", animProperties), -- targetNeedsProxy
        AnimationActorHeights = "",
        AnimProperties = animProperties,
        SwitchPlaces = false,
    }

    local casterScaled = SexActor_PurgeBodyScaleStatuses(pairData.CasterData)
    local targetScaled = SexActor_PurgeBodyScaleStatuses(pairData.TargetData)

    UpdatePairedAnimationVars(pairData)

    AnimationPairs[#AnimationPairs + 1] = pairData

    local setupDelay = 400

    if pairData.CasterData.Strip or pairData.TargetData.Strip then
        if pairData.CasterData.Strip then
            Osi.ApplyStatus(caster, "DARK_JUSTICIAR_VFX", 1)
        end
        if pairData.TargetData.Strip then
            Osi.ApplyStatus(target, "DARK_JUSTICIAR_VFX", 1)
        end
        Osi.ObjectTimerLaunch(caster, "PairedSexStrip", 600)
        setupDelay = 2000
    end

    if (casterScaled or targetScaled) and setupDelay < BODY_SCALE_DELAY then
        setupDelay = BODY_SCALE_DELAY -- Give some time for the bodies to go back to their normal scale
    end
    
    if pairData.AnimProperties["Fade"] == true then
        Osi.ObjectTimerLaunch(caster, "PairedSexFade.Start", setupDelay - 200)
        Osi.ObjectTimerLaunch(caster, "PairedSexFade.End", setupDelay + 800)
        Osi.ObjectTimerLaunch(target, "PairedSexFade.Start", setupDelay - 200)
        Osi.ObjectTimerLaunch(target, "PairedSexFade.End", setupDelay + 800)
    end

    Osi.ObjectTimerLaunch(caster, "PairedSexSetup", setupDelay)

    -- Add sex control spells to the caster
    SexActor_InitCasterSexSpells(pairData)
    SexActor_RegisterCasterSexSpell(pairData, pairData.AnimContainer)
    if pairData.CasterData.HasPenis == pairData.TargetData.HasPenis then
        SexActor_RegisterCasterSexSpell(pairData, "zzSwitchPlaces")
    end
    SexActor_RegisterCasterSexSpell(pairData, "ChangeLocationPaired")
    if pairData.CasterData.CameraScaleDown then
        SexActor_RegisterCasterSexSpell(pairData, "CameraHeight")
    end
    SexActor_RegisterCasterSexSpell(pairData, "zzzEndSex")
    AddPairedCasterSexSpell(pairData)
end

function PairedAnimationListeners()

    Ext.Osiris.RegisterListener("ObjectTimerFinished", 2, "after", function(actor, timer)

        ------------------------------------
                  -- FADE TIMERS --
        ------------------------------------

        if timer == "PairedSexFade.Start" then
            Osi.ScreenFadeTo(actor, 0.1, 0.1, "AnimFade")
            return
        end

        if timer == "PairedSexFade.End" then
            Osi.ClearScreenFade(actor, 0.1, "AnimFade", 0)
            return
        end
        
        ------------------------------------
               -- ANIMATION TIMERS --
        ------------------------------------

        local pairIndex = FindPairIndexByActor(actor)
        if pairIndex < 1 then
            return
        end
        local pairData = AnimationPairs[pairIndex]

        if timer == "PairedSexStrip" then
            function TryStripPairedActor(actorData)
                if actorData.Strip then
                    Osi.ApplyStatus(actorData.Actor, "PASSIVE_WILDMAGIC_MAGICRETRIBUTION_DEFENDER", 1)
                    SexActor_Strip(actorData)
                end
            end

            TryStripPairedActor(pairData.CasterData)
            TryStripPairedActor(pairData.TargetData)
            return
        end

        if timer == "PairedSexSetup" then
            pairData.ProxyData = SexActor_CreateProxyMarker(pairData.Target)
            SexActor_SubstituteProxy(pairData.CasterData, pairData.ProxyData)
            SexActor_SubstituteProxy(pairData.TargetData, pairData.ProxyData)
            Osi.ObjectTimerLaunch(pairData.Caster, "PairedSexAnimStart", 400)
            return
        end

        if timer == "PairedSexAnimStart" then
            SexActor_FinalizeSetup(pairData.CasterData, pairData.ProxyData)
            SexActor_FinalizeSetup(pairData.TargetData, pairData.ProxyData)
            PlayPairedAnimation(pairData)
            Osi.SetDetached(pairData.Caster, 0)
            return
        end
        
        if timer == "PairedAnimTimeout" then
            StopPairedAnimation(pairData)
            return
        end

        if timer == "FinishSex" then
            TerminatePairedAnimation(pairData)
            table.remove(AnimationPairs, pairIndex)
            return
        end

        if timer == "PairedAddCasterSexSpell" then
            AddPairedCasterSexSpell(pairData)
            return
        end

        ------------------------------------
               -- SOUND TIMERS --
        ------------------------------------

        if timer == "SexVocalCaster" then
            SexActor_PlayVocal(pairData.CasterData, 1500, 2500)
            return
        end

        if timer == "SexVocalTarget" then
            SexActor_PlayVocal(pairData.TargetData, 1500, 2500)
            return
        end
        
    end)

    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
        local pairIndex = FindPairIndexByActor(caster)
        if pairIndex < 1 then
            return
        end
        local pairData = AnimationPairs[pairIndex]

        if spell == "zzzEndSex" then
            StopPairedAnimation(pairData)
        elseif spell == "zzSwitchPlaces" then
            pairData.SwitchPlaces = not pairData.SwitchPlaces
            UpdatePairedAnimationVars(pairData)
            PlayPairedAnimation(pairData)
        else
            for _, newAnim in ipairs(SexAnimations) do
                if newAnim.AnimName == spell then
                    pairData.AnimProperties = newAnim
                    UpdatePairedAnimationVars(pairData)
                    PlayPairedAnimation(pairData)
                    break
                end
            end
        end
    end)
    
end

Ext.Events.SessionLoaded:Subscribe(PairedAnimationListeners)

function PlayPairedAnimation(pairData)
    SexActor_StartAnimation(pairData.CasterData, pairData.AnimProperties)
    SexActor_StartAnimation(pairData.TargetData, pairData.AnimProperties)

    -- Timeout timer
    local animTimeout = pairData.AnimProperties["AnimLength"] * 1000
    if animTimeout > 0 then
        Osi.ObjectTimerLaunch(pairData.Caster, "PairedAnimTimeout", animTimeout)
    else
        Osi.ObjectTimerCancel(pairData.Caster, "PairedAnimTimeout")
    end
end

function TerminatePairedAnimation(pairData)
    SexActor_Terminate(pairData.CasterData)
    SexActor_Terminate(pairData.TargetData)
    SexActor_TerminateProxyMarker(pairData.ProxyData)
end

function TerminateAllPairedAnimations()
    for _, pairData in ipairs(AnimationPairs) do
        TerminatePairedAnimation(pairData)
    end
    AnimationPairs = {}
end

function StopPairedAnimation(pairData)
    Osi.ObjectTimerCancel(pairData.Caster, "PairedAnimTimeout")
    Osi.ObjectTimerCancel(pairData.Caster, "PairedSexFade.Start")
    Osi.ObjectTimerCancel(pairData.Caster, "PairedSexFade.End")
    Osi.ObjectTimerCancel(pairData.Target, "PairedSexFade.Start")
    Osi.ObjectTimerCancel(pairData.Target, "PairedSexFade.End")

    Osi.ScreenFadeTo(pairData.Caster, 0.1, 0.1, "AnimFade")
    Osi.ScreenFadeTo(pairData.Target, 0.1, 0.1, "AnimFade")

    Osi.ObjectTimerLaunch(pairData.Caster, "FinishSex", 200)
    Osi.ObjectTimerLaunch(pairData.Caster, "PairedSexFade.End", 2500)
    Osi.ObjectTimerLaunch(pairData.Target, "PairedSexFade.End", 2500)

    SexActor_StopVocalTimer(pairData.CasterData)
    SexActor_StopVocalTimer(pairData.TargetData)
end

function UpdatePairedAnimationVars(pairData)
    local topData = pairData.CasterData
    local btmData = pairData.TargetData

    if topData.HasPenis == false and btmData.HasPenis == false then
        pairData.AnimContainer = "LesbianAnimationsContainer"
    elseif topData.HasPenis == true and btmData.HasPenis == true then
        pairData.AnimContainer = "GayAnimationsContainer"
    else
        pairData.AnimContainer = "StraightAnimationsContainer"
    end

    local switchRoles = 0 -- No role switch
    if topData.HasPenis == btmData.HasPenis and pairData.SwitchPlaces then
        switchRoles = 1 -- Normal role switch
    elseif topData.HasPenis == false and btmData.HasPenis then
        switchRoles = 2 -- Forced switch for FxM pair
    end
    if switchRoles ~= 0 then
        btmData, topData = topData, btmData
    end

    local topAnimation, btmAnimation
    local heightAnimation = pairData.AnimProperties[topData.HeightClass .. "Top_" .. btmData.HeightClass .. "Btm"]
    if heightAnimation then
        topAnimation = heightAnimation.Top
        btmAnimation = heightAnimation.Btm
    else
        topAnimation = pairData.AnimProperties.FallbackTopAnimationID
        btmAnimation = pairData.AnimProperties.FallbackBottomAnimationID
    end

    -- For the initial "standing hug" animation in a FxM pair do NOT revert top/bottom roles
    if switchRoles == 2 and topAnimation == "49d78660-5175-4ed2-9853-840bb58cf34a" and btmAnimation == "10fee5b7-d674-436c-994c-616e01efcb90" then
        switchRoles = 0
        btmData, topData = topData, btmData
    end

    topData.Animation  = topAnimation
    topData.SoundTable = pairData.AnimProperties.SoundTop
    btmData.Animation  = btmAnimation
    btmData.SoundTable = pairData.AnimProperties.SoundBottom

    --Update the Persistent Variable on the actor so that other mods can use this
    local casterEnt = Ext.Entity.Get(pairData.Caster)
    local targetEnt = Ext.Entity.Get(pairData.Target)
    casterEnt.Vars.PairData = pairData
    targetEnt.Vars.PairData = pairData
end

function FindPairIndexByActor(actor)
    for i = 1, #AnimationPairs do
        if AnimationPairs[i].Caster == actor or AnimationPairs[i].Target == actor then
            return i
        end
    end
    return 0
end

function MovePairedSceneToLocation(actor, x, y, z)
    local pairIndex = FindPairIndexByActor(actor)
    if pairIndex < 1 then
        return
    end
    local pairData = AnimationPairs[pairIndex]

    SexActor_MoveSceneToLocation(x, y, z, pairData.CasterData, pairData.TargetData)
end

function AddPairedCasterSexSpell(pairData)
    SexActor_AddCasterSexSpell(pairData, pairData.CasterData, "PairedAddCasterSexSpell")
end
