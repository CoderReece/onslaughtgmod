AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Radius = 150
ENT.Damage = 30
ENT.Reflectable = true

function ENT:Initialize()
	self:SetModel("models/dav0r/hoverball.mdl") 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	--self:SetCollisionGroup(COLLISION_GROUP_NPC) 
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

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

function ENT:OnTakeDamage(dmginfo)
	if not dmginfo:GetAttacker() then return end
	local owner = self.Owner
	local pos = self:GetPos()
	local target = owner:GetPos()
	local lobs = math.max(pos:Distance(target) / 3000,0.1)
	self:GetPhysicsObject():EnableGravity(true)
	self:GetPhysicsObject():EnableDrag(true)
	local vel = GetTrajectoryVelocity(pos,target,lobs,Vector(0,0,-600))
	self:GetPhysicsObject():SetVelocityInstantaneous(Vector(0,0,0))	
	local atk = dmginfo:GetAttacker()
	timer.Simple(0,
	function()
		self:GetPhysicsObject():ApplyForceCenter(vel)
		self.Owner = atk
		self.Damage = self.Damage * 2
	end)
	return false
end

function ENT:Use(activator, caller)
	return false
end

ENT.nextEffect = 0
function ENT:Think()
	if self:GetPhysicsObject():GetVelocity().z <= 10 then
		self:GetPhysicsObject():EnableGravity(false)
		self:GetPhysicsObject():EnableDrag(false)
		local lobs = 1
		local vel = GetTrajectoryVelocity(self:GetPos(),self.Target:GetPos(),lobs,Vector(0,0,-200))
		self:GetPhysicsObject():ApplyForceCenter(vel/2)
	end

	if self.nextEffect > CurTime() then return end
	self.nextEffect = CurTime()+0.1
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart( self:GetPos() ) // not sure if we need a start and origin (endpoint) for this effect, but whatever
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetScale( 1 )
	util.Effect( "StunstickImpact", effectdata ) 
end

function ENT:PhysicsCollide( data, phys )
	self:Explode()
end

local cl, owner, phys, distance, relation, forceDir, pos, pos2, mass, dmg

function ENT:Explode()
	if self.BlewUp then
		self:Remove()
		return
	end
	self.BlewUp = true
	owner = self.Owner
	pos = self:GetPos()

	local effectdata = EffectData()
	effectdata:SetStart( pos ) // not sure if we need a start and origin (endpoint) for this effect, but whatever
	effectdata:SetOrigin( pos )
	util.Effect( "Explosion", effectdata)
	sound.Play("weapons/explode" .. math.random(3, 5) .. ".wav", pos, 95, 100, 1)
	
	for k, v in ipairs(ents.FindInSphere(pos, self.Radius)) do
		if IsValid(v) then
			pos2 = v:GetPos()
			distance = pos:Distance(pos2)
			forceDir = ((pos2 - pos):GetNormal() * 500)
			
			if not owner or (owner:IsNPC() and v:IsPlayer()) or (owner:IsPlayer() and v:IsNPC()) then
				dmg = DamageInfo()
				dmg:SetInflictor(self)
				if IsValid(owner) then
					dmg:SetAttacker(owner)
				end
				dmg:SetDamageType(DMG_BLAST)
				dmg:SetDamage((1 - distance / self.Radius) * self.Damage)
				dmg:SetDamageForce(forceDir * 200)
				v:TakeDamageInfo(dmg)
			end
		end
	end
	self:Remove()
end