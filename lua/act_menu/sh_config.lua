DC_ActConfig = {
	[1] = {
		name = "Сесть в транспорт",
		class = {},
		command = function(ply, vehicle)
			if vehicle.wac_seatswitcher then
				for _, v in pairs(vehicle.seats) do
					if not IsValid(v:GetPassenger(0)) and not ply:InVehicle() then
						ply:EnterVehicle(v)
						return
					end
				end				

				return
			end 

			if vehicle.SetPassenger then
				vehicle:SetPassenger( ply )

				return
			end

			ply:EnterVehicle( vehicle )
		end,
		clientComand = function(ply, vehicle)
			return not vehicle:GetNWBool("carKeysVehicleLocked")
		end,
		material = Material("materials/mst_hud/seat.png"),
		sound = Sound("server/ui/click2.wav"),
		time = 1, -- 1.5
		id = 1,
	},

	[2] = {
		name = "Закрыть транспорт",
		class = {},
		command = function(ply, vehicle)
				if not vehicle then return end -- ! 
				local owner = vehicle:GetNWEntity("carKeysVehicleOwner")
				if (owner != NULL) and (owner:UniqueID() == ply:UniqueID()) then
					vehicle:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1, 7)) .. ".wav")
					vehicle:SetNWBool("carKeysVehicleLocked", true)
					vehicle.VehicleLocked = true

					if not (vehicle:WaterLevel() >= 1) then
						timer.Simple(0.5, function()
							if (vehicle:IsValid()) then
								vehicle:EmitSound("carkeys/lock.wav")
							end
						end)
					end
					rp.Notify(ply,NOTIFY_ERROR, 'Автомобиль закрыт')
				else                                       
					rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете закрыть данный транспорт, он не ваш!') 
					vehicle:EmitSound("doors/handle_pushbar_locked1.wav")
				end
		end,
		clientComand = function(ply, vehicle)
			return not vehicle:GetNWBool("carKeysVehicleLocked")
		end,
		material = Material("materials/mst_hud/lock.png"),
		sound = Sound("mst_vehicle/door_lock.mp3"),
		time = 0.5,
		id = 2,
	},

	[3] = {
		name = "Открыть транспорт",
		class = {},
		command = function(ply, vehicle)

			local owner = vehicle:GetNWEntity("carKeysVehicleOwner")
			if (owner != NULL) and (owner:UniqueID() == ply:UniqueID()) then
				if (vehicle:GetNWBool("carKeysVehicleAlarm")) then
					vehicle:SetNWBool("carKeysVehicleAlarm", false)
					vehicle:StopSound("carKeysAlarmSound")

					timer.Remove("carKeysLoopAlarm" .. ent:EntIndex())
					timer.Remove("carKeysAlarmLights" .. ent:EntIndex()) 
					--rp.Notify(ply, 'Сирена выключена') 
				end
				vehicle:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1, 7)) .. ".wav")
				vehicle:SetNWBool("carKeysVehicleLocked", false)
				vehicle.VehicleLocked = false  
				rp.Notify(ply, 'Автомобиль открыт')
			else
				rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете открыть данный транспорт, он не ваш!') 
				vehicle:EmitSound("doors/handle_pushbar_locked1.wav")
			end

		end,
		clientComand = function(ply, vehicle)
			return vehicle:GetNWBool("carKeysVehicleLocked")
		end,
		material = Material("materials/mst_hud/unlock.png"),
		sound = Sound("mst_vehicle/door_lock.mp3"),
		time = 0.5,
		id = 3,
	},

	----------
	[4] = {
		name = "Открыть капот",
		class = {"sim_fphys_vaz_2121", "sim_fphys_bmp2","sim_fphys_bmp2m", "sim_fphys_bmp1", "sim_fphys_btr70", "sim_fphys_uaz_3151","sim_fphys_uaz_3151_bk","sim_fphys_uaz_3151_ags","sim_fphys_uaz_3151_dshk","sim_fphys_uaz_3151_spg",     "sim_fphys_zil130_covered","sim_fphys_zil130","sim_fphys_zil130_musor",   "sim_fphys_vaz_2103","sim_fphys_vaz_2106", "sim_fphys_gaz24"},
		command = function(ply, vehicle)
			ply:ConCommand('say "/me открыл капот"') 
		end,
		clientComand = function(ply, vehicle)
		 	return 

		 	(vehicle:GetModel() == "models/sim_fphys_vaz_2121/vaz_2121.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("bonnet")) == Angle(0.000, 0.000, 0.000)) 	or  
		 	(vehicle:GetModel() == "models/sim_fphys_gaz24/gaz24.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("bonnet")) == Angle(0.000, 0.000, 0.000)) 	or  

		 	(vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151o.mdl" and  0 == vehicle:GetBodygroup(2))  or 
		 	(vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151c.mdl" and  0 == vehicle:GetBodygroup(3))	or 

			(vehicle:GetModel() == "models/vehicles/btr70/btr70_new.mdl" and  0 == vehicle:GetBodygroup(9)) 	or 
			
		 	(vehicle:GetModel() == "models/vehicles/vaz2103/vaz2103.mdl" and  0 == vehicle:GetBodygroup(10))	or 
		 	(vehicle:GetModel() == "models/vehicles/vaz2106/vaz2106.mdl" and  0 == vehicle:GetBodygroup(5)) 	or 
			
			(vehicle:GetModel() == "models/vehicles/bmp2/bmp2.mdl" and  0 == vehicle:GetBodygroup(8))			or   

			(vehicle:GetModel() == "models/mst_vehicles/bmp1/bmp1_afg.mdl" and  0 == vehicle:GetBodygroup(7))			or   

		 	((vehicle:GetModel() == "models/vehicles/zil130/zil130_musor.mdl" or vehicle:GetModel() == "models/vehicles/zil130/zil130.mdl" or vehicle:GetModel() == "models/vehicles/zil130/zil130_covered.mdl") and  0 == vehicle:GetBodygroup(1))	
		end,
		material = Material("materials/mst_hud/bonnet.png"),
		sound = Sound("mst_vehicle/bunnet_close.mp3"),
		time = 1.25,
		id = 4,
	},	
	
	[5] = {
		name = "Закрыть капот",
		class = {"sim_fphys_vaz_2121", "sim_fphys_bmp2","sim_fphys_bmp2m", "sim_fphys_bmp1", "sim_fphys_btr70","sim_fphys_uaz_3151","sim_fphys_uaz_3151_bk","sim_fphys_uaz_3151_ags","sim_fphys_uaz_3151_dshk","sim_fphys_uaz_3151_spg",     "sim_fphys_zil130_covered","sim_fphys_zil130","sim_fphys_zil130_musor",   "sim_fphys_vaz_2103","sim_fphys_vaz_2106", "sim_fphys_gaz24" },
		command = function(ply, vehicle)
			ply:ConCommand('say "/me закрыл капот"') 
		end,
		clientComand = function(ply, vehicle)
		 	return 

		 	(vehicle:GetModel() == "models/sim_fphys_vaz_2121/vaz_2121.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("bonnet")) == Angle(-90.000, 0.000, 0.000)) 	or  
		 	(vehicle:GetModel() == "models/sim_fphys_gaz24/gaz24.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("bonnet")) == Angle(75.000, 0.000, 0.000)) 	or  

		 	(vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151o.mdl" and  1 == vehicle:GetBodygroup(2))  or 
		 	(vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151c.mdl" and  1 == vehicle:GetBodygroup(3))	or 
			
			(vehicle:GetModel() == "models/vehicles/btr70/btr70_new.mdl" and  1 == vehicle:GetBodygroup(9)) 	or 
			
		 	(vehicle:GetModel() == "models/vehicles/vaz2103/vaz2103.mdl" and  1 == vehicle:GetBodygroup(10))	or 
		 	(vehicle:GetModel() == "models/vehicles/vaz2106/vaz2106.mdl" and  1 == vehicle:GetBodygroup(5))		or 
			
			(vehicle:GetModel() == "models/vehicles/bmp2/bmp2.mdl" and  1 == vehicle:GetBodygroup(8))			or  

			(vehicle:GetModel() == "models/mst_vehicles/bmp1/bmp1_afg.mdl" and  1 == vehicle:GetBodygroup(7))			or    

		 	((vehicle:GetModel() == "models/vehicles/zil130/zil130_musor.mdl" or vehicle:GetModel() == "models/vehicles/zil130/zil130.mdl" or vehicle:GetModel() == "models/vehicles/zil130/zil130_covered.mdl") and  1 == vehicle:GetBodygroup(1))	 
		end,
		material = Material("materials/mst_hud/bonnet_2.png"),
		sound = Sound("mst_vehicle/bunnet_close.mp3"),
		time = 1.25,
		id = 5,
	},	

	[31] = {
		name = "Открыть багажник",
		class = {"sim_fphys_vaz_2121", "sim_fphys_vaz_2103","sim_fphys_vaz_2106", "sim_fphys_gaz24"},
		command = function(ply, vehicle)
			ply:ConCommand('say "/me открыл багажник"') 
			--print(vehicle:GetManipulateBoneAngles( vehicle:LookupBone("boot")))
			--print(vehicle:GetManipulateBoneAngles( vehicle:LookupBone("boot")) == Angle(-100.000, 0.000, 0.000)) 
		end,
		clientComand = function(ply, vehicle)
		 	return (vehicle:GetModel() == "models/sim_fphys_vaz_2121/vaz_2121.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("boot")) == Angle(0.000, 0.000, 0.000)) 	or  
		 	(vehicle:GetModel() == "models/sim_fphys_gaz24/gaz24.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("boot")) == Angle(0.000, 0.000, 0.000)) or 
		 	(vehicle:GetModel() == "models/vehicles/vaz2103/vaz2103.mdl" and  0 == vehicle:GetBodygroup(9))	or 
		 	(vehicle:GetModel() == "models/vehicles/vaz2106/vaz2106.mdl" and  0 == vehicle:GetBodygroup(6))	 
		end,
		material = Material("materials/mst_hud/trunk_open.png"),
		sound = Sound("mst_vehicle/bunnet_close.mp3"),
		time = 1.25,
		id = 31,
	},	
	
	[32] = {
		name = "Закрыть багажник",
		class = {"sim_fphys_vaz_2121", "sim_fphys_vaz_2103","sim_fphys_vaz_2106", "sim_fphys_gaz24"},
		command = function(ply, vehicle)
			ply:ConCommand('say "/me закрыл багажник"') 
		end,
		clientComand = function(ply, vehicle)
		 	return (vehicle:GetModel() == "models/sim_fphys_vaz_2121/vaz_2121.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("boot")) == Angle(-100.000, 0.000, 0.000)) or  
		 	(vehicle:GetModel() == "models/sim_fphys_gaz24/gaz24.mdl" and vehicle:GetManipulateBoneAngles( vehicle:LookupBone("boot")) == Angle(-75.000, 0.000, 0.000)) or 
		 	(vehicle:GetModel() == "models/vehicles/vaz2103/vaz2103.mdl" and  1 == vehicle:GetBodygroup(9))	or 
		 	(vehicle:GetModel() == "models/vehicles/vaz2106/vaz2106.mdl" and  1 == vehicle:GetBodygroup(6))	 
		end,
		material = Material("materials/mst_hud/trunk_close.png"),
		sound = Sound("mst_vehicle/bunnet_close.mp3"),
		time = 1.25,
		id = 32,
	},	
	--
	[6] = {
		name = "Снять запаску",
		class = {"sim_fphys_hilux", "sim_fphys_hilux_sup","sim_fphys_hilux_m2b","sim_fphys_hilux_ags","sim_fphys_hilux_dshkm","sim_fphys_hilux_atgm","sim_fphys_hilux_spg", "sim_fphys_hilux_btr","sim_fphys_hilux_btr",			"sim_fphys_btr70","sim_fphys_uaz_3151","sim_fphys_uaz_3151_bk","sim_fphys_uaz_3151_ags","sim_fphys_uaz_3151_dshk","sim_fphys_uaz_3151_spg",   "sim_fphys_ural4320", "sim_fphys_ural4320_grad",    "sim_fphys_kamaz","sim_fphys_kamaz_kom", "sim_fphys_hmmwv_a","sim_fphys_hmmwv_a2","sim_fphys_hmmwv","sim_fphys_hmmwv2"},
		command = function(ply, vehicle)
			ply:ConCommand('say "/me взял запаску"') 
		end,
		clientComand = function(ply, vehicle)
		 	return (vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151o.mdl" and  0 == vehicle:GetBodygroup(15)) or   
		 		   (vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151c.mdl" and  0 == vehicle:GetBodygroup(15)) or
		 		   (vehicle:GetModel() == "models/vehicles/ural_4320/ural4320.mdl" and  0 == vehicle:GetBodygroup(5)) or 
		 		   (vehicle:GetModel() == "models/vehicles/ural_4320/ural4320_grad.mdl" and  0 == vehicle:GetBodygroup(2)) or
					
				   (vehicle:GetModel() == "models/vehicles/btr70/btr70_new.mdl" and  0 == vehicle:GetBodygroup(11)) or 
					
		 		   (vehicle:GetModel() == "models/vehicles/kamaz/zamak/kamaz1.mdl" and  0 == vehicle:GetBodygroup(7)) or 
		 		   (vehicle:GetModel() == "models/vehicles/kamaz/zamak/kamaz.mdl" and   0 == vehicle:GetBodygroup(5)) or 

		 		   (vehicle:GetModel() == "models/vehicles/hilux/coyota.mdl" and   0 == vehicle:GetBodygroup(3)) or 

		 		   (vehicle:GetModel() == "models/vehicles/hmmwv/hmmwv.mdl" and   1 == vehicle:GetBodygroup(16)) 
		end,
		material = Material("materials/mst_hud/wheel.png"),
		sound = Sound("server/ui/click2.wav"),
		time = 1.5,
		id = 6,
	},	
	
	[7] = {
		name = "Вернуть запаску",
		class = {"sim_fphys_hilux", "sim_fphys_hilux_sup","sim_fphys_hilux_m2b","sim_fphys_hilux_ags","sim_fphys_hilux_dshkm","sim_fphys_hilux_atgm","sim_fphys_hilux_spg", "sim_fphys_hilux_btr","sim_fphys_hilux_btr",			"sim_fphys_btr70","sim_fphys_uaz_3151","sim_fphys_uaz_3151_bk","sim_fphys_uaz_3151_ags","sim_fphys_uaz_3151_dshk","sim_fphys_uaz_3151_spg",   "sim_fphys_ural4320", "sim_fphys_ural4320_grad",   "sim_fphys_kamaz","sim_fphys_kamaz_kom", "sim_fphys_hmmwv_a","sim_fphys_hmmwv_a2","sim_fphys_hmmwv","sim_fphys_hmmwv2"},
		command = function(ply, vehicle)
			ply:ConCommand('say "/me вернул запаску"') 
		end,
		clientComand = function(ply, vehicle)
		 	return (vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151o.mdl" and  1 == vehicle:GetBodygroup(15)) or   
		 		   (vehicle:GetModel() == "models/vehicles/uaz_3151/uaz_3151c.mdl" and  1 == vehicle:GetBodygroup(15)) or
		 		   (vehicle:GetModel() == "models/vehicles/ural_4320/ural4320.mdl" and  1 == vehicle:GetBodygroup(5)) or 
		 		   (vehicle:GetModel() == "models/vehicles/ural_4320/ural4320_grad.mdl" and  1 == vehicle:GetBodygroup(2)) or 
				   
				   (vehicle:GetModel() == "models/vehicles/btr70/btr70_new.mdl" and  1 == vehicle:GetBodygroup(11)) or 

		 		   (vehicle:GetModel() == "models/vehicles/kamaz/zamak/kamaz1.mdl" and  1 == vehicle:GetBodygroup(7)) or 
		 		   (vehicle:GetModel() == "models/vehicles/kamaz/zamak/kamaz.mdl"  and  1 == vehicle:GetBodygroup(5)) or 

		 		   (vehicle:GetModel() == "models/vehicles/hilux/coyota.mdl" and   2 == vehicle:GetBodygroup(3)) or 

		 		   (vehicle:GetModel() == "models/vehicles/hmmwv/hmmwv.mdl" and   0 == vehicle:GetBodygroup(16))   
		end,
		material = Material("materials/mst_hud/wheel.png"),
		sound = Sound("server/ui/click2.wav"),
		time = 1.5,
		id = 7,
	},
 

	
}