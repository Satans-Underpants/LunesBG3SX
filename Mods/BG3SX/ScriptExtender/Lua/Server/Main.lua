----------------------------------------------------------------------------------------
--
--                               For handling the main functionalities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

-- Scene Handling
--------------------------------------------------------------

-- key = Scene scene
-- value = Content content
local savedScenes = {}


-- Listeners
--------------------------------------------------------------

-- Runs every time a save is loaded --
function OnSessionLoaded()
    ------------------------------------------------------------------------------------------------------------------------------------------
                                                 ---- Setup Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    Genitals:Initialize() -- Initializes genitals, check Genitals.lua


    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
        local party = Osi.DB_PartyMembers:Get(nil)
        for i = #party, 1, -1 do
            Spells:AddMainSexSpells(party[i][1])
            Genitals:AddGenitalIfHasNone(party[i][1])
        end
    end)
    
    
    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(actor)
    
        if string.find(actor, "CharacterCreationDummy") == nil then
            Spells:AddMainSexSpells(actor)
            Genitals:AddGenitalIfHasNone(actor)
        end
        
    end)

    -----------------------------------------------------------------------------------------------------------------------------------------
                                                ---- Animation Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    -- Typical Spell Use --
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
        -- Checks to see if the name of the spell used matches any of the Spells in the AnimationPacks
        for _, table in ipairs(StartSexSpells) do
            if table.AnimName == spell then
                Spells:SexSpellUsed(caster, target, table)
                break
            end
        end
    end)
    
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)
        if spell == "BlockStripping" then
            Osi.RemoveStatus(target, "BLOCK_STRIPPING")  
            Osi.ApplyStatus(target, "BLOCK_STRIPPING", -1)  
        elseif spell == "RemoveStrippingBlock" then
            Osi.RemoveStatus(target, "BLOCK_STRIPPING")  
        end
    end)

    Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(caster, x, y, z, spell, spellType, spellElement, storyActionID)
        if spell == "ChangeLocationPaired" then
            MovePairedSceneToLocation(caster, x,y,z)
        end
        if spell == "ChangeLocationSolo" then
            MoveSoloSceneToLocation(caster, x,y,z)
        end
    end)

    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
        if spell == "CameraHeight" then
            BG3SX:ChangeCameraHeight(caster)
        end
    end)

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

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

Ext.Events.GameStateChanged:Subscribe(function(e)
    if e.FromState == "Running" and e.ToState == "Save" then
        TerminateAllSoloAnimations()
        TerminateAllPairedAnimations()
    end
end)







-- On Gameplay Start initialize
-- Adding Spells
-- Adding Genitals


-- On Spell used
-- Start Scene (create proxies etc)

-- if spell "sexspell" then
--     Scene:new({caster, target})
-- end

-- Give Erections
-- Initialize NPC stripping/Give them genitals/erections

-- End Sex etc.
