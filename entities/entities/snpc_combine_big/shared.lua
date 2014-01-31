AddCSLuaFile()
 
ENT.Base			= "snpc_police"

ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Combine Super Soldier"
ENT.Category = "SNPCs"
ENT.Walk = ACT_WALK_AIM_SHOTGUN
ENT.Model = "models/combine_super_soldier.mdl"

ENT.WalkSpeed = 160
ENT.ChaseSpeed = 160

ENT.NPCHealth = 750
ENT.StartBodyGroup = 0

ENT.DeathSound = Sound("NPC_MetroPolice.Die")
ENT.HurtSound = Sound("NPC_MetroPolice.Pain")
ENT.AlertSound = Sound("NPC_MetroPolice.Attack")
ENT.MissSound = Sound("NPC_MetroPolice.AttackMiss")
ENT.HitSound = Sound("NPC_MetroPolice.AttackHit")
ENT.IdleSounds = {Sound("NPC_MetroPolice.Idle")}

ENT.MoveAndShoot = false
function ENT:GetGuns()
	return {"combine_lmg"}
end

function ENT:SecondInit()
	self.MoveAndShoot = true
	self.ScootMaxRand = math.huge
	self:SetModelScale(2,0)
end

function ENT:CanFireGun()
	if !IsValid(self) || !self.Weapon then return false end
	--if not self:EnemyInRange() then return false end
	if (self.NextFireWeapon or 0) > CurTime() then return false end
	return true
end

function ENT:GetFireDelay()
	return 0.06 + math.random(0,math.max(1,(self:GetRangeSquaredTo(self.Enemy)/500))*100)/1000
end

function ENT:MoveToPos( pos, options )
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300000000 )
	path:SetGoalTolerance( options.tolerance or 50 )
	path:Compute( self, pos or self:GetEnemy():GetPos() )
	--path:Chase(self,self:GetEnemy())
	while ( path:IsValid() ) and IsValid(self) do
		if self:GetRangeSquaredTo(self.Enemy) <= 200 then
			self.ForcedScoot = false
			return "ok"
		elseif IsValid(self.Enemy) then
			self.ForcedScoot = true
			--self:StartActivity(self:GetWeaponAttackAnim())
			self:AimAndFire()
			--if not self.MoveAndScoot then return "timeout" end
		end
		path:Update( self )
		-- Draw the path (only visible on listen servers or single player)
		--if ( options.draw ) then
			--path:Draw()
		--end

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

ENT.NextRocketShot = 0
ENT.NextGrenade = 0
ENT.NextActionDelay = 0
function ENT:RanBehavior()
	self.MoveAndShoot = false
	if self.NextActionDelay > CurTime() then return end
	if self.NextRocketShot < CurTime() and IsValid(self.Enemy) then
		local dist = self:GetRangeSquaredTo(self.Enemy)
		if dist < (800 * 800) then
			self.NextActionDelay = CurTime()+math.random(3,7)
			self.NextRocketShot = CurTime() + math.random(7,15)
			self:FaceTowardsAndWait(self.Enemy:GetPos())
			self:EmitSound("npc/combine_soldier/vo/executingfullresponse.wav")
			self:PlaySequenceAndWait("signal_advance") 

			for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
				if v.MoveAndShoot and v.loco and math.random(1,100) <= 93 then
					v.ForcedScoot = true
					v.Enemy = self.Enemy

					local maxageScaled=math.Clamp(self.Enemy:GetPos():Distance(v:GetPos())/1000,0.1,1)
					v.loco:SetDesiredSpeed( v.ChaseSpeed )
					v:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled,repath=1})
				end
			end

			self:StartActivity(ACT_BIG_FLINCH) 
			for i = 1,4 do
				coroutine.wait(0.15 - ((i-1)*0.05))
				local pos = self:EyePos() + Vector(0,0,64)
				if i == 1 then
					pos = pos + self:GetRight() * 20
				else
					pos = pos + self:GetRight() * -20
				end
				
				local ball = ents.Create("proj_carty_ball")
				ball:SetPos(pos)
				--ball:SetCustomCollisionCheck(true)
				ball.Owner = self
				ball:Spawn()
				ball.Target = self.Enemy

				--local dist = self:GetRangeTo(self.Enemy)
				local phys = ball:GetPhysicsObject()
				local v = self:GetUp()*750
				phys:SetVelocityInstantaneous(v)
				--[[GetTrajectoryVelocity(pos,self.Enemy:GetPos(),2,Vector(0,0,-800))
				phys:SetVelocityInstantaneous(v+VectorRand()*math.random(-100,100))]]
			end
			coroutine.wait(0.5)
			self:StartActivity(ACT_RUN_RIFLE)
			return
		end
	end
end