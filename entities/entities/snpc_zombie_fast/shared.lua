AddCSLuaFile()
 
ENT.Base			= "snpc_zombie"

ENT.PrintName = "Fast Zombie"
ENT.Category = "SNPCs"

ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.Walk = ACT_RUN
ENT.Model = "models/Zombie/Fast.mdl"

ENT.IdleSpeed = 65
ENT.ChaseSpeed = 225

ENT.AttackBeforeDamageDelay = 0.1
ENT.AttackAfterDamageDelay = 0.5 --low for a reason; see below.
ENT.Damage = 4
ENT.Range = 58

ENT.NPCHealth = 35

ENT.DeathSound = Sound("NPC_FastZombie.Die")
ENT.HurtSound = Sound("NPC_FastZombie.Pain")

ENT.AlertSound = Sound("NPC_FastZombie.Attack")
ENT.MissSound = Sound("NPC_FastZombie.AttackMiss")
ENT.HitSound = Sound("NPC_FastZombie.AttackHit")
ENT.IdleSounds = {Sound("NPC_FastZombie.Idle")}

function ENT:DealDamage(ent) --simulate swips
	local i = 0
	while i < 5 do
		if not (self:Alive() and self:EnemyInRange()) then break end
		i = i + 1
		local dmginfo=DamageInfo()	
			dmginfo:SetDamagePosition(self:GetPos()+Vector(0,0,50))
			dmginfo:SetDamage(self.Damage)
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
