include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()

end

function ENT:Initialize()
	local ED = EffectData( )
	ED:SetEntity(self)
	ED:SetOrigin(self:GetPos())
	util.Effect( "spawnpoint", ED )
	self.snd = CreateSound( self, "k_lab.teleport_rings_high")
	self.snd:Play()
end

function ENT:Remove()
	self.snd:Stop()
end
