local MyModule = {}

-- Define your variables and functions here
MyModule.staffScreen = script.Parent.StaffMonitor.Screen.SurfaceGui.POSUI.Main
MyModule.customerScreen = script.Parent.CustomerMonitor.Screen.SurfaceGui.POSUI
MyModule.transaction = false
MyModule.open = false
MyModule.scan = script.Parent.StaffMonitor.Scan.TouchPart

-- Log In script
MyModule.scan.Touched:Connect(function(tool)
    local staffID = tool["POINTPLUS_STAFF"]
    print("touched")
    if MyModule.open == false and staffID.Value == true then
        MyModule.open = true
        MyModule.staffScreen.Visible = true
        script.Parent.Beep:Play()
    end
end)

return MyModule





