UI = {}
UI.__index = UI
UI.DevMode = false
UI.SelectingTarget = false
function UI.CreateDevMode(parent)
    local dev = parent:AddCheckbox("Developer Mode")
    dev.Visible = false -- NYI
    dev.OnChange = function()
        if dev.Checked == true then
            UI.DevMode = true
        else
            UI.DevMode = false
    end
    return dev
end
function UI.InDev()
    if UI.DevMode == true then
        return true
    else return false
    end
end

function UI.HighlightConnected(tableToHighlight, listOfTables)
    for _,entry in pairs(listOfTables) do
        if entry.table == tableToHighlight then
            entry.table.Borders = true
            -- Color it in a different color
        end
    end
end

function UI.HighlightOnlyOne(tableToHighlight, listOfTables)
    --FailColor = {1.0, 0.0, 0.0, 1.0},
    --SuccessColor = {0.0, 1.0, 0.0, 1.0},
    --NeutralColor = {0.7, 0.7, 0.7, 1.0},
    for _,entry in pairs(listOfTables) do
        if entry.table == tableToHighlight then
            entry.button.Tint = {1.0, 0.8, 0.3, 1.0} -- Neutral Selected Color -- Beige
            entry.selected = true
        else
            entry.button.Tint = {1.0, 1.0, 1.0, 1.0} -- Reset to regular
            entry.selected = false
        end
    end
end

---------------------------------------------------------------------------------------------------
--                                    Handle Sex Settings Tab
---------------------------------------------------------------------------------------------------
local options = {
    ["Strip"] = {val = true, info = "", box = nil},
    ["Unlock Animation Choice"] = {val = false, info = "", box = nil},
}

function UI.CreateSexSettings(tBar)
    local tab = tBar:AddTabItem("Sex Settings")
    local table = tab:AddTable("",1)
    for option,content in pairs(options) do
        local cell = table:AddRow():AddCell()
        local optionCheckBox = cell:AddCheckbox(option)
        if content.val == true then
            optionCheckBox.Checked = true
        end
        optionCheckBox.OnChange = function()
            if optionCheckBox.Checked == true then
                content.val = true
                --Ext.Net.SendMessageToServer("BG3SX_" .. option, "") -- Setting this to true means we need to be able to show 
            else
                content.val = false
            end
        end
        local info = cell:AddText(content.info)
        options[option].box = optionCheckBox -- Might create infinite loop if someone dumps "options"
    end
    return tab
end

---------------------------------------------------------------------------------------------------
--                                  Handle Genital Settings Tab
---------------------------------------------------------------------------------------------------

local genitals = {}
function UI.CreateGenitalSettings(tBar)
    local tab = tBar:AddTabItem("Genital Settings")

    local favArea = tab:AddTable("",2)
    favArea.SizingStretchProp = true
    local favRow = favArea:AddRow()
    local inactiveGArea = favRow:AddCell() -- Left
    local inactiveGInfo = inactiveGArea:AddText("Inactive Genital")
    local inactiveGSource = inactiveGArea:AddText("Source: ")
    local inactiveGenital = inactiveGArea:AddText("Genital: ")
    local activeGArea = favRow:AddCell() -- Right
    local activeGInfo = activeGArea:AddText("Active Genital")
    local activeGSource = activeGArea:AddText("Source: ")
    local activeGenital = activeGArea:AddText("Genital: ")

    tab:AddSeparator("")

    local function addGenitalEntry(parent)
        local inactiveGButton = parent:AddButton("Inactive")
        local activeGButton = parent:AddButton("Active")
        local GText = parent:AddText(genital.name)
        activeGButton.SameLine = true
        GText.SameLine = true
        inactiveGButton.OnClick = function()
            inactiveGSource.Text = mod
            inactiveGenital.Text = "Genital: " .. genital.name
        end
        activeGButton.OnClick = function()
            activeGSource.Text = mod
            activeGenital.Text = "Genital: " .. genital.name
        end
    end

    local genitalArea = tab:AddTable("",1):AddRow():AddCell()
    for mod,genital in pairs(Data.Bodylibrary.Genitals) do
        local modHeader = genitalArea:AddCollapsableHeader(mod)
        local penisHeader = modHeader:AddCollapsableHeader("Penis")
        local vulvaHeader = modHeader:AddCollapsableHeader("Vulva")
        if genital.type == "Penis" then
            addGenitalEntry(penisHeader)
        elseif genital.type == "Vulva" then
            addGenitalEntry(vulvaHeader)
        else
            local somethingHeader = modHeader:AddCollapsableHeader(genital.type)
            addGenitalEntry(somethingHeader)
        end
    end
end
    return tab
end

---------------------------------------------------------------------------------------------------
--                                   Handle Sex Controls Tab
---------------------------------------------------------------------------------------------------

function UI.DoSexButtonStuff(button)
    if button.Label == "Masturbate" then
        local selectedCharacter = UI.GetSelectedCharacter()
        if selectedCharacter ~= nil then
            Ext.Net.PostMessageToServer("BG3SX_Client_Masturbate", Ext.Json.Stringify({selectedCharacter}))
            -- for genitals
            SatanPrint(GLOBALDEBUG, "Client sending BG3SX_AskForSex to server")
            Ext.Net.PostMessageToServer("BG3SX_AskForSex",Ext.Json.Stringify({selectedCharacter}))
        end
    elseif button.Label == "Ask for Sex" then
        UI.SelectingTarget = true
    end
end


local preSexControls = {
    "Masturbate",
    "Ask for Sex"
}
local sceneTables = {

}
function UI.CreateSexControls(tBar)
    local tab = tBar:AddTabItem("Sex")
    
    local noSceneTable = tab:AddTable("",1)
    local sceneTable = tab:AddTable("",1)
    table.insert(sceneTables, noSceneTable)
    table.insert(sceneTables, sceneTable)

    -- No Scene exists for selected character
    local noSceneArea = noSceneTable:AddRow():AddCell()
    for _,entry in pairs(preSexControls) do
        local sexButton = noSceneArea:AddButton(entry)
        sexButton.SameLine = true
        sexButton.OnClick = function()
            UI.DoSexButtonStuff(sexButton)
            -- makes button invisible to replace it with the scene one
            -- noSceneTable.Visible = false
            sceneTable.Visible = true
        end
    end
    
    
    return tab
end

---------------------------------------------------------------------------------------------------
--                                    Handle Character Table
---------------------------------------------------------------------------------------------------


local characterTables = {}
function UI.GetSelectedCharacter()
    for _,entry in pairs(characterTables) do
        if entry.selected == true then
            return entry.uuid
        end
    end
end

function UI.FindCharacterTable(uuid)
    for _,entry in pairs(characterTables) do
        if entry.uuid == uuid then
            return entry.table
        end
    end
end

function UI.CharacterButton(table)
    UI.HighlightOnlyOne(table, characterTables)
    --DoSomethingElse
    --Refresh Info in Tabs
end

function UI.AddCharacter(parent, uuid)
    local character = Ext.Entity.Get(uuid)
    local charTable = parent:AddCell():AddTable("", 1)
    charTable.SizingStretchProp = true
    --charTable.Borders = true
    local row = charTable:AddRow()
    local size = {100,100}
    local tName = Ext.Loca.GetTranslatedString(character.DisplayName.NameKey.Handle.Handle)
    local characterButton
    local foundOrigin = false
    for uuid,origin in pairs(Data.Origins) do
        if Helper:StringContains(uuid, character.Uuid.EntityUuid) then
            foundOrigin = true
            characterButton = row:AddCell():AddImageButton("","EC_Portrait_"..origin, size)
        end
    end
    if foundOrigin == false then
        characterButton = row:AddCell():AddImageButton("","EC_Portrait_Generic", size)
    end

    characterButton.OnClick = function()
        UI.CharacterButton(charTable)
    end
    --local infoArea = row:AddCell():AddTable("", 1)
    local characterName = charTable:AddRow():AddCell():AddText("")
    characterName.Label = tName
    --local additionalInfo = infoArea:AddRow():AddCell():AddText("AdditionalInfoArea")
    table.insert(characterTables, {uuid = uuid, table = charTable, button = characterButton})
    return charTable
end


--TODO - Osi.DB_Partymembers not available on client
function UI.CreateCharacterTable(parent)
    local charTable = parent:AddTable("characterTable", 4)
    charTable.SizingStretchProp = true
    --charTable.Borders = true
    charTable.ScrollY = false
    --charTable.ScrollX = true
    local row = charTable:AddRow()
    --row:AddCell():AddText("Test")
    local characterCount = 0
    local party = UIHelper:GetCurrentParty()
    for _, uuid in pairs(party) do
        if characterCount > 0 and characterCount % 4 == 0 then
            row = charTable:AddRow()
        end
        --if Entity:IsWhitelisted(uuid, false) then
            local companion = UI.AddCharacter(row, uuid)
            characterCount = characterCount + 1
        --end
    end
    return charTable
end

---------------------------------------------------------------------------------------------------
--                                         Build UI
---------------------------------------------------------------------------------------------------

local function createModTab(tab)
    local dev = UI.CreateDevMode(tab)
    local characters = UI.CreateCharacterTable(tab)
    
    tab:AddSeparator("")

    local tBar = tab:AddTabBar("insertTabBarNameHere")
    local tab1 = UI.CreateSexControls(tBar)
    --local tab2 = UI.CreateGenitalSettings(tBar)
    local tab3 = UI.CreateSexSettings(tBar)



end

---------------------------------------------------------------------------------------------------
--                                          Mouseover
---------------------------------------------------------------------------------------------------

local function getMouseover()
    local mouseover = Ext.UI.GetPickingHelper(1)
    if mouseover ~= nil then
    -- setSavedMouseover(mouseover)
        return mouseover
    else
        _P("[BG3SX] Not a viable mouseover!")
    end 
end

local function getUUIDFromUserdata(mouseover)
    local entity = mouseover.Inner.Inner[1].GameObject
    if entity ~= nil then
        return Ext.Entity.HandleToUuid(entity)
    else
        _P("[BG3SX] getUUIDFromUserdata(mouseover) - Not an entity!")
    end
end

Ext.Events.KeyInput:Subscribe(function (e)
    if e.Event == "KeyDown" and e.Repeat == false then
        if e.Key == "F" then
            if UI.SelectingTarget == true then
                local caster = UI.GetSelectedCharacter()
                local target = getUUIDFromUserdata(getMouseover())
                Ext.Net.PostMessageToServer("BG3SX_Client_AskForSex", Ext.Json.Stringify({caster = caster, target = target}))
                -- genitals
                Ext.Net.PostMessageToServer("BG3SX_AskForSex",Ext.Json.Stringify({caster, target}))
                UI.SelectingTarget = false
            end
        end
        if e.Key == "Escape" then
            sceneTables.noSceneTable.Visible = true
            sceneTables.sceneTable.Visible = false
            UI.SelectingTarget = false
        end
    end
end)

---------------------------------------------------------------------------------------------------
--                                       Load MCM Tab
---------------------------------------------------------------------------------------------------

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "BG3SX", function(tab)
    createModTab(tab)
end)