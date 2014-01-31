AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.Model = "models/items/ammocrate_smg1.mdl"
ENT.LastUse = CurTime()
ENT.AutomaticFrameAdvance = true
ENT.LastTouch = 0
ENT.Open = false
ENT.User = nil

function ENT:Close()
	local sequence = self.Entity:LookupSequence("Close")
	self.Entity:ResetSequence(sequence)
	self.Open = false
	self.User = nil
end

function ENT:Use(act, cal)
	if act:KeyDownLast(IN_USE) then return end 
	if !act:IsPlayer() then return end
	//if PHASE == "BUILD" then return end
	if self.Open && self.User != act then
		act:Message(self.User:Nick().." is currently using this ammo bin")
		return
	elseif self.User == act then
		return
	end
	self.User = act
	self.Open = true
	local sequence = self.Entity:LookupSequence("Open")
	self.Entity:ResetSequence(sequence)
	act:Ammo(self)
	self.Entity:EmitSound("items/ammocrate_open.wav",90,100)
	self.LastUse = CurTime()
end

function ENT:Think()
	if self.Open && (!IsValid(self.User) || self.User:Health() < 1) then self:Close() end
end
