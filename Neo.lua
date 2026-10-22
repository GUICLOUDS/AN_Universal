local IMAGE_URLS = {
    IntroLogo = "https://raw.githubusercontent.com/Fe-ProjectR/GAME-IMAGES/refs/heads/main/Untitled230_20260713073832.png",
    PillLogo = "https://raw.githubusercontent.com/Fe-ProjectR/GAME-IMAGES/refs/heads/main/1000043901.png",
    NeoIcon = "https://raw.githubusercontent.com/GUICLOUDS/Neo-s/refs/heads/main/Icon.gif",
    DefaultIntroLogo = "https://raw.githubusercontent.com/Fe-ProjectR/GAME-IMAGES/refs/heads/main/Untitled230_20260713073832.png",
    DefaultPillLogo = "https://raw.githubusercontent.com/Fe-ProjectR/GAME-IMAGES/refs/heads/main/1000043901.png"
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local AN_ENV = (getgenv and getgenv()) or _G
if type(AN_ENV.AN_UNIVERSAL_CLEANUP) == "function" then
    pcall(AN_ENV.AN_UNIVERSAL_CLEANUP)
end
if AN_ENV.AN_UNIVERSAL_GUI then
    pcall(function()
        if AN_ENV.AN_UNIVERSAL_GUI.Parent then
            AN_ENV.AN_UNIVERSAL_GUI:Destroy()
        end
    end)
end
for _, existingGui in ipairs(PlayerGui:GetChildren()) do
    if existingGui:IsA("ScreenGui") and existingGui.Name == "ANMenutwin" then
        pcall(function() existingGui:Destroy() end)
    end
end
local AN_EXECUTION_TOKEN = tostring(os.time()) .. ":" .. tostring(math.random(100000, 999999))
AN_ENV.AN_UNIVERSAL_SESSION = AN_EXECUTION_TOKEN
AN_ENV.AN_UNIVERSAL_GUI = nil

local JobId = game.JobId
if JobId == "" then JobId = "TestServer" end
local BASE_URL = "https://anuni-21a0e-default-rtdb.firebaseio.com/"
local http_request = request or http_request or (syn and syn.request)

local CREATOR_ID = 1494561843
local CO_FOUNDER_ID = 11084026865
local ADMIN_IDS = {
    0,
    0
}

local function GetUserRank(userId)
    if userId == CREATOR_ID then return 4 end
    if userId == CO_FOUNDER_ID then return 3 end
    if table.find(ADMIN_IDS, userId) then return 2 end
    return 1
end

local function IsAdmin(userId)
    return GetUserRank(userId) >= 2
end

local LoopKillTargets = {}
local SpinTargets = {}
local IceCubePart = nil

local function createIceCube(character)
    if IceCubePart then IceCubePart:Destroy() IceCubePart = nil end
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cube = Instance.new("Part")
    cube.Name = "AN_IceCube"
    cube.Size = Vector3.new(5, 7, 5)
    cube.Material = Enum.Material.Ice
    cube.Color = Color3.fromRGB(130, 210, 255)
    cube.Transparency = 0.35
    cube.CanCollide = false
    cube.Anchored = false
    cube.CastShadow = false
    cube.Parent = workspace
    cube.CFrame = hrp.CFrame
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = cube
    weld.Parent = cube

    -- Ice particle effect while frozen
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(200, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 200, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255))
    })
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.25),
        NumberSequenceKeypoint.new(0.6, 0.12),
        NumberSequenceKeypoint.new(1,   0)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.2),
        NumberSequenceKeypoint.new(0.7, 0.5),
        NumberSequenceKeypoint.new(1,   1)
    })
    particles.LightEmission  = 0.6
    particles.LightInfluence = 0.3
    particles.Speed          = NumberRange.new(1.5, 4)
    particles.SpreadAngle    = Vector2.new(60, 60)
    particles.Rate           = 30
    particles.Lifetime       = NumberRange.new(0.8, 1.6)
    particles.RotSpeed       = NumberRange.new(-60, 60)
    particles.Rotation       = NumberRange.new(0, 360)
    particles.Parent         = cube

    IceCubePart = cube
end

local function removeIceCube()
    if not IceCubePart then return end
    local cube = IceCubePart
    IceCubePart = nil

    -- Stop emitting new particles
    for _, child in ipairs(cube:GetChildren()) do
        if child:IsA("ParticleEmitter") then
            child.Enabled = false
        end
    end

    -- Capture world position before weld yanks it
    local puddlePos = cube.CFrame.Position

    -- Melt animation: squish down and fade out
    TweenService:Create(cube, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size        = Vector3.new(5.5, 0.05, 5.5),
        Transparency = 0.92,
        Color       = Color3.fromRGB(90, 160, 210)
    }):Play()

    task.spawn(function()
        -- Puddle appears mid-melt
        task.wait(0.35)

        local puddle = Instance.new("Part")
        puddle.Name        = "AN_IcePuddle"
        puddle.Size        = Vector3.new(0.5, 0.05, 0.5)
        puddle.Material    = Enum.Material.SmoothPlastic
        puddle.Color       = Color3.fromRGB(100, 180, 230)
        puddle.Transparency = 0.35
        puddle.CanCollide  = false
        puddle.Anchored    = true
        puddle.CastShadow  = false
        puddle.Position    = Vector3.new(puddlePos.X, puddlePos.Y - 3, puddlePos.Z)
        puddle.Parent      = workspace

        -- Spread outward like water
        TweenService:Create(puddle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(6, 0.05, 6)
        }):Play()

        -- Shimmer ripple pulse
        task.wait(0.6)
        TweenService:Create(puddle, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = Vector3.new(6.8, 0.05, 6.8),
            Transparency = 0.45
        }):Play()
        task.wait(0.4)
        TweenService:Create(puddle, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
            Size = Vector3.new(6, 0.05, 6),
            Transparency = 0.35
        }):Play()

        -- Evaporate after 5 seconds
        task.wait(3.8)
        TweenService:Create(puddle, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 1,
            Size         = Vector3.new(3.5, 0.05, 3.5)
        }):Play()
        task.wait(1.2)
        if puddle and puddle.Parent then puddle:Destroy() end
    end)

    -- Destroy ice cube after melt finishes
    task.delay(0.9, function()
        if cube and cube.Parent then cube:Destroy() end
    end)
end

local function parseDuration(durationStr)
    if not durationStr or durationStr == "-1" then return -1 end
    
    local num = tonumber(durationStr:match("%d+"))
    local unit = durationStr:match("%a+"):lower()
    if not num then return -1 end
    
    if unit:find("min") then return num * 60
    elseif unit:find("hr") then return num * 3600
    elseif unit:find("yr") then return num * 31536000
    end
    return -1
end

local function formatRemainingTime(expiresTimestamp)
    if expiresTimestamp == -1 then return "Permanent" end
    local remaining = expiresTimestamp - os.time()
    if remaining <= 0 then return "Expired" end
    
    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    
    if days > 0 then return string.format("%d days, %d hours", days, hours)
    elseif hours > 0 then return string.format("%d hours, %d minutes", hours, minutes)
    else return string.format("%d minutes", minutes)
    end
end

local function checkIn()
    if not http_request then return end
    task.spawn(function()
        while AN_ENV.AN_UNIVERSAL_SESSION == AN_EXECUTION_TOKEN do
            local userUrl = BASE_URL .. "active_users/" .. JobId .. "/" .. tostring(LocalPlayer.UserId) .. ".json"
            local data = HttpService:JSONEncode({
                username = LocalPlayer.Name,
                timestamp = os.time()
            })
            
            http_request({
                Url = userUrl,
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = data
            })
            
            task.wait(30)
        end
    end)
end

local function checkOut()
    if not http_request then return end
    local userUrl = BASE_URL .. "active_users/" .. JobId .. "/" .. tostring(LocalPlayer.UserId) .. ".json"
    http_request({
        Url = userUrl,
        Method = "DELETE"
    })
end

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        checkOut()
    end
end)

pcall(function()
    if makefolder and isfolder and not isfolder("AN") then
        makefolder("AN")
    end
end)

local AUTO_EXECUTE_LOADSTRING = [[
loadstring(game:HttpGet('https://raw.githubusercontent.com/GUI-Offical/FileTest/refs/heads/main/ANHUBB.lua'))()
]]

local SOUND_URLS = {
    Intro = "https://github.com/Fe-ProjectR/GAME-IMAGES/raw/refs/heads/main/dragon-studio-dramatic-youtube-intro-478365.mp3",
    Hover = "https://github.com/Fe-ProjectR/GAME-IMAGES/raw/refs/heads/main/lesiakower-minimalist-button-hover-sound-effect-399749.mp3",
    Click = "https://github.com/Fe-ProjectR/GAME-IMAGES/raw/refs/heads/main/666herohero-click-21156.mp3"
}

local CLOUD_MOVIES_URL = "https://raw.githubusercontent.com/GUICLOUDS/CloudStorage/refs/heads/main/movies.json?nocache=" .. os.time()
local isUserBlacklisted = false
local banTimeText = ""

if http_request then
    local blacklistCheck = http_request({
        Url = BASE_URL .. "blacklist/" .. tostring(LocalPlayer.UserId) .. ".json",
        Method = "GET"
    })

    if blacklistCheck and blacklistCheck.StatusCode == 200 and blacklistCheck.Body ~= "null" then
        local banData = HttpService:JSONDecode(blacklistCheck.Body)
        if banData then
            if banData.expires == -1 or banData.expires > os.time() then
                isUserBlacklisted = true
                banTimeText = formatRemainingTime(banData.expires)
            else
                http_request({
                    Url = BASE_URL .. "blacklist/" .. tostring(LocalPlayer.UserId) .. ".json",
                    Method = "DELETE"
                })
            end
        end
    end
end

local MOVIES = {}
local TagCounts = {}
local UniqueTags = {}
local LastMoviesData = nil
local updateCarousel 

local function FetchMovies()
    pcall(function()
        local res = game:HttpGet(CLOUD_MOVIES_URL)
        if res ~= LastMoviesData then
            local isUpdate = LastMoviesData ~= nil
            LastMoviesData = res
            local decoded = HttpService:JSONDecode(res)
            if decoded and type(decoded) == "table" and #decoded > 0 then
                MOVIES = decoded
                TagCounts = {}
                UniqueTags = {}
                for _, movie in ipairs(MOVIES) do
                    local parsedTags = {}
                    if movie.Tags then
                        if type(movie.Tags) == "string" then
                            for t in string.gmatch(movie.Tags, "([^,]+)") do
                                local trimmed = t:match("^%s*(.-)%s*$")
                                if trimmed ~= "" then table.insert(parsedTags, trimmed) end
                            end
                        elseif type(movie.Tags) == "table" then
                            for _, t in ipairs(movie.Tags) do
                                local trimmed = tostring(t):match("^%s*(.-)%s*$")
                                if trimmed ~= "" then table.insert(parsedTags, trimmed) end
                            end
                        end
                    end
                    
                    movie.ParsedTags = parsedTags
                    
                    for _, t in ipairs(parsedTags) do
                        if not TagCounts[t] then
                            TagCounts[t] = 0
                            table.insert(UniqueTags, t)
                        end
                        TagCounts[t] = TagCounts[t] + 1
                    end
                end
                table.sort(UniqueTags)
                
                if isUpdate and updateCarousel then
                    updateCarousel()
                end
                return isUpdate
            end
        end
    end)
    return false
end
FetchMovies()

local FAVORITES_FILE = "AN/NFX_MyList.json"
local Favorites = {}

pcall(function()
    if isfile and readfile and isfile(FAVORITES_FILE) then
        local decoded = HttpService:JSONDecode(readfile(FAVORITES_FILE))
        if type(decoded) == "table" then
            for _, entry in ipairs(decoded) do
                if type(entry) == "string" then
                    table.insert(Favorites, {Kind = "movie", Title = entry})
                elseif type(entry) == "table" and entry.Title then
                    entry.Kind = entry.Kind or "movie"
                    table.insert(Favorites, entry)
                end
            end
        end
    end
end)

local function saveFavorites()
    pcall(function()
        if writefile then writefile(FAVORITES_FILE, HttpService:JSONEncode(Favorites)) end
    end)
end

function findFavoriteIndex(title, kind)
    title = tostring(title or "")
    kind = kind or "movie"
    for i, entry in ipairs(Favorites) do
        if type(entry) == "table" and tostring(entry.Title or "") == title and (entry.Kind or "movie") == kind then
            return i
        end
    end
    return nil
end

local function isFavorite(movieTitle)
    return findFavoriteIndex(movieTitle, "movie") ~= nil
end

local function toggleFavorite(movieTitle)
    local index = findFavoriteIndex(movieTitle, "movie")
    if index then
        table.remove(Favorites, index)
    else
        table.insert(Favorites, {Kind = "movie", Title = movieTitle})
    end
    saveFavorites()
end

function isPiratedFavorite(title)
    return findFavoriteIndex(title, "pirated") ~= nil
end

function togglePiratedFavorite(scriptData, comments)
    if not scriptData then return end
    local title = tostring(scriptData.title or "Untitled Script")
    local index = findFavoriteIndex(title, "pirated")
    if index then
        table.remove(Favorites, index)
    else
        local tagsCopy = {}
        if type(scriptData.tags) == "table" then
            for _, tag in ipairs(scriptData.tags) do table.insert(tagsCopy, tostring(tag)) end
        end
        local commentCopy = {}
        if type(comments) == "table" then
            for _, comment in ipairs(comments) do table.insert(commentCopy, comment) end
        end
        table.insert(Favorites, {
            Kind = "pirated",
            Title = title,
            Script = type(scriptData.script) == "string" and scriptData.script or "",
            Image = scriptData.image or (scriptData.game and scriptData.game.imageUrl) or "",
            Game = scriptData.game,
            Description = scriptData.features or scriptData.description or "No description provided.",
            Likes = tonumber(scriptData.likeCount) or 0,
            Dislikes = tonumber(scriptData.dislikeCount) or 0,
            Views = tonumber(scriptData.views) or 0,
            Owner = scriptData.owner and scriptData.owner.username or "Unknown",
            UpdatedAt = scriptData.updatedAt,
            CreatedAt = scriptData.createdAt,
            Tags = tagsCopy,
            Verified = scriptData.verified == true,
            Key = scriptData.key == true,
            Universal = scriptData.isUniversal == true,
            Patched = scriptData.isPatched == true,
            ScriptType = scriptData.scriptType,
            Visibility = scriptData.visibility,
            Slug = scriptData.slug,
            Id = scriptData._id,
            Comments = commentCopy
        })
    end
    saveFavorites()
end

function getSavedPiratedEntries()
    local entries = {}
    for _, entry in ipairs(Favorites) do
        if type(entry) == "table" and (entry.Kind == "pirated") then
            table.insert(entries, entry)
        end
    end
    return entries
end

saveFavorites()

local CONFIG_FILE = "AN/NFX_Settings.json"
local Settings = { ShowTags = true }

pcall(function()
    if isfile and readfile and isfile(CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if decoded then for k, v in pairs(decoded) do Settings[k] = v end end
    end
end)

local function saveSettings()
    pcall(function()
        if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(Settings)) end
    end)
end

local WINDOW_CONFIG_FILE = "AN/NFX_WindowConfig.json"
local WindowConfig = { Width = 720, Height = 460 }

pcall(function()
    if isfile and readfile and isfile(WINDOW_CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(WINDOW_CONFIG_FILE))
        if decoded then
            WindowConfig.Width = decoded.Width or WindowConfig.Width
            WindowConfig.Height = decoded.Height or WindowConfig.Height
        end
    end
end)

local THEME_FILE = "AN/NFX_ThemeColor.txt"
local CurrentThemeHex = "E50914"

pcall(function()
    if isfile and readfile and isfile(THEME_FILE) then
        CurrentThemeHex = readfile(THEME_FILE)
    end
end)

local CurrentThemeColor = Color3.fromHex(CurrentThemeHex)
local updateDynamicThemeColors
local applyNewTheme
local PiratedImageFiles = {}
local PiratedImageGeneration = 0

local function getImageExtensionFromContentType(contentType)
    contentType = tostring(contentType or ""):lower():match("^[^;]+") or ""
    local map = {
        ["image/png"] = "png",
        ["image/jpeg"] = "jpg",
        ["image/jpg"] = "jpg",
        ["image/webp"] = "webp",
        ["image/gif"] = "gif",
        ["image/bmp"] = "bmp",
        ["image/x-bmp"] = "bmp"
    }
    return map[contentType]
end

local function getImageExtensionFromUrl(url)
    local cleanUrl = tostring(url or ""):match("^[^?#]+") or tostring(url or "")
    local ext = cleanUrl:match("%.([%a%d]+)$")
    if ext then
        ext = ext:lower()
        if ext == "jpeg" then ext = "jpg" end
        if ext == "png" or ext == "jpg" or ext == "webp" or ext == "gif" or ext == "bmp" then
            return ext
        end
    end
    return nil
end

local function getImageExtensionFromBytes(data)
    if type(data) ~= "string" or data == "" then return nil end
    if data:sub(1, 8) == "\137PNG\r\n\26\n" then return "png" end
    if data:sub(1, 3) == "\255\216\255" then return "jpg" end
    if data:sub(1, 4) == "RIFF" and data:sub(9, 12) == "WEBP" then return "webp" end
    if data:sub(1, 4) == "GIF8" then return "gif" end
    if data:sub(1, 2) == "BM" then return "bmp" end
    return nil
end

local function getImageCacheData(url)
    if http_request then
        local ok, response = pcall(function()
            return http_request({Url = url, Method = "GET"})
        end)
        if ok and response and response.Body then
            local statusCode = tonumber(response.StatusCode or response.status_code or response.Status)
            if not statusCode or (statusCode >= 200 and statusCode < 300) then
                local headers = response.Headers or response.headers or {}
                local contentType = headers["Content-Type"] or headers["content-type"] or headers["CONTENT-TYPE"]
                local body = response.Body
                return body, getImageExtensionFromContentType(contentType) or getImageExtensionFromBytes(body)
            end
        end
    end

    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and data then
        return data, getImageExtensionFromBytes(data)
    end
    return nil, nil
end

local function safeImageCacheName(url)
    local safeUrl = tostring(url or ""):gsub("[^%w]", "")
    if #safeUrl > 64 then safeUrl = safeUrl:sub(-64) end
    if safeUrl == "" then safeUrl = "image" end
    return safeUrl
end

local function clearPiratedImageCache()
    PiratedImageGeneration = PiratedImageGeneration + 1
    for filePath in pairs(PiratedImageFiles) do
        pcall(function()
            if delfile and isfile and isfile(filePath) then delfile(filePath) end
        end)
    end
    PiratedImageFiles = {}

    pcall(function()
        if listfiles and delfile and isfile then
            for _, filePath in ipairs(listfiles("AN")) do
                local normalized = tostring(filePath):gsub("\\", "/")
                if normalized:match("^AN/NFX_PIRATED_IMG_") then
                    if isfile(filePath) then delfile(filePath) end
                end
            end
        end
    end)
end

clearPiratedImageCache()

local function LoadImageAsync(imageLabel, url, skipFade, temporaryPirated)
    if not url or url == "" then return end
    if not skipFade then imageLabel.ImageTransparency = 1 end
    if not (url:find("^http://") or url:find("^https://")) then
        imageLabel.Image = url
        if not skipFade then TweenService:Create(imageLabel, TweenInfo.new(0.35), {ImageTransparency = 0}):Play() end
        return
    end

    local imageGeneration = PiratedImageGeneration
    task.spawn(function()
        local getAsset = getcustomasset or getsynasset
        if not (writefile and isfile and getAsset) then return end

        local hintedExtension = getImageExtensionFromUrl(url)
        local safeName = safeImageCacheName(url)
        local prefix = temporaryPirated and "AN/NFX_PIRATED_IMG_" or "AN/NFX_IMG_"
        local filePath = nil
        local data = nil
        local detectedExtension = nil

        if temporaryPirated and imageGeneration ~= PiratedImageGeneration then return end

        if hintedExtension then
            filePath = prefix .. safeName .. "." .. hintedExtension
        end

        if not filePath or not isfile(filePath) then
            data, detectedExtension = getImageCacheData(url)
            if not data then return end
            local extension = detectedExtension or hintedExtension or "png"
            filePath = prefix .. safeName .. "." .. extension
            if temporaryPirated and imageGeneration ~= PiratedImageGeneration then return end
            local wrote = pcall(function() writefile(filePath, data) end)
            if not wrote then return end
        end

        if temporaryPirated then
            if imageGeneration ~= PiratedImageGeneration then
                pcall(function()
                    if delfile and isfile and isfile(filePath) then delfile(filePath) end
                end)
                return
            end
            PiratedImageFiles[filePath] = true
        end

        if isfile(filePath) and imageLabel and imageLabel.Parent then
            local ok, asset = pcall(function() return getAsset(filePath) end)
            if ok and asset then
                imageLabel.Image = asset
                if not skipFade then TweenService:Create(imageLabel, TweenInfo.new(0.4), {ImageTransparency = 0}):Play() end
            end
        end
    end)
end

local SOUNDS_CACHE = {}
local function PlaySoundAsync(url, name, vol)
    if not url or url == "" then return end
    task.spawn(function()
        local getAsset = getcustomasset or getsynasset
        if not (writefile and isfile and getAsset) then return end
        local safeName = name:gsub("[^%w]", "")
        local filePath = "AN/NFX_SND_" .. safeName .. ".mp3"
        
        if not SOUNDS_CACHE[name] then
            if not isfile(filePath) then
                local success, data = pcall(function() return game:HttpGet(url) end)
                if success and data then writefile(filePath, data) else return end
            end
            if isfile(filePath) then SOUNDS_CACHE[name] = getAsset(filePath) end
        end
        
        if SOUNDS_CACHE[name] then
            local sfx = Instance.new("Sound")
            sfx.SoundId = SOUNDS_CACHE[name]
            sfx.Volume = vol or 1
            sfx.Parent = workspace
            sfx:Play()
            sfx.Ended:Connect(function() sfx:Destroy() end)
        end
    end)
end

local function BindInteractionSounds(guiElement)
    if not guiElement:IsA("GuiButton") then return end
    guiElement.MouseEnter:Connect(function() PlaySoundAsync(SOUND_URLS.Hover, "Hover", 0.3) end)
    guiElement.MouseButton1Click:Connect(function() PlaySoundAsync(SOUND_URLS.Click, "Click", 0.6) end)
end

task.spawn(function()
    PlaySoundAsync(SOUND_URLS.Intro, "Intro", 0)
    PlaySoundAsync(SOUND_URLS.Hover, "Hover", 0)
    PlaySoundAsync(SOUND_URLS.Click, "Click", 0)
end)

local COLORS = {
    DarkBack = Color3.fromRGB(12, 12, 12),
    DarkMid = Color3.fromRGB(18, 18, 18),
    DarkCard = Color3.fromRGB(26, 26, 26),
    Border = Color3.fromRGB(38, 38, 38),
    BrandRed = CurrentThemeColor,
    White = Color3.fromRGB(255, 255, 255),
    GreyMuted = Color3.fromRGB(130, 130, 130),
    GreyLight = Color3.fromRGB(180, 180, 180)
}

local FONTS = {
    Heavy = Enum.Font.GothamBlack,
    Bold = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium,
    Book = Enum.Font.Gotham
}

-- "In My List" label. Plain Unicode check mark (U+2713), NOT the emoji form
-- (U+2714 + U+FE0F), so it renders in the button's text colour instead of as a
-- coloured emoji. Global function on purpose: the main chunk is close to Lua's
-- 200-local limit, so this must not add a top-level local.
function myListLabel(inList)
    return inList and "\u{2713} My List" or "+ My List"
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function queueAutoExecute()
    local q = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if q then q(AUTO_EXECUTE_LOADSTRING) end
end

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local function getTargetSize()
    local viewport = Camera.ViewportSize
    local width = WindowConfig.Width
    local height = WindowConfig.Height
    
    -- Mobile & smaller screen optimization
    if isMobile() then
        -- For mobile: use 40-85% of screen width for better button spacing
        local scale = math.clamp(viewport.X / 1200, 0.4, 0.85)
        return UDim2.new(0, width * scale, 0, height * scale)
    elseif viewport.X < 750 then
        -- For small desktop screens
        local scale = math.clamp(viewport.X / 750, 0.5, 0.85)
        return UDim2.new(0, width * scale, 0, height * scale)
    end
    return UDim2.new(0, width, 0, height)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ANMenutwin"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui
AN_ENV.AN_UNIVERSAL_GUI = ScreenGui
AN_ENV.AN_UNIVERSAL_CLEANUP = function()
    pcall(function()
        if AN_ENV.AN_UNIVERSAL_GUI == ScreenGui then
            AN_ENV.AN_UNIVERSAL_GUI = nil
        end
    end)
    pcall(function() clearPiratedImageCache() end)
    pcall(function() checkOut() end)
    pcall(function()
        if ScreenGui.Parent then ScreenGui:Destroy() end
    end)
end

local function ShowNetflixNotification(title, desc)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 320, 0, 70)
    NotifFrame.Position = UDim2.new(1, 10, 1, -90)
    NotifFrame.AnchorPoint = Vector2.new(1, 1)
    NotifFrame.BackgroundColor3 = COLORS.DarkBack
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ZIndex = 200
    NotifFrame.Parent = ScreenGui
    createCorner(NotifFrame, 6)
    createStroke(NotifFrame, COLORS.BrandRed, 2)

    local NIcon = Instance.new("TextLabel")
    NIcon.Size = UDim2.new(0, 40, 0, 40)
    NIcon.Position = UDim2.new(0, 15, 0.5, -20)
    NIcon.BackgroundTransparency = 1
    NIcon.Text = "N"
    NIcon.TextColor3 = COLORS.BrandRed
    NIcon.Font = FONTS.Heavy
    NIcon.TextSize = 28
    NIcon.ZIndex = 201
    NIcon.Parent = NotifFrame

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -70, 0, 20)
    TitleLbl.Position = UDim2.new(0, 60, 0, 15)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = COLORS.White
    TitleLbl.Font = FONTS.Bold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 201
    TitleLbl.Parent = NotifFrame

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Size = UDim2.new(1, -70, 0, 20)
    DescLbl.Position = UDim2.new(0, 60, 0, 35)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = desc
    DescLbl.TextColor3 = COLORS.GreyLight
    DescLbl.Font = FONTS.Book
    DescLbl.TextSize = 12
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.ZIndex = 201
    DescLbl.Parent = NotifFrame

    PlaySoundAsync(SOUND_URLS.Intro, "Intro", 0.5)

    TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -20, 1, -90)
    }):Play()

    task.delay(4, function()
        local outTween = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, 1, -90)
        })
        outTween:Play()
        outTween.Completed:Wait()
        if NotifFrame then NotifFrame:Destroy() end
    end)
end

task.spawn(function()
    while task.wait(60) do 
        if FetchMovies() then
            ShowNetflixNotification("Script Update Detected", "The movies list has been updated on GitHub.")
        end
    end
end)

local startSize = getTargetSize()
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = startSize
MainFrame.Position = UDim2.new(0.5, -startSize.X.Offset / 2, 0.5, -startSize.Y.Offset / 2)
MainFrame.BackgroundColor3 = COLORS.DarkBack
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 10)
createStroke(MainFrame, COLORS.Border, 1, 0.3)

AN_ENV.AN_NEO_THEME_STATE = {
    Enabled = false,
    OriginalText = setmetatable({}, {__mode = "k"}),
    LastText = setmetatable({}, {__mode = "k"}),
    TextHooks = setmetatable({}, {__mode = "k"}),
    GifCache = {},
    GifTargets = {
        icon = setmetatable({}, {__mode = "k"})
    },
    PlaybackTokens = setmetatable({}, {__mode = "k"})
}

-- GIF playback support: Roblox ImageLabels do not animate raw GIF files by themselves.
-- This small decoder converts downloaded GIF frames into local PNGs and cycles them.
function AN_NeoCRC32(data)
    local table32 = AN_ENV.AN_NEO_CRC32_TABLE
    if not table32 then
        table32 = {}
        for n = 0, 255 do
            local c = n
            for _ = 1, 8 do
                if bit32.band(c, 1) ~= 0 then
                    c = bit32.bxor(bit32.rshift(c, 1), 0xEDB88320)
                else
                    c = bit32.rshift(c, 1)
                end
            end
            table32[n] = c
        end
        AN_ENV.AN_NEO_CRC32_TABLE = table32
    end
    local crc = 0xFFFFFFFF
    for i = 1, #data do
        local b = string.byte(data, i)
        crc = bit32.bxor(bit32.rshift(crc, 8), table32[bit32.band(bit32.bxor(crc, b), 255)])
    end
    return bit32.bxor(crc, 0xFFFFFFFF)
end

function AN_NeoU32BE(n)
    n = n % 4294967296
    return string.char(
        math.floor(n / 16777216) % 256,
        math.floor(n / 65536) % 256,
        math.floor(n / 256) % 256,
        n % 256
    )
end

function AN_NeoPNGChunk(kind, payload)
    local body = kind .. payload
    return AN_NeoU32BE(#payload) .. body .. AN_NeoU32BE(AN_NeoCRC32(body))
end

function AN_NeoEncodePNG(rows, width, height, maxWidth, maxHeight)
    local outWidth = math.max(1, math.min(width, maxWidth or width))
    local outHeight = math.max(1, math.min(height, maxHeight or height))
    local rawRows = {}
    for outY = 1, outHeight do
        local sourceY = math.floor((outY - 1) * height / outHeight) + 1
        local sourceRow = rows[sourceY]
        if outWidth == width then
            rawRows[#rawRows + 1] = "\0" .. sourceRow
        else
            local pixels = {}
            for outX = 1, outWidth do
                local sourceX = math.floor((outX - 1) * width / outWidth)
                pixels[outX] = sourceRow:sub(sourceX * 4 + 1, sourceX * 4 + 4)
            end
            rawRows[#rawRows + 1] = "\0" .. table.concat(pixels)
        end
    end
    local raw = table.concat(rawRows)
    local deflate = {string.char(0x78, 0x01)}
    local rawPos = 1
    while rawPos <= #raw do
        local blockSize = math.min(65535, #raw - rawPos + 1)
        local finalBlock = (rawPos + blockSize - 1 >= #raw) and 1 or 0
        local inverse = 65535 - blockSize
        deflate[#deflate + 1] = string.char(
            finalBlock,
            blockSize % 256,
            math.floor(blockSize / 256),
            inverse % 256,
            math.floor(inverse / 256)
        ) .. raw:sub(rawPos, rawPos + blockSize - 1)
        rawPos = rawPos + blockSize
    end
    local a, b = 1, 0
    for i = 1, #raw do
        a = (a + string.byte(raw, i)) % 65521
        b = (b + a) % 65521
    end
    deflate[#deflate + 1] = AN_NeoU32BE(b * 65536 + a)
    local zlibData = table.concat(deflate)
    local ihdr = AN_NeoU32BE(outWidth) .. AN_NeoU32BE(outHeight) .. string.char(8, 6, 0, 0, 0)
    return "\137PNG\r\n\26\n"
        .. AN_NeoPNGChunk("IHDR", ihdr)
        .. AN_NeoPNGChunk("IDAT", zlibData)
        .. AN_NeoPNGChunk("IEND", "")
end

function AN_NeoDecodeGIF(data, key)
    if type(data) ~= "string" or (#data < 14) or data:sub(1, 3) ~= "GIF" then
        error("The downloaded file is not a valid GIF")
    end
    local getAsset = getcustomasset or getsynasset
    if not (writefile and isfile and getAsset) then
        error("This executor needs writefile, isfile, and getcustomasset/getsynasset for animated images")
    end
    local function byteAt(pos)
        return string.byte(data, pos) or 0
    end
    local function u16(pos)
        return byteAt(pos) + byteAt(pos + 1) * 256
    end
    local function paletteAt(pos, count)
        local palette = {}
        for i = 0, count - 1 do
            local at = pos + i * 3
            palette[i + 1] = string.char(byteAt(at), byteAt(at + 1), byteAt(at + 2))
        end
        return palette, pos + count * 3
    end
    local function getSubBlocks(pos)
        local chunks = {}
        while pos <= #data do
            local size = byteAt(pos)
            pos = pos + 1
            if size == 0 then break end
            chunks[#chunks + 1] = data:sub(pos, pos + size - 1)
            pos = pos + size
        end
        return table.concat(chunks), pos
    end
    local function decodeLZW(stream, minimumCodeSize, expectedPixels)
        minimumCodeSize = math.max(2, math.min(8, minimumCodeSize))
        local clearCode = 2 ^ minimumCodeSize
        local endCode = clearCode + 1
        local dictionary, nextCode, codeSize
        local bytePos, bitBuffer, bitCount = 1, 0, 0
        local function resetDictionary()
            dictionary = {}
            for i = 0, clearCode - 1 do dictionary[i] = string.char(i) end
            nextCode = endCode + 1
            codeSize = minimumCodeSize + 1
        end
        local function readCode(size)
            while bitCount < size do
                local value = string.byte(stream, bytePos)
                if not value then return nil end
                bitBuffer = bitBuffer + value * (2 ^ bitCount)
                bitCount = bitCount + 8
                bytePos = bytePos + 1
            end
            local code = bitBuffer % (2 ^ size)
            bitBuffer = math.floor(bitBuffer / (2 ^ size))
            bitCount = bitCount - size
            return code
        end
        resetDictionary()
        local previous, chunks, total = nil, {}, 0
        while true do
            local code = readCode(codeSize)
            if code == nil or code == endCode then break end
            if code == clearCode then
                resetDictionary()
                previous = nil
            else
                local entry = dictionary[code]
                if not entry and code == nextCode and previous then
                    entry = previous .. previous:sub(1, 1)
                end
                if not entry then break end
                chunks[#chunks + 1] = entry
                total = total + #entry
                if previous and nextCode < 4096 then
                    dictionary[nextCode] = previous .. entry:sub(1, 1)
                    nextCode = nextCode + 1
                    if nextCode == (2 ^ codeSize) and codeSize < 12 then
                        codeSize = codeSize + 1
                    end
                end
                previous = entry
                if total >= expectedPixels then break end
            end
        end
        local decoded = table.concat(chunks)
        if #decoded < expectedPixels then error("GIF frame decoding returned too few pixels") end
        return decoded:sub(1, expectedPixels)
    end
    local screenWidth, screenHeight = u16(7), u16(9)
    if screenWidth < 1 or screenHeight < 1 or screenWidth * screenHeight > 4000000 then
        error("GIF dimensions are invalid or too large")
    end
    local logicalPacked = byteAt(11)
    local hasGlobalPalette = bit32.band(logicalPacked, 128) ~= 0
    local globalPaletteCount = 2 ^ ((logicalPacked % 8) + 1)
    local position = 14
    local globalPalette
    if hasGlobalPalette then
        globalPalette, position = paletteAt(position, globalPaletteCount)
    end
    local canvasRows = {}
    for y = 1, screenHeight do canvasRows[y] = string.rep("\0", screenWidth * 4) end
    local gceDelay, gceDisposal, gceTransparent = 0.08, 0, nil
    local previousDisposal, previousRect, previousRestore = 0, nil, nil
    local frames = {}
    local frameNo = 0
    local baseName = "AN/NFX_NEO_GIF_" .. tostring(key):gsub("[^%w]", "_")
    local function copyRows(source)
        local result = {}
        for i = 1, #source do result[i] = source[i] end
        return result
    end
    local function clearRectangle(rect)
        if not rect then return end
        local x1, y1, rw, rh = rect[1], rect[2], rect[3], rect[4]
        local x2 = math.min(screenWidth, x1 + rw)
        local y2 = math.min(screenHeight, y1 + rh)
        local transparent = string.rep("\0", math.max(0, x2 - x1) * 4)
        for y = math.max(0, y1), y2 - 1 do
            local oldRow = canvasRows[y + 1]
            canvasRows[y + 1] = oldRow:sub(1, x1 * 4) .. transparent .. oldRow:sub(x2 * 4 + 1)
        end
    end
    while position <= #data and frameNo < 80 do
        local marker = byteAt(position)
        position = position + 1
        if marker == 0x3B then
            break
        elseif marker == 0x21 then
            local label = byteAt(position)
            position = position + 1
            if label == 0xF9 then
                local blockSize = byteAt(position)
                position = position + 1
                if blockSize >= 4 then
                    local packed = byteAt(position)
                    local delayCs = u16(position + 1)
                    local transparentIndex = byteAt(position + 3)
                    gceDisposal = math.floor(packed / 4) % 8
                    gceDelay = math.clamp(delayCs / 100, 0.04, 1.5)
                    gceTransparent = (bit32.band(packed, 1) ~= 0) and transparentIndex or nil
                end
                position = position + blockSize
                if byteAt(position) == 0 then position = position + 1 end
            else
                local _, nextPosition = getSubBlocks(position)
                position = nextPosition
            end
        elseif marker == 0x2C then
            local left, top = u16(position), u16(position + 2)
            local frameWidth, frameHeight = u16(position + 4), u16(position + 6)
            local packed = byteAt(position + 8)
            position = position + 9
            if frameWidth < 1 or frameHeight < 1 or frameWidth * frameHeight > 4000000 then
                error("GIF frame dimensions are invalid or too large")
            end
            local imagePalette = globalPalette
            if bit32.band(packed, 128) ~= 0 then
                local count = 2 ^ ((packed % 8) + 1)
                imagePalette, position = paletteAt(position, count)
            end
            local minimumCodeSize = byteAt(position)
            position = position + 1
            local compressed, nextPosition = getSubBlocks(position)
            position = nextPosition
            local indices = decodeLZW(compressed, minimumCodeSize, frameWidth * frameHeight)

            if previousDisposal == 2 then
                clearRectangle(previousRect)
            elseif previousDisposal == 3 and previousRestore then
                canvasRows = previousRestore
            end
            local restoreBeforeFrame = (gceDisposal == 3) and copyRows(canvasRows) or nil
            local rowOrder = {}
            if bit32.band(packed, 64) ~= 0 then
                local passes = {{0, 8}, {4, 8}, {2, 4}, {1, 2}}
                for _, pass in ipairs(passes) do
                    local row = pass[1]
                    while row < frameHeight do
                        rowOrder[#rowOrder + 1] = row
                        row = row + pass[2]
                    end
                end
            else
                for row = 0, frameHeight - 1 do rowOrder[#rowOrder + 1] = row end
            end
            for sourceRow = 0, frameHeight - 1 do
                local destY = top + rowOrder[sourceRow + 1]
                if destY >= 0 and destY < screenHeight then
                    local oldRow = canvasRows[destY + 1]
                    local pixels = {}
                    for sourceX = 0, frameWidth - 1 do
                        local destX = left + sourceX
                        local sourceIndex = sourceRow * frameWidth + sourceX + 1
                        local colorIndex = string.byte(indices, sourceIndex) or 0
                        if destX >= 0 and destX < screenWidth then
                            if gceTransparent ~= nil and colorIndex == gceTransparent then
                                pixels[#pixels + 1] = oldRow:sub(destX * 4 + 1, destX * 4 + 4)
                            else
                                local rgb = imagePalette and imagePalette[colorIndex + 1]
                                pixels[#pixels + 1] = (rgb or "\0\0\0") .. "\255"
                            end
                        end
                    end
                    local clippedPixels = table.concat(pixels)
                    local x1 = math.max(0, left)
                    local x2 = math.min(screenWidth, left + frameWidth)
                    if x2 > x1 then
                        -- pixels already omitted outside the screen, so they align with x1.
                        canvasRows[destY + 1] = oldRow:sub(1, x1 * 4) .. clippedPixels .. oldRow:sub(x2 * 4 + 1)
                    end
                end
            end
            frameNo = frameNo + 1
            local maxW, maxH = 800, 450
            if key == "icon" then maxW, maxH = 160, 160 end
            local png = AN_NeoEncodePNG(canvasRows, screenWidth, screenHeight, maxW, maxH)
            local filePath = baseName .. string.format("_%03d.png", frameNo)
            writefile(filePath, png)
            local assetOk, asset = pcall(function() return getAsset(filePath) end)
            if not assetOk or not asset then error("Could not load the converted GIF frame") end
            frames[#frames + 1] = {Asset = asset, Delay = gceDelay}
            previousDisposal = gceDisposal
            previousRect = {left, top, frameWidth, frameHeight}
            previousRestore = restoreBeforeFrame
            gceDelay, gceDisposal, gceTransparent = 0.08, 0, nil
        else
            break
        end
    end
    if #frames == 0 then error("No readable frames were found in the GIF") end
    return frames
end

function AN_NeoPlayGif(target, key)
    local state = AN_ENV.AN_NEO_THEME_STATE
    local cache = state and state.GifCache and state.GifCache[key]
    if not (state and state.Enabled and target and target.Parent and cache and cache.Ready and #cache.Frames > 0) then return end
    state.PlaybackTokens[target] = (state.PlaybackTokens[target] or 0) + 1
    local token = state.PlaybackTokens[target]
    task.spawn(function()
        local index = 1
        while target.Parent and state.Enabled and state.PlaybackTokens[target] == token do
            local frame = cache.Frames[index]
            if frame then
                pcall(function()
                    target.Image = frame.Asset
                    target.ImageTransparency = 0
                end)
                task.wait(frame.Delay or 0.08)
            else
                task.wait(0.08)
            end
            index = (index % #cache.Frames) + 1
        end
    end)
end

function AN_NeoLoadGif(key, url)
    local state = AN_ENV.AN_NEO_THEME_STATE
    if not state then return end
    state.GifCache = state.GifCache or {}
    local existing = state.GifCache[key]
    if existing and existing.Ready then
        for target in pairs(state.GifTargets[key]) do AN_NeoPlayGif(target, key) end
        return
    end
    if existing and existing.Loading then return end
    state.GifCache[key] = {Loading = true}
    task.spawn(function()
        local dataOk, data = pcall(function()
            local bytes = getImageCacheData(url)
            return bytes
        end)
        local decodeOk, frames
        if dataOk and data then
            decodeOk, frames = pcall(AN_NeoDecodeGIF, data, key)
        end
        local cache = state.GifCache[key]
        if not cache then return end
        cache.Loading = false
        if decodeOk and frames and #frames > 0 then
            cache.Frames = frames
            cache.Ready = true
            for target in pairs(state.GifTargets[key]) do AN_NeoPlayGif(target, key) end
        else
            cache.Failed = true
            warn("[Neo theme] Could not animate " .. tostring(key) .. " GIF. Showing a still image if the executor permits it.")
            for target in pairs(state.GifTargets[key]) do
                pcall(function() LoadImageAsync(target, url, true) end)
            end
        end
    end)
end

function AN_NeoAttachGif(target, key)
    local state = AN_ENV.AN_NEO_THEME_STATE
    if not (state and target and target.Parent) then return end
    state.GifTargets[key][target] = true
    target.ImageTransparency = 0
    local urls = {icon = IMAGE_URLS.NeoIcon}
    local cache = state.GifCache[key]
    if cache and cache.Ready then
        AN_NeoPlayGif(target, key)
    elseif not (cache and cache.Failed) then
        AN_NeoLoadGif(key, urls[key])
    else
        pcall(function() LoadImageAsync(target, urls[key], true) end)
    end
end

function AN_NeoStopGifPlayback()
    local state = AN_ENV.AN_NEO_THEME_STATE
    if not state then return end
    for target, token in pairs(state.PlaybackTokens) do
        state.PlaybackTokens[target] = token + 1
    end
end

local function makeDraggable(dragHandle, target)
    local dragging = false
    local dragInput, startPos, startInputPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = target.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startInputPos
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

do
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Name = "IntroFrame"
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    IntroFrame.BorderSizePixel = 0
    IntroFrame.ZIndex = 50
    IntroFrame.Parent = MainFrame
    createCorner(IntroFrame, 10)

    local LoadingN = Instance.new("ImageLabel")
    LoadingN.Name = "LoadingAN"
    LoadingN.Size = UDim2.new(0, 100, 0, 100)
    LoadingN.Position = UDim2.new(0.5, -50, 0.45, -50)
    LoadingN.BackgroundTransparency = 1
    LoadingN.ImageTransparency = 1
    LoadingN.ZIndex = 51
    LoadingN.Parent = IntroFrame
    LoadImageAsync(LoadingN, IMAGE_URLS.IntroLogo, true)

    local LoadBar = Instance.new("Frame")
    LoadBar.Name = "LoadBar"
    LoadBar.Size = UDim2.new(0, 0, 0, 3)
    LoadBar.Position = UDim2.new(0.5, -60, 0.72, 0)
    LoadBar.BackgroundColor3 = COLORS.BrandRed
    LoadBar.BorderSizePixel = 0
    LoadBar.ZIndex = 51
    LoadBar.Parent = IntroFrame
    createCorner(LoadBar, 1.5)

    PlaySoundAsync(SOUND_URLS.Intro, "Intro", 1.2)
    LoadingN.Size = UDim2.new(0, 60, 0, 60)
    LoadingN.Position = UDim2.new(0.5, -30, 0.45, -30)
    TweenService:Create(LoadingN, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 100, 0, 100),
        Position = UDim2.new(0.5, -50, 0.45, -50),
        ImageTransparency = 0
    }):Play()

    task.wait(0.3)
    TweenService:Create(LoadBar, TweenInfo.new(0.9, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 120, 0, 3)
    }):Play()

    task.wait(1.0)
    TweenService:Create(LoadingN, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 400, 0, 400),
        Position = UDim2.new(0.5, -200, 0.45, -200),
        ImageTransparency = 1
    }):Play()

    TweenService:Create(LoadBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()

    local fadeBg = TweenService:Create(IntroFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    fadeBg:Play()
    fadeBg.Completed:Wait()
    IntroFrame:Destroy()
end

local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 52)
HeaderBar.BackgroundColor3 = COLORS.DarkMid
HeaderBar.BorderSizePixel = 0
HeaderBar.ZIndex = 10
HeaderBar.Parent = MainFrame

do
    local HeaderBottomCover = Instance.new("Frame")
    HeaderBottomCover.Size = UDim2.new(1, 0, 0, 10)
    HeaderBottomCover.Position = UDim2.new(0, 0, 1, -10)
    HeaderBottomCover.BackgroundColor3 = COLORS.DarkMid
    HeaderBottomCover.BorderSizePixel = 0
    HeaderBottomCover.ZIndex = 10
    HeaderBottomCover.Parent = HeaderBar
end

local BrandLogo = Instance.new("TextButton")
BrandLogo.Name = "BrandLogo"
BrandLogo.Size = UDim2.new(0, 170, 1, 0)
BrandLogo.Position = UDim2.new(0, 18, 0, 0)
BrandLogo.BackgroundTransparency = 1
BrandLogo.Text = "AN UNIVERSAL"
BrandLogo.Font = FONTS.Heavy
BrandLogo.TextSize = 20
BrandLogo.TextColor3 = COLORS.BrandRed
BrandLogo.TextXAlignment = Enum.TextXAlignment.Left
BrandLogo.AutoButtonColor = false
BrandLogo.ZIndex = 11
BrandLogo.Parent = HeaderBar
BindInteractionSounds(BrandLogo)

do
    local brandNeoIcon = Instance.new("ImageLabel")
    brandNeoIcon.Name = "BrandNeoIcon"
    brandNeoIcon.Size = UDim2.new(0, 30, 0, 30)
    brandNeoIcon.Position = UDim2.new(0, 15, 0.5, -15)
    brandNeoIcon.BackgroundTransparency = 1
    brandNeoIcon.ImageTransparency = 0
    brandNeoIcon.ScaleType = Enum.ScaleType.Fit
    brandNeoIcon.Visible = false
    brandNeoIcon.ZIndex = 12
    brandNeoIcon.Parent = HeaderBar
    AN_ENV.AN_NEO_THEME_STATE.BrandIcon = brandNeoIcon
end

local TabNavContainer = Instance.new("ScrollingFrame")
TabNavContainer.Name = "TabNavContainer"
TabNavContainer.Size = UDim2.new(1, -260, 1, 0) 
TabNavContainer.Position = UDim2.new(0, 180, 0, 0)
TabNavContainer.BackgroundTransparency = 1
TabNavContainer.ScrollBarThickness = 0
TabNavContainer.ZIndex = 11
TabNavContainer.Parent = HeaderBar

do
    local TabNavLayout = Instance.new("UIListLayout")
    TabNavLayout.FillDirection = Enum.FillDirection.Horizontal
    TabNavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabNavLayout.Padding = UDim.new(0, 14)
    TabNavLayout.Parent = TabNavContainer

    TabNavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabNavContainer.CanvasSize = UDim2.new(0, TabNavLayout.AbsoluteContentSize.X + 20, 0, 0)
    end)
end

local NavIndicator = Instance.new("Frame")
NavIndicator.Name = "NavIndicator"
NavIndicator.Size = UDim2.new(0, 0, 0, 2)
NavIndicator.Position = UDim2.new(0, 0, 1, -6)
NavIndicator.BackgroundColor3 = COLORS.BrandRed
NavIndicator.BorderSizePixel = 0
NavIndicator.ZIndex = 12
NavIndicator.Parent = HeaderBar

local function makeTextTab(name, width)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Tab"
    tab.BackgroundTransparency = 1
    tab.Size = UDim2.new(0, width or 65, 0, 24)
    tab.Text = name
    tab.Font = FONTS.Medium
    tab.TextSize = 13
    tab.TextColor3 = COLORS.GreyMuted
    tab.AutoButtonColor = false
    tab.ZIndex = 12
    tab.Parent = TabNavContainer
    BindInteractionSounds(tab)
    return tab
end

local MoviesTab = makeTextTab("Movies", 55)
local ExecutorTab = makeTextTab("Director's Cut", 100)
local PiratedTab = makeTextTab("Pirated", 60)
local SettingsTab = makeTextTab("Settings", 65)
local CreditsTab = makeTextTab("Credits", 55)
local AdminTab
if IsAdmin(LocalPlayer.UserId) then
    AdminTab = makeTextTab("Admin", 55)
end

local function updateTabLine(targetTab)
    local absolutePos = targetTab.AbsolutePosition
    local relativeX = absolutePos.X - MainFrame.AbsolutePosition.X
    TweenService:Create(NavIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetTab.AbsoluteSize.X, 0, 2),
        Position = UDim2.new(0, relativeX, 0, 46)
    }):Play()
    
    local allTabs = {MoviesTab, ExecutorTab, PiratedTab, SettingsTab, CreditsTab}
    if AdminTab then table.insert(allTabs, AdminTab) end
    
    for _, otherTab in ipairs(allTabs) do
        local active = (otherTab == targetTab)
        TweenService:Create(otherTab, TweenInfo.new(0.2), {
            TextColor3 = active and COLORS.White or COLORS.GreyMuted
        }):Play()
    end
end

local MinimizeBtn = Instance.new("TextButton")
do
    local ActionsHolder = Instance.new("Frame")
    ActionsHolder.Name = "ActionsHolder"
    ActionsHolder.Size = UDim2.new(0, 70, 1, 0)
    ActionsHolder.Position = UDim2.new(1, -82, 0, 0)
    ActionsHolder.BackgroundTransparency = 1
    ActionsHolder.ZIndex = 11
    ActionsHolder.Parent = HeaderBar

    local ActionsLayout = Instance.new("UIListLayout")
    ActionsLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ActionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ActionsLayout.Padding = UDim.new(0, 10)
    ActionsLayout.Parent = ActionsHolder

    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = COLORS.GreyLight
    MinimizeBtn.Font = FONTS.Bold
    MinimizeBtn.TextSize = 12
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 12
    MinimizeBtn.Parent = ActionsHolder
    createCorner(MinimizeBtn, 13)
    BindInteractionSounds(MinimizeBtn)

    MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 45), TextColor3 = COLORS.White}):Play()
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 28), TextColor3 = COLORS.GreyLight}):Play()
    end)
end

makeDraggable(HeaderBar, MainFrame)

local MinimizedPill = Instance.new("ImageButton")
local MinimizedStroke
do
    MinimizedPill.Name = "MinimizedPill"
    MinimizedPill.Size = UDim2.new(0, 56, 0, 56)
    MinimizedPill.Position = UDim2.new(0.5, -28, 0.5, -28)
    MinimizedPill.BackgroundColor3 = COLORS.DarkMid
    MinimizedPill.BorderSizePixel = 0
    MinimizedPill.AutoButtonColor = false
    MinimizedPill.Visible = false
    MinimizedPill.ZIndex = 100
    MinimizedPill.Parent = ScreenGui
    createCorner(MinimizedPill, 28)
    MinimizedStroke = createStroke(MinimizedPill, COLORS.BrandRed, 2, 0.1)
    BindInteractionSounds(MinimizedPill)
    makeDraggable(MinimizedPill, MinimizedPill)
    LoadImageAsync(MinimizedPill, IMAGE_URLS.PillLogo)
end

function AN_NeoReplaceBrandText(value)
    local result = tostring(value or "")
    result = result:gsub("[Aa][Nn]%s+[Hh][Uu][Bb]", "Neo")
    result = result:gsub("[Aa][Nn]%s+[Uu][Nn][Ii][Vv][Ee][Rr][Ss][Aa][Ll]", "Neo")
    result = result:gsub("%f[%w][Aa][Nn]%f[%W]", "Neo")
    return result
end

function AN_NeoProcessText(object)
    local state = AN_ENV.AN_NEO_THEME_STATE
    if not state or not state.Enabled or not object or not object.Parent then return end
    if not (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then return end

    local currentText = object.Text
    if state.LastText[object] ~= nil and currentText == state.LastText[object] then return end

    local replacement = AN_NeoReplaceBrandText(currentText)
    if replacement ~= currentText then
        state.OriginalText[object] = currentText
        state.LastText[object] = replacement
        object.Text = replacement
    else
        state.OriginalText[object] = nil
        state.LastText[object] = nil
    end
end

function AN_NeoThemeAddDescendant(object)
    local state = AN_ENV.AN_NEO_THEME_STATE
    if not state or not object then return end

    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        if not state.TextHooks[object] then
            state.TextHooks[object] = true
            object:GetPropertyChangedSignal("Text"):Connect(function()
                AN_NeoProcessText(object)
            end)
        end
        if state.Enabled then AN_NeoProcessText(object) end
    end

    if state.Enabled then
        if object:IsA("ImageLabel") or object:IsA("ImageButton") then
            if object.Name == "BrandNeoIcon" or object.Name == "CreditsLogo" or object.Name == "LoadingAN" or object.Name == "MinimizedPill" then
                AN_NeoAttachGif(object, "icon")
            end
        end
    end
end

function AN_NeoRefreshLogos()
    local state = AN_ENV.AN_NEO_THEME_STATE
    if not state then return end
    if state.BrandIcon then state.BrandIcon.Visible = state.Enabled end
    for _, object in ipairs(ScreenGui:GetDescendants()) do
        if object:IsA("ImageLabel") or object:IsA("ImageButton") then
            local url
            if state.Enabled then
                if object.Name == "BrandNeoIcon" or object.Name == "CreditsLogo" or object.Name == "LoadingAN" or object.Name == "MinimizedPill" then
                    AN_NeoAttachGif(object, "icon")
                end
            elseif object.Name == "MinimizedPill" then
                url = IMAGE_URLS.DefaultPillLogo
            elseif object.Name == "CreditsLogo" or object.Name == "LoadingAN" then
                url = IMAGE_URLS.DefaultIntroLogo
            end
            if url then
                state.PlaybackTokens[object] = (state.PlaybackTokens[object] or 0) + 1
                LoadImageAsync(object, url, true)
            end
        end
    end
end

function AN_ToggleNeoTheme()
    local state = AN_ENV.AN_NEO_THEME_STATE
    if not state then return end
    state.Enabled = not state.Enabled

    if state.Enabled then
        if state.BrandIcon then state.BrandIcon.Visible = true end
        BrandLogo.Position = UDim2.new(0, 52, 0, 0)
        BrandLogo.Size = UDim2.new(0, 120, 1, 0)
        BrandLogo.TextSize = 20

        for _, object in ipairs(ScreenGui:GetDescendants()) do
            AN_NeoThemeAddDescendant(object)
        end
        AN_NeoRefreshLogos()
    else
        if state.BrandIcon then state.BrandIcon.Visible = false end
        BrandLogo.Position = UDim2.new(0, 18, 0, 0)
        BrandLogo.Size = UDim2.new(0, 170, 1, 0)
        BrandLogo.TextSize = 20
        AN_NeoStopGifPlayback()

        for object, originalText in pairs(state.OriginalText) do
            local lastText = state.LastText[object]
            state.OriginalText[object] = nil
            state.LastText[object] = nil
            if object and object.Parent and lastText ~= nil and object.Text == lastText then
                object.Text = originalText
            end
        end
        AN_NeoRefreshLogos()
    end
end

ScreenGui.DescendantAdded:Connect(AN_NeoThemeAddDescendant)
for _, object in ipairs(ScreenGui:GetDescendants()) do
    AN_NeoThemeAddDescendant(object)
end
BrandLogo.MouseButton1Click:Connect(AN_ToggleNeoTheme)

local isMinimized = false
local cachedWindowPos = MainFrame.Position
local cachedPillPos = nil

local function clampPosition(pos, size)
    local viewport = Camera.ViewportSize
    -- positions and sizes can carry a Scale part (the window starts centred at 0.5 scale,
    -- and dragging keeps it), so turn both into pixels before clamping
    local w = size.X.Scale * viewport.X + size.X.Offset
    local h = size.Y.Scale * viewport.Y + size.Y.Offset
    local px = pos.X.Scale * viewport.X + pos.X.Offset
    local py = pos.Y.Scale * viewport.Y + pos.Y.Offset
    local x = math.clamp(px, 0, math.max(viewport.X - w, 0))
    local y = math.clamp(py, 0, math.max(viewport.Y - h, 0))
    return UDim2.new(0, x, 0, y)
end

local function setMinimized(state)
    isMinimized = state
    if state then
        cachedWindowPos = MainFrame.Position
        if not cachedPillPos then
            local viewport = Camera.ViewportSize
            cachedPillPos = UDim2.new(0, 30, 0, viewport.Y / 2 - 28)
        end
        MinimizedPill.Position = clampPosition(cachedPillPos, MinimizedPill.Size)
        MainFrame.Visible = false
        MinimizedPill.Visible = true
        MinimizedPill.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MinimizedPill, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 56, 0, 56)
        }):Play()
    else
        cachedPillPos = MinimizedPill.Position
        MinimizedPill.Visible = false
        MainFrame.Position = clampPosition(cachedWindowPos, MainFrame.Size)
        MainFrame.Visible = true
    end
end

local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(1, 0, 1, -52)
MenuFrame.Position = UDim2.new(0, 0, 0, 52)
MenuFrame.BackgroundTransparency = 1
MenuFrame.Parent = MainFrame

local CurrentGenre = "All"
local GenreBtn = Instance.new("TextButton")
local GenreDropdown = Instance.new("ScrollingFrame")
local SearchBox = Instance.new("TextBox")
local TagScroll = Instance.new("ScrollingFrame")
local ActiveTagsFilter = {}

do
    local FilterRow = Instance.new("Frame")
    FilterRow.Name = "FilterRow"
    FilterRow.Size = UDim2.new(1, -36, 0, 36)
    FilterRow.Position = UDim2.new(0, 18, 0, 12)
    FilterRow.BackgroundTransparency = 1
    FilterRow.ZIndex = 2
    FilterRow.Parent = MenuFrame

    GenreBtn.Name = "GenreBtn"
    GenreBtn.Size = UDim2.new(0, 115, 1, 0)
    GenreBtn.Position = UDim2.new(0, 0, 0, 0)
    GenreBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    GenreBtn.Text = "Genre: All "
    GenreBtn.TextColor3 = COLORS.White
    GenreBtn.Font = FONTS.Bold
    GenreBtn.TextSize = 12
    GenreBtn.AutoButtonColor = false
    GenreBtn.ZIndex = 3
    GenreBtn.Parent = FilterRow
    createCorner(GenreBtn, 4)
    createStroke(GenreBtn, COLORS.Border, 1, 0.4)
    BindInteractionSounds(GenreBtn)

    GenreDropdown.Name = "GenreDropdown"
    GenreDropdown.Size = UDim2.new(0, 140, 0, 110)
    GenreDropdown.Position = UDim2.new(0, 0, 1, 5)
    GenreDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    GenreDropdown.ZIndex = 5
    GenreDropdown.Visible = false
    GenreDropdown.ScrollBarThickness = 4
    GenreDropdown.ScrollBarImageColor3 = COLORS.BrandRed
    GenreDropdown.BorderSizePixel = 0
    GenreDropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
    GenreDropdown.Parent = GenreBtn
    createCorner(GenreDropdown, 4)
    createStroke(GenreDropdown, COLORS.Border, 1, 0.4)

    local GenreLayout = Instance.new("UIListLayout")
    GenreLayout.SortOrder = Enum.SortOrder.LayoutOrder
    GenreLayout.Parent = GenreDropdown

    GenreLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        GenreDropdown.CanvasSize = UDim2.new(0, 0, 0, GenreLayout.AbsoluteContentSize.Y)
    end)

    local GenresList = {"All", "My List", "Action", "Comedy", "Horror", "Insta Move", "Hat reanim", "Explicit"}
    for _, genre in ipairs(GenresList) do
        local gBtn = Instance.new("TextButton")
        gBtn.Size = UDim2.new(1, -6, 0, 26)
        gBtn.BackgroundTransparency = 1
        gBtn.Text = " " .. genre
        gBtn.TextColor3 = COLORS.GreyLight
        gBtn.Font = FONTS.Medium
        gBtn.TextSize = 12
        gBtn.TextXAlignment = Enum.TextXAlignment.Left
        gBtn.ZIndex = 6
        gBtn.Parent = GenreDropdown
        BindInteractionSounds(gBtn)
        gBtn.MouseEnter:Connect(function() TweenService:Create(gBtn, TweenInfo.new(0.1), {TextColor3 = COLORS.White, BackgroundTransparency = 0.9}):Play() end)
        gBtn.MouseLeave:Connect(function() TweenService:Create(gBtn, TweenInfo.new(0.1), {TextColor3 = COLORS.GreyLight, BackgroundTransparency = 1}):Play() end)

        gBtn.MouseButton1Click:Connect(function()
            CurrentGenre = genre
            GenreBtn.Text = "Genre: " .. genre .. " "
            GenreDropdown.Visible = false
            if updateCarousel then updateCarousel() end
        end)
    end

    GenreBtn.MouseButton1Click:Connect(function() GenreDropdown.Visible = not GenreDropdown.Visible end)

    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0, 260, 1, 0)
    SearchFrame.Position = UDim2.new(0, 125, 0, 0)
    SearchFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    SearchFrame.BorderSizePixel = 0
    SearchFrame.ZIndex = 3
    SearchFrame.Parent = FilterRow
    createCorner(SearchFrame, 4)
    createStroke(SearchFrame, COLORS.Border, 1, 0.4)

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 15, 0, 15)
    SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.ZIndex = 4
    SearchIcon.Parent = SearchFrame
    LoadImageAsync(SearchIcon, "https://raw.githubusercontent.com/Fe-ProjectR/GAME-IMAGES/refs/heads/main/Untitled226_20260710163154.png")

    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -36, 1, 0)
    SearchBox.Position = UDim2.new(0, 32, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.BorderSizePixel = 0
    SearchBox.Text = ""
    SearchBox.TextColor3 = COLORS.White
    SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
    SearchBox.PlaceholderText = "Titles, creators..."
    SearchBox.TextSize = 13
    SearchBox.Font = FONTS.Book
    SearchBox.ClearTextOnFocus = false
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ZIndex = 4
    SearchBox.Parent = SearchFrame

    SearchBox.Focused:Connect(function()
        TweenService:Create(SearchFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    SearchBox.FocusLost:Connect(function()
        TweenService:Create(SearchFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
    end)

    TagScroll.Name = "TagScroll"
    TagScroll.Size = UDim2.new(1, -395, 1, 0)
    TagScroll.Position = UDim2.new(0, 395, 0, 0)
    TagScroll.BackgroundTransparency = 1
    TagScroll.ScrollBarThickness = 2
    TagScroll.ScrollBarImageColor3 = COLORS.GreyMuted
    TagScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TagScroll.ZIndex = 3
    TagScroll.Parent = FilterRow

    local TagLayout = Instance.new("UIListLayout")
    TagLayout.FillDirection = Enum.FillDirection.Horizontal
    TagLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TagLayout.Padding = UDim.new(0, 8)
    TagLayout.Parent = TagScroll

    for _, tagName in ipairs(UniqueTags) do
        local count = TagCounts[tagName]
        local tBtn = Instance.new("TextButton")
        tBtn.Text = tagName .. " (" .. count .. ")"
        tBtn.Font = FONTS.Bold
        tBtn.TextSize = 11
        tBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        tBtn.TextColor3 = COLORS.GreyLight
        tBtn.ZIndex = 4
        local size = TextService:GetTextSize(tBtn.Text, 11, FONTS.Bold, Vector2.new(999, 20))
        tBtn.Size = UDim2.new(0, size.X + 16, 0, 26)

        createCorner(tBtn, 13)
        local stroke = createStroke(tBtn, COLORS.Border, 1)
        tBtn.Parent = TagScroll
        BindInteractionSounds(tBtn)

        tBtn.MouseButton1Click:Connect(function()
            if ActiveTagsFilter[tagName] then
                ActiveTagsFilter[tagName] = nil
                TweenService:Create(tBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 24), TextColor3 = COLORS.GreyLight}):Play()
                stroke.Color = COLORS.Border
            else
                ActiveTagsFilter[tagName] = true
                TweenService:Create(tBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.White, TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
                stroke.Color = COLORS.White
            end
            if updateCarousel then updateCarousel() end
        end)
    end

    TagLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TagScroll.CanvasSize = UDim2.new(0, TagLayout.AbsoluteContentSize.X + 10, 0, 0)
    end)
end

local CarouselContainer = Instance.new("Frame")
CarouselContainer.Name = "CarouselContainer"
CarouselContainer.Size = UDim2.new(1, -36, 1, -114)
CarouselContainer.Position = UDim2.new(0, 18, 0, 60)
CarouselContainer.BackgroundTransparency = 1
CarouselContainer.ClipsDescendants = true
CarouselContainer.ZIndex = 1
CarouselContainer.Parent = MenuFrame

local function makeArrow(name, alignRight, symbol)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.AnchorPoint = Vector2.new(alignRight and 1 or 0, 0.5)
    btn.Position = alignRight and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.1
    btn.TextColor3 = COLORS.White
    btn.TextSize = 16
    btn.Font = FONTS.Bold
    btn.Text = symbol
    btn.AutoButtonColor = false
    btn.ZIndex = 8
    btn.Parent = CarouselContainer
    createCorner(btn, 15)
    createStroke(btn, Color3.fromRGB(60, 60, 60), 1, 0.6)
    BindInteractionSounds(btn)
    return btn
end

local LeftArrow = makeArrow("LeftArrow", false, "<")
local RightArrow = makeArrow("RightArrow", true, ">")

local MovieCarousel = Instance.new("Frame")
MovieCarousel.Name = "MovieCarousel"
MovieCarousel.Size = UDim2.new(1, 0, 1, 0)
MovieCarousel.BackgroundTransparency = 1
MovieCarousel.ZIndex = 2
MovieCarousel.Parent = CarouselContainer

local EmptyState = Instance.new("TextLabel")
EmptyState.Name = "EmptyState"
EmptyState.Size = UDim2.new(1, 0, 1, 0)
EmptyState.BackgroundTransparency = 1
EmptyState.Text = "No matches found."
EmptyState.TextColor3 = COLORS.GreyMuted
EmptyState.Font = FONTS.Book
EmptyState.TextSize = 14
EmptyState.Visible = false
EmptyState.ZIndex = 3
EmptyState.Parent = CarouselContainer

local DotsHolder = Instance.new("Frame")
DotsHolder.Name = "DotsHolder"
DotsHolder.Size = UDim2.new(1, 0, 0, 10)
DotsHolder.Position = UDim2.new(0, 0, 1, -20)
DotsHolder.BackgroundTransparency = 1
DotsHolder.Parent = MenuFrame

local DetailFrame = Instance.new("Frame")
local DetailImage = Instance.new("ImageLabel")
local DetailTitle = Instance.new("TextLabel")
local MetaRow = Instance.new("TextLabel")
local TagsDetailScroll = Instance.new("ScrollingFrame")
local DetailTagsLayout = Instance.new("UIListLayout")
local DetailDescription = Instance.new("TextLabel")
local ReanimOptionsRow = Instance.new("Frame")
local HideEffectsOptionBtn = Instance.new("TextButton")
local MuteMusicOptionBtn = Instance.new("TextButton")
local PlayBtn = Instance.new("TextButton")
local FavBtn = Instance.new("TextButton")
local BackBtn = Instance.new("TextButton")

do
    DetailFrame.Name = "DetailFrame"
    DetailFrame.Size = UDim2.new(1, 0, 1, -52)
    DetailFrame.Position = UDim2.new(0, 0, 0, 52)
    DetailFrame.BackgroundTransparency = 1
    DetailFrame.Visible = false
    DetailFrame.Parent = MainFrame

    local DetailBody = Instance.new("Frame")
    DetailBody.Name = "DetailBody"
    DetailBody.Size = UDim2.new(1, -36, 1, -24)
    DetailBody.Position = UDim2.new(0, 18, 0, 12)
    DetailBody.BackgroundTransparency = 1
    DetailBody.Parent = DetailFrame

    DetailImage.Name = "DetailImage"
    DetailImage.Size = UDim2.new(0.38, 0, 1, 0)
    DetailImage.BackgroundColor3 = COLORS.DarkCard
    DetailImage.ScaleType = Enum.ScaleType.Crop
    DetailImage.Parent = DetailBody
    createCorner(DetailImage, 6)

    local DetailImageGlow = Instance.new("ImageLabel")
    DetailImageGlow.Size = UDim2.new(1, 20, 1, 20)
    DetailImageGlow.Position = UDim2.new(0, -10, 0, -10)
    DetailImageGlow.BackgroundTransparency = 1
    DetailImageGlow.Image = "rbxassetid://6014261993"
    DetailImageGlow.ImageColor3 = Color3.new(0,0,0)
    DetailImageGlow.ImageTransparency = 0.5
    DetailImageGlow.ScaleType = Enum.ScaleType.Slice
    DetailImageGlow.SliceCenter = Rect.new(49, 49, 450, 450)
    DetailImageGlow.ZIndex = 0
    DetailImageGlow.Parent = DetailImage

    local InfoPanel = Instance.new("Frame")
    InfoPanel.Name = "InfoPanel"
    InfoPanel.Size = UDim2.new(0.58, 0, 1, 0)
    InfoPanel.Position = UDim2.new(0.42, 0, 0, 0)
    InfoPanel.BackgroundTransparency = 1
    InfoPanel.Parent = DetailBody

    DetailTitle.Name = "DetailTitle"
    DetailTitle.Size = UDim2.new(1, 0, 0, 36)
    DetailTitle.BackgroundTransparency = 1
    DetailTitle.TextColor3 = COLORS.White
    DetailTitle.TextSize = 24
    DetailTitle.Font = FONTS.Heavy
    DetailTitle.TextXAlignment = Enum.TextXAlignment.Left
    DetailTitle.TextTruncate = Enum.TextTruncate.AtEnd
    DetailTitle.Parent = InfoPanel

    MetaRow.Name = "MetaRow"
    MetaRow.Size = UDim2.new(1, 0, 0, 16)
    MetaRow.Position = UDim2.new(0, 0, 0, 40)
    MetaRow.BackgroundTransparency = 1
    MetaRow.TextColor3 = COLORS.GreyMuted
    MetaRow.TextSize = 12
    MetaRow.Font = FONTS.Medium
    MetaRow.TextXAlignment = Enum.TextXAlignment.Left
    MetaRow.Parent = InfoPanel

    TagsDetailScroll.Name = "TagsDetailScroll"
    TagsDetailScroll.Size = UDim2.new(1, 0, 0, 30)
    TagsDetailScroll.Position = UDim2.new(0, 0, 0, 60)
    TagsDetailScroll.BackgroundTransparency = 1
    TagsDetailScroll.ScrollBarThickness = 0
    TagsDetailScroll.Parent = InfoPanel

    DetailTagsLayout.FillDirection = Enum.FillDirection.Horizontal
    DetailTagsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    DetailTagsLayout.Padding = UDim.new(0, 8)
    DetailTagsLayout.Parent = TagsDetailScroll

    DetailDescription.Name = "DetailDescription"
    DetailDescription.Size = UDim2.new(1, 0, 1, -170)  -- Reduced height to ensure buttons are visible
    DetailDescription.Position = UDim2.new(0, 0, 0, 95)
    DetailDescription.BackgroundTransparency = 1
    DetailDescription.TextColor3 = COLORS.GreyLight
    DetailDescription.TextSize = 12
    DetailDescription.Font = FONTS.Book
    DetailDescription.TextXAlignment = Enum.TextXAlignment.Left
    DetailDescription.TextYAlignment = Enum.TextYAlignment.Top
    DetailDescription.TextWrapped = true
    DetailDescription.Parent = InfoPanel

    -- Hat reanim options are only displayed when the movie metadata explicitly
    -- declares support for them. The values are applied before the script runs.
    ReanimOptionsRow.Name = "ReanimOptionsRow"
    ReanimOptionsRow.Size = UDim2.new(1, 0, 0, 34)
    ReanimOptionsRow.Position = UDim2.new(0, 0, 1, -105)
    ReanimOptionsRow.BackgroundTransparency = 1
    ReanimOptionsRow.Visible = false
    ReanimOptionsRow.Parent = InfoPanel

    local ReanimOptionsLayout = Instance.new("UIListLayout")
    ReanimOptionsLayout.FillDirection = Enum.FillDirection.Horizontal
    ReanimOptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ReanimOptionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ReanimOptionsLayout.Padding = UDim.new(0, 8)
    ReanimOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ReanimOptionsLayout.Parent = ReanimOptionsRow

    local function setupReanimOptionButton(button, name, order)
        button.Name = name
        button.Size = UDim2.new(0.5, -4, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        button.BorderSizePixel = 0
        button.Text = name
        button.TextColor3 = COLORS.White
        button.Font = FONTS.Bold
        button.TextSize = 11
        button.AutoButtonColor = false
        button.LayoutOrder = order
        button.Visible = false
        button.Parent = ReanimOptionsRow
        createCorner(button, 4)
        createStroke(button, COLORS.Border, 1)
        BindInteractionSounds(button)
    end

    setupReanimOptionButton(HideEffectsOptionBtn, "HideEffectsOptionBtn", 1)
    setupReanimOptionButton(MuteMusicOptionBtn, "MuteMusicOptionBtn", 2)

    local ButtonRow = Instance.new("Frame")
    ButtonRow.Name = "ButtonRow"
    ButtonRow.Size = UDim2.new(1, 0, 0, 48)
    ButtonRow.Position = UDim2.new(0, 0, 1, -62)  -- Increased padding to ensure visibility on mobile
    ButtonRow.BackgroundTransparency = 1
    ButtonRow.Parent = InfoPanel

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.Padding = UDim.new(0, 12)
    ButtonLayout.Parent = ButtonRow

    PlayBtn.Name = "PlayBtn"
    PlayBtn.Size = UDim2.new(0.35, -6, 1, 0)  -- Responsive width instead of fixed 120px
    PlayBtn.BackgroundColor3 = COLORS.BrandRed
    PlayBtn.Text = "Execute"
    PlayBtn.Font = FONTS.Bold
    PlayBtn.TextSize = 13
    PlayBtn.TextColor3 = COLORS.White
    PlayBtn.AutoButtonColor = false
    PlayBtn.Parent = ButtonRow
    createCorner(PlayBtn, 4)
    BindInteractionSounds(PlayBtn)

    FavBtn.Name = "FavBtn"
    FavBtn.Size = UDim2.new(0.3, -6, 1, 0)  -- Responsive width
    FavBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    FavBtn.Text = "+ My List"
    FavBtn.Font = FONTS.Bold
    FavBtn.TextSize = 11
    FavBtn.TextColor3 = COLORS.White
    FavBtn.AutoButtonColor = false
    FavBtn.Parent = ButtonRow
    createCorner(FavBtn, 4)
    createStroke(FavBtn, COLORS.Border, 1)
    BindInteractionSounds(FavBtn)

    -- hover for FavBtn/BackBtn/PlayBtn lives only in the Netflix pass (ANNetflixThemeApply)

    BackBtn.Name = "BackBtn"
    BackBtn.Size = UDim2.new(0.25, -6, 1, 0)  -- Responsive width
    BackBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BackBtn.Text = "Back"
    BackBtn.Font = FONTS.Bold
    BackBtn.TextSize = 12
    BackBtn.TextColor3 = COLORS.White
    BackBtn.AutoButtonColor = false
    BackBtn.Parent = ButtonRow
    createCorner(BackBtn, 4)
    BindInteractionSounds(BackBtn)

end

local routeToView

local ExecutorFrame = Instance.new("Frame")
local CodeInput = Instance.new("TextBox")
local ExecActionBtn = Instance.new("TextButton")
local ExecClearBtn = Instance.new("TextButton")

-- ============================================================================
-- DIRECTOR'S CUT / PERSISTENT SCRIPT TABS
-- ============================================================================
local DirectorState = {
    File = "AN/NFX_DirectorTabs.json",
    Tabs = {},
    Active = 1,
    Token = 0,
    Buttons = {},
    Scroller = nil,
    RenameBox = nil,
    Status = nil,
    NewButton = nil
}

-- Director's Cut UI kit: tween helper, ripple, and icons built from plain Frames
-- (no image assets, so they scale cleanly and recolour instantly).
;(function()
    local UI = {}
    DirectorState.UI = UI
    DirectorState.Seen = setmetatable({}, {__mode = "k"})
    DirectorState.PrevActive = nil

    function UI.Tween(obj, t, props, style, dir)
        local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
        tw:Play()
        return tw
    end

    -- x, y, w, h are scale values (0..1) of the icon box; a bar is centred on its box so rotation pivots correctly
    local function newPart(parent, reg, color, x, y, w, h, rot, round)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.new(x + w / 2, 0, y + h / 2, 0)
        f.Size = UDim2.new(w, 0, h, 0)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.Rotation = rot or 0
        f.Parent = parent
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(round or 0.5, 0)
        c.Parent = f
        reg[#reg + 1] = {f, "BackgroundColor3"}
        return f
    end

    local function newOutline(parent, reg, color, px, x, y, w, h)
        local f = Instance.new("Frame")
        f.Position = UDim2.new(x, 0, y, 0)
        f.Size = UDim2.new(w, 0, h, 0)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.Parent = parent
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0.2, 0)
        c.Parent = f
        local s = Instance.new("UIStroke")
        s.Color = color
        s.Thickness = math.max(1, px * 0.085)
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = f
        reg[#reg + 1] = {s, "Color"}
        return f
    end

    local builders = {}

    builders.plus = function(p, reg, col)
        newPart(p, reg, col, 0.18, 0.43, 0.64, 0.14)
        newPart(p, reg, col, 0.43, 0.18, 0.14, 0.64)
    end

    builders.x = function(p, reg, col)
        newPart(p, reg, col, 0.10, 0.43, 0.80, 0.14, 45)
        newPart(p, reg, col, 0.10, 0.43, 0.80, 0.14, -45)
    end

    builders.check = function(p, reg, col)
        newPart(p, reg, col, 0.19, 0.50, 0.32, 0.15, 45)
        newPart(p, reg, col, 0.30, 0.39, 0.60, 0.15, -45)
    end

    -- right-pointing triangle: the right half of a 45 degree square, clipped
    builders.play = function(p, reg, col)
        local clip = Instance.new("Frame")
        clip.BackgroundTransparency = 1
        clip.BorderSizePixel = 0
        clip.ClipsDescendants = true
        clip.Position = UDim2.new(0.30, 0, 0.10, 0)
        clip.Size = UDim2.new(0.42, 0, 0.80, 0)
        clip.Parent = p
        local d = Instance.new("Frame")
        d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.Position = UDim2.new(0, 0, 0.5, 0)
        d.Size = UDim2.new(1.347, 0, 0.7071, 0)
        d.Rotation = 45
        d.BackgroundColor3 = col
        d.BorderSizePixel = 0
        d.Parent = clip
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0.12, 0)
        c.Parent = d
        reg[#reg + 1] = {d, "BackgroundColor3"}
    end

    builders.trash = function(p, reg, col, px)
        newPart(p, reg, col, 0.16, 0.22, 0.68, 0.10)
        newPart(p, reg, col, 0.38, 0.10, 0.24, 0.09)
        newOutline(p, reg, col, px, 0.26, 0.36, 0.48, 0.50)
        newPart(p, reg, col, 0.41, 0.50, 0.07, 0.24)
        newPart(p, reg, col, 0.54, 0.50, 0.07, 0.24)
    end

    builders.copy = function(p, reg, col, px)
        newPart(p, reg, col, 0.12, 0.12, 0.40, 0.10)
        newPart(p, reg, col, 0.12, 0.12, 0.10, 0.40)
        newOutline(p, reg, col, px, 0.36, 0.36, 0.52, 0.52)
    end

    builders.lines = function(p, reg, col)
        newPart(p, reg, col, 0.14, 0.20, 0.72, 0.10)
        newPart(p, reg, col, 0.14, 0.45, 0.52, 0.10)
        newPart(p, reg, col, 0.14, 0.70, 0.36, 0.10)
    end

    builders.doc = function(p, reg, col, px)
        newOutline(p, reg, col, px, 0.22, 0.08, 0.56, 0.84)
        newPart(p, reg, col, 0.34, 0.32, 0.32, 0.08)
        newPart(p, reg, col, 0.34, 0.50, 0.32, 0.08)
        newPart(p, reg, col, 0.34, 0.68, 0.20, 0.08)
    end

    builders.pencil = function(p, reg, col)
        newPart(p, reg, col, 0.24, 0.38, 0.62, 0.20, -45)
        newPart(p, reg, col, 0.14, 0.82, 0.44, 0.08)
    end

    -- autocomplete icons (Studio-style): keyword / class+service / field / function
    builders.kw = function(p, reg, col)
        newPart(p, reg, col, 0.10, 0.18, 0.26, 0.14, 0, 0.3)
        newPart(p, reg, col, 0.46, 0.18, 0.44, 0.14, 0, 0.3)
        newPart(p, reg, col, 0.10, 0.43, 0.80, 0.14, 0, 0.3)
        newPart(p, reg, col, 0.10, 0.68, 0.56, 0.14, 0, 0.3)
    end

    -- three connected nodes
    builders.node = function(p, reg, col)
        newPart(p, reg, col, 0.18, 0.24, 0.10, 0.52)
        newPart(p, reg, col, 0.20, 0.45, 0.46, 0.10)
        newPart(p, reg, col, 0.06, 0.06, 0.34, 0.34)
        newPart(p, reg, col, 0.06, 0.60, 0.34, 0.34)
        newPart(p, reg, col, 0.58, 0.33, 0.34, 0.34)
    end

    -- boxed dot (variables, properties, events)
    builders.field = function(p, reg, col, px)
        newOutline(p, reg, col, px, 0.10, 0.10, 0.80, 0.80)
        newPart(p, reg, col, 0.36, 0.36, 0.28, 0.28)
    end

    -- diamond with a core (functions, methods)
    builders.cube = function(p, reg, col, px)
        local o = newOutline(p, reg, col, px, 0.20, 0.20, 0.60, 0.60)
        o.Rotation = 45
        newPart(p, reg, col, 0.40, 0.40, 0.20, 0.20)
    end

    function UI.Icon(kind, parent, color, px)
        local root = Instance.new("Frame")
        root.Name = "Icon_" .. kind
        root.AnchorPoint = Vector2.new(0.5, 0.5)
        root.Size = UDim2.new(0, px, 0, px)
        root.Position = UDim2.new(0.5, 0, 0.5, 0)
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.ZIndex = 5
        root.Parent = parent
        local reg = {}
        local build = builders[kind]
        if build then build(root, reg, color, px) end
        local icon = {Root = root}
        function icon.Paint(c, t)
            for _, r in ipairs(reg) do
                if t and t > 0 then
                    UI.Tween(r[1], t, {[r[2]] = c})
                else
                    r[1][r[2]] = c
                end
            end
        end
        return icon
    end

    -- soft white pulse that expands from the middle of a button
    function UI.Ripple(btn)
        if not (btn and btn.Parent) then return end
        btn.ClipsDescendants = true
        local d = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.7
        local r = Instance.new("Frame")
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.Position = UDim2.new(0.5, 0, 0.5, 0)
        r.Size = UDim2.new(0, 0, 0, 0)
        r.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        r.BackgroundTransparency = 0.8
        r.BorderSizePixel = 0
        r.ZIndex = 2
        r.Parent = btn
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0.5, 0)
        c.Parent = r
        UI.Tween(r, 0.45, {Size = UDim2.new(0, d, 0, d), BackgroundTransparency = 1})
        task.delay(0.5, function()
            if r then r:Destroy() end
        end)
    end
end)()

function ensureDirectorFolder()
    pcall(function()
        if makefolder and isfolder and not isfolder("AN") then
            makefolder("AN")
        end
    end)
end

ensureDirectorFolder()

function safeTabName(name)
    name = tostring(name or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("[\\/:*?\"<>|]", "")
    if name == "" then name = "Script" end
    return name:sub(1, 48)
end

function makeUniqueDirectorName(name, ignoreIndex)
    local base = safeTabName(name)
    local candidate = base
    local suffix = 2
    while true do
        local taken = false
        for i, tab in ipairs(DirectorState.Tabs) do
            if i ~= ignoreIndex and tostring(tab.Name or ""):lower() == candidate:lower() then
                taken = true
                break
            end
        end
        if not taken then return candidate end
        candidate = base .. " (" .. suffix .. ")"
        suffix = suffix + 1
    end
end

function saveDirectorTabs()
    DirectorState.Token = DirectorState.Token + 1
    pcall(function()
        if writefile then
            writefile(DirectorState.File, HttpService:JSONEncode(DirectorState.Tabs))
        end
    end)
end

function loadDirectorTabs()
    DirectorState.Tabs = {}
    pcall(function()
        if isfile and readfile and isfile(DirectorState.File) then
            local decoded = HttpService:JSONDecode(readfile(DirectorState.File))
            if type(decoded) == "table" then
                for _, tab in ipairs(decoded) do
                    if type(tab) == "table" then
                        local name = safeTabName(tab.Name or tab.Title or "Script")
                        local source = type(tab.Script) == "string" and tab.Script or ""
                        table.insert(DirectorState.Tabs, {Name = name, Script = source})
                    end
                end
            end
        end
    end)
    if #DirectorState.Tabs == 0 then
        DirectorState.Tabs = {{Name = "Script 1", Script = ""}}
        saveDirectorTabs()
    end
    DirectorState.Active = math.clamp(DirectorState.Active, 1, #DirectorState.Tabs)
end

loadDirectorTabs()

function currentDirectorTab()
    return DirectorState.Tabs[DirectorState.Active]
end

function saveActiveDirectorTab()
    local tab = currentDirectorTab()
    if tab and CodeInput then
        tab.Script = CodeInput.Text
        saveDirectorTabs()
    end
end

function queueDirectorAutosave()
    DirectorState.Token = DirectorState.Token + 1
    local token = DirectorState.Token
    task.delay(0.35, function()
        if token == DirectorState.Token then
            saveActiveDirectorTab()
            if DirectorState.Status then
                DirectorState.Status.Text = "Saved"
                task.delay(0.8, function()
                    if DirectorState.Status then DirectorState.Status.Text = "Ready · auto-save on" end
                end)
            end
        end
    end)
end

function refreshDirectorTabButtons()
    if not DirectorState.Scroller then return end
    local UI = DirectorState.UI
    for _, child in ipairs(DirectorState.Scroller:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
    DirectorState.Buttons = {}

    local activeTab = currentDirectorTab()
    local tabWidth = isMobile() and 122 or 150
    local canClose = #DirectorState.Tabs > 1
    local activeHolder = nil

    for index, tab in ipairs(DirectorState.Tabs) do
        local isActive = (index == DirectorState.Active)

        local holder = Instance.new("Frame")
        holder.Name = "DirectorTab_" .. index
        holder.LayoutOrder = index
        holder.Size = UDim2.new(0, tabWidth, 0, 30)
        holder.BackgroundColor3 = isActive and Color3.fromRGB(32, 32, 32) or Color3.fromRGB(20, 20, 20)
        holder.BorderSizePixel = 0
        holder.ClipsDescendants = true
        holder.Parent = DirectorState.Scroller
        createCorner(holder, 6)
        createStroke(holder, isActive and Color3.fromRGB(70, 70, 70) or COLORS.Border, 1, isActive and 0.2 or 0.55)
        if isActive then activeHolder = holder end

        -- accent bar slides in across the top of whichever tab just became active
        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.AnchorPoint = Vector2.new(0.5, 0)
        accent.Position = UDim2.new(0.5, 0, 0, 0)
        accent.Size = UDim2.new(isActive and 1 or 0, 0, 0, 2)
        accent.BackgroundColor3 = COLORS.BrandRed
        accent.BorderSizePixel = 0
        accent.ZIndex = 3
        accent.Parent = holder
        if isActive and DirectorState.PrevActive ~= tab then
            accent.Size = UDim2.new(0, 0, 0, 2)
            UI.Tween(accent, 0.32, {Size = UDim2.new(1, 0, 0, 2)}, Enum.EasingStyle.Cubic)
        end

        local icon = UI.Icon("doc", holder, isActive and COLORS.White or COLORS.GreyMuted, 13)
        icon.Root.AnchorPoint = Vector2.new(0, 0.5)
        icon.Root.Position = UDim2.new(0, 10, 0.5, 1)

        local selectBtn = Instance.new("TextButton")
        selectBtn.Name = "Select"
        selectBtn.Size = UDim2.new(1, canClose and -58 or -34, 1, 0)
        selectBtn.Position = UDim2.new(0, 30, 0, 1)
        selectBtn.BackgroundTransparency = 1
        selectBtn.Text = tostring(tab.Name or ("Script " .. index))
        selectBtn.TextColor3 = isActive and COLORS.White or COLORS.GreyLight
        selectBtn.Font = FONTS.Bold
        selectBtn.TextSize = 11
        selectBtn.TextXAlignment = Enum.TextXAlignment.Left
        selectBtn.TextTruncate = Enum.TextTruncate.AtEnd
        selectBtn.AutoButtonColor = false
        selectBtn.ZIndex = 4
        selectBtn.Parent = holder
        BindInteractionSounds(selectBtn)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "Close"
        closeBtn.AnchorPoint = Vector2.new(1, 0.5)
        closeBtn.Position = UDim2.new(1, -5, 0.5, 1)
        closeBtn.Size = UDim2.new(0, 22, 0, 22)
        closeBtn.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = ""
        closeBtn.AutoButtonColor = false
        closeBtn.Visible = canClose
        closeBtn.ZIndex = 4
        closeBtn.Parent = holder
        createCorner(closeBtn, 5)
        local xIcon = UI.Icon("x", closeBtn, COLORS.GreyMuted, 9)
        BindInteractionSounds(closeBtn)

        closeBtn.MouseEnter:Connect(function()
            UI.Tween(closeBtn, 0.12, {BackgroundTransparency = 0.2})
            xIcon.Paint(COLORS.White, 0.12)
        end)
        closeBtn.MouseLeave:Connect(function()
            UI.Tween(closeBtn, 0.12, {BackgroundTransparency = 1})
            xIcon.Paint(COLORS.GreyMuted, 0.12)
        end)

        selectBtn.MouseEnter:Connect(function()
            if not isActive then
                UI.Tween(holder, 0.12, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)})
                icon.Paint(COLORS.GreyLight, 0.12)
            end
        end)
        selectBtn.MouseLeave:Connect(function()
            if not isActive then
                UI.Tween(holder, 0.12, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
                icon.Paint(COLORS.GreyMuted, 0.12)
            end
        end)

        selectBtn.MouseButton1Click:Connect(function()
            if index == DirectorState.Active then return end
            saveActiveDirectorTab()
            DirectorState.Active = index
            local nextTab = currentDirectorTab()
            CodeInput.Text = nextTab and nextTab.Script or ""
            DirectorState.RenameBox.Text = nextTab and nextTab.Name or "Script"
            refreshDirectorTabButtons()
            if DirectorState.Status then DirectorState.Status.Text = "Switched · Auto-save ready" end
        end)

        closeBtn.MouseButton1Click:Connect(function()
            if #DirectorState.Tabs <= 1 then return end
            if index == DirectorState.Active then saveActiveDirectorTab() end
            table.remove(DirectorState.Tabs, index)
            if index == DirectorState.Active then
                DirectorState.Active = math.clamp(index, 1, #DirectorState.Tabs)
            elseif index < DirectorState.Active then
                DirectorState.Active = DirectorState.Active - 1
            end
            local nextTab = currentDirectorTab()
            CodeInput.Text = nextTab and nextTab.Script or ""
            DirectorState.RenameBox.Text = nextTab and nextTab.Name or "Script"
            saveDirectorTabs()
            refreshDirectorTabButtons()
        end)

        -- brand new tabs pop in
        if not DirectorState.Seen[tab] then
            DirectorState.Seen[tab] = true
            local pop = Instance.new("UIScale")
            pop.Scale = 0.8
            pop.Parent = holder
            UI.Tween(pop, 0.28, {Scale = 1}, Enum.EasingStyle.Back)
        end

        DirectorState.Buttons[index] = holder
    end

    DirectorState.PrevActive = activeTab

    -- keep the active tab inside the visible strip
    if activeHolder then
        task.delay(0.06, function()
            local sc = DirectorState.Scroller
            if not (sc and sc.Parent and activeHolder.Parent) then return end
            local cp = sc.CanvasPosition.X
            local left = activeHolder.AbsolutePosition.X - sc.AbsolutePosition.X + cp
            local right = left + tabWidth
            local win = sc.AbsoluteSize.X
            local target = cp
            if left < cp then
                target = left - 6
            elseif right > cp + win then
                target = right - win + 6
            end
            if target ~= cp then
                UI.Tween(sc, 0.25, {CanvasPosition = Vector2.new(math.max(target, 0), 0)}, Enum.EasingStyle.Cubic)
            end
        end)
    end
end

function createDirectorTab(name, source)
    saveActiveDirectorTab()
    local newName = makeUniqueDirectorName(name or ("Script " .. (#DirectorState.Tabs + 1)))
    table.insert(DirectorState.Tabs, {Name = newName, Script = type(source) == "string" and source or ""})
    DirectorState.Active = #DirectorState.Tabs
    CodeInput.Text = DirectorState.Tabs[DirectorState.Active].Script
    if DirectorState.RenameBox then DirectorState.RenameBox.Text = newName end
    saveDirectorTabs()
    refreshDirectorTabButtons()
    return DirectorState.Tabs[DirectorState.Active]
end

function renameActiveDirectorTab(name)
    local tab = currentDirectorTab()
    if not tab then return end
    local unique = makeUniqueDirectorName(name, DirectorState.Active)
    tab.Name = unique
    if DirectorState.RenameBox then DirectorState.RenameBox.Text = unique end
    saveDirectorTabs()
    refreshDirectorTabButtons()
end

function openScriptInDirectorTab(name, source)
    if type(source) ~= "string" or source == "" then return false end
    createDirectorTab(name, source)
    routeToView("executor")
    updateTabLine(ExecutorTab)
    return true
end


;(function()
    local UI = DirectorState.UI
    local Tween = UI.Tween
    local isMob = isMobile()

    local C = {
        Shell = Color3.fromRGB(13, 13, 13),
        Field = Color3.fromRGB(20, 20, 20),
        Panel = Color3.fromRGB(35, 35, 35),
        PanelHover = Color3.fromRGB(55, 55, 55),
        PanelOn = Color3.fromRGB(52, 52, 52),
        Ink = Color3.fromRGB(229, 229, 229),
        Gutter = Color3.fromRGB(92, 92, 92),
        Idle = Color3.fromRGB(110, 110, 110),
        Ok = Color3.fromRGB(46, 125, 50),
        Bad = Color3.fromRGB(198, 40, 40),
        BadText = Color3.fromRGB(235, 130, 130)
    }

    local PAD_X, PAD_TOP = 10, 8

    ExecutorFrame.Name = "ExecutorFrame"
    ExecutorFrame.Size = UDim2.new(1, 0, 1, -52)
    ExecutorFrame.Position = UDim2.new(0, 0, 0, 52)
    ExecutorFrame.BackgroundTransparency = 1
    ExecutorFrame.Visible = false
    ExecutorFrame.Parent = MainFrame

    local ExecBody = Instance.new("Frame")
    ExecBody.Name = "ExecBody"
    ExecBody.Size = UDim2.new(1, -36, 1, -24)
    ExecBody.Position = UDim2.new(0, 18, 0, 12)
    ExecBody.BackgroundTransparency = 1
    ExecBody.Parent = ExecutorFrame

    for _, tab in ipairs(DirectorState.Tabs) do DirectorState.Seen[tab] = true end

    -- ========================================================================
    -- ROW 1: tab strip + new tab
    -- ========================================================================
    local TabToolbar = Instance.new("Frame")
    TabToolbar.Name = "TabToolbar"
    TabToolbar.Size = UDim2.new(1, 0, 0, 34)
    TabToolbar.BackgroundTransparency = 1
    TabToolbar.Parent = ExecBody

    local Scroller = Instance.new("ScrollingFrame")
    DirectorState.Scroller = Scroller
    Scroller.Name = "DirectorTabScroller"
    Scroller.Size = UDim2.new(1, -44, 1, 0)
    Scroller.BackgroundTransparency = 1
    Scroller.BorderSizePixel = 0
    Scroller.ScrollBarThickness = 0
    Scroller.ScrollingDirection = Enum.ScrollingDirection.X
    Scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroller.Parent = TabToolbar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = Scroller
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroller.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 8, 0, 0)
    end)

    -- mouse wheel scrolls the tab strip sideways
    Scroller.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local x = math.max(Scroller.CanvasPosition.X - input.Position.Z * 48, 0)
            Tween(Scroller, 0.12, {CanvasPosition = Vector2.new(x, 0)})
        end
    end)

    local NewBtn = Instance.new("TextButton")
    DirectorState.NewButton = NewBtn
    NewBtn.Name = "NewTabButton"
    NewBtn.AnchorPoint = Vector2.new(1, 0.5)
    NewBtn.Position = UDim2.new(1, 0, 0.5, 0)
    NewBtn.Size = UDim2.new(0, 34, 0, 30)
    NewBtn.BackgroundColor3 = COLORS.BrandRed
    NewBtn.Text = ""
    NewBtn.AutoButtonColor = false
    NewBtn.ClipsDescendants = true
    NewBtn.Parent = TabToolbar
    createCorner(NewBtn, 6)
    BindInteractionSounds(NewBtn)
    local plusIcon = UI.Icon("plus", NewBtn, COLORS.White, 14)
    NewBtn.MouseEnter:Connect(function() Tween(plusIcon.Root, 0.25, {Rotation = 90}, Enum.EasingStyle.Cubic) end)
    NewBtn.MouseLeave:Connect(function() Tween(plusIcon.Root, 0.25, {Rotation = 0}, Enum.EasingStyle.Cubic) end)
    NewBtn.MouseButton1Down:Connect(function() UI.Ripple(NewBtn) end)
    NewBtn.MouseButton1Click:Connect(function() createDirectorTab() end)

    -- ========================================================================
    -- ROW 2: script name + live position / size readout
    -- ========================================================================
    local NameRow = Instance.new("Frame")
    NameRow.Name = "NameRow"
    NameRow.Size = UDim2.new(1, 0, 0, 28)
    NameRow.Position = UDim2.new(0, 0, 0, 40)
    NameRow.BackgroundTransparency = 1
    NameRow.Parent = ExecBody

    local RenameBox = Instance.new("TextBox")
    DirectorState.RenameBox = RenameBox
    RenameBox.Size = UDim2.new(1, -178, 1, 0)
    RenameBox.BackgroundColor3 = C.Field
    RenameBox.TextColor3 = COLORS.White
    RenameBox.PlaceholderText = "Script name"
    RenameBox.PlaceholderColor3 = COLORS.GreyMuted
    RenameBox.Text = currentDirectorTab().Name
    RenameBox.TextSize = 11
    RenameBox.Font = FONTS.Medium
    RenameBox.ClearTextOnFocus = false
    RenameBox.TextXAlignment = Enum.TextXAlignment.Left
    RenameBox.TextTruncate = Enum.TextTruncate.AtEnd
    RenameBox.Parent = NameRow
    createCorner(RenameBox, 6)
    local renameStroke = createStroke(RenameBox, COLORS.Border, 1, 0.3)
    local renamePad = Instance.new("UIPadding")
    renamePad.PaddingLeft = UDim.new(0, 30)
    renamePad.PaddingRight = UDim.new(0, 9)
    renamePad.Parent = RenameBox

    local pencil = UI.Icon("pencil", RenameBox, COLORS.GreyMuted, 14)
    pencil.Root.AnchorPoint = Vector2.new(0, 0.5)
    pencil.Root.Position = UDim2.new(0, -21, 0.5, 0)

    RenameBox.Focused:Connect(function()
        Tween(renameStroke, 0.15, {Color = COLORS.White, Transparency = 0.1})
        pencil.Paint(COLORS.White, 0.15)
    end)
    RenameBox.FocusLost:Connect(function()
        Tween(renameStroke, 0.15, {Color = COLORS.Border, Transparency = 0.3})
        pencil.Paint(COLORS.GreyMuted, 0.15)
        local tab = currentDirectorTab()
        if tab and RenameBox.Text ~= tab.Name then
            renameActiveDirectorTab(RenameBox.Text)
        end
    end)

    local Stats = Instance.new("TextLabel")
    Stats.Name = "Stats"
    Stats.AnchorPoint = Vector2.new(1, 0)
    Stats.Position = UDim2.new(1, 0, 0, 0)
    Stats.Size = UDim2.new(0, 168, 1, 0)
    Stats.BackgroundTransparency = 1
    Stats.Text = "Ln 1, Col 1  ·  0 chars"
    Stats.TextColor3 = COLORS.GreyMuted
    Stats.Font = FONTS.Medium
    Stats.TextSize = 10
    Stats.TextXAlignment = Enum.TextXAlignment.Right
    Stats.TextTruncate = Enum.TextTruncate.AtEnd
    Stats.Parent = NameRow

    -- ========================================================================
    -- EDITOR: shell > (line numbers | scrolling text box)
    -- ========================================================================
    local Shell = Instance.new("Frame")
    Shell.Name = "EditorShell"
    Shell.Size = UDim2.new(1, 0, 1, -120)
    Shell.Position = UDim2.new(0, 0, 0, 74)
    Shell.BackgroundColor3 = C.Shell
    Shell.BorderSizePixel = 0
    Shell.ClipsDescendants = true
    Shell.Parent = ExecBody
    createCorner(Shell, 6)
    local ShellStroke = createStroke(Shell, COLORS.Border, 1, 0.2)

    local gutterW = 40

    local GutterClip = Instance.new("Frame")
    GutterClip.Name = "Gutter"
    GutterClip.Position = UDim2.new(0, 2, 0, 2)
    GutterClip.Size = UDim2.new(0, gutterW - 2, 1, -4)
    GutterClip.BackgroundTransparency = 1
    GutterClip.ClipsDescendants = true
    GutterClip.Active = true
    GutterClip.Parent = Shell

    local GutterLabel = Instance.new("TextLabel")
    GutterLabel.Name = "Numbers"
    GutterLabel.Size = UDim2.new(1, 0, 0, 0)
    GutterLabel.AutomaticSize = Enum.AutomaticSize.Y
    GutterLabel.BackgroundTransparency = 1
    GutterLabel.Text = "1"
    GutterLabel.TextColor3 = C.Gutter
    GutterLabel.Font = Enum.Font.Code
    GutterLabel.TextSize = isMob and 12 or 13
    GutterLabel.TextXAlignment = Enum.TextXAlignment.Right
    GutterLabel.TextYAlignment = Enum.TextYAlignment.Top
    GutterLabel.Parent = GutterClip
    local gutterPad = Instance.new("UIPadding")
    gutterPad.PaddingTop = UDim.new(0, PAD_TOP)
    gutterPad.PaddingRight = UDim.new(0, 8)
    gutterPad.Parent = GutterLabel

    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Position = UDim2.new(0, gutterW, 0, 8)
    Divider.Size = UDim2.new(0, 1, 1, -16)
    Divider.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    Divider.BorderSizePixel = 0
    Divider.Parent = Shell

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = "EditorScroll"
    Scroll.Position = UDim2.new(0, gutterW + 1, 0, 2)
    Scroll.Size = UDim2.new(1, -(gutterW + 3), 1, -4)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = isMob and 6 or 5
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
    Scroll.ScrollBarImageTransparency = 0.25
    Scroll.ElasticBehavior = Enum.ElasticBehavior.Never
    Scroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    Scroll.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.Parent = Shell

    CodeInput.Name = "CodeInput"
    CodeInput.Position = UDim2.new(0, 0, 0, 0)
    CodeInput.BackgroundTransparency = 1
    CodeInput.BackgroundColor3 = C.Shell
    CodeInput.Text = currentDirectorTab().Script
    CodeInput.TextColor3 = C.Ink
    CodeInput.Font = Enum.Font.Code
    CodeInput.TextSize = isMob and 12 or 13
    CodeInput.TextXAlignment = Enum.TextXAlignment.Left
    CodeInput.TextYAlignment = Enum.TextYAlignment.Top
    CodeInput.ClearTextOnFocus = false
    CodeInput.MultiLine = true
    CodeInput.TextWrapped = true
    CodeInput.PlaceholderText = "-- paste or write your script here"
    CodeInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    CodeInput.Parent = Scroll

    local CodePadding = Instance.new("UIPadding")
    CodePadding.PaddingTop = UDim.new(0, PAD_TOP)
    CodePadding.PaddingLeft = UDim.new(0, PAD_X)
    CodePadding.PaddingRight = UDim.new(0, PAD_X)
    CodePadding.PaddingBottom = UDim.new(0, 12)
    CodePadding.Parent = CodeInput

    -- execution beam that sweeps the top edge of the editor
    local Beam = Instance.new("Frame")
    Beam.Name = "Beam"
    Beam.Position = UDim2.new(-0.34, 0, 0, 0)
    Beam.Size = UDim2.new(0.34, 0, 0, 2)
    Beam.BackgroundColor3 = COLORS.BrandRed
    Beam.BorderSizePixel = 0
    Beam.ZIndex = 20
    Beam.Parent = Shell
    local beamFade = Instance.new("UIGradient")
    beamFade.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    beamFade.Parent = Beam

    local function sweep()
        Beam.Position = UDim2.new(-0.34, 0, 0, 0)
        Tween(Beam, 0.6, {Position = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
    end

    local function shake()
        task.spawn(function()
            local base = UDim2.new(0, 0, 0, 74)
            for _, dx in ipairs({-5, 5, -3, 3, 0}) do
                Tween(Shell, 0.04, {Position = base + UDim2.new(0, dx, 0, 0)})
                task.wait(0.045)
            end
            Shell.Position = base
        end)
    end

    -- ------------------------------------------------------------------------
    -- sizing, wrap mode
    -- ------------------------------------------------------------------------
    local wrapOn = true
    local minW, minH = 40, 40

    local function syncMinSize()
        minH = math.max(Scroll.AbsoluteSize.Y - (wrapOn and 0 or 12), 40)
        minW = math.max(Scroll.AbsoluteSize.X - 12, 40)
        if wrapOn then
            CodeInput.Size = UDim2.new(1, 0, 0, minH)
        else
            CodeInput.Size = UDim2.new(0, minW, 0, minH)
        end
    end

    local function applyGutterWidth(lineCount)
        local digits = #tostring(lineCount)
        local w = math.max(36, math.floor(digits * CodeInput.TextSize * 0.62 + 24))
        if w == gutterW then return end
        gutterW = w
        GutterClip.Size = UDim2.new(0, gutterW - 2, 1, -4)
        Divider.Position = UDim2.new(0, gutterW, 0, 8)
        Scroll.Position = UDim2.new(0, gutterW + 1, 0, 2)
        Scroll.Size = UDim2.new(1, -(gutterW + 3), 1, -4)
    end

    local function measure(text, width)
        local ok, v = pcall(function()
            local params = Instance.new("GetTextBoundsParams")
            params.Text = text
            params.Font = CodeInput.FontFace
            params.Size = CodeInput.TextSize
            params.Width = width
            return TextService:GetTextBoundsAsync(params)
        end)
        if ok then return v end
        return nil
    end

    local gutterToken = 0
    local function refreshGutter()
        gutterToken += 1
        local my = gutterToken
        task.delay(0.05, function()
            if my ~= gutterToken or not GutterLabel.Parent then return end
            local lines = string.split(CodeInput.Text, "\n")
            local n = #lines
            applyGutterWidth(n)
            local out = table.create(n)
            local availW = CodeInput.AbsoluteSize.X - PAD_X * 2
            local simple = (not wrapOn) or n > 3000 or availW < 40
            if simple then
                for i = 1, n do out[i] = tostring(i) end
            else
                local size = CodeInput.TextSize
                local one = measure("Ag", 100000)
                if my ~= gutterToken then return end
                local lineH = one and one.Y or size * 1.2
                local calls = 0
                for i = 1, n do
                    local line = lines[i]
                    local rows = 1
                    -- anything that certainly fits on one row skips the measurement
                    if #line * size * 0.62 > availW * 0.98 then
                        if calls < 60 then
                            calls += 1
                            local v = measure(line, availW)
                            if my ~= gutterToken then return end
                            if v then rows = math.max(1, math.floor(v.Y / lineH + 0.5)) end
                        else
                            rows = math.max(1, math.ceil(#line * size * 0.55 / availW))
                        end
                    end
                    out[i] = rows > 1 and (tostring(i) .. string.rep("\n", rows - 1)) or tostring(i)
                end
            end
            GutterLabel.Text = table.concat(out, "\n")
        end)
    end

    Scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        GutterLabel.Position = UDim2.new(0, 0, 0, -Scroll.CanvasPosition.Y)
    end)

    GutterClip.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local y = math.max(Scroll.CanvasPosition.Y - input.Position.Z * 54, 0)
            Scroll.CanvasPosition = Vector2.new(Scroll.CanvasPosition.X, y)
        end
    end)

    -- ------------------------------------------------------------------------
    -- keep the caret on screen while typing
    -- ------------------------------------------------------------------------
    local followToken = 0
    local function followCursor()
        if not CodeInput:IsFocused() then return end
        local cur = CodeInput.CursorPosition
        if cur < 1 then return end
        followToken += 1
        local my = followToken
        task.spawn(function()
            local before = CodeInput.Text:sub(1, cur - 1)
            local lastLine = before:match("([^\n]*)$") or ""
            local size = CodeInput.TextSize
            local availW = CodeInput.AbsoluteSize.X - PAD_X * 2
            local tall = measure(before .. "|", wrapOn and math.max(availW, 40) or 100000)
            local one = measure("Ag", 100000)
            if my ~= followToken then return end
            local lineH = one and one.Y or size * 1.2
            local bottom = PAD_TOP + (tall and tall.Y or lineH)
            local top = bottom - lineH
            local cp = Scroll.CanvasPosition
            local win = Scroll.AbsoluteWindowSize
            local newY, newX = cp.Y, cp.X
            if top < cp.Y then
                newY = top - 4
            elseif bottom > cp.Y + win.Y then
                newY = bottom - win.Y + 6
            end
            if not wrapOn then
                local wide = measure(lastLine .. "|", 100000)
                if my ~= followToken then return end
                local curX = PAD_X + (wide and wide.X or 0)
                if curX < cp.X + 12 then
                    newX = curX - 40
                elseif curX > cp.X + win.X - 12 then
                    newX = curX - win.X + 40
                end
            end
            newX, newY = math.max(newX, 0), math.max(newY, 0)
            if newX ~= cp.X or newY ~= cp.Y then
                Scroll.CanvasPosition = Vector2.new(newX, newY)
            end
        end)
    end

    local function updateStats()
        local text = CodeInput.Text
        local cur = CodeInput.CursorPosition
        local ln, col = 1, 1
        if cur > 0 then
            local before = text:sub(1, cur - 1)
            ln = select(2, before:gsub("\n", "")) + 1
            col = #(before:match("([^\n]*)$") or "") + 1
        end
        Stats.Text = string.format("Ln %d, Col %d  ·  %d chars", ln, col, #text)
    end

    -- ========================================================================
    -- BOTTOM BAR: status on the left, tools on the right
    -- ========================================================================
    local ActionRow = Instance.new("Frame")
    ActionRow.Name = "ActionRow"
    ActionRow.Size = UDim2.new(1, 0, 0, 40)
    ActionRow.Position = UDim2.new(0, 0, 1, -40)
    ActionRow.BackgroundTransparency = 1
    ActionRow.Parent = ExecBody

    local btnSize = isMob and 34 or 32
    local labelBtnW = isMob and btnSize or 78
    local statusReserve = 112 + 3 * labelBtnW + 4 * 8 + 14

    local Dot = Instance.new("Frame")
    Dot.Name = "StatusDot"
    Dot.AnchorPoint = Vector2.new(0, 0.5)
    Dot.Position = UDim2.new(0, 4, 0.5, 0)
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.BackgroundColor3 = C.Idle
    Dot.BorderSizePixel = 0
    Dot.Parent = ActionRow
    createCorner(Dot, 4)
    TweenService:Create(Dot, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.7
    }):Play()

    local Status = Instance.new("TextLabel")
    DirectorState.Status = Status
    Status.Name = "Status"
    Status.Position = UDim2.new(0, 20, 0, 0)
    Status.Size = UDim2.new(1, -(statusReserve + 20), 1, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "Ready · auto-save on"
    Status.TextColor3 = COLORS.GreyMuted
    Status.Font = FONTS.Medium
    Status.TextSize = 11
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextTruncate = Enum.TextTruncate.AtEnd
    Status.Parent = ActionRow

    local function paintStatus()
        local t = Status.Text
        local dot, ink = C.Idle, COLORS.GreyMuted
        if t:find("^Error") or t:find("^Failed") then
            dot, ink = C.Bad, C.BadText
        elseif t:find("^Running") then
            dot = COLORS.BrandRed
        elseif t:find("^Executed") or t:find("^Saved") or t:find("^Copied") or t:find("^Cleared") or t:find("^Switched") then
            dot = C.Ok
        end
        Tween(Dot, 0.2, {BackgroundColor3 = dot})
        Tween(Status, 0.2, {TextColor3 = ink})
    end
    Status:GetPropertyChangedSignal("Text"):Connect(paintStatus)

    local Buttons = Instance.new("Frame")
    Buttons.Name = "Buttons"
    Buttons.AnchorPoint = Vector2.new(1, 0.5)
    Buttons.Position = UDim2.new(1, 0, 0.5, 0)
    Buttons.Size = UDim2.new(0, 0, 1, 0)
    Buttons.AutomaticSize = Enum.AutomaticSize.X
    Buttons.BackgroundTransparency = 1
    Buttons.Parent = ActionRow
    local ButtonsLayout = Instance.new("UIListLayout")
    ButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonsLayout.Padding = UDim.new(0, 8)
    ButtonsLayout.Parent = Buttons

    -- shared look for the grey tool buttons (icon, plus a label on desktop)
    local function toolButton(btn, kind, label, order)
        btn.Size = UDim2.new(0, labelBtnW, 0, btnSize)
        btn.BackgroundColor3 = C.Panel
        btn.Text = isMob and "" or label
        btn.TextColor3 = COLORS.GreyLight
        btn.Font = FONTS.Bold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.ClipsDescendants = true
        btn.LayoutOrder = order
        btn.Parent = Buttons
        createCorner(btn, 6)
        createStroke(btn, COLORS.Border, 1, 0.3)
        BindInteractionSounds(btn)
        local icon = UI.Icon(kind, btn, COLORS.GreyLight, 15)
        if not isMob then
            icon.Root.Position = UDim2.new(0, 15, 0.5, 0)
            btn.TextXAlignment = Enum.TextXAlignment.Center
        end
        btn.MouseEnter:Connect(function()
            icon.Paint(COLORS.White, 0.12)
            Tween(btn, 0.12, {TextColor3 = COLORS.White})
        end)
        btn.MouseLeave:Connect(function()
            icon.Paint(COLORS.GreyLight, 0.12)
            Tween(btn, 0.12, {TextColor3 = COLORS.GreyLight})
        end)
        btn.MouseButton1Down:Connect(function() UI.Ripple(btn) end)
        return icon
    end

    -- WRAP toggle ------------------------------------------------------------
    local WrapBtn = Instance.new("TextButton")
    WrapBtn.Name = "WrapBtn"
    local wrapIcon = toolButton(WrapBtn, "lines", "Wrap", 1)

    local function wrapRest()
        return wrapOn and C.PanelOn or C.Panel
    end
    local function paintWrap()
        Tween(WrapBtn, 0.15, {BackgroundColor3 = wrapRest()})
        wrapIcon.Paint(wrapOn and COLORS.White or COLORS.GreyLight, 0.15)
    end
    WrapBtn.MouseEnter:Connect(function() Tween(WrapBtn, 0.12, {BackgroundColor3 = C.PanelHover}) end)
    WrapBtn.MouseLeave:Connect(function() Tween(WrapBtn, 0.12, {BackgroundColor3 = wrapRest()}) end)

    local function applyWrap(on)
        wrapOn = on
        Settings.DirectorWrap = on
        if on then
            Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
            Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            CodeInput.TextWrapped = true
            CodeInput.AutomaticSize = Enum.AutomaticSize.Y
            Scroll.CanvasPosition = Vector2.new(0, Scroll.CanvasPosition.Y)
        else
            Scroll.ScrollingDirection = Enum.ScrollingDirection.XY
            Scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
            Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            CodeInput.TextWrapped = false
            CodeInput.AutomaticSize = Enum.AutomaticSize.XY
        end
        syncMinSize()
        refreshGutter()
        paintWrap()
    end

    WrapBtn.MouseButton1Click:Connect(function()
        applyWrap(not wrapOn)
        saveSettings()
        Status.Text = wrapOn and "Word wrap on" or "Word wrap off · scroll sideways for long lines"
    end)

    -- COPY -------------------------------------------------------------------
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Name = "CopyBtn"
    local copyIcon = toolButton(CopyBtn, "copy", "Copy", 2)
    local checkIcon = UI.Icon("check", CopyBtn, C.Ok, 15)
    checkIcon.Root.Position = copyIcon.Root.Position
    checkIcon.Root.Visible = false
    CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, 0.12, {BackgroundColor3 = C.PanelHover}) end)
    CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, 0.12, {BackgroundColor3 = C.Panel}) end)

    local copyId = 0
    CopyBtn.MouseButton1Click:Connect(function()
        local text = CodeInput.Text
        if text == "" then
            Status.Text = "Nothing to copy yet"
            return
        end
        if not setclipboard then
            Status.Text = "Error: this executor has no clipboard support"
            return
        end
        setclipboard(text)
        Status.Text = "Copied to clipboard"
        copyId += 1
        local my = copyId
        copyIcon.Root.Visible = false
        checkIcon.Root.Visible = true
        task.delay(1.3, function()
            if my ~= copyId then return end
            copyIcon.Root.Visible = true
            checkIcon.Root.Visible = false
        end)
    end)

    -- CLEAR (hover colours are handled by the shared polish pass) ------------
    local clearIcon = toolButton(ExecClearBtn, "trash", "Clear", 3)
    ExecClearBtn.MouseButton1Click:Connect(function()
        CodeInput.Text = ""
        saveActiveDirectorTab()
        Scroll.CanvasPosition = Vector2.new(0, 0)
        Status.Text = "Cleared · Saved"
    end)

    -- EXECUTE ----------------------------------------------------------------
    ExecActionBtn.Size = UDim2.new(0, 112, 0, btnSize + 2)
    ExecActionBtn.BackgroundColor3 = COLORS.BrandRed
    ExecActionBtn.Text = "Execute"
    ExecActionBtn.Font = FONTS.Bold
    ExecActionBtn.TextSize = 12
    ExecActionBtn.TextColor3 = COLORS.White
    ExecActionBtn.AutoButtonColor = false
    ExecActionBtn.ClipsDescendants = true
    ExecActionBtn.LayoutOrder = 4
    ExecActionBtn.Parent = Buttons
    createCorner(ExecActionBtn, 6)
    BindInteractionSounds(ExecActionBtn)
    local playIcon = UI.Icon("play", ExecActionBtn, COLORS.White, 15)
    playIcon.Root.Position = UDim2.new(0, 17, 0.5, 0)
    ExecActionBtn.MouseEnter:Connect(function()
        Tween(playIcon.Root, 0.18, {Position = UDim2.new(0, 21, 0.5, 0)}, Enum.EasingStyle.Cubic)
    end)
    ExecActionBtn.MouseLeave:Connect(function()
        Tween(playIcon.Root, 0.18, {Position = UDim2.new(0, 17, 0.5, 0)}, Enum.EasingStyle.Cubic)
    end)
    ExecActionBtn.MouseButton1Down:Connect(function() UI.Ripple(ExecActionBtn) end)

    local runId = 0
    ExecActionBtn.MouseButton1Click:Connect(function()
        saveActiveDirectorTab()
        runId += 1
        local my = runId
        Status.Text = "Running…"
        sweep()
        task.spawn(function()
            local result = {ok = true}
            local fn, compileErr = loadstring(CodeInput.Text)
            if not fn then
                result.ok, result.err = false, compileErr
            else
                local finished = false
                task.spawn(function()
                    local s, e = pcall(fn)
                    result.ok, result.err = s, e
                    finished = true
                end)
                -- a script that keeps running is still a successful launch
                local t0 = os.clock()
                while not finished and os.clock() - t0 < 0.4 do task.wait() end
            end

            ExecActionBtn.Text = result.ok and "Executed" or "Failed"
            if result.ok then
                Status.Text = "Executed"
            else
                local msg = tostring(result.err or "unknown error"):gsub("\n.*", "")
                if #msg > 90 then msg = msg:sub(1, 90) .. "…" end
                Status.Text = "Error: " .. msg
                shake()
            end

            task.wait(1.2)
            if my == runId and ExecActionBtn then ExecActionBtn.Text = "Execute" end
            if not result.ok then
                task.wait(5)
                if my == runId and Status.Text:find("^Error") then Status.Text = "Ready · auto-save on" end
            end
        end)
    end)

    -- ========================================================================
    -- AUTOCOMPLETE  (Roblox Studio style suggestion list)
    --   type  -> a list opens under the word you are typing
    --   hover -> the row highlights        click / Tab / Enter -> fills the word
    --   Up / Down move the highlight       Esc closes
    -- ========================================================================
    local AC_ENABLED = true         -- master switch
    local AC_ENTER_ACCEPTS = true   -- Enter also fills (like Studio). false = Tab / click only
    local AC_ROW_H = isMob and 34 or 24
    local AC_MAX_ROWS = isMob and 5 or 8
    local AC_MAX_RESULTS = 40
    local AC_Z = 80
    local AC_NAME_X = 34
    local AC_MATCH = "#4DA6FF"

    local KIND = {
        keyword = {icon = "kw",    color = Color3.fromRGB(214, 220, 232)},
        class   = {icon = "node",  color = Color3.fromRGB(245, 166, 35)},
        field   = {icon = "field", color = Color3.fromRGB(77, 166, 255)},
        func    = {icon = "cube",  color = Color3.fromRGB(176, 124, 240)},
        snippet = {icon = "doc",   color = Color3.fromRGB(86, 200, 170)}
    }

    -- ---- word lists --------------------------------------------------------
    local function words(kind, str, out)
        for w in str:gmatch("%S+") do out[#out + 1] = {n = w, k = kind} end
        return out
    end

    local KEYWORD_LIST = "and break continue do else elseif end false for function if in local nil not or repeat return then true until while"

    local SERVICES = words("class", [[
        Players Workspace Lighting ReplicatedStorage ReplicatedFirst ServerStorage ServerScriptService
        StarterGui StarterPack StarterPlayer SoundService CoreGui Teams Debris CollectionService
        ContextActionService MarketplaceService TeleportService GuiService VirtualUser VirtualInputManager
        PathfindingService ProximityPromptService LocalizationService HttpService RunService
        UserInputService TweenService TextService TextChatService Chat PolicyService BadgeService
        GroupService SocialService Stats ScriptContext LogService AnalyticsService MaterialService
        AssetService ContentProvider InsertService PhysicsService
    ]], {})

    local GLOBAL = {}
    words("keyword", KEYWORD_LIST, GLOBAL)
    words("func", [[
        print warn error assert pcall xpcall pairs ipairs next select tostring tonumber type typeof
        require loadstring setmetatable getmetatable rawget rawset rawequal rawlen unpack tick time wait
        spawn delay collectgarbage newproxy getfenv setfenv
    ]], GLOBAL)
    words("field", "game workspace script shared _G _VERSION math string table task os coroutine debug utf8 bit32 Drawing crypt", GLOBAL)
    -- executor API
    words("func", [[
        writefile readfile appendfile isfile isfolder makefolder delfolder delfile listfiles loadfile dofile
        getgenv getrenv getreg getgc getinstances getnilinstances getscripts getloadedmodules getconnections
        firesignal fireclickdetector fireproximityprompt firetouchinterest hookfunction hookmetamethod
        newcclosure checkcaller getrawmetatable setrawmetatable setreadonly isreadonly getnamecallmethod
        setnamecallmethod setclipboard toclipboard request http_request queue_on_teleport identifyexecutor
        getexecutorname setfpscap getcustomasset decompile getscriptbytecode getscriptclosure cloneref
        compareinstances clonefunction iscclosure islclosure gethui gethiddenproperty sethiddenproperty
        setsimulationradius mouse1click mouse1press mouse1release mousemoverel mousemoveabs mousescroll
        keypress keyrelease keyclick saveinstance base64_encode base64_decode getcallingscript
        getthreadidentity setthreadidentity getupvalue getupvalues setupvalue getconstants getconstant
        getprotos getstack lz4compress lz4decompress
    ]], GLOBAL)
    for _, s in ipairs(SERVICES) do GLOBAL[#GLOBAL + 1] = s end
    words("class", [[
        Instance Enum Vector3 Vector2 CFrame Color3 UDim2 UDim Rect Ray Region3 BrickColor NumberRange
        NumberSequence ColorSequence TweenInfo Random RaycastParams OverlapParams Font Axes Faces
        PhysicalProperties Part MeshPart WedgePart Model Folder Script LocalScript ModuleScript RemoteEvent
        RemoteFunction BindableEvent BindableFunction ScreenGui Frame TextLabel TextButton TextBox ImageLabel
        ImageButton ScrollingFrame ViewportFrame CanvasGroup UICorner UIStroke UIListLayout UIGridLayout
        UIPadding UIGradient UIScale UIAspectRatioConstraint UISizeConstraint Sound Humanoid Tool Animation
        Animator Attachment BodyVelocity BodyPosition BodyGyro Highlight Beam Trail ParticleEmitter
        PointLight SpotLight ClickDetector ProximityPrompt Seat SpawnLocation Decal Texture Weld
        WeldConstraint Motor6D Camera StringValue NumberValue BoolValue IntValue ObjectValue Color3Value
    ]], GLOBAL)

    local SNIPPETS = {
        {n = "fori",       ins = "for i = 1, $0 do\n    \nend"},
        {n = "forp",       ins = "for _, v in pairs($0) do\n    \nend"},
        {n = "forip",      ins = "for i, v in ipairs($0) do\n    \nend"},
        {n = "whiledo",    ins = "while $0 do\n    task.wait()\nend"},
        {n = "ifthen",     ins = "if $0 then\n    \nend"},
        {n = "localfn",    ins = "local function $0()\n    \nend"},
        {n = "pcallf",     ins = "local ok, err = pcall(function()\n    $0\nend)"},
        {n = "spawnf",     ins = "task.spawn(function()\n    $0\nend)"},
        {n = "getservice", ins = "game:GetService(\"$0\")"}
    }
    for _, s in ipairs(SNIPPETS) do
        s.k = "snippet"
        GLOBAL[#GLOBAL + 1] = s
    end

    local GLOBAL_SET, KEYWORD_SET = {}, {}
    for _, it in ipairs(GLOBAL) do GLOBAL_SET[it.n] = true end
    for w in KEYWORD_LIST:gmatch("%S+") do KEYWORD_SET[w] = true end

    -- members that show after "name." or "name:"
    local MEMBERS = {}
    local function lib(names, funcs, fields)
        local list = {}
        words("func", funcs or "", list)
        words("field", fields or "", list)
        for n in names:gmatch("%S+") do MEMBERS[n] = list end
    end
    lib("math", "abs acos asin atan atan2 ceil clamp cos cosh deg exp floor fmod frexp ldexp log log10 max min modf noise pow rad random randomseed round sign sin sinh sqrt tan tanh", "pi huge")
    lib("string", "byte char find format gmatch gsub len lower match pack packsize rep reverse split sub unpack upper")
    lib("table", "clear clone concat create find freeze insert isfrozen maxn move pack remove sort unpack")
    lib("task", "cancel defer delay desynchronize spawn synchronize wait")
    lib("os", "clock date difftime time")
    lib("coroutine", "close create isyieldable resume running status wrap yield")
    lib("debug", "info profilebegin profileend traceback")
    lib("utf8", "char codepoint codes len offset", "charpattern")
    lib("Instance", "new")
    lib("Vector3", "new FromNormalId FromAxis", "zero one xAxis yAxis zAxis")
    lib("Vector2", "new", "zero one xAxis yAxis")
    lib("CFrame", "new Angles lookAt fromEulerAnglesXYZ fromEulerAnglesYXZ fromOrientation fromAxisAngle fromMatrix", "identity")
    lib("Color3", "new fromRGB fromHSV fromHex")
    lib("UDim2", "new fromScale fromOffset")
    lib("UDim", "new")
    lib("TweenInfo", "new")
    lib("BrickColor", "new random palette")
    lib("Random", "new")
    lib("Enum", nil, "KeyCode UserInputType Material EasingStyle EasingDirection Font HumanoidStateType RaycastFilterType NormalId PartType SortOrder TextXAlignment TextYAlignment FillDirection")
    lib("game", "GetService HttpGet HttpGetAsync FindFirstChild FindFirstChildOfClass WaitForChild IsLoaded GetFullName IsA", "PlaceId GameId JobId PlaceVersion Players Workspace Lighting ReplicatedStorage StarterGui CoreGui Loaded")
    lib("workspace", "Raycast FindFirstChild GetChildren WaitForChild GetServerTimeNow", "CurrentCamera Gravity Terrain DistributedGameTime FallenPartsDestroyHeight")
    lib("Players players", "GetPlayers GetPlayerByUserId GetPlayerFromCharacter GetUserIdFromNameAsync GetNameFromUserIdAsync FindFirstChild", "LocalPlayer PlayerAdded PlayerRemoving MaxPlayers")
    lib("LocalPlayer localPlayer lp plr", "Kick GetMouse LoadCharacter Move GetRankInGroup IsFriendsWith", "Character CharacterAdded CharacterRemoving UserId Name DisplayName Team TeamColor AccountAge PlayerGui Backpack Neutral CameraMode")
    lib("RunService", "BindToRenderStep UnbindFromRenderStep IsStudio IsClient IsServer IsRunning", "Heartbeat RenderStepped Stepped PreRender PreSimulation PostSimulation")
    lib("UserInputService", "IsKeyDown GetMouseLocation GetMouseDelta GetKeysPressed IsMouseButtonPressed GetFocusedTextBox", "InputBegan InputEnded InputChanged TouchEnabled KeyboardEnabled MouseEnabled GamepadEnabled MouseBehavior MouseIconEnabled")
    lib("TweenService", "Create GetValue")
    lib("HttpService", "JSONEncode JSONDecode GenerateGUID UrlEncode RequestAsync GetAsync PostAsync")

    -- anything with an unknown owner: ":" -> methods, "." -> properties and events
    local GEN_METHODS = words("func", [[
        Clone Destroy ClearAllChildren FindFirstChild FindFirstChildOfClass FindFirstChildWhichIsA
        FindFirstAncestor FindFirstAncestorOfClass FindFirstAncestorWhichIsA GetChildren GetDescendants
        GetFullName GetAttribute SetAttribute GetAttributes GetPropertyChangedSignal IsA IsDescendantOf
        IsAncestorOf WaitForChild GetService Connect Once Disconnect Wait Fire FireServer FireClient
        InvokeServer Invoke Play Stop Pause LoadAnimation MoveTo Move Kick TakeDamage ChangeState
        EquipTool UnequipTools GetState GetPivot PivotTo GetBoundingBox TranslateBy ApplyImpulse GetMass
        GetTouchingParts SetNetworkOwner GetNetworkOwner Raycast
    ]], {})
    local GEN_FIELDS = words("field", [[
        Parent Name ClassName Position Size CFrame Orientation Rotation Anchored CanCollide CanTouch
        CanQuery Transparency Color Material Massless Velocity AssemblyLinearVelocity
        AssemblyAngularVelocity Text Visible BackgroundColor3 BackgroundTransparency TextColor3 TextSize
        Font Image ZIndex Active AnchorPoint Health MaxHealth WalkSpeed JumpPower JumpHeight HipHeight
        Character Humanoid HumanoidRootPart Head Torso PrimaryPart Value Enabled Looped Volume SoundId
        TimePosition IsPlaying Changed Touched TouchEnded ChildAdded ChildRemoved DescendantAdded
        DescendantRemoving AncestryChanged Destroying Died HealthChanged Running Jumping StateChanged
        MouseButton1Click MouseButton1Down MouseButton1Up MouseButton2Click MouseEnter MouseLeave Activated
        InputBegan InputEnded InputChanged FocusLost Focused Triggered TriggerEnded OnClientEvent
        OnServerEvent Completed
    ]], {})
    local GEN_ALL = {}
    for _, it in ipairs(GEN_FIELDS) do GEN_ALL[#GEN_ALL + 1] = it end
    for _, it in ipairs(GEN_METHODS) do GEN_ALL[#GEN_ALL + 1] = it end

    -- ---- matching ---------------------------------------------------------
    local function isBoundary(name, s)
        if s == 1 then return true end
        local pc = name:sub(s - 1, s - 1)
        if pc == "_" then return true end
        return name:sub(s, s):match("%u") ~= nil and pc:match("%u") == nil
    end

    local function matchPass(name, lname, q, boundary)
        local idx, pos, prev, score = {}, 1, 0, 500
        for i = 1, #q do
            local c = q:sub(i, i)
            local p = lname:find(c, pos, true)
            if not p then return nil end
            if boundary then
                local s = p
                while s do
                    if isBoundary(name, s) then
                        p = s
                        break
                    end
                    s = lname:find(c, s + 1, true)
                end
            end
            if p == prev + 1 then score += 16 end
            if isBoundary(name, p) then score += 10 end
            score -= math.min(p - prev - 1, 8)
            idx[i] = p
            prev = p
            pos = p + 1
        end
        return score - #name * 0.5, idx
    end

    -- returns score, matched positions (nil when the name does not match)
    local function fuzzy(name, q, raw)
        local ql = #q
        local lname = name:lower()
        if lname:sub(1, ql) == q then
            local idx = table.create(ql)
            for i = 1, ql do idx[i] = i end
            return 2000 - #name + (name:sub(1, ql) == raw and 100 or 0), idx
        end
        if ql < 2 then return nil end
        local s, idx = matchPass(name, lname, q, true)
        if not s then s, idx = matchPass(name, lname, q, false) end
        return s, idx
    end

    -- ---- identifiers from the script itself (locals, functions, params) -----
    local function scanSymbols(text, skipWord)
        local seen, out = {}, {}
        local function add(n, kind)
            if #n < 2 or seen[n] or n == skipWord or KEYWORD_SET[n] or GLOBAL_SET[n] then return end
            if #out >= 400 then return end
            seen[n] = true
            out[#out + 1] = {n = n, k = kind, doc = true}
        end
        for fname in text:gmatch("function%s+([%a_][%w_%.:]*)") do
            add(fname:match("([%a_][%w_]*)$") or fname, "func")
        end
        for line in text:gmatch("[^\n]+") do
            local names = line:match("^%s*local%s+([%a_][%w_,%s]*)")
            if names and not names:match("^function") then
                for n in names:gmatch("[%a_][%w_]*") do add(n, "field") end
            end
            local loopVars = line:match("^%s*for%s+([%a_][%w_,%s]*)%s+in%s")
            if loopVars then
                for n in loopVars:gmatch("[%a_][%w_]*") do add(n, "field") end
            end
            local params = line:match("function%s*[%w_%.:]*%s*%(([^)]*)%)")
            if params then
                for n in params:gmatch("[%a_][%w_]*") do add(n, "field") end
            end
        end
        return out
    end

    local function inCommentOrString(line)
        local q
        local i, n = 1, #line
        while i <= n do
            local ch = line:sub(i, i)
            if q then
                if ch == "\\" then
                    i += 1
                elseif ch == q then
                    q = nil
                end
            else
                if ch == "-" and line:sub(i + 1, i + 1) == "-" then return true end
                if ch == "\"" or ch == "'" or ch == "`" then q = ch end
            end
            i += 1
        end
        return q ~= nil
    end

    -- naming something new ("local fo|", "function fo|", "for i|") gets no suggestions
    local function isDeclaring(line, run)
        if line:match("%f[%w_]local%s+$") then
            return ("function"):sub(1, #run) ~= run
        end
        return line:match("%f[%w_]function%s+$") ~= nil or line:match("%f[%w_]for%s+$") ~= nil
    end

    -- ---- popup UI ----------------------------------------------------------
    local Pop = {
        open = false, items = {}, sel = 1, text = "", ws = 0, we = 0, cursor = 0, run = "",
        cx = 0, cy = 0, lh = 16, w = 220, h = 60, token = 0, hold = 0,
        pending = false, suppress = false, mouseOver = false, pressedAt = -10, symbols = nil, lastLen = #CodeInput.Text
    }
    DirectorState.AC = {Holding = function() return os.clock() < Pop.hold end}

    local okGroup, Root = pcall(function() return Instance.new("CanvasGroup") end)
    local isGroup = okGroup and Root ~= nil
    if not isGroup then Root = Instance.new("Frame") end
    Root.Name = "AutocompleteList"
    Root.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Root.BorderSizePixel = 0
    Root.Active = true
    Root.Visible = false
    Root.Size = UDim2.fromOffset(220, 60)
    Root.ZIndex = AC_Z
    Root.Parent = ExecBody
    createCorner(Root, 6)
    createStroke(Root, COLORS.Border, 1, 0.1)

    local List = Instance.new("ScrollingFrame")
    List.Name = "Items"
    List.Position = UDim2.fromOffset(4, 4)
    List.Size = UDim2.new(1, -8, 1, -8)
    List.BackgroundTransparency = 1
    List.BorderSizePixel = 0
    List.ScrollBarThickness = 3
    List.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
    List.ScrollBarImageTransparency = 0.3
    List.ScrollingDirection = Enum.ScrollingDirection.Y
    List.ElasticBehavior = Enum.ElasticBehavior.Never
    List.CanvasSize = UDim2.new(0, 0, 0, 0)
    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
    List.ZIndex = AC_Z + 1
    List.Parent = Root

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = List

    local rows = {}
    local closePopup, setSel, acceptByClick

    local function getRow(i)
        local r = rows[i]
        if r then return r end
        local btn = Instance.new("TextButton")
        btn.Name = "Item"
        btn.LayoutOrder = i
        btn.Size = UDim2.new(1, 0, 0, AC_ROW_H)
        btn.BackgroundColor3 = C.PanelHover
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.ZIndex = AC_Z + 2
        btn.Parent = List
        createCorner(btn, 4)

        local bar = Instance.new("Frame")
        bar.Name = "Bar"
        bar.AnchorPoint = Vector2.new(0, 0.5)
        bar.Position = UDim2.new(0, 0, 0.5, 0)
        bar.Size = UDim2.new(0, 2, 0, 14)
        bar.BackgroundColor3 = COLORS.BrandRed
        bar.BorderSizePixel = 0
        bar.Visible = false
        bar.ZIndex = AC_Z + 3
        bar.Parent = btn

        local holder = Instance.new("Frame")
        holder.Name = "IconHolder"
        holder.AnchorPoint = Vector2.new(0, 0.5)
        holder.Position = UDim2.new(0, 8, 0.5, 0)
        holder.Size = UDim2.new(0, 18, 0, 18)
        holder.BackgroundTransparency = 1
        holder.ZIndex = AC_Z + 3
        holder.Parent = btn

        local label = Instance.new("TextLabel")
        label.Name = "Name"
        label.Position = UDim2.new(0, AC_NAME_X, 0, 0)
        label.Size = UDim2.new(1, -(AC_NAME_X + 6), 1, 0)
        label.BackgroundTransparency = 1
        label.RichText = true
        label.Font = Enum.Font.Code
        label.TextSize = CodeInput.TextSize
        label.TextColor3 = C.Ink
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.ZIndex = AC_Z + 3
        label.Parent = btn

        r = {btn = btn, bar = bar, holder = holder, label = label, kind = nil, icon = nil}
        rows[i] = r

        -- real mouse movement (not a row sliding under a resting cursor) moves the highlight
        btn.MouseMoved:Connect(function()
            Pop.mouseOver = true
            if Pop.sel ~= i then setSel(i, false) end
        end)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Pop.pressedAt = os.clock()
            end
        end)
        btn.Activated:Connect(function()
            acceptByClick(i)
        end)
        return r
    end

    local function richName(name, idx)
        if not idx or #idx == 0 then return name end
        local mark = {}
        for _, p in ipairs(idx) do mark[p] = true end
        local out, open = {}, false
        for i = 1, #name do
            local on = mark[i] == true
            if on and not open then
                out[#out + 1] = "<font color=\"" .. AC_MATCH .. "\">"
                open = true
            elseif open and not on then
                out[#out + 1] = "</font>"
                open = false
            end
            out[#out + 1] = name:sub(i, i)
        end
        if open then out[#out + 1] = "</font>" end
        return table.concat(out)
    end

    setSel = function(i, scrollTo)
        local n = #Pop.items
        if n == 0 then return end
        Pop.sel = i
        for k = 1, n do
            local r = rows[k]
            if r then
                local on = (k == i)
                r.btn.BackgroundTransparency = on and 0 or 1
                r.bar.Visible = on
            end
        end
        if scrollTo then
            local top = (i - 1) * AC_ROW_H
            local view = math.min(n, AC_MAX_ROWS) * AC_ROW_H
            local cp = List.CanvasPosition.Y
            if top < cp then
                List.CanvasPosition = Vector2.new(0, top)
            elseif top + AC_ROW_H > cp + view then
                List.CanvasPosition = Vector2.new(0, top + AC_ROW_H - view)
            end
        end
    end

    local charW = nil
    local charWSize = nil
    local function getCharW()
        local size = CodeInput.TextSize
        if charW and charWSize == size then return charW end
        local v = measure("MMMMMMMMMM", 100000)
        charW = (v and v.X > 0) and (v.X / 10) or size * 0.55
        charWSize = size
        return charW
    end

    local function renderItems()
        local n = #Pop.items
        local longest = 0
        for k = 1, math.max(n, #rows) do
            local item = Pop.items[k]
            if item then
                local r = getRow(k)
                r.btn.Visible = true
                local kd = KIND[item.k]
                if r.kind ~= item.k then
                    if r.icon then r.icon.Root:Destroy() end
                    r.icon = UI.Icon(kd.icon, r.holder, kd.color, 15)
                    r.kind = item.k
                end
                r.label.TextSize = CodeInput.TextSize
                r.label.Text = richName(item.n, item.idx)
                if #item.n > longest then longest = #item.n end
            elseif rows[k] then
                rows[k].btn.Visible = false
            end
        end
        local w = math.clamp(math.floor(longest * (charW or CodeInput.TextSize * 0.55)) + AC_NAME_X + 24, 190, 380)
        Pop.w, Pop.h = w, math.min(n, AC_MAX_ROWS) * AC_ROW_H + 8
        Root.Size = UDim2.fromOffset(Pop.w, Pop.h)
        List.CanvasPosition = Vector2.new(0, 0)
        setSel(1, false)
    end

    -- screen position of the word -> popup position (flips above the line when low on room)
    local function placePopup()
        if not Pop.open then return end
        local ap, win = Scroll.AbsolutePosition, Scroll.AbsoluteWindowSize
        local px = ap.X + PAD_X + Pop.cx - Scroll.CanvasPosition.X
        local rowTop = ap.Y + PAD_TOP + Pop.cy - Scroll.CanvasPosition.Y
        if rowTop + Pop.lh < ap.Y or rowTop > ap.Y + win.Y then
            Root.Visible = false
            return
        end
        local w, h = Pop.w, Pop.h
        local mp, ms = MainFrame.AbsolutePosition, MainFrame.AbsoluteSize
        local x = px - AC_NAME_X - 4
        local y = rowTop + Pop.lh + 4
        if y + h > mp.Y + ms.Y - 6 then
            local above = rowTop - h - 4
            if above >= mp.Y + 6 then y = above end
        end
        x = math.clamp(x, mp.X + 8, math.max(mp.X + ms.X - w - 8, mp.X + 8))
        local ep = ExecBody.AbsolutePosition
        Root.Position = UDim2.fromOffset(x - ep.X, y - ep.Y)
        if not Root.Visible then
            Root.Visible = true
            if isGroup then
                Root.GroupTransparency = 1
                Tween(Root, 0.12, {GroupTransparency = 0})
            end
        end
    end

    closePopup = function()
        Pop.token += 1
        Pop.symbols = nil
        if not Pop.open and not Root.Visible then return end
        Pop.open = false
        Pop.items = {}
        Root.Visible = false
    end

    -- x / row of the start of the word, in editor pixels (yields: text measuring is async)
    local function lastRowCols(line, cols)
        local used, i, n = 0, 1, #line
        while i <= n do
            local s, e = line:find("^%S+", i)
            local isWord = s ~= nil
            if not s then s, e = line:find("^%s+", i) end
            local len = e - s + 1
            if isWord then
                if used > 0 and used + len > cols then used = 0 end
                if len > cols then
                    used = ((len - 1) % cols) + 1
                else
                    used += len
                end
            else
                used += len
                if used > cols then used = used % cols end
            end
            i = e + 1
        end
        return used
    end

    local function caretMetrics(text, ws)
        local before = text:sub(1, ws - 1)
        local lastLine = before:match("([^\n]*)$") or ""
        local one = measure("Ag", 100000)
        local lineH = one and one.Y or CodeInput.TextSize * 1.2
        local cw = getCharW()
        local availW = math.max(CodeInput.AbsoluteSize.X - PAD_X * 2, 40)
        local tall = measure(before .. "|", wrapOn and availW or 100000)
        local bottom = tall and tall.Y or lineH
        local x
        if wrapOn then
            local cols = math.max(math.floor(availW / cw), 1)
            x = lastRowCols(lastLine, cols) * cw
        else
            x = #lastLine * cw
        end
        return x, math.max(bottom - lineH, 0), lineH
    end

    -- ---- the refresh pass ---------------------------------------------------
    local function refresh(allowOpen)
        if not AC_ENABLED or Pop.pending or Pop.suppress then return end
        if not ExecutorFrame.Visible then return closePopup() end
        if not CodeInput:IsFocused() then
            -- pressing a row takes focus away from the box; the click still has to land
            if Pop.open and (Pop.mouseOver or os.clock() - Pop.pressedAt < 0.5) then return end
            return closePopup()
        end
        if not Pop.open and not allowOpen then return end
        getCharW()

        local text = CodeInput.Text
        local cur = CodeInput.CursorPosition
        local selStart = CodeInput.SelectionStart
        if cur < 1 or (selStart ~= -1 and selStart ~= cur) then return closePopup() end

        local tail = text:sub(math.max(1, cur - 200), cur - 1)
        local run = tail:match("[%w_]*$") or ""
        if run:match("^%d") then return closePopup() end
        local ws = cur - #run
        local after = text:sub(cur, cur + 200):match("^[%w_]*") or ""
        local we = cur - 1 + #after

        local preTail = text:sub(math.max(1, ws - 1500), ws - 1)
        local lineBefore = preTail:match("([^\n]*)$") or ""
        local sep = preTail:sub(-1)

        local mode, base = "global", nil
        if preTail:match("GetService%(%s*[\"']$") then
            mode = "service"
        else
            if inCommentOrString(lineBefore) then return closePopup() end
            if (sep == "." or sep == ":") and preTail:sub(-2) ~= ".." then
                mode = "member"
                base = preTail:sub(1, -2):match("([%w_]+)$")
            elseif run == "" or isDeclaring(lineBefore, run) then
                return closePopup()
            end
        end

        local cands
        if mode == "service" then
            cands = SERVICES
        elseif mode == "member" then
            cands = base and MEMBERS[base]
            if not cands then
                if sep == ":" then
                    cands = GEN_METHODS
                elseif run == "" then
                    return closePopup()
                else
                    cands = GEN_ALL
                end
            end
        else
            local symbols
            if Pop.symbols and Pop.ws == ws then
                symbols = Pop.symbols
            else
                local lo, hi = math.max(1, ws - 40000), math.min(#text, we + 40000)
                symbols = scanSymbols(text:sub(lo, ws - 1) .. text:sub(we + 1, hi), run)
            end
            Pop.symbols = symbols
            cands = {}
            for _, it in ipairs(GLOBAL) do cands[#cands + 1] = it end
            for _, it in ipairs(symbols) do cands[#cands + 1] = it end
        end

        local q = run:lower()
        local res = {}
        local methodsOnly = (mode == "member" and sep == ":")
        for _, c in ipairs(cands) do
            if not (methodsOnly and c.k == "field") then
                if q == "" then
                    res[#res + 1] = {n = c.n, k = c.k, ins = c.ins, s = 0}
                else
                    local s, idx = fuzzy(c.n, q, run)
                    if s then
                        if c.doc then s += 30 elseif c.k == "keyword" then s += 10 end
                        res[#res + 1] = {n = c.n, k = c.k, ins = c.ins, s = s, idx = idx}
                    end
                end
            end
        end
        table.sort(res, function(a, b)
            if a.s ~= b.s then return a.s > b.s end
            if q ~= "" and #a.n ~= #b.n then return #a.n < #b.n end
            return a.n < b.n
        end)
        for k = #res, AC_MAX_RESULTS + 1, -1 do res[k] = nil end

        if #res == 0 or (#res == 1 and res[1].n == run) then return closePopup() end

        local sameAnchor = Pop.open and Pop.ws == ws
        Pop.items, Pop.text, Pop.ws, Pop.we, Pop.cursor, Pop.run = res, text, ws, we, cur, run
        renderItems()

        Pop.token += 1
        local my = Pop.token
        if sameAnchor then
            placePopup()
        else
            task.spawn(function()
                local cx, cy, lh = caretMetrics(text, ws)
                if my ~= Pop.token then return end
                Pop.cx, Pop.cy, Pop.lh = cx, cy, lh
                Pop.open = true
                placePopup()
            end)
        end
    end

    -- ---- filling the word ---------------------------------------------------
    local function applyItem(item, text, ws, we)
        local preTail = text:sub(math.max(1, ws - 400), ws - 1)
        local indent = (preTail:match("([^\n]*)$") or ""):match("^%s*") or ""
        local ins = item.ins or item.n
        if item.k == "snippet" then ins = ins:gsub("\n", "\n" .. indent) end
        local at = ins:find("$0", 1, true)
        local caret
        if at then
            ins = ins:sub(1, at - 1) .. ins:sub(at + 2)
            caret = ws + at - 1
        else
            caret = ws + #ins
        end
        local newText = text:sub(1, ws - 1) .. ins .. text:sub(we + 1)
        Pop.suppress = true
        closePopup()
        CodeInput.Text = newText
        task.spawn(function()
            if not CodeInput:IsFocused() then CodeInput:CaptureFocus() end
            CodeInput.CursorPosition = caret
            RunService.Heartbeat:Wait()
            CodeInput.CursorPosition = caret
            task.wait(0.08)
            Pop.suppress = false
        end)
    end

    acceptByClick = function(i)
        local item = Pop.items[i]
        if not item then return end
        if CodeInput.Text ~= Pop.text then
            closePopup()
            return
        end
        applyItem(item, Pop.text, Pop.ws, Pop.we)
    end

    -- Tab / Enter: the box has already typed its own tab or newline, so take that back out
    local function finishKeyAccept(snap)
        local T = CodeInput.Text
        local c = snap.cursor
        if #T == #snap.text + 1 and T:sub(c, c) == snap.stray then
            T = T:sub(1, c - 1) .. T:sub(c + 1)
        end
        if T ~= snap.text then
            closePopup()
            return
        end
        applyItem(snap.item, T, snap.ws, snap.we)
    end

    local inputConn
    inputConn = UserInputService.InputBegan:Connect(function(input)
        if not Root.Parent then
            inputConn:Disconnect()
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if not Pop.open or not Root.Visible or Pop.pending or not CodeInput:IsFocused() then return end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then return end
        local k = input.KeyCode

        local isTab = (k == Enum.KeyCode.Tab)
        local isEnter = (k == Enum.KeyCode.Return or k == Enum.KeyCode.KeypadEnter)
        if isTab or (isEnter and AC_ENTER_ACCEPTS) then
            if isTab and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then return end
            local item = Pop.items[Pop.sel]
            if not item then return end
            -- Enter on a word that is already complete is just a new line
            if isEnter and item.n == Pop.run then
                closePopup()
                return
            end
            Pop.pending = true
            local snap = {
                item = item, text = Pop.text, ws = Pop.ws, we = Pop.we,
                cursor = Pop.cursor, stray = isTab and "\t" or "\n"
            }
            task.spawn(function()
                RunService.Heartbeat:Wait()
                RunService.Heartbeat:Wait()
                local ok = pcall(finishKeyAccept, snap)
                if not ok then closePopup() end
                Pop.pending = false
            end)
        elseif k == Enum.KeyCode.Down or k == Enum.KeyCode.Up then
            local n = #Pop.items
            local nextSel = Pop.sel + (k == Enum.KeyCode.Down and 1 or -1)
            if nextSel < 1 then nextSel = n elseif nextSel > n then nextSel = 1 end
            setSel(nextSel, true)
            -- the box moves its caret on Up/Down too: put it back
            Pop.hold = os.clock() + 0.3
            local keep = Pop.cursor
            task.spawn(function()
                for _ = 1, 2 do
                    RunService.Heartbeat:Wait()
                    if Pop.open and CodeInput.CursorPosition ~= keep then
                        CodeInput.CursorPosition = keep
                    end
                end
            end)
        elseif k == Enum.KeyCode.Escape then
            closePopup()
        end
    end)

    -- ---- wiring -------------------------------------------------------------
    local wantOpen = false
    local refreshTok = 0
    local function schedule(allowOpen)
        if not AC_ENABLED then return end
        wantOpen = wantOpen or allowOpen
        refreshTok += 1
        local my = refreshTok
        task.delay(0.03, function()
            if my ~= refreshTok then return end
            local allow = wantOpen
            wantOpen = false
            refresh(allow)
        end)
    end

    CodeInput:GetPropertyChangedSignal("Text"):Connect(function()
        local len = #CodeInput.Text
        local delta = math.abs(len - Pop.lastLen)
        Pop.lastLen = len
        if Pop.suppress or Pop.pending then return end
        if delta > 2 then
            -- paste, clear, or a different script loaded: never pop up for those
            closePopup()
            return
        end
        schedule(true)
    end)
    CodeInput:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        if os.clock() < Pop.hold then return end
        schedule(false)
    end)
    CodeInput.FocusLost:Connect(function()
        task.delay(0.12, function()
            if CodeInput:IsFocused() then return end
            if Pop.open and (Pop.mouseOver or os.clock() - Pop.pressedAt < 0.5) then return end
            closePopup()
        end)
    end)
    Root.MouseEnter:Connect(function() Pop.mouseOver = true end)
    Root.MouseLeave:Connect(function()
        Pop.mouseOver = false
        -- re-check shortly: moving between the panel and a row can fire a stray leave
        task.delay(0.1, function()
            if Pop.open and not Pop.mouseOver and not CodeInput:IsFocused() then closePopup() end
        end)
    end)
    Root.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Pop.pressedAt = os.clock()
        end
    end)
    Scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(placePopup)
    Scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(closePopup)
    ExecutorFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not ExecutorFrame.Visible then closePopup() end
    end)

    -- ========================================================================
    -- SYNTAX COLORS
    --   The TextBox keeps doing the typing, caret and selection, but its own
    --   text is made invisible. A colored copy of the same text is drawn on
    --   top (a RichText label with identical font, size, padding and wrap),
    --   so every letter lines up with the caret.
    --   Palette = the reference screenshot (VS Code "Dark+").
    -- ========================================================================
    local HL_ENABLED = true        -- false = plain white text like before
    local HL_MAX_CHARS = 50000     -- bigger scripts stay plain so typing stays smooth

    local HL = {
        keyword = "#569CD6",   -- if then end local function return ...
        ident   = "#9CDCFE",   -- variables and properties
        func    = "#DCDCAA",   -- anything followed by (
        string  = "#CE9178",
        number  = "#B5CEA8",
        comment = "#6A9955"
    }
    local HL_DEFAULT = Color3.fromRGB(212, 212, 212)   -- = ( ) . , and other punctuation

    local HL_ESC = {["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ["\""] = "&quot;", ["'"] = "&apos;"}
    local function hlEsc(s)
        return (s:gsub("[&<>\"']", HL_ESC))
    end

    -- colors one line. `st` is "" or "c<n>" / "s<n>": the line starts inside a long
    -- comment / long string whose closing bracket has <n> equals signs.
    -- returns the rich-text line and the state the NEXT line starts in.
    local function hlLine(line, st)
        local out, n = {}, 0
        local plain, pn = {}, 0

        local function flush()
            if pn > 0 then
                n += 1
                out[n] = hlEsc(table.concat(plain, "", 1, pn))
                pn = 0
            end
        end
        local function put(txt, col)
            if txt == "" then return end
            flush()
            n += 1
            out[n] = "<font color=\"" .. col .. "\">" .. hlEsc(txt) .. "</font>"
        end
        local function raw(txt)
            pn += 1
            plain[pn] = txt
        end

        local len = #line
        local i = 1

        if st ~= "" then
            local lvl = tonumber(st:sub(2)) or 0
            local col = (st:sub(1, 1) == "c") and HL.comment or HL.string
            local _, e = line:find("]" .. string.rep("=", lvl) .. "]", 1, true)
            if not e then
                put(line, col)
                return table.concat(out), st
            end
            put(line:sub(1, e), col)
            i = e + 1
            st = ""
        end

        while i <= len do
            local c = line:sub(i, i)
            if c == " " or c == "\t" then
                local ws = line:match("^[ \t]+", i)
                raw(ws)
                i += #ws

            elseif c == "-" and line:sub(i + 1, i + 1) == "-" then
                local eq = line:match("^%-%-%[(=*)%[", i)
                if eq then
                    local _, e = line:find("]" .. eq .. "]", i + 4 + #eq, true)
                    if e then
                        put(line:sub(i, e), HL.comment)
                        i = e + 1
                    else
                        put(line:sub(i), HL.comment)
                        st = "c" .. #eq
                        i = len + 1
                    end
                else
                    put(line:sub(i), HL.comment)
                    i = len + 1
                end

            elseif c == "[" and line:match("^%[=*%[", i) then
                local eq = line:match("^%[(=*)%[", i)
                local _, e = line:find("]" .. eq .. "]", i + 2 + #eq, true)
                if e then
                    put(line:sub(i, e), HL.string)
                    i = e + 1
                else
                    put(line:sub(i), HL.string)
                    st = "s" .. #eq
                    i = len + 1
                end

            elseif c == "\"" or c == "'" or c == "`" then
                local j = i + 1
                while j <= len do
                    local d = line:sub(j, j)
                    if d == "\\" then
                        j += 2
                    elseif d == c then
                        break
                    else
                        j += 1
                    end
                end
                put(line:sub(i, math.min(j, len)), HL.string)
                i = j + 1

            elseif c:match("%d") or (c == "." and line:match("^%.%d", i)) then
                local num = line:match("^0[xX]%x[%x_]*", i)
                    or line:match("^0[bB][01_]+", i)
                    or line:match("^%d[%d_]*%.?%d*[eE][+-]?%d+", i)
                    or line:match("^%d[%d_]*%.?%d*", i)
                    or line:match("^%.%d+", i)
                    or c
                put(num, HL.number)
                i += #num

            elseif c:match("[%a_]") then
                local word = line:match("^[%a_][%w_]*", i)
                local j = i + #word
                if KEYWORD_SET[word] then
                    put(word, HL.keyword)
                elseif line:match("^%s*%(", j) then
                    put(word, HL.func)
                else
                    put(word, HL.ident)
                end
                i = j

            else
                raw(c)
                i += 1
            end
        end

        flush()
        return table.concat(out), st
    end

    -- whole text, line by line. Lines that did not change are looked up, not re-colored,
    -- so a keystroke only costs one line of work.
    local hlRich, hlState, hlCount = {}, {}, 0
    local function highlightText(text)
        local lines = string.split(text, "\n")
        local out = table.create(#lines)
        local st = ""
        for i = 1, #lines do
            local line = lines[i]
            local key = (st == "") and line or (st .. "\1" .. line)
            local rich = hlRich[key]
            if rich then
                st = hlState[key]
            else
                local ns
                rich, ns = hlLine(line, st)
                if hlCount > 6000 then
                    hlRich, hlState, hlCount = {}, {}, 0
                end
                hlRich[key], hlState[key] = rich, ns
                hlCount += 1
                st = ns
            end
            out[i] = rich
        end
        return table.concat(out, "\n")
    end

    local HLLabel = Instance.new("TextLabel")
    HLLabel.Name = "SyntaxColors"
    HLLabel.BackgroundTransparency = 1
    HLLabel.BorderSizePixel = 0
    HLLabel.Size = UDim2.new(1, 0, 1, 0)   -- fills the padded text area of the box
    HLLabel.RichText = true
    HLLabel.Font = CodeInput.Font
    HLLabel.TextSize = CodeInput.TextSize
    HLLabel.TextColor3 = HL_DEFAULT
    HLLabel.TextXAlignment = Enum.TextXAlignment.Left
    HLLabel.TextYAlignment = Enum.TextYAlignment.Top
    HLLabel.TextWrapped = CodeInput.TextWrapped
    HLLabel.Text = ""
    HLLabel.Visible = false
    HLLabel.Parent = CodeInput

    local function plainMode()
        HLLabel.Visible = false
        CodeInput.TextTransparency = 0
    end

    local function applyHighlight()
        local text = CodeInput.Text
        if not HL_ENABLED or #text > HL_MAX_CHARS then
            plainMode()
            return
        end
        local rich = highlightText(text)
        if #rich > 180000 then
            plainMode()
            return
        end
        HLLabel.Text = rich
        HLLabel.Visible = true
        CodeInput.TextTransparency = 1
    end

    local function safeHighlight()
        local ok = pcall(applyHighlight)
        if not ok then plainMode() end
    end

    CodeInput:GetPropertyChangedSignal("Text"):Connect(safeHighlight)
    CodeInput:GetPropertyChangedSignal("TextWrapped"):Connect(function()
        HLLabel.TextWrapped = CodeInput.TextWrapped
    end)
    CodeInput:GetPropertyChangedSignal("TextSize"):Connect(function()
        HLLabel.TextSize = CodeInput.TextSize
    end)
    safeHighlight()

    -- ========================================================================
    -- wiring
    -- ========================================================================
    local lastTab = currentDirectorTab()
    CodeInput:GetPropertyChangedSignal("Text"):Connect(function()
        local now = currentDirectorTab()
        if now ~= lastTab then
            lastTab = now
            Scroll.CanvasPosition = Vector2.new(0, 0)
        end
        queueDirectorAutosave()
        updateStats()
        refreshGutter()
        followCursor()
    end)
    CodeInput:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        if DirectorState.AC and DirectorState.AC.Holding() then return end
        updateStats()
        followCursor()
    end)

    CodeInput.Focused:Connect(function()
        Tween(ShellStroke, 0.15, {Color = COLORS.White, Transparency = 0.1})
    end)
    CodeInput.FocusLost:Connect(function()
        Tween(ShellStroke, 0.15, {Color = COLORS.Border, Transparency = 0.2})
    end)

    Scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        syncMinSize()
        refreshGutter()
    end)
    CodeInput:GetPropertyChangedSignal("TextSize"):Connect(refreshGutter)
    ExecutorFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if ExecutorFrame.Visible then
            task.defer(function()
                syncMinSize()
                refreshGutter()
            end)
        end
    end)

    applyWrap(Settings.DirectorWrap ~= false)
    updateStats()
    paintStatus()
    refreshDirectorTabButtons()
end)()

local CreditsFrame = Instance.new("Frame")
local CreditsBigN
do
    CreditsFrame.Name = "CreditsFrame"
    CreditsFrame.Size = UDim2.new(1, 0, 1, -52)
    CreditsFrame.Position = UDim2.new(0, 0, 0, 52)
    CreditsFrame.BackgroundTransparency = 1
    CreditsFrame.Visible = false
    CreditsFrame.Parent = MainFrame

    local CreditsContent = Instance.new("Frame")
    CreditsContent.Name = "CreditsContent"
    CreditsContent.Size = UDim2.new(1, -36, 1, -24)
    CreditsContent.Position = UDim2.new(0, 18, 0, 12)
    CreditsContent.BackgroundTransparency = 1
    CreditsContent.Parent = CreditsFrame

    local CreditsLogo = Instance.new("ImageLabel")
    CreditsLogo.Name = "CreditsLogo"
    CreditsLogo.Size = UDim2.new(0, 120, 0, 120)
    CreditsLogo.Position = UDim2.new(0.5, -60, 0.05, 0)
    CreditsLogo.BackgroundTransparency = 1
    CreditsLogo.Parent = CreditsContent
    LoadImageAsync(CreditsLogo, IMAGE_URLS.IntroLogo)

    CreditsBigN = Instance.new("TextLabel")
    CreditsBigN.Size = UDim2.new(1, 0, 0, 60)
    CreditsBigN.Position = UDim2.new(0, 0, 0.05, 120)
    CreditsBigN.BackgroundTransparency = 1
    CreditsBigN.Text = "AN UNIVERSAL"
    CreditsBigN.TextColor3 = COLORS.BrandRed
    CreditsBigN.Font = FONTS.Heavy
    CreditsBigN.TextSize = 48
    CreditsBigN.Parent = CreditsContent

    local AuthorTitle = Instance.new("TextLabel")
    AuthorTitle.Size = UDim2.new(1, 0, 0, 30)
    AuthorTitle.Position = UDim2.new(0, 0, 0.05, 180)
    AuthorTitle.BackgroundTransparency = 1
    AuthorTitle.Text = "Created by: noli_0"
    AuthorTitle.TextColor3 = COLORS.White
    AuthorTitle.Font = FONTS.Bold
    AuthorTitle.TextSize = 18
    AuthorTitle.Parent = CreditsContent

    local CoFounderTitle = Instance.new("TextLabel")
    CoFounderTitle.Size = UDim2.new(1, 0, 0, 30)
    CoFounderTitle.Position = UDim2.new(0, 0, 0.05, 210)
    CoFounderTitle.BackgroundTransparency = 1
    CoFounderTitle.Text = "Co-Founder: thats_carvs"
    CoFounderTitle.TextColor3 = COLORS.White
    CoFounderTitle.Font = FONTS.Bold
    CoFounderTitle.TextSize = 16
    CoFounderTitle.Parent = CreditsContent

    local CreditsDescription = Instance.new("TextLabel")
    CreditsDescription.Size = UDim2.new(1, 0, 0, 40)
    CreditsDescription.Position = UDim2.new(0, 0, 0.05, 250)
    CreditsDescription.BackgroundTransparency = 1
    CreditsDescription.Text = "Everything is created with blood sweat and tears twim"
    CreditsDescription.TextColor3 = COLORS.GreyMuted
    CreditsDescription.Font = FONTS.Medium
    CreditsDescription.TextSize = 13
    CreditsDescription.Parent = CreditsContent
end

local AdminFrame
local AdminCodeInput
local PlayersScroll

if IsAdmin(LocalPlayer.UserId) then
    AdminFrame = Instance.new("Frame")
    AdminFrame.Name = "AdminFrame"
    AdminFrame.Size = UDim2.new(1, 0, 1, -52)
    AdminFrame.Position = UDim2.new(0, 0, 0, 52)
    AdminFrame.BackgroundTransparency = 1
    AdminFrame.Visible = false
    AdminFrame.Parent = MainFrame

    local AdminBody = Instance.new("Frame")
    AdminBody.Size = UDim2.new(1, -36, 1, -24)
    AdminBody.Position = UDim2.new(0, 18, 0, 12)
    AdminBody.BackgroundTransparency = 1
    AdminBody.Parent = AdminFrame
    
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Size = UDim2.new(0.48, 0, 1, -55)
    LeftPanel.Position = UDim2.new(0, 0, 0, 0)
    LeftPanel.BackgroundTransparency = 1
    LeftPanel.Parent = AdminBody

    local CommandsTitle = Instance.new("TextLabel")
    CommandsTitle.Size = UDim2.new(1, 0, 0, 20)
    CommandsTitle.BackgroundTransparency = 1
    CommandsTitle.Text = "Command List"
    CommandsTitle.Font = FONTS.Bold
    CommandsTitle.TextSize = 14
    CommandsTitle.TextColor3 = COLORS.White
    CommandsTitle.TextXAlignment = Enum.TextXAlignment.Left
    CommandsTitle.Parent = LeftPanel

    local CommandsScroll = Instance.new("ScrollingFrame")
    CommandsScroll.Size = UDim2.new(1, 0, 1, -25)
    CommandsScroll.Position = UDim2.new(0, 0, 0, 25)
    CommandsScroll.BackgroundColor3 = COLORS.DarkCard
    CommandsScroll.BorderSizePixel = 0
    CommandsScroll.ScrollBarThickness = 4
    CommandsScroll.ScrollBarImageColor3 = COLORS.BrandRed
    CommandsScroll.Parent = LeftPanel
    createCorner(CommandsScroll, 6)
    createStroke(CommandsScroll, COLORS.Border, 1)

    local CLayout = Instance.new("UIListLayout")
    CLayout.Padding = UDim.new(0, 5)
    CLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CLayout.Parent = CommandsScroll

    local CPadding = Instance.new("UIPadding")
    CPadding.PaddingTop = UDim.new(0, 5)
    CPadding.PaddingLeft = UDim.new(0, 5)
    CPadding.PaddingRight = UDim.new(0, 5)
    CPadding.PaddingBottom = UDim.new(0, 5)
    CPadding.Parent = CommandsScroll

    CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        CommandsScroll.CanvasSize = UDim2.new(0, 0, 0, CLayout.AbsoluteContentSize.Y + 10)
    end)

    local cmds = {
        "/Kill [name/all]",
        "/Kick [name/all]",
        "/Bring [name/all]",
        "/Fling [name/all]",
        "/Loopkill [name/all]",
        "/Unloopkill [name/all]",
        "/Explode [name/all]",
        "/Spin [name/all]",
        "/Unspin [name/all]",
        "/Freeze [name/all]",
        "/Thaw [name/all]",
        "/Jump [name/all]",
        "/Sit [name/all]",
        "/Speed [name/all] [val]",
        "/ban [name] [reason] [duration]",
        "/unban [name]"
    }

    for _, cmdStr in ipairs(cmds) do
        local cLbl = Instance.new("TextLabel")
        cLbl.Size = UDim2.new(1, -5, 0, 30)
        cLbl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        cLbl.Text = " " .. cmdStr
        cLbl.TextColor3 = COLORS.GreyLight
        cLbl.Font = FONTS.Medium
        cLbl.TextSize = 12
        cLbl.TextXAlignment = Enum.TextXAlignment.Left
        cLbl.Parent = CommandsScroll
        createCorner(cLbl, 4)
        createStroke(cLbl, COLORS.Border, 1, 0.5)
    end

    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(0.48, 0, 1, -55)
    RightPanel.Position = UDim2.new(0.52, 0, 0, 0)
    RightPanel.BackgroundTransparency = 1
    RightPanel.Parent = AdminBody

    local PlayersTitle = Instance.new("TextLabel")
    PlayersTitle.Size = UDim2.new(1, 0, 0, 20)
    PlayersTitle.BackgroundTransparency = 1
    PlayersTitle.Text = "Active Users (Click to copy ID)"
    PlayersTitle.Font = FONTS.Bold
    PlayersTitle.TextSize = 14
    PlayersTitle.TextColor3 = COLORS.BrandRed
    PlayersTitle.TextXAlignment = Enum.TextXAlignment.Left
    PlayersTitle.Parent = RightPanel

    PlayersScroll = Instance.new("ScrollingFrame")
    PlayersScroll.Size = UDim2.new(1, 0, 1, -25)
    PlayersScroll.Position = UDim2.new(0, 0, 0, 25)
    PlayersScroll.BackgroundColor3 = COLORS.DarkCard
    PlayersScroll.BorderSizePixel = 0
    PlayersScroll.ScrollBarThickness = 4
    PlayersScroll.ScrollBarImageColor3 = COLORS.BrandRed
    PlayersScroll.Parent = RightPanel
    createCorner(PlayersScroll, 6)
    createStroke(PlayersScroll, COLORS.Border, 1)

    local PLayout = Instance.new("UIListLayout")
    PLayout.Padding = UDim.new(0, 5)
    PLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PLayout.Parent = PlayersScroll

    local PPadding = Instance.new("UIPadding")
    PPadding.PaddingTop = UDim.new(0, 5)
    PPadding.PaddingLeft = UDim.new(0, 5)
    PPadding.PaddingRight = UDim.new(0, 5)
    PPadding.PaddingBottom = UDim.new(0, 5)
    PPadding.Parent = PlayersScroll

    PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PlayersScroll.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y + 10)
    end)

    AdminCodeInput = Instance.new("TextBox")
    AdminCodeInput.Size = UDim2.new(1, 0, 0, 45)
    AdminCodeInput.Position = UDim2.new(0, 0, 1, -45)
    AdminCodeInput.BackgroundColor3 = COLORS.DarkCard
    AdminCodeInput.Text = ""
    AdminCodeInput.PlaceholderText = "Enter command here and hit enter..."
    AdminCodeInput.TextColor3 = COLORS.White
    AdminCodeInput.Font = FONTS.Medium
    AdminCodeInput.TextSize = 15
    AdminCodeInput.TextXAlignment = Enum.TextXAlignment.Left
    AdminCodeInput.ClearTextOnFocus = true
    AdminCodeInput.Parent = AdminBody
    createCorner(AdminCodeInput, 6)
    createStroke(AdminCodeInput, COLORS.Border, 1)

    local AdminPadding = Instance.new("UIPadding")
    AdminPadding.PaddingTop = UDim.new(0, 10)
    AdminPadding.PaddingLeft = UDim.new(0, 10)
    AdminPadding.PaddingRight = UDim.new(0, 10)
    AdminPadding.PaddingBottom = UDim.new(0, 10)
    AdminPadding.Parent = AdminCodeInput

    AdminCodeInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and AdminCodeInput.Text ~= "" then
            local text = AdminCodeInput.Text
            local TextChatService = game:GetService("TextChatService")
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                TextChatService.TextChannels.RBXGeneral:SendAsync(text)
            else
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
            end
            AdminCodeInput.Text = ""
        end
    end)
end

local function ExecuteCommandEffect(speaker, targetPlayer, cmd, args)
    if targetPlayer ~= LocalPlayer then return end
    if cmd == "/kill" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    elseif cmd == "/kick" then
        LocalPlayer:Kick("You have been kicked by an AN Administrator.")
    elseif cmd == "/bring" then
        if speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = speaker.Character.HumanoidRootPart.CFrame
        end
    elseif cmd == "/fling" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(math.random(-10000, 10000), 10000, math.random(-10000, 10000))
            bv.Parent = hrp
            task.delay(0.5, function() bv:Destroy() end)
        end
    elseif cmd == "/loopkill" then
        LoopKillTargets[LocalPlayer.UserId] = not LoopKillTargets[LocalPlayer.UserId]
    elseif cmd == "/explode" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local exp = Instance.new("Explosion")
            exp.Position = LocalPlayer.Character.HumanoidRootPart.Position
            exp.Parent = workspace
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end
    elseif cmd == "/spin" then
        SpinTargets[LocalPlayer.UserId] = not SpinTargets[LocalPlayer.UserId]
    elseif cmd == "/freeze" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = true
            createIceCube(LocalPlayer.Character)
        end
    elseif cmd == "/thaw" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
            removeIceCube()
        end
    elseif cmd == "/unspin" then
        SpinTargets[LocalPlayer.UserId] = nil
    elseif cmd == "/unloopkill" then
        LoopKillTargets[LocalPlayer.UserId] = nil
    elseif cmd == "/jump" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    elseif cmd == "/sit" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Sit = true
        end
    elseif cmd == "/speed" then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[3]) or 16
        end
    end
end

local function ShowCommandRequestNotification(requesterPlayer, cmd, args)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 360, 0, 115)
    NotifFrame.Position = UDim2.new(0.5, -180, 0, -130)
    NotifFrame.BackgroundColor3 = COLORS.DarkBack
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ZIndex = 300
    NotifFrame.Parent = ScreenGui
    createCorner(NotifFrame, 8)
    createStroke(NotifFrame, COLORS.BrandRed, 2)
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -40, 0, 26)
    TitleLbl.Position = UDim2.new(0, 12, 0, 6)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "⚠️ COMMAND PERMISSION REQUEST"
    TitleLbl.TextColor3 = COLORS.BrandRed
    TitleLbl.Font = FONTS.Heavy
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 301
    TitleLbl.Parent = NotifFrame
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -30, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = COLORS.White
    CloseBtn.Font = FONTS.Bold
    CloseBtn.TextSize = 16
    CloseBtn.ZIndex = 301
    CloseBtn.Parent = NotifFrame
    createCorner(CloseBtn, 12)
    BindInteractionSounds(CloseBtn)
    
    local DescLbl = Instance.new("TextLabel")
    DescLbl.Size = UDim2.new(1, -24, 0, 32)
    DescLbl.Position = UDim2.new(0, 12, 0, 32)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = string.format("%s (@%s) asks if they can %s you", requesterPlayer.DisplayName, requesterPlayer.Name, cmd)
    DescLbl.TextColor3 = COLORS.White
    DescLbl.Font = FONTS.Medium
    DescLbl.TextSize = 12
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.TextWrapped = true
    DescLbl.ZIndex = 301
    DescLbl.Parent = NotifFrame
    
    local AcceptBtn = Instance.new("TextButton")
    AcceptBtn.Size = UDim2.new(0.45, 0, 0, 30)
    AcceptBtn.Position = UDim2.new(0, 12, 0, 70)
    AcceptBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
    AcceptBtn.Text = "Accept"
    AcceptBtn.TextColor3 = COLORS.White
    AcceptBtn.Font = FONTS.Bold
    AcceptBtn.TextSize = 12
    AcceptBtn.ZIndex = 301
    AcceptBtn.Parent = NotifFrame
    createCorner(AcceptBtn, 4)
    BindInteractionSounds(AcceptBtn)
    
    local RejectBtn = Instance.new("TextButton")
    RejectBtn.Size = UDim2.new(0.45, 0, 0, 30)
    RejectBtn.Position = UDim2.new(0.5, 5, 0, 70)
    RejectBtn.BackgroundColor3 = Color3.fromRGB(198, 40, 40)
    RejectBtn.Text = "Reject"
    RejectBtn.TextColor3 = COLORS.White
    RejectBtn.Font = FONTS.Bold
    RejectBtn.TextSize = 12
    RejectBtn.ZIndex = 301
    RejectBtn.Parent = NotifFrame
    createCorner(RejectBtn, 4)
    BindInteractionSounds(RejectBtn)
    
    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, 0, 0, 4)
    BarBg.Position = UDim2.new(0, 0, 1, -4)
    BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BarBg.BorderSizePixel = 0
    BarBg.ZIndex = 301
    BarBg.Parent = NotifFrame
    
    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(1, 0, 1, 0)
    BarFill.BackgroundColor3 = COLORS.BrandRed
    BarFill.BorderSizePixel = 0
    BarFill.ZIndex = 302
    BarFill.Parent = BarBg
    
    PlaySoundAsync(SOUND_URLS.Intro, "Intro", 0.6)
    
    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -180, 0, 20)
    }):Play()
    
    local duration = 12
    local drainTween = TweenService:Create(BarFill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 1, 0)
    })
    drainTween:Play()
    
    local isClosed = false
    local function closeNotif()
        if isClosed then return end
        isClosed = true
        drainTween:Cancel()
        local outTween = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -180, 0, -130)
        })
        outTween:Play()
        outTween.Completed:Wait()
        if NotifFrame then NotifFrame:Destroy() end
    end
    
    CloseBtn.MouseButton1Click:Connect(closeNotif)
    RejectBtn.MouseButton1Click:Connect(closeNotif)
    AcceptBtn.MouseButton1Click:Connect(function()
        ExecuteCommandEffect(requesterPlayer, LocalPlayer, cmd, args)
        closeNotif()
    end)
    
    task.delay(duration, function()
        if not isClosed then
            closeNotif()
        end
    end)
end

local function HandleAdminCommand(speaker, message)
    if not IsAdmin(speaker.UserId) then return end
    
    local args = string.split(message, " ")
    local cmd = string.lower(args[1])
    local targetStr = args[2]

    if cmd == "/ban" then
        if GetUserRank(speaker.UserId) < 2 then return end
        local targetName = args[2]
        if not targetName then return end
        
        local durationStr = args[#args]
        local reasonArgs = {}
        
        for i = 3, #args - 1 do
            table.insert(reasonArgs, args[i])
        end
        
        local reasonStr = table.concat(reasonArgs, " ")
        if reasonStr == "" then reasonStr = "Banned via Admin Panel" end
        
        local targetUserId
        for _, p in ipairs(Players:GetPlayers()) do
            if string.lower(p.Name) == string.lower(targetName) or string.lower(p.DisplayName) == string.lower(targetName) then
                targetUserId = p.UserId
                break
            end
        end
        
        if not targetUserId then
            pcall(function()
                targetUserId = Players:GetUserIdFromNameAsync(targetName)
            end)
        end
        
        if targetUserId then
            if GetUserRank(speaker.UserId) <= GetUserRank(targetUserId) and GetUserRank(speaker.UserId) < 4 then return end
            local length = parseDuration(durationStr)
            local expireTime = (length == -1) and -1 or (os.time() + length)
            local payload = HttpService:JSONEncode({
                expires = expireTime,
                banned_by = speaker.Name,
                reason = reasonStr,
                username = targetName
            })
            
            task.spawn(function()
                if http_request then
                    http_request({
                        Url = BASE_URL .. "blacklist/" .. targetUserId .. ".json",
                        Method = "PUT",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = payload
                    })
                    print("AN Hub: Successfully banned User ID " .. targetUserId)
                end
            end)
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p.UserId == targetUserId then
                    p:Kick("You have been banned.\nReason: " .. reasonStr)
                end
            end
        else
            warn("AN Hub: Could not resolve username to UserId.")
        end
        return
    end

    if cmd == "/unban" then
        if GetUserRank(speaker.UserId) < 2 then return end
        local targetName = args[2]
        if not targetName then return end
        
        local targetUserId
        pcall(function()
            targetUserId = Players:GetUserIdFromNameAsync(targetName)
        end)
        
        if targetUserId then
            task.spawn(function()
                if http_request then
                    http_request({
                        Url = BASE_URL .. "blacklist/" .. targetUserId .. ".json",
                        Method = "DELETE"
                    })
                    print("AN Hub: Successfully unbanned User ID " .. targetUserId)
                end
            end)
        end
        return
    end
    
    if targetStr then
        local speakerRank = GetUserRank(speaker.UserId)
        local targetPlayers = {}
        
        if string.lower(targetStr) == "all" then
            for _, p in ipairs(Players:GetPlayers()) do
                table.insert(targetPlayers, p)
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                local pName = string.lower(p.Name)
                local pDisplay = string.lower(p.DisplayName)
                local tStr = string.lower(targetStr)
                if string.sub(pName, 1, #tStr) == tStr or string.sub(pDisplay, 1, #tStr) == tStr then
                    table.insert(targetPlayers, p)
                end
            end
        end
        
        for _, targetPlayer in ipairs(targetPlayers) do
            local targetRank = GetUserRank(targetPlayer.UserId)
            if speakerRank == 4 or speakerRank >= targetRank then
                ExecuteCommandEffect(speaker, targetPlayer, cmd, args)
            else
                if targetPlayer == LocalPlayer then
                    ShowCommandRequestNotification(speaker, cmd, args)
                end
            end
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(msg) HandleAdminCommand(p, msg) end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(msg) HandleAdminCommand(p, msg) end)
end)

local SettingsFrame = Instance.new("Frame")
local SettingsScroll = Instance.new("ScrollingFrame")
local SettingsLayout = Instance.new("UIListLayout")
local FBInput = Instance.new("TextBox")
local FBSubmitBtn = Instance.new("TextButton")
local TagToggleBtn
local JoinIdBox = Instance.new("TextBox")
local HexInput = Instance.new("TextBox")
local updateOverheadVisibility

do
    -- ------------------------------------------------------------------------
    -- SETTINGS PAGE
    --   grouped sections (one card per group, hairline dividers between rows),
    --   a title + one-line help for every setting, real on/off switches,
    --   and controls that drop below the text on narrow (mobile) windows.
    --   Everything is kept in the SUI table so this block adds almost no locals.
    -- ------------------------------------------------------------------------
    local SUI = {sw = {}, syncs = {}, swatches = {}, card = {}}
    AN_ENV.AN_SettingsUI = SUI

    SUI.btnH = isMobile() and 40 or 32
    SUI.narrow = MainFrame.Size.X.Offset < 560
    SUI.hoverRow = Color3.fromRGB(32, 32, 32)
    SUI.fieldBg = Color3.fromRGB(15, 15, 15)
    SUI.neutral = Color3.fromRGB(44, 44, 44)
    SUI.neutralHover = Color3.fromRGB(60, 60, 60)
    SUI.offTrack = Color3.fromRGB(62, 62, 62)
    SUI.dangerText = Color3.fromRGB(235, 130, 130)

    function SUI.make(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end

    function SUI.text(parent, text, font, size, color, pos, siz)
        return SUI.make("TextLabel", {
            BackgroundTransparency = 1, Text = text, Font = font, TextSize = size, TextColor3 = color,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd, Position = pos, Size = siz
        }, parent)
    end

    function SUI.tween(obj, t, props)
        TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    function SUI.pad(parent, t, r, b, l)
        return SUI.make("UIPadding", {
            PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r),
            PaddingBottom = UDim.new(0, b), PaddingLeft = UDim.new(0, l)
        }, parent)
    end

    -- puts a short message on a button, then puts the old text back
    function SUI.flash(btn, text, dur)
        local orig = btn:GetAttribute("OrigText") or btn.Text
        btn:SetAttribute("OrigText", orig)
        btn.Text = text
        task.delay(dur or 1.4, function()
            if btn.Parent then btn.Text = orig end
        end)
    end

    -- ---- page frame ---------------------------------------------------------
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Size = UDim2.new(1, 0, 1, -52)
    SettingsFrame.Position = UDim2.new(0, 0, 0, 52)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Visible = false
    SettingsFrame.Parent = MainFrame

    SettingsScroll.Name = "SettingsScroll"
    SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
    SettingsScroll.Position = UDim2.new(0, 0, 0, 0)
    SettingsScroll.BackgroundTransparency = 1
    SettingsScroll.BorderSizePixel = 0
    SettingsScroll.ScrollBarThickness = 4
    SettingsScroll.ScrollBarImageColor3 = COLORS.BrandRed
    SettingsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SettingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SettingsScroll.Parent = SettingsFrame
    if SUI.narrow then SUI.pad(SettingsScroll, 12, 12, 20, 12) else SUI.pad(SettingsScroll, 18, 20, 28, 18) end

    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsLayout.Padding = UDim.new(0, 18)
    SettingsLayout.Parent = SettingsScroll

    -- ---- building blocks ----------------------------------------------------
    function SUI.section(title, order)
        local wrap = SUI.make("Frame", {
            Name = "Section_" .. title, BackgroundTransparency = 1, LayoutOrder = order,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        }, SettingsScroll)
        SUI.make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}, wrap)
        local head = SUI.text(wrap, string.upper(title), FONTS.Bold, 11, COLORS.GreyMuted, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 14))
        head.LayoutOrder = 1
        SUI.pad(head, 0, 0, 0, 4)
        local card = SUI.make("Frame", {
            Name = "Card", BackgroundColor3 = COLORS.DarkCard, BorderSizePixel = 0, ClipsDescendants = true,
            LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
        }, wrap)
        createCorner(card, 8)
        createStroke(card, COLORS.Border, 1, 0.4)
        SUI.make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, card)
        SUI.card[title] = card
        return card
    end

    -- one row: title + help on the left, controls on the right (or underneath when narrow)
    -- returns the row, and the container the controls go into
    function SUI.row(card, title, desc, opts)
        opts = opts or {}
        local n = (card:GetAttribute("n") or 0) + 1
        card:SetAttribute("n", n)
        local stacked = opts.stack and SUI.narrow
        local h = opts.height or (stacked and (58 + SUI.btnH + 14) or 62)
        local row = SUI.make(opts.clickable and "TextButton" or "Frame", {
            Name = "Row", LayoutOrder = n, BorderSizePixel = 0,
            BackgroundColor3 = SUI.hoverRow, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, h)
        }, card)
        if opts.clickable then
            row.Text = ""
            row.AutoButtonColor = false
            row.MouseEnter:Connect(function() SUI.tween(row, 0.12, {BackgroundTransparency = 0}) end)
            row.MouseLeave:Connect(function() SUI.tween(row, 0.12, {BackgroundTransparency = 1}) end)
            BindInteractionSounds(row)
        end
        if n > 1 then
            SUI.make("Frame", {
                Name = "Divider", BackgroundColor3 = COLORS.Border, BackgroundTransparency = 0.25,
                BorderSizePixel = 0, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -32, 0, 1)
            }, row)
        end
        local reserve = (stacked or opts.noControls) and 32 or ((opts.ctrlW or 150) + 40)
        SUI.text(row, title, FONTS.Bold, 14, COLORS.White, UDim2.new(0, 16, 0, desc and 12 or (h - 18) / 2), UDim2.new(1, -reserve, 0, 18))
        if desc then
            local d = SUI.text(row, desc, FONTS.Book, 12, COLORS.GreyMuted, UDim2.new(0, 16, 0, 32), UDim2.new(1, -reserve, 0, 16))
            if opts.noControls then
                -- long help text wraps instead of being cut off
                d.TextWrapped = true
                d.TextTruncate = Enum.TextTruncate.None
                d.TextYAlignment = Enum.TextYAlignment.Top
                d.Size = UDim2.new(1, -reserve, 0, 30)
            end
        end
        if opts.noControls then return row end

        local ctl = SUI.make("Frame", {Name = "Controls", BackgroundTransparency = 1}, row)
        if stacked then
            ctl.Position = UDim2.new(0, 16, 0, 58)
            ctl.Size = UDim2.new(1, -32, 0, SUI.btnH)
        else
            ctl.AnchorPoint = Vector2.new(1, 0.5)
            ctl.Position = UDim2.new(1, -16, 0.5, 0)
            ctl.Size = UDim2.new(0, opts.ctrlW or 150, 0, SUI.btnH)
        end
        SUI.make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        }, ctl)
        return row, ctl
    end

    -- kind: "default" | "primary" | "danger". `existing` lets an already-declared button be styled.
    function SUI.button(parent, text, kind, w, existing)
        kind = kind or "default"
        local btn = existing or Instance.new("TextButton")
        btn.Text = text
        btn.Font = FONTS.Bold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(0, w or 88, 0, SUI.btnH)
        local function rest()
            if kind == "primary" then return COLORS.BrandRed end
            if kind == "danger" then return Color3.fromRGB(46, 30, 30) end
            return SUI.neutral
        end
        local function hover()
            if kind == "primary" then return COLORS.BrandRed:Lerp(Color3.new(1, 1, 1), 0.15) end
            if kind == "danger" then return Color3.fromRGB(70, 34, 34) end
            return SUI.neutralHover
        end
        btn.BackgroundColor3 = rest()
        btn.TextColor3 = (kind == "danger") and SUI.dangerText or COLORS.White
        btn.Parent = parent
        createCorner(btn, 6)
        if kind ~= "primary" then
            createStroke(btn, kind == "danger" and Color3.fromRGB(90, 44, 44) or Color3.fromRGB(58, 58, 58), 1, 0)
        end
        BindInteractionSounds(btn)
        -- the spam lock and the "Sent!" flash recolour the Submit button themselves
        local function frozen() return btn.Text == "Locked" or btn.Text == "Sent!" end
        btn.MouseEnter:Connect(function()
            if not frozen() then SUI.tween(btn, 0.12, {BackgroundColor3 = hover()}) end
        end)
        btn.MouseLeave:Connect(function()
            if not frozen() then SUI.tween(btn, 0.12, {BackgroundColor3 = rest()}) end
        end)
        return btn
    end

    function SUI.field(box, w)
        box.BackgroundColor3 = SUI.fieldBg
        box.BorderSizePixel = 0
        box.Font = FONTS.Medium
        box.TextSize = 12
        box.TextColor3 = COLORS.White
        box.PlaceholderColor3 = COLORS.GreyMuted
        box.ClearTextOnFocus = false
        if w then box.Size = w end
        createCorner(box, 6)
        local stroke = createStroke(box, COLORS.Border, 1, 0)
        box.Focused:Connect(function() SUI.tween(stroke, 0.12, {Color = COLORS.BrandRed}) end)
        box.FocusLost:Connect(function() SUI.tween(stroke, 0.12, {Color = COLORS.Border}) end)
        return stroke
    end

    -- whole row is the click target; the switch is drawn inside it
    function SUI.switchRow(card, title, desc, initial)
        local btn = SUI.row(card, title, desc, {clickable = true, ctrlW = 96})
        local track = SUI.make("Frame", {
            Name = "Track", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.new(0, 44, 0, 24), BorderSizePixel = 0,
            BackgroundColor3 = initial and COLORS.BrandRed or SUI.offTrack
        }, btn)
        createCorner(track, 12)
        local knob = SUI.make("Frame", {
            Name = "Knob", AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 18, 0, 18),
            BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
            Position = initial and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        }, track)
        createCorner(knob, 9)
        local state = SUI.text(btn, initial and "On" or "Off", FONTS.Bold, 12,
            initial and COLORS.White or COLORS.GreyMuted, UDim2.new(1, -68, 0.5, 0), UDim2.new(0, 34, 0, 18))
        state.AnchorPoint = Vector2.new(1, 0.5)
        state.TextXAlignment = Enum.TextXAlignment.Right
        SUI.sw[btn] = {track = track, knob = knob, state = state}
        return btn
    end

    function SUI.setSwitch(btn, on, instant)
        local r = SUI.sw[btn]
        if not r then return end
        local trackColor = on and COLORS.BrandRed or SUI.offTrack
        local knobPos = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        r.state.Text = on and "On" or "Off"
        r.state.TextColor3 = on and COLORS.White or COLORS.GreyMuted
        if instant then
            r.track.BackgroundColor3 = trackColor
            r.knob.Position = knobPos
        else
            SUI.tween(r.track, 0.18, {BackgroundColor3 = trackColor})
            SUI.tween(r.knob, 0.18, {Position = knobPos})
        end
    end

    function SUI.syncSwatches()
        local cur = string.lower(CurrentThemeHex or "")
        for _, s in ipairs(SUI.swatches) do
            s.ring.Transparency = (string.lower(s.color:ToHex()) == cur) and 0 or 1
        end
    end

    -- ---- page header ----------------------------------------------------------
    local header = SUI.make("Frame", {
        Name = "PageHeader", BackgroundTransparency = 1, LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 48)
    }, SettingsScroll)
    SUI.text(header, "Settings", FONTS.Bold, 22, COLORS.White, UDim2.new(0, 2, 0, 0), UDim2.new(1, -4, 0, 28))
    SUI.text(header, "Preferences, tools and appearance", FONTS.Book, 12, COLORS.GreyMuted, UDim2.new(0, 2, 0, 30), UDim2.new(1, -4, 0, 16))

    -- ---- GENERAL ----------------------------------------------------------------
    local general = SUI.section("General", 10)
    TagToggleBtn = SUI.switchRow(general, "Overhead user tags", "Show AN tags above players' heads", Settings.ShowTags)

    -- ---- NETWORK ----------------------------------------------------------------
    local network = SUI.section("Network", 20)

    local _, tpCtl = SUI.row(network, "Teleportation", "Rejoin this server or hop to a new one", {ctrlW = 200, stack = true})
    local RejoinBtn = SUI.button(tpCtl, "Rejoin", "default", 96)
    RejoinBtn.LayoutOrder = 1
    RejoinBtn.MouseButton1Click:Connect(function()
        if RejoinBtn:GetAttribute("Busy") then return end
        RejoinBtn:SetAttribute("Busy", true)
        RejoinBtn.Text = "Rejoining..."
        queueAutoExecute()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        task.delay(5, function()
            RejoinBtn.Text = "Rejoin"
            RejoinBtn:SetAttribute("Busy", nil)
        end)
    end)

    local ServerHopBtn = SUI.button(tpCtl, "Serverhop", "default", 96)
    ServerHopBtn.LayoutOrder = 2
    ServerHopBtn.MouseButton1Click:Connect(function()
        if ServerHopBtn:GetAttribute("Busy") then return end
        local req = request or http_request or (syn and syn.request)
        if not req then
            SUI.flash(ServerHopBtn, "Unsupported")
            return
        end
        ServerHopBtn:SetAttribute("Busy", true)
        ServerHopBtn.Text = "Searching..."
        task.spawn(function()
            local picked
            local ok, res = pcall(req, {Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"})
            if ok and res and res.StatusCode == 200 then
                local okData, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                if okData and data and data.data then
                    local servers = {}
                    for _, s in ipairs(data.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            table.insert(servers, s.id)
                        end
                    end
                    if #servers > 0 then picked = servers[math.random(1, #servers)] end
                end
            end
            if picked then
                ServerHopBtn.Text = "Joining..."
                queueAutoExecute()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, picked, LocalPlayer)
                task.wait(5)
            else
                ServerHopBtn.Text = "No servers"
                task.wait(1.6)
            end
            ServerHopBtn.Text = "Serverhop"
            ServerHopBtn:SetAttribute("Busy", nil)
        end)
    end)

    local _, idCtl = SUI.row(network, "Server ID", "Copy this ID, or paste one and press Enter to join", {ctrlW = 256, stack = true})
    local copyW = 72
    JoinIdBox.Text = ""
    JoinIdBox.PlaceholderText = "Paste a Job ID..."
    JoinIdBox.TextXAlignment = Enum.TextXAlignment.Left
    JoinIdBox.LayoutOrder = 1
    SUI.field(JoinIdBox, SUI.narrow and UDim2.new(1, -(copyW + 8), 1, 0) or UDim2.new(0, 176, 1, 0))
    SUI.pad(JoinIdBox, 0, 10, 0, 10)
    JoinIdBox.Parent = idCtl

    JoinIdBox.FocusLost:Connect(function(enter)
        local id = JoinIdBox.Text:gsub("%s", "")
        if enter and id ~= "" then
            queueAutoExecute()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
        end
    end)

    local CopyIdBtn = SUI.button(idCtl, "Copy ID", "default", copyW)
    CopyIdBtn.LayoutOrder = 2
    CopyIdBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(tostring(game.JobId))
            SUI.flash(CopyIdBtn, "Copied")
        else
            SUI.flash(CopyIdBtn, "Unsupported")
        end
    end)

    -- ---- APPEARANCE -------------------------------------------------------------
    local appearance = SUI.section("Appearance", 30)
    local swatchSize = SUI.narrow and 26 or 28
    local _, themeCtl = SUI.row(appearance, "Theme color", "Pick a preset or type a hex code", {ctrlW = 264, stack = true})
    themeCtl.UIListLayout.Padding = UDim.new(0, SUI.narrow and 6 or 8)

    HexInput.Text = CurrentThemeHex
    HexInput.PlaceholderText = "RRGGBB"
    HexInput.TextXAlignment = Enum.TextXAlignment.Center
    HexInput.LayoutOrder = 1
    SUI.field(HexInput, UDim2.new(0, SUI.narrow and 68 or 76, 0, swatchSize + 4))
    HexInput.Font = FONTS.Bold
    HexInput.Parent = themeCtl

    SUI.presets = {
        Color3.fromRGB(229, 9, 20),
        Color3.fromRGB(0, 120, 255),
        Color3.fromRGB(0, 255, 127),
        Color3.fromRGB(138, 43, 226),
        Color3.fromRGB(255, 215, 0)
    }
    for i, color in ipairs(SUI.presets) do
        local colorBtn = SUI.make("TextButton", {
            Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = 1 + i,
            BackgroundColor3 = color, Size = UDim2.new(0, swatchSize, 0, swatchSize)
        }, themeCtl)
        colorBtn:SetAttribute("ANThemePreset", true)
        createCorner(colorBtn, swatchSize / 2)
        -- white ring marks the swatch that is currently the theme
        local ring = SUI.make("UIStroke", {
            Color = Color3.new(1, 1, 1), Thickness = 2, Transparency = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }, colorBtn)
        SUI.swatches[#SUI.swatches + 1] = {color = color, ring = ring}
        BindInteractionSounds(colorBtn)
        colorBtn.MouseButton1Click:Connect(function() applyNewTheme(color) end)
    end
    SUI.syncSwatches()

    -- ---- SUPPORT ----------------------------------------------------------------
    local support = SUI.section("Support", 40)
    local fbBoxH = 76
    local fbTop = 70
    local FeedbackRow = SUI.row(support, "Feedback and reports", "Tell us about bugs or ideas. 3 reports, then a 5 minute cooldown.", {
        noControls = true, height = fbTop + fbBoxH + 10 + SUI.btnH + 14
    })
    FeedbackRow.Name = "FeedbackRow"

    FBInput.Text = ""
    FBInput.PlaceholderText = "Describe the bug or idea..."
    FBInput.TextXAlignment = Enum.TextXAlignment.Left
    FBInput.TextYAlignment = Enum.TextYAlignment.Top
    FBInput.TextWrapped = true
    FBInput.MultiLine = true
    FBInput.Font = FONTS.Book
    FBInput.TextSize = 13
    FBInput.Position = UDim2.new(0, 16, 0, fbTop)
    SUI.field(FBInput, UDim2.new(1, -32, 0, fbBoxH))
    FBInput.Font = FONTS.Book
    FBInput.TextSize = 13
    FBInput.TextColor3 = Color3.fromRGB(225, 225, 225)
    SUI.pad(FBInput, 8, 10, 8, 10)
    FBInput.Parent = FeedbackRow

    SUI.button(FeedbackRow, "Submit", "primary", 104, FBSubmitBtn)
    FBSubmitBtn.AnchorPoint = Vector2.new(1, 0)
    FBSubmitBtn.Position = UDim2.new(1, -16, 0, fbTop + fbBoxH + 10)

    -- ---- INTERFACE --------------------------------------------------------------
    local interface = SUI.section("Interface", 50)
    local _, uiCtl = SUI.row(interface, "Destroy UI", "Closes this window and cleans everything up", {ctrlW = 110, stack = false})
    local DestroyBtn = SUI.button(uiCtl, "Destroy UI", "danger", 104)
    DestroyBtn.MouseButton1Click:Connect(function()
        -- two-step so one stray click can't close everything
        if DestroyBtn:GetAttribute("Armed") ~= true then
            DestroyBtn:SetAttribute("Armed", true)
            DestroyBtn.Text = "Confirm?"
            task.delay(3, function()
                if DestroyBtn.Parent and DestroyBtn:GetAttribute("Armed") == true then
                    DestroyBtn:SetAttribute("Armed", nil)
                    DestroyBtn.Text = "Destroy UI"
                end
            end)
            return
        end
        pcall(function() clearPiratedImageCache() end)
        pcall(function() checkOut() end)
        if AN_ENV.AN_UNIVERSAL_GUI == ScreenGui then AN_ENV.AN_UNIVERSAL_GUI = nil end
        if AN_ENV.AN_UNIVERSAL_CLEANUP and AN_ENV.AN_UNIVERSAL_GUI == nil then AN_ENV.AN_UNIVERSAL_CLEANUP = nil end
        ScreenGui:Destroy()
    end)

    local footer = SUI.text(SettingsScroll, "Changes save automatically.", FONTS.Book, 11, COLORS.GreyMuted, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 16))
    footer.LayoutOrder = 200
    footer.TextXAlignment = Enum.TextXAlignment.Center

    -- switches follow settings that were changed somewhere else (e.g. "don't show again")
    SUI.syncs[#SUI.syncs + 1] = function()
        SUI.setSwitch(TagToggleBtn, Settings.ShowTags == true, true)
        SUI.syncSwatches()
    end
    SettingsFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not SettingsFrame.Visible then return end
        for _, fn in ipairs(SUI.syncs) do pcall(fn) end
    end)
end

local maxReports = 3
local currentReports = 0
local isReportLocked = false
local cooldownDuration = 300
local spamLockFile = "AN/NFX_SpamLock.txt"

pcall(function()
    if isfile and readfile and isfile(spamLockFile) then
        local savedTime = tonumber(readfile(spamLockFile))
        if savedTime and (os.time() - savedTime) < cooldownDuration then
            isReportLocked = true
            FBInput.Text = "SEND FEATURE LOCKED DUE TO SPAM. PLEASE WAIT 5 MINS."
            FBInput.TextEditable = false
            FBSubmitBtn.Text = "Locked"
            FBSubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
        end
    end
end)

FBSubmitBtn.MouseButton1Click:Connect(function()
    if isReportLocked then return end
    
    local text = FBInput.Text
    if text == "" then return end
    
    currentReports = currentReports + 1
    local isSpamTrigger = false
    
    if currentReports >= maxReports then
        isReportLocked = true
        isSpamTrigger = true
        
        pcall(function()
            if writefile then writefile(spamLockFile, tostring(os.time())) end
        end)
        
        FBInput.Text = "SEND FEATURE LOCKED DUE TO SPAM. PLEASE WAIT 5 MINS."
        FBInput.TextEditable = false
        FBSubmitBtn.Text = "Locked"
        FBSubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
    end

    task.spawn(function()
        local req = request or http_request or (syn and syn.request)
        if not req then 
            FBSubmitBtn.Text = "Unsupported"
            task.wait(2)
            FBSubmitBtn.Text = isReportLocked and "Locked" or "Submit"
            return 
        end
        
        local url = "https://discord.com/api/webhooks/1525456253331964004/SY6JCjkvak3s1c1nTn4pDq89VamfjXXcEWqZtHNjSli9ilAJULWQKpGoMJDgJoQN8-Fk"
        
        local embedTitle = "🚨 New Report Received!"
        local embedDesc = "**User:** `" .. LocalPlayer.Name .. "`\n**Message:**\n```\n" .. text .. "\n```"
        local embedColor = tonumber("0xE50914")
        
        if isSpamTrigger then
            embedTitle = "🛑 SPAM PREVENTED"
            embedDesc = "**User:** `" .. LocalPlayer.Name .. "` hit the rate limit.\nThey are now locked out for 5 minutes across all sessions.\n**Final Message:**\n```\n" .. text .. "\n```"
            embedColor = tonumber("0xFF0000")
        end
        
        local payload = {
            content = "<@975571423919759410>", 
            embeds = {
                {
                    title = embedTitle,
                    description = embedDesc,
                    color = embedColor,
                    fields = {
                        {
                            name = "📱 Mobile User ID Copy",
                            value = "` " .. tostring(LocalPlayer.UserId) .. " `",
                            inline = true
                        },
                        {
                            name = "💻 PC User ID Copy",
                            value = "```lua\n" .. tostring(LocalPlayer.UserId) .. "\n```",
                            inline = false
                        }
                    },
                    footer = { text = "AN Universal Auto-Report System" }
                }
            }
        }
        
        local success, res = pcall(function()
            return req({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
        
        if success and not isSpamTrigger then
            FBInput.Text = ""
            FBSubmitBtn.Text = "Sent!"
            FBSubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
            task.wait(2)
            if not isReportLocked then
                FBSubmitBtn.Text = "Submit"
                FBSubmitBtn.BackgroundColor3 = COLORS.BrandRed
            end
        elseif not success and not isSpamTrigger then
            FBSubmitBtn.Text = "Error"
            task.wait(2)
            FBSubmitBtn.Text = "Submit"
        end
    end)
end)

TagToggleBtn.MouseButton1Click:Connect(function()
    Settings.ShowTags = not Settings.ShowTags
    saveSettings()
    AN_ENV.AN_SettingsUI.setSwitch(TagToggleBtn, Settings.ShowTags)
    updateOverheadVisibility()
end)

updateDynamicThemeColors = function(newColor)
    local oldColor = COLORS.BrandRed
    COLORS.BrandRed = newColor

    if ScreenGui and ScreenGui.Parent then
        for _, object in ipairs(ScreenGui:GetDescendants()) do
            pcall(function()
                if object:IsA("GuiObject") then
                    local isThemePreset = false
                    pcall(function()
                        isThemePreset = object:GetAttribute("ANThemePreset") == true
                    end)
                    if not isThemePreset then
                        if object.BackgroundColor3 == oldColor then object.BackgroundColor3 = newColor end
                        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                            if object.TextColor3 == oldColor then object.TextColor3 = newColor end
                        end
                        if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                            if object.ImageColor3 == oldColor then object.ImageColor3 = newColor end
                        end
                    end
                elseif object:IsA("UIStroke") then
                    if object.Color == oldColor then object.Color = newColor end
                elseif object:IsA("ScrollingFrame") then
                    if object.ScrollBarImageColor3 == oldColor then object.ScrollBarImageColor3 = newColor end
                end
            end)
        end
    end

    pcall(function() BrandLogo.TextColor3 = newColor end)
    pcall(function() NavIndicator.BackgroundColor3 = newColor end)
    pcall(function() MinimizedStroke.Color = newColor end)
    pcall(function() PlayBtn.BackgroundColor3 = newColor end)
    pcall(function() ExecActionBtn.BackgroundColor3 = newColor end)
    pcall(function() FBSubmitBtn.BackgroundColor3 = newColor end)
    pcall(function() CreditsBigN.TextColor3 = newColor end)
    pcall(function() SettingsScroll.ScrollBarImageColor3 = newColor end)
    pcall(function() PiratedSearchBtn.BackgroundColor3 = newColor end)
    pcall(function() PiratedResults.ScrollBarImageColor3 = newColor end)
    pcall(function() PiratedExecute.BackgroundColor3 = newColor end)
    pcall(function() PiratedFavoriteBtn.BackgroundColor3 = newColor end)
    for _, dot in ipairs(DotsHolder:GetChildren()) do
        if dot:IsA("Frame") and dot.Size.X.Offset > 10 then
            dot.BackgroundColor3 = newColor
        end
    end
end

applyNewTheme = function(color)
    if typeof(color) ~= "Color3" then return end
    local hex = color:ToHex()
    HexInput.Text = hex
    CurrentThemeHex = hex
    CurrentThemeColor = color
    updateDynamicThemeColors(color)
    pcall(function()
        if writefile then writefile(THEME_FILE, hex) end
    end)
end

HexInput.FocusLost:Connect(function()
    local raw = HexInput.Text:gsub("[#%s]", "")
    local ok, newColor = false, nil
    if #raw == 6 or #raw == 3 then ok, newColor = pcall(Color3.fromHex, raw) end
    if ok and typeof(newColor) == "Color3" then
        applyNewTheme(newColor)
    else
        -- not a colour: put the real one back and flash the border
        HexInput.Text = CurrentThemeHex
        local stroke = HexInput:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = Color3.fromRGB(198, 40, 40)
            TweenService:Create(stroke, TweenInfo.new(0.6), {Color = COLORS.Border}):Play()
        end
    end
end)

do
    -- the white ring on the swatch that matches the current theme follows every theme change
    local baseApply = applyNewTheme
    applyNewTheme = function(color)
        baseApply(color)
        pcall(function() AN_ENV.AN_SettingsUI.syncSwatches() end)
    end
end

local currentIndex = 1
local visibleMovies = {}

-- Movie carousel card sizing
-- Desktop keeps the original size; mobile uses smaller cards so the poster does not dominate
-- the carousel on narrow screens.
local baseCardWidth, baseCardHeight = 135, 202
local carouselGap = 24

if isMobile() then
    local viewportWidth = Camera.ViewportSize.X
    local mobileScale = math.clamp(viewportWidth / 900, 0.68, 0.78)
    baseCardWidth = math.floor(baseCardWidth * mobileScale)
    baseCardHeight = math.floor(baseCardHeight * mobileScale)
    carouselGap = 12
end

local function layoutCards(instant)
    local containerW = CarouselContainer.AbsoluteSize.X
    local centerX = containerW / 2
    for i, card in ipairs(MovieCarousel:GetChildren()) do
        if card:IsA("Frame") then
            local offsetFromCurrent = i - currentIndex
            local targetX = centerX + offsetFromCurrent * (baseCardWidth + carouselGap) - baseCardWidth / 2
            local isCenter = (i == currentIndex)
            local dist = math.abs(offsetFromCurrent)
            local targetScale = isCenter and 1.05 or 0.82
            local targetTransparency = isCenter and 0 or math.clamp(0.4 + dist * 0.18, 0.4, 0.85)
            local targetZ = isCenter and 10 or (10 - dist)

            card.ZIndex = math.max(targetZ, 1)

            local goalPos = UDim2.new(0, targetX, 0.45, 0)
            local goalSize = UDim2.new(0, baseCardWidth * targetScale, 0, baseCardHeight * targetScale)

            if instant then
                card.Position = goalPos
                card.Size = goalSize
            else
                TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                    Position = goalPos,
                    Size = goalSize
                }):Play()
            end

            local img = card:FindFirstChild("PosterImg")
            local posterGlow = card:FindFirstChild("PosterGlow")
            if img then 
                TweenService:Create(img, TweenInfo.new(0.35), {ImageTransparency = targetTransparency}):Play() 
            end
            if posterGlow then 
                TweenService:Create(posterGlow, TweenInfo.new(0.35), {ImageTransparency = targetTransparency == 0 and 0.4 or 1}):Play() 
            end
        end
    end
end

local function updateDots()
    DotsHolder:ClearAllChildren()
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = DotsHolder
    for i = 1, #visibleMovies do
        local dot = Instance.new("Frame")
        dot.BorderSizePixel = 0
        dot.LayoutOrder = i
        dot.Parent = DotsHolder
        createCorner(dot, 3)

        if i == currentIndex then
            dot.Size = UDim2.new(0, 14, 0, 4)
            dot.BackgroundColor3 = COLORS.BrandRed
        else
            dot.Size = UDim2.new(0, 4, 0, 4)
            dot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end

local viewDetailScreen
local viewPiratedFavoriteDetail

local function createMovieCard(movie, index)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. index
    card.AnchorPoint = Vector2.new(0, 0.5)
    card.Size = UDim2.new(0, baseCardWidth, 0, baseCardHeight)
    card.BackgroundTransparency = 1
    card.ZIndex = 2
    card.Parent = MovieCarousel

    local posterImg = Instance.new("ImageLabel")
    posterImg.Name = "PosterImg"
    posterImg.Size = UDim2.new(1, 0, 1, 0)
    posterImg.BackgroundColor3 = COLORS.DarkCard
    posterImg.ScaleType = Enum.ScaleType.Crop
    posterImg.ZIndex = 3
    posterImg.Parent = card

    local posterGlow = Instance.new("ImageLabel")
    posterGlow.Name = "PosterGlow"
    posterGlow.Size = UDim2.new(1, 16, 1, 16)
    posterGlow.Position = UDim2.new(0, -8, 0, -8)
    posterGlow.BackgroundTransparency = 1
    posterGlow.Image = "rbxassetid://6014261993"
    posterGlow.ImageColor3 = Color3.new(0, 0, 0)
    posterGlow.ImageTransparency = 1
    posterGlow.ScaleType = Enum.ScaleType.Slice
    posterGlow.SliceCenter = Rect.new(49, 49, 450, 450)
    posterGlow.ZIndex = 2
    posterGlow.Parent = card

    LoadImageAsync(posterImg, movie.Img or (movie.SavedPirated and movie.SavedPirated.Image))

    local clickSensor = Instance.new("TextButton")
    clickSensor.Size = UDim2.new(1, 0, 1, 0)
    clickSensor.BackgroundTransparency = 1
    clickSensor.Text = ""
    clickSensor.ZIndex = 4
    clickSensor.Parent = card
    BindInteractionSounds(clickSensor)

    clickSensor.MouseButton1Click:Connect(function()
        if index == currentIndex then
            if movie.Kind == "pirated" and viewPiratedFavoriteDetail then
                viewPiratedFavoriteDetail(movie)
            else
                viewDetailScreen(movie)
            end
        else
            currentIndex = index
            layoutCards(false)
            updateDots()
        end
    end)

    clickSensor.MouseEnter:Connect(function()
        if index == currentIndex then
            TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, baseCardWidth * 1.08, 0, baseCardHeight * 1.08)
            }):Play()
        end
    end)

    clickSensor.MouseLeave:Connect(function()
        if index == currentIndex then
            TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, baseCardWidth * 1.05, 0, baseCardHeight * 1.05)
            }):Play()
        end
    end)

    return card
end

updateCarousel = function()
    MovieCarousel:ClearAllChildren()
    local query = SearchBox.Text:lower()
    visibleMovies = {}
    for _, movie in ipairs(MOVIES) do
        local titleText = tostring(movie.Title or "")
        local matchSearch = query == "" or titleText:lower():find(query, 1, true)
        local matchGenre = (CurrentGenre == "All") or (CurrentGenre == "My List" and isFavorite(titleText)) or (movie.Genre == CurrentGenre)
        
        local matchTags = true
        for activeTag, _ in pairs(ActiveTagsFilter) do
            local hasTag = false
            if movie.ParsedTags then
                for _, t in ipairs(movie.ParsedTags) do
                    if t == activeTag then hasTag = true break end
                end
            end
            if not hasTag then matchTags = false break end
        end
        
        if matchSearch and matchGenre and matchTags then
            table.insert(visibleMovies, movie)
        end
    end

    -- ScriptBlox favorites are also surfaced in Movies > My List with their
    -- saved metadata so they remain browsable even after the search result is gone.
    if CurrentGenre == "My List" then
        for _, saved in ipairs(getSavedPiratedEntries()) do
            local titleText = tostring(saved.Title or "Untitled Script")
            if query == "" or titleText:lower():find(query, 1, true) then
                table.insert(visibleMovies, {
                    Kind = "pirated",
                    Title = titleText,
                    Img = saved.Image,
                    Creator = saved.Owner or "ScriptBlox",
                    Genre = "Pirated",
                    Date = tostring(saved.UpdatedAt or saved.CreatedAt or ""),
                    Description = saved.Description or "",
                    Tags = saved.Tags or {},
                    Script = saved.Script,
                    SavedPirated = saved
                })
            end
        end
    end

    EmptyState.Visible = (#visibleMovies == 0)
    currentIndex = math.clamp(currentIndex, 1, math.max(#visibleMovies, 1))

    for i, movie in ipairs(visibleMovies) do
        createMovieCard(movie, i)
    end

    task.defer(function()
        layoutCards(true)
        updateDots()
    end)
end

local function shiftCarousel(step)
    if #visibleMovies == 0 then return end
    currentIndex = currentIndex + step
    if currentIndex < 1 then currentIndex = #visibleMovies end
    if currentIndex > #visibleMovies then currentIndex = 1 end
    layoutCards(false)
    updateDots()
end

-- ============================================================================
-- PIRATED / SCRIPTBLOX SECTION
-- ============================================================================
local PiratedFrame
;(function()
PiratedFrame = Instance.new("Frame")
PiratedFrame.Name = "PiratedFrame"
PiratedFrame.Size = UDim2.new(1, 0, 1, -52)
PiratedFrame.Position = UDim2.new(0, 0, 0, 52)
PiratedFrame.BackgroundTransparency = 1
PiratedFrame.Visible = false
PiratedFrame.Parent = MainFrame

local PiratedSearch = Instance.new("TextBox")
PiratedSearch.Name = "PiratedSearch"
PiratedSearch.Size = UDim2.new(1, -36, 0, 38)
PiratedSearch.Position = UDim2.new(0, 18, 0, 12)
PiratedSearch.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
PiratedSearch.BorderSizePixel = 0
PiratedSearch.Text = ""
PiratedSearch.PlaceholderText = "Search ScriptBlox scripts..."
PiratedSearch.PlaceholderColor3 = Color3.fromRGB(105, 105, 105)
PiratedSearch.TextColor3 = COLORS.White
PiratedSearch.Font = FONTS.Book
PiratedSearch.TextSize = 13
PiratedSearch.ClearTextOnFocus = false
PiratedSearch.TextXAlignment = Enum.TextXAlignment.Left
PiratedSearch.ZIndex = 5
PiratedSearch.Parent = PiratedFrame
createCorner(PiratedSearch, 5)
createStroke(PiratedSearch, COLORS.Border, 1, 0.4)

local PiratedSearchBtn = Instance.new("TextButton")
PiratedSearchBtn.Name = "PiratedSearchBtn"
PiratedSearchBtn.Size = UDim2.new(0, 78, 0, 30)
PiratedSearchBtn.Position = UDim2.new(1, -94, 0, 16)
PiratedSearchBtn.BackgroundColor3 = COLORS.BrandRed
PiratedSearchBtn.Text = "Search"
PiratedSearchBtn.TextColor3 = COLORS.White
PiratedSearchBtn.Font = FONTS.Bold
PiratedSearchBtn.TextSize = 12
PiratedSearchBtn.AutoButtonColor = false
PiratedSearchBtn.ZIndex = 6
PiratedSearchBtn.Parent = PiratedFrame
createCorner(PiratedSearchBtn, 4)
BindInteractionSounds(PiratedSearchBtn)

local PiratedStatusLabel = Instance.new("TextLabel")
PiratedStatusLabel.Size = UDim2.new(1, -36, 0, 22)
PiratedStatusLabel.Position = UDim2.new(0, 18, 0, 54)
PiratedStatusLabel.BackgroundTransparency = 1
PiratedStatusLabel.Text = "ScriptBlox  •  Verified / Key / Universal / Patched status shown on every result"
PiratedStatusLabel.TextColor3 = COLORS.GreyMuted
PiratedStatusLabel.Font = FONTS.Book
PiratedStatusLabel.TextSize = 10
PiratedStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
PiratedStatusLabel.ZIndex = 4
PiratedStatusLabel.Parent = PiratedFrame

PiratedResults = Instance.new("ScrollingFrame")
PiratedResults.Name = "PiratedResults"
PiratedResults.Size = UDim2.new(1, -36, 1, -112)
PiratedResults.Position = UDim2.new(0, 18, 0, 82)
PiratedResults.BackgroundTransparency = 1
PiratedResults.BorderSizePixel = 0
PiratedResults.ScrollBarThickness = 5
PiratedResults.ScrollBarImageColor3 = COLORS.BrandRed
PiratedResults.CanvasSize = UDim2.new(0, 0, 0, 0)
PiratedResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
PiratedResults.ScrollingDirection = Enum.ScrollingDirection.Y
PiratedResults.ZIndex = 3
PiratedResults.Parent = PiratedFrame

PiratedGrid = Instance.new("UIGridLayout")
PiratedGrid.CellPadding = UDim2.new(0, 10, 0, 10)
PiratedGrid.CellSize = UDim2.new(0, 205, 0, 184)
PiratedGrid.SortOrder = Enum.SortOrder.LayoutOrder
PiratedGrid.Parent = PiratedResults

local PiratedEmpty = Instance.new("TextLabel")
PiratedEmpty.Name = "PiratedEmpty"
PiratedEmpty.Size = UDim2.new(1, 0, 0, 60)
PiratedEmpty.BackgroundTransparency = 1
PiratedEmpty.Text = "Search ScriptBlox to find scripts."
PiratedEmpty.TextColor3 = COLORS.GreyMuted
PiratedEmpty.Font = FONTS.Book
PiratedEmpty.TextSize = 13
PiratedEmpty.Visible = true
PiratedEmpty.ZIndex = 4
PiratedEmpty.Parent = PiratedResults

-- Full detail container. Everything inside scrolls on small windows/mobile.
local PiratedDetail = Instance.new("ScrollingFrame")
PiratedDetail.Name = "PiratedDetail"
-- Detail view no longer leaves the large search-bar gap above the inner panel.
-- Keep a small 12px gap below the top navigation/header.
PiratedDetail.Size = UDim2.new(1, -36, 1, -28)
PiratedDetail.Position = UDim2.new(0, 18, 0, 12)
PiratedDetail.BackgroundColor3 = COLORS.DarkCard
PiratedDetail.BorderSizePixel = 0
PiratedDetail.Visible = false
PiratedDetail.ZIndex = 10
PiratedDetail.ScrollBarThickness = 5
PiratedDetail.ScrollBarImageColor3 = COLORS.BrandRed
PiratedDetail.CanvasSize = UDim2.new(0, 0, 0, 0)
PiratedDetail.AutomaticCanvasSize = Enum.AutomaticSize.Y
PiratedDetail.ScrollingDirection = Enum.ScrollingDirection.Y
PiratedDetail.Parent = PiratedFrame
createCorner(PiratedDetail, 7)
createStroke(PiratedDetail, COLORS.Border, 1, 0.35)

local PiratedDetailPadding = Instance.new("UIPadding")
PiratedDetailPadding.PaddingTop = UDim.new(0, 12)
PiratedDetailPadding.PaddingBottom = UDim.new(0, 20)
PiratedDetailPadding.PaddingLeft = UDim.new(0, 12)
PiratedDetailPadding.PaddingRight = UDim.new(0, 12)
PiratedDetailPadding.Parent = PiratedDetail

local PiratedDetailLayout = Instance.new("UIListLayout")
PiratedDetailLayout.FillDirection = Enum.FillDirection.Vertical
PiratedDetailLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
PiratedDetailLayout.SortOrder = Enum.SortOrder.LayoutOrder
PiratedDetailLayout.Padding = UDim.new(0, 10)
PiratedDetailLayout.Parent = PiratedDetail

local PiratedBack = Instance.new("TextButton")
PiratedBack.Name = "PiratedBack"
PiratedBack.Size = UDim2.new(0, 70, 0, 30)
PiratedBack.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
PiratedBack.Text = "Back"
PiratedBack.TextColor3 = COLORS.White
PiratedBack.Font = FONTS.Bold
PiratedBack.TextSize = 12
PiratedBack.AutoButtonColor = false
PiratedBack.LayoutOrder = 1
PiratedBack.ZIndex = 12
PiratedBack.Parent = PiratedDetail
createCorner(PiratedBack, 4)
BindInteractionSounds(PiratedBack)

local PiratedHero = Instance.new("Frame")
PiratedHero.Name = "PiratedHero"
PiratedHero.Size = UDim2.new(1, -24, 0, 252)
PiratedHero.BackgroundTransparency = 1
PiratedHero.LayoutOrder = 2
PiratedHero.ZIndex = 11
PiratedHero.Parent = PiratedDetail

local PiratedDetailImage = Instance.new("ImageLabel")
PiratedDetailImage.Name = "PiratedDetailImage"
PiratedDetailImage.Size = UDim2.new(0, 150, 0, 112)
PiratedDetailImage.Position = UDim2.new(0, 0, 0, 10)
PiratedDetailImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PiratedDetailImage.BorderSizePixel = 0
PiratedDetailImage.ScaleType = Enum.ScaleType.Crop
PiratedDetailImage.ZIndex = 11
PiratedDetailImage.Parent = PiratedHero
createCorner(PiratedDetailImage, 6)

local PiratedNoImage = Instance.new("TextLabel")
PiratedNoImage.Size = UDim2.new(1, 0, 1, 0)
PiratedNoImage.BackgroundTransparency = 1
PiratedNoImage.Text = "NO IMAGE"
PiratedNoImage.TextColor3 = COLORS.GreyMuted
PiratedNoImage.Font = FONTS.Bold
PiratedNoImage.TextSize = 10
PiratedNoImage.ZIndex = 10
PiratedNoImage.Parent = PiratedHero

local PiratedHeroInfo = Instance.new("Frame")
PiratedHeroInfo.Size = UDim2.new(1, -162, 1, 0)
PiratedHeroInfo.Position = UDim2.new(0, 162, 0, 0)
PiratedHeroInfo.BackgroundTransparency = 1
PiratedHeroInfo.ZIndex = 11
PiratedHeroInfo.Parent = PiratedHero

local PiratedDetailTitle = Instance.new("TextLabel")
PiratedDetailTitle.Name = "PiratedDetailTitle"
PiratedDetailTitle.Size = UDim2.new(1, 0, 0, 44)
PiratedDetailTitle.BackgroundTransparency = 1
PiratedDetailTitle.TextColor3 = COLORS.White
PiratedDetailTitle.Font = FONTS.Heavy
PiratedDetailTitle.TextSize = 21
PiratedDetailTitle.TextXAlignment = Enum.TextXAlignment.Left
PiratedDetailTitle.TextYAlignment = Enum.TextYAlignment.Top
PiratedDetailTitle.TextWrapped = true
PiratedDetailTitle.TextTruncate = Enum.TextTruncate.AtEnd
PiratedDetailTitle.ZIndex = 11
PiratedDetailTitle.Parent = PiratedHeroInfo

local PiratedMeta = Instance.new("TextLabel")
PiratedMeta.Name = "PiratedMeta"
PiratedMeta.Size = UDim2.new(1, 0, 0, 68)
PiratedMeta.Position = UDim2.new(0, 0, 0, 48)
PiratedMeta.BackgroundTransparency = 1
PiratedMeta.TextColor3 = COLORS.GreyMuted
PiratedMeta.Font = FONTS.Medium
PiratedMeta.TextSize = 11
PiratedMeta.TextWrapped = true
PiratedMeta.TextXAlignment = Enum.TextXAlignment.Left
PiratedMeta.TextYAlignment = Enum.TextYAlignment.Top
PiratedMeta.ZIndex = 11
PiratedMeta.Parent = PiratedHeroInfo

-- Main tags and creator-provided tags are separate.
local PiratedTagsFrame = Instance.new("Frame")
PiratedTagsFrame.Name = "PiratedTagsFrame"
PiratedTagsFrame.Size = UDim2.new(1, -24, 0, 58)
PiratedTagsFrame.LayoutOrder = 3
PiratedTagsFrame.BackgroundTransparency = 1
PiratedTagsFrame.ZIndex = 11
PiratedTagsFrame.Parent = PiratedDetail

local PiratedMainTagsLabel = Instance.new("TextLabel")
PiratedMainTagsLabel.Size = UDim2.new(1, 0, 0, 18)
PiratedMainTagsLabel.BackgroundTransparency = 1
PiratedMainTagsLabel.Text = "STATUS"
PiratedMainTagsLabel.TextColor3 = COLORS.GreyMuted
PiratedMainTagsLabel.Font = FONTS.Bold
PiratedMainTagsLabel.TextSize = 9
PiratedMainTagsLabel.TextXAlignment = Enum.TextXAlignment.Left
PiratedMainTagsLabel.Parent = PiratedTagsFrame

local PiratedTagsScroll = Instance.new("ScrollingFrame")
PiratedTagsScroll.Size = UDim2.new(1, 0, 0, 34)
PiratedTagsScroll.Position = UDim2.new(0, 0, 0, 18)
PiratedTagsScroll.BackgroundTransparency = 1
PiratedTagsScroll.BorderSizePixel = 0
PiratedTagsScroll.ScrollBarThickness = 0
PiratedTagsScroll.ScrollingDirection = Enum.ScrollingDirection.X
PiratedTagsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PiratedTagsScroll.ZIndex = 12
PiratedTagsScroll.Parent = PiratedTagsFrame

local PiratedTagsLayout = Instance.new("UIListLayout")
PiratedTagsLayout.FillDirection = Enum.FillDirection.Horizontal
PiratedTagsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
PiratedTagsLayout.Padding = UDim.new(0, 7)
PiratedTagsLayout.Parent = PiratedTagsScroll

local PiratedCreatorTagsLabel = Instance.new("TextLabel")
PiratedCreatorTagsLabel.Size = UDim2.new(1, 0, 0, 18)
PiratedCreatorTagsLabel.BackgroundTransparency = 1
PiratedCreatorTagsLabel.Text = "CREATOR TAGS"
PiratedCreatorTagsLabel.TextColor3 = COLORS.GreyMuted
PiratedCreatorTagsLabel.Font = FONTS.Bold
PiratedCreatorTagsLabel.TextSize = 9
PiratedCreatorTagsLabel.TextXAlignment = Enum.TextXAlignment.Left
PiratedCreatorTagsLabel.Parent = PiratedDetail

local PiratedCreatorTagsScroll = Instance.new("ScrollingFrame")
PiratedCreatorTagsScroll.Name = "PiratedCreatorTagsScroll"
PiratedCreatorTagsScroll.Size = UDim2.new(1, -24, 0, 54)
PiratedCreatorTagsScroll.LayoutOrder = 4
PiratedCreatorTagsScroll.BackgroundTransparency = 1
PiratedCreatorTagsScroll.BorderSizePixel = 0
PiratedCreatorTagsScroll.ScrollBarThickness = 0
PiratedCreatorTagsScroll.ScrollingDirection = Enum.ScrollingDirection.X
PiratedCreatorTagsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PiratedCreatorTagsScroll.ZIndex = 12
PiratedCreatorTagsScroll.Parent = PiratedDetail

local PiratedCreatorTagsLayout = Instance.new("UIListLayout")
PiratedCreatorTagsLayout.FillDirection = Enum.FillDirection.Horizontal
PiratedCreatorTagsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
PiratedCreatorTagsLayout.Padding = UDim.new(0, 7)
PiratedCreatorTagsLayout.Parent = PiratedCreatorTagsScroll

local function addPiratedTag(text, kind, parent)
    parent = parent or PiratedTagsScroll
    local tag = Instance.new("TextLabel")
    tag.AutomaticSize = Enum.AutomaticSize.X
    tag.Size = UDim2.new(0, 0, 0, 27)
    -- Netflix-only palette.
    tag.BackgroundColor3 = kind == "good" and COLORS.BrandRed or Color3.fromRGB(45, 45, 45)
    tag.TextColor3 = COLORS.White
    tag.Font = FONTS.Bold
    tag.TextSize = 10
    tag.Text = "  " .. tostring(text) .. "  "
    tag.ZIndex = 12
    tag.Parent = parent
    createCorner(tag, 13)
    return tag
end

local PiratedDescriptionHeader = Instance.new("TextLabel")
PiratedDescriptionHeader.Size = UDim2.new(1, -24, 0, 24)
PiratedDescriptionHeader.LayoutOrder = 5
PiratedDescriptionHeader.BackgroundTransparency = 1
PiratedDescriptionHeader.Text = "DESCRIPTION / FEATURES"
PiratedDescriptionHeader.TextColor3 = COLORS.White
PiratedDescriptionHeader.Font = FONTS.Bold
PiratedDescriptionHeader.TextSize = 12
PiratedDescriptionHeader.TextXAlignment = Enum.TextXAlignment.Left
PiratedDescriptionHeader.ZIndex = 11
PiratedDescriptionHeader.Parent = PiratedDetail

local PiratedDescription = Instance.new("TextLabel")
PiratedDescription.Name = "PiratedDescription"
PiratedDescription.Size = UDim2.new(1, -24, 0, 120)
PiratedDescription.AutomaticSize = Enum.AutomaticSize.Y
PiratedDescription.LayoutOrder = 6
PiratedDescription.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
PiratedDescription.TextColor3 = COLORS.GreyLight
PiratedDescription.Font = FONTS.Book
PiratedDescription.TextSize = 12
PiratedDescription.TextWrapped = true
PiratedDescription.TextXAlignment = Enum.TextXAlignment.Left
PiratedDescription.TextYAlignment = Enum.TextYAlignment.Top
PiratedDescription.ZIndex = 11
PiratedDescription.Parent = PiratedDetail
createCorner(PiratedDescription, 5)
local descPad = Instance.new("UIPadding")
descPad.PaddingTop = UDim.new(0, 10)
descPad.PaddingBottom = UDim.new(0, 10)
descPad.PaddingLeft = UDim.new(0, 10)
descPad.PaddingRight = UDim.new(0, 10)
descPad.Parent = PiratedDescription

local PiratedCommentsHeader = Instance.new("TextLabel")
PiratedCommentsHeader.Size = UDim2.new(1, -24, 0, 28)
PiratedCommentsHeader.LayoutOrder = 7
PiratedCommentsHeader.BackgroundTransparency = 1
PiratedCommentsHeader.Text = "COMMUNITY COMMENTS"
PiratedCommentsHeader.TextColor3 = COLORS.White
PiratedCommentsHeader.Font = FONTS.Bold
PiratedCommentsHeader.TextSize = 12
PiratedCommentsHeader.TextXAlignment = Enum.TextXAlignment.Left
PiratedCommentsHeader.ZIndex = 11
PiratedCommentsHeader.Parent = PiratedDetail

local PiratedComments = Instance.new("Frame")
PiratedComments.Name = "PiratedComments"
PiratedComments.Size = UDim2.new(1, -24, 0, 10)
PiratedComments.AutomaticSize = Enum.AutomaticSize.Y
PiratedComments.LayoutOrder = 8
PiratedComments.BackgroundTransparency = 1
PiratedComments.ZIndex = 11
PiratedComments.Parent = PiratedDetail

local PiratedCommentsLayout = Instance.new("UIListLayout")
PiratedCommentsLayout.Padding = UDim.new(0, 7)
PiratedCommentsLayout.SortOrder = Enum.SortOrder.LayoutOrder
PiratedCommentsLayout.Parent = PiratedComments

local PiratedExecuteRow = Instance.new("Frame")
PiratedExecuteRow.Name = "PiratedExecuteRow"
PiratedExecuteRow.Size = UDim2.new(1, 0, 0, 116)
PiratedExecuteRow.Position = UDim2.new(0, 0, 0, 120)
PiratedExecuteRow.BackgroundTransparency = 1
PiratedExecuteRow.ZIndex = 12
PiratedExecuteRow.Parent = PiratedHeroInfo

local PiratedExecuteLayout = Instance.new("UIListLayout")
PiratedExecuteLayout.FillDirection = Enum.FillDirection.Vertical
PiratedExecuteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
PiratedExecuteLayout.VerticalAlignment = Enum.VerticalAlignment.Top
PiratedExecuteLayout.Padding = UDim.new(0, 6)
PiratedExecuteLayout.Parent = PiratedExecuteRow

local PiratedExecute = Instance.new("TextButton")
PiratedExecute.Name = "PiratedExecute"
PiratedExecute.Size = UDim2.new(1, 0, 0, 34)
PiratedExecute.BackgroundColor3 = COLORS.BrandRed
PiratedExecute.Text = "Execute"
PiratedExecute.TextColor3 = COLORS.White
PiratedExecute.Font = FONTS.Bold
PiratedExecute.TextSize = 12
PiratedExecute.AutoButtonColor = false
PiratedExecute.ZIndex = 12
PiratedExecute.Parent = PiratedExecuteRow
createCorner(PiratedExecute, 4)
BindInteractionSounds(PiratedExecute)

PiratedOpenTab = Instance.new("TextButton")
PiratedOpenTab.Name = "PiratedOpenTab"
PiratedOpenTab.Size = UDim2.new(1, 0, 0, 34)
PiratedOpenTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PiratedOpenTab.Text = "Open Tab"
PiratedOpenTab.TextColor3 = COLORS.White
PiratedOpenTab.Font = FONTS.Bold
PiratedOpenTab.TextSize = 12
PiratedOpenTab.AutoButtonColor = false
PiratedOpenTab.ZIndex = 12
PiratedOpenTab.Parent = PiratedExecuteRow
createCorner(PiratedOpenTab, 4)
createStroke(PiratedOpenTab, COLORS.Border, 1)
BindInteractionSounds(PiratedOpenTab)

PiratedFavoriteBtn = Instance.new("TextButton")
PiratedFavoriteBtn.Name = "PiratedFavoriteBtn"
PiratedFavoriteBtn.Size = UDim2.new(1, 0, 0, 34)
PiratedFavoriteBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PiratedFavoriteBtn.Text = "+ My List"
PiratedFavoriteBtn.TextColor3 = COLORS.White
PiratedFavoriteBtn.Font = FONTS.Bold
PiratedFavoriteBtn.TextSize = 11
PiratedFavoriteBtn.AutoButtonColor = false
PiratedFavoriteBtn.ZIndex = 12
PiratedFavoriteBtn.Parent = PiratedExecuteRow
createCorner(PiratedFavoriteBtn, 4)
createStroke(PiratedFavoriteBtn, COLORS.Border, 1)
BindInteractionSounds(PiratedFavoriteBtn)

do
piratedScripts = {}
selectedPirated = nil
selectedPiratedComments = {}
piratedSearchBusy = false
piratedPage = 1
piratedTotalPages = 1
piratedLoadingMore = false

local function piratedHttpGet(url)
    local success, body = pcall(function()
        return game:HttpGet(url)
    end)
    if not success or not body then return nil end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not ok then return nil end
    return decoded
end

local function clearPiratedResults()
    for _, child in ipairs(PiratedResults:GetChildren()) do
        if child:IsA("GuiObject") and child ~= PiratedEmpty then
            child:Destroy()
        end
    end
end

local function clearPiratedComments()
    for _, child in ipairs(PiratedComments:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end

local function clearPiratedTags()
    for _, child in ipairs(PiratedTagsScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
end

local function piratedGameName(scriptData)
    return (scriptData.game and scriptData.game.name) or "Unknown Game"
end

local function formatPiratedDate(value)
    if type(value) ~= "string" or value == "" then return "Unknown date" end
    local y, m, d = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if y then return y .. "-" .. m .. "-" .. d end
    return value
end

function createPiratedResult(scriptData, index)
    local card = Instance.new("TextButton")
    card.Name = "PiratedCard_" .. index
    card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    card.BorderSizePixel = 0
    card.Text = ""
    card.AutoButtonColor = false
    card.LayoutOrder = index
    card.ZIndex = 5
    card.Parent = PiratedResults
    createCorner(card, 7)
    createStroke(card, COLORS.Border, 1, 0.5)
    BindInteractionSounds(card)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 78, 1, -12)
    img.Position = UDim2.new(0, 6, 0, 6)
    img.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    img.BorderSizePixel = 0
    img.ScaleType = Enum.ScaleType.Crop
    img.ZIndex = 6
    img.Parent = card
    createCorner(img, 5)
    LoadImageAsync(img, scriptData.image or (scriptData.game and scriptData.game.imageUrl), true, true)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -94, 0, 32)
    title.Position = UDim2.new(0, 90, 0, 9)
    title.BackgroundTransparency = 1
    title.Text = tostring(scriptData.title or "Untitled Script")
    title.TextColor3 = COLORS.White
    title.Font = FONTS.Bold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.TextWrapped = true
    title.ZIndex = 6
    title.Parent = card

    local meta = Instance.new("TextLabel")
    meta.Size = UDim2.new(1, -94, 0, 38)
    meta.Position = UDim2.new(0, 90, 0, 44)
    meta.BackgroundTransparency = 1
    meta.Text = piratedGameName(scriptData) .. "\n" ..
        tostring(scriptData.views or 0) .. " views • " .. tostring(scriptData.likeCount or 0) .. " likes"
    meta.TextColor3 = COLORS.GreyMuted
    meta.Font = FONTS.Book
    meta.TextSize = 10
    meta.TextWrapped = true
    meta.TextXAlignment = Enum.TextXAlignment.Left
    meta.TextYAlignment = Enum.TextYAlignment.Top
    meta.ZIndex = 6
    meta.Parent = card

    local tags = Instance.new("Frame")
    tags.Size = UDim2.new(1, -94, 0, 48)
    tags.Position = UDim2.new(0, 90, 1, -54)
    tags.BackgroundTransparency = 1
    tags.ZIndex = 7
    tags.Parent = card

    local tagGrid = Instance.new("UIGridLayout")
    tagGrid.CellSize = UDim2.new(0.5, -3, 0, 20)
    tagGrid.CellPadding = UDim2.new(0, 6, 0, 4)
    tagGrid.FillDirection = Enum.FillDirection.Horizontal
    tagGrid.FillDirectionMaxCells = 2
    tagGrid.SortOrder = Enum.SortOrder.LayoutOrder
    tagGrid.Parent = tags

    local function cardTag(text, kind, order)
        local tag = Instance.new("TextLabel")
        tag.Size = UDim2.new(0, 0, 0, 20)
        tag.BackgroundColor3 = kind == "good" and COLORS.BrandRed or Color3.fromRGB(48, 48, 48)
        tag.TextColor3 = COLORS.White
        tag.Font = FONTS.Bold
        tag.TextSize = 8
        tag.Text = tostring(text)
        tag.TextXAlignment = Enum.TextXAlignment.Center
        tag.TextTruncate = Enum.TextTruncate.AtEnd
        tag.LayoutOrder = order
        tag.ZIndex = 8
        tag.Parent = tags
        createCorner(tag, 10)
    end

    cardTag(scriptData.verified and "VERIFIED" or "UNVERIFIED", scriptData.verified and "good" or "neutral", 1)
    cardTag(scriptData.key and "KEY SYSTEM" or "KEYLESS", "neutral", 2)
    cardTag(scriptData.isUniversal and "UNIVERSAL" or "GAME", scriptData.isUniversal and "good" or "neutral", 3)
    cardTag(scriptData.isPatched and "PATCHED" or "WORKING", scriptData.isPatched and "neutral" or "good", 4)

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
    end)

    card.MouseButton1Click:Connect(function()
        local slug = scriptData.slug or scriptData._id
        local detail = slug and piratedHttpGet("https://scriptblox.com/api/script/" .. tostring(slug))
        local full = detail and detail.script or scriptData
        if not full then return end
        renderPiratedDetail(full)
    end)
end

function renderPiratedDetail(full, preloadedComments)
    if not full then return end
    selectedPirated = full
    selectedPiratedComments = type(preloadedComments) == "table" and preloadedComments or {}

    PiratedSearch.Visible = false
    PiratedSearchBtn.Visible = false
    PiratedStatusLabel.Visible = false
    PiratedResults.Visible = false
    PiratedDetail.Visible = true
    PiratedDetail.CanvasPosition = Vector2.new(0, 0)

    PiratedDetailTitle.Text = tostring(full.title or "Untitled Script")
    local detailImageUrl = full.image or (full.game and full.game.imageUrl)
    PiratedDetailImage.Image = ""
    PiratedNoImage.Visible = not (detailImageUrl and detailImageUrl ~= "")
    LoadImageAsync(PiratedDetailImage, detailImageUrl, true, true)

    local likes = tonumber(full.likeCount or full.Likes) or 0
    local dislikes = tonumber(full.dislikeCount or full.Dislikes) or 0
    local totalVotes = likes + dislikes
    local rating = totalVotes > 0 and math.floor((likes / totalVotes) * 100 + 0.5) or 0
    local owner = (full.owner and full.owner.username) or full.Owner or "Unknown"
    PiratedMeta.Text = piratedGameName(full) .. "\n" ..
        "★ " .. tostring(rating) .. "% positive • " .. tostring(likes) .. " likes • " .. tostring(dislikes) .. " dislikes\n" ..
        tostring(full.views or full.Views or 0) .. " views • by " .. owner .. "\nUpdated: " .. formatPiratedDate(full.updatedAt or full.UpdatedAt or full.createdAt or full.CreatedAt)

    clearPiratedTags()
    for _, child in ipairs(PiratedCreatorTagsScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    local isVerified = full.verified == true or full.Verified == true
    local isKey = full.key == true or full.Key == true
    local isUniversal = full.isUniversal == true or full.Universal == true
    local isPatched = full.isPatched == true or full.Patched == true
    addPiratedTag(isVerified and "VERIFIED" or "UNVERIFIED", isVerified and "good" or "neutral")
    addPiratedTag(isKey and "KEY SYSTEM" or "KEYLESS", "neutral")
    addPiratedTag(isUniversal and "UNIVERSAL" or "GAME SPECIFIC", isUniversal and "good" or "neutral")
    addPiratedTag(isPatched and "PATCHED" or "WORKING", "neutral")
    addPiratedTag(tostring(full.scriptType or full.ScriptType or "FREE"):upper(), "neutral")
    if full.visibility or full.Visibility then addPiratedTag(tostring(full.visibility or full.Visibility):upper(), "neutral") end

    local tags = full.tags or full.Tags
    if type(tags) == "table" then
        for _, tagName in ipairs(tags) do
            local text = tostring(tagName)
            if text ~= "" then addPiratedTag(text, "neutral", PiratedCreatorTagsScroll) end
        end
    end
    task.defer(function()
        PiratedTagsScroll.CanvasSize = UDim2.new(0, PiratedTagsLayout.AbsoluteContentSize.X + 8, 0, 0)
        PiratedCreatorTagsScroll.CanvasSize = UDim2.new(0, PiratedCreatorTagsLayout.AbsoluteContentSize.X + 8, 0, 0)
    end)

    PiratedDescription.Text = tostring(full.features or full.description or full.Description or "No description provided.")

    clearPiratedComments()
    local comments = selectedPiratedComments
    if #comments == 0 and full._id then
        local commentResponse = piratedHttpGet("https://scriptblox.com/api/comment/" .. tostring(full._id) .. "?page=1&max=50")
        comments = commentResponse and commentResponse.result and commentResponse.result.comments or {}
        selectedPiratedComments = type(comments) == "table" and comments or {}
    end

    if type(comments) ~= "table" or #comments == 0 then
        local none = Instance.new("TextLabel")
        none.Size = UDim2.new(1, 0, 0, 34)
        none.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
        none.Text = "No comments available."
        none.TextColor3 = COLORS.GreyMuted
        none.Font = FONTS.Book
        none.TextSize = 11
        none.TextXAlignment = Enum.TextXAlignment.Left
        none.ZIndex = 11
        none.Parent = PiratedComments
        createCorner(none, 5)
    else
        for i, comment in ipairs(comments) do
            local box = Instance.new("Frame")
            box.Size = UDim2.new(1, 0, 0, 78)
            box.BackgroundColor3 = Color3.fromRGB(30, 31, 34)
            box.BorderSizePixel = 0
            box.LayoutOrder = i
            box.ZIndex = 11
            box.Parent = PiratedComments
            createCorner(box, 6)

            local accent = Instance.new("Frame")
            accent.Size = UDim2.new(0, 3, 1, 0)
            accent.BackgroundColor3 = COLORS.BrandRed
            accent.BorderSizePixel = 0
            accent.ZIndex = 12
            accent.Parent = box
            createCorner(accent, 2)

            local avatar = Instance.new("ImageLabel")
            avatar.Size = UDim2.new(0, 28, 0, 28)
            avatar.Position = UDim2.new(0, 10, 0, 9)
            avatar.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
            avatar.BorderSizePixel = 0
            avatar.ScaleType = Enum.ScaleType.Crop
            avatar.ZIndex = 12
            avatar.Parent = box
            createCorner(avatar, 14)
            if comment.commentBy and comment.commentBy.profilePicture then
                LoadImageAsync(avatar, comment.commentBy.profilePicture, true, true)
            end

            local username = tostring((comment.commentBy and comment.commentBy.username) or comment.Username or "Unknown")
            local user = Instance.new("TextLabel")
            user.Size = UDim2.new(1, -54, 0, 19)
            user.Position = UDim2.new(0, 47, 0, 7)
            user.BackgroundTransparency = 1
            user.Text = "@" .. username .. ((comment.commentBy and comment.commentBy.verified) and "  ✓" or "")
            user.TextColor3 = COLORS.White
            user.Font = FONTS.Bold
            user.TextSize = 10
            user.TextXAlignment = Enum.TextXAlignment.Left
            user.ZIndex = 12
            user.Parent = box

            local stamp = Instance.new("TextLabel")
            stamp.Size = UDim2.new(1, -54, 0, 16)
            stamp.Position = UDim2.new(0, 47, 0, 26)
            stamp.BackgroundTransparency = 1
            stamp.Text = formatPiratedDate(comment.createdAt or comment.updatedAt or comment.CreatedAt or comment.UpdatedAt)
            stamp.TextColor3 = Color3.fromRGB(148, 150, 156)
            stamp.Font = FONTS.Book
            stamp.TextSize = 9
            stamp.TextXAlignment = Enum.TextXAlignment.Left
            stamp.ZIndex = 12
            stamp.Parent = box

            local body = Instance.new("TextLabel")
            body.Size = UDim2.new(1, -20, 0, 28)
            body.Position = UDim2.new(0, 10, 0, 45)
            body.BackgroundTransparency = 1
            body.Text = tostring(comment.text or comment.Text or "")
            body.TextColor3 = COLORS.GreyLight
            body.Font = FONTS.Book
            body.TextSize = 10
            body.TextWrapped = true
            body.TextXAlignment = Enum.TextXAlignment.Left
            body.TextYAlignment = Enum.TextYAlignment.Top
            body.ZIndex = 12
            body.Parent = box
        end
    end

    PiratedFavoriteBtn.Text = myListLabel(isPiratedFavorite(tostring(full.title or "Untitled Script")))
end

viewPiratedFavoriteDetail = function(saved)
    local full = {
        title = saved.Title,
        script = saved.Script,
        image = saved.Image,
        game = saved.Game,
        features = saved.Description,
        likeCount = saved.Likes,
        dislikeCount = saved.Dislikes,
        views = saved.Views,
        owner = {username = saved.Owner or "Unknown"},
        updatedAt = saved.UpdatedAt,
        createdAt = saved.CreatedAt,
        tags = saved.Tags,
        verified = saved.Verified,
        key = saved.Key,
        isUniversal = saved.Universal,
        isPatched = saved.Patched,
        scriptType = saved.ScriptType,
        visibility = saved.Visibility,
        _id = saved.Id,
        slug = saved.Slug
    }
    renderPiratedDetail(full, saved.Comments or {})
    routeToView("pirated")
    updateTabLine(PiratedTab)
end

function searchPirated(query)
    query = tostring(query or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if query == "" or piratedSearchBusy then return end
    piratedSearchBusy = true
    PiratedSearchBtn.Text = "Searching..."
    clearPiratedImageCache()
    clearPiratedResults()
    PiratedEmpty.Visible = true
    PiratedEmpty.Text = "Searching ScriptBlox..."

    task.spawn(function()
        local encoded = HttpService:UrlEncode(query)
        local url = "https://scriptblox.com/api/script/search?q=" .. encoded .. "&page=1&max=20&sortBy=views&order=desc"
        local response = piratedHttpGet(url)
        piratedScripts = response and response.result and response.result.scripts or {}
        piratedPage = 1
        piratedTotalPages = tonumber(response and response.result and response.result.totalPages) or 1
        piratedLoadingMore = false
        clearPiratedResults()
        if #piratedScripts == 0 then
            PiratedEmpty.Visible = true
            PiratedEmpty.Text = "No ScriptBlox results found."
        else
            PiratedEmpty.Visible = false
            for i, scriptData in ipairs(piratedScripts) do
                createPiratedResult(scriptData, i)
            end
        end
        PiratedSearchBtn.Text = "Search"
        piratedSearchBusy = false
    end)
end

PiratedSearchBtn.MouseButton1Click:Connect(function()
    searchPirated(PiratedSearch.Text)
end)

PiratedSearch.FocusLost:Connect(function(enterPressed)
    if enterPressed then searchPirated(PiratedSearch.Text) end
end)

PiratedBack.MouseButton1Click:Connect(function()
    selectedPirated = nil
    clearPiratedImageCache()
    PiratedDetail.Visible = false
    PiratedSearch.Visible = true
    PiratedSearchBtn.Visible = true
    PiratedStatusLabel.Visible = true
    PiratedResults.Visible = true
end)

PiratedExecute.MouseButton1Click:Connect(function()
    if not selectedPirated then return end
    local source = selectedPirated.script
    if type(source) ~= "string" or source == "" then
        PiratedExecute.Text = "No Source"
        task.delay(1.5, function()
            if PiratedExecute then PiratedExecute.Text = "Execute" end
        end)
        return
    end
    task.spawn(function()
        local ok = pcall(function()
            local fn = loadstring(source)
            if fn then fn() end
        end)
        PiratedExecute.Text = ok and "Executed" or "Failed"
        task.wait(1.2)
        if PiratedExecute then PiratedExecute.Text = "Execute" end
    end)
    -- Executing also persists the current ScriptBlox metadata when it is favorited.
    if isPiratedFavorite(tostring(selectedPirated.title or "Untitled Script")) then
        local idx = findFavoriteIndex(tostring(selectedPirated.title or "Untitled Script"), "pirated")
        if idx and Favorites[idx] then
            Favorites[idx].Script = source
            Favorites[idx].Description = selectedPirated.features or selectedPirated.description or Favorites[idx].Description
            Favorites[idx].Comments = selectedPiratedComments or Favorites[idx].Comments
            saveFavorites()
        end
    end
end)

PiratedOpenTab.MouseButton1Click:Connect(function()
    if not selectedPirated then return end
    local source = selectedPirated.script
    if type(source) ~= "string" or source == "" then
        PiratedOpenTab.Text = "No Source"
        task.delay(1.5, function() if PiratedOpenTab then PiratedOpenTab.Text = "Open Tab" end end)
        return
    end
    openScriptInDirectorTab(selectedPirated.title or "ScriptBlox Script", source)
end)

PiratedFavoriteBtn.MouseButton1Click:Connect(function()
    if not selectedPirated then return end
    togglePiratedFavorite(selectedPirated, selectedPiratedComments)
    PiratedFavoriteBtn.Text = myListLabel(isPiratedFavorite(tostring(selectedPirated.title or "Untitled Script")))
    if CurrentGenre == "My List" then updateCarousel() end
end)

PiratedGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PiratedResults.CanvasSize = UDim2.new(0, 0, 0, PiratedGrid.AbsoluteContentSize.Y + 18)
end)

PiratedResults.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local maxY = math.max(PiratedResults.AbsoluteCanvasSize.Y - PiratedResults.AbsoluteSize.Y, 0)
        if PiratedResults.CanvasPosition.Y >= maxY - 120 and not piratedLoadingMore and piratedPage < piratedTotalPages and not piratedSearchBusy then
            piratedLoadingMore = true
            local nextPage = piratedPage + 1
            task.spawn(function()
                local encoded = HttpService:UrlEncode(PiratedSearch.Text)
                local response = piratedHttpGet("https://scriptblox.com/api/script/search?q=" .. encoded .. "&page=" .. tostring(nextPage) .. "&max=20&sortBy=views&order=desc")
                local more = response and response.result and response.result.scripts or {}
                if #more > 0 then
                    piratedPage = nextPage
                    piratedTotalPages = tonumber(response.result.totalPages) or piratedTotalPages
                    local startIndex = #piratedScripts + 1
                    for i, scriptData in ipairs(more) do
                        table.insert(piratedScripts, scriptData)
                        createPiratedResult(scriptData, startIndex + i - 1)
                    end
                end
                piratedLoadingMore = false
            end)
        end
    end
end)

PiratedTagsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PiratedTagsScroll.CanvasSize = UDim2.new(0, PiratedTagsLayout.AbsoluteContentSize.X + 8, 0, 0)
end)

PiratedCommentsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PiratedComments.Size = UDim2.new(1, -24, 0, PiratedCommentsLayout.AbsoluteContentSize.Y)
end)

PiratedDetailLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PiratedDetail.CanvasSize = UDim2.new(0, 0, 0, PiratedDetailLayout.AbsoluteContentSize.Y + 32)
end)

task.defer(function()
    if isMobile() then
        PiratedGrid.CellSize = UDim2.new(1, -6, 0, 168)
        PiratedGrid.CellPadding = UDim2.new(0, 6, 0, 8)
        PiratedDetailImage.Size = UDim2.new(0, 112, 0, 96)
        PiratedHero.Size = UDim2.new(1, -24, 0, 270)
        PiratedHeroInfo.Position = UDim2.new(0, 122, 0, 0)
        PiratedHeroInfo.Size = UDim2.new(1, -122, 1, 0)
        PiratedDetailTitle.TextSize = 17
        PiratedMeta.TextSize = 9
        PiratedExecuteRow.Position = UDim2.new(0, 0, 0, 120)
        PiratedExecuteRow.Size = UDim2.new(1, 0, 0, 116)
    end
end)

end
end)()

local activeView = nil
local views = {
    menu = MenuFrame,
    detail = DetailFrame,
    executor = ExecutorFrame,
    pirated = PiratedFrame,
    credits = CreditsFrame,
    settings = SettingsFrame
}
if AdminFrame then views.admin = AdminFrame end

local viewOrigins = {}
for name, frame in pairs(views) do viewOrigins[name] = frame.Position end

routeToView = function(viewName)
    if viewName == activeView then return end
    local outgoing = views[activeView]
    local incoming = views[viewName]
    if outgoing and outgoing.Visible then
        local outTarget = viewOrigins[activeView] + UDim2.new(0, 0, 0, 12)
        TweenService:Create(outgoing, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = outTarget
        }):Play()
    end

    task.delay(0.15, function()
        for name, frame in pairs(views) do
            frame.Visible = (name == viewName)
            if name ~= viewName then frame.Position = viewOrigins[name] end
        end

        if incoming then
            incoming.Position = viewOrigins[viewName] + UDim2.new(0, 0, 0, 12)
            TweenService:Create(incoming, TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                Position = viewOrigins[viewName]
            }):Play()
        end
    end)

    activeView = viewName
end

local currentPlayConnection = nil
local currentFavConnection = nil
local CurrentDetailMovie = nil
local CurrentDetailOptions = {HideEffects = false, MuteMusic = false}

local function supportsHatReanimOption(movie, optionName)
    if not movie or movie.Genre ~= "Hat reanim" then return false end
    local options = movie.Options or movie.HatReanimOptions or movie.ReanimOptions
    if type(options) == "table" and options[optionName] == true then
        return true
    end
    -- Also accept explicit support flags for compatibility with alternate JSON schemas.
    return movie["Supports" .. optionName] == true
end

local function updateReanimOptionButton(button, label, enabled)
    button.Text = label .. ": " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled and COLORS.BrandRed or Color3.fromRGB(35, 35, 35)
end

local function replaceBooleanSetting(scriptSource, settingName, enabled)
    local pattern = "(" .. settingName .. "%s*=%s*)[%a]+"
    local patchedSource, count = scriptSource:gsub(pattern, function(prefix)
        return prefix .. (enabled and "true" or "false")
    end, 1)
    return patchedSource, count > 0
end

local function executeMovieWithOptions(movie)
    local scriptSource = tostring(movie.Loadstring or "")
    if scriptSource == "" then error("This movie has no loadstring source.") end

    local supportsHideEffects = supportsHatReanimOption(movie, "HideEffects")
    local supportsMuteMusic = supportsHatReanimOption(movie, "MuteMusic")
    if supportsHideEffects or supportsMuteMusic then
        local hasPatchedSetting = false

        -- A supported Hat reanim can declare settings directly in its Loadstring.
        -- Only options explicitly enabled in the movie metadata are exposed.
        if supportsHideEffects then
            local patched, found = replaceBooleanSetting(scriptSource, "HideEffects", CurrentDetailOptions.HideEffects == true)
            scriptSource = patched
            hasPatchedSetting = hasPatchedSetting or found
        end
        if supportsMuteMusic then
            local patched, found = replaceBooleanSetting(scriptSource, "MuteMusic", CurrentDetailOptions.MuteMusic == true)
            scriptSource = patched
            hasPatchedSetting = hasPatchedSetting or found
        end

        -- If Loadstring only points to a raw GitHub file, try patching that file's
        -- settings too. Keep the original wrapper when there is no editable config.
        if not hasPatchedSetting then
            local remoteUrl = scriptSource:match('game:HttpGet%(%s*"(https?://[^"]+)"%s*%)')
                or scriptSource:match("game:HttpGet%(%s*'(https?://[^']+)'%s*%)")
            if remoteUrl then
                local fetchOk, remoteSource = pcall(function() return game:HttpGet(remoteUrl) end)
                if fetchOk and type(remoteSource) == "string" then
                    local patchedAny = false
                    if supportsHideEffects then
                        local patched, found = replaceBooleanSetting(remoteSource, "HideEffects", CurrentDetailOptions.HideEffects == true)
                        remoteSource = patched
                        patchedAny = patchedAny or found
                    end
                    if supportsMuteMusic then
                        local patched, found = replaceBooleanSetting(remoteSource, "MuteMusic", CurrentDetailOptions.MuteMusic == true)
                        remoteSource = patched
                        patchedAny = patchedAny or found
                    end
                    if patchedAny then scriptSource = remoteSource end
                end
            end
        end

        -- Fallback for scripts that read the shared config without declaring it
        -- in the wrapper. Scripts that don't support these keys get no UI toggles.
        if type(AN_ENV.trulysettings) ~= "table" then AN_ENV.trulysettings = {} end
        if type(AN_ENV.trulysettings.patchma) ~= "table" then AN_ENV.trulysettings.patchma = {} end
        if type(AN_ENV.trulysettings.script) ~= "table" then AN_ENV.trulysettings.script = {} end
        if supportsHideEffects then
            AN_ENV.trulysettings.script.HideEffects = CurrentDetailOptions.HideEffects == true
        end
        if supportsMuteMusic then
            AN_ENV.trulysettings.script.MuteMusic = CurrentDetailOptions.MuteMusic == true
        end
    end

    local compiled, compileError = loadstring(scriptSource)
    if not compiled then error(compileError or "Could not compile movie script.") end
    return compiled()
end

viewDetailScreen = function(movie)
    CurrentDetailMovie = movie
    CurrentDetailOptions = {HideEffects = false, MuteMusic = false}

    local supportsHideEffects = supportsHatReanimOption(movie, "HideEffects")
    local supportsMuteMusic = supportsHatReanimOption(movie, "MuteMusic")
    local optionCount = (supportsHideEffects and 1 or 0) + (supportsMuteMusic and 1 or 0)
    ReanimOptionsRow.Visible = optionCount > 0
    HideEffectsOptionBtn.Visible = supportsHideEffects
    MuteMusicOptionBtn.Visible = supportsMuteMusic
    if optionCount == 1 then
        if supportsHideEffects then HideEffectsOptionBtn.Size = UDim2.new(1, 0, 1, 0) end
        if supportsMuteMusic then MuteMusicOptionBtn.Size = UDim2.new(1, 0, 1, 0) end
    else
        HideEffectsOptionBtn.Size = UDim2.new(0.5, -4, 1, 0)
        MuteMusicOptionBtn.Size = UDim2.new(0.5, -4, 1, 0)
    end
    updateReanimOptionButton(HideEffectsOptionBtn, "Hide Effects", false)
    updateReanimOptionButton(MuteMusicOptionBtn, "Mute Music", false)
    DetailDescription.Size = UDim2.new(1, 0, 1, optionCount > 0 and -210 or -170)

    DetailImage.Image = ""
    LoadImageAsync(DetailImage, movie.Img)
    DetailTitle.Text = movie.Title
    MetaRow.Text = movie.Creator .. " • " .. (movie.Genre or "Uncategorized") .. " • " .. (movie.Date or "")
    DetailDescription.Text = movie.Description
    for _, c in ipairs(TagsDetailScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end

    if movie.ParsedTags then
        for _, tagName in ipairs(movie.ParsedTags) do
            local tLbl = Instance.new("TextLabel")
            tLbl.Text = tagName
            tLbl.Font = FONTS.Bold
            tLbl.TextSize = 11
            tLbl.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            tLbl.TextColor3 = COLORS.White
            local size = TextService:GetTextSize(tagName, 11, FONTS.Bold, Vector2.new(999, 20))
            tLbl.Size = UDim2.new(0, size.X + 16, 1, 0)
            createCorner(tLbl, 13)
            tLbl.Parent = TagsDetailScroll
        end
    end

    TagsDetailScroll.CanvasSize = UDim2.new(0, DetailTagsLayout.AbsoluteContentSize.X + 10, 0, 0)

    if currentPlayConnection then currentPlayConnection:Disconnect() end
    if currentFavConnection then currentFavConnection:Disconnect() end

    currentPlayConnection = PlayBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local ok, err = pcall(function()
                executeMovieWithOptions(movie)
            end)
            if not ok then
                warn("[ANHUB] Movie execution failed: " .. tostring(err))
            end
        end)
        if movie.Genre == "Insta Move" then setMinimized(true) end
    end)

    FavBtn.Text = myListLabel(isFavorite(movie.Title))
    currentFavConnection = FavBtn.MouseButton1Click:Connect(function()
        toggleFavorite(movie.Title)
        FavBtn.Text = myListLabel(isFavorite(movie.Title))
        if CurrentGenre == "My List" then updateCarousel() end
    end)

    routeToView("detail")
end

DetailTagsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TagsDetailScroll.CanvasSize = UDim2.new(0, DetailTagsLayout.AbsoluteContentSize.X + 10, 0, 0)
end)

HideEffectsOptionBtn.MouseButton1Click:Connect(function()
    if not CurrentDetailMovie or not supportsHatReanimOption(CurrentDetailMovie, "HideEffects") then return end
    CurrentDetailOptions.HideEffects = not CurrentDetailOptions.HideEffects
    updateReanimOptionButton(HideEffectsOptionBtn, "Hide Effects", CurrentDetailOptions.HideEffects)
end)

MuteMusicOptionBtn.MouseButton1Click:Connect(function()
    if not CurrentDetailMovie or not supportsHatReanimOption(CurrentDetailMovie, "MuteMusic") then return end
    CurrentDetailOptions.MuteMusic = not CurrentDetailOptions.MuteMusic
    updateReanimOptionButton(MuteMusicOptionBtn, "Mute Music", CurrentDetailOptions.MuteMusic)
end)

-- (PlayBtn hover lives only in the Netflix pass; the old red hover handlers were removed
--  because they fought the Netflix ones and left the button stuck red after hover-out)
LeftArrow.MouseButton1Click:Connect(function() shiftCarousel(-1) end)
RightArrow.MouseButton1Click:Connect(function() shiftCarousel(1) end)
BackBtn.MouseButton1Click:Connect(function() clearPiratedImageCache(); routeToView("menu"); updateTabLine(MoviesTab) end)
MoviesTab.MouseButton1Click:Connect(function() updateTabLine(MoviesTab); clearPiratedImageCache(); routeToView("menu") end)
ExecutorTab.MouseButton1Click:Connect(function() updateTabLine(ExecutorTab); clearPiratedImageCache(); routeToView("executor") end)
PiratedTab.MouseButton1Click:Connect(function() updateTabLine(PiratedTab); routeToView("pirated") end)
SettingsTab.MouseButton1Click:Connect(function() updateTabLine(SettingsTab); clearPiratedImageCache(); routeToView("settings") end)
CreditsTab.MouseButton1Click:Connect(function() updateTabLine(CreditsTab); clearPiratedImageCache(); routeToView("credits") end)
if AdminTab then
    AdminTab.MouseButton1Click:Connect(function() updateTabLine(AdminTab); clearPiratedImageCache(); routeToView("admin") end)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentIndex = 1
    updateCarousel()
end)

CarouselContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() layoutCards(true) end)
MinimizeBtn.MouseButton1Click:Connect(function() setMinimized(true) end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightControl then
            setMinimized(not isMinimized)
        end
    end
end)

local touchStartLocation = nil
MinimizedPill.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        touchStartLocation = input.Position
    end
end)

MinimizedPill.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if touchStartLocation then
            local dragDelta = (input.Position - touchStartLocation).Magnitude
            if dragDelta < 10 then setMinimized(false) end
            touchStartLocation = nil
        end
    end
end)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local targetSize = getTargetSize()
    if PiratedGrid then
        local width = PiratedResults.AbsoluteSize.X
        PiratedGrid.CellSize = isMobile() and UDim2.new(1, -6, 0, 168) or UDim2.new(0, 205, 0, 184)
        PiratedGrid.CellPadding = isMobile() and UDim2.new(0, 6, 0, 8) or UDim2.new(0, 10, 0, 10)
    end
    local viewport = Camera.ViewportSize
    MainFrame.Size = UDim2.new(
        0, math.min(targetSize.X.Offset, viewport.X - 24),
        0, math.min(targetSize.Y.Offset, viewport.Y - 24)
    )
end)

local ActiveTags = {}
local FirebaseActiveUsers = {}

local function cleanTag(player)
    if ActiveTags[player] then
        pcall(function() ActiveTags[player].Gui:Destroy() end)
        ActiveTags[player] = nil
    end
end

local function applyOverheadTag(player)
    cleanTag(player)
    if not Settings.ShowTags then return end
    if player == LocalPlayer and not IsAdmin(player.UserId) then return end
    local character = player.Character
    local head = character and character:WaitForChild("Head", 5)
    if not head then return end

    local bill = Instance.new("BillboardGui")
    bill.Name = "AN_UserTag"
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(4.5, 0, 1.2, 0) 
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.Adornee = head
    bill.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BackgroundTransparency = 0.25
    frame.Parent = bill
    createCorner(frame, 6)

    local tagStroke = createStroke(frame, COLORS.Border, 1.5)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = FONTS.Bold
    textLabel.TextScaled = true

    local textConstraint = Instance.new("UITextSizeConstraint")
    textConstraint.MaxTextSize = 14
    textConstraint.MinTextSize = 6
    textConstraint.Parent = textLabel
    textLabel.Parent = frame

    local role = "AN_Users"
    local rank = GetUserRank(player.UserId)
    if rank == 4 then 
        role = "AN_Founder" 
    elseif rank == 3 then
        role = "AN_Co-founder"
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 40, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
        })
        gradient.Rotation = 45
        gradient.Parent = textLabel
        ActiveTags[player] = { Gui = bill, TextLabel = textLabel, Stroke = tagStroke, UserId = player.UserId, Gradient = gradient, Rank = rank }
    elseif rank == 2 then
        role = "AN_Admin"
        ActiveTags[player] = { Gui = bill, TextLabel = textLabel, Stroke = tagStroke, UserId = player.UserId, Rank = rank }
    else
        role = "AN_Users"
        ActiveTags[player] = { Gui = bill, TextLabel = textLabel, Stroke = tagStroke, UserId = player.UserId, Rank = rank }
    end
    
    textLabel.Text = role
    
    if not ActiveTags[player] then
        ActiveTags[player] = { Gui = bill, TextLabel = textLabel, Stroke = tagStroke, UserId = player.UserId, Rank = rank }
    end
end

task.spawn(function()
    while task.wait(5) do
        if http_request then
            local response = http_request({
                Url = BASE_URL .. "active_users/" .. JobId .. ".json",
                Method = "GET"
            })
            
            if response and response.StatusCode == 200 and response.Body ~= "null" then
                local activeUsers = HttpService:JSONDecode(response.Body)
                local userNames = {}
                local currentTime = os.time()
                
                FirebaseActiveUsers = {}
                if activeUsers then
                    for userIdStr, info in pairs(activeUsers) do
                        if info.timestamp and (currentTime - info.timestamp) <= 60 then
                            FirebaseActiveUsers[userIdStr] = info
                            table.insert(userNames, info.username)
                        end
                    end
                    
                    if Settings.ShowTags then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if FirebaseActiveUsers[tostring(player.UserId)] or IsAdmin(player.UserId) then
                                if not ActiveTags[player] then
                                    applyOverheadTag(player)
                                end
                            else
                                cleanTag(player)
                            end
                        end
                    end
                end
                
                if IsAdmin(LocalPlayer.UserId) and PlayersScroll then
                    for _, child in ipairs(PlayersScroll:GetChildren()) do
                        if child:IsA("TextButton") or child:IsA("TextLabel") then
                            child:Destroy()
                        end
                    end

                    local count = 0
                    for userIdStr, info in pairs(FirebaseActiveUsers) do
                        count = count + 1
                        local pBtn = Instance.new("TextButton")
                        pBtn.Size = UDim2.new(1, -5, 0, 30)
                        pBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                        pBtn.Text = " " .. info.username .. " (" .. userIdStr .. ")"
                        pBtn.TextColor3 = COLORS.GreyLight
                        pBtn.Font = FONTS.Bold
                        pBtn.TextSize = 12
                        pBtn.TextXAlignment = Enum.TextXAlignment.Left
                        pBtn.AutoButtonColor = false
                        pBtn.Parent = PlayersScroll
                        createCorner(pBtn, 4)
                        createStroke(pBtn, COLORS.Border, 1, 0.5)
                        BindInteractionSounds(pBtn)
                        
                        pBtn.MouseEnter:Connect(function()
                            TweenService:Create(pBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = COLORS.White}):Play()
                        end)
                        pBtn.MouseLeave:Connect(function()
                            TweenService:Create(pBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = COLORS.GreyLight}):Play()
                        end)
                        
                        pBtn.MouseButton1Click:Connect(function()
                            if setclipboard then
                                setclipboard(userIdStr)
                                pBtn.Text = " Copied ID to Clipboard!"
                                pBtn.TextColor3 = Color3.fromRGB(46, 125, 50)
                                task.wait(1.5)
                                if pBtn and pBtn.Parent then
                                    pBtn.Text = " " .. info.username .. " (" .. userIdStr .. ")"
                                    pBtn.TextColor3 = COLORS.White
                                end
                            end
                        end)
                    end

                    if count == 0 then
                        local emptyLbl = Instance.new("TextLabel")
                        emptyLbl.Size = UDim2.new(1, 0, 0, 30)
                        emptyLbl.BackgroundTransparency = 1
                        emptyLbl.Text = "No active users found."
                        emptyLbl.TextColor3 = COLORS.GreyMuted
                        emptyLbl.Font = FONTS.Medium
                        emptyLbl.TextSize = 12
                        emptyLbl.Parent = PlayersScroll
                    end
                end
            end
        end
    end
end)

local function managePlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if FirebaseActiveUsers[tostring(player.UserId)] or IsAdmin(player.UserId) then 
            applyOverheadTag(player) 
        end
    end)
    if FirebaseActiveUsers[tostring(player.UserId)] or IsAdmin(player.UserId) then 
        applyOverheadTag(player) 
    end
end

Players.PlayerAdded:Connect(managePlayer)
Players.PlayerRemoving:Connect(cleanTag)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then managePlayer(p) end end
if IsAdmin(LocalPlayer.UserId) then managePlayer(LocalPlayer) end

updateOverheadVisibility = function()
    if Settings.ShowTags then
        for _, p in ipairs(Players:GetPlayers()) do
            if FirebaseActiveUsers[tostring(p.UserId)] or IsAdmin(p.UserId) then applyOverheadTag(p) end
        end
    else
        for p, _ in pairs(ActiveTags) do cleanTag(p) end
    end
end

RunService.Heartbeat:Connect(function()
    local clock = tick()
    for player, data in pairs(ActiveTags) do
        pcall(function()
            if data.Gui and data.TextLabel then
                if data.Rank == 4 or data.UserId == CREATOR_ID then
                    local formula = (math.sin(clock * 4.5) + 1) / 2
                    local customRed = Color3.fromRGB(229, 9, 20)
                    local customBlack = Color3.fromRGB(15, 15, 15)
                    local lerpedColor = customBlack:Lerp(customRed, formula)
                    data.TextLabel.TextColor3 = lerpedColor
                    data.Stroke.Color = lerpedColor
                elseif data.Rank == 3 or (data.UserId == CO_FOUNDER_ID and data.Gradient) then
                    if data.Gradient then data.Gradient.Offset = Vector2.new(math.sin(clock * 1.5), 0) end
                    data.Stroke.Color = Color3.fromRGB(255, 215, 0)
                elseif data.Rank == 2 then
                    local formula = (math.sin(clock * 3.5) + 1) / 2
                    local neonAdmin = Color3.fromRGB(180, 0, 255)
                    local dimAdmin = Color3.fromRGB(40, 0, 60)
                    local lerpedAdmin = dimAdmin:Lerp(neonAdmin, formula)
                    data.TextLabel.TextColor3 = lerpedAdmin
                    data.Stroke.Color = lerpedAdmin
                else
                    local formula = (math.sin(clock * 3) + 1) / 2
                    local neonBase = Color3.fromRGB(0, 220, 255)
                    local dimBase = Color3.fromRGB(0, 60, 80)
                    local lerpedGlow = dimBase:Lerp(neonBase, formula)
                    data.TextLabel.TextColor3 = lerpedGlow
                    data.Stroke.Color = lerpedGlow
                end
            end
        end)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if LoopKillTargets[player.UserId] and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then hum.Health = 0 end
        end
        if SpinTargets[player.UserId] and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(25), 0)
            end
        end
    end
end)

updateDynamicThemeColors(CurrentThemeColor)

-- ============================================================================
-- NETFLIX THEME PASS  (visual only, no logic changes)
--
-- WHERE TO PASTE:
--   Directly AFTER this existing line near the bottom of your script:
--       updateDynamicThemeColors(CurrentThemeColor)
--   and BEFORE:
--       if isUserBlacklisted then
--
-- Design read: streaming-service overlay for gamers, Netflix language,
-- dials ~ variance 4 / motion 5 / density 4. Everything is wrapped in pcall,
-- so a failure in one section can never break the hub itself.
-- ============================================================================
function ANNetflixThemeApply()

if not (MainFrame and HeaderBar and isMobile and updateTabLine) then
    warn("[AN Netflix theme] This file is not a standalone script. Paste its contents INTO your main AN Universal script (after updateDynamicThemeColors(CurrentThemeColor)), then run the main script.")
    return
end

local NF = {
    White   = Color3.fromRGB(255, 255, 255),
    Black   = Color3.fromRGB(0, 0, 0),
    Bg      = Color3.fromRGB(20, 20, 20),      -- Netflix #141414
    Nav     = Color3.fromRGB(10, 10, 10),
    Ink     = Color3.fromRGB(229, 229, 229),   -- #E5E5E5
    Muted   = Color3.fromRGB(179, 179, 179),   -- #B3B3B3
    Ghost   = Color3.fromRGB(109, 109, 110),   -- "More Info" grey #6D6D6E
}

local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then warn("[AN Netflix theme] " .. label .. ": " .. tostring(err)) end
end

local function tween(obj, t, props, style, dir)
    TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function ensure(parent, class, name)
    local o = parent:FindFirstChild(name)
    if not o then
        o = Instance.new(class)
        o.Name = name
        o.Parent = parent
    end
    return o
end

local function setCorner(obj, r)
    local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

local isMob = isMobile()

-- ---------------------------------------------------------------------------
-- 1. WINDOW + TOP NAV  (near-black canvas, fading nav bar, glossy wordmark)
-- ---------------------------------------------------------------------------
try("window", function()
    MainFrame.BackgroundColor3 = NF.Bg
    setCorner(MainFrame, 8)

    HeaderBar.BackgroundColor3 = NF.Nav
    for _, c in ipairs(HeaderBar:GetChildren()) do
        -- the square "bottom cover" strip is no longer needed with a gradient nav
        if c:IsA("Frame") and c.Size.Y.Scale == 0 and c.Size.Y.Offset == 10 then
            c.BackgroundTransparency = 1
        end
    end
    local fade = ensure(HeaderBar, "UIGradient", "NFNavFade")
    fade.Rotation = 90
    fade.Transparency = NumberSequence.new(0, 0.55) -- solid at top, melts into content
end)

try("wordmark", function()
    BrandLogo.TextSize = 22
    local g = ensure(BrandLogo, "UIGradient", "NFWordmarkShine")
    g.Rotation = 90
    g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(165, 165, 165))
end)

-- ---------------------------------------------------------------------------
-- 2. TAB NAV  (white = active, grey = inactive, hover lift, bigger touch size)
-- ---------------------------------------------------------------------------
local navTabs = {MoviesTab, ExecutorTab, PiratedTab, SettingsTab, CreditsTab}
if AdminTab then table.insert(navTabs, AdminTab) end

try("tabs", function()
    for _, tab in ipairs(navTabs) do
        tab.Size = UDim2.new(0, tab.Size.X.Offset + 6, 0, isMob and 36 or 30)
        tab.TextSize = 13
        tab.TextColor3 = NF.Muted
        tab.MouseEnter:Connect(function()
            if not tab:GetAttribute("ANActive") then tween(tab, 0.12, {TextColor3 = NF.White}) end
        end)
        tab.MouseLeave:Connect(function()
            if not tab:GetAttribute("ANActive") then tween(tab, 0.12, {TextColor3 = NF.Muted}) end
        end)
    end

    local origUpdateTabLine = updateTabLine
    updateTabLine = function(targetTab)
        origUpdateTabLine(targetTab)
        for _, tab in ipairs(navTabs) do
            local active = (tab == targetTab)
            tab:SetAttribute("ANActive", active)
            tab.Font = active and FONTS.Bold or FONTS.Medium
            tween(tab, 0.2, {TextColor3 = active and NF.White or NF.Muted})
        end
    end
end)

-- ---------------------------------------------------------------------------
-- 3. FILTER ROW  (outlined search + genre like the Netflix browse bar)
-- ---------------------------------------------------------------------------
try("filters", function()
    GenreBtn.BackgroundColor3 = NF.Black
    local gStroke = GenreBtn:FindFirstChildOfClass("UIStroke")
    if gStroke then gStroke.Color = NF.Ghost; gStroke.Transparency = 0.1 end

    local searchFrame = SearchBox.Parent
    searchFrame.BackgroundColor3 = NF.Black
    local sStroke = searchFrame:FindFirstChildOfClass("UIStroke")
    if sStroke then sStroke.Color = NF.Ghost; sStroke.Transparency = 0.25 end

    -- white outline while typing (Netflix search behaviour)
    SearchBox.Focused:Connect(function()
        searchFrame.BackgroundColor3 = NF.Black
        if sStroke then tween(sStroke, 0.15, {Color = NF.White, Transparency = 0}) end
    end)
    SearchBox.FocusLost:Connect(function()
        searchFrame.BackgroundColor3 = NF.Black
        if sStroke then tween(sStroke, 0.15, {Color = NF.Ghost, Transparency = 0.25}) end
    end)
end)

-- ---------------------------------------------------------------------------
-- 4. CAROUSEL  (edge-to-edge arrows, row title, hover ring, caption scrim)
-- ---------------------------------------------------------------------------
local RowTitle
try("arrows + row title", function()
    for _, arrow in ipairs({LeftArrow, RightArrow}) do
        local right = (arrow.Name == "RightArrow")
        arrow.AnchorPoint = Vector2.new(right and 1 or 0, 0)
        arrow.Position = UDim2.new(right and 1 or 0, 0, 0, 0)
        arrow.Size = UDim2.new(0, isMob and 36 or 34, 1, 0)
        arrow.BackgroundColor3 = NF.Black
        arrow.BackgroundTransparency = 0.45
        arrow.TextColor3 = NF.White
        arrow.TextSize = 24
        arrow.Font = FONTS.Bold
        setCorner(arrow, 4)
        local st = arrow:FindFirstChildOfClass("UIStroke")
        if st then st:Destroy() end
        arrow.MouseEnter:Connect(function() tween(arrow, 0.12, {BackgroundTransparency = 0.15}) end)
        arrow.MouseLeave:Connect(function() tween(arrow, 0.12, {BackgroundTransparency = 0.45}) end)
    end

    RowTitle = ensure(CarouselContainer, "TextLabel", "NFRowTitle")
    RowTitle.BackgroundTransparency = 1
    RowTitle.Size = UDim2.new(1, -90, 0, 20)
    RowTitle.Position = UDim2.new(0, 44, 0, 1)
    RowTitle.Font = FONTS.Bold
    RowTitle.TextSize = 15
    RowTitle.TextColor3 = NF.Ink
    RowTitle.TextXAlignment = Enum.TextXAlignment.Left
    RowTitle.ZIndex = 9
    RowTitle.Text = "All Titles"

    -- hide the row title on very short (small mobile) windows so it never overlaps posters
    local function syncRowTitle()
        RowTitle.Visible = CarouselContainer.AbsoluteSize.Y >= 250
    end
    syncRowTitle()
    CarouselContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncRowTitle)
end)

local function decorateCards()
    for _, card in ipairs(MovieCarousel:GetChildren()) do
        if card:IsA("Frame") then
            local idx = tonumber(card.Name:match("^Card_(%d+)$"))
            local poster = card:FindFirstChild("PosterImg")
            local movie = idx and visibleMovies[idx]
            if poster and movie and not poster:FindFirstChild("NFRing") then
                setCorner(poster, 4)

                local ring = Instance.new("UIStroke")
                ring.Name = "NFRing"
                ring.Color = NF.White
                ring.Thickness = 2
                ring.Transparency = 1
                ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ring.Parent = poster

                -- bottom scrim + title (only visible on the focused card)
                local cap = Instance.new("Frame")
                cap.Name = "NFCaption"
                cap.AnchorPoint = Vector2.new(0, 1)
                cap.Position = UDim2.new(0, 0, 1, 0)
                cap.Size = UDim2.new(1, 0, 0, 54)
                cap.BackgroundColor3 = NF.Black
                cap.BackgroundTransparency = 1
                cap.BorderSizePixel = 0
                cap.ZIndex = 5
                cap.Parent = poster
                setCorner(cap, 4)

                local scrim = Instance.new("UIGradient")
                scrim.Rotation = 90
                scrim.Transparency = NumberSequence.new(1, 0.02)
                scrim.Parent = cap

                local title = Instance.new("TextLabel")
                title.Name = "NFTitle"
                title.BackgroundTransparency = 1
                title.Size = UDim2.new(1, -12, 1, -8)
                title.Position = UDim2.new(0, 6, 0, 0)
                title.Font = FONTS.Bold
                title.TextSize = 11
                title.TextColor3 = NF.White
                title.TextTransparency = 1
                title.TextWrapped = true
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextYAlignment = Enum.TextYAlignment.Bottom
                title.Text = tostring(movie.Title or "")
                title.ZIndex = 6
                title.Parent = cap

                -- small brand tab, top-left (Netflix "N" original badge)
                local badge = Instance.new("TextLabel")
                badge.Name = "NFBadge"
                badge.Size = UDim2.new(0, 22, 0, 14)
                badge.Position = UDim2.new(0, 4, 0, 4)
                badge.BackgroundColor3 = COLORS.BrandRed
                badge.BorderSizePixel = 0
                badge.Text = "AN"
                badge.TextColor3 = NF.White
                badge.Font = FONTS.Heavy
                badge.TextSize = 9
                badge.ZIndex = 5
                badge.Parent = poster
                setCorner(badge, 2)
            end
        end
    end
end

local function refreshOverlays()
    for _, card in ipairs(MovieCarousel:GetChildren()) do
        if card:IsA("Frame") then
            local idx = tonumber(card.Name:match("^Card_(%d+)$"))
            local poster = card:FindFirstChild("PosterImg")
            if idx and poster then
                local center = (idx == currentIndex)
                local ring = poster:FindFirstChild("NFRing")
                local cap = poster:FindFirstChild("NFCaption")
                if ring then tween(ring, 0.2, {Transparency = center and 0 or 1}) end
                if cap then
                    tween(cap, 0.25, {BackgroundTransparency = center and 0 or 1})
                    local t = cap:FindFirstChild("NFTitle")
                    if t then tween(t, 0.25, {TextTransparency = center and 0 or 1}) end
                end
            end
        end
    end
end

try("card hooks", function()
    local origLayout = layoutCards
    layoutCards = function(instant)
        origLayout(instant)
        pcall(decorateCards)
        pcall(refreshOverlays)
    end

    -- Netflix-style pagination bars instead of dots (inactive stays <= 10px wide so
    -- the theme-colour recolour logic still only targets the active bar)
    local origDots = updateDots
    updateDots = function()
        origDots()
        for _, d in ipairs(DotsHolder:GetChildren()) do
            if d:IsA("Frame") then
                local active = d.Size.X.Offset > 10
                d.Size = UDim2.new(0, active and 22 or 8, 0, 3)
            end
        end
    end

    local origUpdateCarousel = updateCarousel
    updateCarousel = function()
        if origUpdateCarousel then origUpdateCarousel() end
        if RowTitle then
            local name = (CurrentGenre == "All") and "All Titles" or CurrentGenre
            RowTitle.Text = name .. "  ·  " .. tostring(#visibleMovies)
        end
    end
end)

-- ---------------------------------------------------------------------------
-- 5. DETAIL SCREEN  (ambient red glow, white Play button, grey ghost buttons)
-- ---------------------------------------------------------------------------
try("detail", function()
    local glow = ensure(DetailFrame, "Frame", "NFHeroGlow")
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundColor3 = COLORS.BrandRed
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    local gg = ensure(glow, "UIGradient", "NFGlowGradient")
    gg.Rotation = 35
    gg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.84),
        NumberSequenceKeypoint.new(0.55, 1),
        NumberSequenceKeypoint.new(1, 1),
    })

    setCorner(DetailImage, 4)
    DetailTitle.TextSize = isMob and 20 or 26
    MetaRow.TextColor3 = NF.Muted
    DetailDescription.TextColor3 = NF.Ink
    DetailDescription.LineHeight = 1.15
end)

local function styleDetailButtons()
    PlayBtn.BackgroundColor3 = NF.White
    PlayBtn.TextColor3 = NF.Black
    PlayBtn.Font = FONTS.Bold
    PlayBtn.TextSize = 14

    for _, b in ipairs({FavBtn, BackBtn}) do
        b.BackgroundColor3 = NF.Ghost
        b.BackgroundTransparency = 0.3
        b.TextColor3 = NF.White
    end
end

try("detail buttons", function()
    styleDetailButtons()

    -- the ONLY hover handlers for these buttons (the originals were deleted: Roblox does
    -- not guarantee handler order, so two sets of tweens on one property race each other)
    PlayBtn.MouseEnter:Connect(function() tween(PlayBtn, 0.12, {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}) end)
    PlayBtn.MouseLeave:Connect(function() tween(PlayBtn, 0.12, {BackgroundColor3 = NF.White}) end)
    for _, b in ipairs({FavBtn, BackBtn}) do
        b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundColor3 = NF.Ghost, BackgroundTransparency = 0.55}) end)
        b.MouseLeave:Connect(function() tween(b, 0.12, {BackgroundColor3 = NF.Ghost, BackgroundTransparency = 0.3}) end)
    end

    -- the theme picker repaints PlayBtn red; re-apply the white Play look afterwards
    local origTheme = updateDynamicThemeColors
    updateDynamicThemeColors = function(newColor)
        origTheme(newColor)
        pcall(styleDetailButtons)
    end
end)

end

ANNetflixThemeApply()

-- ============================================================================
-- NETFLIX FONTS  (Bebas Neue + Figtree + JetBrains Mono)
-- Paste directly AFTER the line:  ANNetflixThemeApply()
-- Downloads once into the AN/ folder, then loads from cache. If the executor has
-- no custom-font support (or a download fails) the UI simply keeps Gotham.
-- ============================================================================
function ANNetflixFonts()

local getAsset = getcustomasset or getsynasset
if not (ScreenGui and writefile and isfile and readfile and getAsset and Font and Font.new) then
    warn("[AN Netflix fonts] Executor lacks custom font support - keeping default fonts.")
    return
end

local BASE = "https://github.com/GUICLOUDS/LRC/raw/refs/heads/main/"
local SPECS = {
    Bebas     = {file = "BebasNeue-Regular.otf",                     ext = "otf", num = 400, weight = Enum.FontWeight.Regular},
    FigBold   = {file = "Figtree-Bold.ttf",                          ext = "ttf", num = 700, weight = Enum.FontWeight.Bold},
    FigMedium = {file = "Figtree-Medium.ttf",                        ext = "ttf", num = 500, weight = Enum.FontWeight.Medium},
    FigReg    = {file = "Figtree-Regular.ttf",                       ext = "ttf", num = 400, weight = Enum.FontWeight.Regular},
    Mono      = {file = "jetbrains-mono-regular-6_ufonts.com.ttf",   ext = "ttf", num = 400, weight = Enum.FontWeight.Regular},
}

-- Gotham (and default) faces -> replacement
local ENUM_MAP = {
    [Enum.Font.GothamBlack]       = "FigBold",
    [Enum.Font.GothamBold]        = "FigBold",
    [Enum.Font.GothamMedium]      = "FigMedium",
    [Enum.Font.Gotham]            = "FigReg",
    [Enum.Font.SourceSans]        = "FigReg",
    [Enum.Font.SourceSansSemibold]= "FigMedium",
    [Enum.Font.SourceSansBold]    = "FigBold",
    [Enum.Font.Code]              = "Mono",
}

local loaded = {}

local function validFont(d)
    if type(d) ~= "string" or #d < 4096 then return false end
    local m = d:sub(1, 4)
    return m == "\0\1\0\0" or m == "OTTO" or m == "true" or m == "ttcf"
end

local function fetch(url)
    if http_request then
        local ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and type(res.Body) == "string" then
            local code = tonumber(res.StatusCode or res.status_code)
            if not code or code == 200 then return res.Body end
        end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    return ok and body or nil
end

local function loadOne(key, spec)
    local path = "AN/NFX_FONT_" .. key .. "." .. spec.ext
    local data
    if isfile(path) then
        local okRead, cached = pcall(readfile, path)
        if okRead and validFont(cached) then data = cached end
    end
    if not data then
        local body = fetch(BASE .. spec.file)
        if not validFont(body) then return end
        data = body
        if not pcall(writefile, path, data) then return end
    end

    local ok, font = pcall(function()
        local jsonPath = "AN/NFX_FONT_" .. key .. ".json"
        writefile(jsonPath, HttpService:JSONEncode({
            name = "AN" .. key,
            faces = {{name = "Regular", weight = spec.num, style = "normal", assetId = getAsset(path)}}
        }))
        return Font.new(getAsset(jsonPath), spec.weight, Enum.FontStyle.Normal)
    end)
    if ok and font then loaded[key] = font end
end

local function isTextObj(o)
    return o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")
end

local function hookText(obj)
    if not isTextObj(obj) then return end
    local busy = false
    local function apply()
        if busy then return end
        local key = obj:GetAttribute("ANFace") or ENUM_MAP[obj.Font]
        local face = key and loaded[key]
        if face then
            busy = true
            pcall(function() obj.FontFace = face end)
            busy = false
        end
    end
    apply()
    if not obj:GetAttribute("ANFontHooked") then
        obj:SetAttribute("ANFontHooked", true)
        obj:GetPropertyChangedSignal("Font"):Connect(apply)
    end
end

task.spawn(function()
    -- download / load all five in parallel
    local pending = 0
    for key, spec in pairs(SPECS) do
        pending = pending + 1
        task.spawn(function()
            pcall(loadOne, key, spec)
            pending = pending - 1
        end)
    end
    local waited = 0
    while pending > 0 and waited < 20 do task.wait(0.1); waited = waited + 0.1 end

    if next(loaded) == nil then
        warn("[AN Netflix fonts] No fonts could be loaded - keeping default fonts.")
        return
    end

    -- Bebas Neue for the "Netflix wordmark" style headings (it is condensed, so bump the size once)
    if loaded.Bebas then
        local bebasTargets = {BrandLogo, DetailTitle, CreditsBigN, ScreenGui:FindFirstChild("NFRowTitle", true)}
        for _, obj in ipairs(bebasTargets) do
            if obj and not obj:GetAttribute("ANBebasScaled") then
                obj:SetAttribute("ANBebasScaled", true)
                obj:SetAttribute("ANFace", "Bebas")
                obj.TextSize = math.floor(obj.TextSize * 1.3)
            end
        end
    end

    for _, d in ipairs(ScreenGui:GetDescendants()) do hookText(d) end
    -- anything created later (cards, comments, tabs, notifications...) gets styled too
    ScreenGui.DescendantAdded:Connect(function(d) task.defer(hookText, d) end)
end)

end

ANNetflixFonts()

-- ============================================================================
-- NETFLIX RESPONSIVE PASS  (mobile + PC, visual / input only)
-- Paste directly AFTER the line:  ANNetflixFonts()
--
-- What it does
--   * Window fits the screen instead of shrinking the layout (bigger on phones)
--   * 40px+ touch targets, readable minimum text size on mobile
--   * Swipe left/right on the poster row (mobile)
--   * Arrow keys / Enter / Backspace (PC) and D-pad / A / B (gamepad)
--   * Pirated result grid fills the width with 1-3 columns automatically
-- ============================================================================
function ANNetflixResponsive()

if not (MainFrame and getTargetSize and shiftCarousel and viewDetailScreen and routeToView and CarouselContainer) then
    warn("[AN Netflix responsive] Paste this INTO the main script after ANNetflixFonts().")
    return
end

local isMob = isMobile()

local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then warn("[AN Netflix responsive] " .. label .. ": " .. tostring(err)) end
end

-- ---------------------------------------------------------------------------
-- 1. WINDOW SIZE  (fit the screen; text stays readable instead of shrinking)
-- ---------------------------------------------------------------------------
try("window size", function()
    getTargetSize = function()
        local vp = Camera.ViewportSize
        local w, h
        if isMobile() then
            w = math.min(vp.X - 32, 720)
            h = math.min(vp.Y - 24, 440)
        else
            w = math.min(WindowConfig.Width, vp.X - 24)
            h = math.min(WindowConfig.Height, vp.Y - 24)
        end
        return UDim2.new(0, math.max(w, 480), 0, math.max(h, 280))
    end

    local s = getTargetSize()
    MainFrame.Size = s
    MainFrame.Position = UDim2.new(0.5, -s.X.Offset / 2, 0.5, -s.Y.Offset / 2)
    cachedWindowPos = MainFrame.Position
end)

-- ---------------------------------------------------------------------------
-- 2. TOUCH TARGETS + MINIMUM TEXT SIZE (mobile only)
-- ---------------------------------------------------------------------------
if isMob then
    try("touch targets", function()
        local filterRow = GenreBtn.Parent
        if filterRow then filterRow.Size = UDim2.new(1, -36, 0, 40) end

        GenreDropdown.Size = UDim2.new(0, 150, 0, 170)
        for _, b in ipairs(GenreDropdown:GetChildren()) do
            if b:IsA("TextButton") then
                b.Size = UDim2.new(1, -6, 0, 34)
                b.TextSize = 13
            end
        end

        MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
        local mc = MinimizeBtn:FindFirstChildOfClass("UICorner")
        if mc then mc.CornerRadius = UDim.new(0, 16) end
        MinimizeBtn.TextSize = 16
    end)

    try("min text size", function()
        local function bump(o)
            if (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox"))
                and not o.TextScaled and o.TextSize < 10 then
                o.TextSize = 10
            end
        end
        for _, d in ipairs(ScreenGui:GetDescendants()) do bump(d) end
        ScreenGui.DescendantAdded:Connect(function(d) task.defer(bump, d) end)
    end)
end

-- ---------------------------------------------------------------------------
-- 3. SWIPE ON THE POSTER ROW (touch)
-- ---------------------------------------------------------------------------
try("swipe", function()
    local touches = {}

    local function insideCarousel(p)
        local a, s = CarouselContainer.AbsolutePosition, CarouselContainer.AbsoluteSize
        local inset = GuiService:GetGuiInset().Y
        local function hit(y) return p.X >= a.X and p.X <= a.X + s.X and y >= a.Y and y <= a.Y + s.Y end
        return hit(p.Y) or hit(p.Y + inset)
    end

    -- while a swipe is happening, cards must not register it as a tap
    local function suppressTaps()
        for _, card in ipairs(MovieCarousel:GetChildren()) do
            local b = card:FindFirstChildOfClass("TextButton")
            if b then b.Active = false end
        end
        task.delay(0.4, function()
            for _, card in ipairs(MovieCarousel:GetChildren()) do
                local b = card:FindFirstChildOfClass("TextButton")
                if b then b.Active = true end
            end
        end)
    end

    UserInputService.TouchStarted:Connect(function(t)
        if activeView ~= "menu" or not MainFrame.Visible then return end
        if insideCarousel(t.Position) then
            touches[t] = {x = t.Position.X, y = t.Position.Y, done = false}
        end
    end)

    UserInputService.TouchMoved:Connect(function(t)
        local rec = touches[t]
        if not rec or rec.done then return end
        local dx, dy = t.Position.X - rec.x, t.Position.Y - rec.y
        if math.abs(dx) > 48 and math.abs(dx) > math.abs(dy) * 1.5 then
            rec.done = true
            suppressTaps()
            shiftCarousel(dx < 0 and 1 or -1)
        end
    end)

    UserInputService.TouchEnded:Connect(function(t) touches[t] = nil end)
end)

-- ---------------------------------------------------------------------------
-- 4. KEYBOARD / GAMEPAD  (PC + console-style controllers)
-- ---------------------------------------------------------------------------
try("keyboard + gamepad", function()
    local K = Enum.KeyCode
    local function openCenter()
        local movie = visibleMovies[currentIndex]
        if not movie then return end
        if movie.Kind == "pirated" and viewPiratedFavoriteDetail then
            viewPiratedFavoriteDetail(movie)
        else
            viewDetailScreen(movie)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not MainFrame.Visible then return end
        local k = input.KeyCode
        if activeView == "menu" then
            if k == K.Left or k == K.DPadLeft then
                shiftCarousel(-1)
            elseif k == K.Right or k == K.DPadRight then
                shiftCarousel(1)
            elseif k == K.Return or k == K.KeypadEnter or k == K.ButtonA then
                openCenter()
            end
        elseif activeView == "detail" then
            if k == K.Backspace or k == K.ButtonB then
                clearPiratedImageCache()
                routeToView("menu")
                updateTabLine(MoviesTab)
            end
        end
    end)
end)

-- ---------------------------------------------------------------------------
-- 5. ADAPTIVE PIRATED GRID  (fills the width with 1-3 columns)
-- ---------------------------------------------------------------------------
try("pirated grid", function()
    if not (PiratedResults and PiratedGrid) then return end

    local function applyGrid()
        local gap = 10
        local minCell = isMobile() and 300 or 205
        local width = PiratedResults.AbsoluteSize.X - 8 -- room for the scrollbar
        if width <= 0 then return end
        local cols = math.clamp(math.floor((width + gap) / (minCell + gap)), 1, 3)
        local cellW = math.floor((width - gap * (cols - 1)) / cols)
        PiratedGrid.CellPadding = UDim2.new(0, gap, 0, gap)
        PiratedGrid.CellSize = UDim2.new(0, cellW, 0, isMobile() and 168 or 184)
    end

    applyGrid()
    PiratedResults:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyGrid)
    -- the original viewport handler also writes CellSize; run after it
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() task.defer(applyGrid) end)
end)

end

ANNetflixResponsive()

-- ============================================================================
-- NETFLIX PIRATED SECTION PASS
-- Paste directly AFTER the line:  ANNetflixResponsive()
--
--   1. Terms & Agreement popup when the Pirated section opens
--        - shows once per session (every time the hub is executed / you rejoin)
--        - unless the user ticks "Don't show this again" (saved to AN/NFX_Settings.json)
--        - Settings tab gets a "Pirated Terms Notice" switch to bring it back
--   2. Comments: long comments no longer get cut off, plus a comment counter
--   3. Favoriting: clear "In My List" state + small confirmation toast
--   4. Executing: button turns green on success / red on failure
--   5. Safety banner on unverified, key-system and patched scripts
--   6. Layout fix: "CREATOR TAGS" label was rendering above the Back button
-- ============================================================================
function ANNetflixPirated()

if not (MainFrame and routeToView and PiratedFrame and Settings and saveSettings
        and SettingsScroll and updateTabLine and MoviesTab) then
    warn("[AN Netflix pirated] Paste this INTO the main script after ANNetflixResponsive().")
    return
end

local PiratedDetail = PiratedFrame:FindFirstChild("PiratedDetail")
if not PiratedDetail then
    warn("[AN Netflix pirated] PiratedDetail not found - skipping.")
    return
end

local NF = {
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Ink   = Color3.fromRGB(229, 229, 229),
    Muted = Color3.fromRGB(179, 179, 179),
    Ghost = Color3.fromRGB(109, 109, 110),
    Card  = Color3.fromRGB(24, 24, 24),
    Green = Color3.fromRGB(46, 125, 50),
    Red   = Color3.fromRGB(198, 40, 40),
}

local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then warn("[AN Netflix pirated] " .. label .. ": " .. tostring(err)) end
end

local function tween(obj, t, props, style, dir)
    TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function setCorner(obj, r)
    local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

local function addStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

-- small confirmation pill at the bottom of the window
local function toast(text)
    local t = Instance.new("TextLabel")
    t.AutomaticSize = Enum.AutomaticSize.X
    t.Size = UDim2.new(0, 0, 0, 34)
    t.AnchorPoint = Vector2.new(0.5, 1)
    t.Position = UDim2.new(0.5, 0, 1, 40)
    t.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    t.TextColor3 = NF.White
    t.Font = FONTS.Bold
    t.TextSize = 12
    t.Text = text
    t.ZIndex = 250
    t.Parent = MainFrame
    setCorner(t, 17)
    addStroke(t, Color3.fromRGB(70, 70, 70), 1, 0.2)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 16)
    pad.PaddingRight = UDim.new(0, 16)
    pad.Parent = t
    tween(t, 0.25, {Position = UDim2.new(0.5, 0, 1, -16)}, Enum.EasingStyle.Cubic)
    task.delay(1.8, function()
        if not t.Parent then return end
        tween(t, 0.2, {Position = UDim2.new(0.5, 0, 1, 40)})
        task.delay(0.22, function() if t.Parent then t:Destroy() end end)
    end)
end

-- ---------------------------------------------------------------------------
-- 1. TERMS & AGREEMENT
-- ---------------------------------------------------------------------------
local termsOpen = false
local sessionAccepted = false

local function showTerms()
    if termsOpen then return end
    termsOpen = true

    local W = math.min(440, MainFrame.AbsoluteSize.X - 32)
    local H = math.min(350, MainFrame.AbsoluteSize.Y - 24)

    local overlay = Instance.new("Frame")
    overlay.Name = "NFTermsOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = NF.Black
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Active = true -- swallow clicks so nothing underneath can be used
    overlay.ZIndex = 400
    overlay.Parent = MainFrame
    setCorner(overlay, 10)
    tween(overlay, 0.18, {BackgroundTransparency = 0.3})

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.Size = UDim2.new(0, W, 0, H)
    card.BackgroundColor3 = NF.Card
    card.BorderSizePixel = 0
    card.ZIndex = 401
    card.Parent = overlay
    setCorner(card, 8)
    addStroke(card, Color3.fromRGB(60, 60, 60), 1, 0.2)

    local scale = Instance.new("UIScale")
    scale.Scale = 0.94
    scale.Parent = card
    tween(scale, 0.2, {Scale = 1}, Enum.EasingStyle.Cubic)

    local kicker = Instance.new("TextLabel")
    kicker.BackgroundTransparency = 1
    kicker.Position = UDim2.new(0, 16, 0, 14)
    kicker.Size = UDim2.new(1, -32, 0, 14)
    kicker.Font = FONTS.Bold
    kicker.TextSize = 10
    kicker.TextColor3 = COLORS.BrandRed
    kicker.TextXAlignment = Enum.TextXAlignment.Left
    kicker.Text = "THIRD-PARTY SCRIPTS"
    kicker.ZIndex = 402
    kicker.Parent = card

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Position = UDim2.new(0, 16, 0, 28)
    heading.Size = UDim2.new(1, -32, 0, 28)
    heading.Font = FONTS.Heavy
    heading.TextSize = 20
    heading.TextColor3 = NF.White
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Text = "Terms & Agreement"
    heading.ZIndex = 402
    heading.Parent = card

    -- scrolling body so it still fits on short phone windows
    local body = Instance.new("ScrollingFrame")
    body.BackgroundTransparency = 1
    body.BorderSizePixel = 0
    body.Position = UDim2.new(0, 16, 0, 64)
    body.Size = UDim2.new(1, -32, 1, -166)
    body.ScrollBarThickness = 3
    body.ScrollBarImageColor3 = COLORS.BrandRed
    body.CanvasSize = UDim2.new(0, 0, 0, 0)
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.ZIndex = 402
    body.Parent = card

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0, 8)
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bodyLayout.Parent = body

    local paragraphs = {
        {"Scripts in the Pirated section are made by other people and hosted on third-party sites. AN Universal does not write, review or control them.", NF.Ink},
        {"By continuing, you accept that AN Universal and its team are not responsible if your account, device or data is compromised, or if a script adds or changes files in your executor's workspace without you knowing.", NF.Ink},
        {"Only run scripts from creators you trust, and check what a script does before you execute it.", NF.Muted},
    }
    for i, p in ipairs(paragraphs) do
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.AutomaticSize = Enum.AutomaticSize.Y
        lbl.Size = UDim2.new(1, -8, 0, 0)
        lbl.Font = FONTS.Book
        lbl.TextSize = 13
        lbl.TextColor3 = p[2]
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.Text = p[1]
        lbl.LayoutOrder = i
        lbl.ZIndex = 403
        lbl.Parent = body
    end

    -- "Don't show this again" checkbox (whole row is the tap target)
    local checked = false
    local row = Instance.new("TextButton")
    row.Text = ""
    row.AutoButtonColor = false
    row.BackgroundTransparency = 1
    row.AnchorPoint = Vector2.new(0, 1)
    row.Position = UDim2.new(0, 16, 1, -66)
    row.Size = UDim2.new(1, -32, 0, 34)
    row.ZIndex = 402
    row.Parent = card
    BindInteractionSounds(row)

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 0, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    box.BorderSizePixel = 0
    box.ZIndex = 403
    box.Parent = row
    setCorner(box, 4)
    local boxStroke = addStroke(box, NF.Ghost, 1.5, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 12, 0, 12)
    fill.Position = UDim2.new(0.5, -6, 0.5, -6)
    fill.BackgroundColor3 = COLORS.BrandRed
    fill.BorderSizePixel = 0
    fill.Visible = false
    fill.ZIndex = 404
    fill.Parent = box
    setCorner(fill, 2)

    local rowLabel = Instance.new("TextLabel")
    rowLabel.BackgroundTransparency = 1
    rowLabel.Position = UDim2.new(0, 30, 0, 0)
    rowLabel.Size = UDim2.new(1, -30, 1, 0)
    rowLabel.Font = FONTS.Medium
    rowLabel.TextSize = 13
    rowLabel.TextColor3 = NF.Muted
    rowLabel.TextXAlignment = Enum.TextXAlignment.Left
    rowLabel.Text = "Don't show this again"
    rowLabel.ZIndex = 403
    rowLabel.Parent = row

    row.MouseButton1Click:Connect(function()
        checked = not checked
        fill.Visible = checked
        boxStroke.Color = checked and NF.White or NF.Ghost
        rowLabel.TextColor3 = checked and NF.White or NF.Muted
    end)

    -- buttons
    local btnRow = Instance.new("Frame")
    btnRow.BackgroundTransparency = 1
    btnRow.AnchorPoint = Vector2.new(0, 1)
    btnRow.Position = UDim2.new(0, 16, 1, -16)
    btnRow.Size = UDim2.new(1, -32, 0, 42)
    btnRow.ZIndex = 402
    btnRow.Parent = card

    local accept = Instance.new("TextButton")
    accept.Size = UDim2.new(0.58, -4, 1, 0)
    accept.BackgroundColor3 = NF.White
    accept.TextColor3 = NF.Black
    accept.Font = FONTS.Bold
    accept.TextSize = 14
    accept.Text = "I Understand"
    accept.AutoButtonColor = false
    accept.ZIndex = 403
    accept.Parent = btnRow
    setCorner(accept, 4)
    BindInteractionSounds(accept)

    local decline = Instance.new("TextButton")
    decline.Size = UDim2.new(0.42, -4, 1, 0)
    decline.Position = UDim2.new(0.58, 4, 0, 0)
    decline.BackgroundColor3 = NF.Ghost
    decline.BackgroundTransparency = 0.3
    decline.TextColor3 = NF.White
    decline.Font = FONTS.Bold
    decline.TextSize = 13
    decline.Text = "Go Back"
    decline.AutoButtonColor = false
    decline.ZIndex = 403
    decline.Parent = btnRow
    setCorner(decline, 4)
    BindInteractionSounds(decline)

    accept.MouseEnter:Connect(function() tween(accept, 0.12, {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}) end)
    accept.MouseLeave:Connect(function() tween(accept, 0.12, {BackgroundColor3 = NF.White}) end)
    decline.MouseEnter:Connect(function() tween(decline, 0.12, {BackgroundTransparency = 0.55}) end)
    decline.MouseLeave:Connect(function() tween(decline, 0.12, {BackgroundTransparency = 0.3}) end)

    local finished = false
    local function close(afterClose)
        if finished then return end
        finished = true
        tween(overlay, 0.15, {BackgroundTransparency = 1})
        tween(scale, 0.15, {Scale = 0.96})
        task.delay(0.16, function()
            if overlay.Parent then overlay:Destroy() end
            termsOpen = false
            if afterClose then afterClose() end
        end)
    end

    accept.MouseButton1Click:Connect(function()
        if checked then
            Settings.HidePiratedTerms = true
            saveSettings()
        end
        sessionAccepted = true
        close()
    end)

    decline.MouseButton1Click:Connect(function()
        close(function()
            routeToView("menu")
            updateTabLine(MoviesTab)
        end)
    end)
end

try("terms gate", function()
    -- gate at the view level so every way into the Pirated section is covered
    -- (the tab itself, and opening a saved script from My List)
    local origRoute = routeToView
    routeToView = function(viewName)
        origRoute(viewName)
        if viewName == "pirated" and not Settings.HidePiratedTerms and not sessionAccepted then
            showTerms()
        end
    end
end)

try("settings switch", function()
    local SUI = AN_ENV.AN_SettingsUI
    local card = SUI and SUI.card and SUI.card["General"]
    if card then
        local sw = SUI.switchRow(card, "Pirated terms notice", "Show the usage notice when you open Pirated", Settings.HidePiratedTerms ~= true)
        sw.MouseButton1Click:Connect(function()
            Settings.HidePiratedTerms = not (Settings.HidePiratedTerms == true)
            saveSettings()
            SUI.setSwitch(sw, Settings.HidePiratedTerms ~= true)
        end)
        SUI.syncs[#SUI.syncs + 1] = function()
            SUI.setSwitch(sw, Settings.HidePiratedTerms ~= true, true)
        end
        return
    end
    -- fallback: old look, if the new settings page is not there
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 44)
    row.BackgroundColor3 = COLORS.DarkCard
    row.BorderSizePixel = 0
    row.LayoutOrder = 100
    row.Parent = SettingsScroll
    setCorner(row, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Pirated Terms Notice"
    lbl.TextColor3 = COLORS.White
    lbl.Font = FONTS.Bold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 30)
    btn.Position = UDim2.new(1, -126, 0.5, -15)
    btn.Font = FONTS.Bold
    btn.TextSize = 12
    btn.TextColor3 = COLORS.White
    btn.AutoButtonColor = false
    btn.Parent = row
    setCorner(btn, 4)
    BindInteractionSounds(btn)

    local function sync()
        local hidden = Settings.HidePiratedTerms == true
        btn.Text = hidden and "Hidden" or "Shown"
        btn.BackgroundColor3 = hidden and NF.Red or NF.Green
    end
    sync()
    btn.MouseButton1Click:Connect(function()
        Settings.HidePiratedTerms = not (Settings.HidePiratedTerms == true)
        saveSettings()
        sync()
    end)
end)

-- ---------------------------------------------------------------------------
-- 2. LAYOUT FIX + SAFETY BANNER
-- ---------------------------------------------------------------------------
local banner, bannerBody

try("detail layout + banner", function()
    -- spread the layout orders out so new rows can slot in between them;
    -- also moves the stray "CREATOR TAGS" label (order 0) under the status tags
    if not PiratedDetail:GetAttribute("NFOrdered") then
        PiratedDetail:SetAttribute("NFOrdered", true)
        for _, c in ipairs(PiratedDetail:GetChildren()) do
            if c:IsA("GuiObject") then
                if c:IsA("TextLabel") and c.Text == "CREATOR TAGS" then
                    c.LayoutOrder = 35
                else
                    c.LayoutOrder = c.LayoutOrder * 10
                end
            end
        end
    end

    banner = Instance.new("Frame")
    banner.Name = "NFSafetyBanner"
    banner.AutomaticSize = Enum.AutomaticSize.Y
    banner.Size = UDim2.new(1, -24, 0, 0)
    banner.BackgroundColor3 = Color3.fromRGB(36, 22, 22)
    banner.BorderSizePixel = 0
    banner.LayoutOrder = 25
    banner.Visible = false
    banner.ZIndex = 11
    banner.Parent = PiratedDetail
    setCorner(banner, 5)
    addStroke(banner, COLORS.BrandRed, 1, 0.55)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = banner

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = banner

    local head = Instance.new("TextLabel")
    head.BackgroundTransparency = 1
    head.Size = UDim2.new(1, 0, 0, 14)
    head.Font = FONTS.Bold
    head.TextSize = 10
    head.TextColor3 = COLORS.BrandRed
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.Text = "HEADS UP"
    head.LayoutOrder = 1
    head.ZIndex = 12
    head.Parent = banner

    bannerBody = Instance.new("TextLabel")
    bannerBody.BackgroundTransparency = 1
    bannerBody.AutomaticSize = Enum.AutomaticSize.Y
    bannerBody.Size = UDim2.new(1, 0, 0, 0)
    bannerBody.Font = FONTS.Book
    bannerBody.TextSize = 12
    bannerBody.TextColor3 = NF.Ink
    bannerBody.TextWrapped = true
    bannerBody.TextXAlignment = Enum.TextXAlignment.Left
    bannerBody.TextYAlignment = Enum.TextYAlignment.Top
    bannerBody.LayoutOrder = 2
    bannerBody.ZIndex = 12
    bannerBody.Parent = banner
end)

local function updateBanner()
    if not (banner and bannerBody) then return end
    local sp = selectedPirated
    if type(sp) ~= "table" then banner.Visible = false return end

    local lines = {}
    if not (sp.verified == true or sp.Verified == true) then
        table.insert(lines, "Unverified script. Review what it does before running it.")
    end
    if sp.key == true or sp.Key == true then
        table.insert(lines, "Uses a key system. It may send you to external websites.")
    end
    if sp.isPatched == true or sp.Patched == true then
        table.insert(lines, "Marked as patched. It probably no longer works.")
    end

    banner.Visible = #lines > 0
    bannerBody.Text = table.concat(lines, "\n")
end

try("banner hooks", function()
    local titleLbl = PiratedFrame:FindFirstChild("PiratedDetailTitle", true)
    if titleLbl then
        titleLbl:GetPropertyChangedSignal("Text"):Connect(function() task.defer(updateBanner) end)
    end
    PiratedDetail:GetPropertyChangedSignal("Visible"):Connect(function()
        if PiratedDetail.Visible then task.defer(updateBanner) end
    end)
end)

-- ---------------------------------------------------------------------------
-- 3. COMMENTS  (grow with their text, plus a counter)
-- ---------------------------------------------------------------------------
try("comments", function()
    local commentsFrame = PiratedFrame:FindFirstChild("PiratedComments", true)
    if not commentsFrame then return end

    local header
    for _, c in ipairs(PiratedDetail:GetChildren()) do
        if c:IsA("TextLabel") and c.Text:find("^COMMUNITY COMMENTS") then header = c end
    end

    local token = 0
    local function refreshCount()
        token = token + 1
        local mine = token
        task.delay(0.1, function()
            if mine ~= token or not header then return end
            local n = 0
            for _, c in ipairs(commentsFrame:GetChildren()) do
                if c:IsA("Frame") then n = n + 1 end
            end
            header.Text = n > 0 and ("COMMUNITY COMMENTS · " .. n) or "COMMUNITY COMMENTS"
        end)
    end

    local function styleComment(box)
        if not box:IsA("Frame") or box:GetAttribute("NFStyled") then return end
        box:SetAttribute("NFStyled", true)
        task.defer(function()
            for _, c in ipairs(box:GetChildren()) do
                -- the comment text is the only wrapped label inside a comment box
                if c:IsA("TextLabel") and c.TextWrapped then
                    c.AutomaticSize = Enum.AutomaticSize.Y
                    c.Size = UDim2.new(1, -20, 0, 0)
                    c.TextSize = isMobile() and 12 or 11
                    c.TextColor3 = NF.Ink
                end
            end
            box.AutomaticSize = Enum.AutomaticSize.Y -- Size (78px) stays the minimum height
            local pad = Instance.new("UIPadding")
            pad.PaddingBottom = UDim.new(0, 10)
            pad.Parent = box
        end)
    end

    for _, c in ipairs(commentsFrame:GetChildren()) do styleComment(c) end
    commentsFrame.ChildAdded:Connect(function(c) styleComment(c); refreshCount() end)
    commentsFrame.ChildRemoved:Connect(refreshCount)
    refreshCount()
end)

-- ---------------------------------------------------------------------------
-- 4. FAVORITING + EXECUTING FEEDBACK
-- ---------------------------------------------------------------------------
try("favorite", function()
    local fav = PiratedFrame:FindFirstChild("PiratedFavoriteBtn", true)
    if not fav then return end

    local function isIn(t)
        return t:find("In My List", 1, true) or t:find("✔", 1, true) or t:find("✓", 1, true)
    end

    local function styleFav()
        local inList = isIn(fav.Text) ~= nil
        local want = myListLabel(inList) -- plain Unicode check, no emoji
        if fav.Text ~= want then fav.Text = want end
        tween(fav, 0.15, {
            BackgroundColor3 = inList and NF.White or Color3.fromRGB(35, 35, 35),
            TextColor3 = inList and NF.Black or NF.White,
        })
    end

    fav:GetPropertyChangedSignal("Text"):Connect(styleFav)
    styleFav()

    -- connects after the original click handler, so the toggle has already happened
    fav.MouseButton1Click:Connect(function()
        if not selectedPirated then return end
        task.defer(function()
            toast(isIn(fav.Text) and "Added to My List" or "Removed from My List")
        end)
    end)

    -- the theme picker repaints this button; restore the correct state afterwards
    local origTheme = updateDynamicThemeColors
    updateDynamicThemeColors = function(c)
        origTheme(c)
        pcall(styleFav)
    end
end)

try("execute", function()
    local exec = PiratedFrame:FindFirstChild("PiratedExecute", true)
    if not exec then return end

    local function styleExec()
        local t = exec.Text
        local col = COLORS.BrandRed
        if t == "Executed" then
            col = NF.Green
        elseif t == "Failed" or t == "No Source" then
            col = NF.Red
        end
        tween(exec, 0.15, {BackgroundColor3 = col})
    end
    exec:GetPropertyChangedSignal("Text"):Connect(styleExec)
end)

end

ANNetflixPirated()

-- ============================================================================
-- NETFLIX POLISH PASS  (visual / input only, no logic changes)
-- Paste directly AFTER the line:  ANNetflixPirated()
--
-- What it does
--   * Hover states can never get "stuck": the resting colour is looked up at
--     hover-out time instead of being remembered, and the detail screen snaps
--     its buttons back to rest whenever it opens (touch devices often never
--     fire MouseLeave)
--   * Execute buttons (Executor + ScriptBlox) get hover + Executed/Failed colours
--   * 3% press-down feedback on the main buttons
--   * Genre dropdown: black Netflix panel with a red marker on the active genre
--   * "My List" button gets a white outline once a title is in the list
--   * Friendlier empty state for an empty My List
--   * Editor outlines white while typing (same as the search box)
--   * Placeholder text bumped to a readable contrast on the dark background
-- ============================================================================
function ANNetflixPolish()

if not (MainFrame and ScreenGui and routeToView and PlayBtn and FavBtn and BackBtn
        and GenreBtn and GenreDropdown and EmptyState and CodeInput and ExecActionBtn) then
    warn("[AN Netflix polish] Paste this INTO the main script after ANNetflixPirated().")
    return
end

local NF = {
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Ghost = Color3.fromRGB(109, 109, 110),
    Green = Color3.fromRGB(46, 125, 50),
    Red   = Color3.fromRGB(198, 40, 40),
}

local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then warn("[AN Netflix polish] " .. label .. ": " .. tostring(err)) end
end

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function darken(c, k)
    return Color3.new(c.R * k, c.G * k, c.B * k)
end

-- hover: `rest()` is evaluated when the pointer leaves, never cached
local function bindHover(btn, rest, hover)
    if not btn or btn:GetAttribute("ANPolishHover") then return end
    btn:SetAttribute("ANPolishHover", true)
    btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = hover(rest())}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = rest()}) end)
end

-- press: scale down a hair while held; always restored on release or leave
local function bindPress(btn)
    if not btn or btn:GetAttribute("ANPolishPress") then return end
    btn:SetAttribute("ANPolishPress", true)
    local sc = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
    sc.Scale = 1
    sc.Parent = btn
    local function to(s) tween(sc, 0.08, {Scale = s}) end
    btn.MouseButton1Down:Connect(function() to(0.97) end)
    btn.MouseButton1Up:Connect(function() to(1) end)
    btn.MouseLeave:Connect(function() to(1) end)
end

local function setCorner(obj, r)
    local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

-- ---------------------------------------------------------------------------
-- 1. DETAIL SCREEN  (no stuck hover, press feedback, "in list" outline)
-- ---------------------------------------------------------------------------
try("detail reset", function()
    local function snapDetailButtons()
        PlayBtn.BackgroundColor3 = NF.White
        for _, b in ipairs({FavBtn, BackBtn}) do
            b.BackgroundColor3 = NF.Ghost
            b.BackgroundTransparency = 0.3
        end
        for _, b in ipairs({PlayBtn, FavBtn, BackBtn}) do
            local sc = b:FindFirstChildOfClass("UIScale")
            if sc then sc.Scale = 1 end
        end
    end

    local origRoute = routeToView
    routeToView = function(viewName, ...)
        if viewName == "detail" then pcall(snapDetailButtons) end
        return origRoute(viewName, ...)
    end
end)

try("detail press + list outline", function()
    for _, b in ipairs({PlayBtn, FavBtn, BackBtn}) do bindPress(b) end

    local stroke = FavBtn:FindFirstChildOfClass("UIStroke")
    local function syncFav()
        if stroke then
            local inList = FavBtn.Text == myListLabel(true)
            tween(stroke, 0.15, {Color = inList and NF.White or COLORS.Border})
        end
    end
    FavBtn:GetPropertyChangedSignal("Text"):Connect(syncFav)
    syncFav()
end)

-- ---------------------------------------------------------------------------
-- 2. EXECUTE BUTTONS  (Executor tab + ScriptBlox detail)
-- ---------------------------------------------------------------------------
local function execRest(btn)
    local t = btn.Text
    if t == "Executed" then return NF.Green end
    if t == "Failed" or t == "No Source" then return NF.Red end
    return COLORS.BrandRed
end

try("execute buttons", function()
    -- PiratedExecute is local to an earlier block, so look it up by name (as the Pirated pass does)
    local execButtons = {ExecActionBtn}
    local piratedExec = PiratedFrame and PiratedFrame:FindFirstChild("PiratedExecute", true)
    if piratedExec then table.insert(execButtons, piratedExec) end
    for _, b in ipairs(execButtons) do
        bindHover(b, function() return execRest(b) end, function(c) return darken(c, 0.8) end)
        bindPress(b)
    end

    -- Executor tab previously stayed red after running; match the ScriptBlox button
    ExecActionBtn:GetPropertyChangedSignal("Text"):Connect(function()
        tween(ExecActionBtn, 0.15, {BackgroundColor3 = execRest(ExecActionBtn)})
    end)

    -- the theme picker repaints these red; put the state colour back afterwards
    local origTheme = updateDynamicThemeColors
    updateDynamicThemeColors = function(c)
        origTheme(c)
        for _, b in ipairs(execButtons) do
            pcall(function() b.BackgroundColor3 = execRest(b) end)
        end
    end

    if ExecClearBtn then
        local rest = Color3.fromRGB(35, 35, 35)
        bindHover(ExecClearBtn, function() return rest end, function() return Color3.fromRGB(55, 55, 55) end)
        bindPress(ExecClearBtn)
    end
end)

-- ---------------------------------------------------------------------------
-- 3. EDITOR  (outline lights up while typing, like the search box)
-- ---------------------------------------------------------------------------
try("editor", function()
    CodeInput.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    local stroke = CodeInput:FindFirstChildOfClass("UIStroke")
    if not stroke then return end
    stroke.Color = NF.Ghost
    stroke.Transparency = 0.6
    CodeInput.Focused:Connect(function()
        tween(stroke, 0.15, {Color = NF.White, Transparency = 0})
    end)
    CodeInput.FocusLost:Connect(function()
        tween(stroke, 0.15, {Color = NF.Ghost, Transparency = 0.6})
    end)
end)

-- ---------------------------------------------------------------------------
-- 4. GENRE DROPDOWN  (black panel, red marker on the active genre)
-- ---------------------------------------------------------------------------
try("genre dropdown", function()
    GenreDropdown.BackgroundColor3 = NF.Black
    local panelStroke = GenreDropdown:FindFirstChildOfClass("UIStroke")
    if panelStroke then
        panelStroke.Color = NF.Ghost
        panelStroke.Transparency = 0.5
    end

    local function sync()
        for _, row in ipairs(GenreDropdown:GetChildren()) do
            if row:IsA("TextButton") then
                local name = (row.Text:gsub("^%s+", ""))
                local bar = row:FindFirstChild("NFActiveBar")
                if not bar then
                    local pad = Instance.new("UIPadding")
                    pad.PaddingLeft = UDim.new(0, 8)
                    pad.Parent = row

                    bar = Instance.new("Frame")
                    bar.Name = "NFActiveBar"
                    bar.Size = UDim2.new(0, 3, 0, 14)
                    bar.AnchorPoint = Vector2.new(0, 0.5)
                    bar.Position = UDim2.new(0, -8, 0.5, 0)
                    bar.BackgroundColor3 = COLORS.BrandRed
                    bar.BorderSizePixel = 0
                    bar.ZIndex = row.ZIndex + 1
                    bar.Parent = row
                    setCorner(bar, 2)
                end
                bar.Visible = (name == CurrentGenre)
            end
        end
    end

    sync()
    GenreBtn:GetPropertyChangedSignal("Text"):Connect(sync)
    GenreDropdown:GetPropertyChangedSignal("Visible"):Connect(sync)
end)

-- ---------------------------------------------------------------------------
-- 5. EMPTY STATE
-- ---------------------------------------------------------------------------
try("empty state", function()
    local origUpdate = updateCarousel
    updateCarousel = function()
        if origUpdate then origUpdate() end
        EmptyState.Text = (CurrentGenre == "My List")
            and "Your list is empty. Open a title and tap \"+ My List\"."
            or "No matches found."
    end
end)

-- ---------------------------------------------------------------------------
-- 6. PLACEHOLDER CONTRAST  (dark-grey placeholders were ~2.7:1 on the dark UI)
-- ---------------------------------------------------------------------------
try("placeholder contrast", function()
    local function fix(d)
        if d:IsA("TextBox") then
            local c = d.PlaceholderColor3
            if (c.R + c.G + c.B) / 3 < 0.5 then
                d.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
    end
    for _, d in ipairs(ScreenGui:GetDescendants()) do fix(d) end
    ScreenGui.DescendantAdded:Connect(function(d) task.defer(fix, d) end)
end)

end

ANNetflixPolish()


if isUserBlacklisted then
    warn("AN Hub: Access Denied.\nTime Remaining: " .. banTimeText)
    
    MenuFrame:Destroy()
    HeaderBar:Destroy()
    local SuspendText = Instance.new("TextLabel")
    SuspendText.Size = UDim2.new(1, 0, 1, -60)
    SuspendText.BackgroundTransparency = 1
    SuspendText.Text = "ACCOUNT SUSPENDED"
    SuspendText.Font = FONTS.Heavy
    SuspendText.TextSize = 36
    SuspendText.TextColor3 = COLORS.BrandRed
    SuspendText.Parent = MainFrame

    local SubText = Instance.new("TextLabel")
    SubText.Size = UDim2.new(1, 0, 0, 40)
    SubText.Position = UDim2.new(0, 0, 0.5, 30)
    SubText.BackgroundTransparency = 1
    SubText.Text = "Your access to AN Universal has been revoked.\nTime Remaining: " .. banTimeText .. "\n\nClosing window in 3 seconds..."
    SubText.Font = FONTS.Medium
    SubText.TextSize = 14
    SubText.TextColor3 = COLORS.GreyLight
    SubText.Parent = MainFrame

    task.delay(3, function()
        local windowFade = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        windowFade:Play()
        windowFade.Completed:Wait()
        if AN_ENV.AN_UNIVERSAL_GUI == ScreenGui then AN_ENV.AN_UNIVERSAL_GUI = nil end
        if AN_ENV.AN_UNIVERSAL_CLEANUP then AN_ENV.AN_UNIVERSAL_CLEANUP = nil end
        ScreenGui:Destroy()
    end)
else
    AN_ENV.AN_UNIVERSAL_GUI = ScreenGui
    checkIn()
    routeToView("menu")
    updateTabLine(MoviesTab)
    if updateCarousel then updateCarousel() end
end
