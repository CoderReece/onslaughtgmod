AddCSLuaFile()
 
ENT.Base			= "snpc_police"

ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Combine Ace"
ENT.Category = "SNPCs"
ENT.Walk = ACT_RUN_AIM_RIFLE
ENT.Model = "models/combine_soldier.mdl"

ENT.IdleSpeed = 185
ENT.ChaseSpeed = 185

ENT.NPCHealth = 150
ENT.StartBodyGroup = 0

ENT.DeathSound = Sound("NPC_MetroPolice.Die")
ENT.HurtSound = Sound("NPC_MetroPolice.Pain")
ENT.AlertSound = Sound("NPC_MetroPolice.Attack")
ENT.MissSound = Sound("NPC_MetroPolice.AttackMiss")
ENT.HitSound = Sound("NPC_MetroPolice.AttackHit")
ENT.IdleSounds = {Sound("NPC_MetroPolice.Idle")}

function ENT:GetGuns()
	return {"combine_ar2","combine_shotgun"}
end

function ENT:SetUpTrails(blurarm,bigblur)
	if IsValid(self.Trail) then
		self.Trail:Remove()
	end
	if IsValid(self.Trail2) then
		self.Trail2:Remove()
	end
	if IsValid(self.Trail3) then
		self.Trail3:Remove()
	end
	if IsValid(self.Trail4) then
		self.Trail4:Remove()
	end
	if blurarm then
		self.Trail2 = util.SpriteTrail( self, self:LookupAttachment("anim_attachment_RH"), Color(255,0,0),false, 5, 2, 1, 1/7*0.5, "trails/tube.vmt" )
		self.Trail3 = util.SpriteTrail( self, self:LookupAttachment("anim_attachment_LH"), Color(255,0,0),false, 5, 2, 1, 1/7*0.5, "trails/tube.vmt" )
	end
	if bigblur then
		self.Trail4 = util.SpriteTrail( self, self:LookupAttachment("beam_damage"), Color(255,0,0),false, 40, 7, 4, 1/47*0.5, "trails/tube.vmt" )
	end
	self.Trail = util.SpriteTrail( self, self:LookupAttachment("eyes"), Color(255,0,0),false, 10, 3,5, 1/13*0.5, "trails/laser.vmt" )
end

function ENT:SecondInit()
	self.WeaponData = {
		["combine_ar2"] = {sound=Sound("Weapon_AR2.Single"),		damage=6,delay=0.15,cone=0.125,range=800,type="AR2Tracer",	act=ACT_RANGE_ATTACK_AR2,		actm=ACT_RUN_AIM_RIFLE,		gest=ACT_GESTURE_RANGE_ATTACK_AR2},
		["combine_shotgun"] = {sound=Sound("Weapon_Shotgun.Single"),damage=5,delay=1,	cone=0.195,	range=350,bullets=8,		act=ACT_RANGE_ATTACK_SHOTGUN,	actm=ACT_RUN_AIM_SHOTGUN,	gest=ACT_GESTURE_RANGE_ATTACK_SHOTGUN},
	}
	self.MoveAndShoot = true
	self:SetPlaybackRate(2)
	self:SetModel("models/combine_super_soldier.mdl")

	self:SetColor(Color(100,100,100))
	self:SetRenderMode(1)
	--[[local ent = ents.Create("prop_dynamic")
	ent:SetPos(att.Pos)
	ent:SetModel("models/dav0r/hoverball.mdl")
	ent:Spawn()
	ent:FollowBone(self,self:LookupBone("ValveBiped.Bip01_Head1"))]]
	--self.Trail = util.SpriteTrail( ent, 1, Color(255,0,0),false, 1, 1, 1, 0.25, "trails/laser" )
	self:SetUpTrails(true)
	self:StartActivity(self.Walk)
end

function ENT:OnInjured(dmginfo) 
	if dmginfo:GetAttacker() and not dmginfo:GetAttacker():IsPlayer() then
		dmginfo:SetDamage(0)
		return
	end
		
	self.Idling=false
	if math.random(1,2) == 1 then
		self:EmitSound(self.HurtSound)
	end
	self:Injured(dmginfo)

	if self.MovingAce then
		if math.random(1,100) <= 65 then return end
		self:SetMaterial("models/props_combine/com_shield001a")
		self.DisableShield = CurTime()+0.24
		timer.Simple(0.25,function()
			if IsValid(self) and self.DisableShield < CurTime() then
				self:SetMaterial("")
			end
		end)
		self:EmitSound("weapons/irifle/irifle_fire2.wav",80,175)
		dmginfo:SetDamage(0)
		return
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

function ENT:GetFireDelay()
	return self.BaseClass.GetFireDelay(self) / 1.35
end

ENT.RecalcWhileAce = true
function ENT:MoveToPos( pos, options )
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300000000 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos or self:GetEnemy():GetPos() )
	--path:Chase(self,self:GetEnemy())
	self:StartActivity(self.Walk)
	while ( path:IsValid() ) and IsValid(self) do
		if self:EnemyInRange() then
			if not self.RecalcWhileAce then --enemy in range, stop preventing recalc
				self.RecalcWhileAce = true
			end
			self:AimAndFire()
		elseif self.MovingAce then
			if not self:EnemyInRange() and self.RecalcWhileAce then --attempt to get in range of our target
				self.RecalcWhileAce = false						--if we get out of range
				self:MoveToPos(self.Enemy:GetPos(),options)
				return "timeout"
			end
			self.ChaseSpeed = 235
			self.loco:SetDesiredSpeed(235)
			self.loco:SetAcceleration(8000)
		end
		path:Update( self )
		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			--path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		if ( path:GetAge() > 1.5 ) then return "timeout" end
		if ( path:GetAge() > 0.5 ) then path:Compute( self, pos ) end

		coroutine.yield()
	end
	self:StartActivity(self:GetWeaponAttackAnim())
	return "ok"
end

ENT.NextGrenade = 0
ENT.NextChargeCommand = 0
ENT.MovingAce = false
ENT.NextMovingAce = 0
function ENT:RanBehavior()
	if not IsValid(self.Enemy) then return end
	if self.MovingAce then
		if self:GetRangeSquaredTo(self.TargetPos) < 70 then --calculate another point because we reached our old one
			local ep = self.Enemy:EyePos()
			local centerPoint = ep
			local result = Vector(0,0,0)
			local angle = Angle(0,math.random(0,360),0) //between 0 and 2 * PI, angle is in radians
			local distance = self:GetWeaponRange()*math.random(4,10)/10;

			local tr = {}
			tr.start = centerPoint
			tr.endpos = centerPoint + angle:Forward() * distance
			tr.filter = {self,self.Weapon}
			local trace = util.TraceLine(tr)
			self.TargetPos = trace.HitPos and trace.HitPos + (trace.HitNormal * 16) or tr.endpos
		end
	end
	if self:EnemyInRange() then
		if self.NextMovingAce < CurTime() and not self.MovingAce then
			self.MovingAce = true
			self.NextMovingAce = CurTime()+math.random(4,6)

			if math.random(1,5)==1 then
				self:SetUpTrails(false)
				self:SetColor(Color(100,100,100,10))
				self.Weapon:SetMaterial("Models/effects/vol_light001")
			else
				self:SetUpTrails(true,true)
			end

			timer.Simple(3,function() 
				if not IsValid(self) then return end
				self.ChaseSpeed = 185
				self:SetUpTrails(true) 
				self.MovingAce = false 
				self:SetColor(Color(100,100,100,255)) 
				self:SetMaterial("")
				if IsValid(self.Weapon) then
					self.Weapon:SetMaterial("")
				end
				self.TargetPos = nil
			end)

			local ep = self.Enemy:EyePos()
			--range is 500, radius will be 500
			local centerPoint = ep
			local result = Vector(0,0,0)
			local angle = Angle(0,math.random(0,360),0) //between 0 and 2 * PI, angle is in radians
			local distance = self:GetWeaponRange()*math.random(1,10)/10;

			local tr = {}
			tr.start = centerPoint
			tr.endpos = centerPoint + angle:Forward() * distance
			tr.filter = {self,self.Weapon}
			local trace = util.TraceLine(tr)
			self.TargetPos = trace.HitPos and trace.HitPos + (trace.HitNormal * 16) or tr.endpos
		end
		if self.TargetPos then
			self:MoveToPos(self.TargetPos,{maxage=3,repath=1})
		end
	elseif self.MovingAce then
		self:MoveToPos(self.Enemy:GetPos(),{maxage=1,repath=1})
	end
	--if self.MovingAce then return end
	local dist = self:GetRangeSquaredTo(self.Enemy)
	if self.NextGrenade < CurTime() and dist < (800*800) then
		local r = math.random(1,1000)
		if r < 987 then
			for k,v in ipairs(ents.FindInSphere(self:GetPos(),2500)) do
				if v.loco and math.random(1,100) <= 93 then
					v.NextGrenade = CurTime() + math.random(5,14)
				end
			end
			self.NextChargeCommand = CurTime()+4
			self.NextGrenade = CurTime()+math.random(3,20)
			self.Grenading = true

			self:RestartGesture( ACT_GESTURE_BIG_FLINCH )

			--timer.Simple(0.3,function()
				if not IsValid(self) then return end
				self.Grenading = false
				local pos = self:GetPos()+Vector(0,0,70)+(self:GetRight()*-5)
				for i = 1,3 do
					timer.Simple(0.1*i,function()
						if not IsValid(self) then return end
						local ball = ents.Create("proj_grenade_frag")
						ball:SetPos(pos)
						ball:SetOwner(self)
						ball.Owner = self
						ball:Spawn()
						ball:Fire( "SetTimer", 3+i*(math.random(5,10)/10) )
						ball:SetColor(Color(0,0,255))

						local phys = ball:GetPhysicsObject()
						phys:Wake()
						phys:SetMass(1)
						local lobs = math.max(self:GetRangeTo(self.Enemy)/600,0.1)
						local v = GetTrajectoryVelocity(pos,self.Enemy:GetPos(),lobs,Vector(0,0,-600))
						phys:SetVelocityInstantaneous(v+VectorRand()*60)
					end)
				end
			--end)
			--coroutine.wait(0.4)
		end
	end
	if self.NextChargeCommand <= CurTime() and math.random(1,1000) <= 21 then
		self.NextChargeCommand = CurTime() + 20
		self.NextGrenade = CurTime() + 2
		for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
			if v.MoveAndShoot and math.random(1,(10000/(self.MaxScootRand or 10000))*10000) <= 1 and v.Squad == self.Squad then --if our MaxScootRand is lower, then decrease the chance to have others come
				v.ForcedScoot = true
				v.Enemy = self.Enemy

				local maxageScaled=0.5--math.Clamp(self.Enemy:GetPos():Distance(v:GetPos())/1000,0.1,1)
				v.loco:SetDesiredSpeed( v.ChaseSpeed )
				v:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled,repath=1})
			end
		end
		self:RestartGesture( ACT_SIGNAL_FORWARD )
		--local seq = self:LookupSequence("signal_forward")
		--self:ResetSequence(seq)
		self:SetPlaybackRate(1.75)
		--coroutine.wait(self:SequenceDuration()/1.75)
		--self:PlaySequenceAndWait() 
	end
end

function ENT:Killed()
	if self.Grenading then
		local pos = self:GetPos()+Vector(0,0,70)+(self:GetRight()*-5)
		for i = 1,3 do
			local ball = ents.Create("proj_grenade_frag")
			ball:SetPos(pos)
			ball:SetOwner(self)
			ball.Owner = self
			ball:Spawn()
			ball:Fire( "SetTimer", 3+i*(math.random(5,10)/10) )
			ball:SetColor(Color(0,0,255))
			local phys = ball:GetPhysicsObject()
			phys:Wake()
		end
	end
end
