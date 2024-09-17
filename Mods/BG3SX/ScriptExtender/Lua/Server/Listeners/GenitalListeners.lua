-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Genital Functions ----
-----------------------------------------------------------------------------------------------------------------------------------------


SatanPrint(GLOBALDEBUG, "Registered GenitalListeners")


-- TODO - test for shapeshifts, rsculpts etc.
Ext.Events.NetMessage:Subscribe(function(e)

    if (e.Channel == "BG3SX_AskForSex") then

        SatanPrint(GLOBALDEBUG, "Server GenitalListener received BG3SX_AskForSex")
        local characters = Ext.Json.Parse(e.Payload)

        -- TOD - modify Give Erections to use the UserVArs
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



    if (e.Channel == "BG3SX_Client_ChangedInactiveGenital") then
        local payload = Ext.Json.Parse(e.Payload)
        local uuid = payload.uuid
        local genital = payload.genital

        -- TODO - currently uuid is sent as nil. Have SKiz send the uuid
        -- so its multiplayer compatible

        local uuid = Osi.GetHostCharacter()
        SexUserVars:AssignGenital("BG3SX_Flaccid", genital, uuid)

         -- If inactive is changed, update USerVars of entity and change genital

         Genital:OverrideGenital(genital, uuid)

    end


    if (e.Channel == "BG3SX_Client_ChangedActiveGenital") then

        local payload = Ext.Json.Parse(e.Payload)
        local uuid = payload.uuid
        local genital = payload.genital

        -- TODO - currently uuid is sent as nil. Have SKiz send the uuid
        -- so its multiplayer compatible

        local uuid = Osi.GetHostCharacter()
        SexUserVars:AssignGenital("BG3SX_Erect", genital, uuid)

        -- If active is changed, update UserVars, search for active actors, and change their genitals as well

        local scene = Scene:FindSceneByEntity(uuid)
        if scene then
            local actors = scene.actors
            for _,actor in  pairs(actors) do
                -- If an actor ith the parent uuid exists, then that one is currently involved in a scene
                if actor.parent == uuid then
                    Genital:OverrideGenital(genital, actor.uuid)
                end
            end
        end

    end

end)



