
# Playerlist

This is inspired by [PlayerList by Zerdos](https://github.com/zer420/Player-List), the goal of this project is to make playerlist with a public api for expanding the lua.

This project is written in [Moonscript](https://moonscript.org), a language which compiles to lua.

## API

This lua adds a public api available under `plist`, which can be used to make extensions.

> **NOTE:** Documentation can be found in the [Github Wiki](https://github.com/Le0Developer/playerlist/wiki#api).

### Example Extension

```lua
local killsay_ref = plist.gui.Checkbox("killsay", "Say a message when they die", false)

client.AllowListener("player_hurt")
callbacks.Register("FireGameEvent", function(Event)
  if Event:GetName() == "player_hurt" and Event:GetInt( "health" ) <= 0 then -- someone died
    local lp = entities.GetLocalPlayer()
    local lp_uid = client.GetPlayerInfo( lp:GetIndex() )[ "UserID" ]
    local victim_uid = Event:GetInt( "userid" )
    local attacker_uid = Event:GetInt( "attacker" )

    if lp_uid == attacker_uid and lp_uid ~= victim_uid then -- i killed someone and it's not myself
      local settings = plist.GetByUserID( victim_uid ) -- get plist info
      if settings.get( "killsay" ) then -- "killsay" is the varname
        client.ChatSay( "RIP." )
      end
    end

  end
end)

callbacks.Register("Unload", function()
  plist.gui.Remove( killsay_ref ) -- delete the checkbox after unloading
end)
```

## Credits

This program includes source from:
  - [PlayerList](https://aimware.net/forum/thread/136420) by [Zerdos](https://aimware.net/forum/user/119901) [GITHUB](https://github.com/zer420/Player-List) Affected code: Prioritizing players and chams code.
  - [Per Player ESP](https://aimware.net/forum/thread/109067) by [Cheeseot](https://aimware.net/forum/user/215088) Affected code: ESP Box
  - [Engine Radar](https://aimware.net/forum/thread/88645) by [Luiz](https://aimware.net/forum/user/70416) Affected code: Reveal on Radar

I'm also thanking:
  - The amazing people from the unofficial AIMWARE discord server.
