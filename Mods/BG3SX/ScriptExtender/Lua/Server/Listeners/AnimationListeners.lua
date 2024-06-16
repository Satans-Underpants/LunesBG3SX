
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
            for _, newAnim in ipairs(ANIMATIONS) do
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
