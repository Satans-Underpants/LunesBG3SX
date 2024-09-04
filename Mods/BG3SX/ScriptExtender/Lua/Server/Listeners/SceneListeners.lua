local function redressAndRemoveGenitalFromNPC(caster)
    local scene = Scene:FindSceneByEntity(caster)
    local npcs = {}
    for _,entity in pairs(scene.entities) do
        if Entity:IsNPC(entity) then
            table.insert(npcs, entity)
        end
    end
    for _,npc in pairs(npcs) do
            Visual:RemoveGenitals(npc)
            Visual:Redress(npc)
            -- Remove Hair if necessary? 
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Scene Functions ----
------------------------------------------------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", function(caster, x, y, z, spell, spellType, spellElement, storyActionID)
    local location = {x = x, y = y, z = z}
    if spell == "BG3SX_ChangeSceneLocation" then
        Scene:MoveSceneToLocation(caster, location)
    end
    if spell == "BG3SX_RotateScene" then
        Scene:RotateScene(caster, location)
    end
end)

Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, _, _, _)
    if spell == "BG3SX_SwitchPlaces" then
        -- TODO: Find a way to make this dynamic and not hardcoded to only switch actor[1] and actor[2]
        -- Sex:SwitchPlaces(caster) -- bundle all of this in a new function instead to handle place switching
        local scene = Scene:FindSceneByEntity(caster)
        local savedActor = scene.actors[1]

        Ext.ModEvents.BG3SX.SceneSwitchPlacesBefore:Throw({scene.actors})
        scene.actors[1] = scene.actors[2]
        scene.actors[2] = savedActor
        Ext.ModEvents.BG3SX.SceneSwitchPlacesAfter:Throw({scene.actors})

        scene:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
        Sex:PlayAnimation(caster, scene.currentAnimation)
    end
    if spell == "BG3SX_ChangeCameraHeight" then
        Sex:ChangeCameraHeight(caster)
    end
    if spell == "BG3SX_StopAction" then
        redressAndRemoveGenitalFromNPC(caster)
        local scene = Scene:FindSceneByEntity(caster)
        scene:Destroy()
    end
end)