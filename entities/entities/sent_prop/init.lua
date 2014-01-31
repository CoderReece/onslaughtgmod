AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.Shealth = 100
ENT.Mhealth = 100
ENT.SMH = 100
ENT.Model = ""
ENT.Owner = nil
ENT.LastTouch = CurTime()
ENT.LastUpdate = CurTime()
ENT.count = 0


function ENT:Initialize()
	self.Entity:SetModel( self.Model ) 	//Model path
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )


	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
		self:SetUnFreezable( true )
		self:CalculateHealth()
		self.Mhealth = self.SMH
		self.Shealth = self.SMH
	end
end

function ENT:CalculateHealth()
		self.SMH = math.Clamp(self.Entity:GetPhysicsObject():GetMass() * (self.Entity:OBBMins():Distance(self.Entity:OBBMaxs())) / 100,200,800)
end

function ENT:Touch(ent) -- Zombies need all the help they can get :-(
	if table.HasValue(Zombies, ent:GetClass()) && (!ent.LastTouch || ent.LastTouch + 2 < CurTime()) then
		ent:SetSchedule(SCHED_MELEE_ATTACK1)
		ent:SetNPCState(3)
		self.Shealth = self.Shealth - 70
		self.Entity:UpdateColour()
		ent.LastTouch = CurTime()
		if self.Shealth <= 0 then
			self:Dissolve()
		elseif GAMEMODE.Config.FLAMABLE_PROPS && self.Shealth / self.Mhealth <= 0.4 then
			self.Entity:Ignite(8,150)
		end
	end
end

function ENT:Think()
end

function ENT:Prepare()
		local trc = {}
		trc.start = self:GetPos()
		trc.endpos = self:GetPos()
		trc.filter = self
		trc = util.TraceLine( trc ) --antiexploiting
		if trc.HitWorld || !self:IsInWorld() then
			self:Remove()
		end
		self.Mhealth=self.SMH

		local ang = self:GetAngles()
		local spawners = ents.FindByClass("sent_spawner")

		local bull = ents.Create("npc_bullseye")
		local pos = spawners[math.random(1,#spawners)]:GetPos()

		local bullpos = self.NearestPoint(self, Vector(pos.x,pos.y,self:LocalToWorld(self:OBBCenter()).z))

		bullpos = self:WorldToLocal(bullpos)

		local posone = self:OBBMaxs()
		local postwo = self:OBBMins()

		local xd = posone.x - postwo.x
		local yd = posone.y - postwo.y
		local zd = posone.z - postwo.z

		local xy = xd*yd
		local xz = xd*zd
		local yz = yd*zd

		if xy > xz && xy > yz then
		bullpos.z = self:OBBCenter().z
		end

		if xz > yz && xz > xy then
		bullpos.x = self:OBBCenter().x
		else
		bullpos.y = self:OBBCenter().y
		end

		bullpos = self:LocalToWorld(bullpos)

		bull:SetPos(bullpos)
		bull:SetParent(self.Entity)
		bull:SetKeyValue("health","9999")
		bull:SetKeyValue("minangle","360")
		bull:SetKeyValue("spawnflags","516")
		bull:SetNotSolid( true )
		bull:Spawn()
		bull:Activate()

		--local debugprop = ents.Create("prop_physics")
		--debugprop:SetPos(bullpos)
		--debugprop:SetParent(self.Entity)
		--debugprop:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		--debugprop:Spawn()

		self:SetAngles(ang)

	local trace = util.QuickTrace(self:GetPos(), Vector(0,0,-1000), ents.FindByClass("sent_*"))
	if trace.HitWorld then
		if trace.Fraction > .01 then
			self.Mhealth = self.Mhealth / (10*trace.Fraction)
		end
	end

	local propcount = #ents.FindByClass("sent_prop")
	self.Mhealth = self.Mhealth - ((propcount / 3) * self.Mhealth / 320) --less health for more props

	if self.Mhealth <= 50 then self.Mhealth = 50 end
	self.Shealth = self.Mhealth

	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetColor(Color(255,255,255,255))
end

function ENT:PropReset()
	self:Extinguish()
	self.Mhealth = self.SMH
	self.Shealth = self.SMH
	self:UpdateColour()
	self:SetMoveType(MOVETYPE_VPHYSICS)
end

function ENT:UpdateColour()
	local col = (self.Shealth / self.Mhealth) * 255
	self.Entity:SetColor(Color(col, col, col, 255))
	self.LastUpdate = CurTime()
end

function ENT:OnTakeDamage(dmg)
	if IsValid(dmg:GetInflictor()) then
		if dmg:GetInflictor():IsPlayer() then
		 	dmg:SetDamage(0)
			return dmg
		elseif IsValid(dmg:GetInflictor():GetRealOwner()) then
			if dmg:GetInflictor():GetRealOwner():IsPlayer() then
				dmg:SetDamage(0)
				return dmg
			end
		end
	end

	local damage = dmg:GetDamage()
	local pos = self:LocalToWorld(self:OBBCenter())
	local base = 0

	if self.count == 0 then 
		damage = damage * DamageMod()
	else 
		damage = damage * DamageMod() / self.count 
	end

	if IsValid(dmg:GetInflictor()) then
		if dmg:GetInflictor():GetClass() == "weapon_shotgun" then damage = damage / 2 end
	end

	if ZOMBIEMODE_ENABLED then
		damage = damage * 2
	end
	--print("DAMAGE: "..(damage + ((self.Mhealth - self.Shealth) / 6)))
	if !GAMEMODE.Config.FLAMABLE_PROPS then
		self.Shealth = self.Shealth - (damage + ((self.Mhealth - self.Shealth) / 12))
	else
		self.Shealth = self.Shealth - damage
	end


	if self.LastUpdate + 2 < CurTime() then
		self:UpdateColour()
		self.count = 0
		if GAMEMODE.Config.ADVANCED_DAMAGE then
			for k,v in pairs(ents.FindInBox(Vector(pos.x-300,pos.y-300,pos.z-300),Vector(pos.x+300,pos.y+300,pos.z+300))) do
				if v:IsPlayer() then self.count = self.count + 1 end
			end
		end
	end
	if self.Shealth <= 0 then
		self:Remove()
	elseif GAMEMODE.Config.FLAMABLE_PROPS && self.Shealth / self.Mhealth <= 0.2 then
		self.Entity:Ignite(8,150)
	end
	return dmg
end

function ENT:OnRemove()
end

