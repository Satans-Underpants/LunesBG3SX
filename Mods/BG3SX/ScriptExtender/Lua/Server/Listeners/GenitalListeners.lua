-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Genital Functions ----
-----------------------------------------------------------------------------------------------------------------------------------------

-- Manual Genital changing
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_)
    -- If UI is used then use UI listener instead
    -- Check wether spell is in container Change Genitals
    local containerID = Ext.Stats.Get(spell).SpellContainerID
    if containerID == "BG3SX_ChangeGenitals" then
    -- Transform genitals
        local newGenital = Genital:GetNextGenital(spell, caster)
        Genital:OverrideGenital(newGenital, caster)
    end
end)

-- Genital Settings
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_)
    -- If UI is used then use UI listener instead
    if spell == "BG3SX_AutoErections" then
        UserSettings:SetAutoErection(1)
    elseif spell == "BG3SX_ManualErections" then
        UserSettings:SetAutoErection(0)
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
    local autoErections = UserSettings:GetAutoErection()
    if (autoErections == 1) and (spell == "BG3SX_AskForSex")  then
        local casterGenital = Genital:GetCurrentGenital(caster)
        local targetGenital

        if not Entity:IsNPC(target) then
            targetGenital = Genital:GetCurrentGenital(target)
        end

        local pair = {caster = caster; casterGenital = casterGenital; target = target, targetGenital = targetGenital}
        table.insert(sexPairs, pair)

        if Entity:HasPenis(caster) then
            Osi.UseSpell(caster, "BG3SX_SimpleErections", caster)
        end

        if Entity:HasPenis(target) then
            Osi.UseSpell(target, "BG3SX_SimpleErections", target)
        end
    end
end)

-- Auto-Erections handling on Sex ending
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
    local autoErections = UserSettings:GetAutoErection()

    if (autoErections == 1) and (spell == "BG3SX_StopAction") then

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
            Genital:OverrideGenital(prevGenCaster, caster)
        end

        if target and prevGenTarget then
            Genital:OverrideGenital(prevGenTarget, target)
        end
    end
end)


-- Auto-Erection handling for masturbating
-- TODO - access Scene/PairsData instead
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
    local autoErections = UserSettings:GetAutoErection()
    

    if (autoErections == 1) and (spell == "BG3SX_StartMasturbating") then
        -- Save previous genitals
        local casterGenital = Genital:GetCurrentGenital(caster)
        local masturbator = {caster = caster; casterGenital = casterGenital}
        table.insert(sexPairs, masturbator)

        if Entity:HasPenis(caster) then
            Osi.UseSpell(caster, "BG3SX_SimpleErections", caster)
        end
    end

    if (autoErections == 1) and spell =="BG3SX_StopMasturbating" then
        local previousGenital = ""

        for _, masturbator in ipairs(sexPairs) do
            if masturbator.caster == caster then
                previousGenital= sexPairs.casterGenital
            end
        end

        if previousGenital then
            Genital:OverrideGenital(previousGenital, caster)
        end

        sexPairs[caster] = nil
    end
end)