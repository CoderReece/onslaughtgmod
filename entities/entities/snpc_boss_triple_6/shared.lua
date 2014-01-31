AddCSLuaFile()
 
ENT.Base			= "snpc_zombie"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "(BOSS) Triple-6"
ENT.Category = "SNPCs"
ENT.Walk = ACT_WALK
ENT.Model = "models/zombie/classic.mdl"

ENT.IdleSpeed = 75*3
ENT.ChaseSpeed = 75*3

ENT.AttackBeforeDamageDelay = 0.75*3
ENT.AttackAfterDamageDelay = 0.85
ENT.Damage = 150
ENT.Range = 130

ENT.NPCHealth = 720

ENT.DealDamageTime = 0
ENT.NextAttackTime = 0

ENT.DeathSound = Sound("Zombie.Die")
ENT.HurtSound = Sound("Zombie.Pain")
ENT.AlertSound = Sound("Zombie.Attack")
ENT.MissSound = Sound("Zombie.AttackMiss")
ENT.HitSound = Sound("Zombie.AttackHit")
ENT.IdleSounds = {Sound("Zombie.Idle")}

ENT.Reincarnations = 0
function ENT:Killed()
	if self.Reincarnations >= 2 then return end
	local ent = ents.Create("snpc_boss_triple_6")
	ent:SetPos(self:GetPos()+VectorRand()*300)
	ent:Spawn()

	ent:StartActivity(ACT_DO_NOT_DISTURB)
	local seq = ent:LookupSequence("canal5aattack")
	ent:ResetSequence(seq)
	timer.Simple(ent:SequenceDuration()+0.1,function()
		ent:StartActivity(ent.Walk)
	end)
	ent.Reincarnations = self.Reincarnations + 1
end

function ENT:BodyUpdate()
 
		local act = self:GetActivity()
		if ( act == ACT_HL2MP_WALK_ZOMBIE_01 ) then
			   self:BodyMoveXY()
		end
		self:FrameAdvance()
 
end

function ENT:SecondInit()
	self:SetColor(Color(255,100,25))
	self:SetModelScale(2,0)
	self.EmitSoundEx = function(ent,sound,vol,pitch)
		vol = vol or 100
		pitch = pitch or 100
		ent:EmitSound(sound,vol,pitch/2)
		ent:EmitSound(sound,vol,pitch/2+10)
		ent:EmitSound(sound,vol,pitch/2+30)
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

ENT.NextExplode = 0
ENT.NextSpawn = 0
ENT.NextSprint = 0
function ENT:RanBehavior()
	if not IsValid(self.Enemy) then return end

	if self.NextSprint < CurTime() then
		self.NextSprint = CurTime()+math.random(30,60)
		self:StartActivity(ACT_DO_NOT_DISTURB)
		sound.Play("npc/zombie/zombie_voice_idle11.wav",self:GetPos(),140,50,1)
		sound.Play("npc/zombie/zombie_voice_idle11.wav",self:GetPos(),140,60,1)
		self:EmitSoundEx("npc/zombie/zombie_pain3.wav")
		self:ResetSequence(self:LookupSequence("physflinch3"))
		coroutine.wait(1.2)
		self:EmitSoundEx("npc/zombie/zombie_pain2.wav")
		self:ResetSequence(self:LookupSequence("physflinch2"))
		coroutine.wait(1.2)
		self:EmitSoundEx("npc/zombie/zombie_pain4.wav")
		self:ResetSequence(self:LookupSequence("physflinch1"))
		coroutine.wait(1.2)

		self:StartActivity(ACT_WALK)
		self.ChaseSpeed = 900
		self.AnimSpeed = 3
		timer.Simple(15,function()
			self.ChaseSpeed = self.IdleSpeed
			self.AnimSpeed = 1
		end)
	end
	if self.NextSpawn <= CurTime() and self.AnimSpeed == 1 then
		self.NextSpawn = CurTime()+math.random(10,20)
		self:StartActivity(ACT_DO_NOT_DISTURB)
		local seq = self:LookupSequence("Tantrum")
		self:ResetSequence(seq)

		local pos = self:GetPos()
		for i = 2,3 do
			timer.Simple(0.4*i,function()
				local ent = ents.Create(table.Random({"snpc_zombie_devil"}))
				ent:SetPos(pos+Vector(math.random(200,300),math.random(200,300),0))
				ent:Spawn()
			end)
		end
		coroutine.wait(2)
		self:SetPlaybackRate(1)
		self:StartActivity(self.Walk)
	end
	local dist = self:GetRangeSquaredTo(self.Enemy)
	if self.NextExplode < CurTime() and dist < 700 and (self.AnimSpeed or 1) == 1 then
		self.NextExplode = CurTime() + math.random(8,14)/3

		self:FaceTowardsAndWait(self.Enemy:GetPos())
		self:EmitSoundEx("npc/zombie_poison/pz_throw3.wav",140,100)
		self:PlaySequenceAndWait("releasecrab")
		self:StartActivity(ACT_DO_NOT_DISTURB)
		local seq = self:LookupSequence("attackE")
		self:ResetSequence(seq)

		coroutine.wait(0.75)
		for i = 1,6 do
			local pos = self:GetPos()
			pos = pos + self:GetRight() * i * 25 + self:GetForward() * i * 85
			local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			util.Effect( "Explosion", effectdata)
			for k, v in pairs(ents.FindInSphere(pos,225)) do
				if IsValid(v) then
					pos2 = v:GetPos()
					distance = pos:Distance(pos2)
					forceDir = ((pos2 - pos):GetNormal() * 500)
					
					if (v:IsPlayer() and v:Health() > 0) then
						dmg = DamageInfo()
						dmg:SetInflictor(self)
						dmg:SetAttacker(self)
						
						dmg:SetDamageType(DMG_BLAST)
						dmg:SetDamage((1 - distance / 225) * 50)
						dmg:SetDamageForce(forceDir * 200)
						v:TakeDamageInfo(dmg)
					end
				end
			end

			local pos = self:GetPos()
			pos = pos + self:GetForward() * i * 85
			local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			util.Effect( "Explosion", effectdata)
			for k, v in pairs(ents.FindInSphere(pos,225)) do
				if IsValid(v) then
					pos2 = v:GetPos()
					distance = pos:Distance(pos2)
					forceDir = ((pos2 - pos):GetNormal() * 500)
					
					if (v:IsPlayer() and v:Health() > 0) then
						dmg = DamageInfo()
						dmg:SetInflictor(self)
						dmg:SetAttacker(self)
						
						dmg:SetDamageType(DMG_BLAST)
						dmg:SetDamage((1 - distance / 225) * 50)
						dmg:SetDamageForce(forceDir * 200)
						v:TakeDamageInfo(dmg)
					end
				end
			end

			local pos = self:GetPos()
			pos = pos + self:GetRight() * i * -25 + self:GetForward() * i * 85
			local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			util.Effect( "Explosion", effectdata)
			for k, v in pairs(ents.FindInSphere(pos,75)) do
				if IsValid(v) then
					pos2 = v:GetPos()
					distance = pos:Distance(pos2)
					forceDir = ((pos2 - pos):GetNormal() * 500)
					
					if (v:IsPlayer() and v:Health() > 0) then
						dmg = DamageInfo()
						dmg:SetInflictor(self)
						dmg:SetAttacker(self)
						
						dmg:SetDamageType(DMG_BLAST)
						dmg:SetDamage((1 - distance / 75) * 50)
						dmg:SetDamageForce(forceDir * 200)
						v:TakeDamageInfo(dmg)
					end
				end
			end
			coroutine.wait(0.09)
		end	
		self:StartActivity(self.Walk)
	end
end