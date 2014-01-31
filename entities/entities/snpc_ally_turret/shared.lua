AddCSLuaFile()
ENT.Base = "base_anim"
ENT.PrintName = "Ally Turret"
ENT.Ally = true
ENT.Spawnable = true


function ENT:Initialize()
	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	if SERVER then
		self:SetUseType(SIMPLE_USE)

		local shoot = ents.Create("prop_dynamic")
		shoot:SetNoDraw(true)
		shoot:SetModel("models/props_junk/sawblade001a.mdl")
		shoot:Spawn()
		shoot:SetParent(self)
		shoot:SetLocalPos(Vector(0,0,45))

		self.Shoot = shoot
	end
	self:SetModelScale(1.5,0)
end	

function ENT:Draw()
	local ang = self:GetAimAngle()
	multimodel.Draw({												--pos 		ang 		scale
		{model="models/props_c17/oildrum001.mdl",transform = {Vector(0,0,0),Angle(0,0,0),Vector(0.75,0.75,0.75)}},
		{model="models/props_vehicles/apc_tire001.mdl",transform = {Vector(0,0,37),Angle(270,0,0) + ang - Angle(0,ang.y,0),Vector(0.3,0.5,0.5)}},
		{model="models/props_wasteland/light_spotlight01_lamp.mdl",transform = {Vector(0,0,45),Angle(0,0,0) + ang,Vector(0.75,0.75,0.75)},material="models/weapons/v_stunbaton/w_shaft01a"},		
		{model="models/props_junk/TrashDumpster02b.mdl",transform = {Vector(0,0,40.5),Angle(0,0,0),Vector(0.2,0.15,0.2)}},
		{model="models/props_c17/oildrum001.mdl",transform = {Vector(0,0,48.5),Angle(0,0,0),Vector(0.2,0.15,0.2)}},
	},self,{modelonly=true})
	self:DrawModel()
end

function ENT:SetupDataTables()
	self:NetworkVar("Angle",0,"AimAngle")
end

function ENT:GetShootPos()
	return self:GetPos()+Vector(0,0,45)
end

ENT.Targets = {}
ENT.NextTargetFind = 0
function ENT:FindTarget()
	if self.Targets == {} or self.NextTargetFind < CurTime() then
		self.NextTargetFind = CurTime()+math.Rand(0.5,1)
		local targets = {}
		local ents = ents.GetAll()
		for i = 1,#ents do
			local v = ents[i]
			if v == self then continue end
			if v:IsNPC() and not v.Ally then
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
		if v:IsPlayer() then
			local tr = {}
			tr.start = self:EyePos()
			tr.endpos = v:GetPos()+Vector(0,0,55)
			tr.filter = self
			local trace = util.TraceLine(tr)
			if trace.Entity and trace.Entity == v then
				local range = self:GetPos():DistToSqr(v:GetPos()+Vector(0,0,55))
				if dist > range then
					dist = range
					target = v
				end
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

function ENT:EnemyInRange()
	return IsValid(self.Enemy) and self.Enemy:Health() > 0
end

ENT.NextShoot = 0
ENT.Ratio = 0.25
ENT.DesiredAim = Angle(0,0,0)
function ENT:AimAndFire()
	local dir = (self.Enemy:GetPos()+(Vector(0,0,35)*self.Enemy:GetModelScale())-self:GetShootPos()):Angle()

	self.DesiredAim = dir
	if CLIENT then
		self.Ratio = self.Ratio * FrameTime()
	end
	dir = dir:Forward()
	if self:GetAimAngle():Forward():Dot(dir) < 0.8 then return end
	if CLIENT or self.NextShoot > CurTime() then return end
	self.NextShoot = CurTime() + 0.01



	local eye = self:GetShootPos()
	local bullet = {}
		bullet.Num = 1
		bullet.Src = eye
		bullet.Dir = dir -- ENT:GetAimVector() equivalent
		bullet.Spread = Vector( spread , spread, 0)
		bullet.Tracer = 1
		bullet.TracerName	= "Tracer"
		bullet.Force = 50
		bullet.Damage = 5
		bullet.AmmoType = "Pistol"
		bullet.Attacker = self

	self.Shoot:EmitSound("weapons/alyxgun/alyx_gun_fire.wav")
	self.Shoot:FireBullets(bullet)
end

function ENT:Think()
	if not IsValid(self.Enemy) then
		self.DesiredAim = Angle(0,0,0)
		self:FindTarget()
	else
		if self:EnemyInRange() then
			self:AimAndFire()
		end
	end
	self:SetAimAngle(LerpAngle(self.Ratio,self:GetAimAngle(),self.DesiredAim))
	self:NextThink(CurTime())
end