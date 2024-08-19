----------------------------------------------------------------------------------------
--
--                      For handling the main functionalities
--
----------------------------------------------------------------------------------------

-- Runs every time a save is loaded --
function OnSessionLoaded()
    ------------------------------------------------------------------------------------------------------------------------------------------
                                                 ---- Setup Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    Genital:Initialize() -- Initializes genitals, check Genitals.lua

    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
        local party = Osi.DB_PartyMembers:Get(nil)
        for i = #party, 1, -1 do
            if Entity:IsWhitelisted(party[i][1]) then
                Sex:AddMainSexSpells(party[i][1])
                Genital:AddGenitalIfHasNone(party[i][1])
            end
        end
    end)

    -- TODO: Check if CharacterCreationDummy might cause issues with "Make NPC into Partymember" mods
    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(character)
        if string.find(character, "CharacterCreationDummy") == nil then
            if Entity:IsWhitelisted(character) then
                Sex:AddMainSexSpells(character)
                Genital:AddGenitalIfHasNone(character)
            end
        end
    end)
end

-- Subscribes to the SessionLoaded event and executes our OnSessionLoaded function
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

-- Makes it so the game never saves with an active scene to avoid errors/crashes
Ext.Events.GameStateChanged:Subscribe(function(e)
    if e.FromState == "Running" and e.ToState == "Save" then
        Sex:TerminateAllScenes()
    end
end)