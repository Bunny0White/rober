--[[
    UI Debugger – Version Sans Limites + ALL GUI 2
    - Dump complet : texte, images, propriétés, hiérarchie
    - AUCUNE limite de profondeur
    - AUCUNE limite de taille
    - Modal draggable + copie
    - Menu draggable listant TOUT PlayerGui
    - Bouton "All GUI" pour tout dump d’un coup
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
-- DUMP COMPLET (AUCUNE LIMITE)
---------------------------------------------------------------------
local function dumpGui(root)
    local function dump(obj, indent)
        indent = indent or 0
        local prefix = string.rep("  ", indent)
        local str = ""

        -- Ligne principale
        str = str .. prefix .. obj.ClassName .. " : " .. obj.Name .. "\n"

        -- Attributs
        for _, attr in ipairs(obj:GetAttributes()) do
            local ok, value = pcall(function()
                return obj:GetAttribute(attr)
            end)
            if ok then
                str = str .. prefix .. "  @" .. attr .. " = " .. tostring(value) .. "\n"
            end
        end

        -- Propriétés standards
        local props = {
            "Text", "FontFace", "TextColor3", "TextSize", "RichText",
            "Image", "ImageColor3", "ImageRectOffset", "ImageRectSize",
            "BackgroundColor3", "BackgroundTransparency",
            "Size", "Position", "Visible", "Active", "AnchorPoint",
            "BorderSizePixel", "ZIndex", "LayoutOrder", "Rotation",
            "ClipsDescendants", "AutomaticSize", "MaxVisibleGraphemes"
        }

        for _, prop in ipairs(props) do
            local ok, value = pcall(function()
                return obj[prop]
            end)
            if ok then
                if typeof(value) == "Color3" then value = tostring(value) end
                str = str .. prefix .. "  " .. prop .. " = " .. tostring(value) .. "\n"
            end
        end

        -- Enfants
        for _, child in ipairs(obj:GetChildren()) do
            str = str .. dump(child, indent + 1)
        end

        return str
    end

    return dump(root)
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
menu.Size = UDim2.fromOffset(250, 350)
menu.Position = UDim2.fromOffset(200, 200)
menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menu.Visible = false

makeDraggable(menu)

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Contenu du PlayerGui"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)

makeDraggable(menu, title)

local list = Instance.new("ScrollingFrame", menu)
list.Size = UDim2.new(1, 0, 1, -70)
list.Position = UDim2.new(0, 0, 0, 30)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6

---------------------------------------------------------------------
-- BOUTON ALL GUI
---------------------------------------------------------------------
local allBtn = Instance.new("TextButton", menu)
allBtn.Size = UDim2.new(1, -10, 0, 30)
allBtn.Position = UDim2.new(0, 5, 1, -35)
allBtn.Text = "ALL GUI"
allBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
allBtn.TextColor3 = Color3.new(1, 1, 1)

---------------------------------------------------------------------
-- OUVERTURE / FERMETURE MENU
---------------------------------------------------------------------
toggle.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

---------------------------------------------------------------------
-- MODAL CREATOR
---------------------------------------------------------------------
local function openModal(titleText, dumpText)
    local modal = Instance.new("Frame", screen)
    modal.Size = UDim2.fromOffset(700, 500)
    modal.Position = UDim2.fromOffset(300, 200)
    modal.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    makeDraggable(modal)

    local header = Instance.new("TextLabel", modal)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.Text = titleText
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

    -- SCROLLING FRAME POUR LE TEXTE
    local scroll = Instance.new("ScrollingFrame", modal)
    scroll.Size = UDim2.new(1, -10, 1, -70)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 8
    scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    -- TEXTLABEL QUI S’ÉTEND AUTOMATIQUEMENT
    local content = Instance.new("TextLabel", scroll)
    content.Size = UDim2.new(1, -10, 0, 0)
    content.Position = UDim2.new(0, 5, 0, 5)
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.BackgroundTransparency = 1
    content.TextColor3 = Color3.new(1, 1, 1)
    content.TextSize = 14
    content.Font = Enum.Font.Code
    content.TextWrapped = false
    content.Text = dumpText
    content.AutomaticSize = Enum.AutomaticSize.Y

    -- Met à jour la taille du scroll
    task.wait()
    scroll.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteSize.Y + 20)

    -- BOUTON COPIER
    local copy = Instance.new("TextButton", modal)
    copy.Size = UDim2.fromOffset(120, 30)
    copy.Position = UDim2.new(0, 5, 1, -35)
    copy.Text = "Copier"
    copy.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    copy.TextColor3 = Color3.new(1, 1, 1)

    copy.MouseButton1Click:Connect(function()
        local ok, err = pcall(function()
            if setclipboard then
                setclipboard(dumpText)
            else
                warn("setclipboard non disponible.")
            end
        end)
        if not ok then warn("Erreur setclipboard :", err) end
    end)
end

---------------------------------------------------------------------
-- BOUTON ALL GUI → DUMP COMPLET
---------------------------------------------------------------------
allBtn.MouseButton1Click:Connect(function()
    local fullDump = ""

    for _, obj in ipairs(playerGui:GetChildren()) do
        fullDump = fullDump .. dumpGui(obj) .. "\n"
    end

    openModal("ALL GUI (PlayerGui complet)", fullDump)
end)

---------------------------------------------------------------------
-- REMPLIR LA LISTE (TOUT PlayerGui)
---------------------------------------------------------------------
local function refreshList()
    list:ClearAllChildren()
    local y = 0

    for _, obj in ipairs(playerGui:GetChildren()) do
        local btn = Instance.new("TextButton", list)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.Text = obj.Name .. " (" .. obj.ClassName .. ")"
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1, 1, 1)

        y += 35

        btn.MouseButton1Click:Connect(function()
            openModal("Inspect : " .. obj.Name, dumpGui(obj))
        end)
    end

    list.CanvasSize = UDim2.new(0, 0, 0, y)
end

refreshList()
