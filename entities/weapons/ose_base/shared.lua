if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
elseif CLIENT then
	SWEP.PrintName			= "Base Wepon"
	SWEP.DrawCrosshair		= true	
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

SWEP.HoldType           = "pistol"

local wep = SWEP

SWEP.Prefix = 0
--Swep info and other stuff
SWEP.Author	= "Matt Damon"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Base wepon."
SWEP.Instructions = "Primary : Fire a bullet."
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_pistol.mdl"
SWEP.WorldModel	= "models/weapons/w_pistol.mdl"
SWEP.Primary.ClipSize 		= 7
SWEP.Primary.Bullets 		= 1
SWEP.Primary.DefaultClip 	= 49
SWEP.Primary.Cone 			= 0.01
SWEP.Primary.Delay			= 0.15
SWEP.Primary.Damage 		= 22
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "pistol"
SWEP.Primary.Sound 			= Sound("Weapon_Pistol.Single")
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.Cone 		= 0.01
SWEP.Secondary.Bullets 		= 1
SWEP.Secondary.Damage 		= 22
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Delay		= 0.1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Sound		= Sound("Weapon_Pistol.Single")

SWEP.First = false

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"prefix")
	self:DTVar("Bool",0,"foundprf")
end

function SWEP:Initialize( )
	self:SetDTInt(0,0)
	self:SetDTBool(0,false)
	self:SetWeaponHoldType( self.HoldType )		
    timer.Simple(1,function() self:GetPrefix(self.Owner) end)
	if CLIENT then
		if self.Owner != LocalPlayer() then return end
		timer.Create("prefixupdate"..LocalPlayer():EntIndex(),1,0,function()
            if not IsValid(self) then timer.Remove("prefixupdate"..LocalPlayer():EntIndex()) return end
            if self:GetDTBool(0) == false then return end
            self.Prefix = self:GetDTInt(0)
            if string.StartWith(self.PrintName,"The") then
                self.PrintName = string.Right(self.PrintName,string.len(self.PrintName)-3) //removes The
            end
            self.PrintName = WEP_PREFIXES[self.Prefix].NAME..self.PrintName
            timer.Remove("prefixupdate"..LocalPlayer():EntIndex())
		end)
	end
end

function SWEP:GetPrefix(ply)
    local prf = 1
	if ply.EItems then
		for k,v in pairs(ply.EItems[convCTable[ply:GetNWInt("class")]]) do
			if NEW_WEAPONS[v[1]] and NEW_WEAPONS[v[1]].WC == self:GetClass() then
				prf = v[2]
			elseif HL2_WEPS[v[1]] and HL2_WEPS[v[1]].WC == self:GetClass() then
				prf = v[2]
			end
		end
	end
    self.Prefix = prf
    self:SetDTInt(0,prf)
    self:SetDTBool(0,true)
end

function SWEP:Deploy()
	return true
end

function SWEP:Equip(ply)
	return true
end

function SWEP:ShootBullet( damage, num_bullets, aimcone)
	if self.Prefix == 8 and math.random(1,3) == 1 then
        aimcone = Vector(0,0,0)
    end
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 1									// Show a tracer on every x bullets 
	bullet.Force	= 1									// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.Inflictor = self.Weapon
	//bullet.TracerName = "Pistol"
	
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack()) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	
	local prf = WEP_PREFIXES[self.Weapon.Prefix] or {}
	
	local dmgmod = prf.DMG or 0
	local conemod = prf.CONE or 0
	
	local dmg = self.Primary.Damage - (self.Primary.Damage * dmgmod)
	local cone = self.Primary.Cone - (self.Primary.Cone * conemod)
	//if SERVER then
		self:ShootBullet(dmg, self.Primary.Bullets, cone)
	//end
    self:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo( 1 )
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_PISTOL)
	if CLIENT then
		self:SendWeaponAnim( ACT_VM_RECOIL1 )
	end

	self.Owner:ViewPunch(Angle(math.random(-2,0),math.random(-2,2),0))
end

function SWEP:SecondaryAttack( )
	if ( !self:CanSecondaryAttack()) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	
	self:ShootBullet( self.Secondary.Damage , self.Secondary.Bullets , self.Secondary.Cone )
	
	self.Weapon:EmitSound(self.Secondary.Sound)
	self:TakePrimaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 )
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_PISTOL)

	self.Owner:ViewPunch(Angle(-10,0,0))
end


function SWEP:Reload()
	if self.Weapon:Clip1() >= self.Primary.ClipSize then return end
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:DoDamage(ent,ply,dmg) --Damage function. Does damage types based on the weapon's prefix.
	local prf = self.Prefix
	local crit = math.random(1,100/WEP_PREFIXES[prf].CHANCE) 
	

	local trace = ply:GetEyeTrace()
	
	if not crit == 1 then return end
	
	if trace.Entity and WEP_PREFIXES[prf].FX and CLIENT then
		WEP_PREFIXES[prf].FX(ply,trace,dmg)
	end
	if prf == 2 then --Fiery 
		ent.Igniter = ply  
		ent:Ignite(1,0)
		timer.Simple(math.random(3,7),function()
            if not IsValid(ent) then return end
			ent:Extinguish()
		end)
	elseif prf == 3 then --Plagued 
		if not ent.poison then --You can't poison poison zombies!
			local stop2 = CurTime()+math.random(4,6)
			local r,g,b,a = ent:GetColor()
			local oldcol = Color(r,g,b,a)
			ent:SetColor(Color(255,0,255,255)) --This gives a poison sort-of look.
			
			timer.Create("Poison"..ent:EntIndex(),1,0,function()
					if stop2 <= CurTime() then
						if ent ~= nil and ent and ent:IsValid() and ent:Alive() then
							ent:SetColor(oldcol)
						end
						timer.Remove("Poison"..ent:EntIndex())
						return
					end
					if not IsValid(ent) then timer.Remove("Poison"..ent:EntIndex()) return end
					ent:TakeDamage(math.random(3,10),ply,ply:GetActiveWeapon())
				end)
		end
	elseif prf == 4 then --Explosive (very small chance.)
			util.BlastDamage(ply:GetActiveWeapon(),ply,ent:GetPos(),30,math.random(4))
	elseif prf == 5 then --Lucky (very small chance)
			ent:TakeDamage(math.random(30,65),ply,ply:GetActiveWeapon())
	elseif prf == 6 then --Vampiric (huge chance)
			local hp = math.random(1,5)
			if ply:Health() + hp > 150 then
				ply:SetHealth(150)
			else
				ply:SetHealth(ply:Health()+hp)
			end
	elseif prf == 7 and ent:IsOnGround() then
		ply:TakeDamage(math.random(1,5),ply,ply)
		ent:SetVelocity(ply:GetAimVector()*1000+Vector(0,0,100))
	end
end

if SERVER then return end
local EFFECT={}
function EFFECT:Init(data)
    local Offset=data:GetOrigin()
    local Derp=data:GetNormal()
    local emitter=ParticleEmitter( Offset )
    
    for i=1,7 do
        local Vec=Derp*-0.1 + (VectorRand():GetNormalized()/4)
        smoke=emitter:Add( "particle/particle_smokegrenade", Offset )
        smoke:SetVelocity(Vec * math.Rand(650,750))
        smoke:SetPos(Offset+(Derp*5))
        smoke:SetDieTime(math.Rand(1,1.3))
        smoke:SetStartAlpha(255)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(10)
        smoke:SetEndSize(20)
        smoke:SetColor(Color(150,150,150,255))
        smoke:SetAirResistance(150)
        smoke:SetGravity(Vector(0,0,20))
        smoke:SetRoll(math.Rand(0,360))
        smoke:SetRollDelta(math.Rand(-2,2))
        smoke:SetBounce(0.3)
        smoke:SetCollide(true)

        local Vec=Derp*-0.1 + (VectorRand():GetNormalized()/4)
        local randcolor = math.random(60,170)
        fire=emitter:Add( "sprites/flamelet"..math.random(1,5), Offset )
        fire:SetVelocity(Vec * math.Rand(850,950))
        fire:SetPos(Offset+(Derp*5))
        fire:SetDieTime(math.Rand(0.4,0.8))
        fire:SetStartAlpha(255)
        fire:SetEndAlpha(0)
        fire:SetStartSize(10)
        fire:SetEndSize(0)
        fire:SetColor(Color(255,randcolor,randcolor))
        fire:SetAirResistance(250)
        fire:SetGravity(Vector(0,0,5))
        fire:SetRoll(math.Rand(0,360))
        fire:SetRollDelta(math.Rand(-2,2))
        fire:SetBounce(0.3)
        fire:SetCollide(true)
    end

    local Vec=Derp + (VectorRand():GetNormalized()/10)
    heatwave=emitter:Add( "sprites/heatwave", Offset )
    heatwave:SetVelocity(Vec * math.Rand(75,85))
    heatwave:SetPos(Offset+(Derp*5))
    heatwave:SetDieTime(math.Rand(1.2,1.5))
    heatwave:SetStartAlpha(255)
    heatwave:SetEndAlpha(0)
    heatwave:SetStartSize(70)
    heatwave:SetEndSize(0)
    heatwave:SetColor(Color(255,255,255,255))
    heatwave:SetAirResistance(200)
    heatwave:SetGravity(Vector(0,0,10))
    heatwave:SetRoll(math.Rand(0,360))
    heatwave:SetRollDelta(math.Rand(-2,2))
    heatwave:SetBounce(0.3)
    heatwave:SetCollide(true)
    
    emitter:Finish()
end
function EFFECT:Think() end
function EFFECT:Render() end
effects.Register(EFFECT,"onslaught_fire",true)

local EFFECT={}
function EFFECT:Init(data)
    local Offset=data:GetOrigin()
    local Derp=data:GetNormal()
    local emitter=ParticleEmitter( Offset )
    
    for i=1,14 do
        local Vec=Derp*-0.1 + (VectorRand():GetNormalized())
        smoke=emitter:Add( "particle/particle_smokegrenade", Offset )
        smoke:SetVelocity(Vec * math.Rand(200,250))
        smoke:SetPos(Offset+(Derp*5))
        smoke:SetDieTime(math.Rand(0.6,0.8))
        smoke:SetStartAlpha(255)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(40)
        smoke:SetEndSize(60)
        smoke:SetColor(Color(200,200,200,255))
        smoke:SetAirResistance(150)
        smoke:SetGravity(Vector(0,0,20))
        smoke:SetRoll(math.Rand(0,360))
        smoke:SetRollDelta(math.Rand(-5,5))
        smoke:SetBounce(0.3)
        smoke:SetCollide(true)

        local Vec=Derp*-0.1 + (VectorRand():GetNormalized())
        local size=math.random(20,30)
        fire=emitter:Add( "effects/fire_cloud2", Offset )
        fire:SetVelocity(Vec * math.Rand(250,300))
        fire:SetPos(Offset+(Derp*5))
        fire:SetDieTime(math.Rand(0.2,0.4))
        fire:SetStartAlpha(255)
        fire:SetEndAlpha(0)
        fire:SetStartSize(size)
        fire:SetEndSize(size * 1.5)
        fire:SetColor(Color(255,255,255))
        fire:SetAirResistance(150)
        fire:SetGravity(Vector(0,0,5))
        fire:SetRoll(math.Rand(0,360))
        fire:SetRollDelta(math.Rand(-8,8))
        fire:SetBounce(0.3)
        fire:SetCollide(true)

        local Vec=Derp*-0.1 + (VectorRand():GetNormalized())
        local size=math.random(6,14)
        local length=math.random(35,45)
        blast=emitter:Add( "effects/fire_cloud2", Offset )
        blast:SetVelocity(Vec * math.Rand(600,800))
        blast:SetDieTime(math.Rand(0.1,0.15))
        blast:SetStartAlpha(255)
        blast:SetEndAlpha(255)
        blast:SetStartSize(size)
        blast:SetEndSize(size)
        blast:SetStartLength(length)
        blast:SetEndLength(length)
        blast:SetColor(Color(255,255,255))
        blast:SetAirResistance(100)
        blast:SetGravity(Vector(0,0,0))
        blast:SetBounce(0)
        blast:SetCollide(true)
    end
    
    for i=1,3 do
        local Vec=Derp + (VectorRand():GetNormalized()/10)
        smoke2=emitter:Add( "particle/particle_smokegrenade", Offset )
        smoke2:SetVelocity(Vec * math.Rand(55,65))
        smoke2:SetPos(Offset+(Derp*5))
        smoke2:SetDieTime(math.Rand(0.9,1.1))
        smoke2:SetStartAlpha(255)
        smoke2:SetEndAlpha(0)
        smoke2:SetStartSize(50)
        smoke2:SetEndSize(80)
        smoke2:SetColor(Color(160,160,160,255))
        smoke2:SetAirResistance(30)
        smoke2:SetGravity(Vector(0,0,10))
        smoke2:SetRoll(math.Rand(0,360))
        smoke2:SetRollDelta(math.Rand(-2,2))
        smoke2:SetBounce(0.3)
        smoke2:SetCollide(true)
    end
    
    emitter:Finish()
end
function EFFECT:Think() end
function EFFECT:Render() end
effects.Register(EFFECT,"onslaught_explode",true)

local EFFECT={}
function EFFECT:Init(data)
    local Offset=data:GetOrigin()
    local Derp=data:GetNormal()
    local emitter=ParticleEmitter( Offset )
    
    for i=1,12 do
        local Vec=Derp*-0.1 + (VectorRand():GetNormalized()/4)
        smoke=emitter:Add( "particle/particle_noisesphere", Offset )
        smoke:SetVelocity(Vec * math.Rand(600,700) + Vector(0,0,100))
        smoke:SetPos(Offset+(Derp*5))
        smoke:SetDieTime(math.Rand(0.9,1.2))
        smoke:SetStartAlpha(255)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(20)
        smoke:SetEndSize(30)
        smoke:SetColor(Color(120,240,120))
        smoke:SetAirResistance(150)
        smoke:SetGravity(Vector(0,0,-150))
        smoke:SetRoll(math.Rand(0,360))
        smoke:SetRollDelta(math.Rand(-7,7))
        smoke:SetBounce(0.3)
        smoke:SetCollide(true)
        
        local Vec=Derp*-0.1 + (VectorRand():GetNormalized()/4)
        smoke2=emitter:Add( "particle/particle_noisesphere", Offset )
        smoke2:SetVelocity(Vec * math.Rand(700,800) + Vector(0,0,100))
        smoke2:SetPos(Offset+(Derp*5))
        smoke2:SetDieTime(math.Rand(0.7,1.0))
        smoke2:SetStartAlpha(255)
        smoke2:SetEndAlpha(0)
        smoke2:SetStartSize(20)
        smoke2:SetEndSize(40)
        smoke2:SetColor(Color(200,200,200))
        smoke2:SetAirResistance(150)
        smoke2:SetGravity(Vector(0,0,-150))
        smoke2:SetRoll(math.Rand(0,360))
        smoke2:SetRollDelta(math.Rand(-6,6))
        smoke2:SetBounce(0.3)
        smoke2:SetCollide(true)

        local Vec=Derp*-0.1 + (VectorRand():GetNormalized()/4)
        local randcolor = math.random(30,90)
        fire=emitter:Add( "sprites/flamelet"..math.random(1,5), Offset )
        fire:SetVelocity(Vec * math.Rand(850,950) + Vector(0,0,100))
        fire:SetPos(Offset+(Derp*5))
        fire:SetDieTime(math.Rand(0.4,0.6))
        fire:SetStartAlpha(255)
        fire:SetEndAlpha(0)
        fire:SetStartSize(40)
        fire:SetEndSize(0)
        fire:SetColor(Color(randcolor,255,randcolor))
        fire:SetAirResistance(250)
        fire:SetGravity(Vector(0,0,-200))
        fire:SetRoll(math.Rand(0,360))
        fire:SetRollDelta(math.Rand(-8,8))
        fire:SetBounce(0.3)
        fire:SetCollide(true)
        
        local Vec=Derp*-0.1 + (VectorRand():GetNormalized()/4)
        local randcolor = math.random(30,90)
        ember=emitter:Add( "effects/fire_embers"..math.random(1,3), Offset )
        ember:SetVelocity(Vec * math.Rand(850,950) + Vector(0,0,100))
        ember:SetPos(Offset+(Derp*5))
        ember:SetDieTime(math.Rand(0.9,1.1))
        ember:SetStartAlpha(255)
        ember:SetEndAlpha(0)
        ember:SetStartSize(40)
        ember:SetEndSize(0)
        ember:SetColor(Color(randcolor,255,randcolor))
        ember:SetAirResistance(200)
        ember:SetGravity(Vector(0,0,-200))
        ember:SetRoll(math.Rand(0,360))
        ember:SetRollDelta(math.Rand(-8,8))
        ember:SetBounce(0.3)
        ember:SetCollide(true)
    end
	emitter:Finish()
end
function EFFECT:Think() end
function EFFECT:Render() end
effects.Register(EFFECT,"onslaught_poison",true)