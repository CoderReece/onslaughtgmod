if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

SWEP.Prefix = 1

if (CLIENT) then
	SWEP.PrintName			= "Magnum"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.HoldType			= "pistol"
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 1
end

SWEP.Base = "ose_base"

--Swep info and other stuff
SWEP.Author	= "Matt Damon"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Firing bullets into enemies."
SWEP.Instructions = "Primary : Fire a bullet."
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_357.mdl"
SWEP.WorldModel	= "models/weapons/w_357.mdl"
SWEP.Primary.ClipSize 		= 6
SWEP.Primary.Bullets 		= 1
SWEP.Primary.DefaultClip 	= 6
SWEP.Primary.Cone 			= 0.02
SWEP.Primary.Delay			= 0.3
SWEP.Primary.Damage 		= 50
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Primary.Sound 			= Sound("Weapon_357.Single")
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.Cone 		= 0.01
SWEP.Secondary.Bullets 		= 1
SWEP.Secondary.Damage 		= 22
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Delay		= 0.1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Sound		= Sound("Weapon_357.Single")

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack()) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	
	local dmgdiv = WEP_PREFIXES[self.Weapon.Prefix].DMG or 0
	local condiv = WEP_PREFIXES[self.Weapon.Prefix].CONE or 0
	local dmg = self.Primary.Damage - (self.Primary.Damage * dmgdiv)
	local cone = self.Primary.Cone - (self.Primary.Cone * condiv)
	self:ShootBullet(dmg, self.Primary.Bullets, cone)
	
	self.Weapon:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 )
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_PISTOL)

	self.Owner:ViewPunch(Angle(math.random(-5,0),math.random(-5,5),0))
end


function SWEP:SecondaryAttack()
end //Nothing.