AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Radius = 50
ENT.Damage = 5
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
	if data.HitObject:GetEntity():IsWorld() then
		self:Remove()
	end

	if self.ExplodeOnTouch and data.HitObject:GetEntity():GetClass() != self:GetClass() then
		local owner = self.Owner
		local dmg = DamageInfo()
		dmg:SetInflictor(self)
		if IsValid(owner) then
			dmg:SetAttacker(owner)
		end
				
		dmg:SetDamageType(DMG_DIRECT)
		dmg:SetDamage(1)

		dmg:SetDamageForce(self:GetVelocity() * 200)
		data.HitObject:GetEntity():TakeDamageInfo(dmg)
		return
	end
end