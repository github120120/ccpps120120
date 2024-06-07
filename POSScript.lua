local POSModule = {}

local Parcel = require(9428572121)

if Parcel:Whitelist("iimoh6l2ioajaym2mfyjyajvlnl4y9f788wvhl59z6", "rcf3w9e1ydb5kmcx79nilhee4zid") then
    -- User owns the product

    -- User doesn’t own the product


-- Ensures initial state is set up correctly
function POSModule.init(state)
    state.open = false
    state.POS = script.Parent
    state.customerScreen = state.POS.CustomerMonitor.Screen.SurfaceGui.POSUI
    state.staffScreen = state.POS.StaffMonitor.Screen.SurfaceGui.POSUI
    --state.onLogIn = false
    state.transaction = false
    state.totalPrice = 0
    state.typingPin = false
    state.contactless = false
    state.canInsert = false
    state.isInsert = false
    state.isContactless = false
    state.customerUIOpen = false

    -- Connect events
    state.scan.Touched:Connect(function(tool)
        if tool:FindFirstChild("POINTPLUS_STAFF") then
            POSModule.logIn(tool, state)
            POSModule.showCustomerUI(state)
        elseif tool:FindFirstChild("POINTPLUS_ITEM") then
            POSModule.scanItem(tool, state)
        end
    end)
    --state.staffScreen.Locked.LogInButton.MouseButton1Click:Connect(function() POSModule.logInScreen(state) end)
    --state.staffScreen.LogIn.BackButton.MouseButton1Click:Connect(function() POSModule.goBack(state) end)
    state.staffScreen.Main.LogOut.MouseButton1Click:Connect(function() POSModule.logOut(state) end)
    state.main.Buttons.Void.MouseButton1Click:Connect(function() POSModule.voidTransaction(state) end)
    state.main.Buttons.Card.MouseButton1Click:Connect(function() POSModule.cardTransaction(state) end)
    state.cardReader.InsertCard.ClickDetector.MouseClick:Connect(function() POSModule.cardInsert(state) end)
    state.cardReader.Tap.Touched:Connect(function(card) POSModule.cardTap(card, state) end)
    state.cardReader.Touch.ClickDetector.MouseClick:Connect(function() POSModule.typePin(state) end)
end

function POSModule.logIn(tool, state)
    local staffID = tool["POINTPLUS_STAFF"]
    if staffID then
        state.open = true
        state.staffScreen.Main.Visible = true
        state.staffScreen.LogIn.Visible = false
        state.customerScreen.Closed.Visible = false
        state.customerScreen.Main.Visible = true
        state.POS.Beep:Play()
        state.main.Items.ItemList.Template.Visible = false
        state.customerScreen.Main.ItemList.Template.Visible = false
        state.customerScreen.Main.ItemScanned.ItemScannedName.Text = "---"
        state.customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "---"
    end
end
function POSModule.showCustomerUI(state)
    state.customerScreen.Closed.Visible = false
    state.customerScreen.Main.Visible = true
end

--[[
function POSModule.logInScreen(state)
    state.onLogIn = true
    state.staffScreen.Locked.Visible = false
    state.staffScreen.LogIn.Visible = true
end
--]]
--[[
function POSModule.goBack(state)
    state.onLogIn = false
    state.staffScreen.Locked.Visible = true
    state.staffScreen.LogIn.Visible = false
end
--]]

function POSModule.logOut(state)
    state.open = false
    --state.onLogIn = false
    state.main.Visible = false
    state.customerScreen.Main.Visible = false
    state.customerScreen.Closed.Visible = true
    state.staffScreen.LogIn.Visible = true
    state.POS.LogOut:Play()
    
    state.totalPrice = 0
    
    local stafflist = Instance.new("UIListLayout")
    state.main.Items.ItemList:ClearAllChildren()
    stafflist.Parent = state.main.Items.ItemList
    state.staffScreen.Main.Items.Total.Text = "$0"
    
    local customerList = Instance.new("UIListLayout")
    state.customerScreen.Main.ItemList:ClearAllChildren()
    customerList.Parent = state.customerScreen.Main.ItemList
    state.customerScreen.Main.Total.TotalPrice.Text = "$0"
    state.customerScreen.Main.ItemScanned.ItemScannedName.Text = "---"
    state.customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "---"

    -- Save the state of the customer UI
    state.customerUIOpen = false
end

-- Other functions remain the same...

function POSModule.scanItem(item, state)
    if state.open == true and state.transaction == false then
        local product = item["POINTPLUS_ITEM"]
        if product then
            state.POS.Beep:Play()
            local price = product.ProductPrice.Value
            state.totalPrice = state.totalPrice + price
            state.totalPrice = math.floor(state.totalPrice * 100) / 100
            local itemName = product.Parent.Parent.Name

            local newItem = state.POS.CustomerMonitor.Screen.SurfaceGui.Template:Clone()
            local newStaffItem = state.POS.StaffMonitor.Screen.SurfaceGui.Template:Clone()

            newItem.Name = itemName
            newItem.Parent = state.customerScreen.Main.ItemList
            newItem.Visible = true
            newItem.Text = "$"..price.." / "..itemName

            newStaffItem.Name = itemName
            newStaffItem.Text = "$"..price.." / "..itemName
            newStaffItem.Visible = true
            newStaffItem.Parent = state.staffScreen.Main.Items.ItemList
            state.main.Items.Total.Text = "$"..state.totalPrice

            state.customerScreen.Main.Total.TotalPrice.Text = "$"..state.totalPrice
            state.customerScreen.Main.ItemScanned.ItemScannedName.Text = itemName
            state.customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "$"..tostring(price)
        end
    end
end

function POSModule.voidTransaction(state)
    state.totalPrice = 0
    state.POS.Beep:Play()
    
    local stafflist = Instance.new("UIListLayout")
    state.main.Items.ItemList:ClearAllChildren()
    stafflist.Parent = state.main.Items.ItemList
    state.staffScreen.Main.Items.Total.Text = "$0"
    
    local customerList = Instance.new("UIListLayout")
    state.customerScreen.Main.ItemList:ClearAllChildren()
    customerList.Parent = state.customerScreen.Main.ItemList
    state.customerScreen.Main.Total.TotalPrice.Text = "$0"
    state.customerScreen.Main.ItemScanned.ItemScannedName.Text = "---"
    state.customerScreen.Main.ItemScanned.ItemScannedPrice.Text = "---"
    
    state.notice.Visible = true
    state.main.Items.ItemList.Visible = false
    state.notice.Title.Text = "Void"
    state.notice.Info.Text = "Voided current scanned items."
    wait(3)
    state.notice.Visible = false
    state.main.Items.ItemList.Visible = true
end

function POSModule.cardTransaction(state)
    if state.transaction == false and state.totalPrice > 0 then
        state.POS.Beep:Play()
        print("Transaction started")
        state.transaction = true
        
        state.cardReader.InsertCard.Transparency = 0.5


        state.notice.Visible = true
        state.main.Items.ItemList.Visible = false
        state.notice.Title.Text = "Transaction"
        state.notice.Info.Text = "Transaction has started. Please ask the customer to follow the instructions on the card reader."
        state.customerNotice.Visible = true
        state.customerScreen.Main.ItemList.Visible = false
        state.customerNotice.Title.Text = "Transaction"
        state.customerNotice.Info.Text = "Your transaction has started, please follow the instructions on the card-reader."
        
        
        
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Total: $"..state.totalPrice
        if state.totalPrice < 100 then
            state.contactless = true
            state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "Please tap or insert your card."
            state.isContactless = true
            state.canInsert = true
            state.isInsert = true
        else
            state.contactless = false
            state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "Please insert your card."
            state.isContactless = false
            state.canInsert = true
            state.isInsert = true
        end
    end
end

function POSModule.cardInsert(state)
    if state.transaction == true and state.typingPin == false and state.canInsert == true and state.isInsert == true then
        state.contactless = false
        state.isContactless = false
        state.cardReader.InsertCard.Transparency = 1
        state.cardReader.Card.Transparency = 0
        state.cardReader.Card.Decal.Transparency = 0
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Enter Pin:"
        state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = ""
        state.typingPin = true
    end
end

function POSModule.typePin(state)
    if state.typingPin == true then
        state.typingPin = false
        local currentDigits = 0
        currentDigits = currentDigits + 1
        state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "*"
        state.POS.Beep:Play()
        wait(1)
        currentDigits = currentDigits + 1
        state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "**"
        state.POS.Beep:Play()
        wait(1)
        currentDigits = currentDigits + 1
        state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "***"
        state.POS.Beep:Play()
        wait(1)
        currentDigits = currentDigits + 1
        state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "****"
        state.POS.Beep:Play()
        
        if currentDigits >= 4 then
            state.typingPin = false
            state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = ""
            state.cardReader.Card.Transparency = 1
            state.cardReader.Card.Decal.Transparency = 1
            state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
            wait(3)
            state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "APPROVED"
            state.POS.Transaction:Play()
            wait(1)
            state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
            wait(1)
            state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Printing Receipt..."
            wait(1)
            state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Thank you for shopping at this store!"
            wait(1)
            state.transaction = false
            POSModule.voidTransaction(state)
            wait(2.5)
            state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Waiting for cashier..."
            state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "$100 Contactless Limit"
            state.customerNotice.Visible = false
            state.customerScreen.Main.ItemList.Visible = true
            state.customerNotice.Title.Text = "Notice Title"
            state.customerNotice.Info.Text = "Notice Info"
            state.notice.Visible = false
            state.main.Items.ItemList.Visible = true
            
        end
    end
end

function POSModule.cardTap(card, state)
    local debit = card["POINT_PLUS_DEBIT"]
    if state.transaction == true and state.contactless == true and state.isContactless == true and debit then
        state.cardReader.InsertCard.Transparency = 1
        state.cardReader.Card.Transparency = 1
        state.cardReader.Card.Decal.Transparency = 1

        state.typingPin = false
        state.isContactless = false
        state.canInsert = false
        state.POS.Beep:Play()
        state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = ""
        wait(1)
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
        wait(3)
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "APPROVED"
        state.POS.Transaction:Play()
        wait(1)
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Processing..."
        wait(1)
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Printing Receipt..."
        wait(1)
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Thank you for shopping at this store!"
        wait(2.5)
        state.cardReader.Screen.SurfaceGui.Frame.Top.Text = "Waiting for cashier..."
        state.cardReader.Screen.SurfaceGui.Frame.Bottom.Text = "$100 Contactless Limit"
        
        
        state.transaction = false
        POSModule.voidTransaction(state)
        wait(3)
        state.notice.Visible = false
        state.main.Items.ItemList.Visible = true

        state.customerNotice.Visible = false
        state.customerScreen.Main.ItemList.Visible = true
        state.customerNotice.Title.Text = "Notice Title"
        state.customerNotice.Info.Text = "Notice Info"
    end
end
else

    state.POS:Destroy()
    warn("[POINT PLUS] LICENSE NOT FOUND FOR PLUSPOS STREAM 150]")
    warn("[POINT PLUS] POS SYSTEM HAS BEEN AUTOMATICALLY REMOVED FROM THIS EXPERIENCE")
    
end

return POSModule
