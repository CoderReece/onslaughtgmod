AddCSLuaFile()

ENT.Base = "snpc_zombie" 

ENT.PrintName		= "Explosive Devil"
ENT.Category		= "SNPCs"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.Walk = ACT_WALK
ENT.Model = "models/Zombie/Classic.mdl"

ENT.IdleSpeed = 75
ENT.ChaseSpeed = 75

ENT.AttackBeforeDamageDelay = 0.85
ENT.AttackAfterDamageDelay = 0.75 --low for a reason; see below.
ENT.Damage = 50
ENT.Range = 100

ENT.NPCHealth = 240

local pref = "npc/zombie_poison/pz_"
ENT.DeathSound = Sound(pref.."die1.wav")
ENT.HurtSound = Sound(pref.."pain3.wav")

ENT.AlertSound = Sound(pref.."warn2.wav")
ENT.MissSound = Sound("NPC_PoisonZombie.AttackMiss")
ENT.HitSound = Sound("NPC_PoisonZombie.AttackHit")
ENT.IdleSounds = {Sound(pref.."idle2.wav"),Sound(pref.."idle3.wav"),Sound(pref.."idle4.wav"),}

function ENT:SecondInit()
	self:SetBodygroup(1,0)
	self:SetColor(Color(255,0,0))
	self:SetModelScale(1.5,0)

	self.Spread = 10

	self.EmitSoundEx = function(ent,sound,vol,pitch)
		vol = vol or 100
		pitch = pitch or 100
		ent:EmitSound(sound,vol,pitch/2)
		ent:EmitSound(sound,vol,pitch/2+10)
	end
end


ENT.AutomaticFrameAdvance = true 

ENT.Spread = 10
ENT.NextSprint = 0
ENT.NextExplode = 0
function ENT:RanBehavior()
	if not IsValid(self.Enemy) then return end
	local dist = self.Enemy:GetPos():DistToSqr(self:GetPos())
	if self.NextExplode < CurTime() and dist < (400 * 400) and self.AnimSpeed == 1 then
		self.NextExplode = CurTime() + math.random(8,14)

		self:FaceTowardsAndWait(self.Enemy:GetPos())
		self:EmitSoundEx("npc/zombie_poison/pz_throw3.wav",140,100)
		self:PlaySequenceAndWait("releasecrab")
		self:StartActivity(ACT_DO_NOT_DISTURB)
		local seq = self:LookupSequence("attackE")
		self:SetSequence(seq)

		coroutine.wait(0.75)
		for i = 1,6 do
			local pos = self:GetPos() + (self:GetForward() * (50 * i)) + self:GetRight()*math.random(-100,100)
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
		self:StartActivity(ACT_WALK)
	elseif self.NextSprint < CurTime() then
		self.NextSprint = CurTime()+math.random(10,20)
		self:StartActivity(ACT_DO_NOT_DISTURB)
		sound.Play("npc/zombie/zombie_voice_idle11.wav",self:GetPos(),140,50,1)
		sound.Play("npc/zombie/zombie_voice_idle11.wav",self:GetPos(),140,60,1)
		self:EmitSoundEx("npc/zombie/zombie_pain3.wav")
		self:ResetSequence(self:LookupSequence("physflinch3"))
		coroutine.wait(0.4)
		self:EmitSoundEx("npc/zombie/zombie_pain2.wav")
		self:ResetSequence(self:LookupSequence("physflinch2"))
		coroutine.wait(0.4)
		self:EmitSoundEx("npc/zombie/zombie_pain4.wav")
		self:ResetSequence(self:LookupSequence("physflinch1"))
		coroutine.wait(0.4)

		self:StartActivity(ACT_WALK)
		self.ChaseSpeed = 300
		self.AnimSpeed = 3
		timer.Simple(5,function()
			self.ChaseSpeed = self.IdleSpeed
			self.AnimSpeed = 1
		end)
	--[[elseif self.NextFire < CurTime() and dist < (1000*1000) then
		self.NextFire = CurTime()+math.random(3,5)

		self:FaceTowardsAndWait(self.Enemy:GetPos())
		self:StartActivity(ACT_DO_NOT_DISTURB)
		--local seq = self:LookupSequence("Breakthrough")
		local seq = self:LookupSequence("swatleftlow")
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
		timer.Create("FIXBallPos"..ball:EntIndex(),0.5/20,20,function()
			ball:SetLocalPos(self:WorldToLocal(self:GetBonePosition(boneid)))
		end)
		timer.Simple(0.6,function()
			ball:SetParent(nil)
			ball:SetPos(self:GetBonePosition(boneid))
			local phys = ball:GetPhysicsObject()
			local v = GetTrajectoryVelocity(pos,self.Enemy:GetPos(),1.25,Vector(0,0,-800))
			phys:SetVelocityInstantaneous(v+VectorRand()*math.random(-100,100))
		end)]]
		--[[local max = math.random(10,15)*2
		for i = 1,max do
			timer.Simple(0.2+(0.025*i)/2,function()
				if not IsValid(self) then return end
				local pos = self:GetBonePosition(boneid)
				local ball = ents.Create("proj_cflamer_ball")
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
			timer.Simple(1.025+(0.025*i)/2,function()
				if not IsValid(self) then return end
				local pos = self:GetBonePosition(boneid)
				local ball = ents.Create("proj_cflamer_ball")
				ball:SetPos(pos)
				ball.Owner = self
				ball:SetCustomCollisionCheck(true)
				ball:Spawn()
				local phys = ball:GetPhysicsObject()
				phys:EnableGravity(false)
				phys:ApplyForceCenter(self:GetForward() * 1500 + Vector(math.random(-self.Spread,self.Spread),math.random(-self.Spread,self.Spread),math.random(-self.Spread,self.Spread)))
				if i == max then
					self:ResetSequenceInfo()
				end
			end)
		end]]

		--[[self:EmitSoundEx("npc/zombie_poison/pz_warn1.wav")
		coroutine.wait(1.25)
		--self:EmitSoundEx("npc/zombie_poison/pz_warn2.wav")
		--coroutine.wait(0.35 + (0.025*max))
		self:StartActivity(ACT_WALK)]]
	end
end