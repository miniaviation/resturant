local firesignal = firesignal or function(signal)
    if getconnections then
        for _, conn in pairs(getconnections(signal)) do
            if conn.Function then
                pcall(conn.Function)
            end
        end
    end
end

local p = game:GetService("Players").LocalPlayer
local pg = p.PlayerGui

-- Helper function to wait for a UI element with a timeout
local function waitForChild(parent, childName, timeout)
    timeout = timeout or 5 -- Default timeout of 5 seconds
    local start = tick()
    local child
    while tick() - start < timeout do
        child = parent:FindFirstChild(childName)
        if child then
            return child
        end
        wait()
    end
    return nil
end

-- Helper function to safely fire a button's MouseButton1Click signal
local function safeFireSignal(signal, description)
    if signal then
        local success, err = pcall(firesignal, signal)
        if not success then
            warn("Failed to fire signal for " .. description .. ": " .. tostring(err))
        end
        return success
    else
        warn("Signal not found for " .. description)
        return false
    end
end

-- 1. DockingRequest – first TextButton in the menu
local docking = waitForChild(pg:WaitForChild("ShipControlGui"):WaitForChild("Menus"), "DockingRequest")
if docking then
    for _, btn in pairs(docking:GetChildren()) do
        if btn:IsA("TextButton") then
            safeFireSignal(btn.MouseButton1Click, "DockingRequest button")
            break
        end
    end
else
    warn("DockingRequest menu not found, skipping to next step")
end

-- WAIT FOR DOCKING TO FINISH
local portGui = waitForChild(pg, "PortGui")
local loadingBar = portGui and waitForChild(portGui, "LoadingBar")
if loadingBar then
    repeat wait() until not loadingBar.Visible
else
    warn("LoadingBar not found, proceeding to next step")
end

-- Optional extra safety: ensure main menu buttons are enabled
if portGui then
    local mainMenu = waitForChild(portGui, "PortMainMenu")
    if mainMenu then
        repeat wait() until mainMenu.Visible and waitForChild(mainMenu, "MenuButtons") and waitForChild(mainMenu.MenuButtons, "CargoManager") and mainMenu.MenuButtons.CargoManager.Visible
    else
        warn("PortMainMenu not found, proceeding to next step")
    end
else
    warn("PortGui not found, proceeding to next step")
end

-- EXTRA 3-SECOND BUFFER
wait(3)

-- 2. CargoManager Button
local cargoButton = pg:FindFirstChild("PortGui") and pg.PortGui:FindFirstChild("PortMainMenu") and pg.PortGui.PortMainMenu:FindFirstChild("MenuButtons") and pg.PortGui.PortMainMenu.MenuButtons:FindFirstChild("CargoManager") and pg.PortGui.PortMainMenu.MenuButtons.CargoManager:FindFirstChild("Button")
safeFireSignal(cargoButton and cargoButton.MouseButton1Click, "CargoManager button")

wait(0.5)

-- 3. Load Button (find ListItem with PortName TextLabel text "Ocean Fall Port")
local containerMenu = pg:FindFirstChild("PortGui") and pg.PortGui:FindFirstChild("ContainerMenu")
local scrollingFrame = containerMenu and containerMenu:FindFirstChild("ScrollingFrame")
local loadButtonClicked = false
if scrollingFrame then
    for _, v in pairs(scrollingFrame:GetChildren()) do
        if v.Name == "ListItem" and v:FindFirstChild("PortName") and v.PortName:IsA("TextLabel") and v.PortName.Text == "Newport" then
            local loadButton = v:FindFirstChild("Load")
            if loadButton then
                loadButtonClicked = safeFireSignal(loadButton.MouseButton1Click, "Load button for Ocean Fall Port")
                break
            else
                warn("Load button not found in ListItem with PortName 'Ocean Fall Port'")
            end
        end
    end
else
    warn("ScrollingFrame not found in ContainerMenu")
end

if loadButtonClicked then
    if loadingBar then
        repeat wait() until not loadingBar.Visible
        wait(3) -- Wait 3 seconds after loading bar is gone
    else
        warn("LoadingBar not found after Load button, proceeding after 3-second fallback")
        wait(3)
    end
else
    warn("Load button for 'Ocean Fall Port' not clicked, proceeding after 3-second fallback")
    wait(3)
end

-- 4. Back Button
local backButton = pg:FindFirstChild("PortGui") and pg.PortGui:FindFirstChild("ContainerMenu") and pg.PortGui.ContainerMenu:FindFirstChild("Back")
safeFireSignal(backButton and backButton.MouseButton1Click, "Back button")

wait(0.5)

--------------------------------------------------------------------
-- 5. OPEN REFUEL MENU
--------------------------------------------------------------------
local refuelBtn = portGui and portGui.PortMainMenu and portGui.PortMainMenu.MenuButtons
                and portGui.PortMainMenu.MenuButtons.Refuel
                and portGui.PortMainMenu.MenuButtons.Refuel.Button
safeFireSignal(refuelBtn and refuelBtn.MouseButton1Click, "Refuel menu")
task.wait(0.6)

--------------------------------------------------------------------
-- 6. PURCHASE FUEL (FULL REFUEL)
--------------------------------------------------------------------
local shipServices = portGui and waitForChild(portGui, "ShipServices", 5)
local purchaseFuelBtn = shipServices and shipServices:FindFirstChild("PurchaseFuel")
if purchaseFuelBtn then
    safeFireSignal(purchaseFuelBtn.MouseButton1Click, "PurchaseFuel")
    -- Wait for refuel to complete
    if loadingBar then
        repeat task.wait() until not loadingBar.Visible
        wait(2)
    else
        wait(2)
    end
else
    warn("PurchaseFuel button not found!")
    wait(2)
end

--------------------------------------------------------------------
-- 7. EXIT SHIP SERVICES (BACK TO MAIN MENU)
--------------------------------------------------------------------
local exitBtn = shipServices and shipServices:FindFirstChild("Exit")
safeFireSignal(exitBtn and exitBtn.MouseButton1Click, "Exit ShipServices")
task.wait(0.6)

-- 5. Undock Button
local undockButton = pg:FindFirstChild("PortGui") and pg.PortGui:FindFirstChild("PortMainMenu") and pg.PortGui.PortMainMenu:FindFirstChild("MenuButtons") and pg.PortGui.PortMainMenu.MenuButtons:FindFirstChild("Undock") and pg.PortGui.PortMainMenu.MenuButtons.Undock:FindFirstChild("Button")
safeFireSignal(undockButton and undockButton.MouseButton1Click, "Undock button")

-- WAIT FOR UNDOCKING TO FINISH
if loadingBar then
    repeat wait() until not loadingBar.Visible
else
    warn("LoadingBar not found, proceeding to next step")
end

-- Optional extra safety: ensure ShipControlGui is re-enabled
local shipControlGui = waitForChild(pg, "ShipControlGui")
if shipControlGui then
    repeat wait() until shipControlGui.Enabled
else
    warn("ShipControlGui not found, proceeding to next step")
end

-- EXTRA 3-SECOND BUFFER
wait(3)
