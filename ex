--[[
    UI Debugger – Version Stable
    - Toggle draggable
    - Menu draggable listant les ScreenGui
    - Modal draggable + fermable
    - Dump sécurisé (limite profondeur + taille)
    - Copie du texte protégée
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- DRAGGABLE
---------------------------------------------------------------------
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

---------------------------------------------------------------------
-- DUMP SÉCURISÉ
---------------------------------------------------------------------
local function dumpGui(gui)
    local MAX_DEPTH = 5
    local MAX_LEN = 20000
    local currentLen = 0

    local function safeAppend(str, add)
        if currentLen > MAX_LEN then return str end
        str = str .. add
        currentLen += #add
        return str
    end

    local function dump(obj, indent, depth)
        indent = indent or 0
        depth = depth or 0
        local prefix = string.rep("  ", indent)
        local str = ""

        if depth > MAX_DEPTH then
            return safeAppend(str, prefix .. "... (profondeur max atteinte)\n")
        end

        str = safeAppend(str, prefix .. obj.ClassName .. " : " .. obj.Name .. "\n")

        for _, prop in ipairs({"Visible", "Active", "Size", "Position", "BackgroundColor3"}) do
            pcall(function()
                local v = obj[prop]
                if typeof(v) == "Color3" then v = tostring(v) end
                str = safeAppend(str, prefix .. "  " .. prop .. " = " .. tostring(v) .. "\n")
            end)
        end

        for _, child in ipairs(obj:GetChildren()) do
            if currentLen > MAX_LEN then
                str = safeAppend(str, prefix .. "... (taille max atteinte)\n")
                break
            end
            str = str .. dump(child, indent + 1, depth + 1)
        end

        return str
    end

    return dump(gui)
end

---------------------------------------------------------------------
-- UI ROOT
---------------------------------------------------------------------
local screen = Instance.new("ScreenGui", playerGui)
screen.Name = "UIDebugger"

---------------------------------------------------------------------
-- TOGGLE BUTTON
---------------------------------------------------------------------
local toggle = Instance.new("TextButton", screen)
toggle.Size = UDim2.fromOffset(120, 40)
toggle.Position = UDim2.fromOffset(50, 200)
toggle.Text = "UI Debug"
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)

makeDraggable(toggle)

---------------------------------------------------------------------
-- MENU
---------------------------------------------------------------------
local menu = Instance.new("Frame", screen)
menu.Size = UDim2.fromOffset(250, 300)
menu.Position = UDim2.fromOffset(200, 200)
menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menu.Visible = false

makeDraggable(menu)

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Liste des GUI"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)

makeDraggable(menu, title)

local list = Instance.new("ScrollingFrame", menu)
list.Size = UDim2.new(1, 0, 1, -30)
list.Position = UDim2.new(0, 0, 0, 30)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6

toggle.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

---------------------------------------------------------------------
-- REMPLIR LA LISTE
---------------------------------------------------------------------
local function refreshList()
    list:ClearAllChildren()
    local y = 0

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local btn = Instance.new("TextButton", list)
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = gui.Name
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.new(1, 1, 1)

            y += 35

            btn.MouseButton1Click:Connect(function()
                ---------------------------------------------------------
                -- MODAL
                ---------------------------------------------------------
                local modal = Instance.new("Frame", screen)
                modal.Size = UDim2.fromOffset(400, 300)
                modal.Position = UDim2.fromOffset(300, 200)
                modal.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

                makeDraggable(modal)

                local header = Instance.new("TextLabel", modal)
                header.Size = UDim2.new(1, 0, 0, 30)
                header.Text = "Inspect : " .. gui.Name
                header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                header.TextColor3 = Color3.new(1, 1, 1)

                makeDraggable(modal, header)

                local close = Instance.new("TextButton", modal)
                close.Size = UDim2.fromOffset(60, 25)
                close.Position = UDim2.new(1, -65, 0, 3)
                close.Text = "Fermer"
                close.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
                close.TextColor3 = Color3.new(1, 1, 1)

                close.MouseButton1Click:Connect(function()
                    modal:Destroy()
                end)

                local content = Instance.new("TextBox", modal)
                content.Size = UDim2.new(1, -10, 1, -70)
                content.Position = UDim2.new(0, 5, 0, 35)
                content.TextXAlignment = Enum.TextXAlignment.Left
                content.TextYAlignment = Enum.TextYAlignment.Top
                content.ClearTextOnFocus = false
                content.MultiLine = true
                content.TextWrapped = false
                content.TextEditable = false
                content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                content.TextColor3 = Color3.new(1, 1, 1)
                content.TextSize = 14

                local dump = dumpGui(gui)
                content.Text = dump

                local copy = Instance.new("TextButton", modal)
                copy.Size = UDim2.fromOffset(120, 30)
                copy.Position = UDim2.new(0, 5, 1, -35)
                copy.Text = "Copier le print"
                copy.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
                copy.TextColor3 = Color3.new(1, 1, 1)

                copy.MouseButton1Click:Connect(function()
                    local ok, err = pcall(function()
                        if setclipboard then
                            setclipboard(dump)
                        else
                            warn("setclipboard non disponible.")
                        end
                    end)
                    if not ok then warn("Erreur setclipboard :", err) end
                end)
            end)
        end
    end

    list.CanvasSize = UDim2.new(0, 0, 0, y)
end

refreshList()
