Ext.Events.NetMessage:Subscribe(function(e) 
    if (e.Channel == "BG3SX_NPCStrip") then
        local strip = Ext.Json.Parse(e.Payload)
        -- _D(strip)
        Ext.Resource.Get(strip.resource,"CharacterVisual").VisualSet.Slots = strip.naked
        
    end
    if (e.Channel == "BG3SX_NPCDress") then
        local dress = Ext.Json.Parse(e.Payload)
        -- _D(dress)
        Ext.Resource.Get(dress.resource,"CharacterVisual").VisualSet.Slots = dress.dressed
    end
end)


-- TODO:
-- USE THIS INSTEAD WHENEVER THE NEW EVENT CLASS CAN SYNC TO CLIENTS

-- ---@diagnostic disable: missing-parameter


-- BG3SX = Mods.BG3SX
-- _D(BG3SX)
-- BG3SX.Event:Subscribe(function(e)
--     if e.Channel == "BG3SX_SceneInit" then
--         local payload = Ext.Json.Parse(e.Payload)
--         _P("-----------------------------------")
--         _P("-----------------------------------")
--         _P("-------------Subscribed------------")
--         _P(payload)
--         _D(payload)
--         _P("-----------------------------------")
--     end

--     if e.Channel == "BG3SX_SceneCreated" then
--     end
-- end)

-- Event:Subscribe(function(e)
--     if e.Channel == "BG3SX_NPCStrip" then
--         _P("---------------------------------------------------")
--         _P("NPCSTRIP")
--         -- local strip = e.Payload
--         -- _D(strip)
--         Ext.Resource.Get(e.Payload.resource,"CharacterVisual").VisualSet.Slots = e.Payload.naked
--     end

--     if e.Channel == "BG3SX_NPCDress" then
--         _P("---------------------------------------------------")
--         _P("NPCDRESS")
--         -- local dress = e.Payload
--         -- _D(dress)
--         Ext.Resource.Get(e.Payload.resource,"CharacterVisual").VisualSet.Slots = e.Payload.dressed
--     end
-- end)