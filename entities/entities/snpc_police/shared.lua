AddCSLuaFile()
 
ENT.Base			= "base_nextbot"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Metro Police"
ENT.Category = "SNPCs"
ENT.Walk = ACT_RUN_AIM_RIFLE
ENT.Model = "models/Police.mdl"

ENT.WalkSpeed = 140
ENT.ChaseSpeed = 140

ENT.NPCHealth = 45
ENT.StartBodyGroup = 0
ENT.MoveAndShoot = true

ENT.DeathSound = Sound("NPC_MetroPolice.Die")
ENT.HurtSound = Sound("NPC_MetroPolice.Pain")
ENT.AlertSound = Sound("NPC_MetroPolice.Attack")
ENT.MissSound = Sound("NPC_MetroPolice.AttackMiss")
ENT.HitSound = Sound("NPC_MetroPolice.AttackHit")
ENT.IdleSounds = {Sound("NPC_MetroPolice.Idle")}

function ENT:GetGuns()
	return {"combine_smg1","combine_pistol"}
end

ENT.WeaponData = {
	["combine_smg1"] = {sound=Sound("Weapon_SMG1.Single"),		damage=4,delay=0.09,cone=0.2,	range=500,					act=ACT_RANGE_ATTACK_SMG1,		actm=ACT_RUN_AIM_RIFLE,		gest=ACT_GESTURE_RANGE_ATTACK_SMG1},
	["combine_pistol"] = {sound=Sound("Weapon_Pistol.Single"),	damage=5,delay=0.3,	cone=0.1775,range=650,					act=ACT_RANGE_ATTACK_PISTOL,	actm=ACT_RUN_AIM_PISTOL,	gest=ACT_GESTURE_RANGE_ATTACK_PISTOL},
	["combine_ar2"] = {sound=Sound("Weapon_AR2.Single"),		damage=6,delay=0.11,cone=0.1775,range=750,type="AR2Tracer",act=ACT_RANGE_ATTACK_AR2,		actm=ACT_RUN_AIM_RIFLE,		gest=ACT_GESTURE_RANGE_ATTACK_AR2},
	["combine_shotgun"] = {sound=Sound("Weapon_Shotgun.Single"),damage=5,delay=1,	cone=0.25,	range=300,bullets=8,		act=ACT_RANGE_ATTACK_SHOTGUN,	actm=ACT_RUN_AIM_RIFLE,		gest=ACT_GESTURE_RANGE_ATTACK_SHOTGUN},
	["combine_silsmg"] = {sound=Sound("buttons/button15.wav"),	damage=4,delay=0.12,cone=0.15,	range=550,					act=ACT_RANGE_ATTACK_SMG1_LOW,	actm=ACT_RUN_AIM_RIFLE,		gest=ACT_GESTURE_RANGE_ATTACK_AR2},
	["combine_lmg"] = {sound=Sound("weapons/ar1/ar1_dist1.wav"),damage=4,delay=0.06,cone=0.19,	range=500,bullets=2,		act=ACT_RANGE_ATTACK_SHOTGUN,	actm=ACT_WALK_AIM_SHOTGUN,	gest=ACT_GESTURE_RANGE_ATTACK_SHOTGUN}
}

function ENT:Initialize()
	self:SetModel( self.Model )
	self.MaxScootRand = 10000
	self:SetCollisionBounds(Vector(-12,-12,0),Vector(12,12,64))

	local gun = table.Random(self:GetGuns())
	if type(gun) == "table" then
		gun = gun[1]
	end
	self:GiveWeapon(gun)
	if self.WeaponData[gun] then
		self.Weapon.NPCShoot_Primary = nil
	end
	
	self.Attacking=true
	self.Idling=false
	self:StartActivity( self.Walk )
	self.targetname=self:GetClass().."_"..tostring(self:EntIndex())
	self:SetKeyValue("targetname",self.targetname)

	self:SetHealth(self.NPCHealth)

	self.WalkSpeed=self.IdleSpeed
	self.NextAmble=0
	self:SetBodygroup(1,self.StartBodyGroup or 1)

	self.ForcedScoot = false --SHOOT AND SCOOT!

	self:FindTarget()
	self:SecondInit()
end

function ENT:SecondInit()
	--override
end

hook.Add("PlayerCanPickupWeapon","NPC.DontTakeMyGun",function(ply,ent)
	return not ent.DontPickUp
end)

function ENT:GiveWeapon(class)
	local ent = self
	if !IsValid(ent) then return end
	if ent.Weapon then ent.Weapon:Remove() end
	local att = "anim_attachment_RH"
	local shootpos = ent:GetAttachment(ent:LookupAttachment(att))
	
	local wep = ents.Create(class)
	wep:SetOwner(ent)
	wep:SetPos(shootpos.Pos)
	--wep:SetAngles(ang)
	wep:Spawn()
	wep.DontPickUp = true
	wep:SetSolid(SOLID_NONE)
		
	wep:SetParent(ent)

	wep:Fire("setparentattachment", "anim_attachment_RH")
	wep:AddEffects(EF_BONEMERGE)
	wep:SetAngles(ent:GetForward():Angle())
		
	ent.Weapon = wep
end

function ENT:GetShootPos()
	return self:GetActiveWeapon():GetPos()
end

function ENT:GetAimVector()
	return self.Enemy and (self.Enemy:GetPos()+Vector(0,0,40)-self:GetShootPos()):GetNormal() or self:GetForward()
end

function ENT:ViewPunch()
end

function ENT:GetActiveWeapon()
	return self.Weapon
end

function ENT:GetWeaponRange()
	if self.Range then return self.Range end
	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		if self.WeaponData[wep:GetClass()] then
			self.Range = self.WeaponData[wep:GetClass()].range + math.random(-50,50)
			return self.Range
		end
		self.Range = (wep.Range or 500) + math.random(-50,50)
		return wep.Range or 500
	end
	return 50
end

function ENT:GetWeaponAttackGest()
	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		if self.WeaponData[wep:GetClass()] then
			return self.WeaponData[wep:GetClass()].gest
		end
		return wep.GestAnim or ACT_GESTURE_RANGE_ATTACK_SMG1 --everyone has this anim
	end
	return ACT_GESTURE_MELEE_ATTACK_SWING
end

function ENT:GetWeaponAttackAnim()
	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		if self.WeaponData[wep:GetClass()] then
			if self.loco:GetVelocity():LengthSqr() > 1 then
				return self.WeaponData[wep:GetClass()].actm or self.WeaponData[wep:GetClass()].act
			else
				return self.WeaponData[wep:GetClass()].act
			end
		end
		return wep.AttackAnim or ACT_RANGE_ATTACK_PISTOL
	end
	return ACT_MELEE_ATTACK
end

function ENT:EnemyInRange()
	if not IsValid(self.Enemy) then
		return
	end
	
	if self.Enemy.Alive and not self.Enemy:Alive() then
		return
	end

	local range = self:GetWeaponRange()
	return (self:GetRangeSquaredTo(self.Enemy) <= range)
end

function ENT:GetFireDelay()
	local wep = self.Weapon
	if wep.NPCShoot_Primary then
		return wep.Primary.Delay
	elseif self.WeaponData[wep:GetClass()] then
		return self.WeaponData[wep:GetClass()].delay + math.random(0,0.01)
	end
	return 0.01
end

function ENT:AimAndFire()
	if not self.ForcedScoot then
		self:FaceTowardsAndWait(self.Enemy:EyePos())
	end
	self:Aim(self.Enemy:EyePos())
	if (self.NextFireWeapon or 0) > CurTime() then
		return
	end

	self:RestartGesture( self:GetWeaponAttackGest() )

	local d = self:FireWeapon()
	self.NextFireWeapon = CurTime()+d

	if self.loco:GetVelocity():LengthSqr() <= 1 and self.NPCCurrentActivity != self:GetWeaponAttackAnim() then --don't run while gesturing
		self:StartActivity(self:GetWeaponAttackAnim())
	end
end

function ENT:CanFireGun()
	if !IsValid(self) || !self.Weapon then return false end
	if not self:EnemyInRange() then return false end
	if (self.NextFireWeapon or 0) > CurTime() then return false end
	return true
end

function ENT:FireWeapon()
	if not self:CanFireGun() then return self:GetFireDelay() end
	local wep = self.Weapon
	if wep.NPCShoot_Primary then
		wep:NPCShoot_Primary()
		--coroutine.wait()
		return self:GetFireDelay()
		--return
	end
	local data = self.WeaponData[wep:GetClass()]
	local spread = data.cone

	local eye = self:GetShootPos()
	local dir = self:GetAimVector() -- replace with eyepos if you want

	local bullet = {}
		bullet.Num = data.bullets or 1
		bullet.Src = eye
		bullet.Dir = dir -- ENT:GetAimVector() equivalent
		bullet.Spread = Vector( spread , spread, 0)
		bullet.Tracer = 1
		bullet.TracerName	= data.type or "Tracer"
		bullet.Force = 50
		bullet.Damage = data.damage
		bullet.AmmoType = "Pistol"
		bullet.Attacker = self

	self.Weapon:FireBullets(bullet)

	wep:EmitSound(data.sound)
	--coroutine.wait(data.delay)
	return self:GetFireDelay() + math.Rand(0,0.05)
end	

ENT.NPCCurrentActivity = 0
local oldStartActivity = ENT.StartActivity
function ENT:StartActivity(arg)
	if self.NPCCurrentActivity != arg then
		oldStartActivity(self,arg)
		self.NPCCurrentActivity = arg
	elseif not arg then
		oldStartActivity(self,self.NPCCurrentActivity)
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

ENT.Targets = {}
ENT.NextTargetFind = 0
function ENT:FindTarget()
	if self.Targets == {} or self.NextTargetFind < CurTime() then
		self.NextTargetFind = CurTime()+math.random(4,10)
		local targets = {}
		local ents = ents.GetAll()
		for i = 1,#ents do
			local v = ents[i]
			if v == self then continue end
			if v:IsPlayer() or (v:IsNPC() and v.Ally) or NPC_TARGETS[v:GetClass()] --[[or (v:GetClass():find("sent") and not v:GetClass():find("spaw"))]] then
				table.insert(targets,v)
			end
		end
		self.Targets = targets
	end

	local target = nil
	local dist = 999999999999999999999999999
	for i = 1,#self.Targets do
		local v = self.Targets[i]
		if not IsValid(v) then continue end
		local tr = {}
		tr.start = self:EyePos()
		tr.endpos = v:GetPos()+Vector(0,0,55)
		tr.filter = self
		local trace = util.TraceLine(tr)
		if trace.Entity and trace.Entity == v then
			local range = self:GetRangeSquaredTo(v:GetPos()+Vector(0,0,55))
			if dist > range then
				dist = range
				target = v
			end
		end
	end
	if target then
		self.Enemy = target
	else
		local target = table.Random(self.Targets)
		self.Enemy=target
	end

	if self:EnemyInRange() then
		self:AimAndFire()
	end
end

function ENT:HandleStuck()
	self:SetPos(self:GetPos()+Vector(math.random(-32,32),math.random(-32,32),math.random(0,10)))
	if not self.loco:IsStuck() then
		self:ClearStuck()
	end
	coroutine.yield()
end

function ENT:OnInjured(dmginfo) 		
	self.Idling=false
	if math.random(1,2) == 1 then
		self:EmitSound(self.HurtSound)
	end
	self:Injured(dmginfo)
	--self.Enemy=dmginfo:GetAttacker()
end

function ENT:Injured(dmginfo)
	--override
end

function ENT:OnKilled(dmginfo)
	self.Weapon:Remove()
	GAMEMODE:OnNPCKilled(self,dmginfo:GetAttacker(),dmginfo:GetInflictor())
	self:Killed(dmginfo)
	self:EmitSound(self.DeathSound)
	self:BecomeRagdoll(dmginfo)
end

function ENT:Killed(dmginfo)
	--override
end

function ENT:OnOtherKilled(dmginfo)
	self.Idling=false
	--self.Enemy=dmginfo:GetAttacker()
end

function ENT:OnLandOnGround() end

function ENT:ShouldChase(entity)
	return self.Attacking and not self:EnemyInRange()
end

ENT.Waypoints = {}
function ENT:MoveToPos( pos, options )
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300000000 )
	path:SetGoalTolerance( options.tolerance or 50 )
	path:Compute( self, pos or self:GetEnemy():GetPos() )
	--path:Chase(self,self:GetEnemy())
	while ( path:IsValid() ) and IsValid(self) do
		if self.ForcedScoot and self:GetRangeSquaredTo(self.Enemy) <= 200 then
			self.ForcedScoot = false
			return "ok"
		elseif self:EnemyInRange() and not self.DontShootScoot then
			self:StartActivity(self:GetWeaponAttackAnim())
			self:AimAndFire()
			if not self.MoveAndScoot then return "timeout" end
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

function ENT:GetEnemy(ent)
	return self.Enemy
end

function ENT:FaceTowardsAndWait(pos)
	--if self:EnemyInRange() then return end
	local eye = self:EyePos()
	eye = Vector(eye.x,eye.y,0)
	pos = Vector(pos.x,pos.y,0)
	local dir = (pos - eye):GetNormal(); -- replace with eyepos if you want

	while (dir:Dot( self:GetForward() ) < 0.8) do
		self.loco:FaceTowards(pos)
		coroutine.yield()
	end
end
--local t = 0
--local t2 = 0
function ENT:Think()
	if IsValid(self.Enemy) then
		self:Aim(self.Enemy:EyePos())
	end
end

function ENT:GetRunAnim()
	if self.ForcedScoot or self.MovingAce then
		return self:GetWeaponAttackAnim()
	end
	return self.Walk
end

local t = CurTime()
function ENT:RunBehaviour()
	while ( true ) do
		if not self.Idling and ((self.NextCheckEnemy or 0) < CurTime() or not IsValid(self.Enemy)) then
			self.NextCheckEnemy = CurTime()+1
			self:FindTarget()
		end
		if (IsValid(self.Enemy) and self.Enemy:Alive()) and not self.Idling then
			self.Attacking=true
			if self:EnemyInRange() then
				self:AimAndFire()
			end

			local rand = math.Rand(1,self.MaxScootRand or 10000)
			if (self.MoveAndShoot and rand <= 3) or self.ForcedScoot or self:ShouldChase(self.Enemy) then
				if (self.MoveAndShoot and rand) and not self.ForcedScoot then --call a charge
					self.ForcedScoot = true
					for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
						if v.MoveAndShoot and math.random(1,(10000/(self.MaxScootRand or 10000))*10000) <= 1 and v.Squad == self.Squad then --if our MaxScootRand is lower, then decrease the chance to have others come
							v.ForcedScoot = true
							v.Enemy = self.Enemy

							local maxageScaled=0.5--math.Clamp(self.Enemy:GetPos():Distance(v:GetPos())/1000,0.1,1)
							v.loco:SetDesiredSpeed( v.ChaseSpeed )
							v:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled,repath=1})
						end
					end
					self:RestartGesture(ACT_SIGNAL_ADVANCE)
				end
				self:StartActivity( self:GetRunAnim() )

				local maxageScaled=0.5--math.Clamp(self.Enemy:GetPos():Distance(self:GetPos())/1000,0.1,1)
				self.loco:SetDesiredSpeed( self.ChaseSpeed )
				self:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled,repath=1})
			elseif rand <= 16 then
				self.ForcedScoot = false
				self.DontShootScoot = true
				self:MoveToPos(self:GetPos()+VectorRand()*250)
			end
		end			
		self:RanBehavior()
		coroutine.yield()
	end
end

function ENT:RanBehavior()
	--override
end

local entMeta = FindMetaTable("Entity")
entMeta.IsNPC = function(self)
	if not IsValid(self) then return false end
	return self:GetClass():find("npc_*") or self:GetClass():find("snpc_*")
end

function ENT:GetYawPitch(vec)
	--This gets the offset from 0,2,0 on the entity to the vec specified as a vector
	local yawAng=vec-self:EyePos()
	--Then converts it to a vector on the entity and makes it an angle ("local angle")
	local yawAng=self:WorldToLocal(self:GetPos()+yawAng):Angle()
	
	--Same thing as above but this gets the pitch angle. Since the turret's pitch axis and the turret's yaw axis are seperate I need to do this seperately.
	local pAng=vec-self:LocalToWorld((yawAng:Forward()*8)+Vector(0,0,50))
	local pAng=self:WorldToLocal(self:GetPos()+pAng):Angle()

	--Y=Yaw. This is a number between 0-360.	
	local y=yawAng.y
	--P=Pitch. This is a number between 0-360.
	local p=pAng.p
	
	--Numbers from 0 to 360 don't work with the pose parameters, so I need to make it a number from -180 to 180
	if y>=180 then y=y-360 end
	if p>=180 then p=p-360 end
	if y<-60 || y>60 then return false end
	if p<-81.2 || p>50 then return false end
	--Returns yaw and pitch as numbers between -180 and 180	
	return y,p
end

--This grabs yaw and pitch from ENT:GetYawPitch. 
--This function sets the facing direction of the turret also.
function ENT:Aim(vec)
	local y,p=self:GetYawPitch(vec)
	if y==false then
		return false
	end
	self:SetPoseParameter("aim_yaw",y)
	self:SetPoseParameter("aim_pitch",p)
	return true
end
