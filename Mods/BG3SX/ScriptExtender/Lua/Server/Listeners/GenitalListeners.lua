-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Genital Functions ----
-----------------------------------------------------------------------------------------------------------------------------------------

-- TODO - make all of the genital spells targeted for absolute control- even over NPCs

-- Manual Genital changing
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_)
    
    -- test 
    --Genital:giveShapeshiftedErection(caster)

    -- TODO - change to giveShapeshiftedVisual
    -- this also has to be used for change genitals (othe rchange genitals spell)
    -- currently they do not reflect teh change on a shapeshifted entity

    -- If UI is used then use UI listener instead
    -- Check wether spell is in container Change Genitals
    local containerID = Ext.Stats.Get(spell).SpellContainerID
    if containerID == "BG3SX_ChangeGenitals" then
    -- Transform 

    local newGenital = Genital:GetNextGenital(spell, caster)


    --if (Ext.Entity.Get(caster).GameObjectVisual.Type == 4) then  -- check if shapeshifted
      --  Ext.Timer.WaitFor(200, function()
     --       Entity:GiveShapeshiftedVisual(caster, newGenital)
     --   end)

    --else 
        Genital:OverrideGenital(newGenital, caster)
   -- end


    end
end)

-- Genital Settings
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell,_,_,_)
    -- If UI is used then use UI listener instead
    if spell == "BG3SX_AutoErections" then
        SexUserVars:SetAutoErection(1, caster)
        print("Set autoerections to ", SexUserVars:GetAutoErection(caster))
    elseif spell == "BG3SX_ManualErections" then
        SexUserVars:SetAutoErection(0, caster)
        print("Set autoerections to ", SexUserVars:GetAutoErection(caster))
    end
end)


----------------------------------------------------------------------------------------------------
-- 
-- 									Automatic Erections Assigning
-- 								  Only MrFunSize supported for now
--
----------------------------------------------------------------------------------------------------

-- TODO - yet those as we are handling the auto erections on the entity now.
-- Add auto erections as entity var

-- TODO - rewrite for variable amount of Sex Havers

-- Auto-Erections handling on Sex start
-- TODO - access Scene/PairsData instead
local sexPairs = {}

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
 
    if spell == "BG3SX_AskForSex" then


        local casterGenital = Genital:GetCurrentGenital(caster)
        local targetGenital

            if not Entity:IsNPC(target) then
                targetGenital = Genital:GetCurrentGenital(target)
            end

        local pair = {caster = caster; casterGenital = casterGenital; target = target, targetGenital = targetGenital}
        table.insert(sexPairs, pair)

        Genital:GiveErection(caster)
        Genital:GiveErection(target)

    -- if casterErection and (spell == "BG3SX_AskForSex")  then
       
    --     if Entity:HasPenis(caster) then
    --        Osi.UseSpell(caster, "BG3SX_SimpleErections", caster)
    --     end

    --     if Entity:HasPenis(target) then
    --        Osi.UseSpell(target, "BG3SX_SimpleErections", target)
    --     end
    -- end

    end

end)

-- Auto-Erections handling on Sex ending
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)

    if spell == "BG3SX_StopAction" then


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


    if spell == "BG3SX_StartMasturbating" then

        local casterGenital = Genital:GetCurrentGenital(caster)
     
        local pair = {caster = caster; casterGenital = casterGenital}
        table.insert(sexPairs, pair)

        Genital:GiveErection(caster)
    end


    -- local entity = Ext.Entity.Get(caster)

    -- if (entity.Vars.BG3SX_AutoErection == 1) and (spell == "BG3SX_StartMasturbating") then
    --     -- Save previous genitals
    --     local casterGenital = Genital:GetCurrentGenital(caster)
    --     local masturbator = {caster = caster; casterGenital = casterGenital}
    --     table.insert(sexPairs, masturbator)

    --     if Entity:HasPenis(caster) then
    --         Osi.UseSpell(caster, "BG3SX_SimpleErections", caster)
    --     end
    -- end
    -- if (entity.Vars.BG3SX_AutoErection == 1) and spell =="BG3SX_StopMasturbating" then
    --     local previousGenital = ""
    --     for _, masturbator in ipairs(sexPairs) do
    --         if masturbator.caster == caster then
    --             previousGenital= sexPairs.casterGenital
    --         end
    --     end

    --     if previousGenital then
    --         Genital:OverrideGenital(previousGenital, caster)
    --     end

    --     sexPairs[caster] = nil
    -- end
end)