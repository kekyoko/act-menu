local closedelay = CreateClientConVar("vehicle_select_auto_close_delay",2.0,true,false)
local key = CreateClientConVar("veh_select_key", "E",true,false)
local autopick = CreateClientConVar("wep_select_auto_close_select",0,true,false)
local selectpack = CreateClientConVar("wep_select_sounds",1,true,false)
local use = CreateClientConVar("wep_select_use",1,true,false)
local heartbeat = CreateClientConVar("wep_select_heartbeat",1,true,false)
local sound = CreateClientConVar("wep_select_warp",1,true,false)
local cos, sin, abs, rad1, log, pow = math.cos, math.sin, math.abs, math.rad, math.log, math.pow
local endTime = SysTime() + 1.5
local startTime = SysTime()
local maxTime = 1.5
local mat = Material("materials/mst_hud/seat.png")
local isSelected = false
local menuOpened = false

// Taked from helix gamemode
local function PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
	local quadarc = {}

	-- Correct start/end ang
	startang = startang or 0
	endang = endang or 0

	-- Define step
	-- roughness = roughness or 1
	local diff = abs(startang - endang)
	local smoothness = log(diff, 2) / 2
	local step = diff / (pow(2, smoothness))

	if startang > endang then
		step = abs(step) * -1
	end

	-- Create the inner circle's points.
	local inner = {}
	local outer = {}
	local ct = 1
	local r = radius - thickness

	for deg = startang, endang, step do
		local rad = rad1(deg)
		local cosrad, sinrad = cos(rad), sin(rad) --calculate sin, cos

		local ox, oy = cx + (cosrad * r), cy + (-sinrad * r) --apply to inner distance
		inner[ct] = {
			x = ox,
			y = oy,
			u = (ox - cx) / radius + .5,
			v = (oy - cy) / radius + .5
		}

		local ox2, oy2 = cx + (cosrad * radius), cy + (-sinrad * radius) --apply to outer distance
		outer[ct] = {
			x = ox2,
			y = oy2,
			u = (ox2 - cx) / radius + .5,
			v = (oy2 - cy) / radius + .5
		}

		ct = ct + 1
	end

	-- QUAD the points.
	for tri = 1, ct do
		local p1, p2, p3, p4
		local t = tri + 1
		p1 = outer[tri]
		p2 = outer[t]
		p3 = inner[t]
		p4 = inner[tri]

		quadarc[tri] = {p1, p2, p3, p4}
	end

	-- Return a table of triangles to draw.
	return quadarc
end

// Taked from helix gamemode
local function DrawPrecachedArc(arc)
	for _, v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

// Taked from helix gamemode
local function DrawArc(cx, cy, radius, thickness, startang, endang, roughness, color)
	surface.SetDrawColor(color)
	DrawPrecachedArc(PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness))
end

local function PrecacheArc2(cx,cy,radius,thickness,startang,endang,roughness)
	local triarc = {}
	-- local deg2rad = math.pi / 180

	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness

	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0

	if startang > endang then
		step = math.abs(step) * -1
	end

	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
		table.insert(inner, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end


	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
		table.insert(outer, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end


	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end

		table.insert(triarc, {p1,p2,p3})
	end

	-- Return a table of triangles to draw.
	return triarc

end

local function DrawArc2(arc)
	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end
local function Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
	surface.SetDrawColor(color)
	DrawArc2(PrecacheArc2(cx,cy,radius,thickness,startang,endang,roughness))
end

local badnums = {
	[7]=true,
	[8]=true,
	[11]=true
}
local function drawSegments(pnl,sections,w,h,thicker)
	sections = math.max(sections,1)
	local dtime = RealTime()-pnl.ctime
	local animtime = .1

	local lerp = !pnl.invert and Lerp(dtime/animtime, 10, thicker and 291 or 288) or Lerp(dtime/animtime, 288, 0)

	local hover = pnl.selected

	local iter
	if badnums[sections] or sections > 15 then
		iter = 1
	else
		iter = thicker and 1 or 2
	end

	for i=0, sections-1 do
		local col = (i==hover and thicker) and Color(231,28,92) or Color(0,100,0, 240) --  Color(0,200,0, 255) or Color(0,0,0, 240)
		local spacer = sections > 1 and (thicker and 1 or 3) or 0
		local starta = i*360/sections + spacer/2 + (thicker and .5 or 0)
		local enda = starta+360/sections - spacer/2
		local thick = thicker and math.min(95.5,lerp) or math.min(90,lerp)


		render.SetStencilReferenceValue(i+1)
		Arc(w/2,h/2,lerp,thick, starta, enda, iter, col)


	end
end

local function OpenActSelect(veh_class)
	local _DC_ActConfig = {}
	isSelected = false

	local id = 1
	local init = false
	for _, v in ipairs(DC_ActConfig) do
		if ((table.Count(v.class) > 0) and !table.HasValue(v.class, veh_class)) or (v.clientComand and (v.clientComand(LocalPlayer(), LocalPlayer():GetEyeTrace().Entity) == false)) then continue end

		_DC_ActConfig[id] = v
		id = id + 1
		init = true
	end

	if !init then return end

	if not LocalPlayer():Alive() or
		(LocalPlayer():GetObserverMode() != OBS_MODE_NONE) or
		LocalPlayer():InVehicle() or
		(IsValid(g_ActSelect) and not g_ActSelect.invert)
	then return end

	menuOpened = true

	mat = Material("materials/mst_hud/seat.png")
	endTime = SysTime() + 1.5
	startTime = SysTime()
	maxTime = 1.5

	if g_ActSelect then g_ActSelect:Remove() end
	local sw,sh = ScrW(),ScrH()

	gui.SetMousePos(ScrW()/2,ScrH()/2)

	local radial = vgui.Create("EditablePanel")
	radial.ctime = RealTime()
	radial.lastact = RealTime()
	radial:SetSize(sw,sh)
	radial:Center()
	radial:MakePopup()
	radial:SetKeyboardInputEnabled(false)

	g_ActSelect = radial

	radial.selectedMdl = vgui.Create("DSprite",radial)
	radial.selectedMdl:SetSize(400,400)
	radial.selectedMdl:Center()
	radial.selectedMdl:SetPaintedManually(true)
	radial.selected = nil

	function radial.selectedMdl:OnMousePressed(mc)
		radial:OnMousePressed(mc)
	end

	radial.selectedName = vgui.Create("DLabel",radial)
	radial.selectedName:SetText("")
	radial.selectedName:SetPos(sw/2,sh/2+70)
	radial.selectedName:SetFont("Trebuchet24")
	radial.selectedName:SetTextColor(Color(255,255,255,200))
	radial.selectedName:SetExpensiveShadow(2,Color(0,0,0))

	radial.selectedDesc = vgui.Create("DLabel",radial)
	radial.selectedDesc:SetText("")
	radial.selectedDesc:SetPos(sw/2,sh/2+80)
	radial.selectedDesc:SetFont("Trebuchet24")
	radial.selectedDesc:SetTextColor(Color(255,255,255,200))
	radial.selectedDesc:SetExpensiveShadow(1,Color(0,0,0))

	function radial.selectedDesc:Update(item)
		self:SizeToContents()
		self:CenterHorizontal()
	end

	function radial:GetHovered()
		local sections = #_DC_ActConfig
		local mx,my = gui.MousePos()
		local hover = 0
		mx = ScrW()/2 - mx
		my = ScrH()/2 - my

		local ang = 180 - math.deg(math.atan2(my,mx))
		hover = math.floor(math.Remap(ang, 0, 360, 0, sections))

		return hover
	end

	//Paint the wheels.
	function radial:Paint(w,h)

		local dtime = RealTime()-self.ctime
		local animtime = .1

		if self.invert and dtime>animtime then return end //Don't draw anything once it's closed.

		local m = Matrix()
		local ang = math.cos(RealTime())/2
		local rad = -math.rad( ang )
		local x = w/2 - ( math.cos( rad ) * w / 2 + math.sin( rad ) * h / 2 )
		local y = -h/2 + ( math.sin( rad ) * w / 2 + math.cos( rad ) * h / 2 )
		local m = Matrix()
		m:SetAngles( Angle( 0, ang, 0 ) )
		m:SetTranslation( Vector( x, y, 0 ) )
		cam.PushModelMatrix( m )

		local sections = #_DC_ActConfig

		local x, y = self:LocalToScreen(0, 0);
		render.SetStencilEnable(true)
		render.ClearStencil()
		render.SetStencilTestMask(255)
		render.SetStencilWriteMask(255)
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_NEVER)
		render.SetStencilFailOperation(STENCIL_REPLACE)
		render.SetStencilZFailOperation(STENCIL_REPLACE)
		render.SetStencilPassOperation(STENCIL_KEEP)

		draw.NoTexture()

		//Define bars
		drawSegments(self,sections,w,h)

		//Draw bar fill
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		for i=0, sections do

			render.SetStencilReferenceValue(i+1)
			local col = Color(0,0,0,200)
			surface.SetDrawColor(col)
			surface.DrawRect(0,0,w,h)

		end

		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		local spacer = sections > 1 and 3 or 0
		local lerp = !self.invert and Lerp(dtime/animtime, 10, 288) or Lerp(dtime/animtime, 288, 0)
		for id=1, sections do

			render.SetStencilReferenceValue(id)

			local starta = (id-1)*360/sections + spacer/2
			local enda = starta+360/sections - spacer/2
			if IsValid(self.previews[id]) then
				local x,y = math.cos(math.rad(enda-(enda-starta)/2-0))*(lerp-48), -math.sin(math.rad(enda-(enda-starta)/2-0))*(lerp-48)
				local pw = !self.invert and Lerp(dtime/animtime, 10, 70) or Lerp(dtime/animtime, 180, 70)
				if sections > 12 then
					pw = math.min(pw - sections*2, pw)
				end
				self.previews[id]:SetPos(x+w/2-pw/2,y+h/2-pw/2)
				self.previews[id]:SetSize(pw,pw)
				self.previews[id]:PaintManual()
			end
		end


		//Draw outlines
		draw.NoTexture()
		render.SetStencilCompareFunction(STENCIL_GREATER)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		drawSegments(self,sections,w,h,true)
		// surface.DrawRect(x * -1, y * -1, ScrW(), ScrH());


		//Draw center circle
		local dtime = RealTime() - self.ctime
		local lerp = !self.invert and Lerp(dtime/.1, 10, 199) or Lerp(dtime/.1, 199, 0)

		if !self.invert or dtime < .1 then
			render.ClearStencil()
			render.SetStencilReferenceValue(1)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			//Define circle
			Arc(w/2,h/2,lerp-2,lerp-2,0,360,10,Color(255,255,255))

		end

		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		local mx,my = gui.MousePos()
		local cw,ch = sw/2,sh/2
		local dist = math.sqrt((mx-ScrW()/2)^2 + (my-ScrH()/2)^2)
		local hover = self:GetHovered()
		if dist > 196 then //Mouse in outer ring
			self:SetCursor("hand")
			if hover != self.selected then
				self:SelectItem(hover+1)
			end
		else
			self:SetCursor("arrow")
		end

		render.SetStencilEnable(false)

		cam.PopModelMatrix()
	end

	function radial:OnMousePressed(mc)
		local mx,my = gui.MousePos()

		local hover = self:GetHovered()
		local dist = math.sqrt((mx-ScrW()/2)^2 + (my-ScrH()/2)^2)

		if dist > 196 and mc==MOUSE_LEFT then -- dist > 196 and mc==MOUSE_LEFT
			local old = self.selected

			if old == hover then
				if _DC_ActConfig[hover+1] and (SysTime() > endTime) then
					net.Start("FriksActSystem")
						net.WriteUInt(_DC_ActConfig[hover+1].id, 6)
					net.SendToServer()

					self:Close()
				end
			else
				self:SelectItem(hover+1)
			end
			self.noauto = true

		else
			self:Close()
		end

	end

	function radial:SelectItem(num)


		local item = _DC_ActConfig[num]
		self.lastact = RealTime()

		if item and istable(item) then
			surface.PlaySound(_DC_ActConfig[num].sound)
			isSelected = true
			self.selected = num-1

			mat = item.material
			startTime = SysTime()
			endTime = SysTime() + item.time
			maxTime = item.time

			self.selectedMdl:SetMaterial(item.material)

			self.selectedMdl:SetSize(400,400)
			self.selectedMdl:Center()

			self.selectedName:SetText(item.name or "Неизвестно")
			self.selectedName:SizeToContents()
			self.selectedName:CenterHorizontal()

			self.selectedDesc:Update(item)
		end

	end

	function radial:OnMouseWheeled(delta)
		if delta < 0 then
			self:RunCommand("invprev")
		else
			self:RunCommand("invnext")
		end
	end

	local curslot,curslotpos = 0,0
	function radial:RunCommand(id)

	end

	function radial:Close( auto )
		menuOpened = false
		//Remove elements
		self.invert = true
		self.ctime = RealTime()
		//endTime = SysTime()-1
		timer.Simple(.1,function()
			if IsValid(self) then
				for k,v in pairs(self.previews)do
					v:Remove()
				end
			end
		end)
		self.selectedMdl:SetVisible(false)
		self.selectedName:SetVisible(false)
		self.selectedDesc:SetVisible(false)

		timer.Simple(.8, function() if IsValid(self) then self:Remove() end end)
	end


	//Set cursor of all children too
	radial.oldsetcur = radial.SetCursor
	function radial:SetCursor(new)
		if self.cursor == new then return end
		self.cursor = new
		self:oldsetcur(new)
		for k,v in pairs(self:GetChildren())do
			v:SetCursor(new)
		end
	end

	function radial:Think()
		self:SetMouseInputEnabled(!self.invert and input.IsKeyDown(_G["KEY_"..key:GetString():upper()]))

		if !isSelected and (SysTime() > endTime) then
			self:Close()

			--print(isSelected, SysTime(), endTime)
			net.Start("ActEnterVehicle")
			net.SendToServer()

			return
		end
	end

	//Create model previews on slices
	radial.previews = {}
	function radial:Update()
		//Clear old
		 self.selected = nil
		for k,v in pairs(self.previews) do v:Remove() end

		//self:SelectItem(1)

		//Create new
		for id, item in ipairs(_DC_ActConfig) do
			local model = vgui.Create("DImage",self)

			model:SetMaterial(item.material)

			local pw,ph = 1,1
			model:SetPos(ScrW()/2-pw/2,ScrH()/2-ph/2)
			model:SetSize(pw,ph)
			-- model.pitch = math.random(-35,35)
			model:SetPaintedManually(true)

			function model:OnMousePressed(mc)
				--print("=======================")
				--print(mc)
				radial:OnMousePressed(mc)
			end
			model.item = item

			self.previews[id] = model
		end
	end
	radial:Update()

end

local function CloseActSelect()
	if IsValid(g_ActSelect) and !g_ActSelect.invert then
		g_ActSelect:Close()
	end
end

//Hotkey opens menu
local hotkeydown = false
hook.Add("Think","OpenActSelect",function()
	if not IsValid(vgui.GetKeyboardFocus()) and not gui.IsConsoleVisible() then

		if input.IsKeyDown(_G["KEY_"..key:GetString():upper()]) then
			local ent = LocalPlayer():GetEyeTrace().Entity
			if !hotkeydown and IsValid(ent) and !LocalPlayer():InVehicle() and (ent:IsVehicle() or string.find(ent:GetClass(), "wac_") and ent:GetNWFloat('health') > 10) and (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) <= 45000) then
				if ent.IsSimfphyscar and ent:IsSimfphyscar() then
					OpenActSelect(ent:GetSpawn_List())
				elseif (ent.GetVehicleClass) then
					OpenActSelect(ent:GetVehicleClass())
				else
					OpenActSelect(ent:GetClass())
				end
				hotkeydown = true
			end
		elseif hotkeydown then
			CloseActSelect()
			hotkeydown = false
		end
	elseif hotkeydown then
		CloseActSelect()
		hotkeydown = false
	end
end)

hook.Add("HUDPaint", "ActDrawBar", function()
	if !menuOpened or !IsValid(g_ActSelect) or LocalPlayer():InVehicle()  then
		return
	end

	local x, y = ScrW() / 2, ScrH() / 2
	////
	local fraction = math.min((endTime - SysTime()) / maxTime, 1)
	local radius, thickness = 45, 6
	local startAngle = 90
	local endAngle = startAngle + (1 - fraction) * 360
	local color = ColorAlpha(color_white, fraction * 255)

	--DrawArc(x, y, radius, thickness, startAngle, endAngle, 2, color)
	////
	surface.SetDrawColor(Color(255, 255, 255, 200))
	surface.SetMaterial(texture.Get('SafeSystem::Background')) -- Material('SafeSystem::Background')
	surface.DrawTexturedRect((ScrW() - 118) / 2,(ScrH() - 118) / 2, 118, 118)

	local perc = math.Clamp((SysTime() - startTime) / (endTime - startTime), 0, 1)

	EZMASK.DrawWithMask(function()
		surface.SetDrawColor(color_white)
		surface.DrawPie(x, y, 136, 136, perc * 360)
	end, function()
		surface.SetDrawColor(color_white)
		surface.SetMaterial(texture.Get('SafeSystem::Circle')) -- 
		surface.DrawTexturedRect((ScrW() - 136) / 2,(ScrH() - 136) / 2, 136, 136)
	end)


	surface.SetDrawColor(color_white)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x-38,y-38,76,76)
end)
