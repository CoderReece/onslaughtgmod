function Class(ply,com,args)
	local newclass = tonumber(args[1])
	if !CLASSES[newclass] then return end
	ply:SetNetworkedInt("class", newclass )
	ply.Class = newclass
	for k,v in pairs( ents.GetAll( ) ) do
		if v:IsNPC() || v:GetClass() == "ose_mines" then
			v:CheckValidOwnership()
		end
	end
	if PHASE == "BATTLE" && ply:Alive() then
		ply.NextSpawn = CurTime() + GAMEMODE.Config.SPAWN_TIME + (#player.GetAll() * 5)
		ply:Kill()
	else
		ply:ChatPrint("You will spawn as "..CLASSES[newclass].NAME.." in the battle phase")
	end
end

concommand.Add("join_class", Class)

function AdminMenu(ply,com,args)
	if not ply:IsAdmin( ) then return false end

	if args[ 1 ] == "1" then
		GAMEMODE:StartBattle()
		AllChat("Admin: " .. ply:Nick() .. " skipped to battle mode!")
	elseif args[ 1 ] == "2" then
		GAMEMODE:StartBuild()
		AllChat("Admin: " .. ply:Nick() .. " skipped to build mode!")
	elseif args[ 1 ] == "3" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		MAX_NPCS = tonumber( args[ 2 ] )
		AllChat("Admin: " .. ply:Nick() .. " changed the maximum NPCs to " .. tonumber( args[ 2 ] ))
	elseif args[ 1 ] == "4" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		GAMEMODE.Config.BUILDTIME = tonumber( args[ 2 ] )
		AllChat("Admin: " .. ply:Nick() .. " changed build time to " .. string.ToMinutesSeconds(tonumber(args[ 2 ])))
		UpdateTime()
		umsg.Start("updatebuildtime")
			umsg.Long(GAMEMODE.Config.BUILDTIME)
		umsg.End()
	elseif args[ 1 ] == "5" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		GAMEMODE.Config.BATTLETIME = tonumber( args[ 2 ] )
		AllChat("Admin: " .. ply:Nick() .. " changed battle time to " .. string.ToMinutesSeconds(tonumber(args[ 2 ])))
		UpdateTime()
		umsg.Start("updatebattletime")
			umsg.Long(GAMEMODE.Config.BATTLETIME)
		umsg.End()
		elseif args[ 1 ] == "6" then
		if not isnumber( args[ 2 ] ) then
			ply:ChatPrint( "Must enter a number." )
			return
		end
		GAMEMODE.Config.SPAWN_TIME = tonumber( args[ 2 ] )
		AllChat("Admin: " .. ply:Nick() .. " changed spawn time to " .. string.ToMinutesSeconds(tonumber(args[ 2 ])))

	elseif args[ 1 ] == "select" then
		ply:Give( "swep_select" )
	elseif args[ 1 ] == "owner" then
		if isnumber( args[ 2 ] ) then
			for k,v in pairs( GAMEMODE.SaveProps ) do
				v.Owner = player.GetByID( tonumber( args[ 2 ] ) )
			end
		else
			ply:ChatPrint( "Must enter a number." )
		end
		GAMEMODE:DeselectAll( )
	elseif args[ 1 ] == "getfiles" then
		if not file.Exists( "onslaught_saves" ) then
			file.CreateDir( "onslaught_saves" )
		end
		local read = file.Find( "onslaught_saves/*.txt" )
		umsg.Start( "RecvLoadfiles", ply )
			umsg.Short( #read )
			for k,v in pairs( read ) do
				umsg.String( v )
			end
		umsg.End( )
	elseif args[1] == "map" then
		AllChat("Admin: "..ply:Nick().." changed map to ".. args[2])
		GAMEMODE:SaveAllProfiles()
		GAMEMODE:ChangeMap(args[2])
	elseif args[1] == "kick" then
		game.ConsoleCommand("kick "..args[2].."\n")
	elseif args[1] == "kill" then
		player.GetByID( tonumber(args[2]) ):Kill()
	end
end

concommand.Add( "admin", AdminMenu )

function GM:PlayerSay( ply, txt, pub )
	if string.sub(txt,1,5) == "!help" then
		ply:ChatPrint("Available chat commands are: !give !agive !voteskip !spawn !resetspawn, !stuck")
	end
	if string.sub(txt,1,6) == "!give " then
		local args = string.Explode(" ", txt)
		if #args != 3 || tonumber(args[3]) <= 0 then
			ply:ChatPrint("Wrong Syntax! Type !give <partial player name> <amount to give>")
			return ""
		end
		if ply:GetNetworkedInt("money") < tonumber(args[3]) then
			ply:ChatPrint("You do not have enough money to give that amount!")
			return ""
		end
		for k,v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()),string.lower(args[2])) then
				v:Money(tonumber(args[3]),ply:Nick().." gave you "..args[3].." money!")
				ply:Money(- tonumber(args[3]),"You succesfully gave "..v:Nick().." "..args[3].." money.")
				return txt
			end
		end
		ply:ChatPrint("Could not find the requested player!")
		return ""
	end
	if string.sub(txt,1,6) == "!agive" then
		if !ply:IsAdmin() then ply:ChatPrint("You need to be an admin to use this command!") return "" end
		local args = string.Explode(" ", txt)
		if #args != 3 || tonumber(args[3]) <= 0 then
			ply:ChatPrint("Wrong Syntax! Type !give <partial player name> <amount to give>")
			return ""
		end
		for k,v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()),string.lower(args[2])) then
				v:Money(tonumber(args[3]),"Admin: "..ply:Nick().." gave you "..args[3].." money!")
				return txt
			end
		end
		ply:ChatPrint("Could not find the requested player!")
		return ""
	end
	if string.sub(txt,1,6) == "!stuck" then
		Stuck(ply)
	end
	if string.sub(txt,1,6) == "!spawn" then
		SpawnPoint(ply)
	end
	if string.sub(txt,1,11) == "!resetspawn" then
		ResetSpawn(ply)
	end
	if string.sub(txt,1,8) == "!sellall" then
		SellAll(ply)
	end
	if string.sub(txt,1,9) == "!voteskip" then
		VoteSkip(ply)
	end
	return txt
end


function Stuck(ply,cmd,args)
	if !ply:IsStuck() then
		ply:Message("You are not stuck!")
	end
end

concommand.Add("stuck", Stuck)

function SpawnPoint(ply,cmd,args)
	if ply:GetRank() < 3 then
		ply:ChatPrint("You must be a corporal or above to use this command!")
		return
	end
	if PHASE == "BUILD" then
		if not ply:IsInWorld( ) || ply:GetMoveType() == MOVETYPE_NOCLIP then
			ply:Message("You can't make your spawnpoint here!", Color(255,100,100,255))
			return
		else
			local trc = {}
			trc.start = ply:GetPos() + Vector(0,0,5)
			trc.endpos = ply:GetPos() + ply:GetUp() * -10
			trc.filter = ply
			trc = util.TraceLine( trc ) --check if the player is standing above skybox (under the map) or a nodraw
			if trc.HitSky || trc.HitNoDraw || trc.Entity:IsProp() || ply:Crouching( ) || !trc.Hit then
				ply:Message("You can't make your spawnpoint here!", Color(255,100,100,255))
				return
			end
			ply:Message("Set custom spawn!")
			ply:Message("Say !resetspawn to reset your spawnpoint")
			if IsValid(ply.CusSpawn) then
				ply.CusSpawn:Remove()
			end
			local spn = ents.Create("sent_spawpoint")
			spn:SetPos(ply:GetPos())
			spn:Spawn()
			spn:Activate()
			spn.Owner = ply
			spn:SetNWEntity("owner", ply)
			ply.CusSpawn = spn
		end
	else
		ply:Message("Can't set spawn in battle phase", Color(255,100,100,255))
	end
end

concommand.Add("spawnpoint", SpawnPoint)

function ResetSpawn(ply,cmd,args)
	ply.CusSpawn:Remove()
	ply.CusSpawn = nil
	ply:Message("Reset spawnpoint!")
end

concommand.Add("resetspawn", ResetSpawn)

function SellAll(ply,cmd,args)
	if PHASE == "BATTLE" then
		ply:Message("Can't sell all in battle mode!", Color(255,100,100,255))
		return
	end
	local mon = 0
	for k,v in pairs(ents.GetAll()) do
		if v:PropOp(ply,true) then
			mon = mon + v:PropRemove(true,true)
		end
	end
	if(mon > 0) then
	ply:Money(mon,"+"..math.Round(mon).." [Sold all props]")
	end
end

concommand.Add("sellall", SellAll)

voted = 0

function VoteSkip(ply,cmd,args)
	if PHASE == "BATTLE" then
		ply:ChatPrint("You cannot skip battle phase")
		return ""
	else
		if ply.Voted == true then
			ply:ChatPrint("You have already voted!")
			return ""
		end
		ply.Voted = true
		voted = voted + 1
		local numplayer = #player.GetAll()
		local req = math.ceil(numplayer * .6)
		AllChat(ply:Nick().." voted to skip build mode!"..voted.."/"..req.." votes.")
		if voted >= req then
			AllChat("Starting Battle Phase in 5 seconds!")
			timer.Simple(5,function() GAMEMODE:StartBattle() end)
			return txt
		end
	end
end

concommand.Add("voteskip", VoteSkip)

local read = file.Find("maps/ose_*.bsp","GAME")

local mapvotes = {}

function SendMaps(ply,cmd,args)
	umsg.Start( "sendmaps", ply )
		umsg.Short( #read )
		for k,v in pairs( read ) do
			umsg.String( v )
		end
	umsg.End( )
end

concommand.Add("getmaps", SendMaps)

voting = false
votingenabled = false

function Votemap(ply,cmd,args)
	if ply.mapvoted then
		ply:ChatPrint("You have already voted!")
		return
	end
	if !args[1] then return end
	if votingenabled == false then
		ply:ChatPrint("You must wait "..string.ToMinutesSeconds(tostring(GAMEMODE.Config.VOTE_ENABLE_TIME - CurTime())).." until you can vote.")
		return
	elseif PHASE == "BATTLE" then
		ply:ChatPrint("You can't start a vote in battle phase!")
		return
	elseif string.sub(args[1],1, -5 ) == game.GetMap() && voting == false then
		ply:ChatPrint("You can't start a vote for the current map!")
		return
	elseif voting == false then
		GAMEMODE:StartMapVote(ply)
	end
	ply.mapvoted = true
	mapvotes[args[1]] = mapvotes[args[1]] + 1
	AllChat(ply:Nick().." voted for map "..args[1]..". "..mapvotes[args[1]].." votes!")
end

concommand.Add("votemap", Votemap)

function SaveProfile(ply,cmd,args)
	ply:SaveProfile()
end

concommand.Add("saveprof", SaveProfile)

function GM:StartMapVote(ply)
	for k,v in pairs(read) do
		mapvotes[v] = 0
	end
	voting = true
	for k,v in pairs(player.GetAll()) do
			if v != ply then
				v:ChatPrint(ply:Nick().." has started a map vote! You have "..GAMEMODE.Config.VOTE_TIME.." to cast your vote!")
				v:ConCommand("openmap")
				v:ChatPrint("Don't want to change? Vote for the current map: "..game.GetMap())
			end
	end
	timer.Simple(GAMEMODE.Config.VOTE_TIME, function() GAMEMODE:EndVote() end)
end

function GM:EndVote()
	local map = ""
	local lastgreat = 0
	for k,v in pairs(mapvotes) do
		if v > lastgreat || (v >= lastgreat && string.sub(k,1, -5 ) == game.GetMap()) then
			map = k
			lastgreat = v
		end
	end
	if game.GetMap() == string.sub(map,1, -5 ) then
		AllChat("The current map has won the vote!")
		AllChat("Map voting is now disabled!")
		for k,v in pairs(player.GetAll()) do
			voting = false
			v.mapvoted = false
		end
		GAMEMODE.Config.VOTE_ENABLE_TIME = CurTime() + 660
		return
	end
	AllChat("The map: "..string.sub(map,1, -5 ).." has won the vote!")
	AllChat("Starting the winning map in 5 seconds!")
	GAMEMODE:SaveAllProfiles()
	timer.Simple(5, function() GAMEMODE:ChangeMap(string.sub(map,1, -5 )) end)
end

function GM:ChangeMap(map)
	game.ConsoleCommand("changelevel "..map.."\n")
end

function BuyAmmo(ply, com, args)
	if !ply.AmmoBin then return end
	if !args[1] then return end
	local ammotogive = AMMOS[tonumber(args[1])]
	if !ammotogive then return false end
	local amt = tonumber(args[2])
	if ply:Money(- ammotogive.PRICE*amt,-ammotogive.PRICE*amt.." [Bought "..ammotogive.QT*amt.." "..ammotogive.NAME.."]") then
		ply:GiveAmmo(ammotogive.QT*amt, ammotogive.AMMO)
		ply:SendLua([[surface.PlaySound("items/ammo_pickup.wav")]])
	end
end

concommand.Add( "buy_ammo", BuyAmmo )

function Pmeta:Ammo(bin)
	self.AmmoBin = bin
	self:Freeze(true)
	umsg.Start("openammo", self)
	umsg.End()
end

function CloseAmmo(ply)
	if !ply.AmmoBin then return end
	ply.AmmoBin:Close()
	ply.AmmoBin = nil
	ply:Freeze(false)
end

concommand.Add("ammo_closed", CloseAmmo)

function DeleteModel(ply, cmd, args)
	local model = args[1]
	if !model then return end
	if PHASE == "BATTLE" && !MODELS[model].ALLOWBATTLE then
		ply:Message("You can't delete props in battle!", Color(255,100,100,255))
		return
	end
	local entz = ents.FindByModel(model)
	local monadd = 0
	if #entz > 0 then
		for k,v in pairs(entz) do
			if v:PropOp(ply,true) then
				monadd = monadd + v:PropRemove(true,true)
			end
		end
		if monadd > 0 then
			ply:Money(monadd,"+"..math.Round(monadd).." [Sold Props]")
		end
	end
end

concommand.Add("deletemodel", DeleteModel)

function OSE_Spawn(ply,cmd,args)
	if !args[1] or !IsValid(ply) then return end
	local model = tostring(args[1])
	if !MODELS[model] then
		ply:Message("That model is disallowed!", Color(255,100,100,255))
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	elseif not MODELS[model].ALLOWBATTLE and PHASE == "BATTLE"  then
		ply:Message("You can't spawn this prop in Onslaught mode!", Color(255,100,100,255))
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	end
	local class = "sent_prop"
	local name = "Prop"
	if MODELS[model].CLASS then class = MODELS[model].CLASS end
	if MODELS[model].NAME then name = MODELS[model].NAME end
	if MODELS[model].PLYCLASS and MODELS[model].PLYCLASS != ply:GetNWInt("class") then return end

	local propcount = 0
	for k,v in pairs(ents.FindByClass(class)) do
		if v:GetRealOwner() == ply then
			propcount = propcount + 1
		end
	end
	if MODELS[model].LIMIT then
		if propcount >= MODELS[model].LIMIT then
			ply:Message(name.." Limit Reached!", Color(255,100,100,255))
			ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
			return
		end
	elseif propcount >= GAMEMODE.Config.PROP_LIMIT then
		ply:Message("Prop Limit Reached!", Color(255,100,100,255)) --The old one would say nameofprop.." Limit Reached", making you think you reached the maximum of that specific prop.
		ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]]) --Fixed now.
		return
	end

	local tracelen = 500
	if MODELS[model].RANGE then tracelen = MODELS[model].RANGE end

	local trace = {}
	trace.start = ply:GetShootPos()
	trace.endpos = ply:GetShootPos() + (ply:GetAimVector() * tracelen)
	trace.filter = {ply,ply:GetActiveWeapon():GetDTEntity(0)}

	local tr = util.TraceLine( trace )

	if !tr.Hit then return end

	local ent

	if !MODELS[model].DONTSPAWN then
		local ang = ply:EyeAngles()
		ang.yaw = ang.yaw + 180
		if MODELS[model].ANG then ang.yaw = ang.yaw + MODELS[model].ANG.yaw end
		ang.roll = 0
		ang.pitch = 0

		local argh = tonumber(args[2])
		local argp = tonumber(args[3])
		local argy = tonumber(args[4])
		local argr = tonumber(args[5])

		ang.yaw = ang.yaw + argy
		ang.pitch = ang.pitch + argp
		ang.roll = ang.roll + argr
		tr.HitPos.z = tr.HitPos.z + argh //lol

		ent = ents.Create(class)
		ent:SetAngles(ang)
		ent:SetPos(tr.HitPos)
		ent:SetModel(model)
		if MODELS[model].SPAWNFLAGS then
			ent:SetKeyValue("spawnflags",MODELS[model].SPAWNFLAGS)
		end
		ent.Owner = ply
		ent:SetNWEntity("Owner", ply)
		ent:Spawn()
		ent:Activate()
		

		
		local vec = tr.HitPos + tr.HitNormal
		if MODELS[model].HEIGHT then
			local maxs = ent:OBBMaxs()
			local mins = ent:OBBMins()
			local height = maxs.Z - mins.Z
			vec.Z = vec.Z + (height/2.1)
		end
		
		ent:SetPos(vec)
		/*//garry
		local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )	// Find a point that is definitely out of the object in the direction of the floor
		vFlushPoint = ent:NearestPoint( vFlushPoint )			// Find the nearest point inside the object to that point
		vFlushPoint = ent:GetPos() - vFlushPoint				// Get the difference
		vFlushPoint = tr.HitPos + vFlushPoint					// Add it to our target pos

		ent:SetPos( vFlushPoint )
		//endgarry*/

		local cost = MODELS[model].COST or ent.SMH or 1000
		cost = cost * 1.05 --What the hell is this? 

		local msg
		if MODELS[model].NAME then
			msg = math.Round(cost * -1).." [Spawned "..MODELS[model].NAME.."]"
		else
			msg = math.Round(cost * -1).." [Spawned Item]"
		end

		if not ent:IsInWorld( ) then
			ent:Remove()
			ply:ChatPrint( "Prop was outside of the world!" )
			return
		elseif !ply:Money(-cost,msg) then
			ent:Remove()
			return
		end
	end
	if MODELS[model].EXTBUILD then
		MODELS[model].EXTBUILD(ent, ply, tr)
	end
end

concommand.Add("gm_spawn", OSE_Spawn)
