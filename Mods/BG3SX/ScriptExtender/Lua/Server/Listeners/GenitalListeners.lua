-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Genital Functions ----
-----------------------------------------------------------------------------------------------------------------------------------------


SatanPrint(GLOBALDEBUG, "Registered GenitalListeners")


Ext.Events.NetMessage:Subscribe(function(e)

    if (e.Channel == "BG3SX_AskForSex") then

        SatanPrint(GLOBALDEBUG, "Server GenitalListener received BG3SX_AskForSex")
        local characters = Ext.Json.Parse(e.Payload)
        Genital:GiveErections(characters)
    end


    if (e.Channel == "BG3SX_StopSex") then

        local scene = Ext.Json.Parse(e.Payload)

        -- TODO - check if the returned entities are the OG parents
        Scene:EntitiesByScene(scene)


    end


    if (e.Channel == "BG3SX_ChangeGenitals") then

        local payload = Ext.Json.Parse(e.Payload)
        local character = payload.character
        local genital = payload.genital

        Genital:OverrideGenital(genital, character)
    end


    if (e.Channel == "BG3SX_ChangeAutoErection") then


        -- payload.setting is "ON" or "OFF"
        local payload = Ext.Json.Parse(e.Payload)
        local character = payload.character
        local setting = payload.setting

        if setting == "ON" then
            SexUserVars:SetAutoErection(true, character)
        elseif setting == "OFF" then
            SexUserVars:SetAutoErection(false, character)
        end
    end


    if (e.Channel == "BG3SX_ChangeSexGenital") then

        local payload = Ext.Json.Parse(e.Payload)
        local character = payload.character
        local genital = payload.genital

        SexUserVars:AssignGenital("BG3SX_Flaccid", genital, character)
    end


    if (e.Channel == "BG3SX_ChangeNormalGenital") then

        local payload = Ext.Json.Parse(e.Payload)
        local character = payload.character
        local genital = payload.genital
        SexUserVars:AssignGenital("BG3SX_Erect", genital, character)

    end
end)

