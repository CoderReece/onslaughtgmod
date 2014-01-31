if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Scattergun"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

SWEP.Base = "ose_base_shotgun"

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Shoot and kill"
SWEP.Instructions = "Primary : 1 shell"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.Primary.ClipSize = 8
SWEP.Primary.Bullets = 10
SWEP.Primary.Damage = 10
SWEP.Primary.Delay = 0.6
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.Bullets = 30
SWEP.Secondary.Delay = 0.75
SWEP.Secondary.Damage = 10
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"
SWEP.Secondary.Sound = Sound("Weapon_Shotgun.Double")

function SWEP:SecondaryAttack( ) //sorry.
end
