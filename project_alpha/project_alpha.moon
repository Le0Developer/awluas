
local gui_invert
__version__ = "__VERSION__"

types = {}
add_type = (name, description, apply_func, setup_func) ->
    table.insert types, {:name, :description, apply: apply_func, setup: setup_func}

-- Add AntiAim types

add_type "Legit AA", "Legit AA with Ragebot",
    (cmd) ->
        changes = {}
        changes["rbot.antiaim.fakeyawstyle"] = if gui_invert\GetValue! then 2 else 1
        changes,
    ->
        -- setup lby override
        gui.SetValue "rbot.antiaim.lbyoverride", true
        gui.SetValue "rbot.antiaim.lby", 58
        gui.SetValue "rbot.antiaim.lbyextend", true
        gui.SetValue "rbot.antiaim.extra.advconfig", true
        -- set max desync
        gui.SetValue "rbot.antiaim.desync", 58
        -- set yaw
        gui.SetValue "rbot.antiaim.yawstyle", 1
        gui.SetValue "rbot.antiaim.yaw", 0


add_type "Real Rapid Switch", "Switching the real from the left to the right side very fast.\nBasically makes hitting you pure luck.",
    (cmd) ->
        changes = {}
        changes["rbot.antiaim.fakeyawstyle"] = if cmd.tick_count % (1 / globals.TickInterval! % 16) >= 2 then 1 else 2
        changes,
    ->
        gui.SetValue "rbot.antiaim.lbyextend", false
        gui.SetValue "rbot.antiaim.lbyoverride", false
        -- set desync
        gui.SetValue "rbot.antiaim.desync", 58


add_type "Real Rapid Switch & Jitter", "Switching the real from the left to the right when moving and jittering at full extended when standing.",
    (cmd) ->
        localplayer = entities.GetLocalPlayer!
        velocity = math.sqrt( localplayer\GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + localplayer\GetPropFloat( "localdata", "m_vecVelocity[1]" )^2 )

        changes = {}
        if velocity > 5
            changes["rbot.antiaim.lbyextend"] = false
            changes["rbot.antiaim.fakeyawstyle"] = if cmd.tick_count % (1 / globals.TickInterval! / 16) >= 2 then 1 else 2
        else
            changes["rbot.antiaim.lbyextend"] = true
            changes["rbot.antiaim.fakeyawstyle"] = if gui_invert\GetValue! then 2 else 1
            changes["rbot.antiaim.yaw"] = if cmd.tick_count % (1 / globals.TickInterval! / 16) >= 2 then 178 else -178
        changes,
    ->
        -- set desync
        gui.SetValue "rbot.antiaim.desync", 58
        gui.SetValue "rbot.antiaim.extra.advconfig", false
        gui.SetValue "rbot.antiaim.lbyextend", false
        gui.SetValue "rbot.antiaim.lbyoverride", false


add_type "Sway Fake and Sway Real", "Sways the real and fake.\nGood against skeet but wouldn't recommend against bruteforce.",
    (cmd) ->
        changes = {}
        if cmd.tick_count % (1 / globals.TickInterval!) == 0
            changes["rbot.antiaim.lby"] = if gui.GetValue"rbot.antiaim.lby" == 58 then -58 else 58
        changes["rbot.antiaim.fakeyawstyle"] = if gui_invert\GetValue! then 2 else 1
        changes,
    ->
        -- enable lby override
        gui.SetValue "rbot.antiaim.lbyextend", true
        gui.SetValue "rbot.antiaim.lbyoverride", true
        gui.SetValue "rbot.antiaim.extra.advconfig", true
        -- set desync
        gui.SetValue "rbot.antiaim.desync", 0
        -- set side to left
        gui.SetValue "rbot.antiaim.fakeyawstyle", 1


add_type "Jitter Fake Out", "Gets OTCv2 to dump every shot as long as the real is not hitable.\nWorks good against free cheats/pastes.",
    (cmd) ->
        changes = {}
        changes["rbot.antiaim.fakeyawstyle"] = if gui_invert\GetValue! then 3 else 4
        changes,
    ->
        gui.SetValue "rbot.antiaim.lbyextend", true
        gui.SetValue "rbot.antiaim.lbyoverride", false
        gui.SetValue "rbot.antiaim.extra.advconfig", true


add_type "Random", "Changes real every 0.25sec between LEFT, MID and RIGHT.",
    (cmd) ->
        changes = {}
        if cmd.tick_count % (1 / globals.TickInterval! * 0.25) == 0
            angle = math.random -1, 1
            changes["rbot.antiaim.fakeyawstyle"] = if angle < 0 then 1 else 2
            changes["rbot.antiaim.desync"] = math.abs angle * 58

        changes,
    ->
        gui.SetValue "rbot.antiaim.extra.advconfig", false
        gui.SetValue "rbot.antiaim.lbyextend", false
        gui.SetValue "rbot.antiaim.lbyoverride", false


-- No more AntiAim types after this

gui_tab = gui.Tab gui.Reference"Ragebot", "project_alpha", "Project Alpha"
gui_aa = gui.Groupbox gui_tab, "AntiAim Modes", 16, 16, 300, 400
gui_misc = gui.Groupbox gui_tab, "Misc", 332, 16, 300, 400


gui_type = gui.Combobox gui_aa, "project_alpha.type", "Type", "No special AA", unpack [k.name for k in *types]
gui_description = gui.Text gui_aa, "No description."
gui_invert = with gui.Checkbox gui_aa, "project_alpha.invert", "Invert", false
    \SetDescription "Should be used for invertion. Might not have effect."

gui_version = gui.Text gui_misc, "Checking for update..."
gui_update = gui.Button gui_misc, "Update", ->
    gui_update\SetDisabled true
    http.Get "__VERSION_LUA_MIN__", (content) ->
        file.Write GetScriptName!, content
        gui_update\SetDisabled false
        gui_version\SetText "Updated, please reload the lua."
        "__REMOVE_ME__"

    "__REMOVE_ME__"
gui_debug = with gui.Checkbox gui_misc, "project_alpha.debug", "Debug", false
    \SetDescription "Prints debug information in console."



last_type_move = nil
last_type_draw = nil


apply_changes = (changes, debug) ->
    for name, value in pairs changes
        if gui.GetValue(name) != value
            if debug
                print "[PROJECT ALPHA] [#{debug}] Changed value at #{name} from #{gui.GetValue name} to #{value}"
            gui.SetValue name, value


callbacks.Register "Draw", ->
    typeno = gui_type\GetValue!
    if typeno != last_type_draw
        if typeno == 0
            gui_description\SetText "You currently have no type selected, so this lua does nothing."
        else
            gui_description\SetText types[typeno].description
        last_type_draw = typeno


callbacks.Register "CreateMove", (cmd) ->
    typeno = gui_type\GetValue!
    if typeno == 0
        last_type_move = 0
        return

    type = types[typeno]

    if typeno != last_type_move -- changed type
        type.setup!
        last_type_move = typeno
    
    if changes = type.apply cmd
        apply_changes changes, if gui_debug\GetValue! then cmd.tick_count else nil


http.Get "__VERSION_URL__", (content) ->
    return unless content
    if content == "404: Not Found"
        gui_version\SetText "Github repository is down."
        gui_update\SetDisabled true
        return
    if content == __version__
        gui_version\SetText "You are up to date."
    else
        gui_version\SetText "An update is available, please press update!"

"__REMOVE_ME__"
