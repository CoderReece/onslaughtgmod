-- This SWEP was generated by mblunk's swep factory.
SWEP.Base = "weapon_base"

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"
end

-- Visual/sound settings
SWEP.PrintName		= "SMG1"
SWEP.Category		= ""
SWEP.Slot			= 2
SWEP.SlotPos		= 4
SWEP.DrawAmmo		= true
SWEP.DrawCrosshair	= true
SWEP.ViewModelFlip	= true
SWEP.ViewModelFOV	= 64
SWEP.ViewModel		= "models/weapons/v_smg1.mdl"
SWEP.WorldModel		= "models/weapons/w_smg1.mdl"
SWEP.ReloadSound	= "weapons/pistol/pistol_reload1.wav"
//SWEP.HoldType		= "ar2"

-- Other settings
SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

-- SWEP info
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= "Because I can!"
SWEP.Instructions	= "Aim away from face!"

SWEP.firepitch = 100

-- Primary fire settings
SWEP.Primary.Sound				= "Weapon_SMG1.Single"
SWEP.Primary.Damage				= 2
SWEP.Primary.NumShots			= 1
SWEP.Primary.Recoil				= 1
SWEP.Primary.Cone				= 5
SWEP.Primary.Delay				= 0.10
SWEP.Primary.ClipSize			= 30
SWEP.Primary.DefaultClip		= 256
SWEP.Primary.Tracer				= 1
SWEP.Primary.Force				= 10
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "SMG1"

-- Secondary fire settings
SWEP.Secondary.Sound				= ""
SWEP.Secondary.Damage				= 10
SWEP.Secondary.NumShots				= 1
SWEP.Secondary.Recoil				= 1
SWEP.Secondary.Cone					= 3
SWEP.Secondary.Delay				= 0.01
SWEP.Secondary.ClipSize				= -1
SWEP.Secondary.DefaultClip			= 0
SWEP.Secondary.Tracer				= 1
SWEP.Secondary.Force				= 5
SWEP.Secondary.TakeAmmoPerBullet	= false
SWEP.Secondary.Automatic			= false
SWEP.Secondary.Ammo					= ""

-- Hooks
function SWEP:Initialize()
	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	local bullet = {}	-- Set up the shot
		bullet.Num = self.Primary.NumShots
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		if self.Owner:IsPlayer() then
			bullet.Spread = Vector( (self.Primary.Cone / 90)/4, (self.Primary.Cone / 90)/4, 0 )
		else
			bullet.Spread = Vector( self.Primary.Cone / 90, self.Primary.Cone / 90, 0 )
		end
		bullet.Tracer = self.Primary.Tracer
		bullet.Force = self.Primary.Force
		if self.Owner:IsPlayer() then
			bullet.Damage = self.Primary.Damage * 4
		else
			bullet.Damage = self.Primary.Damage
		end
		bullet.AmmoType = self.Primary.Ammo
	self.Owner:FireBullets( bullet )
	self.Owner:MuzzleFlash()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:EmitSound(Sound(self.Primary.Sound),340,self.firepitch)
	//self.Owner:ViewPunch(Angle( -self.Primary.Recoil, 0, 0 ))
	if !self.Owner:IsNPC() then
		if (self.Primary.TakeAmmoPerBullet) then
			self:TakePrimaryAmmo(self.Primary.NumShots)
		else
			self:TakePrimaryAmmo(1)
		end
	end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	self.firepitch = math.random(94,106)
	return true
end

function SWEP:Deploy()
	self.firepitch = math.random(94,106)
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
end

function SWEP:OnRestore()
self.firepitch = math.random(94,106)
end

function SWEP:Precache()
end

function SWEP:OwnerChanged()
end