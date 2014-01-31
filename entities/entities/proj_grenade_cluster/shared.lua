AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "proj_grenade_frag"
ENT.Author = "damon"
ENT.Spawnable = false
ENT.AdminSpawnable = false 


ENT.Radius = 100
ENT.Damage = 20 --clusters do damage, not me!
ENT.Spread = 100
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

	local pos = self:GetPos()

	for i = 1,math.random(6,13) do
		local time = math.random(50,400)/100
		print(time)
		local ball = ents.Create("proj_grenade_frag")
		ball:SetPos(pos+Vector(0,0,10)+VectorRand()*4)
		ball.Owner = self
		ball:Spawn()
		ball:SetModelScale(0.6,0)
		math.randomseed(math.random(1,122142112))
		ball:SetTimer(time,time*2)

		local phys = ball:GetPhysicsObject()
		phys:ApplyForceCenter(Vector(math.random(-self.Spread,self.Spread),math.random(-self.Spread,self.Spread),math.random(self.Spread/3,self.Spread))*3)
	end

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "Explosion", effectdata)

	for k, v in ipairs(ents.FindInSphere(pos, self.Radius)) do
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

function ENT:Draw()
	self:DrawModel()
end