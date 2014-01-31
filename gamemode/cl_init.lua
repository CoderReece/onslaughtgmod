//Conman, Xera
// and now matt.


include( "shared.lua" )
include( "sh_shop.lua" )
include( "cl_shop.lua" )
include( "cl_scoreboard.lua" )
include( "cl_deathnotice.lua" )
include( "cl_panels.lua" )
include( "cl_hud.lua")
include( "ose.lua" )
include( "sh_config.lua" )
include( "sh_util.lua")
PHASE = "BUILD"

MENU = nil

NextRound = 0
TimeLeft = GM.Config.BUILDTIME
local d = true
local Lstbeep = CurTime()
local tick = CurTime()

function GM:Initialize( )
	GAMEMODE.ShowScoreboard = false
	surface.CreateFont( "HUD",{font="akbar", size=20, weight=500, antialias=true, additive=true} )
	surface.CreateFont( "HUD2",{font="akbar", size=20, weight=600, antialias=true, additive=false}  )
	surface.CreateFont( "HUDs",{font="akbar", size=16, weight=500, antialias=true, additive=true}  )
	surface.CreateFont( "ScoreboardHead",{font="coolvetica", size=48, weight=500, antialias=true, additive=false}  )
	surface.CreateFont( "ScoreboardSub",{font="coolvetica", size=24, weight=500, antialias=true, additive=false} )
	surface.CreateFont( "ScoreboardText",{font="Tahoma", size=16, weight=1000, antialias=true, additive=false}  )
	surface.CreateFont( "Message",{font="Tahoma", size=18, weight=1000, antialias=true, additive=false}  )

	surface.CreateFont( "gab_test3",{font="Tahoma", size=48, weight=500, antialias=true, additive=true} )
	surface.CreateFont( "gab_test4",{font="Tahoma", size=96, weight=500, antialias=true, additive=true} )


end

function GM:PlayerInitialSpawn(ply) //Default weapons are always given
	ply.Items = table.Copy(defItems)
	ply.EItems = table.Copy(defEItems)

	ply.AMMOS = {}
end

function GM:SpawnMenuEnabled( )
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:InitPostEntity()
end

function GM:Think()
	if TimeLeft < 10 && TimeLeft > 0 && Lstbeep + 1 < CurTime() then
		surface.PlaySound(Sound("tools/ifm/beep.wav"))
		Lstbeep = CurTime()
	end
	if (tick + 4 < CurTime()) and LocalPlayer():KeyDown(IN_SPEED) then
		tick = CurTime()
		LocalPlayer().NextTime = CurTime()+CLASSES[LocalPlayer():GetNWInt("class")].COOLDOWN
		RunConsoleCommand("ose_special")
	end 
	TimeLeft = NextRound - CurTime()							
end

function GM:HUDShouldDraw(nm)
	if (nm == "CHudHealth" || nm == "CHudSecondaryAmmo" || nm == "CHudAmmo" || nm == "CHudBattery") then
		return false
	else
		return true
	end
end

function GM:HUDPaint()

	if GetConVarNumber( "cl_drawhud" ) == 0 then return false end

	if d && LocalPlayer():GetNetworkedInt( "money") == 0 then -- this bit of code stops the HUD from displaying if the usermessages haven't been sent yet
		return false
	else
		d = false
	end

	GAMEMODE:DrawHUD()
	GAMEMODE:HUDDrawTargetID()
end

local ag = 0
local br = 0
local con = 1
local bl = 0

function GM:RenderScreenspaceEffects( )
	if LocalPlayer():GetNWBool("pois", false) == true then
		ag = math.Approach(ag, 8 * 0.05, 0.0003)
		br = math.Approach(br, -0.21, -0.0003)
		con = math.Approach(con,1.5, 0.0003)
		bl = math.Approach(bl, 0.999, 0.002)

		local tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = ag
		tab[ "$pp_colour_addb" ] = 0
		tab[ "$pp_colour_brightness" ] = br
		tab[ "$pp_colour_contrast" ] = con
		tab[ "$pp_colour_colour" ] = 1
		tab[ "$pp_colour_mulr" ] = 0
		tab[ "$pp_colour_mulg" ] = 0
		tab[ "$pp_colour_mulb" ] = 0

		DrawColorModify( tab ) 
		
		DrawMotionBlur( 0.1, bl, 0.05)
	else
		ag = math.Approach(ag, 0, -0.001)
		br = math.Approach(br, 0, 0.001)
		con = math.Approach(con,1, -0.001)
		bl = math.Approach(bl,0, -0.01)
		
		tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = ag
		tab[ "$pp_colour_addb" ] = 0
		tab[ "$pp_colour_brightness" ] = br
		tab[ "$pp_colour_contrast" ] = con
		tab[ "$pp_colour_colour" ] = 1
		tab[ "$pp_colour_mulr" ] = 0
		tab[ "$pp_colour_mulg" ] = 0
		tab[ "$pp_colour_mulb" ] = 0

		DrawColorModify( tab ) 
		DrawMotionBlur( 0.1, bl, 0.05)
	end
end

CreateClientConVar("ose_hidetips", "0", true, false)
CreateClientConVar("ose_hud", "0", true, false)
CreateClientConVar("ose_defaultclass", "Scout", true, true)


tip = TIPS[1]

function ShowTip(lst)
	if GetConVarNumber( "ose_hidetips" ) == 1 then
		timer.Simple(TIP_DELAY,function() ShowTip(last) end)
		return
	end
	//surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" )
	local last = lst or 0
	if last >= #TIPS then last = 0 end
	tip = TIPS[last+1]
	last = last + 1
	timer.Simple(TIP_DELAY,function() ShowTip(last) end)
end

ShowTip()

function UpdateTime(um)
	NextRound = CurTime() + um:ReadLong()
	PHASE = um:ReadString()
end

usermessage.Hook("updatetime", UpdateTime)

function Cl_StartBattle(um)
	NextRound = CurTime() + GAMEMODE.Config.BATTLETIME
	PHASE = "BATTLE"
end

usermessage.Hook("StartBattle", Cl_StartBattle)

function Cl_StartBuild(um)
	NextRound = CurTime() + GAMEMODE.Config.BUILDTIME
	PHASE = "BUILD"
end

usermessage.Hook("StartBuild", Cl_StartBuild)

function UpdateBuild(um)
	GAMEMODE.Config.BUILDTIME = um:ReadLong()
end

usermessage.Hook("updatebuildtime", UpdateBuild)

function UpdateBattle(um)
	GAMEMODE.Config.BATTLETIME = um:ReadLong()
end

usermessage.Hook("updatebattletime", UpdateBattle)

Messages = {}

function Message(um)
	local txt = tostring(um:ReadString())
	local coltable = string.Explode(" ", um:ReadString())
	local msg = um:ReadBool() or false
	if msg then
		print(txt)
	end
	local col = Color(coltable[1], coltable[2], coltable[3], coltable[4])
	msg = {}
	msg.id = #Messages + 1
	msg.text = txt
	msg.colour = col
	msg.Time = CurTime()
	Messages[#Messages + 1] = msg
end

usermessage.Hook("ose_msg", Message)

local function GetTargetPos(ent)
	local attach = nil
	if ent:IsPlayer()
	|| ent:GetModel() == "models/zombie/classic.mdl"
	 || ent:GetModel() == "models/zombie/zombie_soldier.mdl"
	  || ent:GetModel() == "models/combine_soldier.mdl"
	  || ent:GetModel() == "models/combine_super_soldier.mdl"
	  || ent:GetModel() == "models/combine_soldier_prisonguard.mdl"
	   || ent:GetModel() == "models/police.mdl"
		|| ent:GetModel() == "models/zombie/fast.mdl"
		 || ent:GetModel() == "models/zombie/poison.mdl" then
		attach = ent:GetAttachment(2)
		end

		if attach then
			if ent:GetModel() == "models/zombie/classic.mdl" || ent:GetModel() == "models/zombie/zombie_soldier.mdl" then
				return attach.Pos + ent:GetAngles():Forward() * 2
			elseif ent:GetModel() == "models/police.mdl" || ent:GetModel() == "models/combine_super_soldier.mdl" || ent:GetModel() == "models/combine_soldier_prisonguard.mdl" || ent:GetModel() == "models/combine_soldier.mdl" then
				return attach.Pos + ent:GetAngles():Forward() * 8 + ent:GetAngles():Up() * 4 + ent:GetAngles():Right() * 4
			elseif ent:GetModel() == "models/zombie/fast.mdl" then
				return attach.Pos + ent:GetAngles():Forward() * 2
			else
				return attach.Pos
			end
		end

	return ent:OBBCenter()
end

function MdlMessage(um)
	local mdl = tostring(um:ReadString())
	local txt = tostring(um:ReadString())
	local coltable = string.Explode(" ", um:ReadString())
	local msg = um:ReadBool() or false
	--if msg then
	--	print(txt)
	--end
	--local col = Color(coltable[1], coltable[2], coltable[3], coltable[4])
	--msg = {}
	--msg.id = #Messages + 1
	--msg.text = txt
	--msg.colour = col
	--msg.Time = CurTime()
	--Messages[#Messages + 1] = msg


	local mdlmsg = vgui.Create( "onslaught_message" )
	mdlmsg.mdl:SetModel(mdl)
	mdlmsg.mdl:SetSize( 80,80 )

	local ent = ents.CreateClientProp(mdl) -- lol ailias filthy hack
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(Vector(0,0,0))
	ent:Spawn()
	ent:Activate()
	ent:PhysicsInit( SOLID_VPHYSICS )

	local dist = ent:BoundingRadius()*1.2
	local center = GetTargetPos(ent)
	--if center == ent:OBBCenter() then dist = ent:BoundingRadius()*1.2 else dist = ent:BoundingRadius()/3 end

	ent:Remove()

	mdlmsg.mdl:SetLookAt( center )
	mdlmsg.mdl:SetCamPos( center+Vector(-dist,-dist,dist) )
	mdlmsg.mdl:SetPos(244,20)

end

usermessage.Hook("ose_mdl_msg", MdlMessage)



