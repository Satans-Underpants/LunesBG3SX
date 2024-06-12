----------------------------------------------------------------------------------------------------
-- 
-- 							Mashup of SoloAnimation and PairedAnimation
-- 
----------------------------------------------------------------------------------------------------


-- CONSTRUCTOR
--------------------------------------------------------------

function Animation:new()
    local instance      = setmetatable({
    }, Animation)

    return instance
end



----------------------------------------------------------------------------------------------------
-- 
-- 							                Start 
-- 
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- 
-- 							                 End
-- 
----------------------------------------------------------------------------------------------------


-- TODO - might be done in Scene.lua

function createAnimationPairsIfNoneExist()
    if not AnimationPairs then
        AnimationPairs = {}
    end
end


--- func desc
function AnimationListeners()

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
                    Entity:UnequipAll(actorData)
                end
            end

            TryStripPairedActor(pairData.CasterData)
            TryStripPairedActor(pairData.TargetData)
            return
        end

        if timer == "PairedSexSetup" then
            pairData.ProxyData = Helper:CreateLocationMarker(pairData.Target)
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
            Sound:PlaySound(pairData.CasterData, 1500, 2500)
            return
        end

        if timer == "SexVocalTarget" then
            Sound:PlaySound(pairData.TargetData, 1500, 2500)
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
            Sex:UpdateAvailableAnimations(pairData)
            PlayPairedAnimation(pairData)
        else
            for _, newAnim in ipairs(ANIMATIONDATA) do
                if newAnim.AnimName == spell then
                    pairData.AnimProperties = newAnim
                    Sex:UpdateAvailableAnimations(pairData)
                    PlayPairedAnimation(pairData)
                    break
                end
            end
        end
    end)
    
end

Ext.Events.SessionLoaded:Subscribe(PairedAnimationListeners)


--- func desc
---@param pairData any
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


--- func desc
---@param pairData any
function TerminatePairedAnimation(pairData)
    SexActor_Terminate(pairData.CasterData)
    SexActor_Terminate(pairData.TargetData)
    SexActor_TerminateProxyMarker(pairData.ProxyData)
end


--- func desc
function TerminateAllPairedAnimations()
    for _, pairData in ipairs(AnimationPairs) do
        TerminatePairedAnimation(pairData)
    end
    AnimationPairs = {}
end


--- func desc
---@param pairData any
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

    Sex:StopVocals(pairData.CasterData)
    Sex:StopVocals(pairData.TargetData)
end


--- func desc
---@param pairData any
function Sex:UpdateAvailableAnimations(pairData)
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


--- func desc
---@param actor any
function FindPairIndexByActor(actor)
    for i = 1, #AnimationPairs do
        if AnimationPairs[i].Caster == actor or AnimationPairs[i].Target == actor then
            return i
        end
    end
    return 0
end


--- func desc
---@param actor any
---@param x any
---@param y any
---@param z any
function MovePairedSceneToLocation(actor, x, y, z)
    local pairIndex = FindPairIndexByActor(actor)
    if pairIndex < 1 then
        return
    end
    local pairData = AnimationPairs[pairIndex]

    Scene:MoveSceneToLocation(x, y, z, pairData.CasterData, pairData.TargetData)
end





--- func desc
---@param pairData any
function AddPairedCasterSexSpell(pairData)
    Sex:AddSexSpells(pairData, pairData.CasterData, "PairedAddCasterSexSpell")
end
