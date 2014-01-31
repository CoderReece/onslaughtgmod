AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "proj_grenade_frag"
ENT.Author = "damon"
ENT.Spawnable = false
ENT.AdminSpawnable = false 

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Exploded")
end 

function ENT:OnInitialize()
	self.CreatedTime = CurTime()
	--self:SetModelScale(2,0)
end

function ENT:Detonate()
	self:Explode()
end

function ENT:Explode()
	self:SetExploded(true)

	function self:Think()
		local tab = ents.FindInSphere(self:GetPos(),100)
		for i = 1,#tab do
			local v = tab[i]
			if v:IsPlayer() then
				v:TakeDamage(math.random(2,4),self.Owner,self)
			end
		end
		if self.CreatedTime + 20 < CurTime() then
			self:Remove()
		end
	end
end

function ENT:Draw()
	self:DrawModel()
	if self:GetExploded() then
		self:Smoke()
	end
end

function ENT:Smoke()
	local vOffset = self:GetPos()
	local emitter = ParticleEmitter(vOffset)
	for i = 1,1 do
		local smoke = emitter:Add("particle/particle_smokegrenade", vOffset) // + vPos)
				smoke:SetVelocity(Vector(math.random(-350,350),math.random(-350,350),math.random(-10,10)))
				smoke:SetDieTime(math.random(0.5,0.75))
				smoke:SetStartAlpha(255)
				smoke:SetEndAlpha(255)
				smoke:SetStartSize(50)
				smoke:SetEndSize(math.Rand(40, 75))
				smoke:SetRoll(math.Rand(-180, 180))
				smoke:SetRollDelta(math.Rand(-0.2,0.2))
				smoke:SetColor(math.random(200,255), math.random(0,200), math.random(0,100))
				smoke:SetAirResistance(math.Rand(96, 100))
				smoke:SetBounce(0.5)
				smoke:SetCollide(true)
	end
	emitter:Finish()
end 
