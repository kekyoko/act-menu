util.AddNetworkString("FriksActSystem")																																																																																	-- Codded by Friks(https://steamcommunity.com/id/9871275127721)
util.AddNetworkString("ActEnterVehicle")

hook.Add( "PlayerUse", "ActSystem_CustomUseVehicle", function( ply, ent )
	if ( !IsValid( ent ) or ent:IsVehicle() and string.find(ent:GetClass(), "vehicle") or ent:GetClass():lower() == "gmod_sent_vehicle_fphysics_wheel" or not ent:GetClass() == "gmod_sent_vehicle_fphysics_gaspump") then return false end
end )
 
net.Receive("FriksActSystem", function(_, ply)
	local actID = net.ReadUInt(6)
	local vehicle = ply:GetEyeTrace().Entity
	if !IsValid(vehicle) or !vehicle:IsVehicle() or (vehicle:GetPos():DistToSqr(ply:GetPos()) > 45000) then return end


	local vehClass = ""

	if vehicle:IsSimfphyscar() then
		vehClass = vehicle:GetSpawn_List()
	else
		vehClass = vehicle:GetVehicleClass() or vehicle:GetClass()
	end

	local find = false 
	for _, data in pairs(DC_ActConfig) do
		if (data.id == actID) and ((table.Count(data.class) <= 0) or (table.HasValue(data.class, vehClass))) then
			find = true

			break
		end
	end

	if !find then return end

	DC_ActConfig[actID].command(ply, vehicle)
end)

net.Receive("ActEnterVehicle", function(_, ply)
	local vehicle = ply:GetEyeTrace().Entity
	if !IsValid(vehicle) or !vehicle:IsVehicle() or (vehicle:GetPos():DistToSqr(ply:GetPos()) > 45000) then return end

	if vehicle.SetPassenger then
		vehicle:SetPassenger( ply )

		return
	end

	ply:EnterVehicle( vehicle )	
end)																																																																																															-- Codded by Friks(https://steamcommunity.com/id/9871275127721)