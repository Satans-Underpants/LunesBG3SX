Data.Spells = {}

-- Main spells which are accessible outside of scenes
-- Get removed for the duration of a scene
Data.Spells.MainSexSpells = {
    "BG3SX_MainContainer",
    "BG3SX_ChangeGenitals",
    "BG3SX_Options",
}

-- Additional actions to be added during a scene
Data.Spells.AdditionalSexActions = {
    "BG3SX_StopAction",
    "BG3SX_SwitchPlaces",
    "BG3SX_ChangeSceneLocation",
    "BG3SX_ChangeCameraHeight",
    "BG3SX_RotateScene",
}  

-- Every possible spell you could have during a scene which needs to be removed on Scene:Destroy()
Data.Spells.SexSceneSpells = {
    -- Animation Containers - Add all possible here - Update when creating new ones
    "BG3SX_StraightAnimationsContainer",
    "BG3SX_LesbianAnimationsContainer",
    "BG3SX_StraightAnimationsContainer",
    "BG3SX_LesbianAnimationsContainer",
    "BG3SX_GayAnimationsContainer",
    "BG3SX_FemaleMasturbationContainer",
    "BG3SX_MaleMasturbationContainer",
    
    -- Copy spells from Data.Spells.AdditionalSexActions here
    "BG3SX_StopAction",
    "BG3SX_SwitchPlaces",
    "BG3SX_ChangeSceneLocation",
    "BG3SX_ChangeCameraHeight",
    "BG3SX_RotateScene",
}

function Data.Spells:AddSpellsToContainerBySceneType(spellsToAdd)
    local container
    for spell,sType in pairs(spellsToAdd) do
        for _,entry in pairs(Data.SceneTypes) do
            if sType == entry.sceneType then
                container = Ext.Stats.Get(entry.container)
            end
        end
        if string.find(container.ContainerSpells, spell, 1, true) == nil then -- If the spell doesn't already exist in the given spellcontainers list of spells then...
            container.ContainerSpells = container.ContainerSpells ..";" .. spell
            container:Sync()
        end
    end
end

-- Example:
--
-- local spellsToAdd = {
--     ["Lewd_Cowgirl"] = "Straight",
--     ["SomeOtherSpell"] = "Gay",
--   }
-- Mods.BG3SX.Data.Spells:AddSpellsToContainerBySceneType(spellsToAdd)