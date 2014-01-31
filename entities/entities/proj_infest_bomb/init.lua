AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Radius = 150
ENT.Damage = 75
ENT.Spread = 100
ENT.Reflectable = false

function ENT:Initialize()
	self:SetModel("models/dav0r/hoverball.mdl") 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NPC) 
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
	self:SetModelScale(4,0)
	self.Lobs = 1.5
end

function ENT:Use(activator, caller)
	return false
end

function ENT:Think()
	if self.Stuck and not IsValid(self.StuckEntity) then
		self:Remove()
	end
	self.CreateTime = self.CreateTime or CurTime()
	if self.CreateTime+3 < CurTime() then
		self:Remove()
	end
end

ENT.ExplodeOnTouch = true

function ENT:PhysicsCollide( data, phys )
	if self.ExplodeOnTouch and data.HitObject:GetEntity():GetClass() != self:GetClass() then
		self:Explode()
		return
	end
end

local cl, owner, phys, distance, relation, forceDir, pos, pos2, mass, dmg

local function GetTrajectoryVelocity(startingPosition, targetPosition, lob, gravity)

	local physicsTimestep = 1/66
	local timestepsPerSecond = 66
 
	local n = lob * timestepsPerSecond;
 
	local a = physicsTimestep * physicsTimestep * gravity;
	local p = targetPosition;
	local s = startingPosition;
 
	local velocity = (s + (((n * n + n) * a) / 2) - p) * -1 / n

	//This will give us velocity per timestep. The physics engine expects velocity in terms of meters per second
	velocity = velocity / physicsTimestep;
	return velocity;
end

function ENT:Explode()
	if self.BlewUp then
		--self:Remove()
		return
	end
	self.BlewUp = true
	owner = self.Owner
	pos = self:GetPos()

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "Explosion", effectdata)

	for k, v in ipairs(ents.FindInSphere(pos, self.Radius)) do
		if IsValid(v) then
			pos2 = v:GetPos()
			distance = pos:Distance(pos2)
			forceDir = ((pos2 - pos):GetNormal() * 500)
			
			if (v.Health and v:Health() > 0) then
				dmg = DamageInfo()
				dmg:SetInflictor(self)
				if IsValid(owner) then
					dmg:SetAttacker(owner)
				end
				
				dmg:SetDamageType(DMG_DIRECT)
				dmg:SetDamage((1 - distance / self.Radius) * self.Damage)
				--dmg:SetDamageForce(forceDir * 200)
				v:TakeDamageInfo(dmg)
			end
		end
	end
	for i = 1,math.random(10,30) do
		local ball = ents.Create("proj_infest_ball")
		ball:SetCustomCollisionCheck(true)
		ball:SetPos(pos)
		ball.Owner = self
		ball:Spawn()
		local phys = ball:GetPhysicsObject()
		phys:ApplyForceCenter(Vector(math.random(-self.Spread,self.Spread),math.random(-self.Spread,self.Spread),math.random(self.Spread/3,self.Spread))*20)
	end
	if self.Lobs >= 0.75 and math.random(1,30) > 13 then
		local dist = 9999999999999
		local target = nil
		for k,v in ipairs(player.GetAll()) do
			if v:GetPos():DistToSqr(self:GetPos()) < dist then
				dist = v:GetPos():DistToSqr(self:GetPos())
				target = v
			end
		end
		local phys = self:GetPhysicsObject()
		local vel = GetTrajectoryVelocity(self:GetPos(),target:GetPos(),self.Lobs,Vector(0,0,-800))
		self.Lobs = self.Lobs - 0.25
		phys:SetVelocityInstantaneous(vel+VectorRand()*math.random(-100,100))
		timer.Simple(0,function() self.BlewUp = false end)
		self.CreateTime = CurTime()
		return
	end
	self:Remove()
end