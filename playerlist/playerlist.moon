
__version__ = "__VERSION__"
__human_version__ = "1.3.0"

-- we're using a random name for settings, so they don't get accidently saved in the config
-- and even if they did, it'll name no impact on the next session
randomname = ""
for i=1, 16
    rand = math.random 1, 16
    randomname ..= ("0123456789abcdef")\sub rand, rand

guiobjects = {}
guisettings = {}
playerlist = {}
playersettings = {}

MENU = gui.Reference"Menu"
LIST_WIDTH = 300
GUI_TAB = gui.Tab gui.Reference"Misc", "playerlist", "Player List"
GUI_WINDOW = with gui.Window "playerlist", "Player List", 100, 100, 530, 600
    \SetActive false -- disable it, tab is selected by default

GUI_TAB_CTRL_POS = { x: 8, y: 8, w: 618, h: 108 }
GUI_TAB_CTRL = gui.Groupbox GUI_TAB, "Menu Controller", GUI_TAB_CTRL_POS.x , GUI_TAB_CTRL_POS.y, GUI_TAB_CTRL_POS.w, GUI_TAB_CTRL_POS.h
GUI_TAB_CTRL_MODE = with gui.Combobox GUI_TAB_CTRL, "controller.mode", "Menu Mode", "Tab", "Window"
    \SetWidth 200
GUI_TAB_CTRL_OPENKEY = with gui.Keybox GUI_TAB_CTRL, "controller.openkey", "Window Openkey", 0
    \SetWidth 200
    \SetPosX 210
    \SetPosY 0
    \SetDisabled true

selected_player = nil
GUI_PLIST_POS = { x: GUI_TAB_CTRL_POS.x, y: GUI_TAB_CTRL_POS.y + GUI_TAB_CTRL_POS.h, w: LIST_WIDTH, h: 0 }
GUI_PLIST = gui.Groupbox GUI_TAB, "Select a player", GUI_PLIST_POS.x, GUI_PLIST_POS.y, GUI_PLIST_POS.w, GUI_PLIST_POS.h
GUI_PLIST_LIST = gui.Listbox GUI_PLIST, "#{randomname}.players", 440
GUI_PLIST_CLEAR = with gui.Button GUI_PLIST, "Clear", ->
        selected_player = nil -- reset currently selected player
        GUI_PLIST_LIST\SetOptions! -- reset displayed players
        playersettings = {}
        playerlist = {}
    \SetPosX 188
    \SetPosY -42
    \SetWidth 80

GUI_SET_POS = { x: GUI_PLIST_POS.x + GUI_PLIST_POS.w + 4, y: GUI_PLIST_POS.y, w: 618 - LIST_WIDTH, h: 0 }
GUI_SET = gui.Groupbox GUI_TAB, "Per Player Settings", GUI_SET_POS.x, GUI_SET_POS.y, GUI_SET_POS.w, GUI_SET_POS.h

settings_wrapper = (settings) ->
    {
        set: (varname, value) ->
            settings.settings[ varname ] = value
            -- if the player is currently selected, update it
            if #playerlist > 0 and playerlist[ GUI_PLIST_LIST\GetValue! + 1 ] == settings.info.uid
                guisettings[ varname ].set value
        get: (varname) ->
            settings.settings[ varname ]
    }
PreservingGUIObject = (obj, recreate) ->
    modifiers = {}
    public = {
        obj: obj
    }
    public.reapply = (nobj) ->
        public.obj = nobj
        for func, vars in pairs modifiers
            nobj[ func ] nobj, unpack vars

    setmetatable public, {
        __index: (varname) =>
            if varname\sub( 1, 3 ) == "Set"
                return (...) =>
                    modifiers[ varname ] = {...}
                    public.obj[ varname ]( public.obj, ... )
            (...) => 
                public.obj[ varname ]( public.obj, ... )
    }
    public

export plist = {
    -- custom gui library for adding your own shit :)
    gui: {
        Checkbox: ( varname, name, value ) ->
            checkbox = gui.Checkbox GUI_SET, "#{randomname}.settings.#{varname}", name, value
            pubcheckbox = PreservingGUIObject checkbox

            guisettings[ varname ] = {
                set: (value_) -> checkbox\SetValue value_
                get: -> checkbox\GetValue!
                default: value
                obj: checkbox
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = value
            table.insert guiobjects, {
                obj: checkbox
                recreate: ->
                    checkbox = gui.Checkbox GUI_SET, "#{randomname}.settings.#{varname}", name, value
                    pubcheckbox.reapply checkbox
                    checkbox
            }
            pubcheckbox

        Slider: ( varname, name, value, min, max, step ) ->
            slider = gui.Slider GUI_SET, "#{randomname}.settings.#{varname}", name, value, min, max, step or 1
            pubslider = PreservingGUIObject slider
            
            guisettings[ varname ] = {
                set: (value_) -> slider\SetValue value_
                get: -> slider\GetValue!
                default: value
                obj: slider
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = value
            table.insert guiobjects, {
                obj: slider
                recreate: ->
                    slider = gui.Slider GUI_SET, "#{randomname}.settings.#{varname}", name, value, min, max, step or 1
                    pubslider.reapply slider
                    slider
            }
            pubslider

        ColorPicker: ( varname, name, r, g, b, a ) ->
            colorpicker = gui.ColorPicker GUI_SET, "#{randomname}.settings.#{varname}", r, g, b, a
            pubcolorpicker = PreservingGUIObject colorpicker

            guisettings[ varname ] = {
                set: (value_) -> colorpicker\SetValue unpack value_
                get: -> {colorpicker\GetValue!}
                default: {r, g, b, a}
                obj: colorpicker
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = {r, g, b, a}
            table.insert guiobjects, {
                obj: colorpicker
                recreate: ->
                    colorpicker = gui.ColorPicker GUI_SET, "#{randomname}.settings.#{varname}", r, g, b, a
                    pubcolorpicker.reapply colorpicker
                    colorpicker
            }
            pubcolorpicker
                
        Text: ( varname, text ) ->
            text_ = gui.Text GUI_SET, text
            pubtext = PreservingGUIObject text_

            current_text = text
            guisettings[ varname ] = {
                set: (value_) ->
                    text_\SetText value_
                    current_text = value_
                get: -> current_text
                default: text
                obj: text_
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = text
            table.insert guiobjects, {
                obj: text_
                recreate: ->        
                    text_ = gui.Text GUI_SET, text
                    pubtext.reapply text_
                    text_
            }
            pubtext
                
        Combobox: ( varname, name, ... ) ->
            combobox = gui.Combobox GUI_SET, "#{randomname}.settings.#{varname}", name, ...
            pubcombobox = PreservingGUIObject combobox

            guisettings[ varname ] = {
                set: (value_) -> combobox\SetValue value_
                get: -> combobox\GetValue!
                default: 0
                obj: combobox
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = 0
            args = {...}
            table.insert guiobjects, {
                obj: combobox
                recreate: ->
                    combobox = gui.Combobox GUI_SET, "#{randomname}.settings.#{varname}", name, unpack args
                    pubcombobox.reapply combobox
                    combobox
            }
            pubcombobox
        
        Button: ( name, callback ) ->
            mcallback = ->
                if #playerlist > 0
                    callback playerlist[ GUI_PLIST_LIST\GetValue! + 1 ]
                else
                    callback!
                return "__REMOVE_ME__"
            button = gui.Button GUI_SET, name, mcallback
            pubbutton = PreservingGUIObject button

            table.insert guiobjects, {
                obj: button
                recreate: ->
                    button = gui.Button GUI_SET, name, mcallback
                    pubbutton.reapply button
                    button
            }
            pubbutton

        Editbox: ( varname, name ) ->
            editbox = gui.Editbox GUI_SET, varname, name
            pubeditbox =  PreservingGUIObject editbox

            guisettings[ varname ] = {
                set: (value_) -> editbox\SetValue value_
                get: -> editbox\GetValue!
                default: 0
                obj: editbox
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = 0
            table.insert guiobjects, {
                obj: editbox
                recreate: ->
                    editbox = gui.Editbox GUI_SET, varname, name
                    pubeditbox.reapply editbox
                    editbox
            }
            pubeditbox

        Multibox: ( name ) ->
            multibox = gui.Multibox GUI_SET, name
            pubmultibox = PreservingGUIObject multibox

            table.insert guiobjects, {
                obj: multibox
                recreate: ->
                    multibox = gui.Multibox GUI_SET, name
                    pubmultibox.reapply multibox
                    multibox
            }
            pubmultibox

        Multibox_Checkbox: ( parent, varname, name, value ) ->
            checkbox = gui.Checkbox parent.obj, "#{randomname}.settings.#{varname}", name, value
            pubcheckbox = PreservingGUIObject checkbox

            guisettings[ varname ] = {
                set: (value_) -> checkbox\SetValue value_
                get: -> checkbox\GetValue!
                default: value
                obj: checkbox
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = value
            table.insert guiobjects, {
                obj: checkbox
                recreate: ->
                    checkbox = gui.Checkbox parent.obj, "#{randomname}.settings.#{varname}", name, value
                    pubcheckbox.reapply checkbox
                    checkbox
            }
            pubcheckbox
        
        Multibox_ColorPicker: ( parent, varname, name, r, g, b, a ) ->
            colorpicker = gui.ColorPicker parent.obj, varname, r, g, b, a
            pubcolorpicker = PreservingGUIObject colorpicker

            guisettings[ varname ] = {
                set: (value_) -> colorpicker\SetValue unpack value_
                get: -> {colorpicker\GetValue!}
                default: {r, g, b, a}
                obj: colorpicker
            }
            for _, setting in pairs playersettings
                setting.settings[ varname ] = {r, g, b, a}
            table.insert guiobjects, {
                obj: colorpicker
                recreate: ->
                    colorpicker = gui.ColorPicker parent.obj, "#{randomname}.settings.#{varname}", r, g, b, a
                    pubcolorpicker.reapply colorpicker
                    colorpicker
            }
            pubcolorpicker

        Remove: ( object ) ->
            object\Remove!
            for varname, info in pairs guisettings
                if info.obj == object.obj -- found matching varname
                    guisettings[ varname ] = nil -- remove object from varnames
                    for _, set in pairs playersettings
                        set.settings[ varname ] = nil -- remove object from all players
                    break -- only one can match, so we quit

    }
    GetByUserID: (userid) ->
        if not playersettings[ userid ]
            error "Playerlist: No settings for userid: #{userid}", 2
        settings_wrapper playersettings[ userid ]
    GetByIndex: (index) ->
        pinfo = client.GetPlayerInfo index
        if pinfo != nil -- is on server
            if not playersettings[ pinfo[ "UserID" ] ]
                error "Playerlist: No settings for index: #{index}", 2
            return settings_wrapper playersettings[ pinfo[ "UserID" ] ]

        for _, info in pairs playersettings
            if info.info.index == index then return settings_wrapper info

    GetSelected: ->
        if #playerlist > 0
           settings_wrapper playersettings[ playerlist[ GUI_PLIST_LIST\GetValue! + 1 ] ]
        nil
    GetSelectedIndex: ->
        if #playerlist > 0
            playersettings[ playerlist[ GUI_PLIST_LIST\GetValue! + 1 ] ].info.index
        nil
    GetSelectedUserID: ->
        if #playerlist > 0
            playerlist[ GUI_PLIST_LIST\GetValue! + 1 ]
        nil
}

selected_ctrl_mode = 0
selected_ctrl_openkey = 0
teamname = (other) ->
    if other == 1 then "SPECTATOR"
    elseif other == 2 then "T"
    else "CT"
callbacks.Register "Draw", "playerlist.callbacks.Draw", ->
    if GUI_TAB_CTRL_OPENKEY\GetValue! == 0 and GUI_TAB_CTRL_MODE\GetValue! == 1
        GUI_WINDOW\SetActive MENU\IsActive!
    if not MENU\IsActive! and (GUI_TAB_CTRL_MODE\GetValue! == 0 or (not GUI_WINDOW\IsActive! or GUI_TAB_CTRL_MODE\GetValue! != 0)) then return
    
    if GUI_TAB_CTRL_OPENKEY\GetValue! != selected_ctrl_openkey and GUI_TAB_CTRL_MODE\GetValue! == 1
        selected_ctrl_openkey = GUI_TAB_CTRL_OPENKEY\GetValue!
        GUI_WINDOW\SetOpenKey selected_ctrl_openkey

    if GUI_TAB_CTRL_MODE\GetValue! != selected_ctrl_mode
        if GUI_TAB_CTRL_MODE\GetValue! == 0 -- window > tab
            GUI_PLIST\Remove!
            GUI_PLIST_LIST\Remove!
            GUI_PLIST_CLEAR\Remove!

            GUI_PLIST = gui.Groupbox GUI_TAB, "Select a player", GUI_PLIST_POS.x, GUI_PLIST_POS.y, GUI_PLIST_POS.w, GUI_PLIST_POS.h
            GUI_PLIST_LIST = gui.Listbox GUI_PLIST, "#{randomname}.players", 440
            GUI_PLIST_CLEAR = with gui.Button GUI_PLIST, "Clear", ->
                    selected_player = nil -- reset currently selected player
                    GUI_PLIST_LIST\SetOptions! -- reset displayed players
                    playersettings = {}
                    playerlist = {}
                \SetPosX 188
                \SetPosY -42
                \SetWidth 80

            GUI_SET\Remove!
            GUI_SET = gui.Groupbox GUI_TAB, "Per Player Settings", GUI_SET_POS.x, GUI_SET_POS.y, GUI_SET_POS.w, GUI_SET_POS.h

            for guiobj_index=1, #guiobjects
                guiobjects[ guiobj_index ].obj\Remove!
                guiobjects[ guiobj_index ].obj = guiobjects[ guiobj_index ].recreate GUI_SET
            
            GUI_TAB_CTRL_OPENKEY\SetDisabled true
            GUI_WINDOW\SetActive false
            GUI_WINDOW\SetOpenKey 0
        else -- tab > window
            GUI_PLIST\Remove!
            GUI_PLIST_LIST\Remove!
            GUI_PLIST_CLEAR\Remove!

            GUI_PLIST = gui.Groupbox GUI_WINDOW, "Select a player", 8, 8, 188, 584
            GUI_PLIST_LIST = gui.Listbox GUI_PLIST, "#{randomname}.players", 494
            GUI_PLIST_CLEAR = with gui.Button GUI_PLIST, "Clear", ->
                    selected_player = nil -- reset currently selected player
                    GUI_PLIST_LIST\SetOptions! -- reset displayed players
                    playersettings = {}
                    playerlist = {}
                \SetPosX 84
                \SetPosY -42
                \SetWidth 80

            GUI_SET\Remove!
            GUI_SET = gui.Groupbox GUI_WINDOW, "Per Player Settings", 200, 8, 318, 584

            for guiobj_index=1, #guiobjects
                guiobjects[ guiobj_index ].obj\Remove!
                guiobjects[ guiobj_index ].obj = guiobjects[ guiobj_index ].recreate GUI_SET
            
            GUI_TAB_CTRL_OPENKEY\SetDisabled false
            GUI_WINDOW\SetOpenKey GUI_TAB_CTRL_OPENKEY\GetValue!

        selected_ctrl_mode = GUI_TAB_CTRL_MODE\GetValue!
        selected_player = nil -- reset to reload settings
        GUI_PLIST_LIST\SetOptions unpack ["[" .. teamname( playersettings[ v ].info.team ) .. "] " .. playersettings[ v ].info.nickname for _, v in ipairs playerlist]

    if #playerlist == 0
        for guiobj in *guiobjects
            guiobj.obj\SetDisabled true
        selected_player = nil
        return
    elseif selected_player == nil
        for guiobj in *guiobjects
            guiobj.obj\SetDisabled false

    if selected_player != GUI_PLIST_LIST\GetValue!
        selected_player = GUI_PLIST_LIST\GetValue!

        set = playersettings[ playerlist[ GUI_PLIST_LIST\GetValue! + 1 ] ].settings
        for varname, wrap in pairs guisettings
            wrap.set set[ varname ]
    else
        set = playersettings[ playerlist[ GUI_PLIST_LIST\GetValue! + 1 ] ].settings
        for varname, wrap in pairs guisettings
            set[ varname ] = wrap.get!

last_map = nil
last_server = nil
callbacks.Register "CreateMove", "playerlist.callbacks.CreateMove", (cmd) ->
    if engine.GetMapName! != last_map or engine.GetServerIP! != last_server -- different server / map
        last_map = engine.GetMapName!
        last_server = engine.GetServerIP!
        selected_player = nil -- reset currently selected player
        GUI_PLIST_LIST\SetOptions! -- reset displayed players
        playersettings = {}
        playerlist = {}

    for player in *entities.FindByClass"CCSPlayer"
        continue if client.GetPlayerInfo( player\GetIndex! )[ "IsGOTV" ]
        uid = client.GetPlayerInfo( player\GetIndex! )[ "UserID" ]
        if playersettings[ uid ] == nil -- never seen the player
            table.insert playerlist, uid
            playersettings[ uid ] = {
                info: {
                    nickname: player\GetName!
                    uid: uid
                    index: player\GetIndex!
                    team: player\GetProp "m_iPendingTeamNum"
                }
                settings: {}
            }
            set = playersettings[ uid ].settings
            for varname, wrap in pairs guisettings
                set[ varname ] = wrap.default

            selected_player = nil -- order changed, so we have to load the information from the new player, or we'll overwrite their info
            GUI_PLIST_LIST\SetOptions unpack ["[" .. teamname( playersettings[ v ].info.team ) .. "] " .. playersettings[ v ].info.nickname for _, v in ipairs playerlist]

        if playersettings[ uid ].info.nickname != player\GetName! -- changed name
            playersettings[ uid ].info.nickname = player\GetName!
            GUI_PLIST_LIST\SetOptions unpack ["[" .. teamname( playersettings[ v ].info.team ) .. "] " .. playersettings[ v ].info.nickname for _, v in ipairs playerlist]

        if playersettings[ uid ].info.team != player\GetProp "m_iPendingTeamNum" -- changed team
            playersettings[ uid ].info.team = player\GetProp "m_iPendingTeamNum"
            GUI_PLIST_LIST\SetOptions unpack ["[" .. teamname( playersettings[ v ].info.team ) .. "] " .. playersettings[ v ].info.nickname for _, v in ipairs playerlist]

-- updater
http.Get "__VERSION_URL__", (content) ->
    if not content then return
    if content == __version__ then return
    -- update, yay!
    UPD_HEIGHT = 180
    UPDATE = gui.Groupbox GUI_TAB, "Update Available", GUI_TAB_CTRL_POS.x, GUI_TAB_CTRL_POS.y + GUI_TAB_CTRL_POS.h, 618, UPD_HEIGHT
    text = gui.Text UPDATE, "A new update has been spotted. You are using #{__human_version__}"
    minified = gui.Checkbox UPDATE, "updater.minified", "Download minified version", true
    local btn
    btn = with gui.Button UPDATE, "Update", ->
            text\SetText "Updating..."
            btn\SetDisabled true -- disable update button
            http.Get (if minified\GetValue! then "__VERSION_LUA_MIN__" else "__VERSION_LUA__"), (luacode) ->
                if luacode
                    text\SetText "Saving..."
                    with file.Open GetScriptName!, "w"
                        \Write luacode
                        \Close!
                    text\SetText "Updated to version: #{content}.\nReload `#{GetScriptName!}` for changes to take effect."
                else
                    text\SetText "Failed."
                    btn\SetDisabled false -- enable button for retrying
            return "__REMOVE_ME__"
        \SetWidth 290
    with gui.Button UPDATE, "Open Changelog in Browser", ->
            panorama.RunScript "SteamOverlayAPI.OpenExternalBrowserURL('https://github.com/Le0Developer/awluas/blob/master/playerlist/changelog.md');"
        \SetWidth 290
        \SetPosX 300
        \SetPosY 78

    -- move other boxes down
    GUI_PLIST_POS.y += UPD_HEIGHT
    GUI_PLIST\SetPosY GUI_PLIST_POS.y
    GUI_SET_POS.y += UPD_HEIGHT
    if GUI_TAB_CTRL_MODE\GetValue! == 0 -- only update in tab mode
        GUI_SET\SetPosY GUI_SET_POS.y

-- resolver extension
with plist.gui.Combobox "resolver.type", "Resolver", "Automatic", "On", "Off"
    \SetDescription "Choose a resolver for this player."


callbacks.Register "AimbotTarget", "playerlist.extensions.Resolver.AimbotTarget", (entity) ->
    if not entity\GetIndex! then return
    set = plist.GetByIndex entity\GetIndex!
    resolver_toggle = false
    if set.get"resolver.type" == 0
        if entity\GetPropVector"m_angEyeAngles".x >= 85 -- check if enemy is looking down
            resolver_toggle = true
        elseif entity\GetPropFloat("m_flPoseParameter", 11) > 29 -- check if lby delta is a bit too high
            resolver_toggle = true
    elseif set.get"resolver.type" == 1
        resolver_toggle = true
    if gui.GetValue "rbot.master"
        gui.SetValue "rbot.accuracy.posadj.resolver", resolver_toggle and 1 or 0
    else
        gui.SetValue "lbot.posadj.resolver", resolver_toggle

-- player priority extension
priority_targetted_entity = nil
priority_targetting_priority = false
callbacks.Register "AimbotTarget", "playerlist.extensions.Priority.AimbotTarget", (entity) ->
    if not entity\GetIndex! then return
	if priority_targetted_entity and entity\GetIndex! != priority_targetted_entity\GetIndex!
		if priority_targetting_priority
			-- reset lock cuz we're attacking someone else
			--print("switchting to something different than priority target (lock off)", priority_targetted_entity)
			gui.SetValue "rbot.aim.target.lock", false
		priority_targetted_entity = entity
		priority_targetting_priority = false
	elseif priority_targetting_priority
		-- reset fov because we're already locking
		--print("targetting priority target (fov off)", priority_targetted_entity)
		gui.SetValue "rbot.aim.target.fov", 180

with plist.gui.Combobox "targetmode", "Targetmode", "Normal", "Friendly", "Priority"
    \SetDescription "Mode for targetting. NOTE: Priority on teammates attack them."

priority_lock_fov = 3
priority_friendly_affected = {}
callbacks.Register "CreateMove", "playerlist.extensions.Priority.CreateMove", (cmd) ->
    localplayer = entities.GetLocalPlayer!
    for player in *entities.FindByClass"CCSPlayer"
        if not player\IsAlive!
            continue
			
		set = plist.GetByIndex player\GetIndex!
        uid = client.GetPlayerInfo( player\GetIndex! )[ "UserID" ]
		if set.get"targetmode" == 0 and priority_friendly_affected[ uid ] -- reset team number
			player\SetProp "m_iTeamNum",  player\GetProp "m_iPendingTeamNum" -- `m_iPendingTeamNum`, seems to work for resetting
			priority_friendly_affected[ uid ] = nil
		elseif set.get"targetmode" == 1 -- change team number to my team
			player\SetProp "m_iTeamNum", localplayer\GetTeamNumber!
			priority_friendly_affected[ uid ] = true
		elseif set.get"targetmode" == 2
			if player\GetProp"m_iPendingTeamNum" == localplayer\GetTeamNumber! -- in my team = make him enemy
				player\SetProp "m_iTeamNum", (localplayer\GetTeamNumber!-1) % 2 + 2 -- this seems to work for getting enemy team number
				priority_friendly_affected[ uid ] = true
			else
				if priority_friendly_affected[ uid ] -- reset team number
					player\SetProp "m_iTeamNum",  player\GetProp "m_iPendingTeamNum" -- `m_iPendingTeamNum`, seems to work for resetting
					priority_friendly_affected[ uid ] = nil
				-- if we arent targetting anyone and check if ragebot is enabled - dont want to mess legitbot up
				if not priority_targetting_priority and player\GetTeamNumber! != localplayer\GetTeamNumber! and gui.GetValue"rbot.master"
					-- pasted code from Zarkos & converted to moonscript

					lp_pos = localplayer\GetAbsOrigin! + localplayer\GetPropVector "localdata", "m_vecViewOffset[0]"
					t_pos = player\GetHitboxPosition 5

                    trace = engine.TraceLine lp_pos, t_pos, 0xFFFFFFFF
                    if trace.entity\IsPlayer!
                        engine.SetViewAngles (t_pos - lp_pos)\Angles!
                        gui.SetValue "rbot.aim.target.fov", priority_lock_fov
                        gui.SetValue "rbot.aim.target.lock", true
                        priority_targetted_entity = player
                        priority_targetting_priority = true
					
    					--print("priority targetting", player)

callbacks.Register "FireGameEvent", "playerlist.extensions.Priority.FireGameEvent", (event) ->
	-- we have to reset FOV and stuff after they die
	if event\GetName! == "player_death" and priority_targetting_priority
		if client.GetPlayerIndexByUserID( event\GetInt"userid" ) == priority_targetted_entity\GetIndex!
			--print("priority target died", priority_targetted_entity)
			
			priority_targetting_priority = false
			priority_targetted_entity = nil
			gui.SetValue "rbot.aim.target.fov", 180
			gui.SetValue "rbot.aim.target.lock", false
			
-- Force Baim / SafePoint extension (fbsp)
fbsp_force = plist.gui.Multibox "Force ..."
with plist.gui.Multibox_Checkbox fbsp_force, "force.baim", "BAIM", false
    \SetDescription "Sets bodyaim to priority."
with plist.gui.Multibox_Checkbox fbsp_force, "force.safepoint", "Safepoint", false
    \SetDescription "Shoots only on safepoint."

-- setters and undoers
fbsp_weapon_types = {"asniper", "hpistol", "lmg", "pistol", "rifle", "scout", "shared", "shotgun", "smg", "sniper", "zeus"}
fbsp_cache_baim = { applied: false }
fbsp_baim_apply = ->
    if fbsp_cache_baim.applied
        print( "[PLAYERLIST] WARNING: Force baim has already been applied." )
    for weapon in *fbsp_weapon_types
        if gui.GetValue"rbot.hitscan.mode.#{weapon}.bodyaim" != 1
            fbsp_cache_baim[ weapon ] = gui.GetValue"rbot.hitscan.mode.#{weapon}.bodyaim"
            gui.SetValue "rbot.hitscan.mode.#{weapon}.bodyaim", 1 -- priority
    fbsp_cache_baim.applied = true
fbsp_baim_undo = ->
    if not fbsp_cache_baim.applied
        print( "[PLAYERLIST] WARNING: Force baim hasn't been applied." )
    for weapon, value in pairs fbsp_cache_baim
        continue if weapon == "applied"
        gui.SetValue "rbot.hitscan.mode.#{weapon}.bodyaim", value

    fbsp_cache_baim = { applied: false }

fbsp_cache_sp = { applied: false }
fbsp_sp_regions = {"delayshot", "delayshotbody", "delayshotlimbs"}
fbsp_sp_apply = -> -- sp = safepoint
    if fbsp_cache_sp.applied
        print( "[PLAYERLIST] WARNING: Force safepoint has already been applied." )
    for weapon in *fbsp_weapon_types
        for delayshot_region in *fbsp_sp_regions
            if gui.GetValue"rbot.hitscan.mode.#{weapon}.#{delayshot_region}" != 1
                fbsp_cache_sp[ "#{weapon}.#{delayshot_region}" ] = gui.GetValue"rbot.hitscan.mode.#{weapon}.#{delayshot_region}"
                gui.SetValue "rbot.hitscan.mode.#{weapon}.#{delayshot_region}", 1 -- 1 == safepoint
    fbsp_cache_sp.applied = true
fbsp_sp_undo = ->
    if not fbsp_cache_sp.applied
        print( "[PLAYERLIST] WARNING: Force safepoint hasn't been applied." )
    for weapon, value in pairs fbsp_cache_sp
        continue if weapon == "applied"
        gui.SetValue "rbot.hitscan.mode.#{weapon}", value

    fbsp_cache_sp = { applied: false }

fbsp_targetted_enemy = nil
callbacks.Register "AimbotTarget", "playerlist.extensions.FBSP.AimbotTarget", (entity) ->
    if not entity\GetIndex! then return

    fbsp_targetted_enemy = entity
    
    set = plist.GetByIndex entity\GetIndex!
    if set.get"force.baim"
        if not fbsp_cache_baim.applied
            fbsp_baim_apply!
    elseif fbsp_cache_baim.applied
        fbsp_baim_undo!
        
    if set.get"force.safepoint"
        if not fbsp_cache_sp.applied
            fbsp_sp_apply!
    elseif fbsp_cache_sp.applied
        fbsp_sp_undo!
        

callbacks.Register "FireGameEvent", "playerlist.extensions.FBSP.FireGameEvent", (event) ->
	if event\GetName! == "player_death" and fbsp_targetted_enemy and client.GetPlayerIndexByUserID( event\GetInt"userid" ) == fbsp_targetted_enemy\GetIndex! -- reset enemy after death
        fbsp_targetted_enemy = nil
        if fbsp_cache_baim.applied
            fbsp_baim_undo!
        if fbsp_cache_sp.applied
            fbsp_sp_undo!

-- per player esp extension (ppe)
ppe_options = plist.gui.Multibox "ESP Options"
ppe_options_box = with plist.gui.Multibox_Checkbox ppe_options, "esp.box", "Box", false
    \SetDescription "Draw box around entity."
plist.gui.Multibox_ColorPicker ppe_options_box, "esp.box.clr", "Box Color", 0xFF, 0x00, 0x00, 0xFF

ppe_options_chams = with plist.gui.Multibox_Checkbox ppe_options, "esp.chams", "Chams", false
    \SetDescription "Draw chams onto the model. Colors are: visible / invisible"
plist.gui.Multibox_ColorPicker ppe_options_chams, "esp.chams.invclr", "Invisible Color", 0xFF, 0xFF, 0x00, 0xFF
plist.gui.Multibox_ColorPicker ppe_options_chams, "esp.chams.visclr", "Visible Color", 0x00, 0xFF, 0x00, 0xFF

ppe_options_name = with plist.gui.Multibox_Checkbox ppe_options, "esp.name", "Name", false
    \SetDescription "Draw entity name."
plist.gui.Multibox_ColorPicker ppe_options_name, "esp.name.clr", "Color", 0xFF, 0xFF, 0xFF, 0xFF

ppe_options_healthbar = with plist.gui.Multibox_Checkbox ppe_options, "esp.healthbar", "Healthbar", false
    \SetDescription "Draw entity healthbar. 0% alpha = health based"
plist.gui.Multibox_ColorPicker ppe_options_healthbar, "esp.healthbar.clr", "Color", 0x00, 0x00, 0x00, 0x00

ppe_options_ammo = with plist.gui.Multibox_Checkbox ppe_options, "esp.ammo", "Ammo", false
    \SetDescription "Draw amount of money left in weapon."
plist.gui.Multibox_ColorPicker ppe_options_ammo, "esp.ammo.clr", "Color", 0xFF, 0xFF, 0xFF, 0xFF

-- a bit copy pasta from https://aimware.net/forum/thread/109067 (V4 script)
ppe_magsize = { -- is there an easier way to get the magsize?
    -- pistols
    weapon_glock: 20, weapon_usp_silencer: 12, weapon_hkp2000: 13, weapon_revolver: 8, weapon_cz75a: 12, weapon_deagle: 7, weapon_elite: 30, weapon_fiveseven: 20, weapon_p250: 13, weapon_tec9: 18
    -- smgs
    weapon_mac10: 30, weapon_mp7: 30, weapon_mp9: 30, weapon_mp5sd: 30, weapon_bizon: 64, weapon_p90: 50, weapon_ump45: 25
    -- heavy
    weapon_mag7: 5, weapon_nova: 8, weapon_sawedoff: 8, weapon_xn1014: 7, weapon_m249: 100, weapon_negev: 150
    -- rifles
    weapon_ak47: 30, weapon_aug: 30, weapon_famas: 25, weapon_galilar: 35, weapon_m4a1_silencer: 25, weapon_m4a1: 30, weapon_sg556: 30
    -- snipers
    weapon_ssg08: 10, weapon_scar20: 20, weapon_g3sg1: 20, weapon_awp: 10
    -- zeus
    weapon_taser: 1
}
callbacks.Register "DrawESP", "playerlist.extensions.PPE.DrawESP", (builder) ->
    player = builder\GetEntity!
    if not player\IsPlayer! then return
    
    set = plist.GetByIndex( player\GetIndex! )
    if set.get "esp.box"
        draw.Color unpack set.get "esp.box.clr"
        draw.OutlinedRect builder\GetRect!
    if set.get "esp.name"
        builder\Color unpack set.get "esp.name.clr"
        builder\AddTextTop player\GetName!
    if set.get "esp.healthbar"
        p = player\GetHealth! / player\GetMaxHealth!
        if set.get"esp.healthbar.clr"[ 4 ] == 0x00
            builder\Color 0xFF - 0xFF * p, 0xFF * p, 0x00, 0xFF
        else
            builder\Color unpack set.get "esp.healthbar.clr"
        builder\AddBarLeft p, player\GetHealth!
    if set.get "esp.ammo"
        weapon = player\GetPropEntity "m_hActiveWeapon"
        if weapon
            ammoClip = weapon\GetProp "m_iClip1"
            if ammoClip >= 0 -- negative numbers = has no ammo (e.g. knife)
                if ppe_magsize[ tostring weapon ] == nil
                    print "[Player List] [WARNING] Unknow weapon: #{weapon}"
                    ppe_magsize[ tostring weapon ] = ammoClip
                builder\Color unpack set.get "esp.ammo.clr"
                builder\AddBarBottom ammoClip / ppe_magsize[ tostring weapon ], ammoClip

-- credits to Zerdos for the chams code
ppe_chams_materials = {}
ppe_chams_GetMat = (color, visible) ->
    name = color[ 1 ] + color[ 2 ] * 256 + color[ 3 ] * 65536 + color[ 4 ] * 16777216 + visible * 4294967296
    if ppe_chams_materials[ name ]
        return ppe_chams_materials[ name ]

    vmt = '
        "VertexLitGeneric" {
        "$basetexture" "vgui/white_additive"
        "$color" "[%s %s %s]"
        "$alpha" "%s"
        "$ignorez" "%s"
    }'\format color[ 1 ] / 255, color[ 2 ] / 255, color[ 3 ] / 255, color[ 4 ] / 255, visible

    ppe_chams_materials[ name ] = materials.Create "Chams", vmt
    ppe_chams_materials[ name ]

callbacks.Register "DrawModel", "playerlist.extensions.PPE.DrawModel", (builder) ->
    player = builder\GetEntity!
    if not player or not player\IsPlayer! then return

    set = plist.GetByIndex( player\GetIndex! )
    if set.get "esp.chams"
        if set.get"esp.chams.invclr"[ 4 ] > 0
            builder\ForcedMaterialOverride ppe_chams_GetMat set.get"esp.chams.invclr", 1
            builder\DrawExtraPass!
        if set.get"esp.chams.visclr"[ 4 ] > 0
            builder\ForcedMaterialOverride ppe_chams_GetMat set.get"esp.chams.visclr", 0

-- reveal on radar extension (ror)
with plist.gui.Checkbox "reveal_on_radar", "Reveal on Radar", false
    \SetDescription "Reveal player on radar."

-- isnt really pasted, but before someone complains
-- credits to https://aimware.net/forum/thread/88645
callbacks.Register "CreateMove", "playerlist.extensions.ROR.CreateMove", (usercmd) ->
    for player in *entities.FindByClass"CCSPlayer"
        if not player\IsAlive!
            continue
			
		set = plist.GetByIndex player\GetIndex!
        player\SetProp "m_bSpotted", set.get "reveal_on_radar" and 1 or 0

-- removed by `build.py` to prevent crashes
return "__REMOVE_ME__"