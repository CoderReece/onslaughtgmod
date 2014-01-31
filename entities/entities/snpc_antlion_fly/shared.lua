AddCSLuaFile()
 
ENT.Base			= "snpc_antlion"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Giant Fly"
ENT.Category = "SNPCs"
ENT.Walk = ACT_GLIDE
ENT.Model = "models/antlion.mdl"

ENT.IdleSpeed = 400
ENT.ChaseSpeed = 400

ENT.AttackBeforeDamageDelay = 0.75
ENT.AttackAfterDamageDelay = 0.25
ENT.Damage = 12
ENT.Range = 0

ENT.NPCHealth = 25
ENT.JumpChance = 1

function ENT:SecondInit()
	self:SetColor(Color(100,100,100))
	self.JumpChance = 99
end

function ENT:RanBehavior()
	if self.Enemy:GetPos():DistToSqr(self:GetPos()) < (400*400) and not self:EnemyInRange() then
		self:EmitSound("npc/barnacle/barnacle_crunch2.wav",70,150)
		self:StartActivity(ACT_MELEE_ATTACK1)
		local ball = ents.Create("proj_antfly_dart")
		local dir = (self.Enemy:GetPos()+Vector(0,0,50) - self:EyePos()):GetNormal()
		ball:SetPos(self:EyePos()+dir*20)
		ball:SetAngles(ball:GetPos():AngleEx(self.Enemy:GetPos()+Vector(0,0,50)))
		ball.Owner = self
		ball:Spawn()
		local phys = ball:GetPhysicsObject()
		phys:SetVelocityInstantaneous(dir*1000)
		phys:EnableGravity(false)
		phys:SetMass(1)
		coroutine.wait(0.15)
	end
	if self.Enemy:GetPos():DistToSqr(self:GetPos()) > (400*400) then
		self:StartActivity(ACT_GLIDE)
	end
end