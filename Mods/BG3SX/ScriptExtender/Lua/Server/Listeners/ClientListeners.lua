local sexPairs = {}

local function giveErections(caster, target)
    --if spell == "BG3SX_AskForSex" then
        -- if Entity:IsWhitelisted(caster) and Entity:IsWhitelisted(target) then
            local casterGenital = Genital:GetCurrentGenital(caster)
            local targetGenital
                if not Entity:IsNPC(target) then
                    targetGenital = Genital:GetCurrentGenital(target)
                end
            local pair = {caster = caster; casterGenital = casterGenital; target = target, targetGenital = targetGenital}
            table.insert(sexPairs, pair)

            Genital:GiveErection(caster)
            Genital:GiveErection(target)
end


Ext.RegisterNetListener("BG3SX_Client_Masturbate", function(e, payload)
    local payload = Ext.Json.Parse(payload)
    _D(payload)
    local caster = payload[1]
    local target = payload[1]
    if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
        Ext.Timer.WaitFor(200, function() -- Wait for erections
            Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells["BG3SX_StartMasturbating"])
        end)
        Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells["BG3SX_StartMasturbating"]})
    end
end)

Ext.RegisterNetListener("BG3SX_Client_AskForSex", function(e, payload)
    local payload = Ext.Json.Parse(payload)
    _D(payload)
    local caster = payload["caster"]
    local target = payload["target"]
    giveErections(caster, target)
    if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
        Ext.Timer.WaitFor(200, function() -- Wait for erections
            Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells["BG3SX_AskForSex"])
        end)
        Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells["BG3SX_AskForSex"]})
    end
end)





