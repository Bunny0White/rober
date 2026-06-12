-- Roblox GUI Inspector Script
-- Ce script crée un menu déplaçable avec un bouton toggle, une liste des GUIs du joueur,
-- et une modal pour afficher les propriétés des éléments sélectionnés.

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Fonction pour créer un bouton déplaçable
local function createDraggableButton()
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Text = "GUI Inspector"
    button.Size = UDim2.new(0, 120, 0, 30)
    button.Position = UDim2.new(0, 20, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = PlayerGui

    -- Rendre le bouton déplaçable
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    return button
end

-- Fonction pour créer le menu principal
local function createMainMenu()
    local menu = Instance.new("Frame")
    menu.Name = "GUIInspectorMenu"
    menu.Size = UDim2.new(0, 200, 0, 300)
    menu.Position = UDim2.new(0, 20, 0, 60)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = PlayerGui

    -- Rendre le menu déplaçable
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        menu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.Parent = menu

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "GUI Inspector"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = titleBar

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = menu.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    -- Liste des GUIs
    local guiList = Instance.new("ScrollingFrame")
    guiList.Name = "GUIList"
    guiList.Size = UDim2.new(1, -10, 1, -40)
    guiList.Position = UDim2.new(0, 5, 0, 35)
    guiList.BackgroundTransparency = 1
    guiList.ScrollBarThickness = 5
    guiList.Parent = menu

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = guiList

    -- Fonction pour mettre à jour la liste des GUIs
    local function updateGUIList()
        for _, child in ipairs(guiList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("GuiObject") then
                local button = Instance.new("TextButton")
                button.Name = gui.Name
                button.Text = gui.Name
                button.Size = UDim2.new(1, -10, 0, 25)
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.Font = Enum.Font.SourceSans
                button.TextSize = 14
                button.Parent = guiList

                button.MouseButton1Click:Connect(function()
                    createModal(gui)
                end)
            end
        end
    end

    -- Bouton pour rafraîchir la liste
    local refreshButton = Instance.new("TextButton")
    refreshButton.Name = "RefreshButton"
    refreshButton.Text = "Rafraîchir"
    refreshButton.Size = UDim2.new(1, -10, 0, 25)
    refreshButton.Position = UDim2.new(0, 5, 0, 300)
    refreshButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.Font = Enum.Font.SourceSansBold
    refreshButton.TextSize = 14
    refreshButton.Parent = menu

    refreshButton.MouseButton1Click:Connect(updateGUIList)

    -- Mettre à jour la liste au démarrage
    updateGUIList()

    return menu
end

-- Fonction pour créer une modal
function createModal(gui)
    local modal = Instance.new("Frame")
    modal.Name = "GUIInspectorModal"
    modal.Size = UDim2.new(0, 400, 0, 500)
    modal.Position = UDim2.new(0.5, -200, 0.5, -250)
    modal.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    modal.BorderSizePixel = 0
    modal.Parent = PlayerGui

    -- Rendre la modal déplaçable
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        modal.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.Parent = modal

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "Propriétés de: " .. gui.Name
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Parent = titleBar

    closeButton.MouseButton1Click:Connect(function()
        modal:Destroy()
    end)

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = modal.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    -- Zone de contenu
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -10, 1, -70)
    contentFrame.Position = UDim2.new(0, 5, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 5
    contentFrame.Parent = modal

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = contentFrame

    -- Fonction pour afficher les propriétés
    local function printProperties(instance, depth)
        depth = depth or 0
        local indent = string.rep("  ", depth)
        local text = indent .. "--- " .. instance.ClassName .. " (" .. instance.Name .. ") ---\n"

        -- Ajouter les propriétés de l'instance
        for property, value in pairs(instance:GetProperties()) do
            text = text .. indent .. "  " .. property .. ": " .. tostring(value) .. "\n"
        end

        -- Ajouter les propriétés des parents
        if instance.Parent then
            text = text .. indent .. "Parent: " .. instance.Parent.Name .. " (" .. instance.Parent.ClassName .. ")\n"
        end

        -- Ajouter les enfants
        for _, child in ipairs(instance:GetChildren()) do
            text = text .. printProperties(child, depth + 1)
        end

        return text
    end

    -- Afficher les propriétés dans la modal
    local propertiesText = printProperties(gui)
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "PropertiesText"
    textLabel.Text = propertiesText
    textLabel.Size = UDim2.new(1, 0, 0, #propertiesText * 10)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = contentFrame

    -- Bouton pour copier le texte
    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyButton"
    copyButton.Text = "Copier"
    copyButton.Size = UDim2.new(0, 100, 0, 30)
    copyButton.Position = UDim2.new(1, -110, 0, 0)
    copyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.Font = Enum.Font.SourceSansBold
    copyButton.TextSize = 14
    copyButton.Parent = titleBar

    copyButton.MouseButton1Click:Connect(function()
        -- Copier le texte dans le presse-papiers (simulé)
        print("Contenu copié:")
        print(propertiesText)
        -- Dans Roblox, vous pouvez utiliser `setclipboard` si disponible
        if setclipboard then
            setclipboard(propertiesText)
        end
    end)
end

-- Créer le bouton toggle et le menu
local toggleButton = createDraggableButton()
local mainMenu = createMainMenu()

-- Toggle du menu
local isMenuVisible = false
toggleButton.MouseButton1Click:Connect(function()
    isMenuVisible = not isMenuVisible
    mainMenu.Visible = isMenuVisible
end)

-- Mettre à jour la liste des GUIs périodiquement
RunService.Heartbeat:Connect(function()
    if mainMenu.Visible then
        -- Optionnel: Rafraîchir automatiquement la liste
    end
end)
