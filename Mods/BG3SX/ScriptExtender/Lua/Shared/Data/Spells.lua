-- Main spells which are accessible outside of scenes
-- Get removed for the duration of a scene
MAINSEXSPELLS = {
    "BG3SX_MainContainer",
    "BG3SX_ChangeGenitals",
    "BG3SX_Options"
}

-- Additional actions to be added during a scene
ADDITIONALSEXACTIONS = {
    "BG3SX_StopAction",
    "BG3SX_SwitchPlaces",
    "BG3SX_ChangeSceneLocation",
    "BG3SX_ChangeCameraHeight",
    "BG3SX_RotateScene", -- Reentable whenever this POS actually works
}  

-- Every possible spell you could have during a scene which needs to be removed on Scene:Destroy()
SEXSCENESPELLS = {
    -- Animation Containers
    "BG3SX_StraightAnimationsContainer",
    "BG3SX_LesbianAnimationsContainer",
    "BG3SX_StraightAnimationsContainer",
    "BG3SX_LesbianAnimationsContainer",
    "BG3SX_GayAnimationsContainer",
    "BG3SX_FemaleMasturbationContainer",
    "BG3SX_MaleMasturbationContainer",
    
    -- Copy spells from ADDITIONALSEXACTIONS here
    "BG3SX_StopAction",
    "BG3SX_StopMasturbating",
    "BG3SX_ChangeCameraHeight",
    "BG3SX_ChangeSceneLocation",
    "BG3SX_SwitchPlaces",
    "BG3SX_RotateScene",
}