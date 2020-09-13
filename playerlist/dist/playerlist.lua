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

Github: https://github.com/le0developer/awluas/blob/master/playerlist/playerlist.moon
Automatically generated and compiled on Sun Sep 13 12:13:28 2020
]]
local __version__ = [[de91c464f35aab3adf8fb76c7b159f6dce21c4936c4d6b746fc920d10799f0d7]]
local __human_version__ = "1.3.0"
local randomname = ""
for i = 1, 16 do
  local rand = math.random(1, 16)
  randomname = randomname .. ("0123456789abcdef"):sub(rand, rand)
end
local guiobjects = { }
local guisettings = { }
local playerlist = { }
local playersettings = { }
local MENU = gui.Reference("Menu")
local LIST_WIDTH = 300
local GUI_TAB = gui.Tab(gui.Reference("Misc"), "playerlist", "Player List")
local GUI_WINDOW
do
  local _with_0 = gui.Window("playerlist", "Player List", 100, 100, 530, 600)
  _with_0:SetActive(false)
  GUI_WINDOW = _with_0
end
local GUI_TAB_CTRL_POS = {
  x = 8,
  y = 8,
  w = 618,
  h = 108
}
local GUI_TAB_CTRL = gui.Groupbox(GUI_TAB, "Menu Controller", GUI_TAB_CTRL_POS.x, GUI_TAB_CTRL_POS.y, GUI_TAB_CTRL_POS.w, GUI_TAB_CTRL_POS.h)
local GUI_TAB_CTRL_MODE
do
  local _with_0 = gui.Combobox(GUI_TAB_CTRL, "controller.mode", "Menu Mode", "Tab", "Window")
  _with_0:SetWidth(200)
  GUI_TAB_CTRL_MODE = _with_0
end
local GUI_TAB_CTRL_OPENKEY
do
  local _with_0 = gui.Keybox(GUI_TAB_CTRL, "controller.openkey", "Window Openkey", 0)
  _with_0:SetWidth(200)
  _with_0:SetPosX(210)
  _with_0:SetPosY(0)
  _with_0:SetDisabled(true)
  GUI_TAB_CTRL_OPENKEY = _with_0
end
local selected_player = nil
local GUI_PLIST_POS = {
  x = GUI_TAB_CTRL_POS.x,
  y = GUI_TAB_CTRL_POS.y + GUI_TAB_CTRL_POS.h,
  w = LIST_WIDTH,
  h = 0
}
local GUI_PLIST = gui.Groupbox(GUI_TAB, "Select a player", GUI_PLIST_POS.x, GUI_PLIST_POS.y, GUI_PLIST_POS.w, GUI_PLIST_POS.h)
local GUI_PLIST_LIST = gui.Listbox(GUI_PLIST, tostring(randomname) .. ".players", 440)
local GUI_PLIST_CLEAR
do
  local _with_0 = gui.Button(GUI_PLIST, "Clear", function()
    selected_player = nil
    GUI_PLIST_LIST:SetOptions()
    playersettings = { }
    playerlist = { }
  end)
  _with_0:SetPosX(188)
  _with_0:SetPosY(-42)
  _with_0:SetWidth(80)
  GUI_PLIST_CLEAR = _with_0
end
local GUI_SET_POS = {
  x = GUI_PLIST_POS.x + GUI_PLIST_POS.w + 4,
  y = GUI_PLIST_POS.y,
  w = 618 - LIST_WIDTH,
  h = 0
}
local GUI_SET = gui.Groupbox(GUI_TAB, "Per Player Settings", GUI_SET_POS.x, GUI_SET_POS.y, GUI_SET_POS.w, GUI_SET_POS.h)
local settings_wrapper
settings_wrapper = function(settings)
  return {
    set = function(varname, value)
      settings.settings[varname] = value
      if #playerlist > 0 and playerlist[GUI_PLIST_LIST:GetValue() + 1] == settings.info.uid then
        return guisettings[varname].set(value)
      end
    end,
    get = function(varname)
      return settings.settings[varname]
    end
  }
end
local PreservingGUIObject
PreservingGUIObject = function(obj, recreate)
  local modifiers = { }
  local public = {
    obj = obj
  }
  public.reapply = function(nobj)
    public.obj = nobj
    for func, vars in pairs(modifiers) do
      nobj[func](nobj, unpack(vars))
    end
  end
  setmetatable(public, {
    __index = function(self, varname)
      if varname:sub(1, 3) == "Set" then
        return function(self, ...)
          modifiers[varname] = {
            ...
          }
          return public.obj[varname](public.obj, ...)
        end
      end
      return function(self, ...)
        return public.obj[varname](public.obj, ...)
      end
    end
  })
  return public
end
plist = {
  gui = {
    Checkbox = function(varname, name, value)
      local checkbox = gui.Checkbox(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), name, value)
      local pubcheckbox = PreservingGUIObject(checkbox)
      guisettings[varname] = {
        set = function(value_)
          return checkbox:SetValue(value_)
        end,
        get = function()
          return checkbox:GetValue()
        end,
        default = value,
        obj = checkbox
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = value
      end
      table.insert(guiobjects, {
        obj = checkbox,
        recreate = function()
          checkbox = gui.Checkbox(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), name, value)
          pubcheckbox.reapply(checkbox)
          return checkbox
        end
      })
      return pubcheckbox
    end,
    Slider = function(varname, name, value, min, max, step)
      local slider = gui.Slider(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), name, value, min, max, step or 1)
      local pubslider = PreservingGUIObject(slider)
      guisettings[varname] = {
        set = function(value_)
          return slider:SetValue(value_)
        end,
        get = function()
          return slider:GetValue()
        end,
        default = value,
        obj = slider
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = value
      end
      table.insert(guiobjects, {
        obj = slider,
        recreate = function()
          slider = gui.Slider(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), name, value, min, max, step or 1)
          pubslider.reapply(slider)
          return slider
        end
      })
      return pubslider
    end,
    ColorPicker = function(varname, name, r, g, b, a)
      local colorpicker = gui.ColorPicker(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), r, g, b, a)
      local pubcolorpicker = PreservingGUIObject(colorpicker)
      guisettings[varname] = {
        set = function(value_)
          return colorpicker:SetValue(unpack(value_))
        end,
        get = function()
          return {
            colorpicker:GetValue()
          }
        end,
        default = {
          r,
          g,
          b,
          a
        },
        obj = colorpicker
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = {
          r,
          g,
          b,
          a
        }
      end
      table.insert(guiobjects, {
        obj = colorpicker,
        recreate = function()
          colorpicker = gui.ColorPicker(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), r, g, b, a)
          pubcolorpicker.reapply(colorpicker)
          return colorpicker
        end
      })
      return pubcolorpicker
    end,
    Text = function(varname, text)
      local text_ = gui.Text(GUI_SET, text)
      local pubtext = PreservingGUIObject(text_)
      local current_text = text
      guisettings[varname] = {
        set = function(value_)
          text_:SetText(value_)
          current_text = value_
        end,
        get = function()
          return current_text
        end,
        default = text,
        obj = text_
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = text
      end
      table.insert(guiobjects, {
        obj = text_,
        recreate = function()
          text_ = gui.Text(GUI_SET, text)
          pubtext.reapply(text_)
          return text_
        end
      })
      return pubtext
    end,
    Combobox = function(varname, name, ...)
      local combobox = gui.Combobox(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), name, ...)
      local pubcombobox = PreservingGUIObject(combobox)
      guisettings[varname] = {
        set = function(value_)
          return combobox:SetValue(value_)
        end,
        get = function()
          return combobox:GetValue()
        end,
        default = 0,
        obj = combobox
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = 0
      end
      local args = {
        ...
      }
      table.insert(guiobjects, {
        obj = combobox,
        recreate = function()
          combobox = gui.Combobox(GUI_SET, tostring(randomname) .. ".settings." .. tostring(varname), name, unpack(args))
          pubcombobox.reapply(combobox)
          return combobox
        end
      })
      return pubcombobox
    end,
    Button = function(name, callback)
      local mcallback
      mcallback = function()
        if #playerlist > 0 then
          callback(playerlist[GUI_PLIST_LIST:GetValue() + 1])
        else
          callback()
        end
        
      end
      local button = gui.Button(GUI_SET, name, mcallback)
      local pubbutton = PreservingGUIObject(button)
      table.insert(guiobjects, {
        obj = button,
        recreate = function()
          button = gui.Button(GUI_SET, name, mcallback)
          pubbutton.reapply(button)
          return button
        end
      })
      return pubbutton
    end,
    Editbox = function(varname, name)
      local editbox = gui.Editbox(GUI_SET, varname, name)
      local pubeditbox = PreservingGUIObject(editbox)
      guisettings[varname] = {
        set = function(value_)
          return editbox:SetValue(value_)
        end,
        get = function()
          return editbox:GetValue()
        end,
        default = 0,
        obj = editbox
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = 0
      end
      table.insert(guiobjects, {
        obj = editbox,
        recreate = function()
          editbox = gui.Editbox(GUI_SET, varname, name)
          pubeditbox.reapply(editbox)
          return editbox
        end
      })
      return pubeditbox
    end,
    Multibox = function(name)
      local multibox = gui.Multibox(GUI_SET, name)
      local pubmultibox = PreservingGUIObject(multibox)
      table.insert(guiobjects, {
        obj = multibox,
        recreate = function()
          multibox = gui.Multibox(GUI_SET, name)
          pubmultibox.reapply(multibox)
          return multibox
        end
      })
      return pubmultibox
    end,
    Multibox_Checkbox = function(parent, varname, name, value)
      local checkbox = gui.Checkbox(parent.obj, tostring(randomname) .. ".settings." .. tostring(varname), name, value)
      local pubcheckbox = PreservingGUIObject(checkbox)
      guisettings[varname] = {
        set = function(value_)
          return checkbox:SetValue(value_)
        end,
        get = function()
          return checkbox:GetValue()
        end,
        default = value,
        obj = checkbox
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = value
      end
      table.insert(guiobjects, {
        obj = checkbox,
        recreate = function()
          checkbox = gui.Checkbox(parent.obj, tostring(randomname) .. ".settings." .. tostring(varname), name, value)
          pubcheckbox.reapply(checkbox)
          return checkbox
        end
      })
      return pubcheckbox
    end,
    Multibox_ColorPicker = function(parent, varname, name, r, g, b, a)
      local colorpicker = gui.ColorPicker(parent.obj, varname, r, g, b, a)
      local pubcolorpicker = PreservingGUIObject(colorpicker)
      guisettings[varname] = {
        set = function(value_)
          return colorpicker:SetValue(unpack(value_))
        end,
        get = function()
          return {
            colorpicker:GetValue()
          }
        end,
        default = {
          r,
          g,
          b,
          a
        },
        obj = colorpicker
      }
      for _, setting in pairs(playersettings) do
        setting.settings[varname] = {
          r,
          g,
          b,
          a
        }
      end
      table.insert(guiobjects, {
        obj = colorpicker,
        recreate = function()
          colorpicker = gui.ColorPicker(parent.obj, tostring(randomname) .. ".settings." .. tostring(varname), r, g, b, a)
          pubcolorpicker.reapply(colorpicker)
          return colorpicker
        end
      })
      return pubcolorpicker
    end,
    Remove = function(object)
      object:Remove()
      for varname, info in pairs(guisettings) do
        if info.obj == object.obj then
          guisettings[varname] = nil
          for _, set in pairs(playersettings) do
            set.settings[varname] = nil
          end
          break
        end
      end
    end
  },
  GetByUserID = function(userid)
    if not playersettings[userid] then
      error("Playerlist: No settings for userid: " .. tostring(userid), 2)
    end
    return settings_wrapper(playersettings[userid])
  end,
  GetByIndex = function(index)
    local pinfo = client.GetPlayerInfo(index)
    if pinfo ~= nil then
      if not playersettings[pinfo["UserID"]] then
        error("Playerlist: No settings for index: " .. tostring(index), 2)
      end
      return settings_wrapper(playersettings[pinfo["UserID"]])
    end
    for _, info in pairs(playersettings) do
      if info.info.index == index then
        return settings_wrapper(info)
      end
    end
  end,
  GetSelected = function()
    if #playerlist > 0 then
      settings_wrapper(playersettings[playerlist[GUI_PLIST_LIST:GetValue() + 1]])
    end
    return nil
  end,
  GetSelectedIndex = function()
    if #playerlist > 0 then
      local _ = playersettings[playerlist[GUI_PLIST_LIST:GetValue() + 1]].info.index
    end
    return nil
  end,
  GetSelectedUserID = function()
    if #playerlist > 0 then
      local _ = playerlist[GUI_PLIST_LIST:GetValue() + 1]
    end
    return nil
  end
}
local selected_ctrl_mode = 0
local selected_ctrl_openkey = 0
local teamname
teamname = function(other)
  if other == 1 then
    return "SPECTATOR"
  elseif other == 2 then
    return "T"
  else
    return "CT"
  end
end
callbacks.Register("Draw", "playerlist.callbacks.Draw", function()
  if GUI_TAB_CTRL_OPENKEY:GetValue() == 0 and GUI_TAB_CTRL_MODE:GetValue() == 1 then
    GUI_WINDOW:SetActive(MENU:IsActive())
  end
  if not MENU:IsActive() and (GUI_TAB_CTRL_MODE:GetValue() == 0 or (not GUI_WINDOW:IsActive() or GUI_TAB_CTRL_MODE:GetValue() ~= 0)) then
    return 
  end
  if GUI_TAB_CTRL_OPENKEY:GetValue() ~= selected_ctrl_openkey and GUI_TAB_CTRL_MODE:GetValue() == 1 then
    selected_ctrl_openkey = GUI_TAB_CTRL_OPENKEY:GetValue()
    GUI_WINDOW:SetOpenKey(selected_ctrl_openkey)
  end
  if GUI_TAB_CTRL_MODE:GetValue() ~= selected_ctrl_mode then
    if GUI_TAB_CTRL_MODE:GetValue() == 0 then
      GUI_PLIST:Remove()
      GUI_PLIST_LIST:Remove()
      GUI_PLIST_CLEAR:Remove()
      GUI_PLIST = gui.Groupbox(GUI_TAB, "Select a player", GUI_PLIST_POS.x, GUI_PLIST_POS.y, GUI_PLIST_POS.w, GUI_PLIST_POS.h)
      GUI_PLIST_LIST = gui.Listbox(GUI_PLIST, tostring(randomname) .. ".players", 440)
      do
        local _with_0 = gui.Button(GUI_PLIST, "Clear", function()
          selected_player = nil
          GUI_PLIST_LIST:SetOptions()
          playersettings = { }
          playerlist = { }
        end)
        _with_0:SetPosX(188)
        _with_0:SetPosY(-42)
        _with_0:SetWidth(80)
        GUI_PLIST_CLEAR = _with_0
      end
      GUI_SET:Remove()
      GUI_SET = gui.Groupbox(GUI_TAB, "Per Player Settings", GUI_SET_POS.x, GUI_SET_POS.y, GUI_SET_POS.w, GUI_SET_POS.h)
      for guiobj_index = 1, #guiobjects do
        guiobjects[guiobj_index].obj:Remove()
        guiobjects[guiobj_index].obj = guiobjects[guiobj_index].recreate(GUI_SET)
      end
      GUI_TAB_CTRL_OPENKEY:SetDisabled(true)
      GUI_WINDOW:SetActive(false)
      GUI_WINDOW:SetOpenKey(0)
    else
      GUI_PLIST:Remove()
      GUI_PLIST_LIST:Remove()
      GUI_PLIST_CLEAR:Remove()
      GUI_PLIST = gui.Groupbox(GUI_WINDOW, "Select a player", 8, 8, 188, 584)
      GUI_PLIST_LIST = gui.Listbox(GUI_PLIST, tostring(randomname) .. ".players", 494)
      do
        local _with_0 = gui.Button(GUI_PLIST, "Clear", function()
          selected_player = nil
          GUI_PLIST_LIST:SetOptions()
          playersettings = { }
          playerlist = { }
        end)
        _with_0:SetPosX(84)
        _with_0:SetPosY(-42)
        _with_0:SetWidth(80)
        GUI_PLIST_CLEAR = _with_0
      end
      GUI_SET:Remove()
      GUI_SET = gui.Groupbox(GUI_WINDOW, "Per Player Settings", 200, 8, 318, 584)
      for guiobj_index = 1, #guiobjects do
        guiobjects[guiobj_index].obj:Remove()
        guiobjects[guiobj_index].obj = guiobjects[guiobj_index].recreate(GUI_SET)
      end
      GUI_TAB_CTRL_OPENKEY:SetDisabled(false)
      GUI_WINDOW:SetOpenKey(GUI_TAB_CTRL_OPENKEY:GetValue())
    end
    selected_ctrl_mode = GUI_TAB_CTRL_MODE:GetValue()
    selected_player = nil
    GUI_PLIST_LIST:SetOptions(unpack((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, v in ipairs(playerlist) do
        _accum_0[_len_0] = "[" .. teamname(playersettings[v].info.team) .. "] " .. playersettings[v].info.nickname
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()))
  end
  if #playerlist == 0 then
    for _index_0 = 1, #guiobjects do
      local guiobj = guiobjects[_index_0]
      guiobj.obj:SetDisabled(true)
    end
    selected_player = nil
    return 
  elseif selected_player == nil then
    for _index_0 = 1, #guiobjects do
      local guiobj = guiobjects[_index_0]
      guiobj.obj:SetDisabled(false)
    end
  end
  if selected_player ~= GUI_PLIST_LIST:GetValue() then
    selected_player = GUI_PLIST_LIST:GetValue()
    local set = playersettings[playerlist[GUI_PLIST_LIST:GetValue() + 1]].settings
    for varname, wrap in pairs(guisettings) do
      wrap.set(set[varname])
    end
  else
    local set = playersettings[playerlist[GUI_PLIST_LIST:GetValue() + 1]].settings
    for varname, wrap in pairs(guisettings) do
      set[varname] = wrap.get()
    end
  end
end)
local last_map = nil
local last_server = nil
callbacks.Register("CreateMove", "playerlist.callbacks.CreateMove", function(cmd)
  if engine.GetMapName() ~= last_map or engine.GetServerIP() ~= last_server then
    last_map = engine.GetMapName()
    last_server = engine.GetServerIP()
    selected_player = nil
    GUI_PLIST_LIST:SetOptions()
    playersettings = { }
    playerlist = { }
  end
  local _list_0 = entities.FindByClass("CCSPlayer")
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local player = _list_0[_index_0]
      if client.GetPlayerInfo(player:GetIndex())["IsGOTV"] then
        _continue_0 = true
        break
      end
      local uid = client.GetPlayerInfo(player:GetIndex())["UserID"]
      if playersettings[uid] == nil then
        table.insert(playerlist, uid)
        playersettings[uid] = {
          info = {
            nickname = player:GetName(),
            uid = uid,
            index = player:GetIndex(),
            team = player:GetProp("m_iPendingTeamNum")
          },
          settings = { }
        }
        local set = playersettings[uid].settings
        for varname, wrap in pairs(guisettings) do
          set[varname] = wrap.default
        end
        selected_player = nil
        GUI_PLIST_LIST:SetOptions(unpack((function()
          local _accum_0 = { }
          local _len_0 = 1
          for _, v in ipairs(playerlist) do
            _accum_0[_len_0] = "[" .. teamname(playersettings[v].info.team) .. "] " .. playersettings[v].info.nickname
            _len_0 = _len_0 + 1
          end
          return _accum_0
        end)()))
      end
      if playersettings[uid].info.nickname ~= player:GetName() then
        playersettings[uid].info.nickname = player:GetName()
        GUI_PLIST_LIST:SetOptions(unpack((function()
          local _accum_0 = { }
          local _len_0 = 1
          for _, v in ipairs(playerlist) do
            _accum_0[_len_0] = "[" .. teamname(playersettings[v].info.team) .. "] " .. playersettings[v].info.nickname
            _len_0 = _len_0 + 1
          end
          return _accum_0
        end)()))
      end
      if playersettings[uid].info.team ~= player:GetProp("m_iPendingTeamNum") then
        playersettings[uid].info.team = player:GetProp("m_iPendingTeamNum")
        GUI_PLIST_LIST:SetOptions(unpack((function()
          local _accum_0 = { }
          local _len_0 = 1
          for _, v in ipairs(playerlist) do
            _accum_0[_len_0] = "[" .. teamname(playersettings[v].info.team) .. "] " .. playersettings[v].info.nickname
            _len_0 = _len_0 + 1
          end
          return _accum_0
        end)()))
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end)
http.Get([[https://raw.githubusercontent.com/Le0Developer/awluas/master/playerlist/dist/playerlist.version]], function(content)
  if not content then
    return 
  end
  if content == __version__ then
    return 
  end
  local UPD_HEIGHT = 180
  local UPDATE = gui.Groupbox(GUI_TAB, "Update Available", GUI_TAB_CTRL_POS.x, GUI_TAB_CTRL_POS.y + GUI_TAB_CTRL_POS.h, 618, UPD_HEIGHT)
  local text = gui.Text(UPDATE, "A new update has been spotted. You are using " .. tostring(__human_version__))
  local minified = gui.Checkbox(UPDATE, "updater.minified", "Download minified version", true)
  local btn
  do
    local _with_0 = gui.Button(UPDATE, "Update", function()
      text:SetText("Updating...")
      btn:SetDisabled(true)
      http.Get(((function()
        if minified:GetValue() then
          return [[https://raw.githubusercontent.com/Le0Developer/awluas/master/playerlist/dist/playerlist.min.lua]]
        else
          return [[https://raw.githubusercontent.com/Le0Developer/awluas/master/playerlist/dist/playerlist.lua]]
        end
      end)()), function(luacode)
        if luacode then
          text:SetText("Saving...")
          do
            local _with_1 = file.Open(GetScriptName(), "w")
            _with_1:Write(luacode)
            _with_1:Close()
          end
          return text:SetText("Updated to version: " .. tostring(content) .. ".\nReload `" .. tostring(GetScriptName()) .. "` for changes to take effect.")
        else
          text:SetText("Failed.")
          return btn:SetDisabled(false)
        end
      end)
      
    end)
    _with_0:SetWidth(290)
    btn = _with_0
  end
  do
    local _with_0 = gui.Button(UPDATE, "Open Changelog in Browser", function()
      return panorama.RunScript("SteamOverlayAPI.OpenExternalBrowserURL('https://github.com/Le0Developer/awluas/blob/master/playerlist/changelog.md');")
    end)
    _with_0:SetWidth(290)
    _with_0:SetPosX(300)
    _with_0:SetPosY(78)
  end
  GUI_PLIST_POS.y = GUI_PLIST_POS.y + UPD_HEIGHT
  GUI_PLIST:SetPosY(GUI_PLIST_POS.y)
  GUI_SET_POS.y = GUI_SET_POS.y + UPD_HEIGHT
  if GUI_TAB_CTRL_MODE:GetValue() == 0 then
    return GUI_SET:SetPosY(GUI_SET_POS.y)
  end
end)
do
  local _with_0 = plist.gui.Combobox("resolver.type", "Resolver", "Automatic", "On", "Off")
  _with_0:SetDescription("Choose a resolver for this player.")
end
callbacks.Register("AimbotTarget", "playerlist.extensions.Resolver.AimbotTarget", function(entity)
  if not entity:GetIndex() then
    return 
  end
  local set = plist.GetByIndex(entity:GetIndex())
  local resolver_toggle = false
  if set.get("resolver.type") == 0 then
    if entity:GetPropVector("m_angEyeAngles").x >= 85 then
      resolver_toggle = true
    elseif entity:GetPropFloat("m_flPoseParameter", 11) > 29 then
      resolver_toggle = true
    end
  elseif set.get("resolver.type") == 1 then
    resolver_toggle = true
  end
  if gui.GetValue("rbot.master") then
    return gui.SetValue("rbot.accuracy.posadj.resolver", resolver_toggle and 1 or 0)
  else
    return gui.SetValue("lbot.posadj.resolver", resolver_toggle)
  end
end)
local priority_targetted_entity = nil
local priority_targetting_priority = false
callbacks.Register("AimbotTarget", "playerlist.extensions.Priority.AimbotTarget", function(entity)
  if not entity:GetIndex() then
    return 
  end
  if priority_targetted_entity and entity:GetIndex() ~= priority_targetted_entity:GetIndex() then
    if priority_targetting_priority then
      gui.SetValue("rbot.aim.target.lock", false)
    end
    priority_targetted_entity = entity
    priority_targetting_priority = false
  elseif priority_targetting_priority then
    return gui.SetValue("rbot.aim.target.fov", 180)
  end
end)
do
  local _with_0 = plist.gui.Combobox("targetmode", "Targetmode", "Normal", "Friendly", "Priority")
  _with_0:SetDescription("Mode for targetting. NOTE: Priority on teammates attack them.")
end
local priority_lock_fov = 3
local priority_friendly_affected = { }
callbacks.Register("CreateMove", "playerlist.extensions.Priority.CreateMove", function(cmd)
  local localplayer = entities.GetLocalPlayer()
  local _list_0 = entities.FindByClass("CCSPlayer")
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local player = _list_0[_index_0]
      if not player:IsAlive() then
        _continue_0 = true
        break
      end
      local set = plist.GetByIndex(player:GetIndex())
      local uid = client.GetPlayerInfo(player:GetIndex())["UserID"]
      if set.get("targetmode") == 0 and priority_friendly_affected[uid] then
        player:SetProp("m_iTeamNum", player:GetProp("m_iPendingTeamNum"))
        priority_friendly_affected[uid] = nil
      elseif set.get("targetmode") == 1 then
        player:SetProp("m_iTeamNum", localplayer:GetTeamNumber())
        priority_friendly_affected[uid] = true
      elseif set.get("targetmode") == 2 then
        if player:GetProp("m_iPendingTeamNum") == localplayer:GetTeamNumber() then
          player:SetProp("m_iTeamNum", (localplayer:GetTeamNumber() - 1) % 2 + 2)
          priority_friendly_affected[uid] = true
        else
          if priority_friendly_affected[uid] then
            player:SetProp("m_iTeamNum", player:GetProp("m_iPendingTeamNum"))
            priority_friendly_affected[uid] = nil
          end
          if not priority_targetting_priority and player:GetTeamNumber() ~= localplayer:GetTeamNumber() and gui.GetValue("rbot.master") then
            local lp_pos = localplayer:GetAbsOrigin() + localplayer:GetPropVector("localdata", "m_vecViewOffset[0]")
            local t_pos = player:GetHitboxPosition(5)
            local trace = engine.TraceLine(lp_pos, t_pos, 0xFFFFFFFF)
            if trace.entity:IsPlayer() then
              engine.SetViewAngles((t_pos - lp_pos):Angles())
              gui.SetValue("rbot.aim.target.fov", priority_lock_fov)
              gui.SetValue("rbot.aim.target.lock", true)
              priority_targetted_entity = player
              priority_targetting_priority = true
            end
          end
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end)
callbacks.Register("FireGameEvent", "playerlist.extensions.Priority.FireGameEvent", function(event)
  if event:GetName() == "player_death" and priority_targetting_priority then
    if client.GetPlayerIndexByUserID(event:GetInt("userid")) == priority_targetted_entity:GetIndex() then
      priority_targetting_priority = false
      priority_targetted_entity = nil
      gui.SetValue("rbot.aim.target.fov", 180)
      return gui.SetValue("rbot.aim.target.lock", false)
    end
  end
end)
local fbsp_force = plist.gui.Multibox("Force ...")
do
  local _with_0 = plist.gui.Multibox_Checkbox(fbsp_force, "force.baim", "BAIM", false)
  _with_0:SetDescription("Sets bodyaim to priority.")
end
do
  local _with_0 = plist.gui.Multibox_Checkbox(fbsp_force, "force.safepoint", "Safepoint", false)
  _with_0:SetDescription("Shoots only on safepoint.")
end
local fbsp_weapon_types = {
  "asniper",
  "hpistol",
  "lmg",
  "pistol",
  "rifle",
  "scout",
  "shared",
  "shotgun",
  "smg",
  "sniper",
  "zeus"
}
local fbsp_cache_baim = {
  applied = false
}
local fbsp_baim_apply
fbsp_baim_apply = function()
  if fbsp_cache_baim.applied then
    print("[PLAYERLIST] WARNING: Force baim has already been applied.")
  end
  for _index_0 = 1, #fbsp_weapon_types do
    local weapon = fbsp_weapon_types[_index_0]
    if gui.GetValue("rbot.hitscan.mode." .. tostring(weapon) .. ".bodyaim") ~= 1 then
      fbsp_cache_baim[weapon] = gui.GetValue("rbot.hitscan.mode." .. tostring(weapon) .. ".bodyaim")
      gui.SetValue("rbot.hitscan.mode." .. tostring(weapon) .. ".bodyaim", 1)
    end
  end
  fbsp_cache_baim.applied = true
end
local fbsp_baim_undo
fbsp_baim_undo = function()
  if not fbsp_cache_baim.applied then
    print("[PLAYERLIST] WARNING: Force baim hasn't been applied.")
  end
  for weapon, value in pairs(fbsp_cache_baim) do
    local _continue_0 = false
    repeat
      if weapon == "applied" then
        _continue_0 = true
        break
      end
      gui.SetValue("rbot.hitscan.mode." .. tostring(weapon) .. ".bodyaim", value)
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  fbsp_cache_baim = {
    applied = false
  }
end
local fbsp_cache_sp = {
  applied = false
}
local fbsp_sp_regions = {
  "delayshot",
  "delayshotbody",
  "delayshotlimbs"
}
local fbsp_sp_apply
fbsp_sp_apply = function()
  if fbsp_cache_sp.applied then
    print("[PLAYERLIST] WARNING: Force safepoint has already been applied.")
  end
  for _index_0 = 1, #fbsp_weapon_types do
    local weapon = fbsp_weapon_types[_index_0]
    for _index_1 = 1, #fbsp_sp_regions do
      local delayshot_region = fbsp_sp_regions[_index_1]
      if gui.GetValue("rbot.hitscan.mode." .. tostring(weapon) .. "." .. tostring(delayshot_region)) ~= 1 then
        fbsp_cache_sp[tostring(weapon) .. "." .. tostring(delayshot_region)] = gui.GetValue("rbot.hitscan.mode." .. tostring(weapon) .. "." .. tostring(delayshot_region))
        gui.SetValue("rbot.hitscan.mode." .. tostring(weapon) .. "." .. tostring(delayshot_region), 1)
      end
    end
  end
  fbsp_cache_sp.applied = true
end
local fbsp_sp_undo
fbsp_sp_undo = function()
  if not fbsp_cache_sp.applied then
    print("[PLAYERLIST] WARNING: Force safepoint hasn't been applied.")
  end
  for weapon, value in pairs(fbsp_cache_sp) do
    local _continue_0 = false
    repeat
      if weapon == "applied" then
        _continue_0 = true
        break
      end
      gui.SetValue("rbot.hitscan.mode." .. tostring(weapon), value)
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  fbsp_cache_sp = {
    applied = false
  }
end
local fbsp_targetted_enemy = nil
callbacks.Register("AimbotTarget", "playerlist.extensions.FBSP.AimbotTarget", function(entity)
  if not entity:GetIndex() then
    return 
  end
  fbsp_targetted_enemy = entity
  local set = plist.GetByIndex(entity:GetIndex())
  if set.get("force.baim") then
    if not fbsp_cache_baim.applied then
      fbsp_baim_apply()
    end
  elseif fbsp_cache_baim.applied then
    fbsp_baim_undo()
  end
  if set.get("force.safepoint") then
    if not fbsp_cache_sp.applied then
      return fbsp_sp_apply()
    end
  elseif fbsp_cache_sp.applied then
    return fbsp_sp_undo()
  end
end)
callbacks.Register("FireGameEvent", "playerlist.extensions.FBSP.FireGameEvent", function(event)
  if event:GetName() == "player_death" and fbsp_targetted_enemy and client.GetPlayerIndexByUserID(event:GetInt("userid")) == fbsp_targetted_enemy:GetIndex() then
    fbsp_targetted_enemy = nil
    if fbsp_cache_baim.applied then
      fbsp_baim_undo()
    end
    if fbsp_cache_sp.applied then
      return fbsp_sp_undo()
    end
  end
end)
local ppe_options = plist.gui.Multibox("ESP Options")
local ppe_options_box
do
  local _with_0 = plist.gui.Multibox_Checkbox(ppe_options, "esp.box", "Box", false)
  _with_0:SetDescription("Draw box around entity.")
  ppe_options_box = _with_0
end
plist.gui.Multibox_ColorPicker(ppe_options_box, "esp.box.clr", "Box Color", 0xFF, 0x00, 0x00, 0xFF)
local ppe_options_chams
do
  local _with_0 = plist.gui.Multibox_Checkbox(ppe_options, "esp.chams", "Chams", false)
  _with_0:SetDescription("Draw chams onto the model. Colors are: visible / invisible")
  ppe_options_chams = _with_0
end
plist.gui.Multibox_ColorPicker(ppe_options_chams, "esp.chams.invclr", "Invisible Color", 0xFF, 0xFF, 0x00, 0xFF)
plist.gui.Multibox_ColorPicker(ppe_options_chams, "esp.chams.visclr", "Visible Color", 0x00, 0xFF, 0x00, 0xFF)
local ppe_options_name
do
  local _with_0 = plist.gui.Multibox_Checkbox(ppe_options, "esp.name", "Name", false)
  _with_0:SetDescription("Draw entity name.")
  ppe_options_name = _with_0
end
plist.gui.Multibox_ColorPicker(ppe_options_name, "esp.name.clr", "Color", 0xFF, 0xFF, 0xFF, 0xFF)
local ppe_options_healthbar
do
  local _with_0 = plist.gui.Multibox_Checkbox(ppe_options, "esp.healthbar", "Healthbar", false)
  _with_0:SetDescription("Draw entity healthbar. 0% alpha = health based")
  ppe_options_healthbar = _with_0
end
plist.gui.Multibox_ColorPicker(ppe_options_healthbar, "esp.healthbar.clr", "Color", 0x00, 0x00, 0x00, 0x00)
local ppe_options_ammo
do
  local _with_0 = plist.gui.Multibox_Checkbox(ppe_options, "esp.ammo", "Ammo", false)
  _with_0:SetDescription("Draw amount of money left in weapon.")
  ppe_options_ammo = _with_0
end
plist.gui.Multibox_ColorPicker(ppe_options_ammo, "esp.ammo.clr", "Color", 0xFF, 0xFF, 0xFF, 0xFF)
local ppe_magsize = {
  weapon_glock = 20,
  weapon_usp_silencer = 12,
  weapon_hkp2000 = 13,
  weapon_revolver = 8,
  weapon_cz75a = 12,
  weapon_deagle = 7,
  weapon_elite = 30,
  weapon_fiveseven = 20,
  weapon_p250 = 13,
  weapon_tec9 = 18,
  weapon_mac10 = 30,
  weapon_mp7 = 30,
  weapon_mp9 = 30,
  weapon_mp5sd = 30,
  weapon_bizon = 64,
  weapon_p90 = 50,
  weapon_ump45 = 25,
  weapon_mag7 = 5,
  weapon_nova = 8,
  weapon_sawedoff = 8,
  weapon_xn1014 = 7,
  weapon_m249 = 100,
  weapon_negev = 150,
  weapon_ak47 = 30,
  weapon_aug = 30,
  weapon_famas = 25,
  weapon_galilar = 35,
  weapon_m4a1_silencer = 25,
  weapon_m4a1 = 30,
  weapon_sg556 = 30,
  weapon_ssg08 = 10,
  weapon_scar20 = 20,
  weapon_g3sg1 = 20,
  weapon_awp = 10,
  weapon_taser = 1
}
callbacks.Register("DrawESP", "playerlist.extensions.PPE.DrawESP", function(builder)
  local player = builder:GetEntity()
  if not player:IsPlayer() then
    return 
  end
  local set = plist.GetByIndex(player:GetIndex())
  if set.get("esp.box") then
    draw.Color(unpack(set.get("esp.box.clr")))
    draw.OutlinedRect(builder:GetRect())
  end
  if set.get("esp.name") then
    builder:Color(unpack(set.get("esp.name.clr")))
    builder:AddTextTop(player:GetName())
  end
  if set.get("esp.healthbar") then
    local p = player:GetHealth() / player:GetMaxHealth()
    if set.get("esp.healthbar.clr")[4] == 0x00 then
      builder:Color(0xFF - 0xFF * p, 0xFF * p, 0x00, 0xFF)
    else
      builder:Color(unpack(set.get("esp.healthbar.clr")))
    end
    builder:AddBarLeft(p, player:GetHealth())
  end
  if set.get("esp.ammo") then
    local weapon = player:GetPropEntity("m_hActiveWeapon")
    if weapon then
      local ammoClip = weapon:GetProp("m_iClip1")
      if ammoClip >= 0 then
        if ppe_magsize[tostring(weapon)] == nil then
          print("[Player List] [WARNING] Unknow weapon: " .. tostring(weapon))
          ppe_magsize[tostring(weapon)] = ammoClip
        end
        builder:Color(unpack(set.get("esp.ammo.clr")))
        return builder:AddBarBottom(ammoClip / ppe_magsize[tostring(weapon)], ammoClip)
      end
    end
  end
end)
local ppe_chams_materials = { }
local ppe_chams_GetMat
ppe_chams_GetMat = function(color, visible)
  local name = color[1] + color[2] * 256 + color[3] * 65536 + color[4] * 16777216 + visible * 4294967296
  if ppe_chams_materials[name] then
    return ppe_chams_materials[name]
  end
  local vmt = ('\r\n        "VertexLitGeneric" {\r\n        "$basetexture" "vgui/white_additive"\r\n        "$color" "[%s %s %s]"\r\n        "$alpha" "%s"\r\n        "$ignorez" "%s"\r\n    }'):format(color[1] / 255, color[2] / 255, color[3] / 255, color[4] / 255, visible)
  ppe_chams_materials[name] = materials.Create("Chams", vmt)
  return ppe_chams_materials[name]
end
callbacks.Register("DrawModel", "playerlist.extensions.PPE.DrawModel", function(builder)
  local player = builder:GetEntity()
  if not player or not player:IsPlayer() then
    return 
  end
  local set = plist.GetByIndex(player:GetIndex())
  if set.get("esp.chams") then
    if set.get("esp.chams.invclr")[4] > 0 then
      builder:ForcedMaterialOverride(ppe_chams_GetMat(set.get("esp.chams.invclr"), 1))
      builder:DrawExtraPass()
    end
    if set.get("esp.chams.visclr")[4] > 0 then
      return builder:ForcedMaterialOverride(ppe_chams_GetMat(set.get("esp.chams.visclr"), 0))
    end
  end
end)
do
  local _with_0 = plist.gui.Checkbox("reveal_on_radar", "Reveal on Radar", false)
  _with_0:SetDescription("Reveal player on radar.")
end
callbacks.Register("CreateMove", "playerlist.extensions.ROR.CreateMove", function(usercmd)
  local _list_0 = entities.FindByClass("CCSPlayer")
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local player = _list_0[_index_0]
      if not player:IsAlive() then
        _continue_0 = true
        break
      end
      local set = plist.GetByIndex(player:GetIndex())
      player:SetProp("m_bSpotted", set.get("reveal_on_radar" and 1 or 0))
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end)
