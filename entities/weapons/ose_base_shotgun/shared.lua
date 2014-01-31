if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end
SWEP.Prefix = 1

if (CLIENT) then
	SWEP.PrintName			= "Base Shotgun"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 3
end
SWEP.HoldType = "shotgun"
SWEP.Base = "ose_base" --This base takes stuff from another base. Awesome.

--Swep info and other stuff
SWEP.Author	= "Matt Damon"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Shoot to kill."
SWEP.Instructions = "Primary : Fire 8 lead pellets into an enemy.\n Secondary : 2x that."
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"

SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Primary.ClipSize 		= 6
SWEP.Primary.Bullets 		= 8
SWEP.Primary.DefaultClip 	= 36
SWEP.Primary.Cone 			= 0.075
SWEP.Primary.Delay			= 0.7
SWEP.Primary.Damage 		= 10
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "Buckshot"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.Cone 		= 0.08
SWEP.Secondary.Bullets 		= 16
SWEP.Secondary.Damage 		= 10
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo			= "none"


SWEP.LastReload = CurTime()
SWEP.Reloading = false
SWEP.AT = false


function SWEP:Deploy()
	self.Reloading = false
	return true
end

function SWEP:ShootBullet( damage, num_bullets, aimcone)
	
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 3									// Show a tracer on every x bullets 
	bullet.Force	= 1									// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.Inflictor = self.Weapon
	bullet.AmmoType = "Pistol"
	
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
	
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack()) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self.Reloading = false
	local dmgdiv = WEP_PREFIXES[self.Prefix].DMG or 0
	local condiv = WEP_PREFIXES[self.Prefix].CONE or 0

	local dmg = self.Primary.Damage - (self.Primary.Damage * dmgdiv)
	local cone = self.Primary.Cone - (self.Primary.Cone * condiv)
	
	self:ShootBullet(dmg, self.Primary.Bullets, cone)

	self.Weapon:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 )
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_SHOTGUN)
	if SERVER then
		timer.Simple(0.2, function() if IsValid(self) then self:EmitSound("weapons/shotgun/shotgun_cock.wav") end end)
	end
	timer.Simple(0.3, function() if IsValid(self) then self:SendWeaponAnim(ACT_SHOTGUN_PUMP) end end)
	self.Owner:ViewPunch(Angle(-10,0,0))
end

function SWEP:SecondaryAttack( )
	if ( !self:CanPrimaryAttack()) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	self.Reloading = false
	local dmgdiv = WEP_PREFIXES[self.Weapon.Prefix].DMG or 0
	local condiv = WEP_PREFIXES[self.Weapon.Prefix].CONE or 0
	local dmg = self.Secondary.Damage - (self.Secondary.Damage * dmgdiv)
	local cone = self.Secondary.Cone - (self.Secondary.Cone * condiv)

	self:ShootBullet(dmg, self.Secondary.Bullets, cone)
	
	self.Weapon:EmitSound(self.Secondary.Sound)
	self:TakePrimaryAmmo( 2 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL2 )
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_SHOTGUN)

	if SERVER then
		timer.Simple(0.2, function() if IsValid(self) then self:EmitSound("weapons/shotgun/shotgun_cock.wav") end end)
	end
	timer.Simple(0.3, function() if IsValid(self) then self:SendWeaponAnim(ACT_SHOTGUN_PUMP) end end)
	self.Owner:ViewPunch(Angle(-10,0,0))
end


function SWEP:Reload()
	if self.Weapon:Clip1() >= self.Primary.ClipSize	then return end
	if self.Reloading == true then return end
	if self.AT == true then return end
	if self.LastReload + 0.8 > CurTime() then return end
	self.LastReload = CurTime()
	self.Reloading = true
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	if self.AT == false then
		self.AT = true
		timer.Simple(.3,function() DoReload(self) end)
	end
	return
end

function DoReload(swep)
	if IsValid(swep) then
		if swep.Weapon:Clip1() >= swep.Primary.ClipSize || swep:Ammo1() <= 0 then 
			swep.AT = false 
			swep:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH ) 
			swep:SetBodygroup(1,1)
			if SERVER then
				timer.Simple(0.2, function() if IsValid(swep) then swep:EmitSound("weapons/shotgun/shotgun_cock.wav") end end)
			end
			timer.Simple(0.3, function() if IsValid(swep) then swep:SendWeaponAnim(ACT_SHOTGUN_PUMP) end end)
			return 
		end
		if swep.Reloading == true then
			swep:SetBodygroup(1,0)
			swep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
			swep:SendWeaponAnim( ACT_VM_RELOAD )
			swep.Owner:RemoveAmmo( 1, swep.Weapon:GetPrimaryAmmoType() )
			swep.Weapon:SetClip1( swep.Weapon:Clip1() + 1 )
			timer.Simple(.4,function() DoReload(swep) end)
		else
			swep.AT = false
			return
		end
	end
end