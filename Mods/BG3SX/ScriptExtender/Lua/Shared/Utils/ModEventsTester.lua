Ext.ModEvents.BG3SX.SexStartSpellUsed:Subscribe(function (e)
    _P("[BG3SX][Events] SexStartSpellUsed received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.SexAnimationChange:Subscribe(function (e)
    _P("[BG3SX][Events] SexAnimationChange received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.SceneInit:Subscribe(function (e)
    _P("[BG3SX][Events] SceneInit received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.SceneCreated:Subscribe(function (e)
    _P("[BG3SX][Events] SceneCreated received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.ActorInit:Subscribe(function (e)
    _P("[BG3SX][Events] ActorInit received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.ActorCreated:Subscribe(function (e)
    _P("[BG3SX][Events] ActorCreated received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.AnimationChange:Subscribe(function (e)
    _P("[BG3SX][Events] AnimationChange received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.SoundChange:Subscribe(function (e)
    _P("[BG3SX][Events] SoundChange received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.SceneMove:Subscribe(function (e)
    _P("[BG3SX][Events] SceneMove received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.SceneSwitchPlacesBefore:Subscribe(function (e)
    _P("[BG3SX][Events] SceneSwitchPlacesBefore received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.SceneSwitchPlacesAfter:Subscribe(function (e)
    _P("[BG3SX][Events] SceneSwitchPlacesAfter received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.CameraHeightChange:Subscribe(function (e)
    _P("[BG3SX][Events] CameraHeightChange received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.ActorDressed:Subscribe(function (e)
    _P("[BG3SX][Events] ActorDressed received with PayLoad: ")
    _D(e)
end)
Ext.ModEvents.BG3SX.GenitalChange:Subscribe(function (e)
    _P("[BG3SX][Events] GenitalChange received with PayLoad: ")
    _D(e)
end)
-- Ext.ModEvents.BG3SX.NPCStrip:Subscribe(function (e)
--     _P("[BG3SX][Events] NPCStrip received with PayLoad: ")
--     _D(e)
-- end)
-- Ext.ModEvents.BG3SX.NPCDress:Subscribe(function (e)
--     _P("[BG3SX][Events] NPCDress received with PayLoad: ")
--     _D(e)
-- end)

-- TODO: Test if this works as well to just listen to ANY event of a mod
-- for _,event in pairs(Ext.ModEvents.BG3SX) do
--     event:Subscribe(function (e)
--         _P("Recieved " .. event .. " event!")
--         _D(e)
--     end)
-- end