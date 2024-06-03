local POSModule = {}

function POSModule.logIn(tool, state)
    local POS = state.POS
    local staffScreen = state.staffScreen
    local main = state.main
    local customerScreen = state.customerScreen
    local open = state.open
    local onLogIn = state.onLogIn

    local staffID = tool["POINTPLUS_STAFF"]
    if staffID and open == false and onLogIn == true then
        state.open = true
        staffScreen.Main.Visible = true
        POS.Beep:Play()
        main.Items.ItemList.Template.Visible = false
        customerScreen.Main.ItemList.Template.Visible = false
        customerScreen.Main.ItemScanned.ItemScannedName.Text = "---"
        customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "---"
    end
end

function POSModule.logInScreen(state)
    local staffScreen = state.staffScreen
    local customerScreen = state.customerScreen
    state.onLogIn = true
    staffScreen.Locked.Visible = false
    staffScreen.LogIn.Visible = true
    customerScreen.Closed.Visible = false
    customerScreen.Main.Visible = true
end

function POSModule.goBack(state)
    local staffScreen = state.staffScreen
    state.onLogIn = false
    staffScreen.Locked.Visible = true
    staffScreen.LogIn.Visible = false
end

function POSModule.logOut(state)
    local POS = state.POS
    local staffScreen = state.staffScreen
    local main = state.main
    local customerScreen = state.customerScreen

    state.open = false
    state.onLogIn = false
    main.Visible = false
    customerScreen.Main.Visible = false
    customerScreen.Closed.Visible = true
    staffScreen.Locked.Visible = true
    POS.LogOut:Play()
    
    state.totalPrice = 0
    
    local stafflist = Instance.new("UIListLayout")
    main.Items.ItemList:ClearAllChildren()
    stafflist.Parent = main.Items.ItemList
    staffScreen.Main.Items.Total.Text = "$0"
    
    local customerList = Instance.new("UIListLayout")
    customerScreen.Main.ItemList:ClearAllChildren()
    customerList.Parent = customerScreen.Main.ItemList
    customerScreen.Main.Total.TotalPrice.Text = "$0"
    customerScreen.Main.ItemScanned.ItemScannedName.Text = "---"
    customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "---"
end

function POSModule.scanItem(item, state)
    local POS = state.POS
    local staffScreen = state.staffScreen
    local main = state.main
    local customerScreen = state.customerScreen
    local open = state.open
    local transaction = state.transaction
    local totalPrice = state.totalPrice

    if open == true and transaction == false then
        local product = item["POINTPLUS_ITEM"]

        POS.Beep:Play()
        local price = product.ProductPrice.Value
        state.totalPrice = totalPrice + price
        state.totalPrice = math.floor(state.totalPrice * 100) / 100
        local itemName = product.Parent.Parent.Name

        local newItem = POS.CustomerMonitor.Screen.SurfaceGui.Template:Clone()
        local newStaffItem = POS.StaffMonitor.Screen.SurfaceGui.Template:Clone()

        newItem.Name = itemName
        newItem.Parent = customerScreen.Main.ItemList
        newItem.Visible = true
        newItem.Text = "$"..price.." / "..itemName

        newStaffItem.Name = itemName
        newStaffItem.Text = "$"..price.." / "..itemName
        newStaffItem.Visible = true
        newStaffItem.Parent = staffScreen.Main.Items.ItemList
        main.Items.Total.Text = "$"..state.totalPrice

        customerScreen.Main.Total.TotalPrice.Text = "$"..state.totalPrice
        customerScreen.Main.ItemScanned.ItemScannedName.Text = itemName
        customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "$"..tostring(price)
    end
end

function POSModule.voidTransaction(state)
    local POS = state.POS
    local staffScreen = state.staffScreen
    local main = state.main
    local customerScreen = state.customerScreen
    local notice = state.notice

    state.totalPrice = 0
    POS.Beep:Play()
    
    local stafflist = Instance.new("UIListLayout")
    main.Items.ItemList:ClearAllChildren()
    stafflist.Parent = main.Items.ItemList
    staffScreen.Main.Items.Total.Text = "$0"
    
    local customerList = Instance.new("UIListLayout")
    customerScreen.Main.ItemList:ClearAllChildren()
    customerList.Parent = customerScreen.Main.ItemList
    customerScreen.Main.Total.TotalPrice.Text = "$0"
    customerScreen.Main.ItemScanned.ItemScannedName.Text = "---"
    customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "---"
    
    notice.Visible = true
    main.Items.ItemList.Visible = false
    notice.Title.Text = "Void"
    notice.Info.Text = "Voided current scanned items."
    wait(3)
    notice.Visible = false
    main.Items.ItemList.Visible = true
end

function POSModule.cardTransaction(state)
    local cardReader = state.cardReader
    local totalPrice = state.totalPrice
    local transaction = state.transaction

    if transaction == false and totalPrice > 0 then
        state.transaction = true
        
        cardReader.InsertCard.Transparency = 0.5
        
        cardReader.Screen.SurfaceGui.Frame.Top.Text = "Total: $"..totalPrice
        if totalPrice < 100 then
            state.contactless = true
            cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "Please tap or insert your card."
            state.isContactless = true
            state.canInsert = true
            state.isInsert = true
        else
            state.contactless = false
            cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "Please insert your card."
            state.isContactless = false
            state.canInsert = true
            state.isInsert = true
        end
    end
end

function POSModule.cardInsert(state)
    local cardReader = state.cardReader
    local transaction = state.transaction
    local typingPin = state.typingPin
    local canInsert = state.canInsert
    local isInsert = state.isInsert

    if transaction == true and typingPin == false and canInsert == true and isInsert == true then
        state.contactless = false
        state.isContactless = false
        cardReader.InsertCard.Transparency = 1
        cardReader.Card.Transparency = 0
        cardReader.Card.Decal.Transparency = 0
        cardReader.Screen.SurfaceGui.Frame.Top.Text = "Enter Pin:"
        cardReader.Screen.SurfaceGui.Frame.Bottom.Text = ""
        state.typingPin = true
    end
end

function POSModule.typePin(state)
    local cardReader = state.cardReader
    local typingPin = state.typingPin
    local currentDigits = 0

    if typingPin == true then
        state.typingPin = false
        currentDigits = currentDigits + 1
        cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "*"
        state.POS.Beep:Play()
        wait(1)
        currentDigits = currentDigits + 1
        cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "**"
        state.POS.Beep:Play()
        wait(1)
        currentDigits = currentDigits + 1
        cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "***"
        state.POS.Beep:Play()
        wait(1)
        currentDigits = currentDigits + 1
        cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "****"
        state.POS.Beep:Play()
        
        if currentDigits >= 4 then
            state.typingPin = false
            cardReader.Screen.SurfaceGui.Frame.Bottom.Text = ""
            cardReader.Card.Transparency = 1
            cardReader.Card.Decal.Transparency = 1
            cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
            wait(3)
            cardReader.Screen.SurfaceGui.Frame.Top.Text = "APPROVED"
            state.POS.Transaction:Play()
            wait(1)
            cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
            wait(1)
            cardReader.Screen.SurfaceGui.Frame.Top.Text = "Printing Receipt..."
            wait(1)
            cardReader.Screen.SurfaceGui.Frame.Top.Text = "Thank you for shopping at this store!"
            wait(1)
            state.transaction = false
            POSModule.voidTransaction(state)
        end
    end
end

function POSModule.cardTap(card, state)
    local cardReader = state.cardReader
    local contactless = state.contactless
    local isContactless = state.isContactless
    local transaction = state.transaction

    local debit = card["POINT_PLUS_DEBIT"]
    if transaction == true and contactless == true and isContactless == true and debit then
        cardReader.InsertCard.Transparency = 1
        cardReader.Card.Transparency = 1
        cardReader.Card.Decal.Transparency = 1

        state.typingPin = false
        state.isContactless = false
        state.canInsert = false
        state.POS.Beep:Play()
        cardReader.Screen.SurfaceGui.Frame.Bottom.Text = ""
        wait(1)
        cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
        wait(3)
        cardReader.Screen.SurfaceGui.Frame.Top.Text = "APPROVED"
        state.POS.Transaction:Play()
        wait(1)
        cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
        wait(1)
        cardReader.Screen.SurfaceGui.Frame.Top.Text = "Printing Receipt..."
        wait(1)
        cardReader.Screen.SurfaceGui.Frame.Top.Text = "Thank you for shopping at this store!"
        
        state.transaction = false
        POSModule.voidTransaction(state)
    end
end

function POSModule.init(state)
    local POS = state.POS

    -- Connect events
    state.scan.Touched:Connect(function(tool) POSModule.logIn(tool, state) end)
    state.staffScreen.Locked.LogInButton.MouseButton1Click:Connect(function() POSModule.logInScreen(state) end)
    state.staffScreen.LogIn.BackButton.MouseButton1Click:Connect(function() POSModule.goBack(state) end)
    state.staffScreen.Main.LogOut.MouseButton1Click:Connect(function() POSModule.logOut(state) end)
    state.main.Buttons.Void.MouseButton1Click:Connect(function() POSModule.voidTransaction(state) end)
    state.main.Buttons.Card.MouseButton1Click:Connect(function() POSModule.cardTransaction(state) end)
    state.cardReader.InsertCard.ClickDetector.MouseClick:Connect(function() POSModule.cardInsert(state) end)
    state.cardReader.Tap.Touched:Connect(function(card) POSModule.cardTap(card, state) end)
    state.cardReader.Touch.ClickDetector.MouseClick:Connect(function() POSModule.typePin(state) end)
end

return POSModule






