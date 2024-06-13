    -----------------------------------------------------------------------------------------------------------------------------------------
                                                ---- Genital Functions ----
    -----------------------------------------------------------------------------------------------------------------------------------------

    -- Manual Genital changing
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_)
        -- If UI is used then use UI listener instead
        -- Check wether spell is in container Change Genitals
        local containerID = Ext.Stats.Get(spell).SpellContainerID
        if containerID == "Change_Genitals" then
        -- Transform genitals
            local newGenital = Genitals:GetNextGenital(spell, caster)
            Genitals:OverrideGenital(newGenital, caster)
        end
    end)

    -- Genital Settings
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_)
        -- If UI is used then use UI listener instead
        if spell == "Auto_Erections" then
            Genitals:SetAutoErection(1)
        elseif spell == "Manual_Erections" then
            Genitals:SetAutoErection(0)
        end
    end)







----------------------------------------------------------------------------------------------------
-- 
-- 									Automatic Erections Assigning
-- 								  Only MrFunSize supported for now
--
----------------------------------------------------------------------------------------------------


-- TODO - rewrite for variable amount of Sex Havers

    -- Auto-Erections handling on Sex start
    -- TODO - access Scene/PairsData instead
    local sexPairs = {}
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
        local autoErections = GetAutoErection()
        if (autoErections == 1) and (spell == "AskForSex")  then
            local casterGenital = Genitals:GetCurrentGenital(caster)
            local targetGenital

            if not IsNPC(target) then
                targetGenital = Genitals:GetCurrentGenital(target)
            end

            local pair = {caster = caster; casterGenital = casterGenital; target = target, targetGenital = targetGenital}
            table.insert(sexPairs, pair)

            if Entity:HasPenis(caster) then
                Osi.UseSpell(caster, "SimpleErections", caster)
            end

            if Entity:HasPenis(target) then
                Osi.UseSpell(target, "SimpleErections", target)
            end
        end
    end)

    -- Auto-Erections handling on Sex ending
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)


        local autoErections = GetAutoErection()


        if (autoErections == 1) and (spell == "zzzEndSex") then

            local prevGenCaster = ""
            local prevGenTarget = ""
            local target = ""

            for i, pair in ipairs(sexPairs) do
                if pair.caster == caster then
                    target = pair.target
                    prevGenCaster = pair.casterGenital
                    prevGenTarget = pair.targetGenital
                    table.remove(sexPairs, i)
                    break
                end
            end


            if caster and prevGenCaster then
                Genitals:OverrideGenital(prevGenCaster, caster)
            end

            if target and prevGenTarget then
                Genitals:OverrideGenital(prevGenTarget, target)
            end


        end
    end)

    -- Auto-Erection handling for masturbating
    -- TODO - access Scene/PairsData instead
    local masturbators = {}
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)


        local autoErections = GetAutoErection()

        if (autoErections == 1) and (spell == "StartMasturbation") then

            -- Save previous genitals
            local casterGenital = Genitals:GetCurrentGenital(caster)

            local masturbator = {caster = caster; casterGenital = casterGenital}
            table.insert(masturbators, masturbator)

            if Entity:HasPenis(caster) then
                Osi.UseSpell(caster, "SimpleErections", caster)
            end
        end

        if (autoErections == 1) and spell =="zzzStopMasturbating" then

            local previousGenital = ""
            for _, masturbator in ipairs(masturbators) do
                if masturbator.caster == caster then
                    previousGenital= masturbator.casterGenital
                end
            end

            if previousGenital then
                Genitals:OverrideGenital(previousGenital, caster)
            end

            masturbators[caster] = nil
        end
    end)
end