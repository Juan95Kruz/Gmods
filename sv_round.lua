
// server-side round system

include("config.lua")

TEAM_PLAYER = 1
TEAM_CONT = 2
TEAM_SPEC = 3

STATE_NONE = 1
STATE_PREPARING = 2
STATE_LIVE = 3
STATE_POST = 4

if GetGlobalInt("state") == 0 then
	SetGlobalInt( "state", STATE_NONE )
	SetGlobalInt( "round_num", -1 )
end

function GetRoundNum()
	return GetGlobalInt("round_num")
end

function SetRoundNum(num)
	return SetGlobalInt("round_num", num)
end

function GetState()
	return GetGlobalInt("state")
end

function SetState(num)
	SetGlobalInt("state", num)
end

function GetZoneSpeed()
	return GetConVar("lst_zonespeed"):GetFloat()
end

zoneisactive = false
canattack = false

-------------- ROUND SYSTEM --------------

function Round_Check()
	if #player.GetAll() < MinPlayers() then return end
	local usable = true
	if MAPCONFIG == nil then
		usable = false
	end
	if MAPCONFIG[game.GetMap()] == nil then
		usable = false
	end
	if MAPCONFIG[game.GetMap()]["spawns"] == nil then
		usable = false
	end
	if MAPCONFIG[game.GetMap()]["weaponspawns"] == nil then
		usable = false
	end
	if MAPCONFIG[game.GetMap()]["endpositions"] == nil then
		usable = false
	end
	if usable == false then
		Error("This map is not compatible with this gamemode or config file is broken.")
		return false
	end
	if usable then return true end
end
 
function GM:Tick()
	if GetState() == STATE_NONE then
		if #team.GetPlayers(TEAM_PLAYER) >= MinPlayers() then
			print("rround2")
			if #team.GetPlayers(TEAM_PLAYER) >= math.floor(#player.GetAll() / 3) then
				RoundRestart()
			end
		end
	end
	if GetState() == STATE_LIVE then
		if zoneisactive then
			if GetGlobalInt("Zone_Radius") < 2000 then
				if startednuclearsiren == false then
					startednuclearsiren = true
					BroadcastLua('surface.PlaySound("gbombs_5/sirens/nuclear_siren.wav")')
				end
			end
			if GetGlobalInt("Zone_Radius") > 0 then
				SetGlobalInt( "Zone_Radius", GetGlobalInt("Zone_Radius") - GetZoneSpeed() )
			elseif GetConVar("lst_enableimplosion"):GetInt() == 1 then
				zoneisactive = false
				implosionbomb = ents.Create( "hb_nuclear_fatman" )
				if IsValid(implosionbomb) then
					implosionbomb:SetPos( GetGlobalVector("Zone_Pos") )
					implosionbomb:Spawn()
		            implosionbomb:Arm()
				end
				BroadcastLua('RunConsoleCommand("stopsound")')
			end
		end
	end
end

function RunEvents(num)
	if num == 1 then
		PrintMessage(HUD_PRINTTALK, "Nuclear airstrike inbound!")
		PrintMessage(HUD_PRINTCENTER, "Nuclear airstrike inbound!")
		local nuke = ents.Create( "hb_nuclear_fatman" )
		local pos = table.Random(MAPCONFIG[game.GetMap()]["events"]["nukepositions"])
		nuke:SetPos( pos )
		nuke:Spawn()
		nuke:Arm()
	elseif num == 2 then
		local airdropcount = math.random(1,4)
		local allspawns = {}
		table.Add(allspawns, MAPCONFIG[game.GetMap()]["events"]["supplydrops"])
		for i=1, airdropcount do
			table.RemoveByValue(allspawns, table.Random(allspawns))
		end
		PrintMessage(HUD_PRINTTALK, tostring(#allspawns) .. " supply airdrops incoming.")
		PrintMessage(HUD_PRINTCENTER, tostring(#allspawns) .. " supply airdrops incoming!")
		for k,v in pairs(allspawns) do
			local supplydrop = ents.Create( "ent_supplydrop_fix" )
			supplydrop:SetPos( v )
			supplydrop:Spawn()
		end
	end
end

function RoundRestart()
	if ConVarExists("lst_maxrounds") then
		print("Rounds: " .. GetRoundNum() .. "/" .. GetConVar("lst_maxrounds"):GetInt())
		if GetRoundNum() >= GetConVar("lst_maxrounds"):GetInt() then
			hook.Run("MapChange")
		elseif GetConVar("lst_maxrounds"):GetInt() - 1 == GetRoundNum() then
			PrintMessage(HUD_PRINTTALK, "Map will change after this round.")
		end
	end
	SetRoundNum(GetRoundNum() + 1)
	UpdateAllTeamers()
	RegenerateSpawns()
	timer.Destroy("timer_prearing")
	timer.Destroy("timer_attackdelay")
	timer.Destroy("timer_event1")
	timer.Destroy("timer_event2")
	timer.Destroy("timer_event3")
	timer.Destroy("timer_event4")
	canattack = false
	SetState(STATE_PREPARING)
	PrintMessage(HUD_PRINTTALK, "Game is starting in " .. PrepTime() .. " seconds")
	PrintMessage(HUD_PRINTCENTER, "Game is starting in " .. PrepTime() .. " seconds")
	net.Start("LST_PrepStart")
	net.Broadcast()
	timer.Create("timer_prearing", PrepTime(), 1, function()
		for k,pl in pairs(player.GetAll()) do
			for k2,pl2 in pairs(pl.wantstoleave) do
				for k3,pl_teamer_64 in pairs(pl.TeamingPlayers) do
					if pl_teamer_64 == pl2:SteamID64() then
						for k4,v in pairs(pl.TeamingPlayers) do
							if v != pl2:SteamID64() then
								local plyr = player.GetBySteamID64( v )
								if plyr != false then
									print("removing " .. plyr:Nick() .. " from " .. pl2:Nick() .. "'s mates")
									table.RemoveByValue(pl2.TeamingPlayers, plyr:SteamID64())
									plyr:PrintMessage(HUD_PRINTTALK, pl2:Nick() .. " is no longer in your team")
									print("removing " .. pl2:Nick() .. " from " .. plyr:Nick() .. "'s mates")
									table.RemoveByValue(plyr.TeamingPlayers, pl2:SteamID64())
									plyr:UpdateTeamers()
								end
							end
						end
						
						print("removing " .. pl2:Nick() .. " from " .. pl:Nick() .. "'s mates")
						table.RemoveByValue(pl.TeamingPlayers, pl2:SteamID64())
						pl:PrintMessage(HUD_PRINTTALK, pl2:Nick() .. " is no longer in your team")
						pl:UpdateTeamers()
						print("removing " .. pl:Nick() .. " from " .. pl2:Nick() .. "'s mates")
						table.RemoveByValue(pl2.TeamingPlayers, pl:SteamID64())
						pl2:UpdateTeamers()
						pl.wantstoleave = {}
						
					end
				end
			end
		end
		local cnt = player.GetAll()
		if #cnt == 4 then
			if IsInTeam3(cnt[1], cnt[2], cnt[3], cnt[4]) then
				PrintMessage(HUD_PRINTTALK, "You cannot start the game when all players are in a team")
				SetState(STATE_NONE)
				return
			end
		end
		if #cnt == 3 then
			if IsInTeam3(cnt[1], cnt[2], cnt[3]) then
				PrintMessage(HUD_PRINTTALK, "You cannot start the game when all players are in a team")
				SetState(STATE_NONE)
				return
			end
		end
		if #cnt == 2 then
			if IsInTeam(cnt[1], cnt[2]) then
				PrintMessage(HUD_PRINTTALK, "You cannot start the game when all players are in a team")
				SetState(STATE_NONE)
				return
			end
		end

		game.CleanUpMap()
		if GetConVar("arccw_attinv_free"):GetInt() == 0 then
			timer.Simple(1, function()
				RunConsoleCommand("arccw_attinv_free", "1")
				RunConsoleCommand("arccw_attinv_free", "0")
			end)
		elseif GetConVar("arccw_attinv_free"):GetInt() == 1 then
			timer.Simple(1, function()
				RunConsoleCommand("arccw_attinv_free", "0")
				RunConsoleCommand("arccw_attinv_free", "1")
			end)
		end -- this shit should be called every round to properly disable or enable player modules, thanks ArcCW

			if ( string.find( string.lower( game.GetMap() ), "gm_boreas" ) ) then -- cleaning shit on map
				timer.Create("RemoveProps", 5, 1, function()
					for k, v in pairs(ents.FindByClass("weapon_ar2")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("weapon_smg1")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("weapon_pistol")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("weapon_shotgun")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("weapon_grenade")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_ammo_crate")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_battery")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_item_crate")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_healthkit")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_ammo_357")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_ammo_ar2")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_ammo_pistol")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_ammo_smg1")) do v:Remove() end
					for k, v in pairs(ents.FindByClass("item_box_buckshot")) do v:Remove() end
				end) end
				if ( string.find( string.lower( game.GetMap() ), "gm_boreas" ) ) then -- freezing all props on map to prevent nuke crash
					timer.Create("FreezeProps", 1, 1, function()
				        local Ent = ents.FindByClass("prop_physics")
                        for _,Ent in pairs(Ent) do
                            if Ent:IsValid() and !Ent:IsVehicle() then
                                local phys = Ent:GetPhysicsObject()
                                phys:EnableMotion(false)
                            end
                        end
					end) 
				end
		PrintMessage(HUD_PRINTTALK, "Game is live! Grace period will end after after " .. ActionPrepTime() .. " seconds.")
		PrintMessage(HUD_PRINTCENTER, "Game is live!")
		canattack = false
		timer.Create("timer_attackdelay", ActionPrepTime(), 1, function()
			canattack = true
			PrintMessage(HUD_PRINTTALK, "Action phase is live! Players are able to fight now.")
			PrintMessage(HUD_PRINTCENTER, "Action phase is live!")
			net.Start("LST_ActionStart")
			net.Broadcast()
		end)
		timer.Create("timer_event1", 240, 1, function()
			PrintMessage(HUD_PRINTTALK, "Random event starts in one minute")
			PrintMessage(HUD_PRINTCENTER, "Random event starts in one minute")
			timer.Create("timer_event2", 60, 1, function()
				if GetConVar("lst_event_enablenuke"):GetInt() == 1 then
					if math.random(1,3) == 1 then
						RunEvents(1)
					else
						RunEvents(2)
					end
				else
					RunEvents(2)
				end
			end)
		end)
		timer.Create("timer_event3", 540, 1, function()
			PrintMessage(HUD_PRINTTALK, "Random event starts in one minute")
			PrintMessage(HUD_PRINTCENTER, "Random event starts in one minute")
			timer.Create("timer_event4", 60, 1, function()
				if GetConVar("lst_event_enablenuke"):GetInt() == 1 then
					if math.random(1,3) == 1 then
						RunEvents(1)
					else
						RunEvents(2)
					end
				else
					RunEvents(2)
				end
			end)
		end)
		startednuclearsiren = false
		SetupZone()
		SetState(STATE_LIVE)
		zoneisactive = true
		timer.Create("FasterStartingMapSpeed", 2, 1, function() -- adding delays to increase map rounds loading speed
		NewSpawnAllItems()
		if GetConVar("arccw_attinv_free"):GetInt() == 0 then
		SpawnArcCWAttachz()
		elseif GetConVar("arccw_attinv_free"):GetInt() == 1 then end
		end)
		if not ( string.find( string.lower( game.GetMap() ), "gm_marsh" ) ) then
		timer.Create("SpawnVehicles", 6, 1, function() -- car delay to not freeze them with props
		SpawnAllVehicles()
		SpawnAllVehicles2()
		SpawnAllFlyingVehicles()
		SpawnAllBlindados()

		end)
	    end
		local allspawns = {}
		table.Add(allspawns, MAPCONFIG[game.GetMap()]["playerspawns"])
		
		for k,pl in pairs(player.GetAll()) do
			pl.roundkills = 0
			local spawn = table.Random(allspawns)
			pl:Spawn()
			pl:SetActivePlayer()
			if spawn == nil then spawn = table.Random(allspawns) print("bad spawn:" .. spawn) end
			pl:SetPos(spawn)
			table.RemoveByValue(allspawns, spawn)
		end
		net.Start("LST_RoundStart")
		net.Broadcast()
	end)
end
function GetRandomLoadout(loadoutCategory)
    if not loadoutCategory or not istable(loadoutCategory) then
        return nil
    end

    return table.Random(loadoutCategory)
end
////////////// ROUND SYSTEM //////////////

function SetupZone()
	local pos = table.Random( MAPCONFIG[game.GetMap()]["endpositions"] )
	SetGlobalVector( "Zone_Pos", pos )
	SetGlobalInt( "Zone_Radius", MAPCONFIG[game.GetMap()]["zone_radius"] )
	
	zone = ents.Create( "ent_zone" )
	if IsValid(zone) then
		zone:SetPos( pos )
		zone:Spawn()
	end
	net.Start("LST_ZoneSetup")
	net.Broadcast()
end

function IsInZone(ply)
	local radius = GetGlobalInt( "Zone_Radius")
	if radius < 1 then
		return false
	end
	local allents = ents.FindInSphere( GetGlobalInt( "Zone_Pos"), radius )
	for k,v in pairs(allents) do
		if v == ply then
			return true
		end
	end
	return false
end

function HurtPlayers()
	local dmgrad = GetGlobalInt( "Zone_Radius")
	if GetState() != STATE_LIVE then return end
	for k,v in pairs( player.GetAll() ) do
		if IsInZone(v) == false then
			if dmgrad < 3500 and IsInZone(v) == false then
			    v:TakeDamage( math.random(9,18), v, v )
			    else v:TakeDamage( math.random(3,9), v, v )
			end
		elseif GetConVar("lst_healhealth"):GetInt() == 1 then
			if v:Health() < 30 then
				v:SetHealth(v:Health() + 1)
			end
		end
	end
end

timer.Create("HurtAllPlayers", 5, 0, HurtPlayers)

function SpawnAllVehicles() -- SimfPhys is best option.
	for k,v in pairs(MAPCONFIG[game.GetMap()]["vehiclepositions"]) do
		simfphys.SpawnVehicleSimple( table.Random(VEHICLES), v, Angle(0,0,0) )
	end
end
function SpawnAllVehicles2() -- SimfPhys is best option.
	for k,v in pairs(MAPCONFIG[game.GetMap()]["vehicle2positions"]) do
		simfphys.SpawnVehicleSimple( table.Random(VEHICLES2), v, Angle(0,0,0) )
	end
end

function GetItemsToSpawn(n1,n2,n3,n5)
	local tabl = {}
	for i=1, n1 do
		table.ForceInsert(tabl, table.Random(ITEMS["BETTERWEAPONS"]))
	end
	for i=1, n2 do
		table.ForceInsert(tabl, table.Random(ITEMS["WEAPONS"]))
	end
	for i=1, n3 do
		table.ForceInsert(tabl, table.Random(ITEMS["ADDITIONALWEAPONS"]))
	end
	for i=1, n5 do
		table.ForceInsert(tabl, table.Random(ITEMS["AMMO"]))
	end
	return tabl
end

function NewSpawnAllItems()
	local pmult = 1 -- this thing did NOT work correctly, holy shit like it would make every single spawn become BETTERWEAPONS
	local itemstospawn = {}
	local spawns = {}
	table.Add(spawns, MAPCONFIG[game.GetMap()]["weaponspawns"])
	local pls = #player.GetAll()
	itemstospawn = GetItemsToSpawn(MAPCONFIG[game.GetMap()]["weaponsc"][1]*pmult,MAPCONFIG[game.GetMap()]["weaponsc"][2]*pmult,MAPCONFIG[game.GetMap()]["weaponsc"][3]*pmult,MAPCONFIG[game.GetMap()]["weaponsc"][5]*pmult)
	for k,v in pairs(itemstospawn) do
		local it = ents.Create( v )
		if IsValid( it ) then
			local pos = table.Random(spawns)
			if pos == nil then pos = table.Random(spawns) print(pos) print(v) return end
			it:SetPos( pos )
			table.RemoveByValue(spawns, pos)
			it:Spawn()
			it.kanadelootable = true
		end
	end
end

function SpawnAllFlyingVehicles()
    for k, v in pairs(MAPCONFIG[game.GetMap()]["flying_vehiclespawns"]) do
        local spawn = v
        local vehicle = nil

        if math.random(1, 100) <= 50 then
            local selectedLoadout = GetRandomLoadout(FLYING_VEHICLES["VERYRARE"])
            vehicle = ents.Create(selectedLoadout)
        else
            local selectedLoadout = GetRandomLoadout(FLYING_VEHICLES["RARE"])
            vehicle = ents.Create(selectedLoadout)
        end

        if IsValid(vehicle) then
            vehicle:SetPos(spawn)
            vehicle:Spawn()
        end
    end
end

function SpawnAllBlindados()
    for k, v in pairs(MAPCONFIG[game.GetMap()]["blindados"]) do
        local spawn = v
        local vehicle = nil
        local chance = math.random(1, 100)

        if chance <= 70 then
            local selectedLoadout = GetRandomLoadout(BLINDADOS["COMUN"])
            vehicle = ents.Create(selectedLoadout)
        elseif chance <= 90 then
            local selectedLoadout = GetRandomLoadout(BLINDADOS["RARE"])
            vehicle = ents.Create(selectedLoadout)
        else
            local selectedLoadout = GetRandomLoadout(BLINDADOS["VERYRARE"])
            vehicle = ents.Create(selectedLoadout)
        end

        if IsValid(vehicle) then
            vehicle:SetPos(spawn)
            vehicle:Spawn()
        end
    end
end

-------------- ATTACHMENT SPAWN RANDOMIZER --------------

function SpawnArcCWAttachz()
	for k,v in pairs(MAPCONFIG[game.GetMap()]["attachzspawns"]) do
		for i=1,4 do
			if math.random(1,100) <= 25 then -- 25% on each module, one should be guarranted
				local spawn = v
				local attach = ents.Create( table.Random(ARCCW_ATTACHZ["ATTACHZ_BRUH"]) ) -- rolled
				if IsValid( attach ) then
					attach:SetPos( spawn )
					attach:Spawn()
				end
			end
		end
	end
end

function GM:PlayerCanHearPlayersVoice( listener, talker )
	if talker:Team() == TEAM_SPEC and listener:Team() == TEAM_CONT then
		return false
	end
	return true
end

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )
	if listener == speaker then return true end
	if speaker:Team() == TEAM_SPEC and listener:Team() == TEAM_CONT then
		return false
	end
	if teamOnly then
		if IsInTeam(listener, speaker) then
			return true
		else
			return false
		end
	end
	return true
end
