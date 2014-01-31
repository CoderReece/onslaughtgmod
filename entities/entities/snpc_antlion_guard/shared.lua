AddCSLuaFile()
 
ENT.Base			= "base_nextbot"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Antlion Guard"
ENT.Category = "SNPCs"
ENT.Walk = ACT_RUN
ENT.Model = "models/antlion_guard.mdl"

ENT.IdleSpeed = 250
ENT.ChaseSpeed = 250

ENT.AttackBeforeDamageDelay = 0.75
ENT.AttackAfterDamageDelay = 0.25
ENT.Damage = 45
ENT.Range = 240

ENT.NPCHealth = 600

ENT.DeathSound = Sound("NPC_AntlionGuard.Die")
ENT.HurtSound = Sound("NPC_AntlionGuard.Pain")
ENT.AlertSound = Sound("NPC_AntlionGuard.Anger")
ENT.MissSound = ""
ENT.HitSound = Sound("NPC_AntlionGuard.HitHard")
ENT.IdleSounds = {""}
function ENT:Initialize()

	self:FindTarget() 
	self:SetModel( self.Model )

	self.Attacking=true
	self.Idling=false
	self:StartActivity( self.Walk )
	self.targetname=self:GetClass().."_"..tostring(self:EntIndex())
	self:SetKeyValue("targetname",self.targetname)

	self:SetHealth(self.NPCHealth)

	self.WalkSpeed=self.IdleSpeed
	self.NextAmble=0
	self:SetBodygroup(1,self.StartBodyGroup or 1)
	
	self:SetCollisionBounds(Vector(-4,-4,0),Vector(4,4,64))

	self:SecondInit()
end

function ENT:SecondInit()
	--override
end

ENT.NPCCurrentActivity = 0
function ENT:StartActivity(arg)
	if self.NPCCurrentActivity != arg then
		self:StartActivity(arg)
		self.NPCCurrentActivity = arg
	elseif not arg then
		self:StartActivity(self.NPCCurrentActivity)
	end
end

if CLIENT then
	local oldDraw = ENT.Draw
	function ENT:Draw()
		oldDraw(self)
		self:StartActivity()
	end
end
function ENT:Alive()
	return self:Health() > 0
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

ENT.Targets = {}
ENT.NextTargetFind = 0
function ENT:FindTarget()
	local oldEnemy = self.Enemy
	local trace = util.QuickTrace(self:GetPos()+Vector(0,0,55),self:GetForward())
	if IsValid(trace.Entity) and trace.Entity:GetClass():find("sent") then
		self.Target = trace.Entity
		return trace.Entity
	end
	
	if self.Targets == {} or self.NextTargetFind < CurTime() then
		self.NextTargetFind = CurTime()+2
		local targets = {}
		for k,v in pairs(ents.GetAll()) do
			if v == self then continue end
			if v:IsPlayer() or v:GetClass():find("sent") then
				table.insert(targets,v)
			end
		end
		self.Targets = targets
	end
	for k,v in ipairs(self.Targets) do
		if v:IsPlayer() then --visible players first
			local tr = {}
			tr.start = self:GetPos()+Vector(0,0,55) 
			tr.endpos = self:NearestPoint(v:GetPos())
			local trace = util.TraceLine(tr)
			if trace.Entity and trace.Entity == v then
				self.Enemy = v
				return v
			end
		elseif v:GetClass():find("sent") and not v:GetClass():find("spaw") then
			if v:GetClass() == "sent_turretcontroller" then --priority turrets over any other entity
				local tr = {}
				tr.start = self:GetPos()+Vector(0,0,55)
				tr.endpos = v:GetPos()
				local trace = util.TraceLine(tr)
				if trace.Entity and trace.Entity == v then
					self.Enemy = v
					return v
				end
			else
				local tr = {}
				tr.start = self:GetPos()+Vector(0,0,55)
				tr.endpos = v:GetPos()
				local trace = util.TraceLine(tr)
				if trace.Entity and trace.Entity == v then
					self.Enemy = v
					return v
				end
			end
		end
	end
	if not self.Enemy then
		self.Enemy=table.Random(self.Targets)
	end
end

function ENT:EnemyInRange()
	if not IsValid(self.Enemy) then
		self:FindTarget()
	end
	if not IsValid(self.Enemy) then return end

	local eye = self:GetPos()+Vector(0,0,50)
	local dir = (self:GetEnemy():NearestPoint(eye) - eye):GetNormal(); -- replace with eyepos if you want
	local canSee = dir:Dot( self:GetForward() ) > 0.8; -- -1 is directly opposite, 1 is self:GetForward(), 0 is orthogonal

	return self.Enemy:GetPos():Distance(self:GetPos())<=self.Range
end

function ENT:OnStuck()
	self:SetPos(self:GetPos()+Vector(0,0,10))
end

function ENT:OnInjured(dmginfo) 
	self.Idling=false
	--if math.random(1,2) == 1 then
	--	self:EmitSoundEx(self.HurtSound)
	--end
	--self.Enemy=dmginfo:GetAttacker()
	self:Injured()
end

function ENT:Injured()
	--override
end

function ENT:OnKilled(dmginfo)
	GAMEMODE:OnNPCKilled(self,dmginfo:GetAttacker(),dmginfo:GetInflictor())

	if self.poison then
		local sequence = self:LookupSequence("releasecrab")
		self:ResetSequence(sequence)
		timer.Simple(1.5,function()
			self:EmitSoundEx(self.DeathSound)
			self:BecomeRagdoll(dmginfo)
			self:Killed()
		end)
	else
		--[[local grave = nil
		local dist = 99999999999
		for k,v in pairs(ents.FindByClass("snpc_zombie_grave")) do
			if v:GetRangeSquaredTo(self) < dist then
				grave = v
				dist = v:GetRangeSquaredTo(self)
			end
		end]]
		if IsValid(grave) then
			table.insert(grave.DiedPositions,{ent=self:GetClass(),pos=self:GetPos()})
			grave.NextRevive = grave.NextRevive + 1
		end
		
		self:EmitSoundEx(self.DeathSound)
		self:BecomeRagdoll(dmginfo)
		self:Killed()
	end
end

function ENT:Killed()
	--override
end

function ENT:OnOtherKilled(dmginfo)
	self.Idling=false
	--self.Enemy=dmginfo:GetAttacker()
end

function ENT:OnLandOnGround() end

function ENT:ShouldChase(entity)
	return self.Attacking
end

function ENT:MoveToPos( pos, options )
	local options = options or {}
	local path = Path( "Chase" )
	path:SetMinLookAheadDistance( options.lookahead or 300000000 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos or self:GetEnemy():GetPos() )
	while ( path:IsValid() ) do
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
		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end
		--
		-- If they set repath then rebuild the path every x seconds
		--
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end
		coroutine.yield()
	end
	return "ok"
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end

function ENT:GetEnemy(ent)
	return self.Enemy
end

function ENT:DealDamage(ent)
	if not self:EnemyInRange() then
		self:EmitSoundEx(self.MissSound)
		return
	end
	self:EmitSoundEx(self.HitSound)
	local dmginfo=DamageInfo()	
		dmginfo:SetDamagePosition(self:GetPos()+Vector(0,0,50))
		dmginfo:SetDamage(self.Damage)
		dmginfo:SetDamageType(DMG_CLUB)
		dmginfo:SetAttacker(self)
	self.Enemy:TakeDamageInfo(dmginfo)

	local moveAdd=Vector(0,0,200)
	if not self.Enemy:IsOnGround() then
		moveAdd=Vector(0,0,0)
	end
	self.Enemy:SetVelocity(moveAdd+((self.Enemy:GetPos()-self:GetPos()):GetNormal()*100))
end

function ENT:FaceTowardsAndWait(pos)
	if self:EnemyInRange() then return end
	local eye = self:GetPos()
	eye = Vector(eye.x,eye.y,0)
	pos = Vector(pos.x,pos.y,0)
	local dir = (pos - eye):GetNormal(); -- replace with eyepos if you want

	while (dir:Dot( self:GetForward() ) < 0.95) do
		self.loco:FaceTowards(pos)
		coroutine.yield()
	end
end

function ENT:EmitSoundEx(sound,vol,pitch)
	self:EmitSound(sound,vol,pitch)
	--to be override
end

function ENT:RunBehaviour()
	while ( true ) do
		if (math.random(1,200) < 2) or self.Charging then
			self.Charging = true
			self:StartActivity(ACT_RUN)
			self.loco:SetDesiredSpeed(500)
			self.loco:SetAcceleration(2000)
			local maxageScaled=math.Clamp(self.Enemy:GetPos():Distance(self:GetPos())/1000,0.1,3)
			self:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled,repath=0.1})
			local trace = {}
			trace.start = self:GetPos()
			trace.endpos = self:GetPos() + self:GetForward()*250
			trace.filter = self
			trace.mins = Vector(-64,-64,0)
			trace.maxs = Vector(64,64,64)
			local tr = util.TraceHull(tr)
			if IsValid(tr.Entity) then
				tr.Entity:TakeDamage(50,self,self)
				self:StartActivity(ACT_SMALL_FLINCH)
				self.Charging = false
			end
			coroutine.yield()
		else
			self.loco:SetAcceleration(400)
		end
		if math.random(1,20) == 2 then
			local sound = self.IdleSounds
			while type(sound) == "table" do
				sound = table.Random(sound)
			end
			self:EmitSoundEx(sound,140,100)
		end
		if self.Idling then
			self.WalkSpeed=self.IdleSpeed
			if CurTime()>self.NextAmble then
				self:StartActivity(self.Walk)
				self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 )
				
				self.NextAmble=CurTime()--+math.random(1,5)
			end
		elseif self.Attacking then
			self.WalkSpeed=self.ChaseSpeed
		end

		self.loco:SetDesiredSpeed( self.WalkSpeed )
		if not self.Attacking then
			self.Idling=true
		else
			self.Idling=false
		end
		if (self.NextCheckEnemy or 0) < CurTime() then
			self.NextCheckEnemy = CurTime()+3
			self:FindTarget()
		end
		
		if IsValid(self.Enemy) and not self.Idling then
			self.loco:FaceTowards(self.Enemy:GetPos())
			if self:ShouldChase(self.Enemy) then
				self.Attacking=true

				local maxageScaled=math.Clamp(self.Enemy:GetPos():Distance(self:GetPos())/1000,0.1,3)
				self:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled,repath=1})

				if self:EnemyInRange() then
					self.Charging = false
					self:StartActivity(ACT_MELEE_ATTACK1)
					self:EmitSoundEx(self.AlertSound)
					coroutine.wait(self.AttackBeforeDamageDelay)
					
					self:DealDamage(self.Enemy) --leave hitsounds/misssounds to dealdamage

					coroutine.wait(self.AttackBeforeDamageDelay) --For attack to finish
					self:StartActivity( self.Walk )
				end
			else
				self.Attacking=false
			end
		end	
		self:RanBehavior()
		coroutine.yield()
	end
end

function ENT:RanBehavior()
	--override
end