Ext.Require("Shared/AnimationPack.lua")
Ext.Require("Shared/BodyLibrary.lua")
Ext.Require("Server/BG3SX.lua")
Ext.Require("Server/Genitals.lua")
Ext.Require("Server/NPCStripping.lua")
Ext.Require("Server/UserSettings.lua")
Ext.Require("Server/SexActor.lua")
Ext.Require("Server/PairedAnimation.lua")
Ext.Require("Server/SoloAnimation.lua")
Ext.Require("Server/ActorScale.lua")

Ext.Vars.RegisterUserVariable("ActorData", {
    Server = true,
    Client = true, 
    SyncToClient = true
})

Ext.Vars.RegisterUserVariable("PairData", {
    Server = true,
    Client = true, 
    SyncToClient = true
})

Ext.Vars.RegisterUserVariable("SoloData", {
    Server = true,
    Client = true, 
    SyncToClient = true
})

_P("-----------------------------------------------------------------------------")
_P("-----------------------------------------------------------------------------")
_P("-----------------------------------------------------------------------------")
_P("--------------------------BG3SX has been loaded------------------------------")
_P("------------------------------Testversion 1----------------------------------")
_P("-----------------------------------------------------------------------------")
_P("-----------------------------------------------------------------------------")
_P("-----------------------------------------------------------------------------")
