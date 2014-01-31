AddCSLuaFile()
 
ENT.Base			= "snpc_zombie"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "(BOSS) Infestor"
ENT.Category = "SNPCs"
ENT.Walk = ACT_HL2MP_WALK_ZOMBIE_01
ENT.Model = "models/player/zombie_classic.mdl"

ENT.IdleSpeed = 200
ENT.ChaseSpeed = 200

ENT.AttackBeforeDamageDelay = 0.05
ENT.AttackAfterDamageDelay = 0.4
ENT.Damage = 5
ENT.Range = 130

ENT.NPCHealth = 3000

ENT.DealDamageTime = 0
ENT.NextAttackTime = 0

ENT.DeathSound = Sound("Zombie.Die")
ENT.HurtSound = Sound("Zombie.Pain")
ENT.AlertSound = Sound("Zombie.Attack")
ENT.MissSound = Sound("Zombie.AttackMiss")
ENT.HitSound = Sound("Zombie.AttackHit")
ENT.IdleSounds = {Sound("Zombie.Idle")}

function ENT:BodyUpdate()
 
		local act = self:GetActivity()
		if ( act == ACT_HL2MP_WALK_ZOMBIE_01 ) then
			   self:BodyMoveXY()
		end
		self:FrameAdvance()
 
end

function ENT:SecondInit()
	self:SetColor(Color(0,255,0))
	self:SetModelScale(2,0)
end
function ENT:RunBehaviour()
	while ( true ) do
		if self.Damaging and self.DealDamageTime <= CurTime() then
			self.Damaging = false
			self:DealDamage(self.Enemy) --leave hitsounds/misssounds to dealdamage
		end

		self:StartActivity( self.Walk )
		if math.random(1,2000) <= 2 then
			local sound = self.IdleSounds
			while type(sound) == "table" do
				sound = table.Random(sound)
			end
			self:EmitSoundEx(sound,140,100)
		end
		self.WalkSpeed=self.ChaseSpeed

		self.loco:SetDesiredSpeed( self.WalkSpeed )

		if (self.NextCheckEnemy or 0) < CurTime() then
			self.NextCheckEnemy = CurTime()+3
			self:FindTarget()
		end
			
		if IsValid(self.Enemy) and not self.Idling then
			self.loco:FaceTowards(self.Enemy:GetPos())
			if self:ShouldChase(self.Enemy) then

				local maxageScaled=0.5--math.Clamp(self.Enemy:GetPos():DistToSqr(self:GetPos())/(1000*1000),0.1,3)
				self:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled,repath=1})

				if self:EnemyInRange() and self.NextAttackTime <= CurTime() then
					self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
					self:EmitSoundEx(self.AlertSound,140,200)
					self.Damaging = true
					self.DealDamageTime = CurTime()+self.AttackBeforeDamageDelay
					self.NextAttackTime = CurTime()+self.AttackAfterDamageDelay
				end
			end
		end	
		self:RanBehavior()
		coroutine.yield()
	end
end

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
ENT.NextSpawn = 0
function ENT:RanBehavior()
	if not IsValid(self.Enemy) then return end
	if self.NextSpawn <= CurTime() then
		self.NextSpawn = CurTime()+math.random(10,20)
		self:StartActivity(ACT_HL2MP_IDLE_ZOMBIE)
		self:RestartGesture(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)

		local pos = self:GetPos()
		for i = 4,8 do
			timer.Simple(0.4*i,function()
				local ent = ents.Create(table.Random({"snpc_zombie","snpc_zombie_fast","snpc_zombie_poison","snpc_zombie_runner","snpc_zombie_devil"}))
				ent:SetPos(pos+Vector(math.random(100,200)))
				ent:Spawn()
			end)
		end
		coroutine.wait(2)
	end
	if self.NextFire <= CurTime() then
		self.NextFire = CurTime()+math.random(3,5)
		if not IsValid(self.Enemy) then return end
		self:FaceTowardsAndWait(self.Enemy:GetPos())
		self:StartActivity(ACT_DO_NOT_DISTURB)

		local seq = self:LookupSequence("swatleftlow")
		self:SetSequence(seq)

		local boneid = self:LookupBone("ValveBiped.Bip01_R_Hand")
		for i = 1,3 do
			local pos = self:GetBonePosition(boneid)
			local ball = ents.Create("proj_infest_bomb")
			ball:SetCustomCollisionCheck(true)
			ball:SetPos(pos)
			ball:SetParent(self)
			ball.Owner = self
			ball:Spawn()
			timer.Create("FIXBallPos"..ball:EntIndex(),0.5/20,20,function()
				ball:SetLocalPos(self:WorldToLocal(self:GetBonePosition(boneid)))
			end)
			timer.Simple(0.4+(i*0.2),function()
				ball:SetParent(nil)
				ball:SetPos(self:GetBonePosition(boneid))
				local phys = ball:GetPhysicsObject()
				local v = GetTrajectoryVelocity(pos,self.Enemy:GetPos(),1+i*0.333,Vector(0,0,-800))
				phys:SetVelocityInstantaneous(v+VectorRand()*math.random(-100,100))
			end)
		end
		coroutine.wait(1.75)
		self:StartActivity(ACT_WALK)
	end
end