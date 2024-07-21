-- I don't think synchronisation is necessary here as these should all be server side changes?
-- Aahz easydye will use them. FocusCore also has them


-- TODO - this is currently indepenadant
-- make sure corresponding spells trigger varsChanges

-- If anything fails, register them in BootStrap instead

-- CONSTRUCTOR
--------------------------------------------------------------

SexUserVars = {}
SexUserVars.__index = Sex

-- TODO - these have to be set to a default
Ext.Vars.RegisterUserVariable("BG3SX_Flaccid", {})
Ext.Vars.RegisterUserVariable("BG3SX_Erect", {})
Ext.Vars.RegisterUserVariable("BG3SX_AutoErection", {})

print("[BG3SX - SEXUSERVARS] Registered AutoErection")

--@param type string - either "BG3SX_Flaccid" or "BG3SX_Erect"
--@param genital string - uuid
--@param character string - uuid
function SexUserVars:AssignGenital(type, genital, character)
  local e = Ext.Entity.Get(character)
  
  if type == "BG3SX_Flaccid" then 
        e.Vars.BG3SX_Flaccid = genital
  elseif type == "BG3SX_Erect" then
        e.Vars.BG3SX_Erect = genital
  else

    print("invalid type ", type , " please choose ’BG3SX_Flaccid’ or ’BG3SX_Erect’ ")
   end
  
end

--@param type string - either "BG3SX_Flaccid" or "BG3SX_Erect"
--@param character string - uuid
function SexUserVars:GetGenital(type, character)

    local e = Ext.Entity.Get(character)
  
    if type == "BG3SX_Flaccid" then 
          e.Vars.BG3SX_Flaccid = genital
    elseif type == "BG3SX_Erect" then
          e.Vars.BG3SX_Erect = genital
    else
  
      print("invalid type ", type , " please choose ’BG3SX_Flaccid’ or ’BG3SX_Erect’ ")
     end
    
end



--@param BG3SX_AutoErection bool
--@param character string - uuid
function SexUserVars:SetAutoErection(autoErection, character)

    local e = Ext.Entity.Get(character)
    e.Vars.BG3SX_AutoErection = autoErection

end
  

--@param BG3SX_AutoErection bool
--@param character string - uuid
function SexUserVars:GetAutoErection(character)

    local e = Ext.Entity.Get(character)
    return e.Vars.BG3SX_AutoErection
end