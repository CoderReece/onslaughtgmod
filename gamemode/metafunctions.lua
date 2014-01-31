function Emeta:Dissolve()
	if ( IsValid( self) && !self.Dissolving ) then
		local dissolve = ents.Create( "env_entity_dissolver" )
		dissolve:SetPos( self:GetPos() )

		self:SetName( tostring( self ) )
		dissolve:SetKeyValue( "target", self:GetName() )

		dissolve:SetKeyValue( "dissolvetype", "3" )
		dissolve:Spawn()
		dissolve:Fire( "Dissolve", "", 0 )
		dissolve:Fire( "kill", "", 1 )

		dissolve:EmitSound(Sound("weapons/physcannon/energy_sing_flyby1.wav"), 500,100)
		self:Fire( "sethealth", "0", 0 )
		self.Dissolving = true
	end
end

function Emeta:IsZombie()
	if IsValid( self ) then
		if table.HasValue(Zombies, self:GetClass()) then return true end
	end
	return false
end

function Emeta:Alive()
	return self:Health() > 0
end

function Emeta:NPCDiss()
	if ( IsValid( self) && !self.Dissolving ) then
		local dissolve = ents.Create( "env_entity_dissolver" )
		dissolve:SetPos( self:GetPos() )

		self:SetName( tostring( self ) )
		dissolve:SetKeyValue( "target", self:GetName() )

		dissolve:SetKeyValue( "dissolvetype", "0" )
		dissolve:SetKeyValue( "magnitude", "3000" )
		dissolve:Spawn()
		dissolve:Fire( "Dissolve", "", 0 )
		dissolve:Fire( "kill", "", 1 )

		dissolve:EmitSound(Sound("weapons/physcannon/energy_sing_flyby1.wav"), 500,100)
		self:Fire( "sethealth", "0", 0 )
		self.Dissolving = true
	end
end

function Emeta:GetRealOwner()
	local owner
	if IsValid(self.Owner) then owner = self.Owner elseif IsValid(self:GetOwner()) then owner = self:GetOwner() end
	return owner
end

function Emeta:CheckValidOwnership(removenpcs)
	removenpcs = removenpcs or false
	local owner = self:GetRealOwner()
	local model = self:GetModel()
	if owner then
		if MODELS[model] && MODELS[model].PLYCLASS and MODELS[model].PLYCLASS != owner:GetNWInt("class") then
			self:PropRemove(true)
		end
		return
	elseif removenpcs == true then
		self:PropRemove()
	end
end

function Emeta:IsProp()
	if self.Spawnable == true || self:GetClass() == "npc_turret_floor" || self:GetClass() == "npc_turret_ceiling" then return true end return false
end

function AllChat(msg)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(200,0,0),"[OSE] ",Color(255,255,255),"]]..msg..[[")]])
	end
end

function Pmeta:Poison(npc)	
	if self.Poisoned == true then
		self.Poisonend = self.Poisonend + math.Rand(10,15)
		self:TakeDamage(math.random(10,25), self.Poisoner, self.Poisoner)
	else
		self:EmitSound("HL1/fvox/blood_toxins.wav", 150,100)
		self:SetColor(Color(100,150,100,255))
		self.Poisoned = true
		self.Poisoner = npc
		self.Poisonend = CurTime() + math.random(15,30)
		self:PoisonThink()
	end
end

function Pmeta:PoisonThink()
	if !self.Poisoned || CurTime() > self.Poisonend then --stop poisoning
		self:EmitSound("HL1/fvox/antitoxin_shot.wav", 150,100)
		self:SetColor(Color(255,255,255,255))
		self:SetNWBool("pois", false)
		self.Poisoned = false
		return false
	end
	self:SetNWBool("pois", true)
	if self:Health() <= 0 then
		self:TakeDamage(1,self.Poisoner,self.Poisoner)
	end
	self:SetHealth(self:Health() - math.random(2,4))
	timer.Simple(math.Rand(0.4,1.2),function() self:PoisonThink() end)
end

function Pmeta:SaveProfile()
	self:SendLua([[chat.AddText(Color(150,0,0,255),"[OSE] Your profile data has been saved!")]])
	local kills = self:GetNWInt("kills")
	local rank = self:GetNWInt("rank")
	local points = self:GetNWInt("points")
	sql.Query("UPDATE ose_player_info SET kills = "..kills..", rank = "..rank..", points = "..points.." WHERE steam_id = '"..self:SteamID().."'")
	
	self:SaveItems()
	self:SaveEItems()	
end

function Pmeta:SetProp(prop)
	if not MODELS[prop] then return end
	self:SetNWString("prop",prop)
end
concommand.Add("ose_prop",function(ply,cmd,args) ply:SetProp(args[1]) end)

function Pmeta:GetDefaultClass()
	local dclass = self:GetInfo("ose_defaultclass")
	if dclass then
		for k,v in pairs(CLASSES) do
			if v.NAME == dclass then
				self:ConCommand("Join_Class "..k)
				return
			end
		end
	end
end

-------------------------------------------------------------------------------
--PropOp
--Check to see if a player can do an operation on a prop)
-------------------------------------------------------------------------------

function Emeta:PropOp(ply,noadmin)
	if !self:IsProp() then return false end
	local owner = self:GetRealOwner()
	if IsValid(owner) and owner != ply && (!ply:IsAdmin() || noadmin) and not table.HasValue(owner.Buddies,ply:SteamID()) then //i got you conman
		if !noadmin then
			ply:PrintMessage( HUD_PRINTCENTER, "This is owned by " .. self:GetRealOwner():Nick() )
			ply:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		end
		return false
	end
	return true
end

function Emeta:PropRemove(sell,silent)
	if self.Dissolving then return 0 end
	sell = sell or false
	silent = silent or false
	local cost
	if sell then
		local owner = self:GetRealOwner()
		local model = self:GetModel()

		if owner then
			if MODELS[model] && MODELS[model].COST then
				cost = MODELS[model].COST
			elseif self.SMH && self.SMH > 0 then
				cost = self.SMH
			end
		end
		if cost then
			if !silent then
				if MODELS[model] && MODELS[model].NAME then
					owner:Money(cost,"+"..math.Round(cost).." [Deleted "..MODELS[model].NAME.."]")
				else
					owner:Money(cost,"+"..math.Round(cost).." [Deleted Item]")
				end
			end
		end
	end
	if self:IsNPC() then self:Remove() else self:Dissolve() end
	return cost or 0
end

function Pmeta:Money(amt,msg,col)
	local suffix = " "
	local money = self:GetNWInt("money")
	if amt < 0 then
		if money + amt < 0 then
			self:Message("Insufficient Funds!", Color(255,100,100,255))
			self:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
			return false
		end
		if !col then col = Color(255,100,100,255) end
	else
		suffix = "+"
		if !col then col = Color(100,255,100,255) end
	end

	self:SetNetworkedInt("money",money + amt)
	if msg then self:Message(msg,col) end

	return true
end

function Pmeta:IsStuck()
		local trc = {}
		trc.start = self:LocalToWorld(self:OBBMaxs())
		trc.endpos = self:LocalToWorld(self:OBBMins())
		trc.filter = self
		trc = util.TraceLine( trc )
		if trc.Hit then
			self.NextSpawn = CurTime() + 5
			self:Kill()
			return true
		end
	return false
end

function Pmeta:GetRank()
	local rank = self:GetNWInt("rank")
	return rank
end

function Pmeta:Message(txt,col,msg)
	local colour = col or Color(255,255,255,255)
	umsg.Start("ose_msg", self)
		umsg.String(tostring(txt))
		umsg.String(colour.r.." "..colour.g.." "..colour.b.." "..colour.a)
		umsg.Bool(msg)
	umsg.End()
end

function Pmeta:MdlMessage(mdl,txt,col,msg)
	local colour = col or Color(255,255,255,255)
	umsg.Start("ose_mdl_msg", self)
		umsg.String(tostring(mdl))
		umsg.String(tostring(txt))
		umsg.String(colour.r.." "..colour.g.." "..colour.b.." "..colour.a)
		umsg.Bool(msg)
	umsg.End()
end

function Pmeta:AddHealth(health)
	if self:Health() + health > self:GetMaxHealth() then
		self:SetHealth(self:GetMaxHealth())
		return
	end
	self:SetHealth(self:Health() + health)
end

function Pmeta:Taunt()
	self.LastTaunt = self.LastTaunt or CurTime()
	local taunts = TAUNTS[self.Class]
	if math.random(1,2) == 2 && self.LastTaunt + 20 <= CurTime() then
		self:EmitSound(taunts[math.random(1,#taunts)],140,100)
		self.LastTaunt = CurTime()
	end
end

function isnumber( var )
	if var == nil then
		return false
	end
	if type( var ) == "string" then
		return tostring( tonumber( var ) ) == var
	elseif type( var ) == "number" then
		return true
	end
	return false
end

function UpdateTime()
	----------------------------------------------------------------
	umsg.Start("updatebattletime")
		umsg.Long(GAMEMODE.Config.BATTLETIME)
	umsg.End()
	----------------------------------------------------------------
	umsg.Start("updatebuildtime")
			umsg.Long(GAMEMODE.Config.BUILDTIME)
	umsg.End()
	----------------------------------------------------------------
	umsg.Start("updatetime")
		umsg.Long(TimeLeft)
		umsg.String(PHASE)
	umsg.End()
end

function Pmeta:CheckDead()

	if PHASE == "BUILD" then return end

	for k,v in pairs(player.GetAll()) do
		if self != v and v:Alive() then return end
	end
	GAMEMODE:StartBuild()

	AllChat("All players have perished loading build mode!")

end