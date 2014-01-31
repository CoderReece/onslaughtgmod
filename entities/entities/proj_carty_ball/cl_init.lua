include("shared.lua")

function ENT:Initialize()
	self.ParticleTime = CurTime()+0.03
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()		
	local dlight = DynamicLight(self:EntIndex())
		
	if dlight then
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 100
		dlight.Brightness = 2
		dlight.Size = 128
		dlight.Decay = 128 * 3
		dlight.DieTime = CurTime() + 0.1
	end
	if self.ParticleTime < CurTime() then return end
	self:Smoke()
end 

function ENT:Smoke()
	local vOffset = self:GetPos()
	local vPos = VectorRand()*5
	local emitter = ParticleEmitter(vOffset)

	local smoke = emitter:Add("particles/smokey", vOffset + vPos)
			smoke:SetVelocity(vPos)
			smoke:SetDieTime(math.random(0.4,1.2))
			smoke:SetStartAlpha(100)
			smoke:SetEndAlpha(20)
			smoke:SetStartSize(30)
			smoke:SetEndSize(math.Rand(40, 60))
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-0.2,0.2))
			smoke:SetColor(math.random(200,255), math.random(0,150), math.random(0,50),math.random(50,100))
			smoke:SetAirResistance(math.Rand(25, 100))
			smoke:SetBounce(0.5)
			smoke:SetCollide(true)

	local smoke = emitter:Add("particle/particle_smokegrenade", vOffset) // + vPos)
			smoke:SetVelocity(vPos)
			smoke:SetDieTime(0.075)
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(255)
			smoke:SetStartSize(20)
			smoke:SetEndSize(math.Rand(35, 40))
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-0.2,0.2))
			local g = math.random(0,40)
			smoke:SetColor(g, g, g)
			smoke:SetAirResistance(math.Rand(0, 10))
			smoke:SetGravity(Vector(0,0,0))
			smoke:SetBounce(0.5)
			smoke:SetCollide(true)

	emitter:Finish()
end
