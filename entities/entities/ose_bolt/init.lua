AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.Owner = nil
ENT.Touched = 0

function ENT:Initialize()   
	self.Entity:SetModel("models/crossbow_bolt.mdl")
	self:PhysicsInit(SOLD_BBOX)
	self:SetSolid( SOLID_BBOX )
	self:SetSkin(2)
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetGravity( 0.05 )
	local trail = util.SpriteTrail(self, 0, Color(100,100,100), false, 5, 1, 4, 1/(15+1)*0.5, "trails/smoke.vmt")
	timer.Simple(10,function() if not IsValid(self) then return end self:Remove() end)
end

function ENT:Touch(ent)
	if self.Touched > 15 then self:Remove() end
	local class = ent:GetClass()
	if ent:IsNPC() then
		ent:TakeDamage( 100, self:GetOwner(), self:GetOwner())
		self:Remove()
		self.Touched = self.Touched + 1
	elseif class == "sent_prop"|| class == "sent_ladder"|| class == "sent_ammo_dispenser" then
		self.Touched = self.Touched + 1
	end
end

function ENT:Think()
end

function ENT:Use()
	return false
end

function ENT:PhysicsCollide(data)
end

function ENT:OnRemove()
end

