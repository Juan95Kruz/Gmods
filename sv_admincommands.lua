concommand.Add("lst_admin_togglenoclip", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" then
	    if ply:GetMoveType() == MOVETYPE_WALK then
		    ply:SetMoveType( MOVETYPE_NOCLIP )
		    print("Noclip Enabled")
	    elseif ply:GetMoveType() == MOVETYPE_NOCLIP then
		    ply:SetMoveType( MOVETYPE_WALK )
		    print("Noclip Disabled")
		end
    end
end)

concommand.Add("lst_admin_togglegod", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" then
		if !ply:HasGodMode() then
	        ply:GodEnable()
	        print("Godmode Enabled")
	    elseif ply:HasGodMode() then
		    ply:GodDisable()
            print("Godmode Disabled")
		end
    end 
end)

concommand.Add("lst_admin_physgun", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" then
	    ply:Give("weapon_physgun")
	    print("Get your Physgun")
    end 
end)

concommand.Add("lst_admin_roundrestart", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" then
	if #player.GetAll() < MinPlayers() then
		print ("Need more players to start new round.")
	else RoundRestart()
	    PrintMessage(HUD_PRINTTALK, "Round has been restarted by Administrator")
	end
    end 
end)

concommand.Add("lst_admin_slayanyone", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" and GetState() == STATE_LIVE then
		for k,v in pairs( player.GetAll() ) do
			v:Kill()
		end
		PrintMessage(HUD_PRINTTALK, "All players has been slayed by Administrator")
	else print("Round aren't active")
    end 
end)


concommand.Add("lst_admin_maprestart", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" then
        PrintMessage(HUD_PRINTTALK, "MAP RESTART IN 30 SECONDS")
        PrintMessage(HUD_PRINTCENTER, "MAP RESTART IN 30 SECONDS")
    	timer.Create("restart_10_seconds_left", 20, 1, function()
    		PrintMessage(HUD_PRINTTALK, "MAP RESTART IN 10 SECONDS")
    		PrintMessage(HUD_PRINTCENTER, "MAP RESTART IN 10 SECONDS")
    	end)
	    timer.Create("restart_0_seconds_left", 30, 1, function()
	        RunConsoleCommand("changelevel", game.GetMap())
	    end)
    end 
end)

concommand.Add("lst_admin_godfix", function(ply, command, args)
	if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" then
		if canattack == false and GetState() == STATE_LIVE then
		    canattack = true
			print("Player damage now enabled.")
		    net.Start("LST_ActionStart")
		    net.Broadcast()
	        else print("Player damage are already enabled.")
	    end
	end
end)

concommand.Add("lst_admin_callnuke", function(ply, command, args)
    if (ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917") and GetState() == STATE_LIVE then
	    RunEvents(1)
	else print("Round aren't started yet.")
    end 
end)

concommand.Add("lst_admin_callairdrops", function(ply, command, args)
    if (ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917") and GetState() == STATE_LIVE then
	    RunEvents(2)
	else print("Round aren't started yet.")
    end 
end)

-- server convar toggler

concommand.Add("lst_servercvar_toggle_attachments", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" and GetState() == STATE_NONE or GetState() == STATE_PREP then
		if GetConVar("arccw_attinv_free"):GetInt() == 0 then
		    RunConsoleCommand("arccw_attinv_free", "1")
			print("Free Attachments disabled")
	elseif GetConVar("arccw_attinv_free"):GetInt() == 1 then 
		    RunConsoleCommand("arccw_attinv_free", "0")
			print("Free Attachments enabled")
	    end
	else print ("Round shouldn't be active or started.")
    end 
end)

concommand.Add("lst_servercvar_toggle_physbullets", function(ply, command, args)
    if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917" then
		if GetConVar("arccw_bullet_enable"):GetInt() == 0 then
		    RunConsoleCommand("arccw_bullet_enable", "1")
			print("Physical Bullets enabled")
	elseif GetConVar("arccw_bullet_enable"):GetInt() == 1 then 
		    RunConsoleCommand("arccw_bullet_enable", "0")
			print("Physical Bullets disabled")
	    end
    end 
end)
-- physgun calls

local function PlayerPickupPhys(ply, ent)
	if (ent:GetClass():lower() == "player") and (ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917") then ent:Lock()
		return true
	end
end
hook.Add("PhysgunPickup", "Pickup Player", function(ply, ent) 
    PlayerPickup(ply, ent) 
end)

local function PlayerDropPhys(ply, ent)
	if (ent:GetClass():lower() == "player") and (ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:77047618" or ply:SteamID() == "STEAM_0:1:98061917") then ent:UnLock()
		return true
	end
end
function PlayerDrop(ply, ent)
    if ent:IsPlayer() then
        ent:SetMoveType(MOVETYPE_WALK)
    end
end

hook.Add("PhysgunDrop", "Drop Player", PlayerDrop)