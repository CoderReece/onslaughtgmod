AddCSLuaFile()

ENT.Base = "snpc_zombie" 

ENT.PrintName		= "Mother Zombie"
ENT.Category		= "SNPCs"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.Walk = ACT_WALK
ENT.Model = "models/Zombie/Poison.mdl"

ENT.IdleSpeed = 40
ENT.ChaseSpeed = 60

ENT.AttackBeforeDamageDelay = 0.85
ENT.AttackAfterDamageDelay = 1.25
ENT.Damage = 90
ENT.Range = 80

ENT.NPCHealth = 350

ENT.DeathSound = Sound("NPC_PoisonZombie.Die")
ENT.HurtSound = Sound("NPC_PoisonZombie.Pain")

ENT.AlertSound = Sound("NPC_PoisonZombie.Attack")
ENT.MissSound = Sound("NPC_PoisonZombie.AttackMiss")
ENT.HitSound = Sound("NPC_PoisonZombie.AttackHit")
ENT.IdleSounds = {Sound("NPC_PoisonZombie.Idle")}

function ENT:SecondInit()
	self:SetColor(Color(255,100,0))
	self:SetModelScale(1.25,0)
end

ENT.NextRelease = 0
function ENT:RanBehavior()
	if self.NextRelease < CurTime() then
		self.NextRelease = CurTime()+math.random(5,10)

		self:StartActivity(ACT_DO_NOT_DISTURB)
		local seq = self:LookupSequence("ThrowWarning")
		self:ResetSequence(seq)

		coroutine.wait(0.5)

		local fz = ents.Create("snpc_zombie_fast")
		fz:SetPos(self:GetPos()+self:GetForward()*32)
		fz:Spawn()
		fz:SetModelScale(0.4,0)
		fz:SetHealth(20)
		fz:SetCollisionGroup(COLLISION_GROUP_WORLD)

		coroutine.wait(0.75)
		self:StartActivity(ACT_WALK)
	end
end

function ENT:Killed()
	self.Balls = {}

	for i = 1,math.random(3,5) do
		local ball = ents.Create("proj_antfly_dart")
		ball:SetPos(self:GetPos()+Vector(math.random(-50,50),math.random(-50,50),10))
		ball:Spawn()
		ball:SetModel("models/dav0r/hoverball.mdl")
		ball:GetPhysicsObject():SetVelocityInstantaneous(Vector(math.random(-300,300),math.random(-300,300),500))

		self.Balls[i] = ball
	end
	timer.Simple(0.8,function()
		for k,v in ipairs(self.Balls) do
			local fz = ents.Create("snpc_zombie_fast")
			fz:SetPos(v:GetPos())
			v:Remove()
			fz:Spawn()
			fz:SetModelScale(0.4,0)
			fz:SetHealth(20)
		end
		local z = ents.Create("snpc_zombie")
		z:SetPos(self:GetPos())
		z:Spawn()
		z:StartActivity(ACT_DO_NOT_DISTURB)
		local seq = z:LookupSequence("canal5aattack")
		z:ResetSequence(seq)
		timer.Simple(z:SequenceDuration(),function()
			if not IsValid(z) then return end
			z:StartActivity(z.Walk)
		end)
	end)
end