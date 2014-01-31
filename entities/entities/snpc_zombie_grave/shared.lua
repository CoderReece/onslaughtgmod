AddCSLuaFile()

ENT.Base = "snpc_zombie" 

ENT.PrintName		= "Grave Digger"
ENT.Category		= "SNPCs"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.Walk = ACT_WALK
ENT.Model = "models/Zombie/Poison.mdl"

ENT.IdleSpeed = 40
ENT.ChaseSpeed = 60

ENT.AttackBeforeDamageDelay = 0.85
ENT.AttackAfterDamageDelay = 1.25
ENT.Damage = 45
ENT.Range = 50

ENT.NPCHealth = 60

ENT.DeathSound = Sound("NPC_PoisonZombie.Die")
ENT.HurtSound = Sound("NPC_PoisonZombie.Pain")

ENT.AlertSound = Sound("NPC_PoisonZombie.Attack")
ENT.MissSound = Sound("NPC_PoisonZombie.AttackMiss")
ENT.HitSound = Sound("NPC_PoisonZombie.AttackHit")
ENT.IdleSounds = {Sound("NPC_PoisonZombie.Idle")}

ENT.DontRevive = true

function ENT:SecondInit()
	self:SetColor(Color(0,100,255))
	self:SetModelScale(0.8,0)
	self.DiedPositions = {}
	self.DeadPosTarget = nil
	self.DeadPosEntity = nil
end 

ENT.NextRevive = 0
function ENT:RanBehavior()
	if #self.DiedPositions < 1 then return end
	if self.DeadPosTarget then
		self.Idling = true
		self.Enemy = nil
		if self:GetRangeSquaredTo(self.DeadPosTarget) < 300 then
			self:EmitSoundEx("npc/zombie_poison/pz_call1.wav",100,150)
			self:PlaySequenceAndWait("releasecrab")

			local zombie = ents.Create(self.DeadPosEntity)
			zombie:SetPos(self.DeadPosTarget)
			zombie:Spawn()

			self.DeadPosTarget = nil
			self.Idling = false
		else
			self:MoveToPos(self.DeadPosTarget,{maxage=0.5,repath=1})
		end
		return
	end

	self:StartActivity(ACT_WALK)

	local dist = 999999999999999
	local target = nil
	local idx = 0
	for k,v in pairs(self.DiedPositions) do
		if self:GetRangeSquaredTo(v.pos) < dist then
			target = v
			dist = self:GetRangeSquaredTo(v.pos)
			idx = k
		end
	end
	if idx != 0 then
		self.DeadPosTarget = target.pos
		self.DeadPosEntity = target.ent
		self.DiedPositions[idx] = nil
	end
end