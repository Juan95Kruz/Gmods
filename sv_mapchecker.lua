timer.Create("checking_map", 5, 1, function()
	if not (game.GetMap() == "gm_valley" or game.GetMap() == "gm_marsh" or game.GetMap() == "gm_boreas" or game.GetMap() == "gm_fork" or game.GetMap() == "rp_ineu_pass_v1e" or game.GetMap() == "gm_construct" or game.GetMap() == "gm_balkans" or game.GetMap() == "gm_balkans_snow" or game.GetMap() == "rp_deadcity" or game.GetMap() == "rp_fork_stasiland" or game.GetMap() == "rp_fork_stasiland_fog" or game.GetMap() == "gm_blackmesa_sigma" or game.GetMap() == "rp_ineu_valley2_v1a" or game.GetMap() == "rp_clazfort" or game.GetMap() == "malvinas_dattatec" or game.GetMap() == "gm_southern_mist") then -- if you add a new map to config.lua you have to add a line here for the map otherwise it will automatically switch off the current map
		PrintMessage(HUD_PRINTTALK, "Someone changed server on unsupported map, fixing...")
		PrintMessage(HUD_PRINTTALK, "Map is changing on 'rp_fork_stasiland' in 30 seconds.")
		PrintMessage(HUD_PRINTCENTER, "Map is changing on 'rp_fork_stasiland' in 30 seconds.")
		timer.Create("restart_10_seconds_left", 20, 1, function()
			PrintMessage(HUD_PRINTTALK, "Map is changing on 'rp_fork_stasiland' in 10 seconds.")
			PrintMessage(HUD_PRINTCENTER, "Map is changing on 'rp_fork_stasiland' in 10 seconds.")
		end)
		timer.Create("restart_0_seconds_left", 30, 1, function()
			RunConsoleCommand("changelevel", "rp_fork_stasiland")
		end)
	end
end)