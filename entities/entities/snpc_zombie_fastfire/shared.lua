AddCSLuaFile()
 
ENT.Base			= "snpc_zombie"

ENT.PrintName = "Fiery Fastie"
ENT.Category = "SNPCs"

ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.Walk = ACT_RUN
ENT.Model = "models/Zombie/Fast.mdl"

ENT.IdleSpeed = 65
ENT.ChaseSpeed = 190

ENT.AttackBeforeDamageDelay = 0.1
ENT.AttackAfterDamageDelay = 0.5 --low for a reason; see below.
ENT.Damage = 1
ENT.Range = 70

ENT.NPCHealth = 25

ENT.DeathSound = Sound("NPC_FastZombie.Die")
ENT.HurtSound = Sound("NPC_FastZombie.Pain")

ENT.AlertSound = Sound("NPC_FastZombie.Attack")
ENT.MissSound = Sound("NPC_FastZombie.AttackMiss")
ENT.HitSound = Sound("NPC_FastZombie.AttackHit")
ENT.IdleSounds = {Sound("NPC_FastZombie.Idle")}

function ENT:SecondInit()
	self:SetColor(Color(255,150,0))
	self:SetModelScale(1.15,0)
end

function ENT:DealDamage(ent) --simulate swips
	local i = 0
	while i < 5 do
		if not (self:Alive() and self:EnemyInRange()) then break end
		i = i + 1
		local dmginfo=DamageInfo()	
			dmginfo:SetDamagePosition(self:GetPos()+Vector(0,0,50))
			dmginfo:SetDamage(math.random(3,4))
			dmginfo:SetDamageType(DMG_CLUB)
			dmginfo:SetAttacker(self)
		self.Enemy:TakeDamageInfo(dmginfo)

		local moveAdd=Vector(0,0,10)
		if not self.Enemy:IsOnGround() then
			moveAdd=Vector(0,0,0)
		end
		self.Enemy:SetVelocity(moveAdd+((self.Enemy:GetPos()-self:GetPos()):GetNormal()*100))
		coroutine.wait(0.25)
	end
	coroutine.wait(0.5)
end

function ENT:RanBehavior()
	if self.Enemy:GetPos():DistToSqr(self:GetPos()) < (150 * 150) then
		self:StartActivity(ACT_DO_NOT_DISTURB)
		local seq = self:LookupSequence("BR2_Roar")
		self:ResetSequence(seq)
		coroutine.wait(1.3)
		local seq = self:LookupSequence("BR2_Attack")
		self:ResetSequence(seq)
		coroutine.wait(0.8)
		for i = 1,4 do
			--math.randomseed(math.random(1,1000000000))
			local pos = self:GetPos() + (Vector(math.random(-75,75),math.random(-75,75),math.random(-1,1)) * (i-0.5))
			local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			util.Effect( "Explosion", effectdata)

			for k, v in pairs(ents.FindInSphere(pos,200)) do
				if IsValid(v) then
					pos2 = v:GetPos()
					distance = pos:Distance(pos2)
					forceDir = ((pos2 - pos):GetNormal() * 500)
					
					if (v:IsPlayer() and v:Health() > 0) then
						dmg = DamageInfo()
						dmg:SetInflictor(self)
						dmg:SetAttacker(self)
						
						dmg:SetDamageType(DMG_BLAST)
						dmg:SetDamage((1 - distance / 230) * 50)
						dmg:SetDamageForce(forceDir * 200)
						v:TakeDamageInfo(dmg)
					end
				end
			end
			--coroutine.wait(0.01)
		end
		self:StartActivity(ACT_RUN)
		--self:Remove()
		return
	end
	if self.Enemy:GetPos():DistToSqr(self:GetPos()) < (400*400) and not self:EnemyInRange() then
		self:StartActivity(ACT_MELEE_ATTACK1)
		self:EmitSound("NPC_FastZombie.AttackMiss")
		local ball = ents.Create("proj_fieryf_ball")
		local dir = (self.Enemy:GetPos()+Vector(0,0,60) - self:EyePos()):GetNormal()
		ball:SetPos(self:EyePos()+dir*20)
		ball.Owner = self
		ball:Spawn()
		local phys = ball:GetPhysicsObject()
		phys:SetVelocityInstantaneous(dir*1500)
		phys:SetMass(1)
		coroutine.wait(0.1)
	end
	if self.Enemy:GetPos():DistToSqr(self:GetPos()) > (400*400) then
		self:StartActivity(ACT_RUN)
	end
end