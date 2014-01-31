AddCSLuaFile()
 
ENT.Base			= "snpc_zombie"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Runner Zombie"
ENT.Category = "SNPCs"
ENT.Walk = ACT_HL2MP_RUN_ZOMBIE
ENT.Model = "models/player/zombie_classic.mdl"

ENT.IdleSpeed = 200
ENT.ChaseSpeed = 200

ENT.AttackBeforeDamageDelay = 0.4
ENT.AttackAfterDamageDelay = 0.8
ENT.Damage = 5
ENT.Range = 90

ENT.NPCHealth = 65

ENT.DealDamageTime = 0
ENT.NextAttackTime = 0

ENT.DeathSound = Sound("Zombie.Die")
ENT.HurtSound = Sound("Zombie.Pain")
ENT.AlertSound = Sound("Zombie.Attack")
ENT.MissSound = Sound("Zombie.AttackMiss")
ENT.HitSound = Sound("Zombie.AttackHit")
ENT.IdleSounds = Sound("Zombie.Idle")

function ENT:BodyUpdate()
 
        local act = self:GetActivity()
        if ( act == ACT_HL2MP_RUN_ZOMBIE ) then
                self:BodyMoveXY()
        end
        self:FrameAdvance()
 
end

function ENT:SecondInit()
	self.EmitSoundEx = function(ent,sound,vol,pitch)
		vol = vol or 100
		pitch = pitch or 100
		ent:EmitSound(sound,vol,125)
	end
end
function ENT:RunBehaviour()
	while ( true ) do
		if self.Damaging and self.DealDamageTime <= CurTime() then
			self.Damaging = false
			self:DealDamage(self.Enemy) --leave hitsounds/misssounds to dealdamage
		end

		self:StartActivity( self.Walk )
		if math.random(1,2000) <= 2 then
			self:EmitSoundEx(self.IdleSounds,140,100)
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
					self:EmitSoundEx("npc/zombie/zombie_alert"..math.random(1,3)..".wav",140,200)
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

function ENT:RanBehavior()
	--override
end