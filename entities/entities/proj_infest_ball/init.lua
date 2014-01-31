AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Radius = 50
ENT.Damage = 20
ENT.Reflectable = true

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

function ENT:Explode()
	if self.BlewUp then
		self:Remove()
		return
	end
	self.BlewUp = true
	owner = self.Owner
	pos = self:GetPos()
	
	for k, v in pairs(ents.FindInSphere(pos, self.Radius)) do
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
	self:Remove()
end