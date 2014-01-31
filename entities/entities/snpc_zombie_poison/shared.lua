AddCSLuaFile()

ENT.Base = "snpc_zombie" 

ENT.PrintName		= "Poison Zombie"
ENT.Category		= "SNPCs"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.Walk = ACT_WALK
ENT.Model = "models/Zombie/Poison.mdl"

ENT.IdleSpeed = 55
ENT.ChaseSpeed = 55

ENT.AttackBeforeDamageDelay = 0.85
ENT.AttackAfterDamageDelay = 0.75 --low for a reason; see below.
ENT.Damage = 25
ENT.Range = 65

ENT.NPCHealth = 100

ENT.DeathSound = Sound("NPC_PoisonZombie.Die")
ENT.HurtSound = Sound("NPC_PoisonZombie.Pain")

ENT.AlertSound = Sound("NPC_PoisonZombie.Attack")
ENT.MissSound = Sound("NPC_PoisonZombie.AttackMiss")
ENT.HitSound = Sound("NPC_PoisonZombie.AttackHit")
ENT.IdleSounds = {Sound("NPC_PoisonZombie.Idle")}

local function GetTrajectoryVelocity(startingPosition, targetPosition, lob, gravity)

	local physicsTimestep = 1/66
	local timestepsPerSecond = 66
 
	local n = lob * timestepsPerSecond;
 
	local a = physicsTimestep * physicsTimestep * gravity;
	local p = targetPosition;
	local s = startingPosition;
 
	local velocity = (s + (((n * n + n) * a) / 2) - p) * -1 / n

	//This will give us velocity per timestep. The physics engine expects velocity in terms of meters per second
	velocity = velocity / physicsTimestep;
	return velocity;
end

ENT.NextFire = 0
ENT.Spread = 10
function ENT:RanBehavior()
	if not IsValid(self.Enemy) then return end
	local dist = self:GetRangeSquaredTo(self.Enemy)
	if self.NextFire < CurTime() and dist < 2500 then
		self.NextFire = CurTime()+math.random(3,5)
		self:FaceTowardsAndWait(self.Enemy:GetPos())
		self:StartActivity(ACT_DO_NOT_DISTURB)
		--local seq = self:LookupSequence("Breakthrough")
		local seq = self:LookupSequence("Throw")
		self:SetSequence(seq)

		local boneid = self:LookupBone("ValveBiped.Bip01_R_Hand")

		local max = math.random(10,15)*2
		for i = 1,max do
			timer.Simple((0.5/20*50)+(0.025*i)/2,function()
				if not IsValid(self) then return end
				local pos = self:GetBonePosition(boneid)
				local ball = ents.Create("proj_infest_ball")
				ball:SetCustomCollisionCheck(true)
				ball:SetPos(pos)
				ball.Owner = self
				ball:Spawn()
				local phys = ball:GetPhysicsObject()
				phys:EnableGravity(false)
				phys:ApplyForceCenter(self:GetForward() * 1500 + Vector(math.random(-self.Spread,self.Spread),math.random(-self.Spread,self.Spread),math.random(-self.Spread,self.Spread)))
				if i == max then
					self:ResetSequenceInfo()
				end
			end)
		end
		coroutine.wait(self:SequenceDuration())
		self:StartActivity(self.Walk)
--[[
		self:FaceTowardsAndWait(self.Enemy:GetPos())
		self:StartActivity(ACT_DO_NOT_DISTURB)
		--local seq = self:LookupSequence("Breakthrough")
		local seq = self:LookupSequence("Throw")
		self:SetSequence(seq)
		--coroutine.wait(0.7)

		local boneid = self:LookupBone("ValveBiped.Bip01_R_Hand")
		local pos = self:GetBonePosition(boneid)
		local ball = ents.Create("proj_devil_bomb")
		ball:SetCustomCollisionCheck(true)
		ball:SetPos(pos)
		ball:SetParent(self)
		ball.Owner = self
		ball:Spawn()
		timer.Create("FIXBallPos"..ball:EntIndex(),0.5/20,100,function()
			ball:SetLocalPos(self:WorldToLocal(self:GetBonePosition(boneid)))
		end)
		timer.Simple(0.5/20*50,function()
			ball:SetParent(nil)
			ball:SetPos(self:GetBonePosition(boneid))
			local phys = ball:GetPhysicsObject()
			local v = GetTrajectoryVelocity(pos,self.Enemy:GetPos(),1.25,Vector(0,0,-800))
			phys:SetVelocityInstantaneous(v+VectorRand()*math.random(-100,100))
		end)

		coroutine.wait(self:SequenceDuration())
		self:StartActivity(self.Walk)]]
	end
end