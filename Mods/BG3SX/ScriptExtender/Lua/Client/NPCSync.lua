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