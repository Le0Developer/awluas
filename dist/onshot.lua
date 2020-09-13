--[[
MIT License

Copyright (c) 2020 LeoDeveloper

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Github: https://github.com/le0developer/awluas/blob/master/scripts/onshot.moon
Automatically generated and compiled on Sun Sep 13 11:36:44 2020
]]
local force_onshot
do
  local _with_0 = gui.Checkbox(gui.Reference("Ragebot", "Aimbot", "Automation"), "onshot", "Force onshot", false)
  _with_0:SetDescription("Binding recommended.")
  force_onshot = _with_0
end
local onshotable = { }
local changes = false
local ApplyOnshots
ApplyOnshots = function()
  local lp = entities.GetLocalPlayer()
  if force_onshot:GetValue() then
    changes = true
    local _list_0 = entities.FindByClass("CCSPlayer")
    for _index_0 = 1, #_list_0 do
      local player = _list_0[_index_0]
      if player:GetProp("m_iPendingTeamNum") ~= lp:GetProp("m_iPendingTeamNum") then
        if onshotable[player:GetIndex()] then
          local has_onshot = onshotable[player:GetIndex()] > globals.CurTime()
          if has_onshot then
            player:SetProp("m_iTeamNum", player:GetProp("m_iPendingTeamNum"))
          else
            player:SetProp("m_iTeamNum", lp:GetProp("m_iTeamNum"))
          end
        else
          player:SetProp("m_iTeamNum", lp:GetProp("m_iTeamNum"))
        end
      end
    end
  elseif changes then
    changes = false
    local _list_0 = entities.FindByClass("CCSPlayer")
    for _index_0 = 1, #_list_0 do
      local player = _list_0[_index_0]
      player:SetProp("m_iTeamNum", player:GetProp("m_iPendingTeamNum"))
    end
  end
end
callbacks.Register("CreateMove", function(usercmd)
  ApplyOnshots()
  
end)
client.AllowListener("weapon_fire")
callbacks.Register("FireGameEvent", function(event)
  if event:GetName() ~= "weapon_fire" then
    return 
  end
  local index = client.GetPlayerIndexByUserID(event:GetInt("userid"))
  onshotable[index] = globals.CurTime() + 0.2
end)
