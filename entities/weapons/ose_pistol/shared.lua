if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

SWEP.Prefix = 1

if (CLIENT) then
	SWEP.PrintName			= "Pistol"
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
SWEP.ViewModel	= "models/weapons/v_pistol.mdl"
SWEP.WorldModel	= "models/weapons/w_pistol.mdl"
SWEP.Primary.ClipSize 		= 18
SWEP.Primary.Bullets 		= 1
SWEP.Primary.DefaultClip 	= 18
SWEP.Primary.Cone 			= 0.02
SWEP.Primary.Delay			= 0.1
SWEP.Primary.Damage 		= 12
SWEP.Primary.Automatic 		= false
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

function SWEP:SecondaryAttack()
end //Nothing.