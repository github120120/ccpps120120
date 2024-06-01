local staffScreen = script.Parent.StaffMonitor.Screen.SurfaceGui.POSUI.Main
local customerScreen = script.Parent.CustomerMonitor.Screen.SurfaceGui.POSUI
local transaction = false
local open = false
local scan = script.Parent.StaffMonitor.Scan.TouchPart

--Log In script
scan.Touched:Connect(function(tool)

	local staffID = tool["POINTPLUS_STAFF"]

	if open == false and staffID.Value == true then
		open = true
		staffScreen.Visible = true
		script.Parent.Beep:Play()

	end

end)