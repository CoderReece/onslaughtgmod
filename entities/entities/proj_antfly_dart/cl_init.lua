include("shared.lua")

function ENT:Initialize()
	self:SetMaterial("models/props_foliage/tree_deciduous_01a_trunk")
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()		
	self:Smoke()
end 

function ENT:Smoke()
	local vOffset = self:GetPos()
	local emitter = ParticleEmitter(vOffset)
			
	local smoke = emitter:Add("particle/particle_smokegrenade", vOffset) // + vPos)
			smoke:SetVelocity(self:GetVelocity())
			smoke:SetDieTime(math.random(0.1,0.2))
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(255)
			smoke:SetStartSize(5)
			smoke:SetEndSize(math.Rand(3, 6))
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-0.2,0.2))
			smoke:SetColor(math.random(0,100), math.random(200,255), math.random(0,200))
			smoke:SetAirResistance(math.Rand(50, 100))
			smoke:SetBounce(0.5)
			smoke:SetCollide(true)
	emitter:Finish()
end
