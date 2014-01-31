function ReceiveItems(um)
	print("Recieved Items")
	LocalPlayer().Items = net.ReadTable() or {}
end
net.Receive("OSE_ItemUpdate",ReceiveItems)

function ReceiveEItems(um)
	print("Recieved EItems")
	LocalPlayer().EItems = net.ReadTable() or {}
	PrintTable(LocalPlayer().EItems)
end
net.Receive("OSE_EItemUpdate",ReceiveEItems)

function RecieveAMMOs(um)
	print("Received AMMOs")
	LocalPlayer().AMMOS = net.ReadTable() or {}
end
net.Receive("OSE_AMMOUpdate",RecieveAMMOs)

local W, H = ScrW(), ScrH()

----------INVENTORY---------- Not done.
if INV then INV:Remove() end
INV = nil
function InvMenu(bool)
	if bool and INV then
		print("Removing")
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
		INV:Remove()
		return
	end
	if (not INV or not INV:IsValid()) and not (LocalPlayer():GetNWInt("class") < 1) then
		print("Rebuilding")
		gui.EnableScreenClicker( true )
		RestoreCursorPosition()
		INV = vgui.Create("DFrame")
		INV:SetTitle("Onslaught - Your Inventory")
		INV:ShowCloseButton(true)
		INV:SetDraggable(false)
		INV:SetSize(800,700)
		INV:SetPos(W*0.10,H * 0.10)
		INV.Close = 	function()
								if INV and INV:IsValid( ) and INV:IsVisible( ) then
									INV:SetVisible( false )
								end
								RememberCursorPosition( )
								gui.EnableScreenClicker( false )
							end
		INV:SetSkin("ose")
		local inventory = vgui.Create("DPanel", INV )
		inventory:SetSize(450,600)

		local multi = vgui.Create("DComboBox",inventory)
		inventory.MultiChoice = multi
		multi:SetPos(2,0)
		multi:AddChoice("Scout",1)
		multi:AddChoice("Soldier",2)
		multi:AddChoice("Engineer",3)
		multi:AddChoice("Sniper",4)
		multi:AddChoice("Pyro",5)
		multi:AddChoice("Support",6)
		multi.class = 1
		local item = vgui.Create("DPanel",INV)
		item:SetSize(350,360)
		/*item.Paint = 	function(x,y)
							draw.RoundedBox(4,5,0,340,360,Color(50,50,50))
							draw.RoundedBox(4,8,100,335,140,Color(75,75,75))
							draw.RoundedBox(4,8,240,335,115,Color(10,10,10))
						end*/
		item.Model = vgui.Create("DModelPanel",item)
		item.Model:SetSize(96,96)
		item.Model:SetPos(132,0)
		//item.Model:SetModel("models/weapons/w_IRifle.mdl")
		item.Name = vgui.Create("DLabel",item)
		item.Name:SetPos(20,98)
		item.Name:SetText("Item Name")
		item.Name:SetTextColor(Color(255,255,255))
		item.Name:SetSize(325,22)
		
		item.Desc = vgui.Create("DLabel",item)
		item.Desc:SetPos(10,75)
		item.Desc:SetSize(335,120)
		item.Desc:SetTextColor(Color(255,255,255))
		item.Desc:SetText("I am an item description.\nI provide you with all the info you need to know about an item.")
		
		item.PDesc = vgui.Create("DLabel",item)
		item.PDesc:SetPos(10,150)
		item.PDesc:SetSize(335,120)
		item.PDesc:SetTextColor(Color(255,255,255))
		item.PDesc:SetText("I am the prefix description.\nI provide you information about an item's prefix.")
							
		local person = vgui.Create("DPanel",INV) //Contains the equipped items etc.
		person:SetSize(350,360)
		/*person.Paint = 	function(x,y)
							draw.RoundedBox(4,5,0,340,360,Color(75,75,75))
						end*/

		person.MPanels = {}

		person.List = vgui.Create("DIconLayout",person)
		person.List:SetVisible(true)
		person.List:SetSize(350,360)
		person.List:DockPadding(4,4,4,4)
		function person.List:Update()
			self:Clear(true)
			for k,v in ipairs(LocalPlayer().EItems[convCTable[multi.class]]) do
					local wep = {}
					local desc = ""
					if v[1] >= 14 then
						wep = table.Copy(NEW_WEAPONS[v[1]]) //need to duplicate so we can edit the table
					else
						wep = table.Copy(HL2_WEPS[v[1]])
					end
					if not wep then continue end
					//if (person.MPanels[k] and person.MPanels[k].Name == wep.NAME) then continue end
					local ent = ents.CreateClientProp(wep.MODEL) -- lol ailias filthy hack
					ent:SetAngles(Angle(0,0,0))
					ent:SetPos(Vector(0,0,0))
					ent:SetModel(wep.MODEL)
					ent:Spawn()
					ent:Activate()	
					ent:PhysicsInit( SOLID_VPHYSICS )
					local ico = person.List:Add("OSEModelPanel")
					ico:SetWeapon(v[1])
					/*ico.Paint = function(self,w,h)
						draw.RoundedBox(0,0,0,w,h,Color(200,200,200,100))
					end*/
					if v[2] > 1 then
						if string.StartWith(wep.NAME,"The ") then
							wep.NAME = wep.NAME:sub(-(string.len(wep.NAME)-4),string.len(wep.NAME))
						end
					end
					ico.Name = WEP_PREFIXES[v[2]].NAME..wep.NAME
					ico.Desc = wep.DESC
					ico.Prefix = v[2]

					local PrevMins, PrevMaxs = ent:GetRenderBounds()
		    		ico:SetCamPos((PrevMins:Distance(PrevMaxs)*Vector(0.75, 0.75, 0.5))+(wep.OFFSET or Vector(0,0,0)))
					ico:SetLookAt((PrevMaxs + PrevMins)/2)

					ico.OnCursorEntered = function()
						item.Model:SetModel(person.MPanels[k].Entity:GetModel())
						item.Model:SetLookAt(person.MPanels[k]:GetLookAt())
						item.Model:SetCamPos(person.MPanels[k]:GetCamPos())

						item.Name:SetText(string.gsub(person.MPanels[k].Name,"The","")) //Removes any The's.
						item.Desc:SetText(person.MPanels[k].Desc)
						item.PDesc:SetText(WEP_PREFIXES[person.MPanels[k].Prefix].DESC)
					end
					ico.OnCursorExited = function()
						item.Model:SetModel("")
						item.Name:SetText("Item Name")
						item.Desc:SetText("I am an item description.\nI provide you with all the info you need to know about an item.")
						item.PDesc:SetText("I am the prefix description.\nI provide you information about an item's prefix.")
					end
					ico:InvalidateLayout( true )
					//self:AddItem(ico)
					ico:SetSize(k==3 and 256 or 64,k==3 and 256 or 64)
					person.MPanels[k]=ico
					ent:Remove()
			end
		end

		inventory.IconList = vgui.Create( "DPanelList", inventory )
			inventory.IconList:SetPos(0,22)
			inventory.IconList:EnableVerticalScrollbar( true )
			inventory.IconList:EnableHorizontal( true )
			inventory.IconList:SetPadding( 4 )
			inventory.IconList:SetVisible( true )
			inventory.IconList:SetSize(450,596) --7 rows, 7 columns
			/*function inventory.IconList:Paint(x,y)
				draw.RoundedBox(4,0,0,x,y,Color(50,50,50))
			end*/
		function inventory.IconList:Update()
			self:Clear(true)
			for x,s in ipairs(LocalPlayer().Items) do
				local class = multi.class or LocalPlayer():GetNWInt("class")
				if s[1] then
					if LocalPlayer():IsEquipped(s[1],s[2],class) then continue end
					local wep = {}
					local desc = ""
					local sendclass = false
					if s[1] >= 15 then
						wep = NEW_WEAPONS[s[1]]
						if not (wep.CLASS == class) then continue end
					else
						wep = HL2_WEPS[s[1]]
						sendclass = true
						if not table.HasValue(WEAPON_SET[class],s[1]) then continue end
					end
					desc = wep.DESC.."\n"
					local ent = ents.CreateClientProp(wep.MODEL)
					ent:SetAngles(Angle(0,0,0))
					ent:SetPos(Vector(0,0,0))
					ent:Spawn()
					ent:Activate()
					ent:PhysicsInit( SOLID_VPHYSICS )
					local ico = vgui.Create( "DModelPanel",inventory)
					ico.Name = WEP_PREFIXES[s[2]].NAME..wep.NAME
					ico.Desc = wep.DESC
					ico.Prefix = s[2]
					ico:SetModel(wep.MODEL)
					ico.DoClick = 	function(ico) 	
											local icomenu = DermaMenu()
											icomenu:AddOption("Equip this item", 	function()
																						RunConsoleCommand("eqpid",s[1],s[2],(sendclass and class) or nil)
																					end)
											if s[1] >= 14 then
												icomenu:AddOption("Delete this item",	function()
																							RunConsoleCommand("delid",s[1],s[2])
																						end)
											end
											icomenu:Open()
									end
					ico:SetSize(96,96)
					
					ico.OnCursorEntered = function()
						item.Model:SetModel(wep.MODEL)
						item.Model:SetLookAt(ico:GetLookAt())
						item.Model:SetCamPos(ico:GetCamPos())
						item.Name:SetText(ico.Name)
						item.Desc:SetText(ico.Desc)
						item.PDesc:SetText(WEP_PREFIXES[ico.Prefix].DESC)
					end
					ico.OnCursorExited = function()
						item.Model.Entity:Remove()
						item.Name:SetText("Item Name")
						item.Desc:SetText("I am an item description.\nI provide you with all the info you need to know about an item.")
						item.PDesc:SetText("I am the prefix description.\nI provide you information about an item's prefix.")
					end
					
					local PrevMins, PrevMaxs = ent:GetRenderBounds()
		    		ico:SetCamPos(PrevMins:Distance(PrevMaxs)*Vector(0.75, 0.75, 0.5)+(wep.OFFSET or Vector(0,0,0)))
					ico:SetLookAt((PrevMaxs + PrevMins)/2)

					ico:InvalidateLayout( true )
					self:AddItem(ico)
					ent:Remove()
				end
			end
		end
		multi.OnSelect = function(self,idx,str,val)
											self.class = val
											inventory.IconList:Update()
											person.List:Update()
										end
		multi:ChooseOption(CLASSES[LocalPlayer():GetNWInt("class")].NAME,LocalPlayer():GetNWInt("class"))

		//inventory.IconList:Update()
		//person.List:Update()

		local vh = vgui.Create("DVerticalDivider",INV)
		function vh.m_DragBar:OnMousePressed() end
		vh:SetSize(350,728)
		vh:SetTopHeight(364)
		vh:SetDividerHeight(2)
		vh:SetTop(person)
		vh:SetBottom(item)
		
		local dh = vgui.Create("DHorizontalDivider",INV)
		function dh.m_DragBar:OnMousePressed() end
		dh:SetSize(800,728)
		dh:SetPos(0,22)
		dh:SetLeftWidth(450)
		dh:SetLeft(inventory)
		dh:SetRight(vh)
		dh:SetDividerWidth(2)
		
	elseif INV and not bool then
		print("Opening")
		INV:SetVisible(true)
		gui.EnableScreenClicker( true )
		RestoreCursorPosition()
	end
end

------------STORE------------
if SHOP then SHOP:Remove() end

SHOP = nil
function ShopMenu(bool)
	if bool and SHOP then
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
		SHOP:Remove()
		return
	end
	if not SHOP or not SHOP:IsValid() then
		print("Rebuilding.")
		SHOP = vgui.Create("DFrame")
		SHOP:SetTitle("Onslaught Store")
		SHOP:ShowCloseButton(true)
		SHOP:SetDraggable(false)
		SHOP:SetSize(800,400)
		SHOP:SetPos(W * 0.10,H * 0.10)
		SHOP.Close = 	function()
								if SHOP and SHOP:IsValid( ) and SHOP:IsVisible( ) then
									SHOP:Remove()
								end
								RememberCursorPosition( )
								gui.EnableScreenClicker( false )
							end
		SHOP:SetSkin("ose")
		local menu = vgui.Create("DPanel",SHOP) //Info + Buy
		menu:SetSize(350,400)
		/*menu.Paint = function(w,h)
			draw.RoundedBox(4,0,0,350,400,Color(40,40,40))
			draw.RoundedBox(4,0,100,346,300,Color(75,75,75))
		end*/
		
		menu.Model = vgui.Create("DModelPanel",menu) //Model of weapon
		menu.Model:SetSize(128,128) //huge
		menu.Model:SetPos(104,0)
		
		menu.Name = vgui.Create("DLabel",menu) //Name of weapon
		menu.Name:SetText("Item Name")
		menu.Name:SetSize(345,22)
		menu.Name:SetPos(5,104)
		menu.Name:SetTextColor(Color(255,255,255))
		
		menu.Desc = vgui.Create("DLabel",menu) //Description of weapon
		menu.Desc:SetText("I am a item description.\nI tell you stuff about a weapon.\nClick on one to continue!")
		menu.Desc:SetSize(345,300)
		menu.Desc:SetPos(5,22)
		menu.Desc:SetTextColor(Color(255,255,255))
		
		local mubutton = vgui.Create("DButton",menu)
		menu.Button = mubutton //Buy button
		menu.Button:SetText("BUY ME!")
		menu.Button:SetSize(300,100)
		menu.Button:SetPos(25,275) //175-150
		menu.Button:SetVisible(false)
		menu.Button:SetColor(Color(100,100,100,255))
		menu.Button.DoClick = function(mubutton)
			RunConsoleCommand("buyid", mubutton.item)
		end
		
		local seller = vgui.Create("DPanel",SHOP) //List of items
		seller.Label = vgui.Create( "DLabel", seller ) //Instructions
		seller.Label:SetPos(2,0)
		seller.Label:SetText( "Click on an icon to view information." )
		seller.Label:SetTextColor( Color( 10, 10, 10, 255 ) )
		seller.Label:SizeToContents( )

		/*seller.IconList = {}
		seller.IconListCollapse = {}*/
		
		seller.IconListScroll = vgui.Create("DScrollPanel",seller)
		seller.IconListScroll:SetPos(0,22)
		seller.IconListScroll:Dock(FILL)
		
		seller.IconList = vgui.Create( "DListLayout", seller.IconListScroll ) //Icon list
		seller.IconList:Dock(FILL)
		seller.IconList:SetVisible( true )
		seller.IconList:SetSize(450,600)
		
		seller.IcoList ={}
		print("Shop Start")
		PrintTable(NEW_WEAPONS)
		for x,s in pairs( NEW_WEAPONS ) do
			if not LocalPlayer():HasItem(x,1) and not table.HasValue(seller.IcoList,x) then
				local ent = ents.CreateClientProp(s.MODEL) -- lol ailias filthy hack
				ent:SetAngles(Angle(0,0,0))
				ent:SetPos(Vector(0,0,0))
				ent:Spawn()
				ent:Activate()
				ent:PhysicsInit( SOLID_VPHYSICS )
				
				local panel = seller.IconList:Add("DPanel")	//Item
				panel:SetSize(450,75)
				
				local label = vgui.Create("DLabel",panel)	//Item name
				label:SetSize(354,75)
				label:SetPos(98,10)
				label:SetColor(Color(10,10,10,255))
				label:SetFont("ScoreboardHead")
				label:SetText(s.NAME)
				

				local ico = vgui.Create( "DModelPanel",panel )	//Item model
				ico:SetPos(5,0)
				ico:SetModel(s.MODEL)
				ico:SetSize(64,64)
				ico:SetToolTip( s.NAME.."\n"..s.DESC )

				local PrevMins, PrevMaxs = ent:GetRenderBounds()
    			ico:SetCamPos(PrevMins:Distance(PrevMaxs)*Vector(0.75, 0.75, 0.5)+(s.OFFSET or Vector(0,0,0)))
				ico:SetLookAt((PrevMaxs + PrevMins)/2+(s.LOOKAT or Vector(0,0,0)))

				ico:InvalidateLayout( true )
				table.insert(seller.IcoList,x)
				ent:Remove()
				
				local test = vgui.Create("DButton",panel)	//Allows the item to show when clicking on any part of the panel.
				test:SetSize(450,75)
				test.Paint = function() //Makes it insisible. Yay.
								return true
							end

				test.DoClick = function()
					menu.Model:SetModel(s.MODEL)
					menu.Model:SetLookAt(ico:GetLookAt())
					menu.Model:SetCamPos(ico:GetCamPos())
					menu.Name:SetText(s.NAME)
					menu.Desc:SetText(s.DESC)
					menu.Button:SetVisible(true)
					menu.Button.item = x
				end

			end
		end
		print("Shop end")
		local dh = vgui.Create("DHorizontalDivider",SHOP)
		function dh.m_DragBar:OnMousePressed() end
		dh:SetSize(800,400)
		dh:SetPos(0,22)
		dh:SetLeftWidth(450)
		dh:SetLeft(seller)
		dh:SetRight(menu)
		dh:SetDividerWidth(2)
		seller:Dock(FILL)
	else
		print("Opening.")
		SHOP:SetVisible(true)
	end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
end