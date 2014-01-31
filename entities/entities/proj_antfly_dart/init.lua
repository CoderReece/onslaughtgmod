AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Radius = 50
ENT.Damage = 5
ENT.Reflectable = true

function ENT:Initialize()
	self:SetModel("models/props_c17/FurnitureDrawer001a_Shard01.mdl") 
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
	if self.CreateTime+1 < CurTime() then
		self:Remove()
	end
end

ENT.ExplodeOnTouch = true

function ENT:PhysicsCollide( data, phys )
	if self.ExplodeOnTouch and data.HitObject:GetEntity():GetClass() != self:GetClass() then
		self.ExplodeOnTouch = false
		local owner = self.Owner
		local dmg = DamageInfo()
		dmg:SetInflictor(self)
		if IsValid(owner) then
			dmg:SetAttacker(owner)
		end
				
		dmg:SetDamageType(1)
		dmg:SetDamage(math.random(1,2))

		data.HitObject:GetEntity():TakeDamageInfo(dmg)
	end
	self:Remove()
end