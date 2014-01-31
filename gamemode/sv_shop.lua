util.AddNetworkString("OSE_ItemUpdate")
util.AddNetworkString("OSE_EItemUpdate")
util.AddNetworkString("OSE_AMMOUpdate")

function Pmeta:GiveItem(id,prf,random)
	if not (NEW_WEAPONS[id] or HL2_WEPS[id]) or self:HasItem(id,prf) then return end
	local tab
	if id >= #HL2_WEPS then
		tab = NEW_WEAPONS[id]
	else
		tab = HL2_WEPS[id]
	end
	if not tab then print("tab was nil") return end

	local prft = (tab.NOPRF and WEP_PREFIXES[1]) or WEP_PREFIXES[prf]
	local item = {id,prf}
	table.insert(self.Items,item)
	self:SaveItems()
	self:UpdateItems()
	if random then
		self:SendLua([[chat.AddText(Color(175,0,0),"[OSE] ",Color(255,255,255),"You found an ",Color(0,0,200),"]]..prft.NAME..tab.NAME..[[",Color(255,255,255)," from an enemy!")]])
	end
end
function Pmeta:BuyItem(id)
	if not NEW_WEAPONS[id] or self:HasItem(id,1) or self:GetNWInt("points") < NEW_WEAPONS[id].VALUE then return end
	self:AddPoints(-NEW_WEAPONS[id].VALUE)
	self:SendLua([[chat.AddText(Color(175,0,0),"[OSE] ",Color(255,255,255),"You bought ",Color(0,0,200),"]]..NEW_WEAPONS[id].NAME..[[",Color(255,255,255)," for ",Color(0,0,200),"]]..NEW_WEAPONS[id].VALUE..[[",Color(255,255,255)," points!")]])
	self:GiveItem(id,1)
	self:SendLua("ShopMenu(true)")
end
concommand.Add("buyid",	function(ply,cmd,arg)
							if not arg[1] then return end
							ply:BuyItem(tonumber(arg[1]))
						end)

function Pmeta:UpdateItems()
	print("Sent items")
	net.Start("OSE_ItemUpdate")
		net.WriteTable(self.Items)
	net.Send(self)
end
	
function Pmeta:UpdateEItems()
	print("Sent items")
	net.Start("OSE_EItemUpdate")
		net.WriteTable(self.EItems)
	net.Send(self)

	timer.Simple(0,function() self:UpdateAMMOs() end) //update ammos when we update our equipped items, so we don't call it anywhere else
end

function Pmeta:UpdateAMMOs()
	local ammotab = {["sct"]={},["sld"]={},["eng"]={},["snp"]={},["pyr"]={},["sup"]={}}
	for idx,tab in pairs(self.EItems) do
		print(idx)
		for k,v in pairs(tab) do
			if NEW_WEAPONS[v[1]] then
				local ammo = NEW_WEAPONS[v[1]].AD
				if ammo then
					for c,d in pairs(ammo) do
						table.insert(ammotab[idx],d)
					end
				end
			elseif HL2_WEPS[v[1]] then
				local ammo = HL2_WEPS[v[1]].AD
				if ammo then
					for c,d in pairs(ammo) do
						table.insert(ammotab[idx],d)
					end
				end
			end
		end
	end
	print("wrote table")
	net.Start("OSE_AMMOUpdate")
		net.WriteTable(ammotab)
	net.Send(self)
end

function Pmeta:SaveItems()
	PrintTable(self.Items)
	local str = ""
	if self.Items and not (self.Items == defItems) then //should really save this stuff somewhere.
		local items = self.Items
		for k,v in pairs(items)do
			if v[1] < 14 then continue end
			if str == "" then
				str = v[1]..":"..v[2]
			else
				str = str.."/"..v[1]..":"..v[2]
			end
		end
	end
	sql.Query("UPDATE ose_player_items SET items = '"..str.."' WHERE steam_id = '"..self:SteamID().."'")
end

function Pmeta:SaveEItems()
	if self.EItems and not (self.EItems == defEItems) then
		local savestrs = {}
		local items = self.EItems
		for c,d in pairs(items)do //classes
			local str2 = ""
			for k,v in pairs(d) do //items
				if str2 == "" then
					str2 = v[1]..":"..v[2]
				else
					str2 = str2.."/"..v[1]..":"..v[2]
				end
			end
			savestrs[c] = str2
		end	
		local savestr = ""
		for k,v in pairs(savestrs) do
			if savestr == "" then
				savestr = k.." = '"..v.."'"
			else
				savestr = savestr..", "..k.." = '"..v.."'"
			end
		end
		sql.Query("UPDATE ose_player_items SET "..savestr.." WHERE steam_id = '"..self:SteamID().."'")
	end
end

function Pmeta:AddPoints(pts)
	if not pts then return end
	self:SetNWInt("points",self:GetNWInt("points") + pts)
end	

function Pmeta:SetPoints(pts)
	if not pts then return end
	self:SetNWInt("points",pts)
end	

function GM:ShowHelp(ply)
	ply:SendLua([[InvMenu()]])
end

function GM:ShowTeam(ply)
	ply:SendLua([[ShopMenu()]])
end
	
function Pmeta:EquipItem(item,prf,cls)
	if not item or not prf then 
		return
	end
	if self:IsEquipped(item,prf) or not self:HasItem(item,prf) then
		return
	end
	local wep
	local class
	if item >= 14 then
		wep = NEW_WEAPONS[item]
		class = wep.CLASS
	else
		wep = HL2_WEPS[item]
		if not cls then return end //if cls is nil then we're screwed so stop here
		class = tonumber(cls)
	end
	for k,v in pairs(self.Hooks) do //If we already have hooks for the item we're switching out
		if string.find(v,item) then	//Remove them
			hook.Remove(v)
			table.remove(self.Hooks,k)
		end
	end
	if wep.HOOKS then
		for k,v in pairs(wep.HOOKS)do //Create weapon hooks
			hook.Add(k,self:EntIndex().."."..item.."."..k,v)
			table.insert(self.Hooks,self:EntIndex().."."..item.."."..k)
		end
	end
	print(class)
	self.EItems[convCTable[class]][wep.SLOT]={item,prf}
	
	self:SaveEItems()
	self:UpdateEItems()
	self:SendLua("InvMenu(true)")
end
concommand.Add("eqpid",function(ply,cmd,args) ply:EquipItem(tonumber(args[1]),tonumber(args[2]),args[3]) end)

function Pmeta:DeleteItem(item,prf)
	if not item or not prf then 
		return
	end
	if self:IsEquipped(item,prf) or not self:HasItem(item,prf) then
		return
	end
	if item < 14 and prf == 1 then return end //don't remove default items
	for k,v in ipairs(self.Items) do
		if v[1]==item and v[2]==prf then
			table.remove(self.Items,k)
			break
		end
	end

	self:SaveItems()
	self:UpdateItems()
	self:SendLua("InvMenu(true)")
end
concommand.Add("delid",function(ply,cmd,args) ply:DeleteItem(tonumber(args[1]),tonumber(args[2])) end)