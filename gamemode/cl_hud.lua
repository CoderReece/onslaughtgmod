if not string.FormattedTime then
	function string.FormattedTime(TimeInSeconds,Format)
		if not TimeInSeconds then TimeInSeconds = 0 end

		local i = math.floor( TimeInSeconds )
		local h,m,s,ms	=	( i/3600 ),
					( i/60 )-( math.floor( i/3600 )*3600 ),
					TimeInSeconds-( math.floor( i/60 )*60 ),
					( TimeInSeconds-i )*100

		if Format then
			return string.format( Format, m, s, ms )
		else
			return { h=h, m=m, s=s, ms=ms }
		end
	end
end

local Weaponclass = "weapon_none"
local Maxammo = 0
local Maxclip = 0
local lastphase = "none"
local TTimeleft = 0
local Maxmoney = 0
local ply = LocalPlayer()
local bkdrop = Color(31, 31, 31, 127)

function UnifiedBar(r,x,y,w,h,c,d,p,b,t)
	b = b or false
	p = p or 1
	p = math.Clamp(p,0,1)
	if GetConVarNumber( "ose_hud" ) == 1 then
		if b == false then
			draw.RoundedBox(r,x,y,w,h,d)
			if p*w > 2 then
				draw.RoundedBox(r,x+1,y+1,(w-2)*p,h-2,c)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x+w/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		else
			draw.RoundedBox(r,x-w,y,w,h,d)
			if p*w > 2 then
				draw.RoundedBox(r,(x-1)-(w-2)*p,y+1,(w-2)*p,h-2,c)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x-w/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		end
	else
		surface.SetDrawColor(c.r,c.b,c.g,c.a)
		surface.DrawRect(x,y,w*p,h)
		surface.SetDrawColor(d.r,d.b,d.g,d.a)
		surface.DrawOutlinedRect(x,y,w,h)
	end
end

function UnifiedSplitBar(r,x,y,w,h,c,d,p,b,t,n,s)
	p=p*n
	s = s or 0
	if GetConVarNumber( "ose_hud" ) == 1 then
		if b == false then
			for i=1,n do
				UnifiedBar(r,x+(w+s)*(i-1),y,w,h,c,d,p-i+1,b)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x+w*(n)/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		else
			for i=1,n do
				UnifiedBar(r,x-(w+s)*(i-1),y,w,h,c,d,p-i+1,b)
			end
			if t && ply:KeyDown(IN_WALK) then
				draw.SimpleTextOutlined(t,"HUD2",x-w*(n)/2,y,Color(255,255,255,255),1,0,1,Color(0,0,0,255))
			end
		end
	end
end

function GM:DrawHUD()
	local W,H = ScrW(), ScrH()
	local ply = LocalPlayer()
	if not ply:GetNWInt("class") or not CLASSES[ply:GetNWInt("class")] then return end
	local crnd = H/256
	local health = ply:Health()
	local armor = ply:Armor()
	if !ply:Alive() then health = 0 armor = 0 end
	local maxhealth = (PHASE == "BUILD" and 100) or CLASSES[ply:GetNWInt("class")].HEALTH
	local maxarmor = CLASSES[ply:GetNWInt("class")].ARMOR or 0
	if PHASE != lastphase then
		TTimeleft = 0
		lastphase = PHASE
	end
	if TTimeleft < TimeLeft then
		TTimeleft = TimeLeft
	end


	local moncolor = Color(100,255,100,95)
	local money = ply:GetNetworkedInt( "money")
	if money <= 2500 then
		moncolor = Color(255,100,100,95)
	end

	local rank = ply:GetNWInt("rank") or 1
	//local prevrank = RANKS[rank - 1] or RANKS[rank]
	local currank = RANKS[rank]
	local nextrank = RANKS[rank + 1] or RANKS[rank]
	local kills = math.Round(ply:GetNWInt("kills")) or 0

	local timecolor = Color(190, 200, 220, 95)
	if TimeLeft <= 30 && (math.Round(TimeLeft) / 2) == math.Round(TimeLeft / 2) then timecolor = Color(220, 100, 95, 95) end

	local cur_mag,alt_mag,mags,alt_mags,ammofraction,clipfraction,maxclips,clips,alts
	local wdraw = false

	if ply:Alive() && IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().Primary then
		wdraw = true
		local w = ply:GetActiveWeapon()
		local wt = w.Primary
		cur_mag = w:Clip1() or 0
		alt_mag = w:Clip2() or 0
		mags = ply:GetAmmoCount(w:GetPrimaryAmmoType()) or 0
		alt_mags = ply:GetAmmoCount(w:GetSecondaryAmmoType()) or 0

		if Weaponclass != w:GetClass() then
			Weaponclass = w:GetClass()
			Maxammo = wt.Maxammo or 0
			Maxclip = wt.ClipSize or 0
		end

		if cur_mag > Maxclip then Maxclip = cur_mag wt.ClipSize = Maxclip end
		if mags+cur_mag > Maxammo then Maxammo = mags wt.Maxammo = Maxammo end
		ammofraction = (mags)/(Maxammo)
		clipfraction = cur_mag/Maxclip

		maxclips = math.ceil(Maxammo/math.Clamp(Maxclip,1,math.huge))
		clips = math.floor(mags/math.Clamp(Maxclip,1,math.huge))
		alts = math.Clamp(alt_mags-1,-1,math.Round(W/36))
	end

	-- messages
	for k,v in pairs(Messages) do
		local col = v.colour
		local y = (H - 200) - ((CurTime() - v.Time) * 100) + (k * 14)
		draw.SimpleTextOutlined(v.text,"Message",W - 30,y,col,2,0,0.5,Color(50,50,50,255))
		if v.Time - CurTime() <= -4 then
			local newcol = Color(col.r,col.g,col.b,col.a - 10)
			v.colour = newcol
			if v.colour.a <= 0 then
				Messages[k] = nil
			end
		end
	end

	-- Player & Turret info
	local iterator = player.GetAll()
	table.Add(iterator,ents.FindByClass("npc_turret_floor"))
	table.Add(iterator,ents.FindByClass("npc_turret_ceiling"))
	for k, v in pairs(iterator) do
		local trace = {}
		trace.start = ply:GetPos() + Vector(0,0,40)
		trace.endpos = v:GetPos() + Vector(0,0,40)
		trace.filter = ply
		local trace = util.TraceLine( trace )

		if !trace.HitWorld then
			local spos = ply:GetPos()
			local tpos = v:GetPos()
			local dist = spos:Distance(tpos)

			if dist <= 1800 then
				local offset = -0.03333 * dist
				local pos = v:GetPos() + Vector(0,0,offset)
				pos = pos:ToScreen()
				if pos.visible == true then
					local alphavalue = math.Clamp(1200 - (dist/1.5),0,255)
					local outlinealpha = math.Clamp(900 - (dist/2),0,255)

					if v:IsPlayer() then
						local playercolour = team.GetColor(v:Team())
						if v != ply && v:Alive() then
							draw.SimpleTextOutlined(v:Name(), "HUD2", pos.x, pos.y - 10, Color(playercolour.r, playercolour.g, playercolour.b, alphavalue),1,1,1,Color(0,0,0,outlinealpha))
							if classid == 6 || ply:Alive() == false then
								local maxhealth = 150
								if PHASE == "BUILD" then 
									maxhealth = 100
								end
								UnifiedBar(crnd,pos.x-W*.03*maxhealth/100,pos.y+6,W*0.06*maxhealth/100,12,Color(191, 0, 0, 127*alphavalue/255),Color(31, 31, 31, 127*outlinealpha/255),v:Health()/maxhealth)
							end
						end
					else
						UnifiedBar(crnd,pos.x-W*.03,pos.y+6,W*0.06,12,Color(191, 0, 0, 127*alphavalue/255),Color(31, 31, 31, 127*outlinealpha/255),v:GetNWInt("health")/GAMEMODE.Config.TURRET_HEALTH)
					end
				end
			end
		end
	end


		local x,y = 0.02, 0.80
		local w,h = 0.208, 0.13

		-- main bottom pannels
		UnifiedBar(0, W*0.75,H*y, W*w, H*h,Color(50, 50, 50, 200),Color(255, 255, 255, 255))

		-- top bar
		local killneeded = nextrank.KILLS or 0
		local text = ""
		if kills > killneeded || rank >= #RANKS then
			text = kills
		else
			text = kills.."/"..killneeded.." For "..RANKS[rank + 1].NAME.." Rank ("..kills/killneeded..")"
		end

		if GetConVarNumber("ose_hidetips") != 1 then
			UnifiedBar(0,0,0,W,H*0.04,Color(50, 50, 50, 200),Color(255, 255, 255, 255))
			draw.SimpleText("TIP: "..tip,"HUD",W*0.01,H*0.006)
		else
			UnifiedBar(0,W*0.7,0,W*0.3,H*0.04,Color(50, 50, 50, 200),Color(255, 255, 255, 255))
		end
		draw.SimpleText("KILLS: "..text, "HUD",W*0.71,H*0.006)
		if ply:Alive() then
			UnifiedBar(0, W*x,H*y, W*w, H*h,Color(50, 50, 50, 200),Color(255, 255, 255, 255))
			-- health bar
			local itr = W / 5.02 * health/maxhealth - 2
			for i = 0, itr do
				local r = math.Clamp(255 - i,0,255)
				local g = math.Clamp((health / maxhealth)*255,0,255)
				surface.SetDrawColor(r, g, 10, 255)
				surface.DrawRect( W * 0.025 + i, H * 0.84, 1, H / 40 )
			end

			if armor > 0 then
				UnifiedBar(0,W * 0.025, H * 0.81, W / 5.02*armor/maxarmor, H / 40,Color(0, 0, 255, 64),Color(0,0,0,0),armor/maxarmor)
				draw.SimpleTextOutlined("Armor: "..armor.."/"..maxarmor,"ScoreboardText",W*0.03,H*0.8125,Color(255,255,255,255),0,0,1,Color(0,0,0,255))
			end

			UnifiedBar(0,W*0.025,H*0.84,W/5.02,H/40,Color(0, 0, 0, 0),Color(255, 255, 255, 255))
			draw.SimpleTextOutlined("Health: "..health.."/"..maxhealth,"ScoreboardText",W*0.03,H*0.8425,Color(255,255,255,255),0,0,1,Color(0,0,0,255))
			-- weapon bars
			if wdraw == true then
				if Maxammo > 0 then
					surface.SetDrawColor(0, 255, math.Clamp(clipfraction * 255, 0, 255), 255)
					surface.DrawRect( W * 0.755, H * 0.81, (W / 5.02)*math.abs(cur_mag)/Maxclip, H / 40 )

					surface.SetDrawColor(math.Clamp(255-clipfraction*255, 0, 255), math.Clamp(clipfraction*255, 0, 255), math.Clamp(clipfraction*255, 0, 255), 255)
					surface.DrawRect( W * 0.755, H * 0.835, (W / 5.02)*(mags-Maxclip+cur_mag)/(Maxammo), H / 160 )
					
					surface.SetDrawColor(0, 200, 0, 255)
					surface.DrawRect( W * 0.755, H * 0.835, (W / 5.02)*(mags-Maxclip)/(Maxammo), H / 160 )

					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawOutlinedRect( W * 0.755, H * 0.81, W / 5.02, H / 40 )
					surface.DrawOutlinedRect( W * 0.755, H * 0.81, W / 5.02, H / 32 )
					draw.SimpleTextOutlined( "Ammo: "..math.abs(cur_mag).."/"..mags, "ScoreboardText", W * 0.8, H * 0.8125, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
				end
				if alt_mags > 0 then
					draw.SimpleTextOutlined( "Alt: "..alt_mags, "ScoreboardText", W * 0.757, H * 0.8125, Color(255,255,255,255), 0, 0, 1, Color(0,0,0,255) )
				end
			end
		end
		-- right panel
		if TimeLeft <= 0 then TimeLeft = 0 end
		draw.DrawText("Money: "..math.Round(ply:GetNetworkedInt( "money")), "ScoreboardText", W * 0.03 , H * 0.874, MonCol,0)
		draw.DrawText("Points: "..tostring(LocalPlayer():GetNWInt("points")),"ScoreboardText",W*0.03,H*0.9,Color(255,255,255,255),0)
		draw.DrawText("Phase: "..PHASE, "ScoreboardText", W *0.757, H * 0.855, Color(255,255,255,255),0)
		draw.DrawText("Time Remaining: "..string.FormattedTime( TimeLeft, "%2i:%02i")  , "ScoreboardText", W *0.757 , H * 0.888, timecol,0)
end

function GM:HUDDrawTargetID( )
	if !LocalPlayer():Alive() then return end
	local tr = LocalPlayer( ):GetEyeTrace( )
	if not tr.Hit or not IsValid( tr.Entity ) then
		return
	end
	local W,H = ScrW(), ScrH()
	local ent = tr.Entity

	if ent.Turret then ent = ent.Turret end
	local own = ent:GetNWEntity("owner")
	if !IsValid(own) then return end

	if ent:GetClass() == "sent_spawpoint" then
		draw.SimpleTextOutlined(own:Nick().."'s spawnpoint", "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
	else
		local mdl = ent:GetModel()
		if MODELS[mdl].NAME then
			draw.SimpleTextOutlined(own:Nick().."'s "..MODELS[mdl].NAME, "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
		else
			draw.SimpleTextOutlined(own:Nick().."'s prop", "HUD2", W * 0.5, H * 0.9, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255) )
		end
	end
end
