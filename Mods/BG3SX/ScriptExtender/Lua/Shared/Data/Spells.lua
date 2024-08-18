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