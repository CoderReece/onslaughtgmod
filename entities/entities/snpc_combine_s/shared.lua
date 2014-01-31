AddCSLuaFile()
 
ENT.Base			= "snpc_police"

ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Combine Soldier"
ENT.Category = "SNPCs"
ENT.Walk = ACT_RUN_RIFLE
ENT.Model = "models/combine_soldier.mdl"

ENT.IdleSpeed = 160
ENT.ChaseSpeed = 160

ENT.NPCHealth = 75
ENT.StartBodyGroup = 0

ENT.DeathSound = Sound("NPC_MetroPolice.Die")
ENT.HurtSound = Sound("NPC_MetroPolice.Pain")
ENT.AlertSound = Sound("NPC_MetroPolice.Attack")
ENT.MissSound = Sound("NPC_MetroPolice.AttackMiss")
ENT.HitSound = Sound("NPC_MetroPolice.AttackHit")
ENT.IdleSounds = {Sound("NPC_MetroPolice.Idle")}

function ENT:GetGuns()
	return {"combine_smg1","combine_ar2","combine_shotgun"}
end

function ENT:SecondInit()
	self.MoveAndShoot = true
	if self.Weapon:GetClass()=="combine_shotgun" then
		self:SetSkin(1)
		self.MaxScootRand = 5000 --twice as likely to charge
		self.Walk = ACT_RUN_AIM_SHOTGUN
	end
	if self.Weapon:GetClass()=="combine_ar2" and math.random(1,3) == 3 then
		self:SetHealth(100)
		self:SetModel("models/combine_super_soldier.mdl")
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

ENT.NextGrenade = 0
function ENT:RanBehavior()
	if not IsValid(self.Enemy) then return end
	if self.NextGrenade < CurTime() then
		if self:GetRangeSquaredTo(self.Enemy) < (800*800) then
			local r = math.random(1,1000)
			if r >= 987 then
				for k,v in ipairs(ents.FindInSphere(self:GetPos(),2500)) do
					if v.loco and math.random(1,100) <= 93 then
						v.NextGrenade = CurTime() + math.random(5,14)
					end
				end

				self.NextGrenade = CurTime()+math.random(3,20)
				self.Grenading = true

				self:StartActivity(ACT_DO_NOT_DISTURB)
				local seq = self:LookupSequence("grenThrow")
				self:ResetSequence(seq)
				coroutine.wait(0.7)
				self.Grenading = false
				local pos = self:GetPos()+Vector(0,0,70)+(self:GetRight()*-5)
				local ball = ents.Create("proj_grenade_frag")
				ball:SetPos(pos)
				ball:SetOwner(self)
				ball.Owner = self
				ball:Spawn()
				ball:Fire( "SetTimer", 5 )

				local phys = ball:GetPhysicsObject()
				phys:Wake()
				phys:SetMass(1)
				local lobs = math.max(self:GetRangeTo(self.Enemy)/600,0.1)
				local v = GetTrajectoryVelocity(pos,self.Enemy:GetPos(),lobs,Vector(0,0,-600))
				phys:SetVelocityInstantaneous(v+VectorRand()*(lobs*5))
				coroutine.wait(0.5)
				self:StartActivity(ACT_RUN_RIFLE)
			end
		end
	end
end

function ENT:Killed()
	if self.Grenading then
		local pos = self:GetPos()+Vector(0,0,70)+(self:GetRight()*-5)
		local ball = ents.Create("proj_grenade_frag")
		ball:SetPos(pos)
		ball:SetOwner(self)
		ball.Owner = self
		ball:Spawn()
		ball:Fire( "SetTimer", 5 )
		local phys = ball:GetPhysicsObject()
		phys:Wake()
	end
end