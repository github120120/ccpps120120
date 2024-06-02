local MyModule = {}
local staffScreen = script.Parent.StaffMonitor.Screen.SurfaceGui.POSUI.Main
local customerScreen = script.Parent.CustomerMonitor.Screen.SurfaceGui.POSUI
local transaction = false
local open = false
local scan = script.Parent.StaffMonitor.Scan.TouchPart
print("running")

--Log In script
scan.Touched:Connect(function(tool)

	local staffID = tool["POINTPLUS_STAFF"]
	print("touched")
	if open == false and staffID.Value == true then
		open = true
		staffScreen.Visible = true
		script.Parent.Beep:Play()

	end

end)

return MyModule




