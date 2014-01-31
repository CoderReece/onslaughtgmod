SWEP.Ghost 				= nil
SWEP.PrintName = "Prop Spawner"
SWEP.Slot = 0
include('shared.lua')
function SWEP:OnRemove()
	if IsValid(self:GetDTEntity(0)) then
		self:GetDTEntity(0):Remove()
	elseif IsValid(self.Ghost) then
		self.Ghost:Remove()
	end
end

function SWEP:Holster()
	if IsValid(self:GetDTEntity(0)) then
		self:GetDTEntity(0):Remove()
	elseif IsValid(self.Ghost) then
		self.Ghost:Remove()
	end
end

function SWEP:AdjustMouseSensitivity()
	if self.IsRotating==true then
		return 0
	end
	return 1
end
