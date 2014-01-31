function GM:SelectProp( ent )
	if not IsValid( ent ) then
		return
	end
	if not ent:GetClass( ) == "sent_prop" || not ent:GetClass() == "sent_ladder" then
		return
	end
	if not table.HasValue( self.SaveProps, ent ) then
		ent:SetColor( Color(255, 0, 0, 255 ))
		table.insert( self.SaveProps, ent )
	end
end

function GM:DeselectProp( ent )
	if not IsValid( ent ) then
		return
	end
	if not ent:GetClass( ) == "sent_prop" || not ent:GetClass( ) == "sent_ladder" then
		return
	end
	for k,v in pairs( self.SaveProps ) do
		if v == ent then
			table.remove( self.SaveProps, k )
			ent:UpdateColour( )
			break
		end
	end
end

function GM:DeselectAll( )
	for k,v in pairs( self.SaveProps ) do
		if IsValid( v ) and (v:GetClass( ) == "sent_prop" || v:GetClass() == "sent_ladder") then
			v:UpdateColour( )
		end
	end
	self.SaveProps = { }
end

concommand.Add( "prop_save", function( pl, cmd, args )
	if not pl:IsAdmin( ) then
		return
	end

	pl:StripWeapon( "swep_select" )

	if #GAMEMODE.SaveProps == 0 then
		return
	end

	local save = { }

	for k,v in pairs( GAMEMODE.SaveProps ) do
		if IsValid( v ) then
			local pos = v:GetPos( )
			local ang = v:GetAngles( )
			local t = { class = v:GetClass(), model = v:GetModel( ), pos = { x = pos.x, y = pos.y, z = pos.z }, ang = { p = ang.p, y = ang.y, r = ang.r } }
			table.insert( save, t )
		end
	end

	save.map = game.GetMap( )

	if not file.Exists( "onslaught_saves" ) then
		file.CreateDir( "onslaught_saves" )
	end

	file.Write( "onslaught_saves/" .. ( args[ 1 ] != nil && args[ 1 ] || game.GetMap( ) .. os.date( "%H%M%S" ) ) .. ".txt", util.TableToKeyValues( save ) )

	GAMEMODE:DeselectAll( )
end )

local function makeprop( class, mdl, pos, ang, owner )
	class = class or "sent_prop"
	local ent = ents.Create(class)
	ent:SetModel( mdl )
	ent:SetPos( Vector( pos.x, pos.y, pos.z ) )
	ent:SetAngles( Angle( ang.p, ang.y, ang.r ) )
	ent.Owner = owner
	ent:Spawn( )
	local ed = EffectData( )
	ed:SetEntity( ent )
	util.Effect( "PropSpawn", ed )
end

concommand.Add( "prop_load", function( pl, cmd, args )
	if not pl:IsAdmin( ) or not args[ 1 ] or not file.Exists( "onslaught_saves/" .. args[ 1 ] .. ".txt" ) then
		return
	end

	local read = util.KeyValuesToTable( file.Read( "onslaught_saves/" .. args[ 1 ] .. ".txt" ) )

	if game.GetMap( ) != read.map then
		pl:ChatPrint( "Must load save on same map as it was saved on!" )
		pl:ChatPrint( "This is to ensure that no props go outside of the map." )
		return
	end

	read.map = nil

	local time = 0

	for k,v in pairs( read ) do
		timer.Simple( k * .05, function() makeprop( v.class, v.model, v.pos, v.ang, pl) end )
		time = time + .05
	end

	timer.Simple( time, function( ) for k,v in pairs( player.GetAll( ) ) do v:ChatPrint( "Finished loading!" ) end end )
end )