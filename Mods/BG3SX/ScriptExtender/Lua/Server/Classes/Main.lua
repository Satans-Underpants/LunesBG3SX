----------------------------------------------------------------------------------------
--
--                               For handling the main functionalities
--
----------------------------------------------------------------------------------------

-- Runs every time a save is loaded --
function OnSessionLoaded()
    ------------------------------------------------------------------------------------------------------------------------------------------
                                                 ---- Setup Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    Genitals:Initialize() -- Initializes genitals, check Genitals.lua


    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
        local party = Osi.DB_PartyMembers:Get(nil)
        for i = #party, 1, -1 do
            Sex:AddMainSexSpells(party[i][1])
            Genitals:AddGenitalIfHasNone(party[i][1])
        end
    end)

    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(actor)
        if string.find(actor, "CharacterCreationDummy") == nil then
            Sex:AddMainSexSpells(actor)
            Genitals:AddGenitalIfHasNone(actor)
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