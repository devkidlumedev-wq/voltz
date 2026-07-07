-- BUILD: VOLTZUI-1.2.7-THAI-FONT-20260707
--[[
    VoltzUI - Clean Roblox UI Library
    BUILD: VOLTZUI-1.2.7-THAI-FONT-20260707
    Theme: clean dark + blue accent
    External icons: https://github.com/Footagesus/Icons

    Designed for client-side Roblox/Luau environments that support HttpGet + loadstring.
    Includes persistent flags/config support through executor file APIs.
    In Studio, you can inject your own compatible icon provider with VoltzUI:SetIconProvider(provider).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local VoltzUI = {
    Version = "1.2.7",
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
    AccentLight = Color3.fromRGB(126, 218, 255),
    AccentDark = Color3.fromRGB(34, 145, 214),

    -- Window layers
    Background = Color3.fromRGB(12, 16, 22),
    Surface = Color3.fromRGB(18, 23, 31),

    -- Raised cards and control surfaces. These are deliberately brighter
    -- than the page so cards no longer look pressed into the background.
    Surface2 = Color3.fromRGB(34, 42, 54),
    Surface3 = Color3.fromRGB(45, 55, 70),
    SurfaceHover = Color3.fromRGB(40, 50, 64),
    Border = Color3.fromRGB(67, 80, 99),

    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(205, 214, 226),
    TextDim = Color3.fromRGB(153, 168, 188),

    Success = Color3.fromRGB(74, 222, 128),
    Danger = Color3.fromRGB(248, 113, 113),
    Warning = Color3.fromRGB(250, 204, 21),
}

-- Thai-capable font system.
-- NotoSansThai is preferred; safe fallbacks prevent the library from failing
-- when a specific font family is unavailable in the current Roblox build.
local FONT_FALLBACKS = {
    "NotoSansThai",
    "NotoSans",
    "BuilderSans",
    "Gotham",
}

local FONT_WEIGHTS = {
    Regular = Enum.FontWeight.Regular,
    Medium = Enum.FontWeight.Medium,
    SemiBold = Enum.FontWeight.SemiBold,
}

local ActiveFontFamily = "NotoSansThai"
local ActiveFonts = {}

local function tryFontFromName(family, weight)
    if type(family) ~= "string" or family == "" then
        return nil
    end

    local success, result = pcall(function()
        return Font.fromName(family, weight, Enum.FontStyle.Normal)
    end)

    if success and result then
        return result
    end
    return nil
end

local function fallbackFont(weight)
    local success, result = pcall(function()
        return Font.new(
            "rbxasset://fonts/families/GothamSSm.json",
            weight,
            Enum.FontStyle.Normal
        )
    end)

    if success and result then
        return result
    end

    -- BuilderSans should exist on modern clients and remains the final fallback.
    return Font.fromName("BuilderSans", weight, Enum.FontStyle.Normal)
end

local function resolveFontForRole(spec, role)
    local weight = FONT_WEIGHTS[role] or Enum.FontWeight.Regular

    if typeof(spec) == "Font" then
        return Font.new(spec.Family, weight, spec.Style)
    end

    if type(spec) == "table" then
        local direct = spec[role] or spec[role:lower()]
        if typeof(direct) == "Font" then
            return direct
        end
    end

    local requestedFamily
    if type(spec) == "string" then
        requestedFamily = spec
    elseif type(spec) == "table" then
        requestedFamily = spec.Family or spec.Name
    end

    local checked = {}
    local candidates = {}
    if requestedFamily and requestedFamily ~= "" then
        table.insert(candidates, requestedFamily)
    end
    for _, family in ipairs(FONT_FALLBACKS) do
        table.insert(candidates, family)
    end

    for _, family in ipairs(candidates) do
        if not checked[family] then
            checked[family] = true
            local font = tryFontFromName(family, weight)
            if font then
                return font, family
            end
        end
    end

    return fallbackFont(weight), "Gotham"
end

local function applyFontSpec(spec)
    local family = type(spec) == "string" and spec
        or (type(spec) == "table" and (spec.Family or spec.Name))
        or "NotoSansThai"

    local resolved = {}
    local resolvedFamily = family
    for role in pairs(FONT_WEIGHTS) do
        local font, actualFamily = resolveFontForRole(spec or family, role)
        resolved[role] = font
        if actualFamily then
            resolvedFamily = actualFamily
        end
    end

    ActiveFontFamily = resolvedFamily or family
    ActiveFonts = resolved
    VoltzUI.FontFamily = ActiveFontFamily
    VoltzUI.Fonts = ActiveFonts
end

local function fontFace(role)
    return ActiveFonts[role] or ActiveFonts.Regular or fallbackFont(Enum.FontWeight.Regular)
end

applyFontSpec("NotoSansThai")

function VoltzUI:SetFont(fontSpec)
    applyFontSpec(fontSpec or "NotoSansThai")
    return self
end

function VoltzUI:GetFont()
    return self.FontFamily, self.Fonts
end

local function cloneTable(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local function deepClone(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, item in pairs(value) do
        result[deepClone(key)] = deepClone(item)
    end
    return result
end

local function sanitizeName(value, fallback)
    local result = tostring(value or fallback or "default")
    result = result:gsub("[^%w%._%-]", "_")
    if result == "" then
        result = fallback or "default"
    end
    return result
end

local function buildConfigPath(folder, fileName)
    local safeFolder = sanitizeName(folder or "voltz", "voltz")
    local safeName = sanitizeName(fileName or "settings", "settings")
    return safeFolder .. "/" .. safeName .. ".json", safeName
end

local function listConfigNames(folder)
    local names = {}
    if type(listfiles) == "function" then
        local ok, files = pcall(listfiles, folder)
        if ok and type(files) == "table" then
            for _, filePath in ipairs(files) do
                local normalized = tostring(filePath):gsub(string.char(92), "/")
                local name = normalized:match("([^/]+)%.json$")
                if name and name ~= "" then
                    names[name] = true
                end
            end
        end
    end

    local result = {}
    for name in pairs(names) do
        table.insert(result, name)
    end
    table.sort(result, function(a, b)
        return tostring(a):lower() < tostring(b):lower()
    end)
    return result
end

local function normalizeConfigOptions(raw)
    if raw == true then
        raw = { Enabled = true }
    elseif type(raw) ~= "table" then
        raw = {}
    end

    local folder = sanitizeName(raw.Folder or "voltz", "voltz")
    local fileName = sanitizeName(raw.FileName or raw.Name or "settings", "settings")
    local path = buildConfigPath(folder, fileName)

    local config = {
        Enabled = raw.Enabled == true,
        Folder = folder,
        FileName = fileName,
        AutoLoad = raw.AutoLoad ~= false,
        AutoSave = raw.AutoSave ~= false,
        SaveWindowPosition = raw.SaveWindowPosition ~= false,
        SaveSelectedTab = raw.SaveSelectedTab ~= false,
        SaveMinimized = raw.SaveMinimized == true,
        AutoSaveDelay = math.max(tonumber(raw.AutoSaveDelay) or 0.35, 0.1),
    }

    config.Path = path
    return config
end

local function fileSystemAvailable()
    return type(readfile) == "function"
        and type(writefile) == "function"
        and type(isfile) == "function"
end

local function ensureFolder(folder)
    if folder == "" then
        return true
    end

    if type(isfolder) == "function" then
        local ok, exists = pcall(isfolder, folder)
        if ok and exists then
            return true
        end
    end

    if type(makefolder) == "function" then
        local ok = pcall(makefolder, folder)
        return ok
    end

    return false
end

local function serializeValue(value)
    local valueType = typeof(value)

    if valueType == "EnumItem" then
        return {
            __voltzType = "EnumItem",
            EnumType = tostring(value.EnumType),
            Name = value.Name,
        }
    elseif valueType == "Color3" then
        return {
            __voltzType = "Color3",
            R = value.R,
            G = value.G,
            B = value.B,
        }
    elseif valueType == "UDim2" then
        return {
            __voltzType = "UDim2",
            XS = value.X.Scale,
            XO = value.X.Offset,
            YS = value.Y.Scale,
            YO = value.Y.Offset,
        }
    elseif valueType == "Vector2" then
        return {
            __voltzType = "Vector2",
            X = value.X,
            Y = value.Y,
        }
    elseif type(value) == "table" then
        local result = {}
        for key, item in pairs(value) do
            result[tostring(key)] = serializeValue(item)
        end
        return result
    end

    return value
end

local function deserializeValue(value)
    if type(value) ~= "table" then
        return value
    end

    if value.__voltzType == "EnumItem" then
        local enumName = tostring(value.EnumType or ""):match("Enum%.(.+)")
        local enumType = enumName and Enum[enumName]
        if enumType and value.Name then
            return enumType[value.Name]
        end
        return nil
    elseif value.__voltzType == "Color3" then
        return Color3.new(tonumber(value.R) or 0, tonumber(value.G) or 0, tonumber(value.B) or 0)
    elseif value.__voltzType == "UDim2" then
        return UDim2.new(
            tonumber(value.XS) or 0,
            tonumber(value.XO) or 0,
            tonumber(value.YS) or 0,
            tonumber(value.YO) or 0
        )
    elseif value.__voltzType == "Vector2" then
        return Vector2.new(tonumber(value.X) or 0, tonumber(value.Y) or 0)
    end

    local result = {}
    for key, item in pairs(value) do
        result[key] = deserializeValue(item)
    end
    return result
end

local function readConfigData(config)
    if not config.Enabled then
        return nil, "Config is disabled"
    end

    if not fileSystemAvailable() then
        return nil, "Executor file functions are unavailable"
    end

    local existsOk, exists = pcall(isfile, config.Path)
    if not existsOk or not exists then
        return nil, "Config file does not exist"
    end

    local readOk, source = pcall(readfile, config.Path)
    if not readOk or type(source) ~= "string" or source == "" then
        return nil, "Unable to read config file"
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(source)
    end)
    if not decodeOk or type(decoded) ~= "table" then
        return nil, "Config JSON is invalid"
    end

    return decoded
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

local function destroyPreviousVoltzUI()
    local checked = {}

    local function clean(parent)
        if not parent or checked[parent] then
            return
        end
        checked[parent] = true

        local existing = parent:FindFirstChild("VoltzUI")
        if existing then
            pcall(function()
                existing:Destroy()
            end)
        end
    end

    pcall(function()
        if type(gethui) == "function" then
            clean(gethui())
        end
    end)

    clean(CoreGui)

    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            clean(playerGui)
        end
    end
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

local function dragify(handle, target, changedCallback, endedCallback)
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
                    local wasDragging = dragging
                    dragging = false
                    if wasDragging and type(endedCallback) == "function" then
                        endedCallback(target.Position)
                    end
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
            if type(changedCallback) == "function" then
                changedCallback(target.Position)
            end
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
        FontFace = fontFace("Medium"),
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
        Size = UDim2.new(1, 0, 0, height or (options.Desc and 68 or 58)),
        ClipsDescendants = true,
        Parent = section.Container,
    })
    corner(frame, 15)

    local leftOffset = 16
    local iconObject
    if options.Icon then
        iconObject = createIcon(frame, options.Icon, 18, Theme.TextMuted, 3)
        iconObject.Frame.Position = UDim2.new(0, 16, 0.5, -9)
        leftOffset = 46
    end

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftOffset, 0, options.Desc and 12 or 0),
        Size = UDim2.new(1, -(leftOffset + 112), options.Desc and 0 or 1, options.Desc and 21 or 0),
        FontFace = fontFace("Medium"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = frame,
        ZIndex = 3,
    })

    local description
    if options.Desc then
        description = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, leftOffset, 0, 36),
            Size = UDim2.new(1, -(leftOffset + 112), 0, 18),
            FontFace = fontFace("Regular"),
            Text = options.Desc,
            TextColor3 = Theme.TextMuted,
            TextTransparency = 0,
            TextSize = 12,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = frame,
            ZIndex = 3,
        })
    end

    -- No UIStroke here: the previous outline was the "sunken border" visible around every card.
    frame.MouseEnter:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.SurfaceHover })
    end)

    frame.MouseLeave:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.Surface2 })
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
        Position = UDim2.new(1, -96, 0.5, -17),
        Size = UDim2.fromOffset(84, 34),
        Text = options.ButtonText or "Run",
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(action, 10)
    bindHover(action, Theme.Surface3, Theme.AccentDark)

    action.MouseButton1Click:Connect(function()
        tween(action, 0.08, { Size = UDim2.fromOffset(80, 32), Position = UDim2.new(1, -92, 0.5, -15) })
        task.delay(0.08, function()
            if action.Parent then
                tween(action, 0.1, { Size = UDim2.fromOffset(84, 34), Position = UDim2.new(1, -94, 0.5, -16) })
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
        Position = UDim2.new(1, -64, 0.5, -14),
        Size = UDim2.fromOffset(50, 28),
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(toggleButton, 99)

    local knob = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = state and UDim2.new(1, -25, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
        Size = UDim2.fromOffset(20, 20),
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
            Position = state and UDim2.new(1, -25, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
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

    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "toggle")
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
        FontFace = fontFace("Medium"),
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
        Size = UDim2.new(1, -28, 0, 7),
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
        Size = UDim2.fromOffset(16, 16),
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
    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "slider")
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
        Size = UDim2.fromOffset(156, 34),
        Parent = base.Frame,
        ZIndex = 5,
    })
    corner(selector, 10)

    local selectedLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        FontFace = fontFace("Regular"),
        Text = "Select...",
        TextColor3 = Theme.TextMuted,
        TextTransparency = 0.08,
        TextSize = 12,
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
        ScrollBarImageColor3 = Theme.Border,
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
        local listHeight = visibleCount > 0 and (visibleCount * 35 + math.max(visibleCount - 1, 0) * 5) or 0
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
                Size = UDim2.new(1, 0, 0, 35),
                LayoutOrder = index,
                Parent = list,
                ZIndex = 7,
            })
            corner(optionButton, 9)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                FontFace = fontFace("Regular"),
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
                    if controller._Commit then
                        controller:_Commit()
                    end
                else
                    selected = valueName
                    refreshVisuals()
                    setOpen(false)
                    safeCallback(options.Callback, selected)
                    if controller._Commit then
                        controller:_Commit()
                    end
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
    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, options.Multi and "multi-dropdown" or "dropdown")
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
        FontFace = fontFace("Regular"),
        PlaceholderColor3 = Theme.TextDim,
        PlaceholderText = options.Placeholder,
        Position = UDim2.new(1, -190, 0.5, -16),
        Size = UDim2.fromOffset(176, 34),
        Text = tostring(options.Default or ""),
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(box, 10)
    padding(box, 10, 10, 0, 0)
    local boxStroke = stroke(box, Theme.Border, 0.16, 1)

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

    local controller = {
        _Box = box,
    }
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
    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "input")
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
        Size = UDim2.fromOffset(104, 34),
        Text = currentKey and currentKey.Name or "None",
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(keyButton, 10)

    local controller = {}

    function controller:Set(keyCode, silent)
        if type(keyCode) == "string" then
            keyCode = Enum.KeyCode[keyCode]
        end
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

    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "keybind")
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
        Size = UDim2.new(1, 0, 0, 80),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Container,
    })
    corner(frame, 15)
    padding(frame, 16, 16, 14, 14)

    local iconObject = createIcon(frame, options.Icon, 18, Theme.Accent, 3)
    iconObject.Frame.Position = UDim2.fromOffset(0, 1)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -30, 0, 22),
        FontFace = fontFace("Medium"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 3,
    })

    local content = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 30),
        Size = UDim2.new(1, -30, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = fontFace("Regular"),
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextTransparency = 0,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame,
        ZIndex = 3,
    })

    frame.MouseEnter:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.SurfaceHover })
    end)

    frame.MouseLeave:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.Surface2 })
    end)

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
            FontFace = fontFace("Regular"),
            Text = "  " .. tostring(text) .. "  ",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
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
        BackgroundTransparency = 1,
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
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sectionFrame,
    })

    if options.Desc then
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(2, 22),
            Size = UDim2.new(1, -4, 0, 18),
            FontFace = fontFace("Regular"),
            Text = options.Desc,
            TextColor3 = Theme.TextMuted,
            TextTransparency = 0,
            TextSize = 11,
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
        Padding = UDim.new(0, 9),
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
        Title = options.Title,
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

function WindowMethods:_BuildFlag(section, options)
    local requested = options.Flag
    local base = requested or table.concat({
        tostring(section.Tab.Title or "Tab"),
        tostring(section.Title or "Section"),
        tostring(options.Title or "Control"),
    }, ".")

    base = sanitizeName(base, "Control")
    local flag = base
    local index = 2
    while self.Controls[flag] do
        flag = base .. "_" .. tostring(index)
        index = index + 1
    end
    return flag
end

function WindowMethods:_QueueAutoSave()
    if not self.Config.Enabled
        or not self.Config.AutoSave
        or self._LoadingConfig
        or self._Initializing then
        return
    end

    self._SaveToken = (self._SaveToken or 0) + 1
    local token = self._SaveToken
    task.delay(self.Config.AutoSaveDelay, function()
        if self.ScreenGui and self.ScreenGui.Parent and token == self._SaveToken then
            self:SaveConfig()
        end
    end)
end

function WindowMethods:_StoreControl(flag, value)
    if not flag then
        return
    end

    self.Flags[flag] = deepClone(value)
    self:_QueueAutoSave()
end

function WindowMethods:_RegisterControl(section, options, controller, defaultValue, controlType)
    local flag = self:_BuildFlag(section, options)
    local originalSet = controller.Set
    local window = self

    controller.Flag = flag
    controller.Type = controlType

    function controller:Set(value, silent)
        originalSet(self, value, silent)
        window:_StoreControl(flag, self:Get())
    end

    function controller:_Commit()
        window:_StoreControl(flag, self:Get())
    end

    self.Controls[flag] = {
        Controller = controller,
        Default = deepClone(defaultValue),
        Save = options.Save ~= false,
        Type = controlType,
    }
    self.Flags[flag] = deepClone(controller:Get())

    if controller._Box then
        controller._Box:GetPropertyChangedSignal("Text"):Connect(function()
            if controller._Commit then
                controller:_Commit()
            end
        end)
    end

    local savedValues = self.LoadedConfig and self.LoadedConfig.Values
    if self.Config.AutoLoad and type(savedValues) == "table" and savedValues[flag] ~= nil then
        self._LoadingConfig = true
        controller:Set(deserializeValue(savedValues[flag]), false)
        self._LoadingConfig = false
    end

    return controller
end

function WindowMethods:SetAutoSave(value)
    self.Config.AutoSave = value == true
    if self.Config.AutoSave then
        self:_QueueAutoSave()
    end
end

function WindowMethods:SetConfigName(name)
    local path, safeName = buildConfigPath(self.Config.Folder, name or self.Config.FileName)
    self.Config.FileName = safeName
    self.Config.Path = path
    return safeName, path
end

function WindowMethods:GetConfigName()
    return self.Config.FileName
end

function WindowMethods:GetConfigList()
    local names = listConfigNames(self.Config.Folder)
    if self.Config.FileName and self.Config.FileName ~= "" then
        local found = false
        for _, item in ipairs(names) do
            if item == self.Config.FileName then
                found = true
                break
            end
        end
        if not found then
            table.insert(names, self.Config.FileName)
            table.sort(names, function(a, b)
                return tostring(a):lower() < tostring(b):lower()
            end)
        end
    end
    return names
end

function WindowMethods:RefreshConfigList()
    return self:GetConfigList()
end

function WindowMethods:GetFlag(flag)
    return deepClone(self.Flags[flag])
end

function WindowMethods:SetFlag(flag, value, silent)
    local data = self.Controls[flag]
    if not data then
        return false, "Unknown flag: " .. tostring(flag)
    end

    data.Controller:Set(value, silent == true)
    return true
end

function WindowMethods:GetFlags()
    return deepClone(self.Flags)
end

function WindowMethods:SaveConfig(configName)
    if not self.Config.Enabled then
        return false, "Config is disabled"
    end
    if configName ~= nil then
        self:SetConfigName(configName)
    end

    if configName ~= nil then
        self:SetConfigName(configName)
    end

    if not fileSystemAvailable() then
        return false, "Executor does not support readfile/writefile/isfile"
    end

    ensureFolder(self.Config.Folder)

    local values = {}
    for flag, data in pairs(self.Controls) do
        if data.Save ~= false then
            values[flag] = serializeValue(data.Controller:Get())
        end
    end

    local windowData = {}
    if self.Config.SaveWindowPosition then
        windowData.Position = serializeValue(self.Main.Position)
    end
    if self.Config.SaveSelectedTab and self.SelectedTab then
        windowData.SelectedTab = self.SelectedTab.Title
    end
    if self.Config.SaveMinimized then
        windowData.Minimized = self.Minimized
    end

    local payload = {
        Version = 1,
        LibraryVersion = VoltzUI.Version,
        Values = values,
        Window = windowData,
    }

    local encodeOk, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not encodeOk then
        return false, "Unable to encode config: " .. tostring(encoded)
    end

    local writeOk, writeError = pcall(writefile, self.Config.Path, encoded)
    if not writeOk then
        return false, "Unable to write config: " .. tostring(writeError)
    end

    self.LoadedConfig = payload
    return true, self.Config.Path
end

function WindowMethods:LoadConfig(configName)
    if configName ~= nil then
        self:SetConfigName(configName)
    end

    local data, readError = readConfigData(self.Config)
    if not data then
        return false, readError
    end

    self.LoadedConfig = data
    self._LoadingConfig = true

    local values = type(data.Values) == "table" and data.Values or {}
    for flag, controlData in pairs(self.Controls) do
        if values[flag] ~= nil then
            controlData.Controller:Set(deserializeValue(values[flag]), false)
        end
    end

    local windowData = type(data.Window) == "table" and data.Window or {}
    if self.Config.SaveWindowPosition and windowData.Position then
        local position = deserializeValue(windowData.Position)
        if typeof(position) == "UDim2" then
            self.Main.Position = position
            if self.Shadow then
                self.Shadow.Position = UDim2.new(
                    position.X.Scale,
                    position.X.Offset,
                    position.Y.Scale,
                    position.Y.Offset + 8
                )
            end
        end
    end

    if self.Config.SaveSelectedTab and windowData.SelectedTab then
        self.PendingSelectedTab = tostring(windowData.SelectedTab)
        for _, tab in ipairs(self.Tabs) do
            if tab.Title == self.PendingSelectedTab then
                self:SelectTab(tab)
                break
            end
        end
    end

    if self.Config.SaveMinimized and windowData.Minimized ~= nil then
        self:Minimize(windowData.Minimized == true)
    end

    self._LoadingConfig = false
    return true, self.Config.Path
end

function WindowMethods:ResetConfig(saveAfterReset)
    self._LoadingConfig = true
    for flag, data in pairs(self.Controls) do
        if data.Save ~= false then
            data.Controller:Set(deepClone(data.Default), false)
            self.Flags[flag] = deepClone(data.Controller:Get())
        end
    end
    self._LoadingConfig = false

    if saveAfterReset ~= false then
        return self:SaveConfig()
    end
    return true
end

function WindowMethods:DeleteConfig(configName)
    if not self.Config.Enabled then
        return false, "Config is disabled"
    end
    if configName ~= nil then
        self:SetConfigName(configName)
    end
    if type(delfile) ~= "function" or type(isfile) ~= "function" then
        return false, "Executor does not support delfile/isfile"
    end

    local existsOk, exists = pcall(isfile, self.Config.Path)
    if existsOk and exists then
        local deleteOk, deleteError = pcall(delfile, self.Config.Path)
        if not deleteOk then
            return false, tostring(deleteError)
        end
    end
    return true
end

function WindowMethods:SelectTab(tab)
    if self.SelectedTab == tab then
        return
    end

    for _, item in ipairs(self.Tabs) do
        local selected = item == tab
        item.Page.Visible = selected
        tween(item.Button, 0.15, {
            BackgroundColor3 = selected and Theme.Surface2 or Theme.Surface,
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
    if not self._LoadingConfig then
        self:_QueueAutoSave()
    end
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
    corner(button, 11)

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
        FontFace = fontFace("Medium"),
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
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        Visible = false,
        Parent = self.PageContainer,
        ZIndex = 3,
    })
    padding(page, 2, 10, 0, 18)

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

    if self.PendingSelectedTab and self.PendingSelectedTab == tab.Title then
        self:SelectTab(tab)
    elseif not self.SelectedTab then
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
    local targetSize = self.Minimized and UDim2.fromOffset(self.Size.X.Offset, 50) or self.Size
    tween(self.Main, 0.22, {
        Size = targetSize,
    }, Enum.EasingStyle.Quint)
    if self.Shadow then
        tween(self.Shadow, 0.22, { Size = targetSize }, Enum.EasingStyle.Quint)
    end
    if not self._LoadingConfig then
        self:_QueueAutoSave()
    end
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
    corner(card, 12)
    stroke(card, Theme.Border, 0.14, 1)
    padding(card, 14, 14, 12, 12)

    local iconObject = createIcon(card, options.Icon, 18, accent, 102)
    iconObject.Frame.Position = UDim2.fromOffset(0, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -28, 0, 20),
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
        ZIndex = 102,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 25),
        Size = UDim2.new(1, -28, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = fontFace("Regular"),
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextSize = 12,
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

function WindowMethods:AddConfigSection(tab, options)
    options = merge({
        Title = "Configuration",
        Desc = "Save, load and manage multiple VoltzUI configs",
    }, options)

    local section = tab:AddSection({
        Title = options.Title,
        Desc = options.Desc,
    })

    local status = section:AddParagraph({
        Title = self.Config.Enabled and "Config ready" or "Config disabled",
        Content = self.Config.Enabled
            and ("Folder: " .. self.Config.Folder .. "\nActive: " .. self.Config.FileName)
            or "Enable Config in CreateWindow to save settings.",
        Icon = self.Config.Enabled and "database" or "circle-off",
    })

    local configNameInput
    local configListDropdown

    local function refreshStatus(titleText, contentText)
        status:SetTitle(titleText)
        status:SetContent(contentText)
    end

    local function showResult(title, success, message)
        refreshStatus(
            success and title or (title .. " failed"),
            self.Config.Enabled
                and ((tostring(message or "Done")) .. "\nActive: " .. self.Config.FileName)
                or tostring(message or "Done")
        )
        self:Notify({
            Title = title,
            Content = tostring(message or "Done"),
            Type = success and "Success" or "Error",
            Icon = success and "circle-check" or "circle-x",
        })
    end

    local function currentTypedName()
        local raw = configNameInput and configNameInput:Get() or self.Config.FileName
        local safe = sanitizeName(raw, self.Config.FileName or "settings")
        return safe
    end

    local function refreshConfigDropdown(selectName)
        if not configListDropdown then
            return
        end
        local names = self:RefreshConfigList()
        if #names == 0 and currentTypedName() ~= "" then
            names = { currentTypedName() }
        end
        configListDropdown:SetValues(names)
        local target = selectName or self.Config.FileName or names[1]
        if target then
            configListDropdown:Set(target, true)
        end
    end

    configListDropdown = section:AddDropdown({
        Title = "Saved configs",
        Desc = "Choose a config file from your saved list",
        Icon = "folder-open",
        Values = self:RefreshConfigList(),
        Default = self.Config.FileName,
        Save = false,
        Callback = function(value)
            if value and value ~= "" then
                self:SetConfigName(value)
                if configNameInput then
                    configNameInput:Set(value, true)
                end
                refreshStatus("Config selected", "Folder: " .. self.Config.Folder .. "\nActive: " .. self.Config.FileName)
            end
        end,
    })

    configNameInput = section:AddInput({
        Title = "Config name",
        Desc = "Type the name you want to save or load as",
        Icon = "text-cursor-input",
        Default = self.Config.FileName,
        Placeholder = "example_config",
        Save = false,
        Callback = function(text)
            local name = sanitizeName(text, self.Config.FileName or "settings")
            self:SetConfigName(name)
            refreshStatus("Config selected", "Folder: " .. self.Config.Folder .. "\nActive: " .. self.Config.FileName)
        end,
    })

    section:AddButton({
        Title = "Save config",
        Desc = "Save the current values into the typed config name",
        Icon = "save",
        ButtonText = "Save",
        Callback = function()
            local name = currentTypedName()
            local success, message = self:SaveConfig(name)
            if success then
                if configNameInput then
                    configNameInput:Set(self.Config.FileName, true)
                end
                refreshConfigDropdown(self.Config.FileName)
            end
            showResult("Config saved", success, message)
        end,
    })

    section:AddButton({
        Title = "Load config",
        Desc = "Load the selected config from the dropdown",
        Icon = "download",
        ButtonText = "Load",
        Callback = function()
            local selected = configListDropdown and configListDropdown:Get() or currentTypedName()
            local success, message = self:LoadConfig(selected)
            if success then
                if configNameInput then
                    configNameInput:Set(self.Config.FileName, true)
                end
                refreshConfigDropdown(self.Config.FileName)
            end
            showResult("Config loaded", success, message)
        end,
    })

    section:AddButton({
        Title = "Refresh list",
        Desc = "Reload the dropdown from files inside your config folder",
        Icon = "refresh-cw",
        ButtonText = "Refresh",
        Callback = function()
            refreshConfigDropdown(self.Config.FileName)
            showResult("Config list refreshed", true, self.Config.Folder)
        end,
    })

    section:AddButton({
        Title = "Delete config",
        Desc = "Delete the selected config file from disk",
        Icon = "trash-2",
        ButtonText = "Delete",
        Callback = function()
            local selected = configListDropdown and configListDropdown:Get() or currentTypedName()
            local success, message = self:DeleteConfig(selected)
            if success then
                refreshConfigDropdown(currentTypedName())
            end
            showResult("Config deleted", success, message)
        end,
    })

    section:AddButton({
        Title = "Reset defaults",
        Desc = "Restore all saved controls to their default values",
        Icon = "rotate-ccw",
        ButtonText = "Reset",
        Callback = function()
            local success, message = self:ResetConfig(false)
            showResult("Defaults restored", success, message)
        end,
    })

    refreshConfigDropdown(self.Config.FileName)
    return section
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
        Font = "NotoSansThai",
        Config = {
            Enabled = false,
        },
    }, options)

    self:SetFont(options.Font or "NotoSansThai")

    local config = normalizeConfigOptions(options.Config)
    local loadedConfig = nil
    if config.Enabled and config.AutoLoad then
        loadedConfig = readConfigData(config)
    end

    local initialPosition = UDim2.fromScale(0.5, 0.5)
    local initialWindowData = loadedConfig and loadedConfig.Window
    if config.SaveWindowPosition and type(initialWindowData) == "table" and initialWindowData.Position then
        local savedPosition = deserializeValue(initialWindowData.Position)
        if typeof(savedPosition) == "UDim2" then
            initialPosition = savedPosition
        end
    end

    loadExternalIcons()

    -- Clear stale windows from gethui/CoreGui/PlayerGui before creating a new one.
    -- This prevents an older build from remaining visible after a loader error.
    destroyPreviousVoltzUI()

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

    -- The old offset black shadow created a visible square/edge outside
    -- the rounded window. Keep a transparent placeholder so existing
    -- window methods stay compatible without drawing that edge.
    local shadow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = initialPosition,
        Size = options.Size,
        Visible = false,
        Parent = root,
        ZIndex = 1,
    })

    local main = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = initialPosition,
        Size = options.Size,
        ClipsDescendants = true,
        Parent = root,
        ZIndex = 2,
    })
    corner(main, 10)

    local uiScale = create("UIScale", {
        Scale = 1,
        Parent = main,
    })
    local shadowScale = create("UIScale", {
        Scale = 1,
        Parent = shadow,
    })

    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        local viewport = camera.ViewportSize
        local desiredWidth = options.Size.X.Offset + 40
        local desiredHeight = options.Size.Y.Offset + 40
        local scale = math.min(1, viewport.X / desiredWidth, viewport.Y / desiredHeight)
        uiScale.Scale = scale
        shadowScale.Scale = scale
    end

    updateScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    local topbar = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 54),
        Parent = main,
        ZIndex = 5,
    })
    corner(topbar, 10)
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Surface2),
            ColorSequenceKeypoint.new(1, Theme.Surface),
        }),
        Rotation = 90,
        Parent = topbar,
    })

    -- UICorner does not clip child backgrounds in Roblox. The topbar needs
    -- its own rounded top corners, while this small fill keeps its bottom edge square.
    create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = topbar,
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
        Position = UDim2.fromOffset(14, 11),
        Size = UDim2.fromOffset(32, 32),
        Parent = topbar,
        ZIndex = 7,
    })
    corner(logoBox, 10)
    local logo = createIcon(logoBox, options.Icon, 17, Color3.fromRGB(255, 255, 255), 8)
    logo.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Frame.Position = UDim2.fromScale(0.5, 0.5)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(58, 7),
        Size = UDim2.new(1, -180, 0, 21),
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
        ZIndex = 7,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(58, 27),
        Size = UDim2.new(1, -180, 0, 17),
        FontFace = fontFace("Regular"),
        Text = options.Subtitle,
        TextColor3 = Theme.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
        ZIndex = 7,
    })

    local minimizeButton = createTextButton({
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -86, 0, 11),
        Size = UDim2.fromOffset(32, 32),
        Parent = topbar,
        ZIndex = 8,
    })
    corner(minimizeButton, 10)
    local minimizeIcon = createIcon(minimizeButton, "minus", 15, Theme.TextMuted, 9)
    minimizeIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    minimizeIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
    bindHover(minimizeButton, Theme.Surface2, Theme.Surface3)

    local closeButton = createTextButton({
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -46, 0, 11),
        Size = UDim2.fromOffset(32, 32),
        Parent = topbar,
        ZIndex = 8,
    })
    corner(closeButton, 10)
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
        Position = UDim2.fromOffset(0, 54),
        Size = UDim2.new(1, 0, 1, -54),
        Parent = main,
        ZIndex = 3,
    })

    local sidebar = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 176, 1, 0),
        Parent = body,
        ZIndex = 4,
    })
    corner(sidebar, 10)

    -- Keep only the outer bottom-left corner rounded. The top and right edges
    -- are internal joins, so these fills keep those joins perfectly square.
    create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = sidebar,
        ZIndex = 4,
    })

    create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        Parent = sidebar,
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
        FontFace = fontFace("Medium"),
        Text = "NAVIGATION",
        TextColor3 = Theme.TextDim,
        TextSize = 10,
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
        Position = UDim2.fromOffset(176, 0),
        Size = UDim2.new(1, -176, 1, 0),
        Parent = body,
        ZIndex = 3,
    })
    corner(content, 10)

    -- Keep only the outer bottom-right corner rounded. Top and left are
    -- internal joins with the topbar/sidebar.
    create("Frame", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = content,
        ZIndex = 3,
    })

    create("Frame", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        Parent = content,
        ZIndex = 3,
    })

    local activeTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(22, 16),
        Size = UDim2.new(1, -40, 0, 22),
        FontFace = fontFace("SemiBold"),
        Text = "Tab",
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content,
        ZIndex = 4,
    })

    local activeDescription = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(22, 39),
        Size = UDim2.new(1, -40, 0, 17),
        FontFace = fontFace("Regular"),
        Text = "",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        Parent = content,
        ZIndex = 4,
    })

    local pageContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(22, 66),
        Size = UDim2.new(1, -44, 1, -66),
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
        Shadow = shadow,
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
        Config = config,
        LoadedConfig = loadedConfig,
        PendingSelectedTab = loadedConfig and loadedConfig.Window and loadedConfig.Window.SelectedTab or nil,
        Controls = {},
        Flags = {},
        _LoadingConfig = false,
        _Initializing = true,
        _SaveToken = 0,
    }, WindowMethods)

    minimizeButton.MouseButton1Click:Connect(function()
        window:Minimize()
    end)

    closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)

    dragify(topbar, main, function(position)
        shadow.Position = UDim2.new(
            position.X.Scale,
            position.X.Offset,
            position.Y.Scale,
            position.Y.Offset + 8
        )
    end, function()
        window:_QueueAutoSave()
    end)

    window.InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window.ToggleKey then
            window:Toggle()
        end
    end)

    if config.SaveMinimized and loadedConfig and loadedConfig.Window and loadedConfig.Window.Minimized == true then
        window._LoadingConfig = true
        window:Minimize(true)
        window._LoadingConfig = false
    end

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
        corner(mobileButton, 14)
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

    task.defer(function()
        if window.ScreenGui and window.ScreenGui.Parent then
            window._Initializing = false
        end
    end)

    return window
end

-- Friendly aliases: both AddButton(...) and Button(...) styles are supported.
WindowMethods.CreateTab = WindowMethods.AddTab
WindowMethods.Notification = WindowMethods.Notify
WindowMethods.ConfigSection = WindowMethods.AddConfigSection
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
VoltzUI.SetFontFamily = VoltzUI.SetFont

return VoltzUI
