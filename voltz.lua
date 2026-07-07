--[[
    VoltzUI - Clean Roblox UI Library
    Theme: clean dark + blue accent
    External icons: https://github.com/Footagesus/Icons

    Designed for client-side Roblox/Luau environments that support HttpGet + loadstring.
    In Studio, you can inject your own compatible icon provider with VoltzUI:SetIconProvider(provider).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local VoltzUI = {
    Version = "1.0.0",
    IconProvider = nil,
    IconsLoaded = false,
}

local ICON_PACK_URLS = {
    lucide = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
    solar = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua",
    craft = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua",
    geist = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua",
    sfsymbols = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua",
    gravity = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua",
}

local Theme = {
    Accent = Color3.fromRGB(50, 180, 253),
    AccentDark = Color3.fromRGB(26, 126, 184),
    Background = Color3.fromRGB(14, 17, 22),
    Surface = Color3.fromRGB(20, 24, 31),
    Surface2 = Color3.fromRGB(27, 32, 41),
    Surface3 = Color3.fromRGB(34, 40, 50),
    Border = Color3.fromRGB(48, 56, 69),
    Text = Color3.fromRGB(241, 245, 249),
    TextMuted = Color3.fromRGB(148, 163, 184),
    TextDim = Color3.fromRGB(100, 116, 139),
    Success = Color3.fromRGB(74, 222, 128),
    Danger = Color3.fromRGB(248, 113, 113),
    Warning = Color3.fromRGB(250, 204, 21),
}

local function cloneTable(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local function merge(defaults, options)
    local result = cloneTable(defaults)
    if type(options) == "table" then
        for key, value in pairs(options) do
            result[key] = value
        end
    end
    return result
end

local function create(className, properties, children)
    local object = Instance.new(className)

    if properties then
        for property, value in pairs(properties) do
            if property ~= "Parent" then
                object[property] = value
            end
        end
    end

    if children then
        for _, child in ipairs(children) do
            child.Parent = object
        end
    end

    if properties and properties.Parent then
        object.Parent = properties.Parent
    end

    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent,
    })
end

local function tween(object, duration, properties, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.18,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local animation = TweenService:Create(object, tweenInfo, properties)
    animation:Play()
    return animation
end

local function safeCallback(callback, ...)
    if type(callback) ~= "function" then
        return
    end

    local args = table.pack(...)
    task.spawn(function()
        local success, message = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        if not success then
            warn("[VoltzUI Callback Error] " .. tostring(message))
        end
    end)
end

local function getGuiParent()
    local success, result = pcall(function()
        if type(gethui) == "function" then
            return gethui()
        end

        if type(syn) == "table" and type(syn.protect_gui) == "function" then
            return CoreGui
        end

        if LocalPlayer then
            return LocalPlayer:WaitForChild("PlayerGui")
        end

        return CoreGui
    end)

    if success and result then
        return result
    end

    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    return CoreGui
end

local function protectGui(screenGui)
    pcall(function()
        if type(syn) == "table" and type(syn.protect_gui) == "function" then
            syn.protect_gui(screenGui)
        end
    end)
end

local function httpGet(url)
    local asyncSuccess, asyncResult = pcall(function()
        return game:HttpGetAsync(url)
    end)
    if asyncSuccess and type(asyncResult) == "string" and #asyncResult > 0 then
        return asyncResult
    end

    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and type(result) == "string" and #result > 0 then
        return result
    end

    error("Unable to download icon data: " .. tostring(result or asyncResult))
end

local function compileSource(source, chunkName)
    local loader = loadstring
    if type(loader) ~= "function" then
        error("loadstring is unavailable")
    end

    local chunk, compileError = loader(source, chunkName)
    if type(chunk) ~= "function" then
        error(compileError or "Source did not compile")
    end

    return chunk()
end

local function buildDirectIconProvider()
    local provider = {
        IconsType = "lucide",
        Icons = {},
    }

    local function parseIconString(iconString)
        if type(iconString) == "string" then
            local splitIndex = iconString:find(":")
            if splitIndex then
                return iconString:sub(1, splitIndex - 1), iconString:sub(splitIndex + 1)
            end
        end
        return nil, iconString
    end

    local function loadPack(packName)
        if provider.Icons[packName] then
            return provider.Icons[packName]
        end

        local url = ICON_PACK_URLS[packName]
        if not url then
            return nil
        end

        local pack = compileSource(httpGet(url), "@VoltzUI/Icons/" .. packName)
        if type(pack) ~= "table" then
            error("Icon pack '" .. tostring(packName) .. "' returned invalid data")
        end

        provider.Icons[packName] = pack
        return pack
    end

    function provider.SetIconsType(packName)
        if ICON_PACK_URLS[packName] then
            provider.IconsType = packName
            local success, message = pcall(loadPack, packName)
            if not success then
                warn("[VoltzUI] Could not preload icon pack '" .. tostring(packName) .. "': " .. tostring(message))
            end
        else
            warn("[VoltzUI] Unknown icon pack: " .. tostring(packName))
        end
    end

    function provider.Icon(icon, iconType, defaultFormat)
        defaultFormat = defaultFormat ~= false
        local explicitType, iconName = parseIconString(icon)
        local targetType = explicitType or iconType or provider.IconsType
        local iconSet = loadPack(targetType)

        if not iconSet or not iconName then
            return nil
        end

        if iconSet.Icons and iconSet.Icons[iconName] then
            local metadata = iconSet.Icons[iconName]
            local image = metadata.Image
            if iconSet.Spritesheets then
                image = iconSet.Spritesheets[tostring(metadata.Image)] or image
            end

            if type(image) == "number" then
                image = "rbxassetid://" .. tostring(image)
            end

            return {
                image,
                metadata,
            }
        end

        local directIcon = iconSet[iconName]
        if type(directIcon) == "number" then
            directIcon = "rbxassetid://" .. tostring(directIcon)
        end

        if type(directIcon) == "string" and directIcon:find("rbxassetid://", 1, true) then
            if defaultFormat then
                return {
                    directIcon,
                    {
                        ImageRectSize = Vector2.new(0, 0),
                        ImageRectPosition = Vector2.new(0, 0),
                    },
                }
            end
            return directIcon
        end

        return nil
    end

    function provider.Icon2(icon, iconType)
        return provider.Icon(icon, iconType, true)
    end

    function provider.GetIcon(icon, iconType)
        return provider.Icon(icon, iconType, false)
    end

    function provider.AddIcons(packName, iconData)
        if type(packName) ~= "string" or type(iconData) ~= "table" then
            error("AddIcons expects a pack name and icon table")
        end

        local pack = provider.Icons[packName] or {
            Icons = {},
            Spritesheets = {},
        }
        provider.Icons[packName] = pack

        for iconName, value in pairs(iconData) do
            if type(value) == "number" or type(value) == "string" then
                local image = type(value) == "number" and ("rbxassetid://" .. tostring(value)) or value
                pack.Icons[iconName] = {
                    Image = image,
                    ImageRectSize = Vector2.new(0, 0),
                    ImageRectPosition = Vector2.new(0, 0),
                }
                pack.Spritesheets[tostring(image)] = image
            elseif type(value) == "table" and value.Image then
                pack.Icons[iconName] = value
                local image = value.Image
                if type(image) == "number" then
                    image = "rbxassetid://" .. tostring(image)
                end
                pack.Spritesheets[tostring(value.Image)] = image
            end
        end
    end

    loadPack("lucide")
    return provider
end

local function loadExternalIcons()
    if VoltzUI.IconProvider then
        VoltzUI.IconsLoaded = true
        return VoltzUI.IconProvider
    end

    local success, provider = pcall(buildDirectIconProvider)
    if success and type(provider) == "table" then
        VoltzUI.IconProvider = provider
        VoltzUI.IconsLoaded = true
        return provider
    end

    VoltzUI.IconsLoaded = false
    warn("[VoltzUI] External icons could not be loaded: " .. tostring(provider))
    return nil
end

function VoltzUI:SetIconProvider(provider)
    assert(type(provider) == "table", "Icon provider must be a table")
    self.IconProvider = provider
    self.IconsLoaded = true
    return self
end

function VoltzUI:SetDefaultIconPack(packName)
    local provider = self.IconProvider or loadExternalIcons()
    if provider and provider.SetIconsType then
        provider.SetIconsType(packName)
    end
    return self
end

local function parseIconResult(provider, iconName, iconType)
    if not provider or not iconName or iconName == "" then
        return nil
    end

    local success, result = pcall(function()
        if provider.Icon2 then
            return provider.Icon2(iconName, iconType, true)
        elseif provider.Icon then
            return provider.Icon(iconName, iconType, true)
        elseif provider.GetIcon then
            return provider.GetIcon(iconName, iconType)
        end
        return nil
    end)

    if not success then
        return nil
    end

    if type(result) == "string" then
        return {
            Image = result,
            ImageRectSize = Vector2.new(0, 0),
            ImageRectPosition = Vector2.new(0, 0),
        }
    end

    if type(result) == "table" then
        if type(result[1]) == "string" then
            local metadata = result[2] or {}
            return {
                Image = result[1],
                ImageRectSize = metadata.ImageRectSize or Vector2.new(0, 0),
                ImageRectPosition = metadata.ImageRectPosition or Vector2.new(0, 0),
                Parts = metadata.Parts,
            }
        end

        if type(result.Image) == "string" then
            return result
        end
    end

    return nil
end

local function createIcon(parent, iconName, size, color, zIndex)
    local holder = create("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size or 18, size or 18),
        Parent = parent,
        ZIndex = zIndex or 1,
    })

    local iconObject = {
        Frame = holder,
        Layers = {},
    }

    function iconObject:SetColor(newColor)
        for _, layer in ipairs(self.Layers) do
            layer.ImageColor3 = newColor
        end
    end

    function iconObject:SetTransparency(value)
        for _, layer in ipairs(self.Layers) do
            layer.ImageTransparency = value
        end
    end

    function iconObject:Destroy()
        if self.Frame then
            self.Frame:Destroy()
        end
    end

    if not iconName or iconName == "" then
        holder.Visible = false
        return iconObject
    end

    local provider = VoltzUI.IconProvider or loadExternalIcons()
    local explicitType = type(iconName) == "string" and iconName:match("^([^:]+):") or nil
    local data = parseIconResult(provider, iconName, explicitType)

    if not data or not data.Image then
        holder.Visible = false
        return iconObject
    end

    local function addLayer(layerData)
        local image = create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = layerData.Image,
            ImageColor3 = color or Theme.TextMuted,
            ImageRectSize = layerData.ImageRectSize or Vector2.new(0, 0),
            ImageRectOffset = layerData.ImageRectPosition or Vector2.new(0, 0),
            ScaleType = Enum.ScaleType.Stretch,
            Parent = holder,
            ZIndex = zIndex or 1,
        })
        table.insert(iconObject.Layers, image)
    end

    addLayer(data)

    if type(data.Parts) == "table" then
        for _, partName in ipairs(data.Parts) do
            local partData = parseIconResult(provider, partName, explicitType)
            if partData and partData.Image then
                addLayer(partData)
            end
        end
    end

    return iconObject
end

local function dragify(handle, target)
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

local function bindHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        tween(button, 0.14, { BackgroundColor3 = hoverColor })
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.14, { BackgroundColor3 = normalColor })
    end)
end

local function createTextButton(properties)
    local button = create("TextButton", merge({
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Surface2,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Text,
        TextSize = 13,
    }, properties))
    return button
end

local function createElementBase(section, options, height)
    options = merge({
        Title = "Element",
        Desc = nil,
        Icon = nil,
    }, options)

    local frame = create("Frame", {
        Name = options.Title,
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or (options.Desc and 62 or 52)),
        ClipsDescendants = true,
        Parent = section.Container,
    })
    corner(frame, 9)
    local frameStroke = stroke(frame, Theme.Border, 0.35, 1)

    local leftOffset = 14
    local iconObject
    if options.Icon then
        iconObject = createIcon(frame, options.Icon, 18, Theme.TextMuted, 3)
        iconObject.Frame.Position = UDim2.new(0, 14, 0.5, -9)
        leftOffset = 43
    end

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftOffset, 0, options.Desc and 10 or 0),
        Size = UDim2.new(1, -(leftOffset + 110), options.Desc and 0 or 1, options.Desc and 20 or 0),
        Font = Enum.Font.GothamMedium,
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = frame,
        ZIndex = 3,
    })

    local description
    if options.Desc then
        description = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, leftOffset, 0, 31),
            Size = UDim2.new(1, -(leftOffset + 110), 0, 17),
            Font = Enum.Font.Gotham,
            Text = options.Desc,
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
            ZIndex = 3,
        })
    end

    frame.MouseEnter:Connect(function()
        tween(frameStroke, 0.14, { Transparency = 0, Color = Theme.Surface3 })
    end)

    frame.MouseLeave:Connect(function()
        tween(frameStroke, 0.14, { Transparency = 0.35, Color = Theme.Border })
    end)

    return {
        Frame = frame,
        Title = title,
        Description = description,
        Icon = iconObject,
        Options = options,
    }
end

local SectionMethods = {}
SectionMethods.__index = SectionMethods

function SectionMethods:AddButton(options)
    options = merge({
        Title = "Button",
        Desc = nil,
        Icon = "mouse-pointer-click",
        Callback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local action = createTextButton({
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(1, -94, 0.5, -16),
        Size = UDim2.fromOffset(80, 32),
        Text = options.ButtonText or "Run",
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(action, 8)
    bindHover(action, Theme.Surface3, Theme.AccentDark)

    action.MouseButton1Click:Connect(function()
        tween(action, 0.08, { Size = UDim2.fromOffset(76, 30), Position = UDim2.new(1, -92, 0.5, -15) })
        task.delay(0.08, function()
            if action.Parent then
                tween(action, 0.1, { Size = UDim2.fromOffset(80, 32), Position = UDim2.new(1, -94, 0.5, -16) })
            end
        end)
        safeCallback(options.Callback)
    end)

    local controller = {}
    function controller:SetText(text)
        action.Text = tostring(text)
    end
    function controller:Fire()
        safeCallback(options.Callback)
    end
    function controller:Destroy()
        base.Frame:Destroy()
    end
    return controller
end

function SectionMethods:AddToggle(options)
    options = merge({
        Title = "Toggle",
        Desc = nil,
        Icon = "toggle-left",
        Default = false,
        Callback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local state = options.Default == true

    local toggleButton = createTextButton({
        BackgroundColor3 = state and Theme.Accent or Theme.Surface3,
        Position = UDim2.new(1, -62, 0.5, -13),
        Size = UDim2.fromOffset(48, 26),
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(toggleButton, 99)

    local knob = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = state and UDim2.new(1, -23, 0.5, -9) or UDim2.new(0, 5, 0.5, -9),
        Size = UDim2.fromOffset(18, 18),
        Parent = toggleButton,
        ZIndex = 5,
    })
    corner(knob, 99)

    local controller = {}

    function controller:Set(value, silent)
        state = value == true
        tween(toggleButton, 0.18, {
            BackgroundColor3 = state and Theme.Accent or Theme.Surface3,
        })
        tween(knob, 0.2, {
            Position = state and UDim2.new(1, -23, 0.5, -9) or UDim2.new(0, 5, 0.5, -9),
        }, Enum.EasingStyle.Back)

        if not silent then
            safeCallback(options.Callback, state)
        end
    end

    function controller:Get()
        return state
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    toggleButton.MouseButton1Click:Connect(function()
        controller:Set(not state)
    end)

    return controller
end

function SectionMethods:AddSlider(options)
    options = merge({
        Title = "Slider",
        Desc = nil,
        Icon = "sliders-horizontal",
        Min = 0,
        Max = 100,
        Default = 50,
        Increment = 1,
        Suffix = "",
        Callback = function() end,
    }, options)

    options.Min = tonumber(options.Min) or 0
    options.Max = tonumber(options.Max) or 100
    options.Increment = math.max(tonumber(options.Increment) or 1, 0.0001)

    local base = createElementBase(self, options, options.Desc and 76 or 68)
    base.Title.Size = UDim2.new(1, -180, 0, 20)

    local value = math.clamp(tonumber(options.Default) or options.Min, options.Min, options.Max)
    local valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 10),
        Size = UDim2.fromOffset(86, 20),
        Font = Enum.Font.GothamMedium,
        Text = tostring(value) .. tostring(options.Suffix),
        TextColor3 = Theme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = base.Frame,
        ZIndex = 4,
    })

    local bar = create("Frame", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 1, -19),
        Size = UDim2.new(1, -28, 0, 6),
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(bar, 99)

    local fill = create("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = bar,
        ZIndex = 5,
    })
    corner(fill, 99)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Parent = bar,
        ZIndex = 6,
    })
    corner(knob, 99)
    stroke(knob, Theme.Accent, 0, 2)

    local dragging = false
    local controller = {}

    local function normalize(number)
        if options.Max == options.Min then
            return 0
        end
        return (number - options.Min) / (options.Max - options.Min)
    end

    local function roundToIncrement(number)
        local rounded = math.floor(((number - options.Min) / options.Increment) + 0.5) * options.Increment + options.Min
        local decimals = tostring(options.Increment):match("%.(%d+)")
        if decimals then
            local precision = #decimals
            local multiplier = 10 ^ precision
            rounded = math.floor(rounded * multiplier + 0.5) / multiplier
        end
        return math.clamp(rounded, options.Min, options.Max)
    end

    function controller:Set(newValue, silent)
        value = roundToIncrement(tonumber(newValue) or options.Min)
        local alpha = math.clamp(normalize(value), 0, 1)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. tostring(options.Suffix)
        if not silent then
            safeCallback(options.Callback, value)
        end
    end

    function controller:Get()
        return value
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    local function updateFromPosition(x)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        controller:Set(options.Min + ((options.Max - options.Min) * alpha))
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromPosition(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPosition(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    controller:Set(value, true)
    return controller
end

function SectionMethods:AddDropdown(options)
    options = merge({
        Title = "Dropdown",
        Desc = nil,
        Icon = "list-filter",
        Values = {},
        Default = nil,
        Multi = false,
        Callback = function() end,
    }, options)

    local collapsedHeight = options.Desc and 62 or 52
    local base = createElementBase(self, options, collapsedHeight)
    local open = false
    local values = options.Values or {}
    local selected = options.Multi and {} or options.Default
    local optionButtons = {}

    if options.Multi and type(options.Default) == "table" then
        for _, item in ipairs(options.Default) do
            selected[item] = true
        end
    end

    local selector = createTextButton({
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(1, -170, 0, 10),
        Size = UDim2.fromOffset(156, 32),
        Parent = base.Frame,
        ZIndex = 5,
    })
    corner(selector, 8)

    local selectedLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Select...",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = selector,
        ZIndex = 6,
    })

    local arrow = createIcon(selector, "chevron-down", 14, Theme.TextMuted, 6)
    arrow.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Frame.Position = UDim2.new(1, -18, 0.5, 0)

    local list = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 14, 0, collapsedHeight + 8),
        Size = UDim2.new(1, -28, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
        Parent = base.Frame,
        ZIndex = 6,
    })

    local listLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })

    local controller = {}

    local function selectedText()
        if options.Multi then
            local names = {}
            for _, item in ipairs(values) do
                if selected[item] then
                    table.insert(names, tostring(item))
                end
            end
            if #names == 0 then
                return "Select..."
            end
            return table.concat(names, ", ")
        end

        return selected ~= nil and tostring(selected) or "Select..."
    end

    local function refreshVisuals()
        selectedLabel.Text = selectedText()
        selectedLabel.TextColor3 = selectedLabel.Text == "Select..." and Theme.TextMuted or Theme.Text

        for valueName, buttonData in pairs(optionButtons) do
            local isSelected = options.Multi and selected[valueName] == true or selected == valueName
            tween(buttonData.Button, 0.12, {
                BackgroundColor3 = isSelected and Theme.AccentDark or Theme.Surface3,
            })
            buttonData.Check.Frame.Visible = isSelected
        end
    end

    local function setOpen(value)
        open = value == true
        local visibleCount = math.min(#values, 5)
        local listHeight = visibleCount > 0 and (visibleCount * 33 + math.max(visibleCount - 1, 0) * 5) or 0
        list.Visible = open
        list.Size = UDim2.new(1, -28, 0, listHeight)
        tween(base.Frame, 0.2, {
            Size = UDim2.new(1, 0, 0, open and (collapsedHeight + listHeight + 18) or collapsedHeight),
        })
        tween(arrow.Frame, 0.2, {
            Rotation = open and 180 or 0,
        })
    end

    local function rebuild()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        optionButtons = {}

        for index, valueName in ipairs(values) do
            local optionButton = createTextButton({
                BackgroundColor3 = Theme.Surface3,
                Size = UDim2.new(1, 0, 0, 33),
                LayoutOrder = index,
                Parent = list,
                ZIndex = 7,
            })
            corner(optionButton, 7)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.Gotham,
                Text = tostring(valueName),
                TextColor3 = Theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = optionButton,
                ZIndex = 8,
            })

            local check = createIcon(optionButton, "check", 14, Theme.Text, 8)
            check.Frame.AnchorPoint = Vector2.new(1, 0.5)
            check.Frame.Position = UDim2.new(1, -10, 0.5, 0)
            check.Frame.Visible = false

            optionButtons[valueName] = {
                Button = optionButton,
                Check = check,
            }

            optionButton.MouseButton1Click:Connect(function()
                if options.Multi then
                    selected[valueName] = not selected[valueName]
                    refreshVisuals()
                    safeCallback(options.Callback, cloneTable(selected))
                else
                    selected = valueName
                    refreshVisuals()
                    setOpen(false)
                    safeCallback(options.Callback, selected)
                end
            end)
        end

        refreshVisuals()
        if open then
            setOpen(true)
        end
    end

    function controller:Set(value, silent)
        if options.Multi then
            selected = {}
            if type(value) == "table" then
                for key, item in pairs(value) do
                    if type(key) == "number" then
                        selected[item] = true
                    elseif item == true then
                        selected[key] = true
                    end
                end
            end
        else
            selected = value
        end

        refreshVisuals()
        if not silent then
            safeCallback(options.Callback, options.Multi and cloneTable(selected) or selected)
        end
    end

    function controller:Get()
        return options.Multi and cloneTable(selected) or selected
    end

    function controller:SetValues(newValues)
        values = type(newValues) == "table" and newValues or {}
        rebuild()
    end

    function controller:Open()
        setOpen(true)
    end

    function controller:Close()
        setOpen(false)
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    selector.MouseButton1Click:Connect(function()
        setOpen(not open)
    end)

    rebuild()
    return controller
end

function SectionMethods:AddInput(options)
    options = merge({
        Title = "Input",
        Desc = nil,
        Icon = "text-cursor-input",
        Placeholder = "Type here...",
        Default = "",
        Numeric = false,
        ClearOnFocus = false,
        Callback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local box = create("TextBox", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        ClearTextOnFocus = options.ClearOnFocus == true,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = Theme.TextDim,
        PlaceholderText = options.Placeholder,
        Position = UDim2.new(1, -190, 0.5, -16),
        Size = UDim2.fromOffset(176, 32),
        Text = tostring(options.Default or ""),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(box, 8)
    padding(box, 10, 10, 0, 0)
    local boxStroke = stroke(box, Theme.Border, 0.3, 1)

    box.Focused:Connect(function()
        tween(boxStroke, 0.15, { Color = Theme.Accent, Transparency = 0 })
    end)

    box.FocusLost:Connect(function(enterPressed)
        tween(boxStroke, 0.15, { Color = Theme.Border, Transparency = 0.3 })
        safeCallback(options.Callback, options.Numeric and tonumber(box.Text) or box.Text, enterPressed)
    end)

    if options.Numeric then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local filtered = box.Text:gsub("[^%d%.%-]", "")
            if filtered ~= box.Text then
                box.Text = filtered
            end
        end)
    end

    local controller = {}
    function controller:Set(value, silent)
        box.Text = tostring(value or "")
        if not silent then
            safeCallback(options.Callback, options.Numeric and tonumber(box.Text) or box.Text, false)
        end
    end
    function controller:Get()
        return options.Numeric and tonumber(box.Text) or box.Text
    end
    function controller:Focus()
        box:CaptureFocus()
    end
    function controller:Destroy()
        base.Frame:Destroy()
    end
    return controller
end

function SectionMethods:AddKeybind(options)
    options = merge({
        Title = "Keybind",
        Desc = nil,
        Icon = "keyboard",
        Default = Enum.KeyCode.RightShift,
        Callback = function() end,
        ChangedCallback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local currentKey = options.Default
    local listening = false

    local keyButton = createTextButton({
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(1, -116, 0.5, -16),
        Size = UDim2.fromOffset(102, 32),
        Text = currentKey and currentKey.Name or "None",
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(keyButton, 8)

    local controller = {}

    function controller:Set(keyCode, silent)
        currentKey = keyCode
        keyButton.Text = currentKey and currentKey.Name or "None"
        if not silent then
            safeCallback(options.ChangedCallback, currentKey)
        end
    end

    function controller:Get()
        return currentKey
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    keyButton.MouseButton1Click:Connect(function()
        listening = true
        keyButton.Text = "Press a key..."
        tween(keyButton, 0.12, { BackgroundColor3 = Theme.AccentDark })
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                controller:Set(input.KeyCode)
                tween(keyButton, 0.12, { BackgroundColor3 = Theme.Surface3 })
            end
            return
        end

        if not gameProcessed and currentKey and input.KeyCode == currentKey then
            safeCallback(options.Callback, currentKey)
        end
    end)

    return controller
end

function SectionMethods:AddParagraph(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Information",
        Content = "",
        Icon = "info",
    }, options)

    local frame = create("Frame", {
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 72),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Container,
    })
    corner(frame, 9)
    stroke(frame, Theme.Border, 0.35, 1)
    padding(frame, 14, 14, 12, 12)

    local iconObject = createIcon(frame, options.Icon, 18, Theme.Accent, 3)
    iconObject.Frame.Position = UDim2.fromOffset(0, 1)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -28, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 3,
    })

    local content = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 27),
        Size = UDim2.new(1, -28, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame,
        ZIndex = 3,
    })

    local controller = {}
    function controller:SetTitle(text)
        title.Text = tostring(text)
    end
    function controller:SetContent(text)
        content.Text = tostring(text)
    end
    function controller:Destroy()
        frame:Destroy()
    end
    return controller
end

function SectionMethods:AddDivider(text)
    local frame = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, text and 26 or 14),
        Parent = self.Container,
    })

    local line = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = frame,
    })

    if text then
        local label = create("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(0, 18),
            Font = Enum.Font.Gotham,
            Text = "  " .. tostring(text) .. "  ",
            TextColor3 = Theme.TextDim,
            TextSize = 10,
            Parent = frame,
            ZIndex = 2,
        })
        line.ZIndex = 1
        return label
    end

    return line
end

local TabMethods = {}
TabMethods.__index = TabMethods

function TabMethods:AddSection(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Section",
        Desc = nil,
    }, options)

    local sectionFrame = create("Frame", {
        Name = options.Title,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Page,
    })

    local headerHeight = options.Desc and 49 or 35
    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -4, 0, 22),
        Font = Enum.Font.GothamSemibold,
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sectionFrame,
    })

    if options.Desc then
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(2, 22),
            Size = UDim2.new(1, -4, 0, 18),
            Font = Enum.Font.Gotham,
            Text = options.Desc,
            TextColor3 = Theme.TextDim,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sectionFrame,
        })
    end

    local container = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, headerHeight),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = sectionFrame,
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = container,
    })

    create("UIPadding", {
        PaddingBottom = UDim.new(0, 5),
        Parent = container,
    })

    local section = setmetatable({
        Frame = sectionFrame,
        Container = container,
        TitleLabel = title,
        Tab = self,
    }, SectionMethods)

    return section
end

function TabMethods:Select()
    self.Window:SelectTab(self)
end

function TabMethods:SetTitle(text)
    self.Title = tostring(text)
    self.ButtonLabel.Text = self.Title
    if self.Window.SelectedTab == self then
        self.Window.ActiveTitle.Text = self.Title
    end
end

function TabMethods:Destroy()
    self.Button:Destroy()
    self.Page:Destroy()

    for index, tab in ipairs(self.Window.Tabs) do
        if tab == self then
            table.remove(self.Window.Tabs, index)
            break
        end
    end

    if self.Window.SelectedTab == self then
        self.Window.SelectedTab = nil
        if self.Window.Tabs[1] then
            self.Window:SelectTab(self.Window.Tabs[1])
        end
    end
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods

function WindowMethods:SelectTab(tab)
    if self.SelectedTab == tab then
        return
    end

    for _, item in ipairs(self.Tabs) do
        local selected = item == tab
        item.Page.Visible = selected
        tween(item.Button, 0.15, {
            BackgroundColor3 = selected and Theme.Surface3 or Theme.Surface,
            BackgroundTransparency = selected and 0 or 1,
        })
        tween(item.Indicator, 0.15, {
            BackgroundTransparency = selected and 0 or 1,
        })
        item.ButtonLabel.TextColor3 = selected and Theme.Text or Theme.TextMuted
        if item.IconObject then
            item.IconObject:SetColor(selected and Theme.Accent or Theme.TextMuted)
        end
    end

    self.SelectedTab = tab
    self.ActiveTitle.Text = tab.Title
    self.ActiveDescription.Text = tab.Description or ""
    self.ActiveDescription.Visible = tab.Description ~= nil and tab.Description ~= ""
end

function WindowMethods:AddTab(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Tab",
        Desc = nil,
        Icon = "circle",
    }, options)

    local button = createTextButton({
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = self.TabList,
        ZIndex = 5,
    })
    corner(button, 8)

    local indicator = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 22),
        Parent = button,
        ZIndex = 7,
    })
    corner(indicator, 99)

    local iconObject = createIcon(button, options.Icon, 17, Theme.TextMuted, 7)
    iconObject.Frame.Position = UDim2.new(0, 13, 0.5, -8)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(41, 0),
        Size = UDim2.new(1, -51, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = options.Title,
        TextColor3 = Theme.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
        ZIndex = 7,
    })

    local page = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
        Parent = self.PageContainer,
        ZIndex = 3,
    })
    padding(page, 0, 7, 0, 18)

    create("UIListLayout", {
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    local tab = setmetatable({
        Window = self,
        Title = options.Title,
        Description = options.Desc,
        Button = button,
        ButtonLabel = label,
        Indicator = indicator,
        IconObject = iconObject,
        Page = page,
    }, TabMethods)

    table.insert(self.Tabs, tab)

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    button.MouseEnter:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0.45 })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 1 })
        end
    end)

    if not self.SelectedTab then
        self:SelectTab(tab)
    end

    return tab
end

function WindowMethods:SetVisible(value)
    self.Visible = value == true
    self.Root.Visible = self.Visible
    if self.MobileButton then
        self.MobileButton.Visible = not self.Visible
    end
end

function WindowMethods:Toggle()
    self:SetVisible(not self.Visible)
end

function WindowMethods:Minimize(value)
    if value == nil then
        value = not self.Minimized
    end

    self.Minimized = value == true
    self.Body.Visible = not self.Minimized
    tween(self.Main, 0.22, {
        Size = self.Minimized and UDim2.fromOffset(self.Size.X.Offset, 50) or self.Size,
    }, Enum.EasingStyle.Quint)
end

function WindowMethods:SetToggleKey(keyCode)
    self.ToggleKey = keyCode
end

function WindowMethods:Notify(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Notification",
        Content = "",
        Duration = 4,
        Icon = "bell",
        Type = "Info",
    }, options)

    local accent = Theme.Accent
    if options.Type == "Success" then
        accent = Theme.Success
    elseif options.Type == "Warning" then
        accent = Theme.Warning
    elseif options.Type == "Error" or options.Type == "Danger" then
        accent = Theme.Danger
    end

    local card = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(300, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.NotificationList,
        ZIndex = 100,
    })
    corner(card, 10)
    stroke(card, Theme.Border, 0.1, 1)
    padding(card, 14, 14, 12, 12)

    local iconObject = createIcon(card, options.Icon, 18, accent, 102)
    iconObject.Frame.Position = UDim2.fromOffset(0, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -28, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
        ZIndex = 102,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 25),
        Size = UDim2.new(1, -28, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
        ZIndex = 102,
    })

    card.BackgroundTransparency = 1
    card.Position = UDim2.fromOffset(40, 0)
    tween(card, 0.25, { BackgroundTransparency = 0, Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)

    task.delay(math.max(tonumber(options.Duration) or 4, 0.5), function()
        if not card.Parent then
            return
        end
        tween(card, 0.2, { BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 0) })
        task.delay(0.22, function()
            if card.Parent then
                card:Destroy()
            end
        end)
    end)
end

function WindowMethods:Destroy()
    if self.InputConnection then
        self.InputConnection:Disconnect()
    end
    self.ScreenGui:Destroy()
end

function VoltzUI:CreateWindow(options)
    options = merge({
        Title = "Voltz UI",
        Subtitle = "Clean Roblox Interface",
        Icon = "sparkles",
        Size = UDim2.fromOffset(690, 470),
        ToggleKey = Enum.KeyCode.RightShift,
        MobileButton = true,
        Acrylic = false,
    }, options)

    loadExternalIcons()

    local previous = getGuiParent():FindFirstChild("VoltzUI")
    if previous then
        previous:Destroy()
    end

    local screenGui = create("ScreenGui", {
        Name = "VoltzUI",
        DisplayOrder = 999,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    protectGui(screenGui)
    screenGui.Parent = getGuiParent()

    local root = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = screenGui,
    })

    local main = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = options.Size,
        ClipsDescendants = true,
        Parent = root,
        ZIndex = 2,
    })
    corner(main, 13)
    stroke(main, Theme.Border, 0.05, 1)

    local uiScale = create("UIScale", {
        Scale = 1,
        Parent = main,
    })

    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        local viewport = camera.ViewportSize
        local desiredWidth = options.Size.X.Offset + 40
        local desiredHeight = options.Size.Y.Offset + 40
        uiScale.Scale = math.min(1, viewport.X / desiredWidth, viewport.Y / desiredHeight)
    end

    updateScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    local topbar = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = main,
        ZIndex = 5,
    })

    create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = topbar,
        ZIndex = 6,
    })

    local logoBox = create("Frame", {
        BackgroundColor3 = Theme.AccentDark,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.fromOffset(30, 30),
        Parent = topbar,
        ZIndex = 7,
    })
    corner(logoBox, 8)
    local logo = createIcon(logoBox, options.Icon, 17, Color3.fromRGB(255, 255, 255), 8)
    logo.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Frame.Position = UDim2.fromScale(0.5, 0.5)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(54, 6),
        Size = UDim2.new(1, -180, 0, 21),
        Font = Enum.Font.GothamSemibold,
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
        ZIndex = 7,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(54, 25),
        Size = UDim2.new(1, -180, 0, 17),
        Font = Enum.Font.Gotham,
        Text = options.Subtitle,
        TextColor3 = Theme.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
        ZIndex = 7,
    })

    local minimizeButton = createTextButton({
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -82, 0, 10),
        Size = UDim2.fromOffset(30, 30),
        Parent = topbar,
        ZIndex = 8,
    })
    corner(minimizeButton, 8)
    local minimizeIcon = createIcon(minimizeButton, "minus", 15, Theme.TextMuted, 9)
    minimizeIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    minimizeIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
    bindHover(minimizeButton, Theme.Surface2, Theme.Surface3)

    local closeButton = createTextButton({
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -44, 0, 10),
        Size = UDim2.fromOffset(30, 30),
        Parent = topbar,
        ZIndex = 8,
    })
    corner(closeButton, 8)
    local closeIcon = createIcon(closeButton, "x", 15, Theme.TextMuted, 9)
    closeIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
    closeButton.MouseEnter:Connect(function()
        tween(closeButton, 0.14, { BackgroundColor3 = Theme.Danger })
        closeIcon:SetColor(Color3.fromRGB(255, 255, 255))
    end)
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, 0.14, { BackgroundColor3 = Theme.Surface2 })
        closeIcon:SetColor(Theme.TextMuted)
    end)

    local body = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        Parent = main,
        ZIndex = 3,
    })

    local sidebar = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 178, 1, 0),
        Parent = body,
        ZIndex = 4,
    })

    create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar,
        ZIndex = 5,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 12),
        Size = UDim2.new(1, -28, 0, 18),
        Font = Enum.Font.GothamMedium,
        Text = "NAVIGATION",
        TextColor3 = Theme.TextDim,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebar,
        ZIndex = 5,
    })

    local tabList = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Position = UDim2.fromOffset(10, 38),
        Size = UDim2.new(1, -20, 1, -50),
        ScrollBarThickness = 0,
        Parent = sidebar,
        ZIndex = 5,
    })
    create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList,
    })

    local content = create("Frame", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(178, 0),
        Size = UDim2.new(1, -178, 1, 0),
        Parent = body,
        ZIndex = 3,
    })

    local activeTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 14),
        Size = UDim2.new(1, -40, 0, 22),
        Font = Enum.Font.GothamSemibold,
        Text = "Tab",
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content,
        ZIndex = 4,
    })

    local activeDescription = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 36),
        Size = UDim2.new(1, -40, 0, 17),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Theme.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        Parent = content,
        ZIndex = 4,
    })

    local pageContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 61),
        Size = UDim2.new(1, -40, 1, -61),
        ClipsDescendants = true,
        Parent = content,
        ZIndex = 3,
    })

    local notificationList = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.fromOffset(300, 600),
        Parent = screenGui,
        ZIndex = 100,
    })
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notificationList,
    })

    local window = setmetatable({
        ScreenGui = screenGui,
        Root = root,
        Main = main,
        Body = body,
        Topbar = topbar,
        TabList = tabList,
        PageContainer = pageContainer,
        ActiveTitle = activeTitle,
        ActiveDescription = activeDescription,
        NotificationList = notificationList,
        Tabs = {},
        SelectedTab = nil,
        Visible = true,
        Minimized = false,
        Size = options.Size,
        ToggleKey = options.ToggleKey,
        MobileButton = nil,
    }, WindowMethods)

    minimizeButton.MouseButton1Click:Connect(function()
        window:Minimize()
    end)

    closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)

    dragify(topbar, main)

    window.InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window.ToggleKey then
            window:Toggle()
        end
    end)

    if options.MobileButton and UserInputService.TouchEnabled then
        local mobileButton = createTextButton({
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Theme.AccentDark,
            Position = UDim2.new(1, -18, 1, -18),
            Size = UDim2.fromOffset(48, 48),
            Visible = false,
            Parent = screenGui,
            ZIndex = 120,
        })
        corner(mobileButton, 12)
        stroke(mobileButton, Theme.Accent, 0.1, 1)
        local mobileIcon = createIcon(mobileButton, options.Icon, 22, Color3.fromRGB(255, 255, 255), 121)
        mobileIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        mobileIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
        mobileButton.MouseButton1Click:Connect(function()
            window:SetVisible(true)
        end)
        dragify(mobileButton, mobileButton)
        window.MobileButton = mobileButton
    end

    return window
end

-- Friendly aliases: both AddButton(...) and Button(...) styles are supported.
WindowMethods.CreateTab = WindowMethods.AddTab
WindowMethods.Notification = WindowMethods.Notify
WindowMethods.SetVisibility = WindowMethods.SetVisible
TabMethods.CreateSection = TabMethods.AddSection
SectionMethods.Button = SectionMethods.AddButton
SectionMethods.Toggle = SectionMethods.AddToggle
SectionMethods.Slider = SectionMethods.AddSlider
SectionMethods.Dropdown = SectionMethods.AddDropdown
SectionMethods.Input = SectionMethods.AddInput
SectionMethods.Keybind = SectionMethods.AddKeybind
SectionMethods.Paragraph = SectionMethods.AddParagraph
SectionMethods.Divider = SectionMethods.AddDivider

VoltzUI.Theme = Theme
VoltzUI.LoadIcons = loadExternalIcons

return VoltzUI
