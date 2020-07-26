force_onshot = with gui.Checkbox gui.Reference("Ragebot", "Aimbot", "Automation"), "onshot", "Force onshot", false
    \SetDescription"Binding recommended."
    

onshotable = { }
changes = false
ApplyOnshots = ->
    lp = entities.GetLocalPlayer!
    if force_onshot\GetValue!
        changes = true
        for player in *entities.FindByClass("CCSPlayer")
            if player\GetProp"m_iPendingTeamNum" ~= lp\GetProp"m_iPendingTeamNum"
                if onshotable[player\GetIndex!]
                    has_onshot = onshotable[player\GetIndex!] > globals.CurTime!
                    if has_onshot 
                        player\SetProp "m_iTeamNum", player\GetProp"m_iPendingTeamNum"
                    else
                        player\SetProp "m_iTeamNum", lp\GetProp"m_iTeamNum"
                else
                    player\SetProp "m_iTeamNum", lp\GetProp"m_iTeamNum"

    elseif changes
        changes = false
        for player in *entities.FindByClass("CCSPlayer")
            player\SetProp("m_iTeamNum", player\GetProp("m_iPendingTeamNum"))


callbacks.Register"CreateMove", (usercmd) ->
    ApplyOnshots!
    "__REMOVE_ME__"

client.AllowListener"weapon_fire"
callbacks.Register "FireGameEvent", (event) ->
    if event\GetName() ~= "weapon_fire" then return

    index = client.GetPlayerIndexByUserID(event\GetInt("userid"))
    onshotable[index] = globals.CurTime() + 0.2

"__REMOVE_ME__"