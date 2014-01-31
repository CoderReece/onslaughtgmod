//Ailia, Conman, Scooby, Xera
// and now matt

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_hud.lua")
AddCSLuaFile( "ose.lua" )
AddCSLuaFile( "sh_shop.lua" )
AddCSLuaFile( "cl_shop.lua" )
AddCSLuaFile( "sh_config.lua" )
AddCSLuaFile( "sh_util.lua" )
Pmeta = FindMetaTable( "Player" )
Emeta = FindMetaTable( "Entity" )

include( "shared.lua" )
include( "metafunctions.lua" )
include( "prop_save.lua" )
include( "shared.lua" )
include( "cl_panels.lua" )
include( "commands.lua" )
include( "sh_shop.lua" )
include( "sv_shop.lua" )
include( "sh_config.lua" )
include( "extbuild.lua" )
include( "sh_util.lua" )

for k,v in pairs( file.Find( "materials/onslaught/*","GAME" ) ) do
	resource.AddFile( "materials/onslaught/" .. v )
end


NextRound = GM.Config.BUILDTIME + CurTime( )
TimeLeft = NextRound - CurTime( )
local discplayers = {}
ROUND_ID = 0
NPC_COUNT = 0

function GM:PlayerInitialSpawn(ply)
	ply.LastKill = 0
	ply.Buddies = {} --I'll get round to this I swear
	ply:SetNWInt("prop","models/props_lab/blastdoor001c.mdl")
	AllChat(ply:Nick().." has finished joining the server!")
	ply.Class = 1
	ply.Hooks = {}

	ply:GetDefaultClass()
	timer.Simple(2,function() ply:LoadSQLStuff() UpdateTime(ply)  end)
	
	if discplayers[ply:SteamID()] != nil then
		ply:SetNWInt("money", discplayers[ply:SteamID()].MONEY )
		ply.NextSpawn = discplayers[ply:SteamID()].NEXTSPAWN
		ply.Died = discplayers[ply:SteamID()].DIED
		ply:SetHealth(discplayers[ply:SteamID()].HEALTH)
		local oldobj = discplayers[ply:SteamID()].OBJECT
		for k,v in pairs(ents.GetAll()) do
			if v.Owner == oldobj then
				v.Owner = ply
				v:SetNWEntity("Owner", ply)
			end
			if v:GetOwner() == oldobj then
				v:SetOwner(ply)
				v:SetNWEntity("Owner", ply)
			end
		end
		discplayers[ply:SteamID()] = nil
	else
		ply.Died = 0
		ply:SetNetworkedInt( "money", GAMEMODE.Config.STARTING_MONEY )
	end
	if PHASE == "BATTLE" then
		if !ply.NextSpawn then
			ply.NextSpawn = CurTime() + 5
		end
		timer.Simple(0.01, function() ply:KillSilent() end)
	end
end


function Pmeta:LoadSQLStuff()
	local result = "SELECT steam_id, kills, rank, points FROM ose_player_info WHERE steam_id = '"..self:SteamID().."'"
	local query  = sql.Query(result)
	local kills
	local rank
	if query then
		kills = tonumber(query[1].kills)
		rank = tonumber(query[1].rank)
		points = tonumber(query[1].points)
		self:SetNWInt("kills",kills)
		self:SetNWInt("rank",rank)
		self:SetNWInt("points",points)
		self:SetTeam(rank+1)
	else
		sql.Query("INSERT INTO ose_player_info VALUES( '"..self:SteamID().."', 0 , 1, 0 );")
		query = sql.Query(result)
		if not query then
			print("Error on line 45! *********** "..sql.LastError(result).." ***************")
			return
		end
		self:SetNWInt("kills",0)
		self:SetNWInt("rank",1)
		self:SetNWInt("points",0)
		self:SetTeam(2)
	end
	result = "SELECT items,sct,sld,eng,snp,pyr,sup FROM ose_player_items WHERE steam_id = '"..self:SteamID().."'"
	query = sql.Query(result)

	self.Items = table.Copy(defItems)
	self.EItems = table.Copy(defEItems)

	if query then
		if query[1].items and not (query[1].items == "") then
			local items = string.Explode("/",query[1].items)
			for k = 1,#items do
				local v = string.Explode(":",items[k])
				for c,d in ipairs(v) do
					v[c] = tonumber(d)
				end
				table.insert(self.Items,v)
			end
		end
		for k,v in pairs(query[1]) do
			if v != "" and k!="items" then
				//self.EItems[k] = {}
				local items = string.Explode("/",v)
				for i = 1,#items do
					local c = string.Explode(":",items[i])
					self.EItems[k][i] = {}
					self.EItems[k][i][1] = tonumber(c[1])
					self.EItems[k][i][2] = tonumber(c[2])
				end
			end
 		end
	else
		self:SaveItems()
		self:SaveEItems()
		result = "SELECT * FROM ose_player_items WHERE steam_id = '"..self:SteamID().."'"
		query = sql.Query(result)
		if not query then
			//print("Error on line 192! *********** "..sql.LastError(result).." ***************")
			//return
		end
	end

	self:UpdateItems()
	self:UpdateEItems()
end


function GM:PlayerCanPickupWeapon(ply, wep)
	if PHASE == "BUILD" then
		return true
	end
	for k,v in pairs(ply.EItems[convCTable[ply.Class]])do
		if v[1] > 14 then
			if NEW_WEAPONS[v[1]] then
				if NEW_WEAPONS[v[1]].WC == wep:GetClass() then 
					return true
				end
			end
		else
			if HL2_WEPS[v[1]] then
				if HL2_WEPS[v[1]].WC == wep:GetClass() then
					return true
				end
			end
		end
	end

	return false
end

function GM:PlayerSpawn(ply)
	ply:ShouldDropWeapon(false)
	ply:UnSpectate()
	ply:SetTeam(ply:GetNWInt("rank") + 1)
	ply:RemoveAllAmmo()
	GAMEMODE:PlayerLoadout(ply)

	if PHASE == "BUILD" then
		GAMEMODE:SetPlayerSpeed(ply, 350, 500)
		ply:SetMaxHealth(100)
		ply:SetHealth(100)
	else
		GAMEMODE:SetPlayerSpeed(ply, CLASSES[ply.Class].SPEED, CLASSES[ply.Class].SPEED)
		GAMEMODE:RestockPlayer(ply)
		ply:SetMaxHealth(CLASSES[ply.Class].HEALTH)
		ply:SetHealth(CLASSES[ply.Class].HEALTH)
		ply:SetJumpPower(CLASSES[ply.Class].JUMP)
	end
	ply:SetModel(CLASSES[ply.Class].MODEL )
	if IsValid(ply.CusSpawn) then
		ply:SetPos(ply.CusSpawn:GetPos())
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		timer.Simple(2, function() ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) end)
	end
end

function GM:PlayerLoadout(ply)
	if PHASE == "BATTLE" then
		local wep = {}
		for k,v in pairs(ply.EItems[convCTable[ply.Class]])do
			if v[1] >= 15 then
				if NEW_WEAPONS[v[1]] then
					if NEW_WEAPONS[v[1]].WC then 
						ply:Give(NEW_WEAPONS[v[1]].WC)
					end
				end
			else
				if HL2_WEPS[v[1]] then
					if HL2_WEPS[v[1]].WC then
						ply:Give(HL2_WEPS[v[1]].WC)
					end
				end
			end
		end
	elseif PHASE == "BUILD" then
		ply:Give("weapon_physgun")
		ply:Give("swep_repair")
		ply:Give("swep_propspawner")
	end
end

function GM:RestockPlayer(ply)
	if !ply then return end
	local nw = {}
	local wep = {}
	if not ply.EItems or ply.EItems == {} or ply.EItems[1] == {} then timer.Simple(0.5,function() self:RestockPlayer(ply) end) return end //Infinite Loop?
	local wep
	local ammo
	for k,v in pairs(ply.EItems[convCTable[ply.Class]])do
		//if v[1] > 14 then
			if NEW_WEAPONS[v[1]] then
				if NEW_WEAPONS[v[1]].AD then
					wep = NEW_WEAPONS[v[1]]
					for x,s in pairs(wep.AD or {})do
						ammo = s
						ply:GiveAmmo(AMMOS[ammo].QT*(AMMOS[ammo].SMULT or 1),AMMOS[ammo].AMMO)
					end
				end
			end
		//else
			if HL2_WEPS[v[1]] then
				if HL2_WEPS[v[1]].AD then
					wep = HL2_WEPS[v[1]]
					for x,s in pairs(wep.AD or {})do
						ammo = s
						ply:GiveAmmo(AMMOS[ammo].QT*(AMMOS[ammo].SMULT or 1),AMMOS[ammo].AMMO)
					end
				end
			end
		//end
	end
end

function GM:StartBattle()
	print("[ONSLAUGHT] Battle phase started!")
	NextRound = CurTime() + GAMEMODE.Config.BATTLETIME
	UpdateTime()
	PHASE = "BATTLE"

	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(150,0,0,255),"[OSE] The onslaught has begun! NPCs take ",Color(0,0,200),"]].. math.Round(100/DMGMOD)..[[% damage.")]])
	end

	
	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsWeapon( ) then
			v:Remove( )
		elseif v:IsNPC() || v:GetClass() == "ose_mines" then
			v:CheckValidOwnership()
		elseif v.Prepare then
			timer.Simple(k*0.05,function() v:Prepare() end)
		elseif v:IsPlayer() then
			v.Voted = false
			v.NextSpawn = (CurTime() + 3) + math.Rand(0.5,1.5)
			v:KillSilent()
			v.FullRound = true
		end
	end

	umsg.Start("StartBattle")
	umsg.End()
	for k,v in pairs(ents.FindByName("ose_battle")) do
		v:Fire("trigger",0,3)
	end
end

function GM:CalculateLiveBonus()
	if TimeLeft > 1 then
		for k,v in pairs(player.GetAll()) do
			local bonus = math.Round((GAMEMODE.Config.LIVE_BONUS + (GAMEMODE.Config.DEATH_PENALTY * v.Died))/2)
			if bonus > 0 && v.FullRound == true then
				v:Money(bonus,"+"..bonus.." [Round End Bonus]")
			end
			v.Died = 0
		end
	else
		for k,v in pairs(player.GetAll()) do
			local bonus = GAMEMODE.Config.LIVE_BONUS + (GAMEMODE.Config.DEATH_PENALTY * v.Died)
			if bonus > 0 && v.FullRound == true then
				if v.GivePoints then
					v:GivePoints(5-(v.Died*2)," for completing the round!")
				end
				v:Money(bonus,"+"..bonus.." [Round Live Bonus]")
				v:SetNWInt("kills", v:GetNWInt("kills") + math.Round(bonus / 100))
			end
			v.Died = 0
		end
	end
end

function GM:StartBuild()
	if PHASE != "BUILD" then
		print("[ONSLAUGHT] Build phase started!")
		if TimeLeft > 1 then
			for k,v in pairs(ents.FindByName("ose_lose")) do
				if IsValid(v) then
					v:Fire("trigger")
				end
			end
			ROUND_ID = ROUND_ID - 0.5
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[chat.AddText(Color(150,0,0,255),"[OSE] Removed 1 minute from battle and decreased difficulty!")]])
			end
		else
			ROUND_ID = ROUND_ID + 1
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[chat.AddText(Color(150,0,0,255),"[OSE] Added 1 minute to battle and increased difficulty!")]])
			end
			for k,v in pairs(ents.FindByName("ose_win")) do
				if IsValid(v) then
					v:Fire("trigger")
				end
			end
		end
		GAMEMODE:SaveAllProfiles()
		GAMEMODE:CalculateLiveBonus()
		PHASE = "BUILD"
	end

	NPC_COUNT = 0

	NextRound = CurTime() + GAMEMODE.Config.BUILDTIME
	UpdateTime()
	voted = 0

	if ROUND_ID < 0 then ROUND_ID = 0 end
	for k,v in pairs(ents.FindByClass("snpc_*")) do v:Remove() end
	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsWeapon( ) or v:GetClass() == "class C_ClientRagdoll" then
			v:Remove( )
		elseif v:IsNPC() || v:IsProp() then
			v:CheckValidOwnership(true)
		elseif v.PropReset then
			v:PropReset()
		elseif v:IsPlayer() then
			v.NextSpawn = CurTime() + 5
			v:KillSilent()
		end
	end
	for k,v in pairs(ents.FindByName("ose_build")) do
		if IsValid(v) then
			v:Fire("trigger",0,5)
		end
	end
	umsg.Start("StartBuild")
	umsg.End()
end

DMGMOD = 1
LDMGMOD = CurTime() //next check for 
function DamageMod()												-- ROUND_ID is a difficulty increaser. A win adds 1, a loss subtracts .5
	if CurTime() > LDMGMOD + 5 then									-- DMGMOD = 4 (4 players + ROUND_ID (0) = 4)
		DMGMOD = math.sqrt(#player.GetAll())+math.sqrt(ROUND_ID) 	-- 100 / DMGMOD
	end																-- 25% DMG to NPCs.
	return DMGMOD													-- And even then, ZOMBIEMODE_ENABLED is always on, so divide that by 2.
end																	

function GM:ScaleNPCDamage(npc,hit,dmg)
	if npc:GetClass() == "npc_turret_floor" || npc:GetClass() == "npc_turret_ceiling" then return end

	local wep
	if dmg:GetInflictor():IsPlayer() then
		wep = dmg:GetInflictor():GetActiveWeapon():GetClass()
	else
		wep = dmg:GetInflictor():GetClass()
	end

	//if DMGO[wep] then dmg:SetDamage(DMGO[wep]) end //Since all weapons are now SWEPs this is invalid.

	if hit == 1 then
		dmg:ScaleDamage(2)
	end

	if ZOMBIEMODE_ENABLED then
		dmg:ScaleDamage(.5)
	end

	dmg:ScaleDamage(1 / DamageMod())
	return dmg
end

function GM:Initialize()
	self:InitSQLDatabase()

	
	self.SaveProps = { }
	GAMEMODE:StartBuild()

	if game.SinglePlayer() then
		GAMEMODE.Config.PROP_LIMIT = 10000
		GAMEMODE.Config.MAX_NPCS = GAMEMODE.Config.S_MAX_NPCS -- If it isnt a server raise the NPC limit since you shouldn't have to worry about lag :)
	end
end

function GM:InitSQLDatabase()
	local query = sql.TableExists("ose_player_info")
	if not query then
		local result = "CREATE TABLE ose_player_info ( steam_id varchar(255), kills INTEGER, rank INTEGER, points INTEGER, PRIMARY KEY(steam_id) )"
		query = sql.Query(result)
		if not sql.TableExists("ose_player_info") then
			print("Error on line 57! *******"..sql.LastError(result).."*******")
		end
	end
	query = sql.TableExists("ose_player_items")
	if not query then
		local result = "CREATE TABLE ose_player_items (steam_id varchar(255), items string,sct string,sld string,eng string,snp string,pyr string,sup string, PRIMARY KEY(steam_id) )"
		query = sql.Query(result)
		if not sql.TableExists("ose_player_items") then
			print("Error on line 65! *******"..sql.LastError(result).."********")
		end
	end
end

function GM:CheckRanks(ply,join)
	local kills = ply:GetNWInt("kills")
	local rank = ply:GetNWInt("rank")
	local newrank = rank
	for k,v in pairs(RANKS) do
		if kills >= v.KILLS then
			newrank = k
		end
	end
	if newrank > rank then
		ply:SetNWInt("rank", newrank)
		ply:SetTeam(newrank+1)
		if !join then
			ply:AddPoints(newrank*10)
			ply:SendLua([[chat.AddText(Color(150,0,0,255),"[OSE] You are now a ]]..RANKS[ply:GetNWInt("rank")].NAME..[[!")]])
			ply:SaveProfile()
		end
	end
end

function GM:PlayerDeath( ply, wep, killer )
	ply:SetTeam(1)
	ply:SendLua([[RunConsoleCommand("stopsound")]])
	ply:Spectate(OBS_MODE_DEATHCAM)
	ply.specid = 1
	ply.Specatemode = OBS_MODE_CHASE
	local name = npcs[killer:GetClass()] or killer:GetClass()
	if ply.Poisoned == true then name = "Poisoned Zombie" end
	if ply != killer then
		for k,v in pairs(player.GetAll()) do
			v:Message(ply:Nick().." was killed by a " .. name, Color(255,100,100,255), true)
		end
	end
		
	ply:SetNWBool("pois", false) -- prevent being poisened on death
	ply.Poisoned = false

	if self.AmmoBin then self.AmmoBin:Close() self.AmmoBin = nil end

	if PHASE == "BUILD" then
		ply.NextSpawn = CurTime() + 5
	else
		ply.NextSpawn = CurTime() + GAMEMODE.Config.SPAWN_TIME + (#player.GetAll() * GAMEMODE.Config.ADD_SPAWN_TIME)
		for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
			if v:GetRealOwner() == ply then v:PropRemove() end
		end
		for k,v in pairs(ents.FindByClass("npc_turret_ceiling")) do
			if v:GetRealOwner() == ply then v:PropRemove() end
		end
		for k,v in pairs(ents.FindByClass("sent_dispenser")) do
			if v:GetRealOwner() == ply && v.Type == "BATTLE" then v:PropRemove() end
		end
	end

	ply:CreateRagdoll( )
	ply.Died = ply.Died + 1
	self:CheckDead(ply)
	ply:AddDeaths(1)
	return true
end

function GM:CheckDead(ply)
	if PHASE == "BUILD" then return end
	if #player.GetAll() == 0 then
		GAMEMODE:StartBuild()
		return
	end
	for k,v in pairs(player.GetAll()) do
		if ply != v and v:Alive() then return end
	end
	GAMEMODE:StartBuild()
	AllChat("All players have perished. Loading build mode!")
end

function GM:PlayerDeathThink( ply )
	if ply.NextSpawn == nil then
		ply.NextSpawn = CurTime() + GAMEMODE.Config.SPAWN_TIME + (#player.GetAll() * GAMEMODE.Config.ADD_SPAWN_TIME)
	end
	if ply.NextSpawn > CurTime( ) then
		local players = player.GetAll()
		if ply:KeyReleased( IN_ATTACK ) then
			if !ply.specid then ply.specid = 1 end
			ply.specid = ply.specid + 1
			if ply.specid > #players then
				ply.specid = 1
			end
			if players[ply.specid] == ply || !players[ply.specid]:Alive() then
				return
			end
			ply:SetPos(players[ply.specid]:GetPos())
			ply:UnSpectate()
			ply:Spectate(ply.Specatemode)
			ply:Message("You are now spectating "..players[ply.specid]:Nick())
			ply:SpectateEntity( players[ply.specid] )
		end
		if ply:KeyReleased( IN_ATTACK2 ) then
			ply.specid = ply.specid - 1
			if ply.specid <= 0 then
				ply.specid = #players
			end
			ply:SetPos(players[ply.specid]:GetPos())
			ply:UnSpectate()
			ply:Spectate(ply.Specatemode)
			ply:SpectateEntity( players[ply.specid] )
		end
		if ply:KeyReleased( IN_JUMP ) then
			if ply.Specatemode == OBS_MODE_CHASE then
				ply.Specatemode = OBS_MODE_IN_EYE
			else
				ply.Specatemode = OBS_MODE_CHASE
			end
			ply:Spectate(ply.Specatemode)
			ply:SpectateEntity( players[ply.specid] )
		end
		ply:PrintMessage( HUD_PRINTCENTER, "You will respawn in " .. math.Round( ply.NextSpawn - CurTime( ) ) )
		return
	end
	ply:Spawn( )
end

function GM:PlayerShouldTakeDamage( ply, attacker )
	if PHASE == "BATTLE" then
		if attacker:IsPlayer() then
			return false
		elseif IsValid(attacker:GetOwner()) then
			if attacker:GetOwner():IsPlayer() then
				return false
			end
		end
		return true
	else
		if attacker:GetClass() == "worldspawn" then
			return false
		end
	end


	if !attacker:IsNPC() && !attacker:GetClass() == "trigger_hurt" then return false end
	return true
end

function GM:ScalePlayerDamage(ply, hitgrp, dmg)
	if dmg:GetAttacker():IsPlayer() then dmg:ScaleDamage(0) return end
	if dmg:IsExplosionDamage() || dmg:GetInflictor():GetClass() == "weapon_shotgun" then
		dmg:ScaleDamage(0.4)
	elseif dmg:GetAttacker():IsZombie() then
		dmg:ScaleDamage(10)
	elseif dmg:GetAttacker():GetClass() == "npc_manhack" then
		dmg:ScaleDamage(2)
	end
	if ZOMBIEMODE_ENABLED then
		dmg:ScaleDamage(2)
	end
	return dmg
end

function GM:PlayerNoClip(ply)
	if PHASE == "BATTLE" then return false end
	return true
end

function NoClipThink()
	if PHASE == "BATTLE" then return end
	for k,v in pairs(player.GetAll()) do
		if !v:IsInWorld() && v:Alive() then
			v:SetPos(v:GetPos() + (v:GetVelocity() * -0.1))
			v:SetVelocity(Vector(0,0,0))
			if !v:IsInWorld() then
				v:Kill()
				v:Message("Spy sappin' mah noclip protection", Color(255,100,100,255))
			end
		end
	end
end

hook.Add("Think", "NoClipThink", NoClipThink)

function GM:SaveAllProfiles()
	for k,ply in pairs(player.GetAll()) do
		ply:SaveProfile()
	end
end

function GM:ShutDown( )
	GAMEMODE:SaveAllProfiles()
end

function GM:PlayerDisconnected( ply )
	local iterator = ents.FindByClass("npc_turret_floor")
	table.Add(iterator,ents.FindByClass("npc_turret_ceiling"))
	table.Add(iterator,ents.FindByClass("sent_dispenser"))
	for k,v in pairs(iterator) do
		if v:GetRealOwner() == ply then v:PropRemove() end
	end
	if IsValid(ply.CusSpawn) then
		ply.CusSpawn:Remove()
	end
	self:CheckDead(ply)
	discplayers[ply:SteamID()] = {MONEY = ply:GetNWInt("money"), OBJECT = ply, NEXTSPAWN = ply.NextSpawn, DIED = ply.Died, HEALTH = ply:Health()}
	if GAMEMODE.Config.PROP_CLEANUP then
		timer.Simple(GAMEMODE.Config.PROP_DELETE_TIME, function() GAMEMODE:DeleteProps(ply, ply:SteamID(), ply:Nick()) end)
		for k,v in pairs(player.GetAll()) do
			v:Message("Removing "..ply:Nick().."'s props in "..GAMEMODE.Config.PROP_DELETE_TIME.." seconds!")
		end
	end
	for k,v in pairs(ply.Hooks) do
		hook.Remove(v)
	end

	ply:SaveProfile()
end

function GM:DeleteProps(ply, ID, nick)
	if !ID then return end
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == ID then
			v:Message(nick.."'s prop will not be deleted", Color(100,255,100,255))
			return
		end
	end
	print("[ONSLAUGHT] Deleting props")
	for k,v in pairs(ents.FindByClass("sent_*")) do
		if v:GetClass() != "sent_spawner" then
			if v:GetRealOwner() == ply then
				v:PropRemove()
			end
		end
	end
	for k,v in pairs(discplayers) do
		if k == ID then discplayers[k] = nil end
	end
end

function GM:GravGunOnDropped( ply, ent )
	return false
end

function GM:GravGunPunt( ply, ent )
	if !ent:GetClass() == "npc_manhack" or !ent:GetClass() == "npc_rollermine" then return false end
	return true
end

function GM:PhysgunPickup(ply, ent)
	if ent:GetClass( ) == "sent_dispenser" then return false end
	if ent:PropOp(ply) then
		return true
	end
	return false
end

function GM:PhysgunDrop(ply, ent)
	ent:GetPhysicsObject():EnableMotion(false)
end

function GM:OnPhysgunFreeze(weapon, physobj, ent, ply)
	if ent:PropOp(ply) then
		if ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent:SetColor(Color(100,100,255,128))
		else
			ent:SetRenderMode(RENDERMODE_NORMAL)
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		ent:SetColor(Color(255,255,255,255))
		end
	end
	return false
end

function GM:OnPhysgunReload( wep, ply ) -- TODO: BUDDY SYSTEM

	local trace = {}
	trace.start = ply:GetShootPos()
	trace.endpos = trace.start + (ply:GetAimVector() * 1000)
	trace.filter = ply
	local trc = util.TraceLine(trace)

	if !trc.Entity then return false end
	if !trc.Entity:IsValid( ) then return false end

	local ent = trc.Entity

	if ent.Turret then ent = ent.Turret end

	if ent:PropOp(ply) then
		ent:PropRemove(true)
	end
	return false
end
LAGGGGG = 100
function GM:Think()
	TimeLeft = NextRound - CurTime()
	if TimeLeft <= 0 then
		if PHASE == "BUILD" then
			GAMEMODE:StartBattle()
		elseif PHASE == "BATTLE" then
			GAMEMODE:StartBuild()
		end
	end
	if CurTime() > GAMEMODE.Config.VOTE_ENABLE_TIME && votingenabled == false then
		 votingenabled = true
		 AllChat("Map voting is now enabled!")
	end
	self.lagcalc = self.lagcalc or CurTime( )
	self.tic = self.tic or CurTime( )
	if CurTime( ) - self.lagcalc >= 5 then
		local avg = 0
		local plys = player.GetAll()
		for k,v in pairs( plys ) do
			avg = avg + v:Ping( )
		end
		LAGGGGG = avg / #plys
		local npcs = 0
		for k,v in pairs( ents.GetAll() ) do
			if v:IsNPC() and v:GetClass() != "npc_turret_floor" then //Might as well do this here.
				v:Fire( "setrelationship", "player D_HT 99" )
			end
			if v.spn then
				npcs = npcs + 1
			end
		end
		NPC_COUNT = npcs
		self.lagcalc = CurTime()
	elseif CurTime( ) - self.tic >= .75 then
		self.tic =	CurTime( )
		for k,v in pairs(player.GetAll()) do
			if v.Class == 2 then
				if v:Armor() < 50 then
					v:SetArmor(v:Armor()+1)
				end
			end
		end
	end
end

hook.Add("ShouldCollide","OSE.CombineBallCollision",function(ent1, ent2)
	if ent1:IsPlayer() and ent2:GetClass() == "prop_combine_ball" then
		return false
	end
end)

function GM:EntityTakeDamage(ent, dmginfo)
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	if ent:IsNPC() and IsValid(inflictor) and IsValid(attacker) then
		if attacker.DMGMult then
			dmginfo:ScaleDamage(attacker.DMGMult)
		end
		if inflictor:IsPlayer() then inflictor = attacker:GetActiveWeapon() end --This looks VERY dumb.
		if not IsValid(inflictor) then return end
		if inflictor:IsWeapon() and inflictor.Prefix and not ent.Igniter then
			inflictor:DoDamage(ent,attacker,dmginfo)
		end
	end
	if ent:IsPlayer() then
		ent:SetNWInt("Armor", ent:Armor())
	end
	
end

function GM:OnNPCKilled( npc, killer, wep)
	if npc.spn then
		NPC_COUNT = NPC_COUNT - 1
	end
	if !killer:IsValid() then return end
	local class = npc:GetClass()
	local tab = {}
	if not NPCS[class] then
		NPC_COUNT = NPC_COUNT + 0.5
		for k,v in pairs(NPCS) do
			if v.ENTITY == class then
				tab = v
				class = k
				break
			end
		end
	else
		tab = NPCS[class]
	end
	
	local name = npcs[class] or class
	local bonus = 0
	
	if class == "snpc_combine_s" then
		if npc:GetModel() == "models/combine_super_soldier.mdl" then
			bonus = 40
		elseif npc:GetModel() == "models/combine_soldier_prisonguard.mdl" then
			bonus = 20
		end
	end
	if npc:IsZombie() && npc.poison then -- ZOMBIES ARE SUPREME (rightnow)
		local sequence = npc:LookupSequence("releasecrab")
		npc:ResetSequence(sequence)
		local pos = npc:GetPos()
		local entz = ents.FindInBox(Vector(pos.x-150,pos.y-150,pos.z-150),Vector(pos.x+150,pos.y+150,pos.z+150))
		local ed = EffectData()
		ed:SetOrigin(pos)
		for k,v in pairs(entz) do
			if v:IsPlayer() && v:Alive() then
				v:Poison(npc)
			end
		end
		util.Effect("poisonexplode", ed)
	end
	local plyobj = killer
	if not killer:IsPlayer() then
		if IsValid(killer:GetOwner()) && killer:GetOwner():IsPlayer() then
			plyobj = killer:GetOwner()
		elseif IsValid(npc.Igniter) then
			plyobj = npc.Igniter
		elseif IsValid(killer.Owner) and killer.Owner:IsPlayer() then
			plyobj = killer.Owner
		end
	end
	if !plyobj:IsPlayer() then return false end
	self:CalculatePowerups(npc,plyobj,wep)
	self:AddNPCKillMoney(class,plyobj,bonus)
	GAMEMODE:CheckRanks(plyobj,false)

	if math.random(1,1000) == 1 then
		local item
		local id
		local prf
		while not item do
			id = math.random(#NEW_WEAPONS)
			prf = math.random(#WEP_PREFIXES)
			if id >= #HL2_WEPS then
				item = NEW_WEAPONS[id]
			else
				item = HL2_WEPS[id]
			end
			if (item.NOPRF or prf==1) and ((not item.INDEX) or item.INDEX <= #HL2_WEPS) then
				item = nil //continue the loop if the item is an old wep and has noprf (no duplicates)
			end
		end
		plyobj:GiveItem(id,prf,true)
	end
end

function GM:AddNPCKillMoney(class,ply,bonus)
	local convZTable = {["snpc_police"]="npc_metropolice",["snpc_combine_s"]="npc_combine_s",["snpc_zombie_fast"]="npc_fastzombie",["snpc_zombie"]="npc_zombie",["snpc_zombie_poison"]="npc_poisonzombie"}
	local tab = NPCS[class]
	if not tab then
		if convZTable[class] then
			class = convZTable[class]
		end
	end
	local givemoney = NPCS[class].MONEY or NPCS[class][1].MONEY or 50
	local name = npcs[class] or class
	givemoney = givemoney + bonus

	ply:Money(givemoney,"+"..tonumber(givemoney).."$ ["..name.."]")
	timer.Simple(0.2,function() ply:Taunt() end)
	ply:SetNWInt("kills", ply:GetNWInt("kills") + math.Round(math.Clamp(givemoney / 100, 1, 10)))
	ply:SetFrags(ply:GetNWInt("kills"))
end

function GM:CalculatePowerups(npc, killer, wep, bonus)
	if not killer.Killstreak then killer.Killstreak = 0 end
	killer.LastKill = killer.LastKill or CurTime()
	if killer.LastKill + 0.5 > CurTime() then
		killer.Killstreak = killer.Killstreak + 1
		killer:Message("+"..killer.Killstreak*10 .." Health [Killing Spree]", Color(100,100,255,255))
		killer:AddHealth(killer.Killstreak*10)
	end
	killer.LastKill = CurTime()
	timer.Simple(0.5, function() if killer.LastKill + 0.5 < CurTime() then killer.Killstreak = 0 end end)
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

end

function GM:CreateEntityRagdoll( entity, ragdoll )

	ragdoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	timer.Simple( 2, function() if IsValid( ragdoll ) then ragdoll:Remove( ) end end)

end
/*
		local mortar = ents.Create( "func_tankmortar" )	
			mortar:SetPos( trace.HitPos )
			mortar:SetAngles( Angle( 90, 0, 0 ) )
			mortar:SetKeyValue( "iMagnitude", 200 ) // Damage.
			mortar:SetKeyValue( "firedelay", "1" ) // Time before hitting.
			mortar:SetKeyValue( "warningtime", "1" ) // Time to play incoming sound before hitting.
			mortar:SetKeyValue( "incomingsound", "Weapon_Mortar.Incomming" ) // Incoming sound.
		mortar:Spawn()
		mortar.Owner = ply
		mortar:SetOwner(ply)
		// Create the target.
		local target = ents.Create( "info_target" )
			target:SetPos( trace.HitPos )
			target:SetName( tostring( target ) )
		target:Spawn()
		mortar:DeleteOnRemove( target )
		
		// Fire.
		mortar:Fire( "SetTargetEntity", target:GetName(), 0 )
		mortar:Fire( "Activate", "", 0 )
		mortar:Fire( "FireAtWill", "", 0 )
		mortar:Fire( "Deactivate", "", 2 )
		mortar:Fire( "kill", "", 2 )*/
