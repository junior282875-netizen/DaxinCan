repeat task.wait(15) until game:IsLoaded()

local Library = (function()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ANIM_ENABLED = true

local Spring = {}
Spring.__index = Spring

function Spring.new(stiffness, damping, mass)
	local self = setmetatable({}, Spring)
	self.Pos = 0
	self.Vel = 0
	self.Target = 0
	self.K = stiffness or 220
	self.D = damping or 22
	self.M = mass or 1
	return self
end

function Spring:Update(dt)
	dt = math.min(dt, 0.033)
	local steps = math.ceil(dt / 0.016)
	local subDt = dt / steps
	for _ = 1, steps do
		local x = self.Pos - self.Target
		local springForce = -self.K * x
		local dampForce = -self.D * self.Vel
		local accel = (springForce + dampForce) / self.M
		self.Vel = self.Vel + accel * subDt
		self.Pos = self.Pos + self.Vel * subDt
	end
	return self.Pos
end

function Spring:Impulse(force)
	self.Vel = self.Vel + force
end

function Spring:SetTarget(t)
	self.Target = t
end

function Spring:Done(threshold)
	threshold = threshold or 0.001
	return math.abs(self.Pos - self.Target) < threshold and math.abs(self.Vel) < threshold
end
local Pool = {}
local _poolConn = nil
local _poolId = 0

local function poolAdd(fn)
	_poolId = _poolId + 1
	local id = _poolId
	Pool[id] = fn
	if not _poolConn then
		_poolConn = RunService.Heartbeat:Connect(function(dt)
			for k, v in pairs(Pool) do
				if v(dt) == false then
					Pool[k] = nil
				end
			end
			if not next(Pool) and _poolConn then
				_poolConn:Disconnect()
				_poolConn = nil
			end
		end)
	end
	return id
end

local function poolRemove(id)
	if id then Pool[id] = nil end
end

local function poolRemove(id)
	if id then Pool[id] = nil end
end

local C = {
	GradA = Color3.fromRGB(18, 18, 18),
	GradB = Color3.fromRGB(24, 24, 24),
	GradC = Color3.fromRGB(14, 14, 14),
	GradD = Color3.fromRGB(10, 10, 10),
	Wave1 = Color3.fromRGB(28, 28, 28),
	Wave2 = Color3.fromRGB(22, 22, 22),
	Wave3 = Color3.fromRGB(25, 25, 25),
	BG = Color3.fromRGB(12, 12, 12),
	BGAlt = Color3.fromRGB(18, 18, 18),
	Surface = Color3.fromRGB(26, 26, 26),
	SurfaceAlt = Color3.fromRGB(32, 32, 32),
	Border = Color3.fromRGB(48, 48, 48),
	BorderLit = Color3.fromRGB(70, 70, 70),
	Text = Color3.fromRGB(235, 235, 235),
	Sub = Color3.fromRGB(160, 160, 160),
	Dim = Color3.fromRGB(95, 95, 95),
	Accent = Color3.fromRGB(220, 220, 220),
	AccentLit = Color3.fromRGB(245, 245, 245),
	AccentSub = Color3.fromRGB(36, 36, 36),
	AccentDark = Color3.fromRGB(170, 170, 170),
	Purple = Color3.fromRGB(150, 150, 150),
	PurpleLit = Color3.fromRGB(190, 190, 190),
	PurpleSub = Color3.fromRGB(30, 30, 30),
	PurpleDeep = Color3.fromRGB(120, 120, 120),
	Peach = Color3.fromRGB(150, 150, 150),
	PeachLit = Color3.fromRGB(190, 190, 190),
	PeachSub = Color3.fromRGB(30, 30, 30),
	PeachDeep = Color3.fromRGB(120, 120, 120),
	Watermelon = Color3.fromRGB(150, 150, 150),
	ElecBlue = Color3.fromRGB(160, 160, 160),
	Mint = Color3.fromRGB(160, 160, 160),
	Lilac = Color3.fromRGB(150, 150, 150),
	SoftOrange = Color3.fromRGB(170, 170, 170),
	HotPink = Color3.fromRGB(150, 150, 150),
	Coral = Color3.fromRGB(150, 150, 150),
	SkyBlue = Color3.fromRGB(170, 170, 170),
	Lavender = Color3.fromRGB(160, 160, 160),
	Ok = Color3.fromRGB(220, 220, 220),
	Warn = Color3.fromRGB(180, 180, 180),
	Err = Color3.fromRGB(90, 90, 90),
	Info = Color3.fromRGB(160, 160, 160),
	TrackOff = Color3.fromRGB(40, 40, 40),
	SidebarBG = Color3.fromRGB(10, 10, 10),
	SidebarHover = Color3.fromRGB(28, 28, 28),
	SidebarActive = Color3.fromRGB(32, 32, 32),
	TopbarBG = Color3.fromRGB(10, 10, 10),
	SubTabBG = Color3.fromRGB(16, 16, 16),
	SubTabActive = Color3.fromRGB(30, 30, 30),
	NotifBG = Color3.fromRGB(24, 24, 24),
	ActivePanelBG = Color3.fromRGB(16, 16, 16),
	ActiveItemBG = Color3.fromRGB(30, 30, 30),
	ActiveItemGlow = Color3.fromRGB(48, 48, 48),
	ClayHighlight = Color3.fromRGB(60, 60, 60),
	ClayShadow = Color3.fromRGB(4, 4, 4),
	ClayShadowDeep = Color3.fromRGB(2, 2, 2),
	FooterBG = Color3.fromRGB(10, 10, 10),
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function lerpColor(a, b, t)
	return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function tw(obj, dur, props, style, dir)
	if not obj or not obj.Parent then return nil end
	if not ANIM_ENABLED then
		for k, v in pairs(props) do
			pcall(function() obj[k] = v end)
		end
		return nil
	end
	local info = TweenInfo.new(dur, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 16)
	c.Parent = parent
	return c
end

local function pad(parent, top, bot, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bot or 0)
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.Parent = parent
	return p
end

local function uiList(parent, gap, dir, hAlign, vAlign)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, gap or 6)
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left
	l.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
	l.Parent = parent
	return l
end

local function uiGrid(parent, cellSizeX, cellSizeY, gap, fillDir)
	local g = Instance.new("UIGridLayout")
	g.CellSize = UDim2.new(0, cellSizeX or 200, 0, cellSizeY or 80)
	g.CellPadding = UDim2.new(0, gap or 8, 0, gap or 8)
	g.FillDirection = fillDir or Enum.FillDirection.Horizontal
	g.SortOrder = Enum.SortOrder.LayoutOrder
	g.FillDirectionMaxCells = 2
	g.Parent = parent
	return g
end

local function strokeInst(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Border
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function tweenIconColor(icon, dur, color, style)
	if not icon or not icon.Parent then return end
	if icon:IsA("ImageLabel") or icon:IsA("ImageButton") then
		tw(icon, dur, {ImageColor3 = color}, style)
	else
		tw(icon, dur, {TextColor3 = color}, style)
	end
end

local function noHit(frame)
	frame.Active = false
	pcall(function() frame.Selectable = false end)
	return frame
end

local function getScale()
	local vp = Camera.ViewportSize
	return math.clamp(math.min(vp.X, vp.Y * 1.6) / 1080, 0.65, 1.15)
end

local SC = getScale()

local FONT_TITLE = math.floor(19 * SC)
local FONT_ICON_SIDEBAR = math.floor(20 * SC)
local FONT_SIDEBAR_LABEL = math.floor(13 * SC)
local FONT_SUBTAB = math.floor(13 * SC)
local FONT_ELEM_NAME = math.floor(15 * SC)
local FONT_ELEM_VALUE = math.floor(12 * SC)
local FONT_SMALL = math.floor(11 * SC)
local FONT_SECTION = math.floor(14 * SC)
local FONT_SECTION_ICON = math.floor(15 * SC)
local FONT_VERSION = math.floor(10 * SC)
local FONT_FOOTER = math.floor(12 * SC)
local FONT_ACTIVE_PANEL = math.floor(12 * SC)

local TextIcons = {
	circle      = "\xE2\x97\x8F",
	ring        = "\xE2\x97\x8B",
	dot         = "\xE2\x80\xA2",
	check       = "\xE2\x9C\x93",
	x           = "\xE2\x9C\x95",
	star        = "\xE2\x98\x85",
	heart       = "\xE2\x99\xA5",
	arrow_r     = "\xE2\x86\x92",
	arrow_l     = "\xE2\x86\x90",
	arrow_u     = "\xE2\x86\x91",
	arrow_d     = "\xE2\x86\x93",
	expand      = "\xE2\x96\xBC",
	collapse    = "\xE2\x96\xB2",
	sparkle     = "\xE2\x9C\xA6",
	diamond     = "\xE2\x97\x86",
	dash        = "\xE2\x80\x94",
	play        = "\xE2\x96\xB6",
	pause       = "\xE2\x8F\xB8",
}

local IconAssets = {
	["10k"] = "rbxassetid://6026643035",
	["10mp"] = "rbxassetid://6031328149",
	["11mp"] = "rbxassetid://6031328141",
	["12mp"] = "rbxassetid://6031328140",
	["13mp"] = "rbxassetid://6031328137",
	["14mp"] = "rbxassetid://6031328161",
	["15mp"] = "rbxassetid://6031328158",
	["16mp"] = "rbxassetid://6031328168",
	["17mp"] = "rbxassetid://6031339055",
	["18mp"] = "rbxassetid://6031339064",
	["19mp"] = "rbxassetid://6031339054",
	["1k"] = "rbxassetid://6026643002",
	["1k_plus"] = "rbxassetid://6026681580",
	["20mp"] = "rbxassetid://6031488940",
	["21mp"] = "rbxassetid://6031339065",
	["22mp"] = "rbxassetid://6031360353",
	["23mp"] = "rbxassetid://6031339045",
	["24mp"] = "rbxassetid://6031360352",
	["2k"] = "rbxassetid://6026643032",
	["2k_plus"] = "rbxassetid://6026681588",
	["2mp"] = "rbxassetid://6031328138",
	["360"] = "rbxassetid://6034767608",
	["3d_rotation"] = "rbxassetid://6022668893",
	["3k"] = "rbxassetid://6026681574",
	["3k_plus"] = "rbxassetid://6026681598",
	["3mp"] = "rbxassetid://6031328136",
	["4k"] = "rbxassetid://6026643017",
	["4k_plus"] = "rbxassetid://6026643005",
	["4mp"] = "rbxassetid://6031328152",
	["5g"] = "rbxassetid://6026643007",
	["5k"] = "rbxassetid://6026681575",
	["5k_plus"] = "rbxassetid://6026643028",
	["5mp"] = "rbxassetid://6031328144",
	["6k"] = "rbxassetid://6026681579",
	["6k_plus"] = "rbxassetid://6026643019",
	["6mp"] = "rbxassetid://6031328131",
	["7k"] = "rbxassetid://6026681584",
	["7k_plus"] = "rbxassetid://6026643012",
	["7mp"] = "rbxassetid://6031328139",
	["8k"] = "rbxassetid://6026643014",
	["8k_plus"] = "rbxassetid://6026643003",
	["8mp"] = "rbxassetid://6031328133",
	["9k"] = "rbxassetid://6026643013",
	["9k_plus"] = "rbxassetid://6026681585",
	["9mp"] = "rbxassetid://6031328146",
	["_add_alert"] = "rbxassetid://6031071067",
	["_auto_delete"] = "rbxassetid://6031071068",
	["_error"] = "rbxassetid://6031071057",
	["_error_outline"] = "rbxassetid://6031071050",
	["_notification_important"] = "rbxassetid://6031071056",
	["_warning"] = "rbxassetid://6031071053",
	["ac_unit"] = "rbxassetid://6035107929",
	["access_alarm"] = "rbxassetid://6034983844",
	["access_alarms"] = "rbxassetid://6034983853",
	["access_time"] = "rbxassetid://6034983856",
	["accessibility"] = "rbxassetid://6022668887",
	["accessibility_new"] = "rbxassetid://6022668945",
	["accessible"] = "rbxassetid://6022668902",
	["accessible_forward"] = "rbxassetid://6022668906",
	["account_balance"] = "rbxassetid://6022668900",
	["account_balance_wallet"] = "rbxassetid://6022668892",
	["account_box"] = "rbxassetid://6023426915",
	["account_circle"] = "rbxassetid://6022668898",
	["account_tree"] = "rbxassetid://6034418507",
	["ad_units"] = "rbxassetid://6034983845",
	["adb"] = "rbxassetid://6034418515",
	["add"] = "rbxassetid://6035047377",
	["add_a_photo"] = "rbxassetid://6031339049",
	["add_alarm"] = "rbxassetid://6034983850",
	["add_box"] = "rbxassetid://6035047375",
	["add_business"] = "rbxassetid://6034483666",
	["add_call"] = "rbxassetid://6034418524",
	["add_chart"] = "rbxassetid://6034898093",
	["add_circle"] = "rbxassetid://6035047380",
	["add_circle_outline"] = "rbxassetid://6035047391",
	["add_comment"] = "rbxassetid://6034898128",
	["add_ic_call"] = "rbxassetid://6035173839",
	["add_link"] = "rbxassetid://6035047374",
	["add_location"] = "rbxassetid://6034483672",
	["add_location_alt"] = "rbxassetid://6034483678",
	["add_moderator"] = "rbxassetid://6034295699",
	["add_photo_alternate"] = "rbxassetid://6031471484",
	["add_road"] = "rbxassetid://6034483677",
	["add_shopping_cart"] = "rbxassetid://6022668875",
	["add_task"] = "rbxassetid://6022668912",
	["add_to_drive"] = "rbxassetid://6022860335",
	["add_to_home_screen"] = "rbxassetid://6034983858",
	["add_to_photos"] = "rbxassetid://6031371075",
	["add_to_queue"] = "rbxassetid://6026647903",
	["addchart"] = "rbxassetid://6023426905",
	["adjust"] = "rbxassetid://6031339048",
	["admin_panel_settings"] = "rbxassetid://6022668961",
	["agriculture"] = "rbxassetid://6034483674",
	["airline_seat_flat"] = "rbxassetid://6034418511",
	["airline_seat_flat_angled"] = "rbxassetid://6034418513",
	["airline_seat_individual_suite"] = "rbxassetid://6034418514",
	["airline_seat_legroom_extra"] = "rbxassetid://6034418508",
	["airline_seat_legroom_normal"] = "rbxassetid://6034418532",
	["airline_seat_legroom_reduced"] = "rbxassetid://6034418520",
	["airline_seat_recline_extra"] = "rbxassetid://6034418528",
	["airline_seat_recline_normal"] = "rbxassetid://6034418512",
	["airplanemode_active"] = "rbxassetid://6034983864",
	["airplanemode_inactive"] = "rbxassetid://6034983848",
	["airplay"] = "rbxassetid://6026647929",
	["airport_shuttle"] = "rbxassetid://6035107921",
	["alarm"] = "rbxassetid://6023426910",
	["alarm_add"] = "rbxassetid://6023426898",
	["alarm_off"] = "rbxassetid://6023426901",
	["alarm_on"] = "rbxassetid://6023426920",
	["album"] = "rbxassetid://6026647905",
	["all_inbox"] = "rbxassetid://6022668909",
	["all_inclusive"] = "rbxassetid://6035107920",
	["all_out"] = "rbxassetid://6022668876",
	["alt_route"] = "rbxassetid://6034483670",
	["alternate_email"] = "rbxassetid://6035173865",
	["amp_stories"] = "rbxassetid://6035047382",
	["analytics"] = "rbxassetid://6022668884",
	["anchor"] = "rbxassetid://6023426906",
	["android"] = "rbxassetid://6022668966",
	["animation"] = "rbxassetid://6031625150",
	["announcement"] = "rbxassetid://6022668946",
	["apartment"] = "rbxassetid://6035107922",
	["api"] = "rbxassetid://6022668911",
	["app_blocking"] = "rbxassetid://6022668952",
	["app_registration"] = "rbxassetid://6035173870",
	["app_settings_alt"] = "rbxassetid://6031090998",
	["approval"] = "rbxassetid://6031302928",
	["apps"] = "rbxassetid://6031090999",
	["architecture"] = "rbxassetid://6034275730",
	["archive"] = "rbxassetid://6035047379",
	["arrow_back"] = "rbxassetid://6031091000",
	["arrow_back_ios"] = "rbxassetid://6031091003",
	["arrow_circle_down"] = "rbxassetid://6022668877",
	["arrow_circle_up"] = "rbxassetid://6022668934",
	["arrow_downward"] = "rbxassetid://6031090991",
	["arrow_drop_down"] = "rbxassetid://6031091004",
	["arrow_drop_down_circle"] = "rbxassetid://6031091001",
	["arrow_drop_up"] = "rbxassetid://6031090990",
	["arrow_forward"] = "rbxassetid://6031090995",
	["arrow_forward_ios"] = "rbxassetid://6031091008",
	["arrow_left"] = "rbxassetid://6031091002",
	["arrow_right"] = "rbxassetid://6031090994",
	["arrow_right_alt"] = "rbxassetid://6022668890",
	["arrow_upward"] = "rbxassetid://6031090997",
	["art_track"] = "rbxassetid://6026647908",
	["article"] = "rbxassetid://6022668907",
	["aspect_ratio"] = "rbxassetid://6022668895",
	["assessment"] = "rbxassetid://6022668897",
	["assignment"] = "rbxassetid://6022668882",
	["assignment_ind"] = "rbxassetid://6022668935",
	["assignment_late"] = "rbxassetid://6022668880",
	["assignment_return"] = "rbxassetid://6023426931",
	["assignment_returned"] = "rbxassetid://6023426899",
	["assignment_turned_in"] = "rbxassetid://6023426904",
	["assistant"] = "rbxassetid://6031360356",
	["assistant_direction"] = "rbxassetid://6031091005",
	["assistant_navigation"] = "rbxassetid://6031091006",
	["assistant_photo"] = "rbxassetid://6031339052",
	["atm"] = "rbxassetid://6034767614",
	["attach_email"] = "rbxassetid://6031302935",
	["attach_file"] = "rbxassetid://6034898102",
	["attach_money"] = "rbxassetid://6034898098",
	["attachment"] = "rbxassetid://6031302921",
	["attractions"] = "rbxassetid://6034767620",
	["audiotrack"] = "rbxassetid://6031471489",
	["auto_awesome"] = "rbxassetid://6031360365",
	["auto_awesome_mosaic"] = "rbxassetid://6031371053",
	["auto_awesome_motion"] = "rbxassetid://6031360370",
	["auto_fix_high"] = "rbxassetid://6031360355",
	["auto_fix_normal"] = "rbxassetid://6031371074",
	["auto_fix_off"] = "rbxassetid://6031360381",
	["auto_stories"] = "rbxassetid://6031360360",
	["autorenew"] = "rbxassetid://6023565901",
	["av_timer"] = "rbxassetid://6026647934",
	["baby_changing_station"] = "rbxassetid://6035107930",
	["backpack"] = "rbxassetid://6035107928",
	["backspace"] = "rbxassetid://6035047397",
	["backup"] = "rbxassetid://6023426911",
	["backup_table"] = "rbxassetid://6022860338",
	["badge"] = "rbxassetid://6034767607",
	["bakery_dining"] = "rbxassetid://6034767610",
	["ballot"] = "rbxassetid://6035047386",
	["bar_chart"] = "rbxassetid://6034898096",
	["batch_prediction"] = "rbxassetid://6022860334",
	["bathtub"] = "rbxassetid://6035107939",
	["battery_alert"] = "rbxassetid://6034983843",
	["battery_charging_full"] = "rbxassetid://6034983849",
	["battery_full"] = "rbxassetid://6034983854",
	["battery_unknown"] = "rbxassetid://6034983842",
	["beach_access"] = "rbxassetid://6035107923",
	["bedtime"] = "rbxassetid://6031371054",
	["beenhere"] = "rbxassetid://6034483675",
	["bento"] = "rbxassetid://6035107924",
	["bike_scooter"] = "rbxassetid://6034483669",
	["biotech"] = "rbxassetid://6035047385",
	["block"] = "rbxassetid://6035047387",
	["block_flipped"] = "rbxassetid://6035047378",
	["bluetooth"] = "rbxassetid://6034983880",
	["bluetooth_audio"] = "rbxassetid://6034418522",
	["bluetooth_connected"] = "rbxassetid://6034983855",
	["bluetooth_disabled"] = "rbxassetid://6034989562",
	["bluetooth_searching"] = "rbxassetid://6034989553",
	["blur_circular"] = "rbxassetid://6031488945",
	["blur_linear"] = "rbxassetid://6031488930",
	["blur_off"] = "rbxassetid://6031371055",
	["blur_on"] = "rbxassetid://6031371068",
	["bolt"] = "rbxassetid://6035047381",
	["book"] = "rbxassetid://6022860343",
	["book_online"] = "rbxassetid://6022860332",
	["bookmark"] = "rbxassetid://6022852108",
	["bookmark_border"] = "rbxassetid://6022860339",
	["bookmarks"] = "rbxassetid://6023426924",
	["border_all"] = "rbxassetid://6034898101",
	["border_bottom"] = "rbxassetid://6034898094",
	["border_clear"] = "rbxassetid://6034898135",
	["border_color"] = "rbxassetid://6034898100",
	["border_horizontal"] = "rbxassetid://6034898105",
	["border_inner"] = "rbxassetid://6034898131",
	["border_left"] = "rbxassetid://6034898099",
	["border_outer"] = "rbxassetid://6034898104",
	["border_right"] = "rbxassetid://6034898120",
	["border_style"] = "rbxassetid://6034898097",
	["border_top"] = "rbxassetid://6034900726",
	["border_vertical"] = "rbxassetid://6034900725",
	["branding_watermark"] = "rbxassetid://6026647911",
	["breakfast_dining"] = "rbxassetid://6034483671",
	["brightness_1"] = "rbxassetid://6031471488",
	["brightness_2"] = "rbxassetid://6031488938",
	["brightness_3"] = "rbxassetid://6031572317",
	["brightness_4"] = "rbxassetid://6031471483",
	["brightness_5"] = "rbxassetid://6031471479",
	["brightness_6"] = "rbxassetid://6031572309",
	["brightness_7"] = "rbxassetid://6031471491",
	["brightness_auto"] = "rbxassetid://6034989545",
	["brightness_high"] = "rbxassetid://6034989541",
	["brightness_low"] = "rbxassetid://6034989542",
	["brightness_medium"] = "rbxassetid://6034989543",
	["broken_image"] = "rbxassetid://6031471480",
	["browser_not_supported"] = "rbxassetid://6034789875",
	["brunch_dining"] = "rbxassetid://6034767611",
	["brush"] = "rbxassetid://6031572320",
	["bubble_chart"] = "rbxassetid://6034925612",
	["bug_report"] = "rbxassetid://6022852107",
	["build"] = "rbxassetid://6023426938",
	["build_circle"] = "rbxassetid://6023426952",
	["burst_mode"] = "rbxassetid://6031572306",
	["bus_alert"] = "rbxassetid://6034767618",
	["business"] = "rbxassetid://6035173853",
	["business_center"] = "rbxassetid://6035107933",
	["cached"] = "rbxassetid://6023426921",
	["cake"] = "rbxassetid://6034295702",
	["calculate"] = "rbxassetid://6035047384",
	["calendar_today"] = "rbxassetid://6022668917",
	["calendar_view_day"] = "rbxassetid://6023426946",
	["call"] = "rbxassetid://6035173859",
	["call_end"] = "rbxassetid://6035173845",
	["call_made"] = "rbxassetid://6035173858",
	["call_merge"] = "rbxassetid://6035173843",
	["call_missed"] = "rbxassetid://6035173850",
	["call_missed_outgoing"] = "rbxassetid://6035173847",
	["call_received"] = "rbxassetid://6035173844",
	["call_split"] = "rbxassetid://6035173861",
	["call_to_action"] = "rbxassetid://6026647898",
	["camera"] = "rbxassetid://6031572312",
	["camera_alt"] = "rbxassetid://6031572307",
	["camera_enhance"] = "rbxassetid://6023426935",
	["camera_front"] = "rbxassetid://6031572318",
	["camera_rear"] = "rbxassetid://6031572316",
	["camera_roll"] = "rbxassetid://6031572314",
	["campaign"] = "rbxassetid://6031094666",
	["cancel"] = "rbxassetid://6031094677",
	["cancel_presentation"] = "rbxassetid://6035173837",
	["cancel_schedule_send"] = "rbxassetid://6022668963",
	["car_rental"] = "rbxassetid://6034767641",
	["car_repair"] = "rbxassetid://6034767617",
	["card_giftcard"] = "rbxassetid://6023426978",
	["card_membership"] = "rbxassetid://6023426942",
	["card_travel"] = "rbxassetid://6023426925",
	["carpenter"] = "rbxassetid://6035107955",
	["cases"] = "rbxassetid://6031572324",
	["casino"] = "rbxassetid://6035107936",
	["cast"] = "rbxassetid://6034789876",
	["cast_connected"] = "rbxassetid://6034789895",
	["cast_for_education"] = "rbxassetid://6034789872",
	["category"] = "rbxassetid://6034767621",
	["celebration"] = "rbxassetid://6034767613",
	["cell_wifi"] = "rbxassetid://6035173852",
	["center_focus_strong"] = "rbxassetid://6031625147",
	["center_focus_weak"] = "rbxassetid://6031625144",
	["change_history"] = "rbxassetid://6023426914",
	["charging_station"] = "rbxassetid://6035107925",
	["chat"] = "rbxassetid://6035173838",
	["chat_bubble"] = "rbxassetid://6035181858",
	["chat_bubble_outline"] = "rbxassetid://6035181869",
	["check"] = "rbxassetid://6031094667",
	["check_box"] = "rbxassetid://6031068421",
	["check_box_outline_blank"] = "rbxassetid://6031068420",
	["check_circle"] = "rbxassetid://6023426945",
	["check_circle_outline"] = "rbxassetid://6023426909",
	["checkroom"] = "rbxassetid://6035107931",
	["chevron_left"] = "rbxassetid://6031094670",
	["chevron_right"] = "rbxassetid://6031094680",
	["child_care"] = "rbxassetid://6035107927",
	["child_friendly"] = "rbxassetid://6035121942",
	["chrome_reader_mode"] = "rbxassetid://6023426912",
	["circle"] = "rbxassetid://6031625146",
	["circle_notifications"] = "rbxassetid://6023426923",
	["class"] = "rbxassetid://6022668949",
	["clean_hands"] = "rbxassetid://6034275729",
	["cleaning_services"] = "rbxassetid://6034767619",
	["clear"] = "rbxassetid://6035047409",
	["clear_all"] = "rbxassetid://6035181870",
	["close"] = "rbxassetid://6031094678",
	["close_fullscreen"] = "rbxassetid://6023426928",
	["closed_caption"] = "rbxassetid://6026647896",
	["closed_caption_disabled"] = "rbxassetid://6026647900",
	["closed_caption_off"] = "rbxassetid://6026647943",
	["cloud"] = "rbxassetid://6031302918",
	["cloud_circle"] = "rbxassetid://6031302919",
	["cloud_done"] = "rbxassetid://6031302927",
	["cloud_download"] = "rbxassetid://6031302917",
	["cloud_off"] = "rbxassetid://6031302993",
	["cloud_queue"] = "rbxassetid://6031302916",
	["cloud_upload"] = "rbxassetid://6031302992",
	["code"] = "rbxassetid://6022668955",
	["collections"] = "rbxassetid://6031625145",
	["collections_bookmark"] = "rbxassetid://6034328965",
	["color_lens"] = "rbxassetid://6031625148",
	["colorize"] = "rbxassetid://6031625161",
	["comment"] = "rbxassetid://6035181871",
	["comment_bank"] = "rbxassetid://6023426937",
	["commute"] = "rbxassetid://6022668901",
	["compare"] = "rbxassetid://6031625151",
	["compare_arrows"] = "rbxassetid://6022668951",
	["compass_calibration"] = "rbxassetid://6034767623",
	["compress"] = "rbxassetid://6022668878",
	["computer"] = "rbxassetid://6034789874",
	["confirmation_number"] = "rbxassetid://6034418519",
	["connect_without_contact"] = "rbxassetid://6034275800",
	["connected_tv"] = "rbxassetid://6034789870",
	["construction"] = "rbxassetid://6034275725",
	["contact_mail"] = "rbxassetid://6035181868",
	["contact_page"] = "rbxassetid://6022668881",
	["contact_phone"] = "rbxassetid://6035181861",
	["contact_support"] = "rbxassetid://6022668879",
	["contactless"] = "rbxassetid://6022668886",
	["contacts"] = "rbxassetid://6035181864",
	["content_copy"] = "rbxassetid://6035053278",
	["content_cut"] = "rbxassetid://6035053280",
	["content_paste"] = "rbxassetid://6035053285",
	["control_camera"] = "rbxassetid://6026647916",
	["control_point"] = "rbxassetid://6031625131",
	["control_point_duplicate"] = "rbxassetid://6034328959",
	["copyright"] = "rbxassetid://6023565898",
	["coronavirus"] = "rbxassetid://6034275724",
	["corporate_fare"] = "rbxassetid://6035121908",
	["countertops"] = "rbxassetid://6035121914",
	["create"] = "rbxassetid://6035053304",
	["create_new_folder"] = "rbxassetid://6031302933",
	["crop"] = "rbxassetid://6034328964",
	["crop_16_9"] = "rbxassetid://6031630205",
	["crop_3_2"] = "rbxassetid://6034328956",
	["crop_5_4"] = "rbxassetid://6034328960",
	["crop_7_5"] = "rbxassetid://6031630197",
	["crop_din"] = "rbxassetid://6031630208",
	["crop_free"] = "rbxassetid://6031630212",
	["crop_landscape"] = "rbxassetid://6031630202",
	["crop_original"] = "rbxassetid://6031630204",
	["crop_portrait"] = "rbxassetid://6031630198",
	["crop_rotate"] = "rbxassetid://6031630203",
	["crop_square"] = "rbxassetid://6031630222",
	["dangerous"] = "rbxassetid://6022668916",
	["dashboard"] = "rbxassetid://6022668883",
	["dashboard_customize"] = "rbxassetid://6022668899",
	["data_usage"] = "rbxassetid://6034989568",
	["date_range"] = "rbxassetid://6022668894",
	["deck"] = "rbxassetid://6034295703",
	["dehaze"] = "rbxassetid://6031630200",
	["delete"] = "rbxassetid://6022668885",
	["delete_forever"] = "rbxassetid://6022668939",
	["delete_outline"] = "rbxassetid://6022668962",
	["delete_sweep"] = "rbxassetid://6035053301",
	["delivery_dining"] = "rbxassetid://6034767644",
	["departure_board"] = "rbxassetid://6034767615",
	["description"] = "rbxassetid://6022668888",
	["design_services"] = "rbxassetid://6034754453",
	["desktop_access_disabled"] = "rbxassetid://6035181863",
	["desktop_mac"] = "rbxassetid://6034789898",
	["desktop_windows"] = "rbxassetid://6034789893",
	["details"] = "rbxassetid://6034328968",
	["developer_board"] = "rbxassetid://6034789883",
	["developer_mode"] = "rbxassetid://6034989549",
	["device_hub"] = "rbxassetid://6034789877",
	["device_thermostat"] = "rbxassetid://6034989544",
	["device_unknown"] = "rbxassetid://6034789884",
	["devices"] = "rbxassetid://6034989540",
	["devices_other"] = "rbxassetid://6034789873",
	["dialer_sip"] = "rbxassetid://6035181865",
	["dialpad"] = "rbxassetid://6035181892",
	["dinner_dining"] = "rbxassetid://6034754457",
	["directions"] = "rbxassetid://6034754449",
	["directions_bike"] = "rbxassetid://6034754459",
	["directions_boat"] = "rbxassetid://6034754442",
	["directions_bus"] = "rbxassetid://6034754434",
	["directions_car"] = "rbxassetid://6034754441",
	["directions_off"] = "rbxassetid://6034418517",
	["directions_railway"] = "rbxassetid://6034754433",
	["directions_run"] = "rbxassetid://6034754445",
	["directions_subway"] = "rbxassetid://6034754440",
	["directions_transit"] = "rbxassetid://6034754436",
	["directions_walk"] = "rbxassetid://6034754448",
	["dirty_lens"] = "rbxassetid://6034328967",
	["disabled_by_default"] = "rbxassetid://6023426939",
	["disc_full"] = "rbxassetid://6034418518",
	["dns"] = "rbxassetid://6023426958",
	["do_not_disturb"] = "rbxassetid://6034439645",
	["do_not_disturb_alt"] = "rbxassetid://6034461619",
	["do_not_disturb_off"] = "rbxassetid://6034439642",
	["do_not_disturb_on"] = "rbxassetid://6034439649",
	["do_not_step"] = "rbxassetid://6035121910",
	["do_not_touch"] = "rbxassetid://6035121915",
	["dock"] = "rbxassetid://6034789888",
	["domain"] = "rbxassetid://6034275722",
	["domain_disabled"] = "rbxassetid://6035181862",
	["domain_verification"] = "rbxassetid://6035181867",
	["done"] = "rbxassetid://6023426926",
	["done_all"] = "rbxassetid://6023426929",
	["done_outline"] = "rbxassetid://6023426936",
	["double_arrow"] = "rbxassetid://6031094674",
	["drafts"] = "rbxassetid://6035053297",
	["drag_handle"] = "rbxassetid://6034910907",
	["drag_indicator"] = "rbxassetid://6023426962",
	["drive_eta"] = "rbxassetid://6034464371",
	["drive_file_move"] = "rbxassetid://6031302922",
	["drive_file_move_outline"] = "rbxassetid://6031302924",
	["drive_file_rename_outline"] = "rbxassetid://6031302994",
	["drive_folder_upload"] = "rbxassetid://6031302929",
	["dry"] = "rbxassetid://6035121909",
	["dry_cleaning"] = "rbxassetid://6034754456",
	["duo"] = "rbxassetid://6035181860",
	["dvr"] = "rbxassetid://6034989561",
	["dynamic_feed"] = "rbxassetid://6035053289",
	["dynamic_form"] = "rbxassetid://6023426970",
	["east"] = "rbxassetid://6031094675",
	["eco"] = "rbxassetid://6023426988",
	["edit"] = "rbxassetid://6034328955",
	["edit_attributes"] = "rbxassetid://6034754443",
	["edit_location"] = "rbxassetid://6034754439",
	["edit_off"] = "rbxassetid://6023426983",
	["edit_road"] = "rbxassetid://6034744035",
	["eject"] = "rbxassetid://6023426930",
	["elderly"] = "rbxassetid://6034295698",
	["electric_bike"] = "rbxassetid://6034744032",
	["electric_car"] = "rbxassetid://6034744029",
	["electric_moped"] = "rbxassetid://6034744027",
	["electric_rickshaw"] = "rbxassetid://6034744043",
	["electric_scooter"] = "rbxassetid://6034744041",
	["electrical_services"] = "rbxassetid://6034744038",
	["elevator"] = "rbxassetid://6035121912",
	["email"] = "rbxassetid://6035181866",
	["emoji_emotions"] = "rbxassetid://6034275731",
	["emoji_events"] = "rbxassetid://6034275726",
	["emoji_flags"] = "rbxassetid://6034304898",
	["emoji_food_beverage"] = "rbxassetid://6034304883",
	["emoji_nature"] = "rbxassetid://6034281896",
	["emoji_objects"] = "rbxassetid://6034281900",
	["emoji_people"] = "rbxassetid://6034281904",
	["emoji_symbols"] = "rbxassetid://6034281899",
	["emoji_transportation"] = "rbxassetid://6034281894",
	["engineering"] = "rbxassetid://6034281908",
	["enhanced_encryption"] = "rbxassetid://6034439652",
	["equalizer"] = "rbxassetid://6026647906",
	["escalator"] = "rbxassetid://6035121939",
	["escalator_warning"] = "rbxassetid://6035121930",
	["euro"] = "rbxassetid://6034328963",
	["euro_symbol"] = "rbxassetid://6023426954",
	["ev_station"] = "rbxassetid://6034744037",
	["event"] = "rbxassetid://6023426959",
	["event_available"] = "rbxassetid://6034439643",
	["event_busy"] = "rbxassetid://6034439634",
	["event_note"] = "rbxassetid://6034439637",
	["exit_to_app"] = "rbxassetid://6023426922",
	["expand"] = "rbxassetid://6022668891",
	["expand_less"] = "rbxassetid://6031094679",
	["expand_more"] = "rbxassetid://6031094687",
	["explicit"] = "rbxassetid://6026647913",
	["explore"] = "rbxassetid://6023426941",
	["explore_off"] = "rbxassetid://6023426953",
	["exposure"] = "rbxassetid://6034328962",
	["exposure_neg_1"] = "rbxassetid://6034328957",
	["exposure_neg_2"] = "rbxassetid://6034328973",
	["exposure_plus_1"] = "rbxassetid://6034328970",
	["exposure_plus_2"] = "rbxassetid://6034328961",
	["exposure_zero"] = "rbxassetid://6034329000",
	["extension"] = "rbxassetid://6023565892",
	["face"] = "rbxassetid://6023426944",
	["face_retouching_natural"] = "rbxassetid://6034333274",
	["facebook"] = "rbxassetid://6034281898",
	["fact_check"] = "rbxassetid://6023426951",
	["family_restroom"] = "rbxassetid://6035121916",
	["fast_forward"] = "rbxassetid://6026647902",
	["fast_rewind"] = "rbxassetid://6026647942",
	["fastfood"] = "rbxassetid://6034744034",
	["favorite"] = "rbxassetid://6023426974",
	["favorite_border"] = "rbxassetid://6023565882",
	["featured_play_list"] = "rbxassetid://6026647932",
	["featured_video"] = "rbxassetid://6026647910",
	["feedback"] = "rbxassetid://6023426957",
	["fence"] = "rbxassetid://6035121923",
	["festival"] = "rbxassetid://6034744031",
	["fiber_dvr"] = "rbxassetid://6026647912",
	["fiber_manual_record"] = "rbxassetid://6026647909",
	["fiber_new"] = "rbxassetid://6026647930",
	["fiber_pin"] = "rbxassetid://6026660064",
	["fiber_smart_record"] = "rbxassetid://6026660080",
	["file_copy"] = "rbxassetid://6035053293",
	["file_download"] = "rbxassetid://6031302931",
	["file_download_done"] = "rbxassetid://6031302926",
	["file_upload"] = "rbxassetid://6031302996",
	["filter"] = "rbxassetid://6031597514",
	["filter_1"] = "rbxassetid://6031597511",
	["filter_2"] = "rbxassetid://6031597521",
	["filter_3"] = "rbxassetid://6031597513",
	["filter_4"] = "rbxassetid://6031597512",
	["filter_5"] = "rbxassetid://6031597518",
	["filter_6"] = "rbxassetid://6031597524",
	["filter_7"] = "rbxassetid://6031597515",
	["filter_8"] = "rbxassetid://6031597532",
	["filter_9"] = "rbxassetid://6031597534",
	["filter_9_plus"] = "rbxassetid://6031600812",
	["filter_alt"] = "rbxassetid://6023426984",
	["filter_b_and_w"] = "rbxassetid://6031600824",
	["filter_center_focus"] = "rbxassetid://6031600817",
	["filter_drama"] = "rbxassetid://6031600813",
	["filter_frames"] = "rbxassetid://6031600833",
	["filter_hdr"] = "rbxassetid://6031600819",
	["filter_list"] = "rbxassetid://6035053294",
	["filter_list_alt"] = "rbxassetid://6023426955",
	["filter_none"] = "rbxassetid://6031600815",
	["filter_tilt_shift"] = "rbxassetid://6031600814",
	["filter_vintage"] = "rbxassetid://6031600811",
	["find_in_page"] = "rbxassetid://6023426986",
	["find_replace"] = "rbxassetid://6023426979",
	["fingerprint"] = "rbxassetid://6023565895",
	["fire_extinguisher"] = "rbxassetid://6035121913",
	["fireplace"] = "rbxassetid://6034281910",
	["first_page"] = "rbxassetid://6031094682",
	["fitness_center"] = "rbxassetid://6035121907",
	["flag"] = "rbxassetid://6035053279",
	["flaky"] = "rbxassetid://6031082523",
	["flare"] = "rbxassetid://6031600816",
	["flash_auto"] = "rbxassetid://6034333287",
	["flash_off"] = "rbxassetid://6034333270",
	["flash_on"] = "rbxassetid://6034333271",
	["flight"] = "rbxassetid://6034744030",
	["flight_land"] = "rbxassetid://6023565897",
	["flight_takeoff"] = "rbxassetid://6023565891",
	["flip"] = "rbxassetid://6034333275",
	["flip_camera_android"] = "rbxassetid://6034333280",
	["flip_camera_ios"] = "rbxassetid://6034333267",
	["flip_to_back"] = "rbxassetid://6023565896",
	["flip_to_front"] = "rbxassetid://6023565894",
	["folder"] = "rbxassetid://6031302932",
	["folder_open"] = "rbxassetid://6031302934",
	["folder_shared"] = "rbxassetid://6031302945",
	["folder_special"] = "rbxassetid://6034439639",
	["follow_the_signs"] = "rbxassetid://6034281911",
	["font_download"] = "rbxassetid://6035053275",
	["food_bank"] = "rbxassetid://6035121921",
	["format_align_center"] = "rbxassetid://6034900718",
	["format_align_justify"] = "rbxassetid://6034900721",
	["format_align_left"] = "rbxassetid://6034900727",
	["format_align_right"] = "rbxassetid://6034900723",
	["format_bold"] = "rbxassetid://6034900732",
	["format_clear"] = "rbxassetid://6034910902",
	["format_color_fill"] = "rbxassetid://6034910903",
	["format_color_reset"] = "rbxassetid://6034900743",
	["format_color_text"] = "rbxassetid://6034910910",
	["format_indent_decrease"] = "rbxassetid://6034900733",
	["format_indent_increase"] = "rbxassetid://6034900724",
	["format_italic"] = "rbxassetid://6034910912",
	["format_line_spacing"] = "rbxassetid://6034910905",
	["format_list_bulleted"] = "rbxassetid://6034925620",
	["format_list_numbered"] = "rbxassetid://6034925622",
	["format_list_numbered_rtl"] = "rbxassetid://6034910906",
	["format_paint"] = "rbxassetid://6034925618",
	["format_quote"] = "rbxassetid://6034925629",
	["format_shapes"] = "rbxassetid://6034910909",
	["format_size"] = "rbxassetid://6034910908",
	["format_strikethrough"] = "rbxassetid://6034910904",
	["format_textdirection_l_to_r"] = "rbxassetid://6034925619",
	["format_textdirection_r_to_l"] = "rbxassetid://6034925623",
	["format_underlined"] = "rbxassetid://6034925627",
	["forum"] = "rbxassetid://6035202002",
	["forward"] = "rbxassetid://6035053298",
	["forward_10"] = "rbxassetid://6026660062",
	["forward_30"] = "rbxassetid://6026660088",
	["forward_5"] = "rbxassetid://6026660067",
	["forward_to_inbox"] = "rbxassetid://6035190840",
	["foundation"] = "rbxassetid://6035121918",
	["free_breakfast"] = "rbxassetid://6035145363",
	["fullscreen"] = "rbxassetid://6031094681",
	["fullscreen_exit"] = "rbxassetid://6031094691",
	["functions"] = "rbxassetid://6034925614",
	["g_translate"] = "rbxassetid://6031082526",
	["gamepad"] = "rbxassetid://6034789879",
	["games"] = "rbxassetid://6026660074",
	["gavel"] = "rbxassetid://6023565902",
	["gesture"] = "rbxassetid://6035053287",
	["get_app"] = "rbxassetid://6023565889",
	["gif"] = "rbxassetid://6031082540",
	["golf_course"] = "rbxassetid://6035145423",
	["gps_fixed"] = "rbxassetid://6034989550",
	["gps_not_fixed"] = "rbxassetid://6034989547",
	["gps_off"] = "rbxassetid://6034989548",
	["grade"] = "rbxassetid://6026568189",
	["gradient"] = "rbxassetid://6034333261",
	["grading"] = "rbxassetid://6026568191",
	["grain"] = "rbxassetid://6034333288",
	["graphic_eq"] = "rbxassetid://6034989551",
	["grass"] = "rbxassetid://6035145359",
	["grid_off"] = "rbxassetid://6034333286",
	["grid_on"] = "rbxassetid://6034333276",
	["grid_view"] = "rbxassetid://6031302950",
	["group"] = "rbxassetid://6034281901",
	["group_add"] = "rbxassetid://6034281909",
	["group_work"] = "rbxassetid://6023565910",
	["groups"] = "rbxassetid://6034281935",
	["hail"] = "rbxassetid://6034744033",
	["handyman"] = "rbxassetid://6034744057",
	["hardware"] = "rbxassetid://6034744036",
	["hd"] = "rbxassetid://6026660065",
	["hdr_enhanced_select"] = "rbxassetid://6034333281",
	["hdr_off"] = "rbxassetid://6034333266",
	["hdr_on"] = "rbxassetid://6034333279",
	["hdr_strong"] = "rbxassetid://6034333272",
	["hdr_weak"] = "rbxassetid://6034407083",
	["headset"] = "rbxassetid://6034789880",
	["headset_mic"] = "rbxassetid://6034818383",
	["headset_off"] = "rbxassetid://6034818402",
	["healing"] = "rbxassetid://6034407071",
	["hearing"] = "rbxassetid://6026660060",
	["hearing_disabled"] = "rbxassetid://6026660068",
	["height"] = "rbxassetid://6034925613",
	["help_center"] = "rbxassetid://6026568192",
	["help_outline"] = "rbxassetid://6026568201",
	["high_quality"] = "rbxassetid://6026660059",
	["highlight"] = "rbxassetid://6034925617",
	["highlight_alt"] = "rbxassetid://6023565913",
	["highlight_off"] = "rbxassetid://6023565916",
	["history"] = "rbxassetid://6026568197",
	["history_edu"] = "rbxassetid://6034281934",
	["history_toggle_off"] = "rbxassetid://6026568196",
	["home"] = "rbxassetid://6026568195",
	["home_filled"] = "rbxassetid://6026568198",
	["home_repair_service"] = "rbxassetid://6034744064",
	["home_work"] = "rbxassetid://6031094683",
	["horizontal_rule"] = "rbxassetid://6034925610",
	["horizontal_split"] = "rbxassetid://6026568194",
	["hot_tub"] = "rbxassetid://6035145382",
	["hotel"] = "rbxassetid://6034687977",
	["hourglass_bottom"] = "rbxassetid://6035202043",
	["hourglass_disabled"] = "rbxassetid://6026568193",
	["hourglass_full"] = "rbxassetid://6026568190",
	["hourglass_top"] = "rbxassetid://6035190886",
	["house"] = "rbxassetid://6035145364",
	["house_siding"] = "rbxassetid://6035145393",
	["how_to_reg"] = "rbxassetid://6035053288",
	["how_to_vote"] = "rbxassetid://6035053295",
	["https"] = "rbxassetid://6026568200",
	["hvac"] = "rbxassetid://6034687960",
	["icecream"] = "rbxassetid://6034687967",
	["image"] = "rbxassetid://6034407078",
	["image_aspect_ratio"] = "rbxassetid://6034407073",
	["image_not_supported"] = "rbxassetid://6034407076",
	["image_search"] = "rbxassetid://6034407084",
	["imagesearch_roller"] = "rbxassetid://6034439635",
	["import_contacts"] = "rbxassetid://6035190854",
	["import_export"] = "rbxassetid://6035202040",
	["important_devices"] = "rbxassetid://6026568202",
	["inbox"] = "rbxassetid://6035067831",
	["indeterminate_check_box"] = "rbxassetid://6031068445",
	["info"] = "rbxassetid://6026568227",
	["info_outline"] = "rbxassetid://6026568210",
	["input"] = "rbxassetid://6026568225",
	["insert_chart"] = "rbxassetid://6034925628",
	["insert_chart_outlined"] = "rbxassetid://6034925606",
	["insert_comment"] = "rbxassetid://6034925609",
	["insert_drive_file"] = "rbxassetid://6034941697",
	["insert_emoticon"] = "rbxassetid://6034973079",
	["insert_invitation"] = "rbxassetid://6034973091",
	["insert_link"] = "rbxassetid://6034973074",
	["insert_photo"] = "rbxassetid://6034941703",
	["insights"] = "rbxassetid://6035067839",
	["integration_instructions"] = "rbxassetid://6026568214",
	["inventory"] = "rbxassetid://6035056487",
	["invert_colors"] = "rbxassetid://6026568253",
	["invert_colors_off"] = "rbxassetid://6035190842",
	["ios_share"] = "rbxassetid://6034281941",
	["iso"] = "rbxassetid://6034407106",
	["keyboard"] = "rbxassetid://6034818398",
	["keyboard_arrow_down"] = "rbxassetid://6034818372",
	["keyboard_arrow_left"] = "rbxassetid://6034818375",
	["keyboard_arrow_right"] = "rbxassetid://6034818365",
	["keyboard_arrow_up"] = "rbxassetid://6034818379",
	["keyboard_backspace"] = "rbxassetid://6034818381",
	["keyboard_capslock"] = "rbxassetid://6034818403",
	["keyboard_hide"] = "rbxassetid://6034818386",
	["keyboard_return"] = "rbxassetid://6034818370",
	["keyboard_tab"] = "rbxassetid://6034818363",
	["keyboard_voice"] = "rbxassetid://6034818360",
	["king_bed"] = "rbxassetid://6034281948",
	["kitchen"] = "rbxassetid://6035145362",
	["label"] = "rbxassetid://6031082525",
	["label_important"] = "rbxassetid://6026568215",
	["label_important_outline"] = "rbxassetid://6026568199",
	["label_off"] = "rbxassetid://6026568209",
	["label_outline"] = "rbxassetid://6026568207",
	["landscape"] = "rbxassetid://6034407069",
	["language"] = "rbxassetid://6026568213",
	["laptop"] = "rbxassetid://6034818367",
	["laptop_chromebook"] = "rbxassetid://6034818364",
	["laptop_mac"] = "rbxassetid://6034837808",
	["laptop_windows"] = "rbxassetid://6034837796",
	["last_page"] = "rbxassetid://6031094686",
	["launch"] = "rbxassetid://6026568211",
	["layers"] = "rbxassetid://6034687957",
	["layers_clear"] = "rbxassetid://6034687975",
	["leaderboard"] = "rbxassetid://6026568216",
	["leak_add"] = "rbxassetid://6034407074",
	["leak_remove"] = "rbxassetid://6034407080",
	["legend_toggle"] = "rbxassetid://6031097233",
	["lens"] = "rbxassetid://6034407081",
	["library_add"] = "rbxassetid://6026660063",
	["library_add_check"] = "rbxassetid://6026660083",
	["library_books"] = "rbxassetid://6026660085",
	["library_music"] = "rbxassetid://6026660075",
	["lightbulb"] = "rbxassetid://6026568247",
	["lightbulb_outline"] = "rbxassetid://6026568254",
	["line_style"] = "rbxassetid://6026568276",
	["line_weight"] = "rbxassetid://6026568226",
	["linear_scale"] = "rbxassetid://6034941707",
	["link"] = "rbxassetid://6035056475",
	["link_off"] = "rbxassetid://6035056484",
	["linked_camera"] = "rbxassetid://6034407082",
	["list"] = "rbxassetid://6026568229",
	["list_alt"] = "rbxassetid://6035190838",
	["live_help"] = "rbxassetid://6035190836",
	["live_tv"] = "rbxassetid://6034439648",
	["local_activity"] = "rbxassetid://6034687955",
	["local_airport"] = "rbxassetid://6034687951",
	["local_atm"] = "rbxassetid://6034687953",
	["local_bar"] = "rbxassetid://6034687950",
	["local_cafe"] = "rbxassetid://6034687954",
	["local_car_wash"] = "rbxassetid://6034687976",
	["local_convenience_store"] = "rbxassetid://6034687956",
	["local_dining"] = "rbxassetid://6034687963",
	["local_drink"] = "rbxassetid://6034687965",
	["local_fire_department"] = "rbxassetid://6034684949",
	["local_florist"] = "rbxassetid://6034684940",
	["local_gas_station"] = "rbxassetid://6034684935",
	["local_grocery_store"] = "rbxassetid://6034684933",
	["local_hospital"] = "rbxassetid://6034684956",
	["local_hotel"] = "rbxassetid://6034684939",
	["local_laundry_service"] = "rbxassetid://6034684943",
	["local_library"] = "rbxassetid://6034684931",
	["local_mall"] = "rbxassetid://6034684934",
	["local_movies"] = "rbxassetid://6034684936",
	["local_offer"] = "rbxassetid://6034513891",
	["local_parking"] = "rbxassetid://6034513893",
	["local_pharmacy"] = "rbxassetid://6034513903",
	["local_phone"] = "rbxassetid://6034513884",
	["local_pizza"] = "rbxassetid://6034513885",
	["local_play"] = "rbxassetid://6034513889",
	["local_police"] = "rbxassetid://6034513895",
	["local_post_office"] = "rbxassetid://6034513883",
	["local_printshop"] = "rbxassetid://6034513897",
	["local_see"] = "rbxassetid://6034513887",
	["local_shipping"] = "rbxassetid://6034684926",
	["local_taxi"] = "rbxassetid://6034684927",
	["location_city"] = "rbxassetid://6034304889",
	["location_disabled"] = "rbxassetid://6034996694",
	["location_off"] = "rbxassetid://6035202049",
	["location_on"] = "rbxassetid://6035190846",
	["location_pin"] = "rbxassetid://6034684937",
	["location_searching"] = "rbxassetid://6034996695",
	["lock"] = "rbxassetid://6026568224",
	["lock_clock"] = "rbxassetid://6026568260",
	["lock_open"] = "rbxassetid://6026568220",
	["lock_outline"] = "rbxassetid://6031082533",
	["login"] = "rbxassetid://6031082527",
	["logout"] = "rbxassetid://6031082522",
	["looks"] = "rbxassetid://6034407096",
	["looks_3"] = "rbxassetid://6034407088",
	["looks_4"] = "rbxassetid://6034407089",
	["looks_5"] = "rbxassetid://6034412764",
	["looks_6"] = "rbxassetid://6034412759",
	["looks_one"] = "rbxassetid://6034412761",
	["looks_two"] = "rbxassetid://6034412757",
	["loop"] = "rbxassetid://6026660087",
	["loupe"] = "rbxassetid://6034412770",
	["low_priority"] = "rbxassetid://6035056491",
	["loyalty"] = "rbxassetid://6026568237",
	["luggage"] = "rbxassetid://6034295708",
	["lunch_dining"] = "rbxassetid://6034684928",
	["mail"] = "rbxassetid://6035056477",
	["mail_outline"] = "rbxassetid://6035190844",
	["map"] = "rbxassetid://6034684930",
	["maps_ugc"] = "rbxassetid://6034509992",
	["margin"] = "rbxassetid://6034941701",
	["mark_as_unread"] = "rbxassetid://6026568223",
	["mark_chat_read"] = "rbxassetid://6035202031",
	["mark_chat_unread"] = "rbxassetid://6035190841",
	["mark_email_read"] = "rbxassetid://6035202038",
	["mark_email_unread"] = "rbxassetid://6035202027",
	["markunread"] = "rbxassetid://6035056476",
	["markunread_mailbox"] = "rbxassetid://6031082531",
	["masks"] = "rbxassetid://6034295710",
	["maximize"] = "rbxassetid://6026568267",
	["mediation"] = "rbxassetid://6026568249",
	["medical_services"] = "rbxassetid://6034510001",
	["meeting_room"] = "rbxassetid://6035145361",
	["memory"] = "rbxassetid://6034837807",
	["menu"] = "rbxassetid://6031097225",
	["menu_book"] = "rbxassetid://6034509994",
	["menu_open"] = "rbxassetid://6031097229",
	["merge_type"] = "rbxassetid://6034941705",
	["message"] = "rbxassetid://6035202033",
	["mic"] = "rbxassetid://6026660078",
	["mic_external_off"] = "rbxassetid://6034323672",
	["mic_external_on"] = "rbxassetid://6034323671",
	["mic_none"] = "rbxassetid://6026660066",
	["mic_off"] = "rbxassetid://6026660076",
	["microwave"] = "rbxassetid://6035145367",
	["military_tech"] = "rbxassetid://6034295711",
	["minimize"] = "rbxassetid://6026568240",
	["miscellaneous_services"] = "rbxassetid://6034509993",
	["mms"] = "rbxassetid://6034461621",
	["mobile_friendly"] = "rbxassetid://6034996699",
	["mobile_off"] = "rbxassetid://6034996702",
	["mobile_screen_share"] = "rbxassetid://6035202021",
	["mode_comment"] = "rbxassetid://6034941700",
	["mode_edit"] = "rbxassetid://6034941708",
	["model_training"] = "rbxassetid://6026568222",
	["monetization_on"] = "rbxassetid://6034973115",
	["money"] = "rbxassetid://6034509997",
	["money_off"] = "rbxassetid://6034973088",
	["monitor"] = "rbxassetid://6034837803",
	["monochrome_photos"] = "rbxassetid://6034323678",
	["mood"] = "rbxassetid://6034295704",
	["mood_bad"] = "rbxassetid://6034295706",
	["moped"] = "rbxassetid://6034509999",
	["more"] = "rbxassetid://6034461627",
	["more_horiz"] = "rbxassetid://6031104650",
	["more_time"] = "rbxassetid://6035202036",
	["more_vert"] = "rbxassetid://6031104648",
	["motion_photos_off"] = "rbxassetid://6034323670",
	["motion_photos_on"] = "rbxassetid://6034323669",
	["motion_photos_pause"] = "rbxassetid://6034323668",
	["motion_photos_paused"] = "rbxassetid://6034323675",
	["mouse"] = "rbxassetid://6034837797",
	["move_to_inbox"] = "rbxassetid://6035067838",
	["movie"] = "rbxassetid://6026660081",
	["movie_creation"] = "rbxassetid://6034323681",
	["movie_filter"] = "rbxassetid://6034323687",
	["mp"] = "rbxassetid://6034323674",
	["multiline_chart"] = "rbxassetid://6034941721",
	["multiple_stop"] = "rbxassetid://6034510026",
	["museum"] = "rbxassetid://6034510005",
	["music_note"] = "rbxassetid://6034323673",
	["music_off"] = "rbxassetid://6034323679",
	["music_video"] = "rbxassetid://6026663704",
	["my_location"] = "rbxassetid://6034509987",
	["nat"] = "rbxassetid://6035202082",
	["nature"] = "rbxassetid://6034323695",
	["nature_people"] = "rbxassetid://6034323711",
	["navigate_before"] = "rbxassetid://6034323696",
	["navigate_next"] = "rbxassetid://6034315956",
	["navigation"] = "rbxassetid://6034509984",
	["near_me"] = "rbxassetid://6034509996",
	["near_me_disabled"] = "rbxassetid://6034509988",
	["network_cell"] = "rbxassetid://6034996709",
	["network_check"] = "rbxassetid://6034461631",
	["network_locked"] = "rbxassetid://6034457064",
	["network_wifi"] = "rbxassetid://6034996712",
	["new_releases"] = "rbxassetid://6026663730",
	["next_plan"] = "rbxassetid://6026568231",
	["next_week"] = "rbxassetid://6035067835",
	["nfc"] = "rbxassetid://6034996698",
	["night_shelter"] = "rbxassetid://6035145378",
	["nightlife"] = "rbxassetid://6034510003",
	["nightlight_round"] = "rbxassetid://6031084743",
	["nights_stay"] = "rbxassetid://6034304881",
	["no_backpack"] = "rbxassetid://6035145368",
	["no_cell"] = "rbxassetid://6035145376",
	["no_drinks"] = "rbxassetid://6035145390",
	["no_encryption"] = "rbxassetid://6034457059",
	["no_flash"] = "rbxassetid://6035145424",
	["no_food"] = "rbxassetid://6035145372",
	["no_luggage"] = "rbxassetid://6034304891",
	["no_meals"] = "rbxassetid://6034510024",
	["no_meals_ouline"] = "rbxassetid://6034510025",
	["no_meeting_room"] = "rbxassetid://6035153649",
	["no_photography"] = "rbxassetid://6035153664",
	["no_sim"] = "rbxassetid://6035202030",
	["no_stroller"] = "rbxassetid://6035153661",
	["no_transfer"] = "rbxassetid://6034503363",
	["north_east"] = "rbxassetid://6031097228",
	["north_west"] = "rbxassetid://6031104630",
	["not_accessible"] = "rbxassetid://6026568269",
	["not_interested"] = "rbxassetid://6026663743",
	["not_listed_location"] = "rbxassetid://6034503380",
	["not_started"] = "rbxassetid://6026568232",
	["note"] = "rbxassetid://6026663734",
	["note_add"] = "rbxassetid://6031084749",
	["notes"] = "rbxassetid://6034973084",
	["notifications"] = "rbxassetid://6034308946",
	["notifications_active"] = "rbxassetid://6034304908",
	["notifications_none"] = "rbxassetid://6034308947",
	["notifications_off"] = "rbxassetid://6034304894",
	["notifications_paused"] = "rbxassetid://6034304896",
	["offline_bolt"] = "rbxassetid://6031084742",
	["offline_pin"] = "rbxassetid://6031084770",
	["offline_share"] = "rbxassetid://6031097267",
	["ondemand_video"] = "rbxassetid://6034457065",
	["online_prediction"] = "rbxassetid://6026568239",
	["opacity"] = "rbxassetid://6026568295",
	["open_in_browser"] = "rbxassetid://6026568266",
	["open_in_full"] = "rbxassetid://6026568245",
	["open_in_new"] = "rbxassetid://6026568256",
	["open_with"] = "rbxassetid://6026568265",
	["outbond"] = "rbxassetid://6026568244",
	["outbox"] = "rbxassetid://6026568263",
	["outdoor_grill"] = "rbxassetid://6034304900",
	["outgoing_mail"] = "rbxassetid://6026568242",
	["outlet"] = "rbxassetid://6031084748",
	["outlined_flag"] = "rbxassetid://6035056486",
	["padding"] = "rbxassetid://6034973078",
	["pages"] = "rbxassetid://6034304892",
	["pageview"] = "rbxassetid://6031216007",
	["palette"] = "rbxassetid://6034316009",
	["pan_tool"] = "rbxassetid://6031084771",
	["panorama"] = "rbxassetid://6034315955",
	["panorama_fish_eye"] = "rbxassetid://6034315969",
	["panorama_horizontal"] = "rbxassetid://6034315966",
	["panorama_horizontal_select"] = "rbxassetid://6034315965",
	["panorama_photosphere"] = "rbxassetid://6034412763",
	["panorama_photosphere_select"] = "rbxassetid://6034315975",
	["panorama_vertical"] = "rbxassetid://6034315963",
	["panorama_vertical_select"] = "rbxassetid://6034315961",
	["panorama_wide_angle"] = "rbxassetid://6031770995",
	["panorama_wide_angle_select"] = "rbxassetid://6031770990",
	["park"] = "rbxassetid://6034503369",
	["party_mode"] = "rbxassetid://6034287521",
	["pause"] = "rbxassetid://6026663719",
	["pause_circle_filled"] = "rbxassetid://6026663718",
	["pause_circle_outline"] = "rbxassetid://6026663701",
	["pause_presentation"] = "rbxassetid://6035202015",
	["payment"] = "rbxassetid://6031084751",
	["payments"] = "rbxassetid://6031097227",
	["pedal_bike"] = "rbxassetid://6034503374",
	["pending"] = "rbxassetid://6031084745",
	["pending_actions"] = "rbxassetid://6031260777",
	["people"] = "rbxassetid://6034287513",
	["people_alt"] = "rbxassetid://6034287518",
	["people_outline"] = "rbxassetid://6034287528",
	["perm_camera_mic"] = "rbxassetid://6031215983",
	["perm_contact_calendar"] = "rbxassetid://6031215990",
	["perm_data_setting"] = "rbxassetid://6031215991",
	["perm_device_information"] = "rbxassetid://6031215996",
	["perm_identity"] = "rbxassetid://6031215978",
	["perm_media"] = "rbxassetid://6031215982",
	["perm_phone_msg"] = "rbxassetid://6031215986",
	["perm_scan_wifi"] = "rbxassetid://6031215985",
	["person"] = "rbxassetid://6034287594",
	["person_add"] = "rbxassetid://6034287514",
	["person_add_alt"] = "rbxassetid://6034267994",
	["person_add_alt_1"] = "rbxassetid://6034287519",
	["person_add_disabled"] = "rbxassetid://6035202007",
	["person_outline"] = "rbxassetid://6034268008",
	["person_pin"] = "rbxassetid://6034503364",
	["person_pin_circle"] = "rbxassetid://6034503375",
	["person_remove"] = "rbxassetid://6034267996",
	["person_remove_alt_1"] = "rbxassetid://6034287515",
	["person_search"] = "rbxassetid://6035202013",
	["personal_video"] = "rbxassetid://6034457070",
	["pest_control"] = "rbxassetid://6034470809",
	["pest_control_rodent"] = "rbxassetid://6034470803",
	["pets"] = "rbxassetid://6031260782",
	["phone"] = "rbxassetid://6035202017",
	["phone_android"] = "rbxassetid://6034837793",
	["phone_bluetooth_speaker"] = "rbxassetid://6034457057",
	["phone_callback"] = "rbxassetid://6034457104",
	["phone_disabled"] = "rbxassetid://6035202028",
	["phone_enabled"] = "rbxassetid://6035202089",
	["phone_forwarded"] = "rbxassetid://6034457106",
	["phone_in_talk"] = "rbxassetid://6034457067",
	["phone_iphone"] = "rbxassetid://6034837811",
	["phone_locked"] = "rbxassetid://6034457058",
	["phone_missed"] = "rbxassetid://6034457056",
	["phone_paused"] = "rbxassetid://6034457066",
	["phonelink"] = "rbxassetid://6034837801",
	["phonelink_erase"] = "rbxassetid://6035202085",
	["phonelink_lock"] = "rbxassetid://6035202064",
	["phonelink_off"] = "rbxassetid://6034837804",
	["phonelink_ring"] = "rbxassetid://6035202066",
	["phonelink_setup"] = "rbxassetid://6035202025",
	["photo"] = "rbxassetid://6031770993",
	["photo_album"] = "rbxassetid://6031770989",
	["photo_camera"] = "rbxassetid://6031770997",
	["photo_camera_back"] = "rbxassetid://6031771007",
	["photo_camera_front"] = "rbxassetid://6031771000",
	["photo_filter"] = "rbxassetid://6031770992",
	["photo_library"] = "rbxassetid://6031770998",
	["photo_size_select_actual"] = "rbxassetid://6031771012",
	["photo_size_select_large"] = "rbxassetid://6031763423",
	["photo_size_select_small"] = "rbxassetid://6031763457",
	["picture_as_pdf"] = "rbxassetid://6031763425",
	["picture_in_picture"] = "rbxassetid://6031215994",
	["picture_in_picture_alt"] = "rbxassetid://6031215979",
	["pie_chart"] = "rbxassetid://6034973076",
	["pie_chart_outlined"] = "rbxassetid://6034973077",
	["pin_drop"] = "rbxassetid://6034470807",
	["pivot_table_chart"] = "rbxassetid://6031097234",
	["place"] = "rbxassetid://6034503372",
	["plagiarism"] = "rbxassetid://6031243320",
	["play_arrow"] = "rbxassetid://6026663699",
	["play_circle_filled"] = "rbxassetid://6026663705",
	["play_circle_outline"] = "rbxassetid://6026663726",
	["play_disabled"] = "rbxassetid://6026663702",
	["play_for_work"] = "rbxassetid://6031260776",
	["playlist_add"] = "rbxassetid://6026663728",
	["playlist_add_check"] = "rbxassetid://6026663727",
	["playlist_play"] = "rbxassetid://6026663723",
	["plumbing"] = "rbxassetid://6034470800",
	["plus_one"] = "rbxassetid://6034268012",
	["point_of_sale"] = "rbxassetid://6034837798",
	["policy"] = "rbxassetid://6035056512",
	["poll"] = "rbxassetid://6034267991",
	["polymer"] = "rbxassetid://6031260785",
	["pool"] = "rbxassetid://6035153655",
	["portable_wifi_off"] = "rbxassetid://6035202091",
	["portrait"] = "rbxassetid://6031763434",
	["post_add"] = "rbxassetid://6034973083",
	["power"] = "rbxassetid://6034457105",
	["power_input"] = "rbxassetid://6034837794",
	["power_off"] = "rbxassetid://6034457087",
	["power_settings_new"] = "rbxassetid://6031260781",
	["present_to_all"] = "rbxassetid://6035202020",
	["preview"] = "rbxassetid://6031260793",
	["print"] = "rbxassetid://6031243324",
	["print_disabled"] = "rbxassetid://6035202041",
	["priority_high"] = "rbxassetid://6034457092",
	["privacy_tip"] = "rbxassetid://6031260784",
	["psychology"] = "rbxassetid://6034287516",
	["public"] = "rbxassetid://6034287522",
	["public_off"] = "rbxassetid://6034287538",
	["publish"] = "rbxassetid://6034973085",
	["published_with_changes"] = "rbxassetid://6031243328",
	["push_pin"] = "rbxassetid://6035056481",
	["qr_code"] = "rbxassetid://6035202012",
	["qr_code_scanner"] = "rbxassetid://6035202022",
	["query_builder"] = "rbxassetid://6031086183",
	["question_answer"] = "rbxassetid://6031086172",
	["queue"] = "rbxassetid://6026663724",
	["queue_music"] = "rbxassetid://6026663725",
	["queue_play_next"] = "rbxassetid://6026663700",
	["quickreply"] = "rbxassetid://6031243319",
	["radio"] = "rbxassetid://6026663698",
	["radio_button_checked"] = "rbxassetid://6031068426",
	["radio_button_unchecked"] = "rbxassetid://6031068433",
	["railway_alert"] = "rbxassetid://6034470823",
	["ramen_dining"] = "rbxassetid://6034503377",
	["rate_review"] = "rbxassetid://6034503385",
	["read_more"] = "rbxassetid://6035202014",
	["receipt"] = "rbxassetid://6031086173",
	["receipt_long"] = "rbxassetid://6031763428",
	["recent_actors"] = "rbxassetid://6026663773",
	["recommend"] = "rbxassetid://6034287524",
	["record_voice_over"] = "rbxassetid://6031243318",
	["redeem"] = "rbxassetid://6031086170",
	["redo"] = "rbxassetid://6035056483",
	["reduce_capacity"] = "rbxassetid://6034268013",
	["refresh"] = "rbxassetid://6031097226",
	["remove"] = "rbxassetid://6035067836",
	["remove_circle"] = "rbxassetid://6035067837",
	["remove_circle_outline"] = "rbxassetid://6035067843",
	["remove_done"] = "rbxassetid://6031086169",
	["remove_from_queue"] = "rbxassetid://6026663771",
	["remove_moderator"] = "rbxassetid://6034267998",
	["remove_red_eye"] = "rbxassetid://6031763426",
	["remove_shopping_cart"] = "rbxassetid://6031260778",
	["reorder"] = "rbxassetid://6031154868",
	["repeat"] = "rbxassetid://6026666998",
	["repeat_on"] = "rbxassetid://6026666994",
	["repeat_one"] = "rbxassetid://6026681590",
	["repeat_one_on"] = "rbxassetid://6026666992",
	["replay"] = "rbxassetid://6026666999",
	["replay_10"] = "rbxassetid://6026667007",
	["replay_30"] = "rbxassetid://6026667010",
	["replay_5"] = "rbxassetid://6026666993",
	["replay_circle_filled"] = "rbxassetid://6026667002",
	["reply"] = "rbxassetid://6035067844",
	["reply_all"] = "rbxassetid://6035067824",
	["report"] = "rbxassetid://6035067826",
	["report_off"] = "rbxassetid://6035067830",
	["report_problem"] = "rbxassetid://6031086176",
	["request_page"] = "rbxassetid://6031154873",
	["request_quote"] = "rbxassetid://6031302941",
	["reset_tv"] = "rbxassetid://6034996696",
	["restaurant"] = "rbxassetid://6034503366",
	["restaurant_menu"] = "rbxassetid://6034503378",
	["restore"] = "rbxassetid://6031260800",
	["restore_from_trash"] = "rbxassetid://6031154869",
	["restore_page"] = "rbxassetid://6031154877",
	["rice_bowl"] = "rbxassetid://6035153662",
	["ring_volume"] = "rbxassetid://6035202032",
	["roofing"] = "rbxassetid://6035153656",
	["room"] = "rbxassetid://6031154875",
	["room_preferences"] = "rbxassetid://6035153642",
	["room_service"] = "rbxassetid://6035153648",
	["rotate_90_degrees_ccw"] = "rbxassetid://6031763456",
	["rotate_left"] = "rbxassetid://6031763427",
	["rotate_right"] = "rbxassetid://6031763429",
	["rounded_corner"] = "rbxassetid://6031154861",
	["router"] = "rbxassetid://6034837806",
	["rowing"] = "rbxassetid://6031154857",
	["rss_feed"] = "rbxassetid://6035202016",
	["rtt"] = "rbxassetid://6035202010",
	["rule"] = "rbxassetid://6031154859",
	["rule_folder"] = "rbxassetid://6031302940",
	["run_circle"] = "rbxassetid://6034503367",
	["sanitizer"] = "rbxassetid://6034287586",
	["satellite"] = "rbxassetid://6034503370",
	["save"] = "rbxassetid://6035067857",
	["save_alt"] = "rbxassetid://6035067842",
	["saved_search"] = "rbxassetid://6031154867",
	["scanner"] = "rbxassetid://6034837799",
	["scatter_plot"] = "rbxassetid://6034973094",
	["schedule"] = "rbxassetid://6031260808",
	["schedule_send"] = "rbxassetid://6031154866",
	["school"] = "rbxassetid://6034230641",
	["science"] = "rbxassetid://6034230640",
	["score"] = "rbxassetid://6034934041",
	["screen_lock_landscape"] = "rbxassetid://6034996700",
	["screen_lock_portrait"] = "rbxassetid://6034996706",
	["screen_lock_rotation"] = "rbxassetid://6034996710",
	["screen_rotation"] = "rbxassetid://6034996701",
	["screen_search_desktop"] = "rbxassetid://6034996711",
	["screen_share"] = "rbxassetid://6035202008",
	["sd"] = "rbxassetid://6026681582",
	["sd_card"] = "rbxassetid://6034457089",
	["sd_storage"] = "rbxassetid://6034996719",
	["search"] = "rbxassetid://6031154871",
	["search_off"] = "rbxassetid://6031260783",
	["security"] = "rbxassetid://6034837802",
	["segment"] = "rbxassetid://6031260773",
	["select_all"] = "rbxassetid://6035067834",
	["self_improvement"] = "rbxassetid://6034230634",
	["send"] = "rbxassetid://6035067832",
	["send_and_archive"] = "rbxassetid://6031280889",
	["send_to_mobile"] = "rbxassetid://6034996697",
	["sensor_door"] = "rbxassetid://6031067241",
	["sensor_window"] = "rbxassetid://6031067242",
	["sentiment_dissatisfied"] = "rbxassetid://6034230637",
	["sentiment_neutral"] = "rbxassetid://6034230636",
	["sentiment_satisfied"] = "rbxassetid://6034230668",
	["sentiment_satisfied_alt"] = "rbxassetid://6035202069",
	["sentiment_very_dissatisfied"] = "rbxassetid://6034230659",
	["sentiment_very_satisfied"] = "rbxassetid://6034230650",
	["set_meal"] = "rbxassetid://6034503368",
	["settings"] = "rbxassetid://6031280882",
	["settings_applications"] = "rbxassetid://6031280894",
	["settings_backup_restore"] = "rbxassetid://6031280886",
	["settings_bluetooth"] = "rbxassetid://6031280905",
	["settings_brightness"] = "rbxassetid://6031280902",
	["settings_cell"] = "rbxassetid://6031280890",
	["settings_ethernet"] = "rbxassetid://6031280883",
	["settings_input_antenna"] = "rbxassetid://6031280891",
	["settings_input_component"] = "rbxassetid://6031280884",
	["settings_input_composite"] = "rbxassetid://6031280896",
	["settings_input_hdmi"] = "rbxassetid://6031280970",
	["settings_input_svideo"] = "rbxassetid://6031289444",
	["settings_overscan"] = "rbxassetid://6031289459",
	["settings_phone"] = "rbxassetid://6031289445",
	["settings_power"] = "rbxassetid://6031289446",
	["settings_remote"] = "rbxassetid://6031289442",
	["settings_system_daydream"] = "rbxassetid://6035030081",
	["settings_voice"] = "rbxassetid://6031265966",
	["share"] = "rbxassetid://6034230648",
	["shield"] = "rbxassetid://6035078889",
	["shop"] = "rbxassetid://6031265983",
	["shop_two"] = "rbxassetid://6031289461",
	["shopping_bag"] = "rbxassetid://6031265970",
	["shopping_basket"] = "rbxassetid://6031265997",
	["shopping_cart"] = "rbxassetid://6031265976",
	["short_text"] = "rbxassetid://6034934035",
	["show_chart"] = "rbxassetid://6034934032",
	["shuffle"] = "rbxassetid://6026667003",
	["shuffle_on"] = "rbxassetid://6026666996",
	["shutter_speed"] = "rbxassetid://6031763443",
	["sick"] = "rbxassetid://6034230642",
	["signal_cellular_0_bar"] = "rbxassetid://6035030072",
	["signal_cellular_4_bar"] = "rbxassetid://6035030076",
	["signal_cellular_alt"] = "rbxassetid://6035030079",
	["signal_cellular_connected_no_internet_4"] = "rbxassetid://6035229858",
	["signal_cellular_no_sim"] = "rbxassetid://6035030078",
	["signal_cellular_null"] = "rbxassetid://6035030075",
	["signal_cellular_off"] = "rbxassetid://6035030084",
	["signal_wifi_0_bar"] = "rbxassetid://6035030067",
	["signal_wifi_4_bar"] = "rbxassetid://6035030077",
	["signal_wifi_off"] = "rbxassetid://6035030074",
	["sim_card"] = "rbxassetid://6034837800",
	["sim_card_alert"] = "rbxassetid://6034452641",
	["single_bed"] = "rbxassetid://6034230651",
	["skip_next"] = "rbxassetid://6026667005",
	["skip_previous"] = "rbxassetid://6026667011",
	["slideshow"] = "rbxassetid://6031754546",
	["slow_motion_video"] = "rbxassetid://6026681583",
	["smart_button"] = "rbxassetid://6031265962",
	["smartphone"] = "rbxassetid://6034848731",
	["smoke_free"] = "rbxassetid://6035153647",
	["smoking_rooms"] = "rbxassetid://6035153636",
	["sms"] = "rbxassetid://6034452645",
	["sms_failed"] = "rbxassetid://6034452676",
	["snippet_folder"] = "rbxassetid://6031302947",
	["snooze"] = "rbxassetid://6026667006",
	["soap"] = "rbxassetid://6035153645",
	["sort"] = "rbxassetid://6035078888",
	["sort_by_alpha"] = "rbxassetid://6026667009",
	["source"] = "rbxassetid://6031289451",
	["south"] = "rbxassetid://6031104646",
	["south_east"] = "rbxassetid://6031104642",
	["south_west"] = "rbxassetid://6031104652",
	["spa"] = "rbxassetid://6035153639",
	["space_bar"] = "rbxassetid://6034934037",
	["speaker"] = "rbxassetid://6034848746",
	["speaker_group"] = "rbxassetid://6034848732",
	["speaker_notes"] = "rbxassetid://6031266001",
	["speaker_notes_off"] = "rbxassetid://6031265965",
	["speaker_phone"] = "rbxassetid://6035202018",
	["speed"] = "rbxassetid://6026681578",
	["spellcheck"] = "rbxassetid://6031289450",
	["sports"] = "rbxassetid://6034230647",
	["sports_bar"] = "rbxassetid://6035153638",
	["sports_baseball"] = "rbxassetid://6034230652",
	["sports_basketball"] = "rbxassetid://6034230649",
	["sports_cricket"] = "rbxassetid://6034230660",
	["sports_esports"] = "rbxassetid://6034227061",
	["sports_football"] = "rbxassetid://6034227067",
	["sports_golf"] = "rbxassetid://6034227060",
	["sports_handball"] = "rbxassetid://6034227074",
	["sports_hockey"] = "rbxassetid://6034227064",
	["sports_kabaddi"] = "rbxassetid://6034227141",
	["sports_mma"] = "rbxassetid://6034227072",
	["sports_motorsports"] = "rbxassetid://6034227071",
	["sports_rugby"] = "rbxassetid://6034227073",
	["sports_soccer"] = "rbxassetid://6034227075",
	["sports_tennis"] = "rbxassetid://6034227068",
	["sports_volleyball"] = "rbxassetid://6034227139",
	["square_foot"] = "rbxassetid://6035078918",
	["stacked_bar_chart"] = "rbxassetid://6035078892",
	["stacked_line_chart"] = "rbxassetid://6034934039",
	["stairs"] = "rbxassetid://6035153637",
	["star"] = "rbxassetid://6031068423",
	["star_border"] = "rbxassetid://6031068425",
	["star_half"] = "rbxassetid://6031068427",
	["star_outline"] = "rbxassetid://6031068428",
	["star_rate"] = "rbxassetid://6031265978",
	["stars"] = "rbxassetid://6031265971",
	["stay_current_landscape"] = "rbxassetid://6035202011",
	["stay_current_portrait"] = "rbxassetid://6035202004",
	["stay_primary_landscape"] = "rbxassetid://6035202026",
	["stay_primary_portrait"] = "rbxassetid://6035202009",
	["sticky_note_2"] = "rbxassetid://6031265972",
	["stop"] = "rbxassetid://6026681576",
	["stop_circle"] = "rbxassetid://6026681577",
	["stop_screen_share"] = "rbxassetid://6035202042",
	["storage"] = "rbxassetid://6035030083",
	["store"] = "rbxassetid://6031265968",
	["store_mall_directory"] = "rbxassetid://6034470811",
	["storefront"] = "rbxassetid://6035161534",
	["straighten"] = "rbxassetid://6031754545",
	["stream"] = "rbxassetid://6035078897",
	["streetview"] = "rbxassetid://6034470805",
	["strikethrough_s"] = "rbxassetid://6034934030",
	["stroller"] = "rbxassetid://6035161535",
	["style"] = "rbxassetid://6031754538",
	["subdirectory_arrow_left"] = "rbxassetid://6031104654",
	["subdirectory_arrow_right"] = "rbxassetid://6031104647",
	["subject"] = "rbxassetid://6031289452",
	["subscript"] = "rbxassetid://6034934059",
	["subscriptions"] = "rbxassetid://6026671207",
	["subtitles"] = "rbxassetid://6026671203",
	["subtitles_off"] = "rbxassetid://6031289466",
	["subway"] = "rbxassetid://6034467790",
	["superscript"] = "rbxassetid://6034934034",
	["supervised_user_circle"] = "rbxassetid://6031289449",
	["supervisor_account"] = "rbxassetid://6031251516",
	["support"] = "rbxassetid://6031251532",
	["support_agent"] = "rbxassetid://6034452656",
	["surround_sound"] = "rbxassetid://6026671209",
	["swap_calls"] = "rbxassetid://6035202037",
	["swap_horiz"] = "rbxassetid://6031233841",
	["swap_horizontal_circle"] = "rbxassetid://6031233833",
	["swap_vert"] = "rbxassetid://6031233847",
	["swap_vertical_circle"] = "rbxassetid://6031233839",
	["swipe"] = "rbxassetid://6031233863",
	["switch_account"] = "rbxassetid://6034227138",
	["switch_camera"] = "rbxassetid://6031754550",
	["switch_left"] = "rbxassetid://6031104651",
	["switch_right"] = "rbxassetid://6031104649",
	["switch_video"] = "rbxassetid://6031754536",
	["sync"] = "rbxassetid://6034452662",
	["sync_alt"] = "rbxassetid://6031233840",
	["sync_disabled"] = "rbxassetid://6034452649",
	["sync_problem"] = "rbxassetid://6034452653",
	["system_update"] = "rbxassetid://6034452663",
	["system_update_alt"] = "rbxassetid://6031251515",
	["tab"] = "rbxassetid://6031233851",
	["tab_unselected"] = "rbxassetid://6031251505",
	["table_chart"] = "rbxassetid://6034973081",
	["table_rows"] = "rbxassetid://6034934025",
	["table_view"] = "rbxassetid://6031233835",
	["tablet"] = "rbxassetid://6034848733",
	["tablet_android"] = "rbxassetid://6034848734",
	["tag"] = "rbxassetid://6035078895",
	["tag_faces"] = "rbxassetid://6031754560",
	["takeout_dining"] = "rbxassetid://6034467808",
	["tap_and_play"] = "rbxassetid://6034452650",
	["tapas"] = "rbxassetid://6035161533",
	["taxi_alert"] = "rbxassetid://6034467792",
	["terrain"] = "rbxassetid://6034467794",
	["text_fields"] = "rbxassetid://6034934040",
	["text_format"] = "rbxassetid://6035078890",
	["text_rotate_up"] = "rbxassetid://6031251526",
	["text_rotate_vertical"] = "rbxassetid://6031251518",
	["text_rotation_angledown"] = "rbxassetid://6031251513",
	["text_rotation_angleup"] = "rbxassetid://6031229337",
	["text_rotation_down"] = "rbxassetid://6031229334",
	["text_rotation_none"] = "rbxassetid://6031229344",
	["text_snippet"] = "rbxassetid://6031302995",
	["textsms"] = "rbxassetid://6035202006",
	["texture"] = "rbxassetid://6031754553",
	["theater_comedy"] = "rbxassetid://6034467796",
	["theaters"] = "rbxassetid://6031229335",
	["thumb_down"] = "rbxassetid://6031229336",
	["thumb_down_alt"] = "rbxassetid://6034227069",
	["thumb_down_off_alt"] = "rbxassetid://6031229354",
	["thumb_up"] = "rbxassetid://6031229347",
	["thumb_up_alt"] = "rbxassetid://6034227076",
	["thumb_up_off_alt"] = "rbxassetid://6031229342",
	["thumbs_up_down"] = "rbxassetid://6031229373",
	["time_to_leave"] = "rbxassetid://6034452660",
	["timelapse"] = "rbxassetid://6031754541",
	["timeline"] = "rbxassetid://6031229350",
	["timer"] = "rbxassetid://6031754564",
	["timer_10"] = "rbxassetid://6031734880",
	["timer_3"] = "rbxassetid://6031754540",
	["timer_off"] = "rbxassetid://6031734881",
	["title"] = "rbxassetid://6034934042",
	["toc"] = "rbxassetid://6031229341",
	["today"] = "rbxassetid://6031229352",
	["toggle_off"] = "rbxassetid://6031068429",
	["toggle_on"] = "rbxassetid://6031068430",
	["toll"] = "rbxassetid://6031229343",
	["tonality"] = "rbxassetid://6031734891",
	["topic"] = "rbxassetid://6031302976",
	["touch_app"] = "rbxassetid://6031229361",
	["tour"] = "rbxassetid://6031229362",
	["toys"] = "rbxassetid://6034848752",
	["track_changes"] = "rbxassetid://6031225814",
	["traffic"] = "rbxassetid://6034467797",
	["train"] = "rbxassetid://6034467803",
	["tram"] = "rbxassetid://6034467806",
	["transfer_within_a_station"] = "rbxassetid://6034467809",
	["transform"] = "rbxassetid://6031734873",
	["transit_enterexit"] = "rbxassetid://6034467805",
	["translate"] = "rbxassetid://6031225812",
	["trending_down"] = "rbxassetid://6031225811",
	["trending_flat"] = "rbxassetid://6031225818",
	["trending_up"] = "rbxassetid://6031225816",
	["trip_origin"] = "rbxassetid://6034467804",
	["tty"] = "rbxassetid://6035161541",
	["tune"] = "rbxassetid://6031734877",
	["turned_in"] = "rbxassetid://6031225808",
	["turned_in_not"] = "rbxassetid://6031225806",
	["tv"] = "rbxassetid://6034848740",
	["tv_off"] = "rbxassetid://6034452646",
	["two_wheeler"] = "rbxassetid://6034467795",
	["umbrella"] = "rbxassetid://6035161550",
	["unarchive"] = "rbxassetid://6035078921",
	["undo"] = "rbxassetid://6035078896",
	["unfold_less"] = "rbxassetid://6031104681",
	["unfold_more"] = "rbxassetid://6031104644",
	["unpublished"] = "rbxassetid://6031225817",
	["unsubscribe"] = "rbxassetid://6035202044",
	["update"] = "rbxassetid://6031225810",
	["upgrade"] = "rbxassetid://6031225815",
	["upload_file"] = "rbxassetid://6031302959",
	["usb"] = "rbxassetid://6035030080",
	["verified"] = "rbxassetid://6031225809",
	["verified_user"] = "rbxassetid://6031225819",
	["vertical_align_bottom"] = "rbxassetid://6034934023",
	["vertical_align_center"] = "rbxassetid://6034934051",
	["vertical_align_top"] = "rbxassetid://6034973080",
	["vertical_split"] = "rbxassetid://6031225820",
	["vibration"] = "rbxassetid://6034452651",
	["video_label"] = "rbxassetid://6026671204",
	["video_library"] = "rbxassetid://6026671208",
	["video_settings"] = "rbxassetid://6026671211",
	["videocam"] = "rbxassetid://6026671213",
	["videocam_off"] = "rbxassetid://6026671212",
	["videogame_asset"] = "rbxassetid://6034848748",
	["view_agenda"] = "rbxassetid://6031225831",
	["view_array"] = "rbxassetid://6031225842",
	["view_carousel"] = "rbxassetid://6031251507",
	["view_column"] = "rbxassetid://6031079172",
	["view_comfy"] = "rbxassetid://6031734876",
	["view_compact"] = "rbxassetid://6031734878",
	["view_day"] = "rbxassetid://6031079153",
	["view_headline"] = "rbxassetid://6031079151",
	["view_in_ar"] = "rbxassetid://6031079158",
	["view_list"] = "rbxassetid://6031079156",
	["view_module"] = "rbxassetid://6031079152",
	["view_quilt"] = "rbxassetid://6031079155",
	["view_sidebar"] = "rbxassetid://6031079160",
	["view_stream"] = "rbxassetid://6031079164",
	["view_week"] = "rbxassetid://6031079154",
	["vignette"] = "rbxassetid://6031734905",
	["visibility"] = "rbxassetid://6031075931",
	["visibility_off"] = "rbxassetid://6031075929",
	["voice_over_off"] = "rbxassetid://6031075927",
	["voicemail"] = "rbxassetid://6035202019",
	["volume_down"] = "rbxassetid://6026671206",
	["volume_mute"] = "rbxassetid://6026671214",
	["volume_off"] = "rbxassetid://6026671224",
	["volume_up"] = "rbxassetid://6026671215",
	["volunteer_activism"] = "rbxassetid://6034467799",
	["vpn_key"] = "rbxassetid://6035202034",
	["vpn_lock"] = "rbxassetid://6034452648",
	["wallpaper"] = "rbxassetid://6035030102",
	["wash"] = "rbxassetid://6035161540",
	["watch"] = "rbxassetid://6034848747",
	["watch_later"] = "rbxassetid://6031075924",
	["water_damage"] = "rbxassetid://6035161563",
	["waterfall_chart"] = "rbxassetid://6031104632",
	["waves"] = "rbxassetid://6035078898",
	["wb_auto"] = "rbxassetid://6031734875",
	["wb_cloudy"] = "rbxassetid://6031734907",
	["wb_incandescent"] = "rbxassetid://6034316010",
	["wb_iridescent"] = "rbxassetid://6034315972",
	["wb_shade"] = "rbxassetid://6034315974",
	["wb_sunny"] = "rbxassetid://6034412758",
	["wb_twighlight"] = "rbxassetid://6034412760",
	["wc"] = "rbxassetid://6034452643",
	["web"] = "rbxassetid://6026671234",
	["web_asset"] = "rbxassetid://6026671239",
	["weekend"] = "rbxassetid://6035078894",
	["west"] = "rbxassetid://6031104677",
	["whatshot"] = "rbxassetid://6034287525",
	["wheelchair_pickup"] = "rbxassetid://6035161536",
	["where_to_vote"] = "rbxassetid://6035078913",
	["widgets"] = "rbxassetid://6035039429",
	["wifi"] = "rbxassetid://6034461626",
	["wifi_calling"] = "rbxassetid://6035202065",
	["wifi_lock"] = "rbxassetid://6035039428",
	["wifi_off"] = "rbxassetid://6034461625",
	["wifi_protected_setup"] = "rbxassetid://6031075926",
	["wifi_tethering"] = "rbxassetid://6035039430",
	["work"] = "rbxassetid://6031075939",
	["work_off"] = "rbxassetid://6031075937",
	["work_outline"] = "rbxassetid://6031075930",
	["workspaces_filled"] = "rbxassetid://6031302961",
	["workspaces_outline"] = "rbxassetid://6031302952",
	["wrap_text"] = "rbxassetid://6034973118",
	["wrong_location"] = "rbxassetid://6034467801",
	["wysiwyg"] = "rbxassetid://6031075938",
	["youtube_searched_for"] = "rbxassetid://6031075934",
	["zoom_in"] = "rbxassetid://6031075573",
	["zoom_out"] = "rbxassetid://6031075577",
	["zoom_out_map"] = "rbxassetid://6035229856",
}

local Icons = setmetatable({}, {
	__index = function(_, key)
		if TextIcons[key] then return TextIcons[key] end
		if IconAssets[key] then return TextIcons.circle end
		return TextIcons.circle
	end
})
Icons.dot = TextIcons.dot
Icons.check = TextIcons.check
Icons.x = TextIcons.x
Icons.circle = TextIcons.circle
Icons.ring = TextIcons.ring
Icons.sparkle = TextIcons.sparkle
Icons.star = TextIcons.star
Icons.heart = TextIcons.heart
Icons.expand = TextIcons.expand
Icons.collapse = TextIcons.collapse
Icons.play = TextIcons.play
Icons.arrow_r = TextIcons.arrow_r
Icons.arrow_l = TextIcons.arrow_l

local function getIconAsset(name)
	return IconAssets[name]
end

local function getIcon(name)
	return TextIcons[name] or TextIcons.circle
end

local function createIconImage(parent, iconName, size, color, zIdx)
	local assetId = IconAssets[iconName]
	if not assetId then
		local fallback = Instance.new("TextLabel")
		noHit(fallback)
		fallback.BackgroundTransparency = 1
		fallback.Size = UDim2.new(0, size or 16, 0, size or 16)
		fallback.Font = Enum.Font.GothamBold
		fallback.TextSize = (size or 16) - 2
		fallback.Text = TextIcons[iconName] or TextIcons.circle
		fallback.TextColor3 = color or Color3.new(1, 1, 1)
		fallback.ZIndex = zIdx or 10
		fallback.Parent = parent
		return fallback
	end
	local img = Instance.new("ImageLabel")
	noHit(img)
	img.BackgroundTransparency = 1
	img.Size = UDim2.new(0, size or 16, 0, size or 16)
	img.Image = assetId
	img.ImageColor3 = color or Color3.new(1, 1, 1)
	img.ScaleType = Enum.ScaleType.Fit
	img.ZIndex = zIdx or 10
	img.Parent = parent
	return img
end

local function setIconImage(imageLabel, iconName, color)
	local assetId = IconAssets[iconName]
	if assetId and imageLabel then
		imageLabel.Image = assetId
		if color then imageLabel.ImageColor3 = color end
	end
end

local SND_ON = true
local Sounds = {
	click = "rbxassetid://876939830",
	toggle = "rbxassetid://876939830",
	hover = "rbxassetid://876939830",
	whoosh = "rbxassetid://876939830",
	ding = "rbxassetid://876939830",
	slide = "rbxassetid://876939830",
	pop = "rbxassetid://876939830",
	expand = "rbxassetid://876939830",
	collapse = "rbxassetid://876939830",
	typing = "rbxassetid://876939830",
	sel = "rbxassetid://876939830",
	success = "rbxassetid://876939830",
	err = "rbxassetid://876939830",
	notif = "rbxassetid://876939830",
}

local SoundProfiles = {
	click = {vol = 0.12, pitch = 1.0},
	toggle = {vol = 0.10, pitch = 1.15},
	hover = {vol = 0.04, pitch = 1.5},
	whoosh = {vol = 0.08, pitch = 0.7},
	ding = {vol = 0.12, pitch = 1.3},
	slide = {vol = 0.03, pitch = 1.2},
	pop = {vol = 0.10, pitch = 1.4},
	expand = {vol = 0.08, pitch = 0.85},
	collapse = {vol = 0.08, pitch = 0.75},
	typing = {vol = 0.03, pitch = 1.6},
	sel = {vol = 0.10, pitch = 1.1},
	success = {vol = 0.12, pitch = 1.5},
	err = {vol = 0.10, pitch = 0.6},
	notif = {vol = 0.15, pitch = 1.25},
}

local SoundPacks = {
	Default = {style = "normal"},
	Quiet = {style = "quiet"},
	Clicky = {style = "clicky"},
	Silent = {style = "silent"},
}

local activeSoundPack = "Default"
local soundPackMultipliers = {
	normal = {vol = 1.0, pitchRange = 0.0},
	quiet = {vol = 0.4, pitchRange = 0.0},
	clicky = {vol = 1.2, pitchRange = 0.05},
	silent = {vol = 0.0, pitchRange = 0.0},
}

local function setSoundPack(name)
	if SoundPacks[name] then activeSoundPack = name end
end

local _soundIdToName = {}
for k, v in pairs(Sounds) do _soundIdToName[v] = _soundIdToName[v] or k end

local _soundCache = {}
local _soundCacheSize = 0
local MAX_SOUND_CACHE = 6

local function playSound(id, vol, pitch)
	if not SND_ON then return end
	local packStyle = (SoundPacks[activeSoundPack] or {}).style or "normal"
	local mult = soundPackMultipliers[packStyle] or soundPackMultipliers.normal
	if mult.vol == 0 then return end
	local sndName = _soundIdToName[id]
	local prof = sndName and SoundProfiles[sndName]
	local finalVol = (vol or (prof and prof.vol) or 0.12) * mult.vol
	local finalPitch = (pitch or (prof and prof.pitch) or 1.0) + (math.random() - 0.5) * mult.pitchRange * 2
	pcall(function()
		local sndId = id or Sounds.click
		local s = _soundCache[sndId]
		if not s or not s.Parent then
			s = Instance.new("Sound")
			s.SoundId = sndId
			s.Parent = SoundService
			if _soundCacheSize < MAX_SOUND_CACHE then
				_soundCache[sndId] = s
				_soundCacheSize = _soundCacheSize + 1
			else
				Debris:AddItem(s, 3)
			end
		end
		s.Volume = finalVol
		s.PlaybackSpeed = finalPitch
		s:Play()
	end)
end

local function addClayShadow(parent, cr)
	local shadow = Instance.new("ImageLabel")
	noHit(shadow)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0.5, 3, 0.5, 3)
	shadow.Size = UDim2.new(1, 12, 1, 12)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = C.ClayShadow
	shadow.ImageTransparency = 0.35
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Parent = parent

	local shadow2 = Instance.new("ImageLabel")
	noHit(shadow2)
	shadow2.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow2.BackgroundTransparency = 1
	shadow2.Position = UDim2.new(0.5, 5, 0.5, 6)
	shadow2.Size = UDim2.new(1, 28, 1, 28)
	shadow2.ZIndex = parent.ZIndex - 2
	shadow2.Image = "rbxassetid://6014261993"
	shadow2.ImageColor3 = C.ClayShadowDeep
	shadow2.ImageTransparency = 0.55
	shadow2.ScaleType = Enum.ScaleType.Slice
	shadow2.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow2.Parent = parent

	return shadow
end

local function addClayHighlight(parent)
	local highlight = Instance.new("Frame")
	noHit(highlight)
	highlight.BackgroundColor3 = C.ClayHighlight
	highlight.BackgroundTransparency = 0.82
	highlight.Size = UDim2.new(1, 0, 0, 1)
	highlight.Position = UDim2.new(0, 0, 0, 0)
	highlight.ZIndex = parent.ZIndex + 1
	highlight.Parent = parent
	corner(highlight, 16)
	local hGrad = Instance.new("UIGradient")
	hGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	hGrad.Parent = highlight
	return highlight
end

local function createRipple(parent, color)
	if not ANIM_ENABLED then return end
	local r = Instance.new("Frame")
	r.BackgroundColor3 = color or C.Accent
	r.BackgroundTransparency = 0.55
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Position = UDim2.new(0.5, 0, 0.5, 0)
	r.Size = UDim2.new(0, 0, 0, 0)
	r.ZIndex = 9
	r.Parent = parent
	corner(r, 999)
	local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
	tw(r, 0.65, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, Enum.EasingStyle.Quart)
	task.delay(0.7, function()
		if r and r.Parent then r:Destroy() end
	end)
end

local function makeDrag(frame, handle)
	local dragging = false
	local dragStart = nil
	local frameStart = nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			frameStart = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				frameStart.X.Scale, frameStart.X.Offset + delta.X,
				frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
			)
		end
	end)
end

local function springAnimate(obj, prop, target, stiffness, damping, mass)
	if not obj or not obj.Parent then return end
	if not ANIM_ENABLED then
		pcall(function() obj[prop] = target end)
		return
	end
	local sp = Spring.new(stiffness or 280, damping or 22, mass or 1)
	local startVal = obj[prop]
	sp.Pos = 0
	sp.Target = 1
	poolAdd(function(dt)
		if not obj or not obj.Parent then return false end
		local t = sp:Update(dt)
		if typeof(startVal) == "UDim2" then
			obj[prop] = UDim2.new(
				lerp(startVal.X.Scale, target.X.Scale, t),
				lerp(startVal.X.Offset, target.X.Offset, t),
				lerp(startVal.Y.Scale, target.Y.Scale, t),
				lerp(startVal.Y.Offset, target.Y.Offset, t)
			)
		elseif typeof(startVal) == "number" then
			obj[prop] = lerp(startVal, target, t)
		elseif typeof(startVal) == "Color3" then
			obj[prop] = lerpColor(startVal, target, t)
		end
		if sp:Done(0.002) then
			pcall(function() obj[prop] = target end)
			return false
		end
		return true
	end)
end

local function springBounce(obj, prop, target, overshoot)
	if not obj or not obj.Parent then return end
	if not ANIM_ENABLED then
		pcall(function() obj[prop] = target end)
		return
	end
	local sp = Spring.new(350, 18, 0.7)
	local startVal = obj[prop]
	sp.Pos = 0
	sp.Target = 1
	sp:Impulse(overshoot or 8)
	poolAdd(function(dt)
		if not obj or not obj.Parent then return false end
		local t = sp:Update(dt)
		if typeof(startVal) == "UDim2" then
			obj[prop] = UDim2.new(
				lerp(startVal.X.Scale, target.X.Scale, t),
				lerp(startVal.X.Offset, target.X.Offset, t),
				lerp(startVal.Y.Scale, target.Y.Scale, t),
				lerp(startVal.Y.Offset, target.Y.Offset, t)
			)
		elseif typeof(startVal) == "number" then
			obj[prop] = lerp(startVal, target, t)
		end
		if sp:Done(0.002) then
			pcall(function() obj[prop] = target end)
			return false
		end
		return true
	end)
end

local function addHoverLift(frame, liftPx)
	if IS_MOBILE or not ANIM_ENABLED then return end
	liftPx = liftPx or 3
	local origPos = nil
	local lifting = false
	frame.MouseEnter:Connect(function()
		if lifting then return end
		lifting = true
		origPos = origPos or frame.Position
		springAnimate(frame, "Position", UDim2.new(
			origPos.X.Scale, origPos.X.Offset,
			origPos.Y.Scale, origPos.Y.Offset - liftPx
			), 300, 20, 0.8)
		playSound(Sounds.hover, 0.04, 1.35)
	end)
	frame.MouseLeave:Connect(function()
		lifting = false
		if origPos then
			springAnimate(frame, "Position", origPos, 260, 22, 1)
		end
	end)
end

local function addMagneticHover(frame, strength)
	if IS_MOBILE or not ANIM_ENABLED then return end
	strength = strength or 4
	local origPos = nil
	local tracking = false
	local _magPoolId = nil
	frame.MouseEnter:Connect(function()
		if not ANIM_ENABLED then return end
		tracking = true
		origPos = origPos or frame.Position
		if not _magPoolId then
			_magPoolId = poolAdd(function(dt)
				if not frame or not frame.Parent then _magPoolId = nil return false end
				if not tracking then _magPoolId = nil return false end
				if origPos then
					local mPos = UserInputService:GetMouseLocation()
					local absPos = frame.AbsolutePosition
					local absSize = frame.AbsoluteSize
					local centerX = absPos.X + absSize.X / 2
					local centerY = absPos.Y + absSize.Y / 2
					local dx = (mPos.X - centerX) / absSize.X * strength
					local dy = (mPos.Y - centerY) / absSize.Y * strength
					frame.Position = UDim2.new(
						origPos.X.Scale, origPos.X.Offset + dx,
						origPos.Y.Scale, origPos.Y.Offset + dy
					)
				end
				return true
			end)
		end
	end)
	frame.MouseLeave:Connect(function()
		tracking = false
		if origPos and frame and frame.Parent then
			springAnimate(frame, "Position", origPos, 320, 22, 0.8)
		end
	end)
end

local function staggerIn(container)
	if not ANIM_ENABLED then return end
	local children = {}
	for _, ch in ipairs(container:GetChildren()) do
		if ch:IsA("GuiObject") and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") and not ch:IsA("UIGridLayout") then
			children[#children + 1] = ch
		end
	end
	for i, ch in ipairs(children) do
		local orig = ch.Position
		ch.Position = UDim2.new(orig.X.Scale, orig.X.Offset + 22, orig.Y.Scale, orig.Y.Offset + 18)
		local origTr = ch.BackgroundTransparency
		if ch:IsA("Frame") or ch:IsA("TextButton") or ch:IsA("ScrollingFrame") then
			ch.BackgroundTransparency = math.min(origTr + 0.6, 1)
		end
		task.delay(i * 0.05, function()
			if not ch or not ch.Parent then return end
			springAnimate(ch, "Position", orig, 240, 20, 0.85)
			if ch:IsA("Frame") or ch:IsA("TextButton") or ch:IsA("ScrollingFrame") then
				tw(ch, 0.5, {BackgroundTransparency = origTr}, Enum.EasingStyle.Quart)
			end
		end)
	end
end

local function createOrb(parent, size, color, posX, posY, zindex, transparency)
	local orb = Instance.new("Frame")
	noHit(orb)
	orb.AnchorPoint = Vector2.new(0.5, 0.5)
	orb.BackgroundColor3 = color
	orb.BackgroundTransparency = transparency or 0.55
	orb.Position = UDim2.new(posX, 0, posY, 0)
	orb.Size = UDim2.new(0, size, 0, size)
	orb.ZIndex = zindex or 1
	orb.Parent = parent
	corner(orb, math.floor(size / 2))

	local glow1 = Instance.new("Frame")
	noHit(glow1)
	glow1.AnchorPoint = Vector2.new(0.5, 0.5)
	glow1.BackgroundColor3 = color
	glow1.BackgroundTransparency = (transparency or 0.55) + 0.15
	glow1.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow1.Size = UDim2.new(1, math.floor(size * 0.5), 1, math.floor(size * 0.5))
	glow1.ZIndex = (zindex or 1) - 1
	glow1.Parent = orb
	corner(glow1, math.floor(size * 0.75))

	local glow2 = Instance.new("Frame")
	noHit(glow2)
	glow2.AnchorPoint = Vector2.new(0.5, 0.5)
	glow2.BackgroundColor3 = color
	glow2.BackgroundTransparency = (transparency or 0.55) + 0.25
	glow2.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow2.Size = UDim2.new(1, math.floor(size * 1.0), 1, math.floor(size * 1.0))
	glow2.ZIndex = (zindex or 1) - 1
	glow2.Parent = orb
	corner(glow2, math.floor(size))

	return orb
end

local function addShimmer(parent, color, rad)
	if not ANIM_ENABLED then return nil end
	rad = rad or 18
	parent.ClipsDescendants = true

	-- The highlight fills the header with the SAME rounded corners as the card and
	-- extends past the bottom (which the header's clip trims to a straight edge), so
	-- its shape matches the card exactly: rounded top corners, straight sides. The
	-- sweep is a bright band slid across via UIGradient.Offset. ClipsDescendants
	-- ignores UICorner, so a moving hard-edged bar showed square nubs at the corners
	-- (and simply insetting it left an ugly hard cut) — a gradient inside a
	-- corner-matched frame has no hard edge to square off.
	local shimmer = Instance.new("Frame")
	noHit(shimmer)
	shimmer.BackgroundColor3 = color or C.Accent
	shimmer.Size = UDim2.new(1, 0, 1, rad)
	shimmer.Position = UDim2.new(0, 0, 0, 0)
	shimmer.ZIndex = parent.ZIndex + 1
	shimmer.Parent = parent
	corner(shimmer, rad)

	local sg = Instance.new("UIGradient")
	sg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.34, 1),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(0.66, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	sg.Offset = Vector2.new(-0.9, 0)
	sg.Parent = shimmer

	local function doShimmer()
		if not ANIM_ENABLED then return end
		sg.Offset = Vector2.new(-0.9, 0)
		tw(sg, 2.6, {Offset = Vector2.new(0.9, 0)}, Enum.EasingStyle.Sine)
	end
	doShimmer()
	local _shimmerTimer = 0
	poolAdd(function(dt)
		if not shimmer or not shimmer.Parent then return false end
		if not ANIM_ENABLED then return true end
		_shimmerTimer = _shimmerTimer + dt
		if _shimmerTimer >= 4.5 + math.random() * 3 then
			_shimmerTimer = 0
			doShimmer()
		end
		return true
	end)
	return shimmer
end

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(hubName, configFolder)
	local userId = tostring(Players.LocalPlayer.UserId)
	local self = setmetatable({
		HubName = hubName or "ExpensiveHub",
		Folder = configFolder or (hubName or "ExpensiveHub") .. "_configs",
		Profiles = {Default = {}},
		Active = "Default",
		Flags = {},
		_userId = userId,
		_boundProfile = nil,
		_autoSaveConn = nil,
		_loaded = false,
	}, ConfigManager)
	self:_ensureFolder(self.Folder)
	return self
end

function ConfigManager:_ensureFolder(path)
	pcall(function()
		if makefolder then
			if isfolder then
				if not isfolder(path) then makefolder(path) end
			else
				pcall(makefolder, path)
			end
		end
	end)
end

function ConfigManager:_userFolder()
	self:_ensureFolder(self.Folder)
	local uf = self.Folder .. "/" .. self._userId
	self:_ensureFolder(uf)
	return uf
end

function ConfigManager:_profileFile(profileName)
	return self:_userFolder() .. "/" .. (profileName or self.Active) .. ".json"
end

function ConfigManager:_metaFile()
	return self:_userFolder() .. "/_meta.json"
end

function ConfigManager:BindProfile(profileName)
	self._boundProfile = profileName or self.Active
	self:Save(self._boundProfile)
	pcall(function()
		if writefile then
			writefile(self:_metaFile(), HttpService:JSONEncode({boundProfile = self._boundProfile}))
		end
	end)
	self.Active = self._boundProfile
end

function ConfigManager:UnbindProfile()
	self._boundProfile = nil
	pcall(function()
		local path = self:_metaFile()
		if delfile and isfile and isfile(path) then
			delfile(path)
		elseif writefile then
			writefile(path, HttpService:JSONEncode({}))
		end
	end)
	return true
end

function ConfigManager:GetBoundProfile()
	if self._boundProfile then return self._boundProfile end
	pcall(function()
		if readfile and isfile and isfile(self:_metaFile()) then
			local s, data = pcall(HttpService.JSONDecode, HttpService, readfile(self:_metaFile()))
			if s and data and data.boundProfile then
				self._boundProfile = data.boundProfile
			end
		end
	end)
	return self._boundProfile
end

function ConfigManager:CreateProfile(name)
	if not name or name == "" then return false end
	self.Profiles[name] = self:CollectAll()
	self:Save(name)
	return true
end

function ConfigManager:DeleteProfile(name)
	if name == "Default" then return false end
	self.Profiles[name] = nil
	pcall(function()
		local path = self:_profileFile(name)
		if delfile and isfile and isfile(path) then delfile(path) end
	end)
	if self.Active == name then self.Active = "Default" end
	if self._boundProfile == name then self._boundProfile = nil end
	return true
end

function ConfigManager:SetProfile(n)
	if not n or n == "" then return false end
	if self:SaveExists(n) then
		return self:Load(n) -- Load fires callbacks on success
	else
		if not self.Profiles[n] then self.Profiles[n] = self:CollectAll() end
		self.Active = n
		self:Save(n)
		return true
	end
end

function ConfigManager:ListProfiles()
	local r = {}
	local seen = {}
	for k in pairs(self.Profiles) do r[#r+1] = k; seen[k] = true end
	for _, s in ipairs(self:ListSaves()) do
		if not seen[s] then r[#r+1] = s; seen[s] = true end
	end
	table.sort(r)
	return r
end

function ConfigManager:Set(f, v)
	if not self.Profiles[self.Active] then self.Profiles[self.Active] = {} end
	self.Profiles[self.Active][f] = v
end

function ConfigManager:Get(f)
	return self.Profiles[self.Active] and self.Profiles[self.Active][f]
end

function ConfigManager:Register(f, a)
	self.Flags[f] = a
end

function ConfigManager:CollectAll()
	local data = {}
	for f, a in pairs(self.Flags) do
		if a.Get then
			local ok2, val = pcall(a.Get, a)
			if ok2 then
				if typeof(val) == "Color3" then
					data[f] = {R = math.floor(val.R*255), G = math.floor(val.G*255), B = math.floor(val.B*255)}
				elseif typeof(val) == "EnumItem" then
					data[f] = val.Name
				else
					data[f] = val
				end
			end
		end
	end
	return data
end

function ConfigManager:ApplyData(data)
	if type(data) ~= "table" then return false end
	for f, a in pairs(self.Flags) do
		if data[f] ~= nil and a.Set then
			pcall(a.Set, a, data[f], true)
		end
	end
	return true
end

function ConfigManager:FireAllCallbacks()
	for f, a in pairs(self.Flags) do
		if a.Get and a._cb then
			local ok2, val = pcall(a.Get, a)
			if ok2 then pcall(a._cb, val) end
		end
	end
end

function ConfigManager:Save(name)
	name = name or self.Active
	local data = self:CollectAll()
	self.Profiles[name] = data
	local ok = false
	local path = self:_profileFile(name)
	pcall(function()
		if not writefile then return end
		writefile(path, HttpService:JSONEncode(data))
		ok = true
	end)
	return ok, path
end

function ConfigManager:SaveEnhanced(name)
	return self:Save(name)
end

function ConfigManager:Load(name)
	name = name or self.Active
	local ok = false
	pcall(function()
		local path = self:_profileFile(name)
		if readfile and isfile and isfile(path) then
			local s, data = pcall(HttpService.JSONDecode, HttpService, readfile(path))
			if s and type(data) == "table" then
				self.Profiles[name] = data
				self.Active = name
				self:ApplyData(data)
				ok = true
			end
		end
	end)
	-- ApplyData sets values silently (noCallback); fire callbacks once so the
	-- feature logic matches the loaded state (otherwise: visual on, logic off).
	if ok then task.defer(function() self:FireAllCallbacks() end) end
	return ok
end

function ConfigManager:LoadEnhanced(name)
	return self:Load(name) -- Load already fires callbacks
end

function ConfigManager:AutoLoad()
	local bound = self:GetBoundProfile()
	local target = bound or "Default"
	local ok = self:Load(target)
	if not ok and target ~= "Default" then
		ok = self:Load("Default")
	end
	self._loaded = true
	-- Load() fires callbacks when it succeeds; if nothing was loaded (first run),
	-- still apply the Default-value callbacks once so defaults activate.
	if not ok then task.defer(function() self:FireAllCallbacks() end) end
	return ok
end

function ConfigManager:SaveAll()
	local results = {}
	for _, name in ipairs(self:ListProfiles()) do
		local ok2 = self:Save(name)
		results[name] = ok2
	end
	return results
end

function ConfigManager:ListSaves()
	local saves = {}
	pcall(function()
		if listfiles then
			for _, file in ipairs(listfiles(self:_userFolder())) do
				-- normalize Windows back-slashes first; listfiles returns full paths and
				-- the old pattern failed to strip "\", capturing the whole path as the name.
				local norm = file:gsub("\\", "/")
				local name = norm:match("([^/]+)%.json$")
				if name and name ~= "_meta" then saves[#saves+1] = name end
			end
		end
	end)
	table.sort(saves)
	return saves
end

function ConfigManager:Delete(name)
	return self:DeleteProfile(name)
end

function ConfigManager:Export()
	return HttpService:JSONEncode(self:CollectAll())
end

function ConfigManager:Import(json)
	local s, data = pcall(HttpService.JSONDecode, HttpService, json)
	if s and type(data) == "table" then
		self.Profiles[self.Active] = data
		self:ApplyData(data)
		task.defer(function() self:FireAllCallbacks() end)
		return true
	end
	return false
end

function ConfigManager:EnableAutoSave(interval)
	self:DisableAutoSave()
	self._autoSaveConn = task.spawn(function()
		while true do
			task.wait(interval or 30)
			pcall(function() self:Save() end)
		end
	end)
end

function ConfigManager:DisableAutoSave()
	if self._autoSaveConn then
		pcall(function() task.cancel(self._autoSaveConn) end)
		self._autoSaveConn = nil
	end
end

function ConfigManager:GetAutoSaveStatus()
	return self._autoSaveConn ~= nil
end

function ConfigManager:QuickSave()
	return self:Save(self.Active)
end

function ConfigManager:QuickLoad()
	return self:Load(self.Active)
end

function ConfigManager:SaveExists(name)
	name = name or self.Active
	local exists = false
	pcall(function()
		local fileName = self:_profileFile(name)
		if isfile then exists = isfile(fileName) end
	end)
	return exists
end

local BlurEffect = nil
local blurEnabled = false

local function createBlur()
	pcall(function()
		BlurEffect = Instance.new("BlurEffect")
		BlurEffect.Name = "EHBlur"
		BlurEffect.Size = 0
		BlurEffect.Parent = Lighting
	end)
end

local function showBlur()
	if BlurEffect then tw(BlurEffect, 0.5, {Size = 20}, Enum.EasingStyle.Quint) end
end

local function hideBlur()
	if BlurEffect then tw(BlurEffect, 0.35, {Size = 0}, Enum.EasingStyle.Quint) end
end

local function destroyBlur()
	if BlurEffect then BlurEffect:Destroy() BlurEffect = nil end
end

local Library = {}

if _G.__ExpensiveHub_Cleanup then
	pcall(_G.__ExpensiveHub_Cleanup)
end

function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local title = cfg.Title or "Animeadventures"
	local introOn = cfg.Intro ~= false
	local keybind = cfg.Keybind or Enum.KeyCode.RightControl
	SND_ON = cfg.Sounds ~= false
	SC = getScale()

	local WW = math.floor(math.clamp(960 * SC, 680, 1100))
	local WH = math.floor(math.clamp(640 * SC, 460, 750))
	local SIDEBAR_W = math.floor(58 * SC)
	local SIDEBAR_EXP = math.floor(195 * SC)
	local TOPBAR_H = math.floor(52 * SC)
	local SUBTAB_H = math.floor(42 * SC)
	local FOOTER_H = math.floor(32 * SC)

	local W = {
		Tabs = {},
		ActiveTab = nil,
		Visible = true,
		_conns = {},
		_flags = {},
		_elems = {},
		_activeFeatures = {},
		-- Names the user has opted out of the Active Features panel (via a toggle's
		-- HideFromActive option or Window:SetFeatureHiddenFromActive). The feature
		-- still works and still counts internally; it just isn't listed in the panel.
		_activeHidden = {},
		Config = ConfigManager.new(cfg.ConfigName or title:gsub("%s+", ""), cfg.ConfigFolder),
		AutoSaveEnabled = true,
	}
	-- Single source of truth: the window flag registry IS the ConfigManager registry.
	W._flags = W.Config.Flags

	local sidebarExpanded = false
	local sidebarHoverLock = false

	local function trackConn(conn)
		W._conns[#W._conns + 1] = conn
	end

	createBlur()

	pcall(function()
		local old = CoreGui:FindFirstChild("ExpensiveHub")
		if not old then old = Player:WaitForChild("PlayerGui"):FindFirstChild("ExpensiveHub") end
		if old then old:Destroy() end
	end)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ExpensiveHub"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	pcall(function() screenGui.Parent = CoreGui end)
	if not screenGui.Parent then
		screenGui.Parent = Player:WaitForChild("PlayerGui")
	end

	local uiScaleObj = Instance.new("UIScale")
	-- Mobile defaults to 80% so the window doesn't dominate small touch screens.
	uiScaleObj.Scale = IS_MOBILE and 0.8 or 1
	uiScaleObj.Parent = screenGui

	local main = Instance.new("CanvasGroup")
	main.Name = "Main"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = C.BG
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = introOn and UDim2.new(0, 0, 0, 0) or UDim2.new(0, WW, 0, WH)
	main.GroupTransparency = introOn and 1 or 0
	main.ClipsDescendants = true
	main.Parent = screenGui
	corner(main, 22)

	for i = 1, 4 do
		local sh = Instance.new("ImageLabel")
		noHit(sh)
		sh.AnchorPoint = Vector2.new(0.5, 0.5)
		sh.BackgroundTransparency = 1
		sh.Position = UDim2.new(0.5, i * 1.5, 0.5, i * 2.5)
		sh.Size = UDim2.new(1, 45 + i * 22, 1, 45 + i * 22)
		sh.ZIndex = -1
		sh.Image = "rbxassetid://6014261993"
		sh.ImageColor3 = C.ClayShadow
		sh.ImageTransparency = 0.25 + i * 0.12
		sh.ScaleType = Enum.ScaleType.Slice
		sh.SliceCenter = Rect.new(49, 49, 450, 450)
		sh.Parent = main
	end

	for i = 1, 2 do
		local hl = Instance.new("ImageLabel")
		noHit(hl)
		hl.AnchorPoint = Vector2.new(0.5, 0.5)
		hl.BackgroundTransparency = 1
		hl.Position = UDim2.new(0.5, -i * 1.5, 0.5, -i * 1.5)
		hl.Size = UDim2.new(1, 20 + i * 12, 1, 20 + i * 12)
		hl.ZIndex = -1
		hl.Image = "rbxassetid://6014261993"
		hl.ImageColor3 = C.ClayHighlight
		hl.ImageTransparency = 0.78 + i * 0.08
		hl.ScaleType = Enum.ScaleType.Slice
		hl.SliceCenter = Rect.new(49, 49, 450, 450)
		hl.Parent = main
	end

	local bgMaster = Instance.new("Frame")
	noHit(bgMaster)
	bgMaster.BackgroundColor3 = C.BG
	bgMaster.Size = UDim2.new(1, 0, 1, 0)
	bgMaster.ZIndex = 0
	bgMaster.ClipsDescendants = true
	bgMaster.Parent = main

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.GradA),
		ColorSequenceKeypoint.new(0.3, lerpColor(C.GradA, C.GradB, 0.6)),
		ColorSequenceKeypoint.new(0.6, C.GradB),
		ColorSequenceKeypoint.new(0.8, C.GradC),
		ColorSequenceKeypoint.new(1, C.GradD),
	})
	bgGradient.Rotation = 135
	bgGradient.Parent = bgMaster

	local _bgGradAccum = 0
	poolAdd(function(dt)
		if not bgGradient or not bgGradient.Parent then return false end
		if not ANIM_ENABLED then return true end
		_bgGradAccum = _bgGradAccum + dt
		if _bgGradAccum < 0.05 then return true end
		_bgGradAccum = 0
		local t = tick() * 0.03
		bgGradient.Rotation = 135 + math.sin(t) * 15
		bgGradient.Offset = Vector2.new(math.sin(t * 0.8) * 0.08, math.cos(t * 0.6) * 0.05)
		return true
	end)

	local bgPresets = {}
	local activeBG = "matrix"

	do
		local matrixContainer = Instance.new("Frame")
		noHit(matrixContainer)
		matrixContainer.BackgroundTransparency = 1
		matrixContainer.Size = UDim2.new(1, 0, 1, 0)
		matrixContainer.ZIndex = 1
		matrixContainer.ClipsDescendants = true
		matrixContainer.Visible = true
		matrixContainer.Parent = bgMaster

		local COL_COUNT = 8
		local matrixLabels = {}

		for col = 1, COL_COUNT do
			local colX = (col - 0.5) / COL_COUNT
			local speed = 18 + math.random() * 25
			local ROW_COUNT = 3 + math.random(0, 2)
			local spacing = 1.0 / ROW_COUNT

			for row = 1, ROW_COUNT do
				local lbl = Instance.new("TextLabel")
				noHit(lbl)
				lbl.BackgroundTransparency = 1
				lbl.AnchorPoint = Vector2.new(0.5, 0.5)
				local startY = -0.15 + (row - 1) * spacing + math.random() * 0.05
				lbl.Position = UDim2.new(colX, 0, startY, 0)
				lbl.Size = UDim2.new(0, 90, 0, 24)
				lbl.Font = Enum.Font.GothamBlack
				local fSize = math.floor((10 + math.random() * 6) * SC)
				lbl.TextSize = fSize
				lbl.Text = (math.random() > 0.4) and "ANGEL" or "ANGEL WARE"
				lbl.TextColor3 = C.Text
				lbl.TextTransparency = 0.88 + math.random() * 0.08
				lbl.ZIndex = 1
				lbl.Parent = matrixContainer
				matrixLabels[#matrixLabels + 1] = {
					label = lbl,
					colX = colX,
					startY = startY,
					speed = speed + math.random() * 8,
					baseTr = 0.88 + math.random() * 0.08,
				}
			end
		end

		local bigEH = Instance.new("TextLabel")
		noHit(bigEH)
		bigEH.BackgroundTransparency = 1
		bigEH.AnchorPoint = Vector2.new(0.5, 0.5)
		bigEH.Position = UDim2.new(0.5, 0, 0.5, 0)
		bigEH.Size = UDim2.new(1, 0, 0.5, 0)
		bigEH.Font = Enum.Font.GothamBlack
		bigEH.TextSize = math.floor(140 * SC)
		bigEH.Text = ""
		bigEH.TextColor3 = C.Text
		bigEH.TextTransparency = 0.96
		bigEH.ZIndex = 1
		bigEH.Parent = matrixContainer

		local _matrixAccum = 0
		poolAdd(function(dt)
			if not matrixContainer or not matrixContainer.Parent or not matrixContainer.Visible then return true end
			if not ANIM_ENABLED then return true end
			_matrixAccum = _matrixAccum + dt
			if _matrixAccum < 0.033 then return true end
			_matrixAccum = 0
			local now = tick()
			for _, item in ipairs(matrixLabels) do
				local newY = item.startY + (now * item.speed * 0.002) % 1.4
				if newY > 1.2 then newY = newY - 1.4 end
				item.label.Position = UDim2.new(item.colX, 0, newY, 0)
			end
			bigEH.TextTransparency = 0.95 + math.sin(now * 0.15) * 0.02
			return true
		end)

		bgPresets["matrix"] = matrixContainer
	end

	do
		local auroraContainer = Instance.new("Frame")
		noHit(auroraContainer)
		auroraContainer.BackgroundTransparency = 1
		auroraContainer.Size = UDim2.new(1, 0, 1, 0)
		auroraContainer.ZIndex = 1
		auroraContainer.ClipsDescendants = true
		auroraContainer.Visible = false
		auroraContainer.Parent = bgMaster

		local auroraColors = {
			{lerpColor(C.BG, C.Purple, 0.15), lerpColor(C.BG, C.Lilac, 0.2), lerpColor(C.BG, C.ElecBlue, 0.18), lerpColor(C.BG, C.SkyBlue, 0.15), lerpColor(C.BG, C.Mint, 0.12)},
			{lerpColor(C.BG, C.HotPink, 0.1), lerpColor(C.BG, C.Purple, 0.18), lerpColor(C.BG, C.Lavender, 0.15), lerpColor(C.BG, C.Peach, 0.1)},
			{lerpColor(C.BG, C.ElecBlue, 0.12), lerpColor(C.BG, C.Accent, 0.15), lerpColor(C.BG, C.SkyBlue, 0.1)},
		}

		local auroraBands = {}
		local bandConfigs = {
			{pos = {0.5, 0.3}, size = {2.0, 0.35}, rot = -8, alpha = 0.45, colors = auroraColors[1]},
			{pos = {0.45, 0.55}, size = {2.2, 0.3}, rot = 5, alpha = 0.5, colors = auroraColors[2]},
			{pos = {0.55, 0.15}, size = {1.8, 0.2}, rot = -3, alpha = 0.6, colors = auroraColors[3]},
		}

		for i, cfg in ipairs(bandConfigs) do
			local band = Instance.new("Frame")
			noHit(band)
			band.BackgroundColor3 = Color3.new(1, 1, 1)
			band.BackgroundTransparency = cfg.alpha
			band.AnchorPoint = Vector2.new(0.5, 0.5)
			band.Position = UDim2.new(cfg.pos[1], 0, cfg.pos[2], 0)
			band.Size = UDim2.new(cfg.size[1], 0, cfg.size[2], 0)
			band.Rotation = cfg.rot
			band.ZIndex = 1
			band.Parent = auroraContainer
			corner(band, 200)
			local grad = Instance.new("UIGradient")
			local keypoints = {}
			for j, c in ipairs(cfg.colors) do
				keypoints[#keypoints + 1] = ColorSequenceKeypoint.new((j - 1) / (#cfg.colors - 1), c)
			end
			grad.Color = ColorSequence.new(keypoints)
			grad.Parent = band
			auroraBands[#auroraBands + 1] = {frame = band, grad = grad, cfg = cfg}
		end

		for i = 1, 2 do
			local depth = Instance.new("Frame")
			noHit(depth)
			depth.BackgroundColor3 = Color3.fromRGB(8 + i * 2, 8 + i * 2, 14 + i * 2)
			depth.BackgroundTransparency = 0.3 + i * 0.1
			depth.AnchorPoint = Vector2.new(0.5, 0.5)
			depth.Position = UDim2.new(0.5 + (i == 1 and 0.05 or -0.1), 0, 0.4 + i * 0.15, 0)
			depth.Size = UDim2.new(1.6, 0, 0.5, 0)
			depth.Rotation = -4 + i * 8
			depth.ZIndex = 1
			depth.Parent = auroraContainer
			corner(depth, 150)
		end

		local streaks = {}
		local streakColors = {C.Purple, C.ElecBlue, C.Lilac, C.Mint, C.SkyBlue, C.HotPink}
		for i = 1, 6 do
			local streak = Instance.new("Frame")
			noHit(streak)
			streak.BackgroundColor3 = lerpColor(streakColors[i], C.BG, 0.5)
			streak.BackgroundTransparency = 0.88
			streak.AnchorPoint = Vector2.new(0.5, 0.5)
			streak.Position = UDim2.new(0.5, 0, 0.1 + (i - 1) * 0.15, 0)
			streak.Size = UDim2.new(2.5, 0, 0, math.floor((1 + math.random() * 2) * SC))
			streak.Rotation = -12 + (i - 1) * 4
			streak.ZIndex = 2
			streak.Parent = auroraContainer
			local sGrad = Instance.new("UIGradient")
			sGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0.3),
				NumberSequenceKeypoint.new(0.5, 0.1),
				NumberSequenceKeypoint.new(0.75, 0.3),
				NumberSequenceKeypoint.new(1, 1),
			})
			sGrad.Parent = streak
			streaks[#streaks + 1] = {frame = streak, grad = sGrad, baseY = 0.1 + (i-1) * 0.15, speed = 0.06 + math.random() * 0.08, phase = math.random() * math.pi * 2}
		end

		local auroraParX, auroraParY = 0, 0
		poolAdd(function(dt)
			if not auroraContainer or not auroraContainer.Parent then return false end
			if not auroraContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick() * 0.3
			local mPos = UserInputService:GetMouseLocation()
			local vpS = Camera.ViewportSize
			auroraParX = auroraParX + ((mPos.X / vpS.X - 0.5) * 0.01 - auroraParX) * math.min(dt * 2.5, 1)
			auroraParY = auroraParY + ((mPos.Y / vpS.Y - 0.5) * 0.01 - auroraParY) * math.min(dt * 2.5, 1)

			for i, b in ipairs(auroraBands) do
				b.frame.Rotation = b.cfg.rot + math.sin(t * (0.3 + i * 0.1)) * 3
				b.frame.Position = UDim2.new(
					b.cfg.pos[1] + math.sin(t * (0.2 + i * 0.05)) * 0.03 - auroraParX * (0.8 + i * 0.3),
					0,
					b.cfg.pos[2] + math.cos(t * (0.25 + i * 0.08)) * 0.02 - auroraParY * (0.6 + i * 0.2),
					0
				)
				b.frame.BackgroundTransparency = b.cfg.alpha + math.sin(t * (0.4 + i * 0.15)) * 0.05
				b.grad.Offset = Vector2.new(math.sin(t * (0.12 + i * 0.03)) * 0.15, 0)
			end
			for _, s in ipairs(streaks) do
				s.frame.Position = UDim2.new(0.5 + math.sin(t * s.speed + s.phase) * 0.02, 0, s.baseY + math.cos(t * s.speed * 0.7 + s.phase) * 0.01, 0)
				s.grad.Offset = Vector2.new(math.sin(t * 0.1 + s.phase) * 0.2, 0)
			end
			return true
		end)

		bgPresets["aurora"] = auroraContainer
	end

	do
		local gridContainer = Instance.new("Frame")
		noHit(gridContainer)
		gridContainer.BackgroundTransparency = 1
		gridContainer.Size = UDim2.new(1, 0, 1, 0)
		gridContainer.ZIndex = 1
		gridContainer.ClipsDescendants = true
		gridContainer.Visible = false
		gridContainer.Parent = bgMaster

		local gridDots = {}
		local GRID_COLS = 8
		local GRID_ROWS = 5
		local gridColors = {C.Accent, C.Purple, C.Peach, C.Lilac, C.SkyBlue, C.ElecBlue, C.Mint}

		for row = 1, GRID_ROWS do
			for col = 1, GRID_COLS do
				local px = (col - 0.5) / GRID_COLS
				local py = (row - 0.5) / GRID_ROWS
				local dotS = math.floor((2 + math.random() * 2) * SC)
				local dot = Instance.new("Frame")
				noHit(dot)
				dot.AnchorPoint = Vector2.new(0.5, 0.5)
				dot.BackgroundColor3 = gridColors[math.random(1, #gridColors)]
				dot.BackgroundTransparency = 0.88
				dot.Position = UDim2.new(px, 0, py, 0)
				dot.Size = UDim2.new(0, dotS, 0, dotS)
				dot.ZIndex = 2
				dot.Parent = gridContainer
				corner(dot, math.floor(dotS / 2))
				gridDots[#gridDots + 1] = {
					frame = dot,
					bx = px, by = py,
					speed = 0.15 + math.random() * 0.2,
					phase = math.random() * math.pi * 2,
				}
			end
		end

		for i = 1, 5 do
			local line = Instance.new("Frame")
			noHit(line)
			line.BackgroundColor3 = gridColors[math.random(1, #gridColors)]
			line.BackgroundTransparency = 0.94
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Position = UDim2.new(0.5, 0, i / 6, 0)
			line.Size = UDim2.new(1.2, 0, 0, 1)
			line.Rotation = -3 + math.random() * 6
			line.ZIndex = 1
			line.Parent = gridContainer
			local lGrad = Instance.new("UIGradient")
			lGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.3, 0.5),
				NumberSequenceKeypoint.new(0.7, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			})
			lGrad.Parent = line
		end

		local gridParX, gridParY = 0, 0
		poolAdd(function(dt)
			if not gridContainer or not gridContainer.Parent then return false end
			if not gridContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick() * 0.35
			local mPos = UserInputService:GetMouseLocation()
			local vpS = Camera.ViewportSize
			gridParX = gridParX + ((mPos.X / vpS.X - 0.5) * 0.01 - gridParX) * math.min(dt * 2.5, 1)
			gridParY = gridParY + ((mPos.Y / vpS.Y - 0.5) * 0.01 - gridParY) * math.min(dt * 2.5, 1)
			for i, d in ipairs(gridDots) do
				local px = d.bx + math.sin(t * d.speed + d.phase) * 0.008 - gridParX * (0.5 + (i % 4) * 0.15)
				local py = d.by + math.cos(t * d.speed * 0.8 + d.phase) * 0.006 - gridParY * (0.3 + (i % 3) * 0.1)
				d.frame.Position = UDim2.new(px, 0, py, 0)
				d.frame.BackgroundTransparency = 0.86 + math.sin(t * (0.6 + i * 0.1)) * 0.06
			end
			return true
		end)

		bgPresets["grid"] = gridContainer
	end

	do
		local wavesContainer = Instance.new("Frame")
		noHit(wavesContainer)
		wavesContainer.BackgroundTransparency = 1
		wavesContainer.Size = UDim2.new(1, 0, 1, 0)
		wavesContainer.ZIndex = 1
		wavesContainer.ClipsDescendants = true
		wavesContainer.Visible = false
		wavesContainer.Parent = bgMaster

		local waveFrames = {}
		local waveColors = {C.Wave1, C.Wave2, C.Wave3}
		for i = 1, 3 do
			local wave = Instance.new("Frame")
			noHit(wave)
			wave.BackgroundColor3 = waveColors[i]
			wave.BackgroundTransparency = 0.12 + i * 0.03
			wave.AnchorPoint = Vector2.new(0.5, 0)
			wave.Position = UDim2.new(0.5, 0, 0, TOPBAR_H + (i - 1) * 12)
			wave.Size = UDim2.new(1.3 - i * 0.05, 0, 0.35 - i * 0.05, 0)
			wave.Rotation = -2 + (i - 1) * 2
			wave.ZIndex = 1
			wave.Parent = wavesContainer
			corner(wave, 80)
			local wGrad = Instance.new("UIGradient")
			wGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, lerpColor(waveColors[i], C.BG, 0.3)),
				ColorSequenceKeypoint.new(0.5, waveColors[i]),
				ColorSequenceKeypoint.new(1, lerpColor(waveColors[i], C.BGAlt, 0.4)),
			})
			wGrad.Parent = wave
			waveFrames[#waveFrames + 1] = {frame = wave, grad = wGrad, baseRot = -2 + (i-1) * 2, baseY = TOPBAR_H + (i-1)*12}
		end

		for i = 1, 2 do
			local dark = Instance.new("Frame")
			noHit(dark)
			dark.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
			dark.BackgroundTransparency = 0.25 + i * 0.15
			dark.AnchorPoint = Vector2.new(0.5, 0)
			dark.Position = UDim2.new(0.5 + (i == 1 and 0.05 or -0.1), 0, 0.25 + i * 0.15, 0)
			dark.Size = UDim2.new(1.5, 0, 0.6 - i * 0.05, 0)
			dark.Rotation = -4 + i * 9
			dark.ZIndex = 1
			dark.Parent = wavesContainer
			corner(dark, 100)
		end

		poolAdd(function(dt)
			if not wavesContainer or not wavesContainer.Parent then return false end
			if not wavesContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick() * 0.45
			for i, w in ipairs(waveFrames) do
				w.frame.Rotation = w.baseRot + math.sin(t * (0.5 + i * 0.1)) * 2.5
				w.frame.Position = UDim2.new(
					0.5 + math.sin(t * (0.3 + i * 0.08)) * 0.02,
					0, 0,
					w.baseY + math.cos(t * (0.4 + i * 0.06)) * 4
				)
				w.grad.Offset = Vector2.new(math.sin(t * (0.2 + i * 0.05)) * 0.1, 0)
			end
			return true
		end)

		bgPresets["waves"] = wavesContainer
	end

	do
		local particleContainer = Instance.new("Frame")
		noHit(particleContainer)
		particleContainer.BackgroundTransparency = 1
		particleContainer.Size = UDim2.new(1, 0, 1, 0)
		particleContainer.ZIndex = 1
		particleContainer.ClipsDescendants = true
		particleContainer.Visible = false
		particleContainer.Parent = bgMaster

		local particles = {}
		local pColors = {C.Accent, C.Purple, C.ElecBlue, C.Mint, C.Lilac, C.SkyBlue, C.Peach, C.Lavender}
		for i = 1, 20 do
			local p = Instance.new("Frame")
			noHit(p)
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			p.BackgroundColor3 = pColors[math.random(1, #pColors)]
			local sz = math.floor((2 + math.random() * 6) * SC)
			p.Size = UDim2.new(0, sz, 0, sz)
			p.BackgroundTransparency = 0.82 + math.random() * 0.12
			local px = math.random(5, 95) / 100
			local py = math.random(5, 95) / 100
			p.Position = UDim2.new(px, 0, py, 0)
			p.ZIndex = 1
			p.Parent = particleContainer
			corner(p, math.floor(sz / 2))
			particles[#particles + 1] = {
				frame = p,
				bx = px, by = py,
				vx = (math.random() - 0.5) * 0.01,
				vy = -0.002 - math.random() * 0.005,
				speed = 0.3 + math.random() * 0.5,
				phase = math.random() * math.pi * 2,
				baseTr = 0.82 + math.random() * 0.12,
			}
		end

		local pParX, pParY = 0, 0
		poolAdd(function(dt)
			if not particleContainer or not particleContainer.Parent then return false end
			if not particleContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick()
			local mPos = UserInputService:GetMouseLocation()
			local vpS = Camera.ViewportSize
			pParX = pParX + ((mPos.X / vpS.X - 0.5) * 0.015 - pParX) * math.min(dt * 2, 1)
			pParY = pParY + ((mPos.Y / vpS.Y - 0.5) * 0.015 - pParY) * math.min(dt * 2, 1)
			for i, p in ipairs(particles) do
				p.bx = p.bx + p.vx * dt
				p.by = p.by + p.vy * dt
				if p.by < -0.1 then p.by = 1.1; p.bx = math.random(5, 95) / 100 end
				if p.bx < -0.1 then p.bx = 1.1 end
				if p.bx > 1.1 then p.bx = -0.1 end
				local wobbleX = math.sin(t * p.speed + p.phase) * 0.008
				local wobbleY = math.cos(t * p.speed * 0.7 + p.phase) * 0.005
				p.frame.Position = UDim2.new(
					p.bx + wobbleX - pParX * (0.5 + (i % 5) * 0.2),
					0,
					p.by + wobbleY - pParY * (0.3 + (i % 4) * 0.15),
					0
				)
				p.frame.BackgroundTransparency = p.baseTr + math.sin(t * (0.5 + i * 0.08)) * 0.06
			end
			return true
		end)

		bgPresets["particles"] = particleContainer
	end

	function W:SetBackground(name)
		name = name or "matrix"
		for k, container in pairs(bgPresets) do
			container.Visible = (k == name)
		end
		activeBG = name
	end

	function W:GetBackgroundNames()
		local names = {}
		for k in pairs(bgPresets) do
			names[#names + 1] = k
		end
		table.sort(names)
		return names
	end

	W:SetBackground(activeBG)

if introOn then
    local intro = Instance.new("Frame")
    intro.BackgroundTransparency = 0
    intro.BackgroundColor3 = C.BG
    intro.Size = UDim2.new(1, 0, 1, 0)
    intro.ZIndex = 100
    intro.ClipsDescendants = true
    intro.Parent = screenGui

    local termBox = Instance.new("Frame")
    noHit(termBox)
    termBox.AnchorPoint = Vector2.new(0.5, 0.5)
    termBox.BackgroundColor3 = C.BGAlt
    termBox.BackgroundTransparency = 0.15
    termBox.Position = UDim2.new(0.5, 0, 0.46, 0)
    termBox.Size = UDim2.new(0, math.floor(420 * SC), 0, math.floor(150 * SC))
    termBox.ZIndex = 101
    termBox.Parent = intro
    corner(termBox, 10)
    local termStroke = strokeInst(termBox, C.Border, 1, 0.3)

    -- barrinha de topo tipo janela de terminal, com 3 "botões"
    local termTop = Instance.new("Frame")
    noHit(termTop)
    termTop.BackgroundColor3 = C.Surface
    termTop.BackgroundTransparency = 0.2
    termTop.Size = UDim2.new(1, 0, 0, math.floor(22 * SC))
    termTop.ZIndex = 102
    termTop.Parent = termBox
    corner(termTop, 10)
    local termDotColors = {
        Color3.fromRGB(210, 80, 80),   -- vermelho
        Color3.fromRGB(210, 180, 70),  -- amarelo
        Color3.fromRGB(90, 180, 100),  -- verde
    }
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        noHit(dot)
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.BackgroundColor3 = termDotColors[i]
        dot.Position = UDim2.new(0, 10 + (i - 1) * 12, 0.5, 0)
        dot.Size = UDim2.new(0, math.floor(6 * SC), 0, math.floor(6 * SC))
        dot.ZIndex = 103
        dot.Parent = termTop
        corner(dot, 99)
    end

    local termLabel = Instance.new("TextLabel")
    noHit(termLabel)
    termLabel.BackgroundTransparency = 1
    termLabel.Position = UDim2.new(0, 14, 0, math.floor(30 * SC))
    termLabel.Size = UDim2.new(1, -28, 1, -math.floor(40 * SC))
    termLabel.Font = Enum.Font.Code
    termLabel.TextSize = math.floor(13 * SC)
    termLabel.Text = ""
    termLabel.TextColor3 = C.Text
    termLabel.TextXAlignment = Enum.TextXAlignment.Left
    termLabel.TextYAlignment = Enum.TextYAlignment.Top
    termLabel.TextWrapped = true
    termLabel.LineHeight = 1.35
    termLabel.ZIndex = 102
    termLabel.Parent = termBox

    local pName = "guest"
    pcall(function() pName = Player.DisplayName end)

    local bootLines = {
        "> " .. (title or "hub") .. " boot sequence",
        "> mounting sidebar & tabs... ok",
        "> config manager... ok",
        "> theme: monochrome",
        "> user: " .. pName,
        "> bind: [" .. keybind.Name .. "] toggle menu",
        "> " .. (title or "hub") .. " ready",
    }

    task.spawn(function()
        task.wait(0.15)
        local shown = ""
        for li, line in ipairs(bootLines) do
            for ci = 1, #line do
                termLabel.Text = shown .. string.sub(line, 1, ci)
                if ci % 3 == 0 then playSound(Sounds.typing, 0.02, 1.3 + math.random() * 0.5) end
                task.wait(0.009)
            end
            shown = shown .. line .. "\n"
            task.wait(li == #bootLines and 0.25 or 0.08)
        end

        for i = 1, 4 do
            termLabel.Text = shown .. (i % 2 == 1 and "_" or "")
            task.wait(0.15)
        end

        playSound(Sounds.expand, 0.1, 1.1)
        tw(termStroke, 0.25, {Transparency = 1})
        tw(termBox, 0.3, {BackgroundTransparency = 1})
        tw(termLabel, 0.25, {TextTransparency = 1})
        tw(termTop, 0.25, {BackgroundTransparency = 1})
        task.wait(0.15)
        tw(intro, 0.3, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint)
        task.wait(0.35)
        if intro and intro.Parent then intro:Destroy() end
    end)
end

	task.spawn(function()
		if introOn then task.wait(3.7) end
		if blurEnabled then showBlur() end
		tw(main, 0.6, {Size = UDim2.new(0, WW, 0, WH), GroupTransparency = 0}, Enum.EasingStyle.Back)
		playSound(Sounds.expand, 0.15, 0.9)
	end)

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.BackgroundColor3 = C.TopbarBG
	topbar.BackgroundTransparency = 0
	topbar.Position = UDim2.new(0, 0, 0, 0)
	topbar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
	topbar.ZIndex = 30
	topbar.BorderSizePixel = 0
	topbar.Parent = main

	local topbarOverlay = Instance.new("Frame")
	noHit(topbarOverlay)
	topbarOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
	topbarOverlay.BackgroundTransparency = 0.92
	topbarOverlay.Size = UDim2.new(1, 0, 1, 0)
	topbarOverlay.ZIndex = 30
	topbarOverlay.Parent = topbar
	local tbGrad = Instance.new("UIGradient")
	tbGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, lerpColor(C.PurpleSub, C.BG, 0.7)),
		ColorSequenceKeypoint.new(0.5, C.BG),
		ColorSequenceKeypoint.new(1, lerpColor(C.AccentSub, C.BG, 0.6)),
	})
	tbGrad.Parent = topbarOverlay

	local topbarBotLine = Instance.new("Frame")
	noHit(topbarBotLine)
	topbarBotLine.BackgroundColor3 = C.Border
	topbarBotLine.BackgroundTransparency = 0.5
	topbarBotLine.Position = UDim2.new(0, 0, 1, -1)
	topbarBotLine.Size = UDim2.new(1, 0, 0, 1)
	topbarBotLine.ZIndex = 31
	topbarBotLine.Parent = topbar

	local logoIcon = Instance.new("ImageLabel")
	noHit(logoIcon)
	logoIcon.BackgroundTransparency = 1
	logoIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	logoIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	logoIcon.Size = UDim2.new(0, math.floor(26 * SC), 0, math.floor(26 * SC))
	logoIcon.Image = getIconAsset("flare") or "rbxassetid://6031280882"
	logoIcon.ImageColor3 = C.Accent
	logoIcon.ScaleType = Enum.ScaleType.Fit
	logoIcon.ZIndex = 32
	logoIcon.Rotation = 0
	logoIcon.Parent = topbar

	local logoText = Instance.new("TextLabel")
	noHit(logoText)
	logoText.BackgroundTransparency = 1
	logoText.Position = UDim2.new(0, 46, 0, 0)
	logoText.Size = UDim2.new(0, 220, 1, 0)
	logoText.Font = Enum.Font.GothamBlack
	logoText.TextSize = FONT_TITLE
	logoText.RichText = true
	logoText.Text = string.format(
		'<font color="rgb(255,255,255)">Angel</font> <font color="rgb(30,30,30)">Ware</font>',
		math.floor(C.Text.R * 255), math.floor(C.Text.G * 255), math.floor(C.Text.B * 255),
		math.floor(C.Dim.R * 255), math.floor(C.Dim.G * 255), math.floor(C.Dim.B * 255)
	)
	logoText.TextXAlignment = Enum.TextXAlignment.Left
	logoText.TextTransparency = 1
	logoText.ZIndex = 32
	logoText.Parent = topbar

	task.spawn(function()
		if introOn then task.wait(4.0) else task.wait(0.8) end
		tw(logoIcon, 0.5, {Rotation = 720, Position = UDim2.new(0, 27, 0.5, 0)}, Enum.EasingStyle.Quint)
		task.wait(0.4)
		tw(logoIcon, 0.3, {Rotation = 0}, Enum.EasingStyle.Back)
		tw(logoText, 0.5, {TextTransparency = 0}, Enum.EasingStyle.Quint)
	end)

	local searchContainer = Instance.new("Frame")
	searchContainer.Active = true
	searchContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	searchContainer.BackgroundColor3 = C.Surface
	searchContainer.BackgroundTransparency = 0.3
	searchContainer.Position = UDim2.new(0.5, 20, 0.5, 0)
	searchContainer.Size = UDim2.new(0, math.floor(240 * SC), 0, math.floor(30 * SC))
	searchContainer.ZIndex = 33
	searchContainer.Parent = topbar
	corner(searchContainer, 12)
	strokeInst(searchContainer, C.Border, 1, 0.45)

	local searchIcon = Instance.new("TextLabel")
	noHit(searchIcon)
	searchIcon.BackgroundTransparency = 1
	searchIcon.Position = UDim2.new(0, 10, 0, 0)
	searchIcon.Size = UDim2.new(0, 20, 1, 0)
	searchIcon.Font = Enum.Font.GothamBold
	searchIcon.TextSize = math.floor(14 * SC)
	searchIcon.Text = ""
	searchIcon.TextColor3 = C.Dim
	local searchImgIcon = Instance.new("ImageLabel")
	noHit(searchImgIcon)
	searchImgIcon.BackgroundTransparency = 1
	searchImgIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	searchImgIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	searchImgIcon.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
	searchImgIcon.Image = getIconAsset("search") or ""
	searchImgIcon.ImageColor3 = C.Dim
	searchImgIcon.ScaleType = Enum.ScaleType.Fit
	searchImgIcon.ZIndex = 33
	searchImgIcon.Parent = searchIcon
	searchIcon.ZIndex = 34
	searchIcon.Parent = searchContainer

	local searchBox = Instance.new("TextBox")
	searchBox.BackgroundTransparency = 1
	searchBox.Position = UDim2.new(0, 30, 0, 0)
	searchBox.Size = UDim2.new(1, -70, 1, 0)
	searchBox.Font = Enum.Font.GothamMedium
	searchBox.TextSize = math.floor(11 * SC)
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search... (Ctrl+K)"
	searchBox.PlaceholderColor3 = C.Dim
	searchBox.TextColor3 = C.Text
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = true
	searchBox.ZIndex = 35
	searchBox.Parent = searchContainer

	local searchKbd = Instance.new("TextLabel")
	noHit(searchKbd)
	searchKbd.AnchorPoint = Vector2.new(1, 0.5)
	searchKbd.BackgroundColor3 = C.BGAlt
	searchKbd.BackgroundTransparency = 0.4
	searchKbd.Position = UDim2.new(1, -6, 0.5, 0)
	searchKbd.Size = UDim2.new(0, 36, 0, 18)
	searchKbd.Font = Enum.Font.GothamBold
	searchKbd.TextSize = math.floor(8 * SC)
	searchKbd.Text = "Ctrl K"
	searchKbd.TextColor3 = C.Dim
	searchKbd.ZIndex = 34
	searchKbd.Parent = searchContainer
	corner(searchKbd, 5)

	local function createCtrlBtn(symbol, posX, hoverColor, callback)
		local btn = Instance.new("TextButton")
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.BackgroundTransparency = 1
		btn.BackgroundColor3 = hoverColor
		btn.Position = UDim2.new(1, posX, 0.5, 0)
		btn.Size = UDim2.new(0, 34, 0, 34)
		btn.Text = symbol
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = symbol == "\xC3\x97" and 22 or 16
		btn.TextColor3 = C.Dim
		btn.AutoButtonColor = false
		btn.ZIndex = 35
		btn.Parent = topbar
		corner(btn, 11)

		btn.MouseEnter:Connect(function()
			tw(btn, 0.14, {BackgroundTransparency = 0.75, TextColor3 = hoverColor})
			playSound(Sounds.hover, 0.05, 1.3)
		end)
		btn.MouseLeave:Connect(function()
			tw(btn, 0.14, {BackgroundTransparency = 1, TextColor3 = C.Dim})
		end)
		btn.MouseButton1Click:Connect(function()
			playSound(Sounds.click, 0.12, 1.0)
			createRipple(btn, hoverColor)
			callback()
		end)
		return btn
	end

	local function hideWindow()
		W.Visible = false
		playSound(Sounds.collapse, 0.12, 1.1)
		hideBlur()
		tw(main, 0.35, {
			GroupTransparency = 1,
			Size = UDim2.new(0, WW * 0.92, 0, WH * 0.92),
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.38, function()
			main.Visible = false
		end)
	end

	local function showWindow()
		W.Visible = true
		main.Visible = true
		if blurEnabled then showBlur() end
		playSound(Sounds.expand, 0.12, 0.95)
		tw(main, 0.5, {
			GroupTransparency = 0,
			Size = UDim2.new(0, WW, 0, WH),
		}, Enum.EasingStyle.Back)
	end

	createCtrlBtn("\xC3\x97", -14, C.Err, hideWindow)
	createCtrlBtn("\xE2\x80\x94", -52, C.Warn, hideWindow)
	makeDrag(main, topbar)

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if input.KeyCode == keybind then
			local focused = UserInputService:GetFocusedTextBox()
			if focused then return end
			if W.Visible then hideWindow() else showWindow() end
		end
	end))

	if IS_MOBILE then
		local mobileBtn = Instance.new("TextButton")
		mobileBtn.AnchorPoint = Vector2.new(0, 1)
		mobileBtn.BackgroundColor3 = C.Surface
		mobileBtn.BackgroundTransparency = 0.1
		mobileBtn.Position = UDim2.new(0, 12, 1, -12)
		mobileBtn.Size = UDim2.new(0, 48, 0, 48)
		mobileBtn.Text = ""
		mobileBtn.Font = Enum.Font.GothamBold
		mobileBtn.TextSize = 22
		mobileBtn.TextColor3 = C.Accent
		mobileBtn.AutoButtonColor = false
		mobileBtn.ZIndex = 99
		mobileBtn.Parent = screenGui
		corner(mobileBtn, 24)
		strokeInst(mobileBtn, C.Border, 1.5, 0.3)
		addClayShadow(mobileBtn, 24)

		local mobileIcon = Instance.new("ImageLabel")
		noHit(mobileIcon)
		mobileIcon.BackgroundTransparency = 1
		mobileIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		mobileIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		mobileIcon.Size = UDim2.new(0, 26, 0, 26)
		mobileIcon.Image = getIconAsset("flare") or "rbxassetid://6031280882"
		mobileIcon.ImageColor3 = C.Accent
		mobileIcon.ScaleType = Enum.ScaleType.Fit
		mobileIcon.ZIndex = 100
		mobileIcon.Parent = mobileBtn

		local mobileDragging = false
		local mobileDragStart = nil
		local mobileBtnStart = nil

		mobileBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				mobileDragging = true
				mobileDragStart = input.Position
				mobileBtnStart = mobileBtn.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						mobileDragging = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if mobileDragging and input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - mobileDragStart
				if delta.Magnitude > 15 then
					mobileBtn.Position = UDim2.new(
						mobileBtnStart.X.Scale, mobileBtnStart.X.Offset + delta.X,
						mobileBtnStart.Y.Scale, mobileBtnStart.Y.Offset + delta.Y
					)
				end
			end
		end)

		mobileBtn.MouseButton1Click:Connect(function()
			playSound(Sounds.click, 0.12, 1.0)
			createRipple(mobileBtn, C.Accent)
			if W.Visible then
				hideWindow()
				tw(mobileBtn, 0.2, {BackgroundTransparency = 0.1})
			else
				showWindow()
				tw(mobileBtn, 0.2, {BackgroundTransparency = 0.4})
			end
		end)

		poolAdd(function(dt)
			if not mobileBtn or not mobileBtn.Parent then return false end
			if not ANIM_ENABLED then return true end
			local t = tick() * 2
			mobileBtn.Rotation = math.sin(t * 0.3) * 3
			return true
		end)
	end

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = C.SidebarBG
	sidebar.BackgroundTransparency = 0.03
	sidebar.Position = UDim2.new(0, 0, 0, TOPBAR_H)
	sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -TOPBAR_H - FOOTER_H)
	sidebar.ZIndex = 25
	sidebar.BorderSizePixel = 0
	sidebar.ClipsDescendants = true
	sidebar.Parent = main

	local sideGrad = Instance.new("UIGradient")
	sideGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.SidebarBG),
		ColorSequenceKeypoint.new(1, lerpColor(C.SidebarBG, C.BG, 0.5)),
	})
	sideGrad.Rotation = 180
	sideGrad.Parent = sidebar

	local sideRightLine = Instance.new("Frame")
	noHit(sideRightLine)
	sideRightLine.BackgroundColor3 = C.Border
	sideRightLine.BackgroundTransparency = 0.5
	sideRightLine.Position = UDim2.new(1, -1, 0, 0)
	sideRightLine.Size = UDim2.new(0, 1, 1, 0)
	sideRightLine.ZIndex = 26
	sideRightLine.Parent = sidebar

	local sideScroll = Instance.new("ScrollingFrame")
	sideScroll.BackgroundTransparency = 1
	sideScroll.Size = UDim2.new(1, 0, 1, -math.floor(56 * SC))
	sideScroll.Position = UDim2.new(0, 0, 0, math.floor(56 * SC))
	sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	sideScroll.ScrollBarThickness = 0
	sideScroll.ZIndex = 26
	sideScroll.Parent = sidebar
	pad(sideScroll, 6, 12, 0, 0)

	local sideLayout = uiList(sideScroll, 7, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
	sideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		task.defer(function()
			if sideScroll and sideScroll.Parent then
				-- AbsoluteContentSize is in scaled px; divide by UIScale so CanvasSize (local
				-- space) stays correct when UI Scale < 100% — otherwise the canvas shrinks
				-- below the content and the bottom tabs become unreachable.
				sideScroll.CanvasSize = UDim2.new(0, 0, 0, sideLayout.AbsoluteContentSize.Y / math.max(uiScaleObj.Scale, 0.01) + 24)
			end
		end)
	end)

	local playerInfoFrame = Instance.new("Frame")
	noHit(playerInfoFrame)
	playerInfoFrame.BackgroundTransparency = 1
	playerInfoFrame.Size = UDim2.new(1, 0, 0, math.floor(50 * SC))
	playerInfoFrame.Position = UDim2.new(0, 0, 0, 4)
	playerInfoFrame.ZIndex = 27
	playerInfoFrame.Parent = sidebar

	local playerAvatar = Instance.new("ImageLabel")
	noHit(playerAvatar)
	playerAvatar.AnchorPoint = Vector2.new(0.5, 0.5)
	playerAvatar.BackgroundColor3 = C.AccentSub
	playerAvatar.BackgroundTransparency = 0.4
	playerAvatar.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2), 0.5, 0)
	playerAvatar.Size = UDim2.new(0, math.floor(32 * SC), 0, math.floor(32 * SC))
	playerAvatar.ZIndex = 28
	playerAvatar.Parent = playerInfoFrame
	corner(playerAvatar, math.floor(16 * SC))
	pcall(function()
		playerAvatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	strokeInst(playerAvatar, C.Border, 1.5, 0.3)

	local playerNameLabel = Instance.new("TextLabel")
	noHit(playerNameLabel)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2) + math.floor(22 * SC), 0, 6)
	playerNameLabel.Size = UDim2.new(1, -math.floor(SIDEBAR_W / 2) - math.floor(28 * SC), 0, math.floor(18 * SC))
	playerNameLabel.Font = Enum.Font.GothamBold
	playerNameLabel.TextSize = math.floor(11 * SC)
	playerNameLabel.Text = Player.DisplayName
	playerNameLabel.TextColor3 = C.Text
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	playerNameLabel.TextTransparency = 1
	playerNameLabel.Visible = false
	playerNameLabel.ZIndex = 28
	playerNameLabel.Parent = playerInfoFrame

	local playerIdLabel = Instance.new("TextLabel")
	noHit(playerIdLabel)
	playerIdLabel.BackgroundTransparency = 1
	playerIdLabel.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2) + math.floor(22 * SC), 0, math.floor(24 * SC))
	playerIdLabel.Size = UDim2.new(1, -math.floor(SIDEBAR_W / 2) - math.floor(28 * SC), 0, math.floor(14 * SC))
	playerIdLabel.Font = Enum.Font.GothamMedium
	playerIdLabel.TextSize = math.floor(9 * SC)
	playerIdLabel.Text = "ID: " .. tostring(Player.UserId)
	playerIdLabel.TextColor3 = C.Dim
	playerIdLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerIdLabel.TextTruncate = Enum.TextTruncate.AtEnd
	playerIdLabel.TextTransparency = 1
	playerIdLabel.Visible = false
	playerIdLabel.ZIndex = 28
	playerIdLabel.Parent = playerInfoFrame
	local _allSideLabels = {}
	local _sidebarTweens = {}

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true
	content.Position = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H)
	content.Size = UDim2.new(1, -SIDEBAR_W, 1, -TOPBAR_H - FOOTER_H)
	content.ZIndex = 5
	content.Parent = main

	local function cancelSidebarTweens()
		for _, t in ipairs(_sidebarTweens) do
			pcall(function() t:Cancel() end)
		end
		_sidebarTweens = {}
	end

	local function expandSidebar()
		if sidebarExpanded then return end
		sidebarExpanded = true
		playSound(Sounds.expand, 0.06, 1.15)
		cancelSidebarTweens()
		local dur = 0.25
		local style = Enum.EasingStyle.Quart
		local dir = Enum.EasingDirection.Out
		local info = TweenInfo.new(dur, style, dir)
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(sidebar, info, {Size = UDim2.new(0, SIDEBAR_EXP, 1, -TOPBAR_H - FOOTER_H)})
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(content, info, {Position = UDim2.new(0, SIDEBAR_EXP, 0, TOPBAR_H)})
		for _, t in ipairs(_sidebarTweens) do t:Play() end
		for _, info2 in ipairs(_allSideLabels) do
			if info2.label and info2.label.Parent then
				info2.label.Visible = true
				tw(info2.label, dur, {TextTransparency = 0}, style, dir)
			end
		end
		if playerNameLabel and playerNameLabel.Parent then
			playerNameLabel.Visible = true
			playerIdLabel.Visible = true
			tw(playerNameLabel, dur, {TextTransparency = 0}, style, dir)
			tw(playerIdLabel, dur, {TextTransparency = 0}, style, dir)
		end
	end

	local function collapseSidebar()
		if not sidebarExpanded then return end
		sidebarExpanded = false
		playSound(Sounds.collapse, 0.04, 1.2)
		cancelSidebarTweens()
		local dur = 0.2
		local style = Enum.EasingStyle.Quart
		local dir = Enum.EasingDirection.Out
		local info = TweenInfo.new(dur, style, dir)
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(sidebar, info, {Size = UDim2.new(0, SIDEBAR_W, 1, -TOPBAR_H - FOOTER_H)})
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(content, info, {Position = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H)})
		for _, t in ipairs(_sidebarTweens) do t:Play() end
		for _, info2 in ipairs(_allSideLabels) do
			if info2.label and info2.label.Parent then
				tw(info2.label, dur, {TextTransparency = 1}, style, dir)
				task.delay(dur, function()
					if not sidebarExpanded and info2.label and info2.label.Parent then info2.label.Visible = false end
				end)
			end
		end
		if playerNameLabel and playerNameLabel.Parent then
			tw(playerNameLabel, dur, {TextTransparency = 1}, style, dir)
			tw(playerIdLabel, dur, {TextTransparency = 1}, style, dir)
			task.delay(dur, function()
				if not sidebarExpanded and playerNameLabel and playerNameLabel.Parent then
					playerNameLabel.Visible = false
					playerIdLabel.Visible = false
				end
			end)
		end
	end

	sidebar.MouseEnter:Connect(function()
		if not sidebarHoverLock then expandSidebar() end
	end)
	sidebar.MouseLeave:Connect(function()
		if not sidebarHoverLock then collapseSidebar() end
	end)

	local footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundColor3 = C.FooterBG
	footer.BackgroundTransparency = 0.08
	footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
	footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
	footer.ZIndex = 30
	footer.BorderSizePixel = 0
	footer.Parent = main

	local footerTopLine = Instance.new("Frame")
	noHit(footerTopLine)
	footerTopLine.BackgroundColor3 = C.Border
	footerTopLine.BackgroundTransparency = 0.5
	footerTopLine.Size = UDim2.new(1, 0, 0, 1)
	footerTopLine.ZIndex = 31
	footerTopLine.Parent = footer

	local footerGrad = Instance.new("UIGradient")
	footerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, lerpColor(C.FooterBG, C.BG, 0.3)),
		ColorSequenceKeypoint.new(1, C.FooterBG),
	})
	footerGrad.Parent = footer

	local fpsLabel = Instance.new("TextLabel")
	noHit(fpsLabel)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Position = UDim2.new(0, 14, 0, 0)
	fpsLabel.Size = UDim2.new(0, 100, 1, 0)
	fpsLabel.Font = Enum.Font.GothamBold
	fpsLabel.TextSize = FONT_FOOTER
	fpsLabel.Text = "FPS: --"
	fpsLabel.TextColor3 = C.Sub
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.ZIndex = 32
	fpsLabel.Parent = footer

	local pingLabel = Instance.new("TextLabel")
	noHit(pingLabel)
	pingLabel.BackgroundTransparency = 1
	pingLabel.Position = UDim2.new(0, 120, 0, 0)
	pingLabel.Size = UDim2.new(0, 110, 1, 0)
	pingLabel.Font = Enum.Font.GothamBold
	pingLabel.TextSize = FONT_FOOTER
	pingLabel.Text = "Ping: --ms"
	pingLabel.TextColor3 = C.Sub
	pingLabel.TextXAlignment = Enum.TextXAlignment.Left
	pingLabel.ZIndex = 32
	pingLabel.Parent = footer

	local timeLabel = Instance.new("TextLabel")
	noHit(timeLabel)
	timeLabel.AnchorPoint = Vector2.new(1, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Position = UDim2.new(1, -14, 0, 0)
	timeLabel.Size = UDim2.new(0, 120, 1, 0)
	timeLabel.Font = Enum.Font.GothamBold
	timeLabel.TextSize = FONT_FOOTER
	timeLabel.Text = "00:00:00"
	timeLabel.TextColor3 = C.Sub
	timeLabel.TextXAlignment = Enum.TextXAlignment.Right
	timeLabel.ZIndex = 32
	timeLabel.Parent = footer

	local versionFooter = Instance.new("TextLabel")
	noHit(versionFooter)
	versionFooter.AnchorPoint = Vector2.new(0.5, 0)
	versionFooter.BackgroundTransparency = 1
	versionFooter.Position = UDim2.new(0.5, 0, 0, 0)
	versionFooter.Size = UDim2.new(0, 200, 1, 0)
	versionFooter.Font = Enum.Font.GothamBold
	versionFooter.TextSize = FONT_FOOTER
	versionFooter.Text = title
	versionFooter.TextColor3 = C.Dim
	versionFooter.TextTransparency = 0.25
	versionFooter.ZIndex = 32
	versionFooter.Parent = footer

	local fpsCounter = 0
	local fpsAccum = 0
	local _pingAccum = 0
	local _timeAccum = 0
	poolAdd(function(dt)
		if not fpsLabel or not fpsLabel.Parent then return false end
		fpsAccum = fpsAccum + dt
		fpsCounter = fpsCounter + 1
		_pingAccum = _pingAccum + dt
		_timeAccum = _timeAccum + dt
		if fpsAccum >= 0.5 then
			local fps = math.floor(fpsCounter / fpsAccum)
			fpsLabel.Text = "FPS: " .. tostring(fps)
			fpsLabel.TextColor3 = fps >= 50 and C.Ok or fps >= 30 and C.Warn or C.Err
			fpsCounter = 0
			fpsAccum = 0
		end
		if _pingAccum >= 1 then
			_pingAccum = 0
			local pingValue = nil
			pcall(function()
				pingValue = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			if not pingValue then
				pcall(function()
					pingValue = math.floor(Player:GetNetworkPing() * 1000)
				end)
			end
			if pingValue then
				pingLabel.Text = "Ping: " .. tostring(pingValue) .. "ms"
				pingLabel.TextColor3 = pingValue <= 80 and C.Ok or pingValue <= 150 and C.Warn or C.Err
			else
				pingLabel.Text = "Ping: N/A"
				pingLabel.TextColor3 = C.Dim
			end
		end
		if _timeAccum >= 1 then
			_timeAccum = 0
			local now = os.date("*t")
			timeLabel.Text = string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
		end
		return true
	end)

	local ACTIVE_W = math.floor(180 * SC)
	local ACTIVE_HEADER_H = math.floor(30 * SC)
	local ACTIVE_ITEM_H = math.floor(24 * SC)
	local ACTIVE_MAX_VISIBLE = 10
	local activePanelMinimized = false

	local activeOverlay = Instance.new("Frame")
	noHit(activeOverlay)
	activeOverlay.AnchorPoint = Vector2.new(1, 0)
	activeOverlay.BackgroundColor3 = C.BG
	activeOverlay.BackgroundTransparency = 0.06
	activeOverlay.Position = UDim2.new(1, -10, 0, 54)
	activeOverlay.Size = UDim2.new(0, ACTIVE_W, 0, 0)
	activeOverlay.AutomaticSize = Enum.AutomaticSize.Y
	activeOverlay.ZIndex = 45
	activeOverlay.Visible = false
	activeOverlay.ClipsDescendants = true
	activeOverlay.Active = true
	activeOverlay.Draggable = true
	activeOverlay.Parent = screenGui
	corner(activeOverlay, 10)
	strokeInst(activeOverlay, C.Border, 1, 0.4)
	addClayShadow(activeOverlay, 10)

	local activeHeader = Instance.new("Frame")
	noHit(activeHeader)
	activeHeader.BackgroundTransparency = 1
	activeHeader.Size = UDim2.new(1, 0, 0, ACTIVE_HEADER_H)
	activeHeader.ZIndex = 47
	activeHeader.Parent = activeOverlay

	local activeStatusDot = Instance.new("Frame")
	noHit(activeStatusDot)
	activeStatusDot.AnchorPoint = Vector2.new(0, 0.5)
	activeStatusDot.BackgroundColor3 = C.Accent
	activeStatusDot.Position = UDim2.new(0, 10, 0.5, 0)
	activeStatusDot.Size = UDim2.new(0, math.floor(6 * SC), 0, math.floor(6 * SC))
	activeStatusDot.ZIndex = 48
	activeStatusDot.Parent = activeHeader
	corner(activeStatusDot, 99)

	local activeTitle = Instance.new("TextLabel")
	noHit(activeTitle)
	activeTitle.BackgroundTransparency = 1
	activeTitle.Position = UDim2.new(0, math.floor(22 * SC), 0, 0)
	activeTitle.Size = UDim2.new(0.7, 0, 1, 0)
	activeTitle.Font = Enum.Font.GothamBold
	activeTitle.TextSize = math.floor(11 * SC)
	activeTitle.Text = "Active"
	activeTitle.TextColor3 = C.Text
	activeTitle.TextTransparency = 0.1
	activeTitle.TextXAlignment = Enum.TextXAlignment.Left
	activeTitle.ZIndex = 47
	activeTitle.Parent = activeHeader

	local activeCountBadge = Instance.new("Frame")
	noHit(activeCountBadge)
	activeCountBadge.AnchorPoint = Vector2.new(1, 0.5)
	activeCountBadge.BackgroundColor3 = C.Accent
	activeCountBadge.BackgroundTransparency = 0.4
	activeCountBadge.Position = UDim2.new(1, -8, 0.5, 0)
	activeCountBadge.Size = UDim2.new(0, math.floor(22 * SC), 0, math.floor(16 * SC))
	activeCountBadge.ZIndex = 48
	activeCountBadge.Parent = activeHeader
	corner(activeCountBadge, 8)

	local activeCountLabel = Instance.new("TextLabel")
	noHit(activeCountLabel)
	activeCountLabel.BackgroundTransparency = 1
	activeCountLabel.Size = UDim2.new(1, 0, 1, 0)
	activeCountLabel.Font = Enum.Font.GothamBold
	activeCountLabel.TextSize = math.floor(10 * SC)
	activeCountLabel.Text = "0"
	activeCountLabel.TextColor3 = C.Text
	activeCountLabel.ZIndex = 49
	activeCountLabel.Parent = activeCountBadge
	strokeInst(activeCountBadge, C.Accent, 1, 0.35)

	-- Hairline under the header separates title/count from the feature list.
	local headerDivider = Instance.new("Frame")
	noHit(headerDivider)
	headerDivider.BackgroundColor3 = C.Border
	headerDivider.BackgroundTransparency = 0.35
	headerDivider.Position = UDim2.new(0, 10, 0, ACTIVE_HEADER_H - 1)
	headerDivider.Size = UDim2.new(1, -20, 0, 1)
	headerDivider.ZIndex = 47
	headerDivider.Parent = activeOverlay
	local hdGrad = Instance.new("UIGradient")
	hdGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	hdGrad.Parent = headerDivider

	local activeListFrame = Instance.new("ScrollingFrame")
	noHit(activeListFrame)
	activeListFrame.BackgroundTransparency = 1
	activeListFrame.Position = UDim2.new(0, 0, 0, ACTIVE_HEADER_H + 2)
	activeListFrame.Size = UDim2.new(1, 0, 0, 0)
	activeListFrame.AutomaticSize = Enum.AutomaticSize.Y
	activeListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	activeListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	activeListFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	activeListFrame.ScrollBarThickness = 2
	activeListFrame.ScrollBarImageColor3 = C.Border
	activeListFrame.ZIndex = 46
	activeListFrame.Parent = activeOverlay
	pad(activeListFrame, 2, 4, 4, 4)
	uiList(activeListFrame, 2, Enum.FillDirection.Vertical)

	local activeFeatureLabels = {}
	local prevActiveCount = 0

	local function updateActivePanel()
		for _, lbl in pairs(activeFeatureLabels) do
			if lbl and lbl.Parent then lbl:Destroy() end
		end
		activeFeatureLabels = {}
		local activeCount = 0
		local sortedNames = {}
		for name, val in pairs(W._activeFeatures) do
			if val and not W._activeHidden[name] then
				activeCount = activeCount + 1
				sortedNames[#sortedNames + 1] = name
			end
		end
		table.sort(sortedNames)

		activeCountLabel.Text = tostring(activeCount)
		if activeCount ~= prevActiveCount then
			springBounce(activeCountBadge, "Size",
				UDim2.new(0, math.floor(22 * SC), 0, math.floor(16 * SC)), 1.1)
			prevActiveCount = activeCount
		end

		activeCountBadge.BackgroundColor3 = C.Accent
		activeStatusDot.BackgroundColor3 = C.Accent

		local maxH = ACTIVE_ITEM_H * math.min(#sortedNames, ACTIVE_MAX_VISIBLE) + 12
		activeListFrame.Size = UDim2.new(1, 0, 0, maxH)

		for i, name in ipairs(sortedNames) do
			local item = Instance.new("Frame")
			noHit(item)
			item.BackgroundColor3 = C.ActiveItemBG
			item.BackgroundTransparency = 1
			item.Size = UDim2.new(1, -6, 0, ACTIVE_ITEM_H)
			item.LayoutOrder = i
			item.ZIndex = 47
			item.Parent = activeListFrame
			corner(item, 6)

			-- Slim accent edge reads cleaner than a floating dot and gives each row a spine.
			local edge = Instance.new("Frame")
			noHit(edge)
			edge.AnchorPoint = Vector2.new(0, 0.5)
			edge.BackgroundColor3 = C.Accent
			edge.BackgroundTransparency = 1
			edge.Position = UDim2.new(0, 5, 0.5, 0)
			edge.Size = UDim2.new(0, math.floor(2 * SC), 0, math.floor(ACTIVE_ITEM_H * 0.5))
			edge.ZIndex = 49
			edge.Parent = item
			corner(edge, 2)

			local nameLabel = Instance.new("TextLabel")
			noHit(nameLabel)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Position = UDim2.new(0, math.floor(14 * SC), 0, 0)
			nameLabel.Size = UDim2.new(1, -math.floor(18 * SC), 1, 0)
			nameLabel.Font = Enum.Font.GothamMedium
			nameLabel.TextSize = math.floor(11 * SC)
			nameLabel.Text = name
			nameLabel.TextColor3 = C.Text
			nameLabel.TextTransparency = 1
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.ZIndex = 49
			nameLabel.Parent = item

			-- Quick, subtly staggered fade-in so the list feels alive on change.
			local delayT = math.min((i - 1) * 0.02, 0.22)
			task.delay(delayT, function()
				if not item.Parent then return end
				tw(item, 0.2, {BackgroundTransparency = 0.45}, Enum.EasingStyle.Quint)
				tw(edge, 0.2, {BackgroundTransparency = 0.1}, Enum.EasingStyle.Quint)
				tw(nameLabel, 0.2, {TextTransparency = 0.12}, Enum.EasingStyle.Quint)
			end)

			activeFeatureLabels[#activeFeatureLabels + 1] = item
		end
		activeOverlay.Visible = activeCount > 0 and W._activePanelEnabled ~= false
	end

	W._activePanelEnabled = true

	function W:SetActivePanelVisible(visible)
		W._activePanelEnabled = visible
		if not visible then
			activeOverlay.Visible = false
		else
			updateActivePanel()
		end
	end

	function W:ToggleActivePanel()
		W:SetActivePanelVisible(not W._activePanelEnabled)
	end

	function W:IsActivePanelVisible()
		return W._activePanelEnabled
	end

	-- Hide/show a single feature in the Active Features panel by its display name
	-- (the toggle's Name, or Flag if it has no Name). The feature keeps working and
	-- keeps counting; it's only removed from the panel list. Equivalent to setting
	-- HideFromActive on the toggle, but toggleable at runtime.
	function W:SetFeatureHiddenFromActive(name, hidden)
		if not name then return end
		W._activeHidden[name] = hidden and true or nil
		if updateActivePanel then updateActivePanel() end
	end

	function W:IsFeatureHiddenFromActive(name)
		return W._activeHidden[name] == true
	end

	W._updateLog = {}
	function W:LogUpdate(msg)
		W._updateLog[#W._updateLog + 1] = {time = os.date("%H:%M:%S"), msg = msg}
		while #W._updateLog > 50 do table.remove(W._updateLog, 1) end
	end
	function W:GetUpdateLog()
		return W._updateLog
	end
	function W:ClearUpdateLog()
		W._updateLog = {}
	end

	local notifContainer = Instance.new("Frame")
	noHit(notifContainer)
	notifContainer.AnchorPoint = Vector2.new(1, 1)
	notifContainer.BackgroundTransparency = 1
	notifContainer.Position = UDim2.new(1, -18, 1, -18)
	notifContainer.Size = UDim2.new(0, 310, 0, 460)
	notifContainer.ZIndex = 70
	notifContainer.Parent = screenGui
	uiList(notifContainer, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)

	function W:Notify(opts)
		opts = opts or {}
		local color = ({Success = C.Ok, Warning = C.Warn, Error = C.Err, Info = C.Info})[opts.Type or "Info"] or C.Accent
		local duration = opts.Duration or 3.5
		playSound(Sounds.notif, 0.12, 1.1)

		local toast = Instance.new("Frame")
		toast.BackgroundColor3 = C.NotifBG
		toast.BackgroundTransparency = 0.01
		toast.Size = UDim2.new(0, 300, 0, 0)
		toast.ClipsDescendants = true
		toast.ZIndex = 72
		toast.Parent = notifContainer
		corner(toast, 16)
		addClayShadow(toast, 16)

		local accentBar = Instance.new("Frame")
		noHit(accentBar)
		accentBar.BackgroundColor3 = color
		accentBar.BackgroundTransparency = 0.3
		accentBar.Position = UDim2.new(0, 16, 0, 0)
		accentBar.Size = UDim2.new(1, -32, 0, 2)
		accentBar.ZIndex = 74
		accentBar.Parent = toast
		corner(accentBar, 1)
		local notifAccGrad = Instance.new("UIGradient")
		notifAccGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.15, 0),
			NumberSequenceKeypoint.new(0.85, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		notifAccGrad.Parent = accentBar

		local iconFrame = Instance.new("Frame")
		noHit(iconFrame)
		iconFrame.AnchorPoint = Vector2.new(0, 0.5)
		iconFrame.BackgroundColor3 = color
		iconFrame.BackgroundTransparency = 0.78
		iconFrame.Position = UDim2.new(0, 16, 0, 28)
		iconFrame.Size = UDim2.new(0, 30, 0, 30)
		iconFrame.ZIndex = 74
		iconFrame.Parent = toast
		corner(iconFrame, 15)

		local iconText = Instance.new("TextLabel")
		noHit(iconText)
		iconText.BackgroundTransparency = 1
		iconText.Size = UDim2.new(1, 0, 1, 0)
		iconText.Font = Enum.Font.GothamBold
		iconText.TextSize = 14
		local notifIconNames = {Success = "check_circle", Error = "cancel", Warning = "warning", Info = "info"}
		local notifIconAsset = getIconAsset(notifIconNames[opts.Type or "Info"])
		if notifIconAsset then
			iconText.Visible = false
			local notifImg = Instance.new("ImageLabel")
			noHit(notifImg)
			notifImg.BackgroundTransparency = 1
			notifImg.AnchorPoint = Vector2.new(0.5, 0.5)
			notifImg.Position = UDim2.new(0.5, 0, 0.5, 0)
			notifImg.Size = UDim2.new(0, 18, 0, 18)
			notifImg.Image = notifIconAsset
			notifImg.ImageColor3 = color
			notifImg.ScaleType = Enum.ScaleType.Fit
			notifImg.ZIndex = 75
			notifImg.Parent = iconFrame
		else
			local notifIconNames = {Success = "check_circle", Error = "cancel", Warning = "warning", Info = "info"}
			local notifIconAsset = getIconAsset(notifIconNames[opts.Type or "Info"])
			if notifIconAsset then
				iconText.Text = ""
				local nImg = Instance.new("ImageLabel")
				noHit(nImg)
				nImg.BackgroundTransparency = 1
				nImg.AnchorPoint = Vector2.new(0.5, 0.5)
				nImg.Position = UDim2.new(0.5, 0, 0.5, 0)
				nImg.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
				nImg.Image = notifIconAsset
				nImg.ImageColor3 = typeColor
				nImg.ScaleType = Enum.ScaleType.Fit
				nImg.ZIndex = iconText.ZIndex + 1
				nImg.Parent = iconText
			else
				iconText.Text = opts.Type == "Success" and "OK" or opts.Type == "Error" and "X" or opts.Type == "Warning" and "!" or "i"
			end
		end
		iconText.TextColor3 = color
		iconText.ZIndex = 75
		iconText.Parent = iconFrame

		local titleLabel = Instance.new("TextLabel")
		noHit(titleLabel)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Position = UDim2.new(0, 54, 0, 8)
		titleLabel.Size = UDim2.new(1, -64, 0, 18)
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 14
		titleLabel.Text = opts.Title or ""
		titleLabel.TextColor3 = C.Text
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.ZIndex = 74
		titleLabel.Parent = toast

		local contentLabel = Instance.new("TextLabel")
		noHit(contentLabel)
		contentLabel.BackgroundTransparency = 1
		contentLabel.Position = UDim2.new(0, 54, 0, 28)
		contentLabel.Size = UDim2.new(1, -64, 0, 16)
		contentLabel.Font = Enum.Font.GothamMedium
		contentLabel.TextSize = 11
		contentLabel.Text = opts.Content or ""
		contentLabel.TextColor3 = C.Sub
		contentLabel.TextXAlignment = Enum.TextXAlignment.Left
		contentLabel.TextTruncate = Enum.TextTruncate.AtEnd
		contentLabel.ZIndex = 74
		contentLabel.Parent = toast

		local progressBG = Instance.new("Frame")
		noHit(progressBG)
		progressBG.BackgroundColor3 = color
		progressBG.BackgroundTransparency = 0.78
		progressBG.AnchorPoint = Vector2.new(0, 1)
		progressBG.Position = UDim2.new(0, 10, 1, -6)
		progressBG.Size = UDim2.new(1, -20, 0, 3)
		progressBG.ZIndex = 74
		progressBG.Parent = toast
		corner(progressBG, 2)

		local progressFill = Instance.new("Frame")
		noHit(progressFill)
		progressFill.BackgroundColor3 = color
		progressFill.Size = UDim2.new(1, 0, 1, 0)
		progressFill.ZIndex = 75
		progressFill.Parent = progressBG
		corner(progressFill, 2)

		tw(toast, 0.45, {Size = UDim2.new(0, 300, 0, 58)}, Enum.EasingStyle.Back)
		tw(progressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

		task.delay(duration + 0.5, function()
			if toast and toast.Parent then
				tw(toast, 0.3, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1})
				task.delay(0.35, function()
					if toast and toast.Parent then toast:Destroy() end
				end)
			end
		end)
	end

	local cmdOverlay = Instance.new("TextButton")
	cmdOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	cmdOverlay.BackgroundTransparency = 0.35
	cmdOverlay.Size = UDim2.new(1, 0, 1, 0)
	cmdOverlay.Text = ""
	cmdOverlay.ZIndex = 79
	cmdOverlay.Visible = false
	cmdOverlay.AutoButtonColor = false
	cmdOverlay.Parent = screenGui

	local cmdFrame = Instance.new("Frame")
	cmdFrame.AnchorPoint = Vector2.new(0.5, 0)
	cmdFrame.BackgroundColor3 = C.Surface
	cmdFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
	cmdFrame.Size = UDim2.new(0, 500, 0, 56)
	cmdFrame.ZIndex = 80
	cmdFrame.Visible = false
	cmdFrame.ClipsDescendants = true
	cmdFrame.Parent = screenGui
	corner(cmdFrame, 20)
	strokeInst(cmdFrame, C.BorderLit, 1, 0.3)
	addClayShadow(cmdFrame, 20)

	local cmdBox = Instance.new("TextBox")
	cmdBox.BackgroundTransparency = 1
	cmdBox.Position = UDim2.new(0, 20, 0, 0)
	cmdBox.Size = UDim2.new(1, -40, 0, 52)
	cmdBox.Font = Enum.Font.GothamMedium
	cmdBox.TextSize = 16
	cmdBox.Text = ""
	cmdBox.PlaceholderText = "Search features..."
	cmdBox.PlaceholderColor3 = C.Dim
	cmdBox.TextColor3 = C.Text
	cmdBox.TextXAlignment = Enum.TextXAlignment.Left
	cmdBox.ClearTextOnFocus = true
	cmdBox.ZIndex = 82
	cmdBox.Parent = cmdFrame

	local cmdResults = Instance.new("ScrollingFrame")
	cmdResults.BackgroundTransparency = 1
	cmdResults.Position = UDim2.new(0, 0, 0, 54)
	cmdResults.Size = UDim2.new(1, 0, 1, -54)
	cmdResults.CanvasSize = UDim2.new(0, 0, 0, 0)
	cmdResults.ScrollBarThickness = 2
	cmdResults.ScrollBarImageColor3 = C.Accent
	cmdResults.ZIndex = 81
	cmdResults.Parent = cmdFrame
	pad(cmdResults, 6, 12, 12, 12)
	local cmdLayout = uiList(cmdResults, 5)

	local cmdOpen = false
	local closeCmd

	local function openCmd()
		if cmdOpen then return end
		cmdOpen = true
		cmdOverlay.Visible = true
		cmdFrame.Visible = true
		cmdFrame.Size = UDim2.new(0, 500, 0, 56)
		playSound(Sounds.expand, 0.1, 1.1)

		for _, ch in pairs(cmdResults:GetChildren()) do
			if ch:IsA("TextButton") then ch:Destroy() end
		end

		local totalElems = 0
		for _, elem in ipairs(W._elems) do
			totalElems = totalElems + 1
			local rb = Instance.new("TextButton")
			rb.BackgroundColor3 = C.SurfaceAlt
			rb.BackgroundTransparency = 0.2
			rb.Size = UDim2.new(1, 0, 0, 34)
			rb.Text = ""
			rb.AutoButtonColor = false
			rb.ZIndex = 83
			rb.Parent = cmdResults
			corner(rb, 12)

			local iconL = Instance.new("TextLabel")
			noHit(iconL)
			iconL.BackgroundTransparency = 1
			iconL.Position = UDim2.new(0, 8, 0, 0)
			iconL.Size = UDim2.new(0, 22, 1, 0)
			iconL.Font = Enum.Font.GothamBold
			iconL.TextSize = 14
			iconL.Text = elem.Type == "Toggle" and "T" or elem.Type == "Slider" and "S" or elem.Type == "Dropdown" and "D" or elem.Type == "Button" and "B" or elem.Type == "Input" and "I" or elem.Type == "Keybind" and "K" or "?"
			iconL.TextColor3 = C.Dim
			iconL.ZIndex = 84
			iconL.Parent = rb

			local nl = Instance.new("TextLabel")
			noHit(nl)
			nl.Name = "ElemName"
			nl.BackgroundTransparency = 1
			nl.Position = UDim2.new(0, 34, 0, 0)
			nl.Size = UDim2.new(0.5, -34, 1, 0)
			nl.Font = Enum.Font.GothamBold
			nl.TextSize = 13
			nl.Text = elem.Name
			nl.TextColor3 = C.Text
			nl.TextXAlignment = Enum.TextXAlignment.Left
			nl.ZIndex = 84
			nl.Parent = rb

			local ml = Instance.new("TextLabel")
			noHit(ml)
			ml.BackgroundTransparency = 1
			ml.Position = UDim2.new(0.5, 0, 0, 0)
			ml.Size = UDim2.new(0.5, -16, 1, 0)
			ml.Font = Enum.Font.GothamMedium
			ml.TextSize = 10
			ml.Text = elem.Tab .. " / " .. (elem.SubTab or elem.Group or "") .. " / " .. elem.Type
			ml.TextColor3 = C.Dim
			ml.TextXAlignment = Enum.TextXAlignment.Right
			ml.ZIndex = 84
			ml.Parent = rb

			rb.MouseEnter:Connect(function()
				tw(rb, 0.12, {BackgroundTransparency = 0.02})
				playSound(Sounds.hover, 0.03, 1.4)
			end)
			rb.MouseLeave:Connect(function()
				tw(rb, 0.12, {BackgroundTransparency = 0.2})
			end)
			rb.MouseButton1Click:Connect(function()
				playSound(Sounds.sel, 0.1, 1.0)
				for _, tab in pairs(W.Tabs) do
					if tab.Name == elem.Tab and tab._select then
						tab._select()
						if elem.SubTab then
							task.delay(0.1, function()
								for _, st in pairs(tab.SubTabs or {}) do
									if st.Name == elem.SubTab and st._select then
										st._select()
										break
									end
								end
							end)
						end
						if elem._card and elem._card.Parent then
							task.delay(0.2, function()
								tw(elem._card, 0.15, {BackgroundColor3 = C.Accent})
								task.delay(0.5, function()
									if elem._card and elem._card.Parent then
										tw(elem._card, 0.4, {BackgroundColor3 = C.SurfaceAlt})
									end
								end)
							end)
						end
						break
					end
				end
				closeCmd()
			end)
		end

		local targetH = math.min(400, 56 + totalElems * 38 + 20)
		tw(cmdFrame, 0.35, {Size = UDim2.new(0, 500, 0, targetH)}, Enum.EasingStyle.Back)
		cmdBox:CaptureFocus()
		cmdBox.Text = ""
	end

	closeCmd = function()
		if not cmdOpen then return end
		cmdOpen = false
		playSound(Sounds.collapse, 0.08, 1.2)
		tw(cmdFrame, 0.22, {Size = UDim2.new(0, 500, 0, 56)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.28, function()
			cmdFrame.Visible = false
			cmdOverlay.Visible = false
		end)
	end

	cmdOverlay.MouseButton1Click:Connect(closeCmd)

	cmdBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = cmdBox.Text:lower()
		for _, ch in pairs(cmdResults:GetChildren()) do
			if ch:IsA("TextButton") then
				local nl = ch:FindFirstChild("ElemName")
				if nl then
					ch.Visible = (query == "" or nl.Text:lower():find(query, 1, true) ~= nil)
				end
			end
		end
		local visCount = 0
		for _, ch in pairs(cmdResults:GetChildren()) do
			if ch:IsA("TextButton") and ch.Visible then visCount = visCount + 1 end
		end
		local targetH = math.min(400, 56 + visCount * 38 + 20)
		tw(cmdFrame, 0.2, {Size = UDim2.new(0, 500, 0, targetH)}, Enum.EasingStyle.Quint)
	end)

	searchBox.Focused:Connect(function()
		searchBox:ReleaseFocus()
		openCmd()
	end)

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			if cmdOpen then closeCmd() else openCmd() end
		end
		if input.KeyCode == Enum.KeyCode.Escape and cmdOpen then
			closeCmd()
		end
	end))

	function W:CreateTab(tc)
		tc = tc or {}
		local Tab = {
			Name = tc.Name or "Tab",
			Icon = tc.Icon or "circle",
			Groups = {},
			SubTabs = {},
			ActiveSubTab = nil,
			_select = nil,
		}
		local accent = tc.Accent or C.Accent
		local tabIndex = #W.Tabs + 1
		W.Tabs[tabIndex] = Tab

		local sBtn = Instance.new("TextButton")
		sBtn.BackgroundColor3 = C.SidebarActive
		sBtn.BackgroundTransparency = 1
		sBtn.Size = UDim2.new(1, -12, 0, math.floor(44 * SC))
		sBtn.Text = ""
		sBtn.AutoButtonColor = false
		sBtn.LayoutOrder = tabIndex
		sBtn.ZIndex = 27
		sBtn.Parent = sideScroll
		corner(sBtn, 12)

		local sIcon
		local sIconIsImage = false
		local sIconAsset = getIconAsset(tc.Icon)
		if sIconAsset then
			sIconIsImage = true
			sIcon = Instance.new("ImageLabel")
			noHit(sIcon)
			sIcon.BackgroundTransparency = 1
			sIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			sIcon.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2) - 3, 0.5, 0)
			sIcon.Size = UDim2.new(0, math.floor(20 * SC), 0, math.floor(20 * SC))
			sIcon.Image = sIconAsset
			sIcon.ImageColor3 = C.Dim
			sIcon.ScaleType = Enum.ScaleType.Fit
			sIcon.ZIndex = 28
		else
			sIcon = Instance.new("TextLabel")
			noHit(sIcon)
			sIcon.BackgroundTransparency = 1
			sIcon.Position = UDim2.new(0, 0, 0, 0)
			sIcon.Size = UDim2.new(0, math.floor(SIDEBAR_W - 12), 1, 0)
			sIcon.Font = Enum.Font.GothamBold
			sIcon.TextSize = FONT_ICON_SIDEBAR
			sIcon.Text = getIcon(tc.Icon)
			sIcon.TextColor3 = C.Dim
			sIcon.ZIndex = 28
		end
		sIcon.Parent = sBtn

		local sLabel = Instance.new("TextLabel")
		noHit(sLabel)
		sLabel.BackgroundTransparency = 1
		sLabel.Position = UDim2.new(0, math.floor(SIDEBAR_W - 12), 0, 0)
		sLabel.Size = UDim2.new(1, -math.floor(SIDEBAR_W - 12), 1, 0)
		sLabel.Font = Enum.Font.GothamBold
		sLabel.TextSize = FONT_SIDEBAR_LABEL
		sLabel.Text = tc.Name or "Tab"
		sLabel.TextColor3 = C.Sub
		sLabel.TextXAlignment = Enum.TextXAlignment.Left
		sLabel.TextTransparency = 1
		sLabel.Visible = false
		sLabel.ZIndex = 28
		sLabel.Parent = sBtn
		_allSideLabels[#_allSideLabels + 1] = {label = sLabel}

		local indicator = Instance.new("Frame")
		noHit(indicator)
		indicator.AnchorPoint = Vector2.new(0, 0.5)
		indicator.BackgroundColor3 = accent
		indicator.BackgroundTransparency = 1
		indicator.Position = UDim2.new(0, 2, 0.5, 0)
		indicator.Size = UDim2.new(0, 3, 0, 0)
		indicator.ZIndex = 29
		indicator.Parent = sBtn
		corner(indicator, 2)

		sBtn.MouseEnter:Connect(function()
			if W.ActiveTab ~= Tab then
				tw(sBtn, 0.14, {BackgroundTransparency = 0.75})
				tweenIconColor(sIcon, 0.14, C.Sub)
			end
			playSound(Sounds.hover, 0.04, 1.35)
		end)
		sBtn.MouseLeave:Connect(function()
			if W.ActiveTab ~= Tab then
				tw(sBtn, 0.14, {BackgroundTransparency = 1})
				tweenIconColor(sIcon, 0.14, C.Dim)
			end
		end)

		local tabFrame = Instance.new("Frame")
		tabFrame.Name = "TabFrame_" .. (tc.Name or "")
		tabFrame.BackgroundTransparency = 1
		tabFrame.Size = UDim2.new(1, 0, 1, 0)
		tabFrame.Visible = false
		tabFrame.ZIndex = 6
		tabFrame.Parent = content

		local subTabBar = Instance.new("Frame")
		noHit(subTabBar)
		subTabBar.BackgroundColor3 = C.SubTabBG
		subTabBar.BackgroundTransparency = 0.2
		subTabBar.Size = UDim2.new(1, 0, 0, SUBTAB_H)
		subTabBar.ZIndex = 15
		subTabBar.BorderSizePixel = 0
		subTabBar.Parent = tabFrame

		local subTabBotLine = Instance.new("Frame")
		noHit(subTabBotLine)
		subTabBotLine.BackgroundColor3 = C.Border
		subTabBotLine.BackgroundTransparency = 0.5
		subTabBotLine.Position = UDim2.new(0, 0, 1, -1)
		subTabBotLine.Size = UDim2.new(1, 0, 0, 1)
		subTabBotLine.ZIndex = 16
		subTabBotLine.Parent = subTabBar

		local subTabScroll = Instance.new("ScrollingFrame")
		subTabScroll.BackgroundTransparency = 1
		subTabScroll.Size = UDim2.new(1, -24, 1, 0)
		subTabScroll.Position = UDim2.new(0, 12, 0, 0)
		subTabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		subTabScroll.ScrollBarThickness = 0
		subTabScroll.ZIndex = 16
		subTabScroll.Parent = subTabBar
		local subTabLayout = uiList(subTabScroll, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		subTabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			-- divide by UIScale: AbsoluteContentSize is scaled px, CanvasSize is local space
			subTabScroll.CanvasSize = UDim2.new(0, subTabLayout.AbsoluteContentSize.X / math.max(uiScaleObj.Scale, 0.01) + 24, 0, 0)
		end)

		local contentScroll = Instance.new("ScrollingFrame")
		contentScroll.BackgroundTransparency = 1
		contentScroll.Position = UDim2.new(0, 0, 0, SUBTAB_H)
		contentScroll.Size = UDim2.new(1, 0, 1, -SUBTAB_H)
		contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		contentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
		contentScroll.ScrollBarThickness = 3
		contentScroll.ScrollBarImageColor3 = C.Border
		contentScroll.ZIndex = 7
		contentScroll.Parent = tabFrame
		pad(contentScroll, 14, 50, 14, 14)

		local contentLayout = uiList(contentScroll, 14)

		local function selectTab()
			if W.ActiveTab == Tab then return end
			for _, t in pairs(W.Tabs) do
				if t ~= Tab and t._frame then t._frame.Visible = false end
				if t._sideBtn then
					tw(t._sideBtn, 0.15, {BackgroundTransparency = 1})
					tweenIconColor(t._sideIcon, 0.15, C.Dim)
					if t._indicator then
						tw(t._indicator, 0.18, {BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 0)})
					end
				end
			end
			W.ActiveTab = Tab
			tabFrame.Visible = true
			tw(sBtn, 0.2, {BackgroundTransparency = 0.5})
			tweenIconColor(sIcon, 0.2, accent)
			springBounce(indicator, "Size", UDim2.new(0, 3, 0, 22), 6)
			tw(indicator, 0.28, {BackgroundTransparency = 0.15})
			playSound(Sounds.sel, 0.1, 1.0)
			staggerIn(contentScroll)
		end

		Tab._frame = tabFrame
		Tab._sideBtn = sBtn
		Tab._sideIcon = sIcon
		Tab._indicator = indicator
		Tab._select = selectTab
		Tab._contentScroll = contentScroll
		Tab._subTabScroll = subTabScroll
		Tab._accent = accent
		sBtn.MouseButton1Click:Connect(selectTab)
		if tabIndex == 1 then task.defer(selectTab) end

		function Tab:CreateSubTab(stc)
			stc = stc or {}
			local ST = {
				Name = stc.Name or "SubTab",
				_select = nil,
				_contentFrame = nil,
			}
			local stIndex = #Tab.SubTabs + 1
			Tab.SubTabs[stIndex] = ST

			local stBtn = Instance.new("TextButton")
			stBtn.BackgroundColor3 = C.SubTabActive
			stBtn.BackgroundTransparency = 1
			stBtn.Size = UDim2.new(0, 0, 0, math.floor(28 * SC))
			stBtn.AutomaticSize = Enum.AutomaticSize.X
			stBtn.Text = ""
			stBtn.AutoButtonColor = false
			stBtn.LayoutOrder = stIndex
			stBtn.ZIndex = 17
			stBtn.Parent = subTabScroll
			corner(stBtn, 10)
			pad(stBtn, 0, 0, 14, 14)

			local stLabel = Instance.new("TextLabel")
			noHit(stLabel)
			stLabel.BackgroundTransparency = 1
			stLabel.Size = UDim2.new(0, 0, 1, 0)
			stLabel.AutomaticSize = Enum.AutomaticSize.X
			stLabel.Font = Enum.Font.GothamBold
			stLabel.TextSize = FONT_SUBTAB
			stLabel.Text = stc.Name or "SubTab"
			stLabel.TextColor3 = C.Dim
			stLabel.ZIndex = 18
			stLabel.Parent = stBtn

			local stIndicator = Instance.new("Frame")
			noHit(stIndicator)
			stIndicator.AnchorPoint = Vector2.new(0.5, 1)
			stIndicator.BackgroundColor3 = accent
			stIndicator.BackgroundTransparency = 1
			stIndicator.Position = UDim2.new(0.5, 0, 1, 0)
			stIndicator.Size = UDim2.new(0.6, 0, 0, 2)
			stIndicator.ZIndex = 18
			stIndicator.Parent = stBtn
			corner(stIndicator, 1)

			local stContent = Instance.new("Frame")
			noHit(stContent)
			stContent.BackgroundTransparency = 1
			stContent.Size = UDim2.new(1, 0, 0, 0)
			stContent.AutomaticSize = Enum.AutomaticSize.Y
			stContent.LayoutOrder = stIndex
			stContent.Visible = false
			stContent.ZIndex = 7
			stContent.Parent = contentScroll

			local stContentLayout = uiList(stContent, 14)
			ST._contentFrame = stContent

			local function selectSubTab()
				if Tab.ActiveSubTab == ST then return end
				for _, ost in pairs(Tab.SubTabs) do
					if ost ~= ST and ost._contentFrame then
						ost._contentFrame.Visible = false
					end
					if ost._btn then
						tw(ost._btn, 0.15, {BackgroundTransparency = 1})
						if ost._label then tw(ost._label, 0.15, {TextColor3 = C.Dim}) end
						if ost._indicator then tw(ost._indicator, 0.15, {BackgroundTransparency = 1}) end
					end
				end
				Tab.ActiveSubTab = ST
				stContent.Visible = true
				tw(stBtn, 0.2, {BackgroundTransparency = 0.5})
				tw(stLabel, 0.2, {TextColor3 = C.Text})
				tw(stIndicator, 0.2, {BackgroundTransparency = 0.15})
				playSound(Sounds.sel, 0.06, 1.15)
				staggerIn(stContent)
			end

			ST._select = selectSubTab
			ST._btn = stBtn
			ST._label = stLabel
			ST._indicator = stIndicator

			stBtn.MouseEnter:Connect(function()
				if Tab.ActiveSubTab ~= ST then
					tw(stBtn, 0.12, {BackgroundTransparency = 0.7})
					tw(stLabel, 0.12, {TextColor3 = C.Sub})
				end
				playSound(Sounds.hover, 0.03, 1.4)
			end)
			stBtn.MouseLeave:Connect(function()
				if Tab.ActiveSubTab ~= ST then
					tw(stBtn, 0.12, {BackgroundTransparency = 1})
					tw(stLabel, 0.12, {TextColor3 = C.Dim})
				end
			end)
			stBtn.MouseButton1Click:Connect(selectSubTab)

			if stIndex == 1 then task.defer(selectSubTab) end

			function ST:CreateGroup(gc)
				gc = gc or {}
				return Tab:_createGroupInternal(gc, stContent, ST.Name)
			end

			return ST
		end

		function Tab:_createGroupInternal(gc, parentScroll, subTabName)
			gc = gc or {}
			local groupOrder = #Tab.Groups + 1
			Tab.Groups[groupOrder] = gc
			local G = {}
			local useBento = gc.BentoGrid == true

			local groupFrame = Instance.new("Frame")
			groupFrame.Name = gc.Name or "Group"
			groupFrame.BackgroundColor3 = C.Surface
			groupFrame.BackgroundTransparency = 0.15
			groupFrame.Size = UDim2.new(1, 0, 0, 0)
			groupFrame.AutomaticSize = Enum.AutomaticSize.Y
			groupFrame.LayoutOrder = groupOrder
			groupFrame.ClipsDescendants = true
			groupFrame.ZIndex = 8
			groupFrame.Parent = parentScroll
			corner(groupFrame, 18)
			addClayShadow(groupFrame, 18)
			addClayHighlight(groupFrame)
			strokeInst(groupFrame, C.Border, 1, 0.55)

			local header = Instance.new("Frame")
			noHit(header)
			header.BackgroundTransparency = 1
			header.Size = UDim2.new(1, 0, 0, math.floor(38 * SC))
			header.ClipsDescendants = true
			header.ZIndex = 10
			header.Parent = groupFrame
			corner(header, 18)

			local hasIcon = gc.Icon ~= nil and gc.Icon ~= ""
			local labelX = hasIcon and 44 or 16

			if hasIcon then
				local hIconAsset = getIconAsset(gc.Icon)
				if hIconAsset then
					local hImgIcon = Instance.new("ImageLabel")
					noHit(hImgIcon)
					hImgIcon.BackgroundTransparency = 1
					hImgIcon.Position = UDim2.new(0, 16, 0.5, 0)
					hImgIcon.AnchorPoint = Vector2.new(0, 0.5)
					hImgIcon.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
					hImgIcon.Image = hIconAsset
					hImgIcon.ImageColor3 = accent
					hImgIcon.ScaleType = Enum.ScaleType.Fit
					hImgIcon.ZIndex = 11
					hImgIcon.Parent = header
				else
					local hIcon = Instance.new("TextLabel")
					noHit(hIcon)
					hIcon.BackgroundTransparency = 1
					hIcon.Position = UDim2.new(0, 16, 0, 0)
					hIcon.Size = UDim2.new(0, 24, 1, 0)
					hIcon.Font = Enum.Font.GothamBold
					hIcon.TextSize = FONT_SECTION_ICON
					hIcon.Text = getIcon(gc.Icon)
					hIcon.TextColor3 = accent
					hIcon.ZIndex = 11
					hIcon.Parent = header
				end
			end

			local hLabel = Instance.new("TextLabel")
			noHit(hLabel)
			hLabel.BackgroundTransparency = 1
			hLabel.Position = UDim2.new(0, labelX, 0, 0)
			hLabel.Size = UDim2.new(1, -(labelX + 16), 1, 0)
			hLabel.Font = Enum.Font.GothamBold
			hLabel.TextSize = FONT_SECTION
			hLabel.Text = gc.Name or "Group"
			hLabel.TextColor3 = C.Text
			hLabel.TextXAlignment = Enum.TextXAlignment.Left
			hLabel.ZIndex = 11
			hLabel.Parent = header
			addShimmer(header, accent)

			local gContent = Instance.new("Frame")
			noHit(gContent)
			gContent.BackgroundTransparency = 1
			gContent.Position = UDim2.new(0, 0, 0, math.floor(38 * SC))
			gContent.Size = UDim2.new(1, 0, 0, 0)
			gContent.AutomaticSize = Enum.AutomaticSize.Y
			gContent.ZIndex = 8
			gContent.Parent = groupFrame

			if useBento then
				uiGrid(gContent, gc.GridCellWidth or math.floor(230 * SC), gc.GridCellHeight or math.floor(52 * SC), 8)
				pad(gContent, 4, 14, 14, 14)
			else
				uiList(gContent, 6)
				pad(gContent, 4, 14, 14, 14)
			end

			local elemOrder = 0
			local function gNext()
				elemOrder = elemOrder + 1
				return elemOrder
			end

			local function createCard(height, opts)
				opts = opts or {}
				local card = Instance.new("TextButton")
				card.BackgroundColor3 = C.SurfaceAlt
				card.BackgroundTransparency = 0.12
				card.Size = UDim2.new(1, 0, 0, height or math.floor(44 * SC))
				card.LayoutOrder = gNext()
				card.ClipsDescendants = true
				card.Active = true
				card.Text = ""
				card.AutoButtonColor = false
				card.ZIndex = 9
				card.Parent = gContent
				corner(card, 14)
				if not opts.noShadow then
					addClayShadow(card, 14)
				end
				strokeInst(card, C.Border, 1, 0.6)
				addHoverLift(card, 2)
				return card
			end

			-- Clay-style shadow with a FIXED height (width still hugs the card). Used for
			-- text cards whose height grows via AutomaticSize: the shadow stays the same
			-- compact size as a normal ~44px card instead of stretching with the text.
			-- Center-anchored so it stays put; scale-sized on X so it never inflates the
			-- card's AutomaticSize.
			local function addFixedShadow(card)
				local h1 = math.floor(56 * SC)
				local h2 = math.floor(72 * SC)

				local shadow = Instance.new("ImageLabel")
				noHit(shadow)
				shadow.AnchorPoint = Vector2.new(0.5, 0.5)
				shadow.BackgroundTransparency = 1
				shadow.Position = UDim2.new(0.5, 3, 0.5, 3)
				shadow.Size = UDim2.new(1, 12, 0, h1)
				shadow.ZIndex = card.ZIndex - 1
				shadow.Image = "rbxassetid://6014261993"
				shadow.ImageColor3 = C.ClayShadow
				shadow.ImageTransparency = 0.35
				shadow.ScaleType = Enum.ScaleType.Slice
				shadow.SliceCenter = Rect.new(49, 49, 450, 450)
				shadow.Parent = card

				local shadow2 = Instance.new("ImageLabel")
				noHit(shadow2)
				shadow2.AnchorPoint = Vector2.new(0.5, 0.5)
				shadow2.BackgroundTransparency = 1
				shadow2.Position = UDim2.new(0.5, 5, 0.5, 6)
				shadow2.Size = UDim2.new(1, 28, 0, h2)
				shadow2.ZIndex = card.ZIndex - 2
				shadow2.Image = "rbxassetid://6014261993"
				shadow2.ImageColor3 = C.ClayShadowDeep
				shadow2.ImageTransparency = 0.55
				shadow2.ScaleType = Enum.ScaleType.Slice
				shadow2.SliceCenter = Rect.new(49, 49, 450, 450)
				shadow2.Parent = card
			end

			function G:CreateToggle(tc2)
				tc2 = tc2 or {}
				local toggled = tc2.Default or false
				-- Key this toggle is tracked under in the Active panel (matches updateToggle).
				local activeKey = tc2.Name or tc2.Flag
				-- HideFromActive (alias: ShowInActive = false) keeps the toggle out of the
				-- Active Features panel while still working/counting normally.
				if activeKey and (tc2.HideFromActive or tc2.ShowInActive == false) then
					W._activeHidden[activeKey] = true
				end
				local cH = math.floor(44 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(1, -80, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card
				local tIconAsset = tc2.Icon and getIconAsset(tc2.Icon)
				if tIconAsset then
					nL.Position = UDim2.new(0, 36, 0, 0)
					nL.Size = UDim2.new(1, -116, 1, 0)
					nL.Text = tc2.Name or "Toggle"
					local tImg = Instance.new("ImageLabel")
					noHit(tImg)
					tImg.BackgroundTransparency = 1
					tImg.AnchorPoint = Vector2.new(0, 0.5)
					tImg.Position = UDim2.new(0, 14, 0.5, 0)
					tImg.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
					tImg.Image = tIconAsset
					tImg.ImageColor3 = accent
					tImg.ScaleType = Enum.ScaleType.Fit
					tImg.ZIndex = 11
					tImg.Parent = card
				else
					nL.Text = tc2.Name or "Toggle"
				end

				local tW = math.floor(42 * SC)
				local tH = math.floor(24 * SC)
				local kD = math.floor(18 * SC)

				local tBg = Instance.new("Frame")
				noHit(tBg)
				tBg.AnchorPoint = Vector2.new(1, 0.5)
				tBg.BackgroundColor3 = C.TrackOff
				tBg.Position = UDim2.new(1, -16, 0.5, 0)
				tBg.Size = UDim2.new(0, tW, 0, tH)
				tBg.ZIndex = 11
				tBg.Parent = card
				corner(tBg, math.floor(tH / 2))
				strokeInst(tBg, C.Border, 1, 0.5)

				local fill = Instance.new("Frame")
				noHit(fill)
				fill.BackgroundColor3 = accent
				fill.BackgroundTransparency = 1
				fill.Size = UDim2.new(1, 0, 1, 0)
				fill.ZIndex = 10
				fill.Parent = tBg
				corner(fill, math.floor(tH / 2))

				local knob = Instance.new("Frame")
				noHit(knob)
				knob.AnchorPoint = Vector2.new(0, 0.5)
				knob.BackgroundColor3 = C.Dim
				knob.Position = UDim2.new(0, 3, 0.5, 0)
				knob.Size = UDim2.new(0, kD, 0, kD)
				knob.ZIndex = 12
				knob.Parent = tBg
				corner(knob, math.floor(kD / 2))

				local function updateToggle(animate, suppressCallback)
					if toggled then
						if animate ~= false then
							tw(fill, 0.3, {BackgroundTransparency = 0.08})
							springBounce(knob, "Position", UDim2.new(1, -kD - 3, 0.5, 0), 5)
							tw(knob, 0.3, {BackgroundColor3 = C.Text})
							tw(tBg, 0.3, {BackgroundColor3 = accent})
						else
							fill.BackgroundTransparency = 0.08
							knob.Position = UDim2.new(1, -kD - 3, 0.5, 0)
							knob.BackgroundColor3 = C.Text
							tBg.BackgroundColor3 = accent
						end
					else
						if animate ~= false then
							tw(fill, 0.3, {BackgroundTransparency = 1})
							springBounce(knob, "Position", UDim2.new(0, 3, 0.5, 0), 5)
							tw(knob, 0.3, {BackgroundColor3 = C.Dim})
							tw(tBg, 0.3, {BackgroundColor3 = C.TrackOff})
						else
							fill.BackgroundTransparency = 1
							knob.Position = UDim2.new(0, 3, 0.5, 0)
							knob.BackgroundColor3 = C.Dim
							tBg.BackgroundColor3 = C.TrackOff
						end
					end
					if tc2.Flag then
						W._activeFeatures[tc2.Name or tc2.Flag] = toggled
						updateActivePanel()
						W.Config:Set(tc2.Flag, toggled)
					end
					if tc2.Callback and not suppressCallback then task.spawn(tc2.Callback, toggled) end
				end

				card.MouseButton1Click:Connect(function()
					toggled = not toggled
					playSound(Sounds.toggle, 0.1, toggled and 1.15 or 0.9)
					createRipple(card, accent)
					updateToggle()
				end)

				if toggled then task.defer(function() updateToggle(false, true) end) end

				local elemData = {Name = tc2.Name or "Toggle", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Toggle", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback)
					toggled = v
					updateToggle(nil, noCallback)
				end
				function api:Get() return toggled end
				-- Runtime control over this toggle's presence in the Active panel.
				function api:SetHiddenFromActive(hidden)
					if not activeKey then return end
					W._activeHidden[activeKey] = hidden and true or nil
					updateActivePanel()
				end
				function api:IsHiddenFromActive() return activeKey ~= nil and W._activeHidden[activeKey] == true end
				api._cb = tc2.Callback
				if tc2.Flag then W._flags[tc2.Flag] = api; W.Config:Register(tc2.Flag, api) end
				return api
			end

			function G:CreateSlider(sc2)
				sc2 = sc2 or {}
				local min = sc2.Min or 0
				local max = sc2.Max or 100
				local increment = sc2.Increment or 1
				local value = math.clamp(sc2.Default or min, min, max)
				local suffix = sc2.Suffix or ""
				local cH = math.floor(64 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 4)
				nL.Size = UDim2.new(0.55, -16, 0, 20)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card
				local slImgAsset = sc2.Icon and getIconAsset(sc2.Icon)
				if slImgAsset then
					nL.Position = UDim2.new(0, 36, 0, 4)
					nL.Size = UDim2.new(0.5, -36, 0, 20)
					nL.Text = sc2.Name or "Slider"
					local slI = Instance.new("ImageLabel")
					noHit(slI)
					slI.BackgroundTransparency = 1
					slI.AnchorPoint = Vector2.new(0, 0.5)
					slI.Position = UDim2.new(0, 14, 0, 14)
					slI.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
					slI.Image = slImgAsset
					slI.ImageColor3 = accent
					slI.ScaleType = Enum.ScaleType.Fit
					slI.ZIndex = 11
					slI.Parent = card
				else
					nL.Text = sc2.Name or "Slider"
				end

				local vL = Instance.new("TextLabel")
				noHit(vL)
				vL.BackgroundTransparency = 1
				vL.AnchorPoint = Vector2.new(1, 0)
				vL.Position = UDim2.new(1, -16, 0, 4)
				vL.Size = UDim2.new(0.45, -16, 0, 20)
				vL.Font = Enum.Font.GothamBold
				vL.TextSize = FONT_ELEM_VALUE
				vL.Text = tostring(value) .. suffix
				vL.TextColor3 = accent
				vL.TextXAlignment = Enum.TextXAlignment.Right
				vL.ZIndex = 10
				vL.Parent = card

				local trackHeight = math.floor(8 * SC)
				local tBg = Instance.new("Frame")
				noHit(tBg)
				tBg.BackgroundColor3 = C.TrackOff
				tBg.Position = UDim2.new(0, 16, 0, 30)
				tBg.Size = UDim2.new(1, -32, 0, trackHeight)
				tBg.ZIndex = 10
				tBg.Parent = card
				corner(tBg, math.floor(4 * SC))
				strokeInst(tBg, C.Border, 1, 0.55)

				local tFill = Instance.new("Frame")
				noHit(tFill)
				tFill.BackgroundColor3 = accent
				tFill.Size = UDim2.new(0, 0, 1, 0)
				tFill.ZIndex = 11
				tFill.Parent = tBg
				corner(tFill, math.floor(4 * SC))

				local tFillGrad = Instance.new("UIGradient")
				tFillGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor(accent, C.Text, 0.25)),
					ColorSequenceKeypoint.new(1, accent),
				})
				tFillGrad.Parent = tFill

				local kS = math.floor(18 * SC)
				local knob = Instance.new("Frame")
				noHit(knob)
				knob.AnchorPoint = Vector2.new(0.5, 0.5)
				knob.BackgroundColor3 = C.Text
				knob.Position = UDim2.new(0, 0, 0.5, 0)
				knob.Size = UDim2.new(0, kS, 0, kS)
				knob.ZIndex = 13
				knob.Parent = tBg
				corner(knob, math.floor(kS / 2))
				addClayShadow(knob, math.floor(kS / 2))

				local tooltip = Instance.new("TextLabel")
				noHit(tooltip)
				tooltip.AnchorPoint = Vector2.new(0.5, 1)
				tooltip.BackgroundColor3 = C.Surface
				tooltip.BackgroundTransparency = 0.05
				tooltip.Position = UDim2.new(0.5, 0, 0, -4)
				tooltip.Size = UDim2.new(0, 48, 0, 20)
				tooltip.Font = Enum.Font.GothamBold
				tooltip.TextSize = math.floor(10 * SC)
				tooltip.Text = tostring(value)
				tooltip.TextColor3 = C.Text
				tooltip.Visible = false
				tooltip.ZIndex = 20
				tooltip.Parent = knob
				corner(tooltip, 6)
				strokeInst(tooltip, C.Border, 1, 0.5)

				local function updateVisual(val, suppressCallback)
					value = val
					local pct = (value - min) / (max - min)
					tFill.Size = UDim2.new(pct, 0, 1, 0)
					knob.Position = UDim2.new(pct, 0, 0.5, 0)
					vL.Text = tostring(value) .. suffix
					tooltip.Text = tostring(value)
					if sc2.Flag then W.Config:Set(sc2.Flag, value) end
					if sc2.Callback and not suppressCallback then task.spawn(sc2.Callback, value) end
				end
				updateVisual(value, true) -- initial render must not fire the callback

				local sliderDragging = false

				local function processInput(input)
					local absPos = tBg.AbsolutePosition
					local absSize = tBg.AbsoluteSize
					local relX = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
					local raw = min + (max - min) * relX
					local stepped = math.floor(raw / increment + 0.5) * increment
					stepped = math.clamp(stepped, min, max)
					if increment < 1 then
						stepped = tonumber(string.format("%." .. tostring(math.ceil(-math.log10(increment))) .. "f", stepped))
					end
					if stepped ~= value then
						updateVisual(stepped)
						playSound(Sounds.slide, 0.03, 0.9 + relX * 0.3)
					end
				end

				local hitSlider = Instance.new("TextButton")
				hitSlider.BackgroundTransparency = 1
				hitSlider.Text = ""
				hitSlider.Position = UDim2.new(0, 0, 0, 24)
				hitSlider.Size = UDim2.new(1, 0, 0, cH - 24)
				hitSlider.ZIndex = 14
				hitSlider.AutoButtonColor = false
				hitSlider.Parent = card

				hitSlider.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						sliderDragging = true
						tooltip.Visible = true
						card.ClipsDescendants = false
						card.ZIndex = 20
						tw(knob, 0.12, {Size = UDim2.new(0, kS + 8, 0, kS + 8), BackgroundColor3 = accent})
						tw(tFill, 0.1, {BackgroundTransparency = 0})
						processInput(input)
					end
				end)

				trackConn(UserInputService.InputChanged:Connect(function(input)
					if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						processInput(input)
					end
				end))

				trackConn(UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if sliderDragging then
							sliderDragging = false
							tooltip.Visible = false
							card.ClipsDescendants = true
							card.ZIndex = 9
							tw(knob, 0.2, {Size = UDim2.new(0, kS, 0, kS), BackgroundColor3 = C.Text})
						end
					end
				end))

				local elemData = {Name = sc2.Name or "Slider", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Slider", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback) updateVisual(math.clamp(v, min, max), noCallback) end
				function api:Get() return value end
				api._cb = sc2.Callback
				if sc2.Flag then W._flags[sc2.Flag] = api; W.Config:Register(sc2.Flag, api) end
				return api
			end

			function G:CreateDropdown(dc)
				dc = dc or {}
				local options = dc.Options or {}
				local multi = dc.Multi or false
				local selected, selectedSet
				if multi then
					selectedSet = {}
					if type(dc.Default) == "table" then
						selected = {}
						for _, v in ipairs(dc.Default) do selected[#selected+1] = v; selectedSet[v] = true end
					elseif dc.Default then
						selected = {dc.Default}; selectedSet[dc.Default] = true
					else
						selected = {}
					end
				else
					selected = dc.Default or (options[1] or "")
				end

				local function displayText()
					if multi then
						if #selected == 0 then return "None" end
						if #selected == 1 then return selected[1] end
						return selected[1] .. " +" .. (#selected - 1)
					end
					return tostring(selected)
				end

				local cH = math.floor(44 * SC)
				local card = createCard(cH)
				local expanded = false

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.5, -16, 0, cH)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = dc.Name or "Dropdown"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local vL = Instance.new("TextLabel")
				noHit(vL)
				vL.AnchorPoint = Vector2.new(1, 0.5)
				vL.BackgroundColor3 = C.AccentSub
				vL.BackgroundTransparency = 0.35
				vL.Position = UDim2.new(1, -16, 0, math.floor(cH / 2))
				vL.Size = UDim2.new(0, math.floor(120 * SC), 0, math.floor(28 * SC))
				vL.Font = Enum.Font.GothamBold
				vL.TextSize = FONT_ELEM_VALUE
				vL.Text = displayText()
				vL.TextColor3 = accent
				vL.TextXAlignment = Enum.TextXAlignment.Left
				vL.ZIndex = 10
				vL.Parent = card
				corner(vL, 10)
				strokeInst(vL, C.Border, 1, 0.5)

				local vLPad = Instance.new("UIPadding")
				vLPad.PaddingLeft = UDim.new(0, 8)
				vLPad.PaddingRight = UDim.new(0, 24)
				vLPad.Parent = vL

				local ddArrow = Instance.new("ImageLabel")
				noHit(ddArrow)
				ddArrow.BackgroundTransparency = 1
				ddArrow.AnchorPoint = Vector2.new(1, 0.5)
				ddArrow.Position = UDim2.new(1, 14, 0.5, 0)
				ddArrow.Size = UDim2.new(0, math.floor(12 * SC), 0, math.floor(12 * SC))
				ddArrow.Image = getIconAsset("expand_more") or "rbxassetid://6031094687"
				ddArrow.ImageColor3 = accent
				ddArrow.ScaleType = Enum.ScaleType.Fit
				ddArrow.ZIndex = 11
				ddArrow.Rotation = 0
				ddArrow.Parent = vL

				local optList = Instance.new("Frame")
				noHit(optList)
				optList.BackgroundTransparency = 1
				optList.Position = UDim2.new(0, 8, 0, cH + 2)
				optList.Size = UDim2.new(1, -16, 0, 0)
				optList.ClipsDescendants = true
				optList.ZIndex = 12
				optList.Parent = card
				local optLayout = uiList(optList, 2)

				local function isSel(opt)
					if multi then return selectedSet[opt] == true end
					return opt == selected
				end

				local function buildOptions()
					for _, ch in pairs(optList:GetChildren()) do
						if ch:IsA("TextButton") then ch:Destroy() end
					end
					for i, opt in ipairs(options) do
						local sel = isSel(opt)
						local ob = Instance.new("TextButton")
						ob.BackgroundColor3 = sel and C.AccentSub or C.SurfaceAlt
						ob.BackgroundTransparency = sel and 0.2 or 0.5
						ob.Size = UDim2.new(1, 0, 0, math.floor(28 * SC))
						ob.Text = ""
						ob.AutoButtonColor = false
						ob.LayoutOrder = i
						ob.ZIndex = 14
						ob.Parent = optList
						corner(ob, 8)

						local xOff = multi and 28 or 10
						local ol = Instance.new("TextLabel")
						noHit(ol)
						ol.BackgroundTransparency = 1
						ol.Position = UDim2.new(0, xOff, 0, 0)
						ol.Size = UDim2.new(1, -(xOff + 10), 1, 0)
						ol.Font = sel and Enum.Font.GothamBold or Enum.Font.GothamMedium
						ol.TextSize = FONT_ELEM_VALUE
						ol.Text = opt
						ol.TextColor3 = sel and accent or C.Sub
						ol.TextXAlignment = Enum.TextXAlignment.Left
						ol.ZIndex = 15
						ol.Parent = ob

						if multi then
							local chk = Instance.new("Frame")
							noHit(chk)
							chk.AnchorPoint = Vector2.new(0, 0.5)
							chk.Position = UDim2.new(0, 8, 0.5, 0)
							chk.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
							chk.BackgroundColor3 = sel and accent or C.SurfaceAlt
							chk.BackgroundTransparency = sel and 0 or 0.3
							chk.ZIndex = 16
							chk.Parent = ob
							corner(chk, 4)
							strokeInst(chk, sel and accent or C.Border, 1, 0.4)
							if sel then
								local cm = Instance.new("TextLabel")
								noHit(cm)
								cm.BackgroundTransparency = 1
								cm.Size = UDim2.new(1, 0, 1, 0)
								cm.Font = Enum.Font.GothamBold
								cm.TextSize = math.floor(10 * SC)
								cm.Text = "?"
								cm.TextColor3 = C.BG
								cm.ZIndex = 17
								cm.Parent = chk
							end
						end

						ob.MouseEnter:Connect(function() tw(ob, 0.1, {BackgroundTransparency = 0.1}) end)
						ob.MouseLeave:Connect(function() tw(ob, 0.1, {BackgroundTransparency = sel and 0.2 or 0.5}) end)

						ob.MouseButton1Click:Connect(function()
							if multi then
								if selectedSet[opt] then
									selectedSet[opt] = nil
									local ns = {}
									for _, v in ipairs(selected) do if v ~= opt then ns[#ns+1] = v end end
									selected = ns
								else
									selectedSet[opt] = true
									selected[#selected+1] = opt
								end
								vL.Text = displayText()
								playSound(Sounds.sel, 0.08, 1.1)
								buildOptions()
								if dc.Flag then W.Config:Set(dc.Flag, selected) end
								if dc.Callback then task.spawn(dc.Callback, selected) end
							else
								selected = opt
								vL.Text = displayText()
								playSound(Sounds.sel, 0.1, 1.0)
								if dc.Flag then W.Config:Set(dc.Flag, selected) end
								if dc.Callback then task.spawn(dc.Callback, selected) end
								expanded = false
								tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
								tw(optList, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
								tw(ddArrow, 0.15, {Rotation = 0})
								buildOptions()
							end
						end)
					end
				end
				buildOptions()

				card.MouseButton1Click:Connect(function()
					expanded = not expanded
					if expanded then
						playSound(Sounds.expand, 0.08, 1.15)
						local itemH = math.floor(28 * SC) + 2
						local listH = #options * itemH + 4
						tw(card, 0.25, {Size = UDim2.new(1, 0, 0, cH + listH + 6)}, Enum.EasingStyle.Quint)
						tw(optList, 0.25, {Size = UDim2.new(1, -16, 0, listH)}, Enum.EasingStyle.Quint)
						tw(ddArrow, 0.2, {Rotation = 180})
					else
						playSound(Sounds.collapse, 0.06, 1.2)
						tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
						tw(optList, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
						tw(ddArrow, 0.15, {Rotation = 0})
					end
				end)

				local elemData = {Name = dc.Name or "Dropdown", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Dropdown", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback)
					if multi then
						if type(v) == "table" then
							selected = v; selectedSet = {}
							for _, x in ipairs(v) do selectedSet[x] = true end
						end
					else
						selected = v
					end
					vL.Text = displayText()
					if dc.Flag then W.Config:Set(dc.Flag, selected) end
					if not noCallback and dc.Callback then task.spawn(dc.Callback, selected) end
					buildOptions()
				end
				function api:Get() return selected end
				function api:SetOptions(o)
					options = o
					if multi then
						local ns, nss = {}, {}
						for _, v in ipairs(selected) do
							for _, opt in ipairs(o) do if v == opt then ns[#ns+1] = v; nss[v] = true; break end end
						end
						selected = ns; selectedSet = nss
					else
						local f = false
						for _, opt in ipairs(o) do if opt == selected then f = true; break end end
						if not f then selected = o[1] or "" end
					end
					vL.Text = displayText()
					buildOptions()
				end
				api._cb = dc.Callback
				if dc.Flag then W._flags[dc.Flag] = api; W.Config:Register(dc.Flag, api) end
				return api
			end

			function G:CreateButton(bc)
				bc = bc or {}
				local cH = math.floor(44 * SC)
				local card = createCard(cH)
				addMagneticHover(card, 2)

				local bIcon = Instance.new("TextLabel")
				noHit(bIcon)
				bIcon.BackgroundTransparency = 1
				bIcon.Position = UDim2.new(0, 16, 0, 0)
				bIcon.Size = UDim2.new(0, 22, 1, 0)
				bIcon.Font = Enum.Font.GothamBold
				bIcon.TextSize = math.floor(15 * SC)
				bIcon.TextColor3 = accent
				bIcon.ZIndex = 10
				bIcon.Parent = card

				local bIconAsset = getIconAsset(bc.Icon)
				if bIconAsset then
					bIcon.Visible = false
					local bImgIcon = Instance.new("ImageLabel")
					noHit(bImgIcon)
					bImgIcon.BackgroundTransparency = 1
					bImgIcon.AnchorPoint = Vector2.new(0, 0.5)
					bImgIcon.Position = UDim2.new(0, 16, 0.5, 0)
					bImgIcon.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
					bImgIcon.Image = bIconAsset
					bImgIcon.ImageColor3 = accent
					bImgIcon.ScaleType = Enum.ScaleType.Fit
					bImgIcon.ZIndex = 11
					bImgIcon.Parent = card
				else
					bIcon.Text = getIcon(bc.Icon)
				end

				local bL = Instance.new("TextLabel")
				noHit(bL)
				bL.BackgroundTransparency = 1
				bL.Position = UDim2.new(0, 42, 0, 0)
				bL.Size = UDim2.new(1, -58, 1, 0)
				bL.Font = Enum.Font.GothamBold
				bL.TextSize = FONT_ELEM_NAME
				bL.Text = bc.Name or "Button"
				bL.TextColor3 = C.Text
				bL.TextXAlignment = Enum.TextXAlignment.Left
				bL.ZIndex = 10
				bL.Parent = card

				local arrow = Instance.new("TextLabel")
				noHit(arrow)
				arrow.AnchorPoint = Vector2.new(1, 0.5)
				arrow.BackgroundTransparency = 1
				arrow.Position = UDim2.new(1, -16, 0.5, 0)
				arrow.Size = UDim2.new(0, 20, 0, 20)
				arrow.Font = Enum.Font.GothamBold
				arrow.TextSize = 14
				arrow.Text = "\xE2\x86\x92"
				arrow.TextColor3 = C.Dim
				arrow.ZIndex = 10
				arrow.Parent = card

				card.MouseButton1Click:Connect(function()
					playSound(Sounds.click, 0.12, 1.05)
					createRipple(card, accent)
					springBounce(arrow, "Position", UDim2.new(1, -12, 0.5, 0), 8)
					tw(arrow, 0.12, {TextColor3 = accent})
					task.delay(0.2, function()
						tw(arrow, 0.25, {TextColor3 = C.Dim})
						springAnimate(arrow, "Position", UDim2.new(1, -16, 0.5, 0), 260, 22, 1)
					end)
					if bc.Callback then task.spawn(bc.Callback) end
				end)

				local elemData = {Name = bc.Name or "Button", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Button", _card = card}
				W._elems[#W._elems + 1] = elemData
			end

			function G:CreateInput(ic)
				ic = ic or {}
				local cH = math.floor(44 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.4, -16, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = ic.Name or "Input"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local iBg = Instance.new("Frame")
				noHit(iBg)
				iBg.AnchorPoint = Vector2.new(1, 0.5)
				iBg.BackgroundColor3 = C.AccentSub
				iBg.BackgroundTransparency = 0.3
				iBg.Position = UDim2.new(1, -12, 0.5, 0)
				iBg.Size = UDim2.new(0.55, -8, 0, math.floor(30 * SC))
				iBg.ZIndex = 10
				iBg.Parent = card
				corner(iBg, 10)
				strokeInst(iBg, C.Border, 1, 0.5)

				local iBox = Instance.new("TextBox")
				iBox.BackgroundTransparency = 1
				iBox.Position = UDim2.new(0, 10, 0, 0)
				iBox.Size = UDim2.new(1, -20, 1, 0)
				iBox.Font = Enum.Font.GothamMedium
				iBox.TextSize = FONT_ELEM_VALUE
				iBox.Text = ic.Default or ""
				iBox.PlaceholderText = ic.Placeholder or "Type..."
				iBox.PlaceholderColor3 = C.Dim
				iBox.TextColor3 = C.Text
				iBox.TextXAlignment = Enum.TextXAlignment.Left
				iBox.ClearTextOnFocus = false
				iBox.ZIndex = 12
				iBox.Parent = iBg

				iBox.Focused:Connect(function()
					playSound(Sounds.click, 0.06, 1.2)
					tw(iBg, 0.15, {BackgroundTransparency = 0.1})
					springAnimate(iBg, "Size", UDim2.new(0.55, -4, 0, math.floor(32 * SC)), 300, 20, 0.8)
				end)
				iBox.FocusLost:Connect(function(enter)
					tw(iBg, 0.15, {BackgroundTransparency = 0.3})
					springAnimate(iBg, "Size", UDim2.new(0.55, -8, 0, math.floor(30 * SC)), 260, 22, 1)
					if enter and ic.Callback then
						playSound(Sounds.sel, 0.08, 1.0)
						task.spawn(ic.Callback, iBox.Text)
					end
					if ic.Flag then W.Config:Set(ic.Flag, iBox.Text) end
				end)

				local elemData = {Name = ic.Name or "Input", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Input", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback)
					iBox.Text = v
					if ic.Flag then W.Config:Set(ic.Flag, v) end
					if not noCallback and ic.Callback then task.spawn(ic.Callback, v) end
				end
				function api:Get() return iBox.Text end
				api._cb = ic.Callback
				if ic.Flag then W._flags[ic.Flag] = api; W.Config:Register(ic.Flag, api) end
				return api
			end

			function G:CreateKeybind(kc)
				kc = kc or {}
				local currentKey = kc.Default or Enum.KeyCode.E
				local listening = false
				local cH = math.floor(44 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.6, -16, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = kc.Name or "Keybind"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local kBtn = Instance.new("TextButton")
				kBtn.AnchorPoint = Vector2.new(1, 0.5)
				kBtn.BackgroundColor3 = C.AccentSub
				kBtn.BackgroundTransparency = 0.25
				kBtn.Position = UDim2.new(1, -16, 0.5, 0)
				kBtn.Size = UDim2.new(0, math.floor(70 * SC), 0, math.floor(28 * SC))
				kBtn.Font = Enum.Font.GothamBold
				kBtn.TextSize = FONT_ELEM_VALUE
				kBtn.Text = currentKey.Name
				kBtn.TextColor3 = accent
				kBtn.AutoButtonColor = false
				kBtn.ZIndex = 11
				kBtn.Parent = card
				corner(kBtn, 10)
				strokeInst(kBtn, C.Border, 1, 0.5)

				kBtn.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					kBtn.Text = "..."
					playSound(Sounds.click, 0.08, 1.1)
					tw(kBtn, 0.15, {BackgroundTransparency = 0.05})
					springBounce(kBtn, "Size", UDim2.new(0, math.floor(74 * SC), 0, math.floor(30 * SC)), 4)

					local conn
					conn = UserInputService.InputBegan:Connect(function(input, gpe)
						if gpe then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							currentKey = input.KeyCode
							kBtn.Text = currentKey.Name
							listening = false
							tw(kBtn, 0.15, {BackgroundTransparency = 0.25})
							springAnimate(kBtn, "Size", UDim2.new(0, math.floor(70 * SC), 0, math.floor(28 * SC)), 280, 22, 1)
							playSound(Sounds.sel, 0.08, 1.0)
							if kc.Flag then W.Config:Set(kc.Flag, currentKey.Name) end
							if kc.Callback then task.spawn(kc.Callback, currentKey) end
							conn:Disconnect()
						end
					end)
				end)

				local elemData = {Name = kc.Name or "Keybind", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Keybind", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(k, noCallback)
					if type(k) == "string" then
						local ok2, resolved = pcall(function() return Enum.KeyCode[k] end)
						if ok2 and resolved then k = resolved else return end
					end
					if not k then return end
					currentKey = k
					kBtn.Text = k.Name
					if kc.Flag then W.Config:Set(kc.Flag, k.Name) end
					if not noCallback and kc.Callback then task.spawn(kc.Callback, currentKey) end
				end
				function api:Get() return currentKey end
				api._cb = kc.Callback
				if kc.Flag then W._flags[kc.Flag] = api; W.Config:Register(kc.Flag, api) end
				return api
			end

			function G:CreateColorPicker(cc)
				cc = cc or {}
				local color = cc.Default or Color3.fromRGB(180, 180, 195)
				local h, s, v = Color3.toHSV(color)
				local cH = math.floor(44 * SC)
				local card = createCard(cH)
				local expandedCP = false

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.6, -16, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = cc.Name or "Color"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local preview = Instance.new("Frame")
				noHit(preview)
				preview.AnchorPoint = Vector2.new(1, 0.5)
				preview.BackgroundColor3 = color
				preview.Position = UDim2.new(1, -16, 0.5, 0)
				preview.Size = UDim2.new(0, math.floor(36 * SC), 0, math.floor(24 * SC))
				preview.ZIndex = 11
				preview.Parent = card
				corner(preview, 8)
				strokeInst(preview, C.Border, 1, 0.4)

				local cpFrame = Instance.new("Frame")
				cpFrame.BackgroundColor3 = C.Surface
				cpFrame.BackgroundTransparency = 0.05
				cpFrame.Position = UDim2.new(0, 8, 0, cH)
				cpFrame.Size = UDim2.new(1, -16, 0, 0)
				cpFrame.ClipsDescendants = true
				cpFrame.ZIndex = 50
				cpFrame.Visible = false
				cpFrame.Parent = card
				corner(cpFrame, 14)
				strokeInst(cpFrame, C.Border, 1, 0.4)

				local svBox = Instance.new("Frame")
				svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				svBox.Position = UDim2.new(0, 12, 0, 12)
				svBox.Size = UDim2.new(1, -60, 0, math.floor(100 * SC))
				svBox.ZIndex = 52
				svBox.Active = true
				svBox.ClipsDescendants = true
				svBox.Parent = cpFrame
				corner(svBox, 10)

				local whiteGrad = Instance.new("UIGradient")
				whiteGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
				})
				whiteGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				})
				whiteGrad.Parent = svBox

				local darkFrame = Instance.new("Frame")
				noHit(darkFrame)
				darkFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				darkFrame.Size = UDim2.new(1, 0, 1, 0)
				darkFrame.ZIndex = 52
				darkFrame.Parent = svBox
				local darkGrad = Instance.new("UIGradient")
				darkGrad.Rotation = 90
				darkGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				})
				darkGrad.Parent = darkFrame

				local svCursor = Instance.new("Frame")
				noHit(svCursor)
				svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				svCursor.Size = UDim2.new(0, 12, 0, 12)
				svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
				svCursor.ZIndex = 54
				svCursor.Parent = svBox
				corner(svCursor, 6)
				strokeInst(svCursor, Color3.new(0, 0, 0), 2, 0.2)

				local hueBar = Instance.new("Frame")
				hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
				hueBar.AnchorPoint = Vector2.new(1, 0)
				hueBar.Position = UDim2.new(1, -12, 0, 12)
				hueBar.Size = UDim2.new(0, math.floor(24 * SC), 0, math.floor(100 * SC))
				hueBar.ZIndex = 52
				hueBar.Active = true
				hueBar.Parent = cpFrame
				corner(hueBar, 8)

				local hueGrad = Instance.new("UIGradient")
				hueGrad.Rotation = 90
				hueGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
					ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
					ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
					ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
					ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
				})
				hueGrad.Parent = hueBar

				local hueCursor = Instance.new("Frame")
				noHit(hueCursor)
				hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				hueCursor.Size = UDim2.new(1, 6, 0, 8)
				hueCursor.Position = UDim2.new(0.5, 0, h, 0)
				hueCursor.ZIndex = 54
				hueCursor.Parent = hueBar
				corner(hueCursor, 4)
				strokeInst(hueCursor, Color3.new(0, 0, 0), 1.5, 0.3)

				local function updateColor(suppressCallback)
					color = Color3.fromHSV(h, s, v)
					preview.BackgroundColor3 = color
					svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
					hueCursor.Position = UDim2.new(0.5, 0, h, 0)
					if cc.Flag then
						W.Config:Set(cc.Flag, {
							R = math.floor(color.R * 255),
							G = math.floor(color.G * 255),
							B = math.floor(color.B * 255),
						})
					end
					if cc.Callback and not suppressCallback then task.spawn(cc.Callback, color) end
				end

				local svDrag = false
				local hueDrag = false

				svBox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						svDrag = true
					end
				end)
				hueBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						hueDrag = true
					end
				end)

				trackConn(UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						if svDrag then
							local ap = svBox.AbsolutePosition
							local as = svBox.AbsoluteSize
							s = math.clamp((input.Position.X - ap.X) / as.X, 0.005, 1)
							v = 1 - math.clamp((input.Position.Y - ap.Y) / as.Y, 0, 1)
							updateColor()
						elseif hueDrag then
							local ap = hueBar.AbsolutePosition
							local as = hueBar.AbsoluteSize
							h = math.clamp((input.Position.Y - ap.Y) / as.Y, 0, 0.995)
							updateColor()
						end
					end
				end))

				trackConn(UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						svDrag = false
						hueDrag = false
					end
				end))

				local cpHeaderBtn = Instance.new("TextButton")
				cpHeaderBtn.BackgroundTransparency = 1
				cpHeaderBtn.Text = ""
				cpHeaderBtn.AutoButtonColor = false
				cpHeaderBtn.Size = UDim2.new(1, 0, 0, cH)
				cpHeaderBtn.Position = UDim2.new(0, 0, 0, 0)
				cpHeaderBtn.ZIndex = 14
				cpHeaderBtn.Parent = card

				cpHeaderBtn.MouseButton1Click:Connect(function()
					expandedCP = not expandedCP
					if expandedCP then

						cpFrame.Parent = card
						cpFrame.Position = UDim2.new(0, 8, 0, cH + 2)
						cpFrame.Size = UDim2.new(1, -16, 0, 0)
						cpFrame.ZIndex = 16
						cpFrame.Visible = true

						for _, child in pairs(cpFrame:GetDescendants()) do
							if child:IsA("GuiObject") then
								child.ZIndex = math.max(child.ZIndex, 17)
							end
						end
						svBox.ZIndex = 202
						hueBar.ZIndex = 202
						svCursor.ZIndex = 204
						hueCursor.ZIndex = 204
						darkFrame.ZIndex = 203

						playSound(Sounds.expand, 0.08, 1.1)
						local expandH = math.floor(130 * SC)
						tw(cpFrame, 0.3, {Size = UDim2.new(1, -16, 0, expandH)}, Enum.EasingStyle.Quint)
						tw(card, 0.3, {Size = UDim2.new(1, 0, 0, cH + expandH + 8)}, Enum.EasingStyle.Quint)

						local closeCon
						closeCon = UserInputService.InputBegan:Connect(function(inp)
							if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
								local mPos = inp.Position
								local cPos = card.AbsolutePosition
								local cSize = card.AbsoluteSize
								if mPos.X < cPos.X or mPos.X > cPos.X + cSize.X
									or mPos.Y < cPos.Y or mPos.Y > cPos.Y + cSize.Y then
									expandedCP = false
									playSound(Sounds.collapse, 0.06, 1.2)
									tw(cpFrame, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
									tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
									task.delay(0.22, function()
										cpFrame.Visible = false
										cpFrame.Parent = card
										cpFrame.Position = UDim2.new(0, 8, 0, cH)
										cpFrame.Size = UDim2.new(1, -16, 0, 0)
										cpFrame.ZIndex = 50
										svBox.ZIndex = 52
										hueBar.ZIndex = 52
										svCursor.ZIndex = 54
										hueCursor.ZIndex = 54
										darkFrame.ZIndex = 52
									end)
									if closeCon then closeCon:Disconnect(); closeCon = nil end
								end
							end
						end)
						trackConn(closeCon)
					else
						playSound(Sounds.collapse, 0.06, 1.2)
						tw(cpFrame, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
						tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
						task.delay(0.22, function()
							cpFrame.Visible = false
							cpFrame.Parent = card
							cpFrame.Position = UDim2.new(0, 8, 0, cH)
							cpFrame.Size = UDim2.new(1, -16, 0, 0)
							cpFrame.ZIndex = 50
							svBox.ZIndex = 52
							hueBar.ZIndex = 52
							svCursor.ZIndex = 54
							hueCursor.ZIndex = 54
							darkFrame.ZIndex = 52
						end)
					end
				end)

				local elemData = {Name = cc.Name or "ColorPicker", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "ColorPicker", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(c2, noCallback)
					if type(c2) == "table" and c2.R then
						c2 = Color3.fromRGB(c2.R, c2.G, c2.B)
					end
					h, s, v = Color3.toHSV(c2)
					updateColor(noCallback)
				end
				function api:Get() return color end
				api._cb = cc.Callback
				if cc.Flag then W._flags[cc.Flag] = api; W.Config:Register(cc.Flag, api) end
				return api
			end

			-- Compact info line. A left accent tick + muted medium text gives it a
			-- "home" so it reads as an intentional callout instead of bold text
			-- floating in an oversized plate. The card hugs the text via a
			-- scale-based clay shadow (excluded from AutomaticSize), unlike the old
			-- fixed-offset shadow that forced every card to a ~62px minimum.
			function G:CreateLabel(lc)
				lc = lc or {}
				local text = lc.Text or ""
				local iconAsset = lc.Icon and getIconAsset(lc.Icon)

				local lCard = Instance.new("Frame")
				lCard.BackgroundColor3 = C.SurfaceAlt
				lCard.BackgroundTransparency = 0.15
				lCard.Size = UDim2.new(1, 0, 0, math.floor(40 * SC))
				lCard.LayoutOrder = gNext()
				lCard.ZIndex = 9
				lCard.Parent = gContent
				corner(lCard, 12)
				strokeInst(lCard, C.Border, 1, 0.55)
				addClayShadow(lCard, 12)

				local tick = Instance.new("Frame")
				noHit(tick)
				tick.AnchorPoint = Vector2.new(0, 0.5)
				tick.BackgroundColor3 = accent
				tick.Position = UDim2.new(0, 13, 0.5, 0)
				tick.Size = UDim2.new(0, math.floor(3 * SC), 1, -18)
				tick.ZIndex = 11
				tick.Parent = lCard
				corner(tick, 2)
				local tickGrad = Instance.new("UIGradient")
				tickGrad.Rotation = 90
				tickGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor(accent, C.Text, 0.4)),
					ColorSequenceKeypoint.new(1, accent),
				})
				tickGrad.Parent = tick

				local textX = 26
				if iconAsset then
					local ic = Instance.new("ImageLabel")
					noHit(ic)
					ic.BackgroundTransparency = 1
					ic.AnchorPoint = Vector2.new(0, 0.5)
					ic.Position = UDim2.new(0, 25, 0.5, 0)
					ic.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
					ic.Image = iconAsset
					ic.ImageColor3 = accent
					ic.ScaleType = Enum.ScaleType.Fit
					ic.ZIndex = 11
					ic.Parent = lCard
					textX = 46
				end

				local l = Instance.new("TextLabel")
				noHit(l)
				l.BackgroundTransparency = 1
				l.Position = UDim2.new(0, textX, 0, 0)
				l.Size = UDim2.new(1, -(textX + 16), 0, 0)
				l.AutomaticSize = Enum.AutomaticSize.Y
				l.Font = Enum.Font.GothamMedium
				l.TextSize = lc.TextSize or math.floor(13 * SC)
				l.Text = text
				l.TextColor3 = lerpColor(C.Text, C.Sub, 0.22)
				l.TextXAlignment = Enum.TextXAlignment.Left
				l.TextYAlignment = Enum.TextYAlignment.Top
				l.TextWrapped = true
				l.LineHeight = 1.12
				l.ZIndex = 10
				l.Parent = lCard
				-- Pad the text (not the card) so the tick keeps its absolute inset.
				local lPad = Instance.new("UIPadding")
				lPad.PaddingTop = UDim.new(0, math.floor(11 * SC))
				lPad.PaddingBottom = UDim.new(0, math.floor(12 * SC))
				lPad.Parent = l

				-- Fixed-height card that tracks the text's measured height, so it always
				-- hugs the content exactly. (Auto-sizing a card that also holds scale/offset
				-- children misbehaves: scale children blow the height up, offset shadows
				-- push the text to the top.)
				local function syncLabelH()
					lCard.Size = UDim2.new(1, 0, 0, math.max(math.floor(34 * SC), math.ceil(l.AbsoluteSize.Y)))
				end
				l:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncLabelH)
				task.defer(syncLabelH)

				return {Set = function(_, t) l.Text = t end, Get = function() return l.Text end, SetTextSize = function(_, s) l.TextSize = s end}
			end

			-- Titled block. A full-height accent stripe + a bold bright title over
			-- muted, line-spaced body text gives a real visual hierarchy (was: title
			-- and body identical bold-white, stacked with a newline).
			function G:CreateParagraph(pc)
				pc = pc or {}
				local content = pc.Content or ""
				local title = pc.Title or ""
				local iconAsset = pc.Icon and getIconAsset(pc.Icon)

				local pCard = Instance.new("Frame")
				pCard.BackgroundColor3 = C.SurfaceAlt
				pCard.BackgroundTransparency = 0.12
				pCard.Size = UDim2.new(1, 0, 0, math.floor(56 * SC))
				pCard.LayoutOrder = gNext()
				pCard.ZIndex = 9
				pCard.Parent = gContent
				corner(pCard, 12)
				strokeInst(pCard, C.Border, 1, 0.5)
				addClayShadow(pCard, 12)

				local stripe = Instance.new("Frame")
				noHit(stripe)
				stripe.AnchorPoint = Vector2.new(0, 0.5)
				stripe.BackgroundColor3 = accent
				stripe.Position = UDim2.new(0, 14, 0.5, 0)
				stripe.Size = UDim2.new(0, math.floor(3 * SC), 1, -22)
				stripe.ZIndex = 11
				stripe.Parent = pCard
				corner(stripe, 2)
				local stripeGrad = Instance.new("UIGradient")
				stripeGrad.Rotation = 90
				stripeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor(accent, C.Text, 0.45)),
					ColorSequenceKeypoint.new(1, accent),
				})
				stripeGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.2),
				})
				stripeGrad.Parent = stripe

				local holder = Instance.new("Frame")
				noHit(holder)
				holder.BackgroundTransparency = 1
				holder.Position = UDim2.new(0, 28, 0, 0)
				holder.Size = UDim2.new(1, -46, 0, 0)
				holder.AutomaticSize = Enum.AutomaticSize.Y
				holder.ZIndex = 10
				holder.Parent = pCard
				local hPad = Instance.new("UIPadding")
				hPad.PaddingTop = UDim.new(0, math.floor(13 * SC))
				hPad.PaddingBottom = UDim.new(0, math.floor(14 * SC))
				hPad.Parent = holder
				local hList = Instance.new("UIListLayout")
				hList.FillDirection = Enum.FillDirection.Vertical
				hList.SortOrder = Enum.SortOrder.LayoutOrder
				hList.Padding = UDim.new(0, math.floor(5 * SC))
				hList.Parent = holder

				local titleLabel
				if title ~= "" then
					local titleRow = Instance.new("Frame")
					noHit(titleRow)
					titleRow.BackgroundTransparency = 1
					titleRow.Size = UDim2.new(1, 0, 0, 0)
					titleRow.AutomaticSize = Enum.AutomaticSize.Y
					titleRow.LayoutOrder = 1
					titleRow.ZIndex = 10
					titleRow.Parent = holder

					local tX = 0
					if iconAsset then
						local pIcon = Instance.new("ImageLabel")
						noHit(pIcon)
						pIcon.BackgroundTransparency = 1
						pIcon.AnchorPoint = Vector2.new(0, 0.5)
						pIcon.Position = UDim2.new(0, 0, 0, math.floor(8 * SC))
						pIcon.Size = UDim2.new(0, math.floor(15 * SC), 0, math.floor(15 * SC))
						pIcon.Image = iconAsset
						pIcon.ImageColor3 = accent
						pIcon.ScaleType = Enum.ScaleType.Fit
						pIcon.ZIndex = 11
						pIcon.Parent = titleRow
						tX = math.floor(22 * SC)
					end

					titleLabel = Instance.new("TextLabel")
					noHit(titleLabel)
					titleLabel.BackgroundTransparency = 1
					titleLabel.Position = UDim2.new(0, tX, 0, 0)
					titleLabel.Size = UDim2.new(1, -tX, 0, 0)
					titleLabel.AutomaticSize = Enum.AutomaticSize.Y
					titleLabel.Font = Enum.Font.GothamBold
					titleLabel.TextSize = FONT_ELEM_NAME
					titleLabel.Text = title
					titleLabel.TextColor3 = C.Text
					titleLabel.TextXAlignment = Enum.TextXAlignment.Left
					titleLabel.TextYAlignment = Enum.TextYAlignment.Top
					titleLabel.TextWrapped = true
					titleLabel.ZIndex = 10
					titleLabel.Parent = titleRow
				end

				local cL = Instance.new("TextLabel")
				noHit(cL)
				cL.BackgroundTransparency = 1
				cL.Size = UDim2.new(1, 0, 0, 0)
				cL.AutomaticSize = Enum.AutomaticSize.Y
				cL.Font = Enum.Font.GothamMedium
				cL.TextSize = math.floor(12.5 * SC)
				cL.Text = content
				cL.TextColor3 = C.Sub
				cL.TextXAlignment = Enum.TextXAlignment.Left
				cL.TextYAlignment = Enum.TextYAlignment.Top
				cL.TextWrapped = true
				cL.LineHeight = 1.2
				cL.LayoutOrder = 2
				cL.ZIndex = 10
				cL.Parent = holder

				-- Card tracks the text column's measured height (see CreateLabel).
				local function syncParaH()
					pCard.Size = UDim2.new(1, 0, 0, math.max(math.floor(40 * SC), math.ceil(holder.AbsoluteSize.Y)))
				end
				holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncParaH)
				task.defer(syncParaH)

				local api = {}
				function api:Set(d)
					d = d or {}
					if d.Title ~= nil then
						title = d.Title
						if titleLabel then titleLabel.Text = title end
					end
					if d.Content ~= nil then
						content = d.Content
						cL.Text = content
					end
				end
				function api:Get() return title ~= "" and (title .. "\n" .. content) or content end
				return api
			end

			function G:CreateSeparator()
				local sep = Instance.new("Frame")
				noHit(sep)
				sep.BackgroundColor3 = C.Border
				sep.BackgroundTransparency = 0.55
				sep.Size = UDim2.new(1, -24, 0, 1)
				sep.LayoutOrder = gNext()
				sep.ZIndex = 8
				sep.Parent = gContent

				local sepGrad = Instance.new("UIGradient")
				sepGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.15, 0),
					NumberSequenceKeypoint.new(0.85, 0),
					NumberSequenceKeypoint.new(1, 1),
				})
				sepGrad.Parent = sep
			end

			return G
		end

		function Tab:CreateGroup(gc)
			gc = gc or {}
			return Tab:_createGroupInternal(gc, contentScroll, nil)
		end

		return Tab
	end

	function W:Destroy()
		for _, conn in pairs(W._conns) do
			pcall(function() conn:Disconnect() end)
		end
		hideBlur()
		playSound(Sounds.collapse, 0.12, 0.8)
		tw(main, 0.35, {
			Size = UDim2.new(0, 0, 0, 0),
			GroupTransparency = 1,
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.4, function()
			screenGui:Destroy()
			destroyBlur()
		end)
	end

	local watermarkVisible = true
	local watermarkFrame = Instance.new("Frame")
	watermarkFrame.AnchorPoint = Vector2.new(0, 0)
	watermarkFrame.BackgroundColor3 = C.BG
	watermarkFrame.BackgroundTransparency = 0.08
	watermarkFrame.Position = UDim2.new(0, 16, 0, 48)
	watermarkFrame.Size = UDim2.new(0, 0, 0, math.floor(26 * SC))
	watermarkFrame.AutomaticSize = Enum.AutomaticSize.X
	watermarkFrame.ZIndex = 55
	watermarkFrame.Visible = true
	watermarkFrame.Active = true
	watermarkFrame.Draggable = true
	watermarkFrame.Parent = screenGui
	corner(watermarkFrame, 8)
	strokeInst(watermarkFrame, C.Border, 1, 0.5)
	addClayShadow(watermarkFrame, 8)

	local wmPad = Instance.new("UIPadding")
	wmPad.PaddingLeft = UDim.new(0, 12)
	wmPad.PaddingRight = UDim.new(0, 12)
	wmPad.Parent = watermarkFrame

	local wmText = Instance.new("TextLabel")
	noHit(wmText)
	wmText.BackgroundTransparency = 1
	wmText.Position = UDim2.new(0, 0, 0, 0)
	wmText.Size = UDim2.new(0, 0, 1, 0)
	wmText.AutomaticSize = Enum.AutomaticSize.X
	wmText.Font = Enum.Font.GothamBold
	wmText.TextSize = math.floor(11 * SC)
	wmText.Text = title .. "  |  Loading..."
	wmText.TextColor3 = C.Text
	wmText.TextTransparency = 0
	wmText.TextXAlignment = Enum.TextXAlignment.Left
	wmText.ZIndex = 56
	wmText.Parent = watermarkFrame

	local wmUpdateCounter = 0
	poolAdd(function(dt)
		if not wmText or not wmText.Parent then return false end
		wmUpdateCounter = wmUpdateCounter + dt
		if wmUpdateCounter < 0.5 then return true end
		wmUpdateCounter = 0

		local fps = math.floor(1 / dt)
		local ping = "N/A"
		pcall(function()
			ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. "ms"
		end)
		if ping == "N/A" then
			pcall(function()
				ping = tostring(math.floor(Player:GetNetworkPing() * 1000)) .. "ms"
			end)
		end

		local timeStr = os.date("%H:%M")
		local pName = ""
		pcall(function() pName = Player.DisplayName end)

		wmText.Text = title .. " | " .. tostring(fps) .. " FPS"
			.. " | " .. ping
			.. " | " .. pName
			.. " | " .. timeStr

		return true
	end)

	function W:SetWatermarkVisible(vis)
		watermarkVisible = vis
		watermarkFrame.Visible = vis
	end

	function W:SetWatermarkText(txt)
		wmText.Text = txt
	end

	function W:SetFooterVisible(vis)
		if footer and footer.Parent then footer.Visible = vis end
	end

	function W:SetBGVisible(vis)
		if bgMaster and bgMaster.Parent then bgMaster.Visible = vis end
	end

	function W:SetBlurEnabled(vis)
		blurEnabled = vis
		if vis then showBlur() else hideBlur() end
	end

	function W:SetUIScale(scale)
		scale = math.clamp(scale, 0.5, 1.5)
		tw(uiScaleObj, 0.3, {Scale = scale}, Enum.EasingStyle.Quint)
	end

	function W:SetSoundsEnabled(vis)
		SND_ON = vis
	end

	function W:SetSoundPack(name)
		setSoundPack(name)
	end

	function W:GetSoundPackNames()
		local r = {}
		for k in pairs(SoundPacks) do r[#r + 1] = k end
		table.sort(r)
		return r
	end

	function W:SetToggleKeybind(key)
		if type(key) == "string" then key = Enum.KeyCode[key] end
		if key then keybind = key end
	end

	function W:RegisterKeybind(name, key, callback)
		W._customKeybinds = W._customKeybinds or {}
		if type(key) == "string" then key = Enum.KeyCode[key] end
		W._customKeybinds[name] = {Key = key, Callback = callback, Enabled = true}
	end

	function W:UnregisterKeybind(name)
		if W._customKeybinds then W._customKeybinds[name] = nil end
	end

	function W:SetKeybindEnabled(name, enabled)
		if W._customKeybinds and W._customKeybinds[name] then
			W._customKeybinds[name].Enabled = enabled
		end
	end

	function W:SetKeybindKey(name, key)
		if type(key) == "string" then key = Enum.KeyCode[key] end
		if W._customKeybinds and W._customKeybinds[name] then
			W._customKeybinds[name].Key = key
		end
	end

	function W:GetKeybinds()
		return W._customKeybinds or {}
	end

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if W._customKeybinds then
			for _, kb in pairs(W._customKeybinds) do
				if kb.Enabled and kb.Key == input.KeyCode and kb.Callback then
					task.spawn(kb.Callback)
				end
			end
		end
	end))

	local ThemePresets = {
		["Default"] = {
			BG = Color3.fromRGB(14, 14, 20),
			Surface = Color3.fromRGB(24, 24, 32),
			Border = Color3.fromRGB(42, 42, 55),
			Text = Color3.fromRGB(225, 225, 235),
			Sub = Color3.fromRGB(145, 145, 165),
			Accent = Color3.fromRGB(180, 180, 195),
			Ok = Color3.fromRGB(75, 190, 130),
		},
		["Midnight"] = {
			BG = Color3.fromRGB(8, 10, 20),
			Surface = Color3.fromRGB(14, 18, 32),
			Border = Color3.fromRGB(28, 35, 55),
			Text = Color3.fromRGB(200, 210, 230),
			Sub = Color3.fromRGB(100, 115, 150),
			Accent = Color3.fromRGB(75, 120, 200),
			Ok = Color3.fromRGB(60, 150, 170),
		},
		["Rose"] = {
			BG = Color3.fromRGB(16, 10, 12),
			Surface = Color3.fromRGB(26, 18, 22),
			Border = Color3.fromRGB(45, 32, 38),
			Text = Color3.fromRGB(230, 215, 220),
			Sub = Color3.fromRGB(140, 110, 120),
			Accent = Color3.fromRGB(200, 100, 120),
			Ok = Color3.fromRGB(180, 90, 110),
		},
		["Forest"] = {
			BG = Color3.fromRGB(8, 14, 10),
			Surface = Color3.fromRGB(14, 24, 18),
			Border = Color3.fromRGB(28, 44, 34),
			Text = Color3.fromRGB(200, 228, 210),
			Sub = Color3.fromRGB(100, 140, 118),
			Accent = Color3.fromRGB(55, 165, 105),
			Ok = Color3.fromRGB(45, 175, 115),
		},
		["OLED"] = {
			BG = Color3.fromRGB(0, 0, 0),
			Surface = Color3.fromRGB(8, 8, 8),
			Border = Color3.fromRGB(22, 22, 22),
			Text = Color3.fromRGB(220, 220, 220),
			Sub = Color3.fromRGB(100, 100, 100),
			Accent = Color3.fromRGB(160, 160, 160),
			Ok = Color3.fromRGB(80, 170, 80),
		},
		["Neon"] = {
			BG = Color3.fromRGB(6, 3, 12),
			Surface = Color3.fromRGB(12, 8, 24),
			Border = Color3.fromRGB(30, 22, 55),
			Text = Color3.fromRGB(225, 215, 245),
			Sub = Color3.fromRGB(130, 110, 170),
			Accent = Color3.fromRGB(150, 60, 220),
			Ok = Color3.fromRGB(40, 200, 170),
		},
		["Ember"] = {
			BG = Color3.fromRGB(14, 8, 6),
			Surface = Color3.fromRGB(24, 16, 12),
			Border = Color3.fromRGB(45, 30, 24),
			Text = Color3.fromRGB(235, 220, 208),
			Sub = Color3.fromRGB(155, 125, 108),
			Accent = Color3.fromRGB(210, 100, 45),
			Ok = Color3.fromRGB(220, 135, 40),
		},
		["Frost"] = {
			BG = Color3.fromRGB(10, 14, 18),
			Surface = Color3.fromRGB(18, 24, 32),
			Border = Color3.fromRGB(34, 46, 60),
			Text = Color3.fromRGB(210, 225, 240),
			Sub = Color3.fromRGB(120, 145, 168),
			Accent = Color3.fromRGB(90, 175, 230),
			Ok = Color3.fromRGB(75, 190, 215),
		},
		["Void"] = {
			BG = Color3.fromRGB(3, 2, 6),
			Surface = Color3.fromRGB(8, 6, 14),
			Border = Color3.fromRGB(20, 16, 35),
			Text = Color3.fromRGB(190, 185, 215),
			Sub = Color3.fromRGB(95, 88, 135),
			Accent = Color3.fromRGB(110, 65, 210),
			Ok = Color3.fromRGB(85, 50, 200),
		},
		["Crimson"] = {
			BG = Color3.fromRGB(10, 4, 4),
			Surface = Color3.fromRGB(20, 10, 10),
			Border = Color3.fromRGB(40, 22, 22),
			Text = Color3.fromRGB(230, 205, 205),
			Sub = Color3.fromRGB(140, 95, 95),
			Accent = Color3.fromRGB(185, 45, 55),
			Ok = Color3.fromRGB(200, 60, 50),
		},
		["Mint"] = {
			BG = Color3.fromRGB(6, 12, 10),
			Surface = Color3.fromRGB(12, 22, 18),
			Border = Color3.fromRGB(24, 42, 35),
			Text = Color3.fromRGB(200, 235, 222),
			Sub = Color3.fromRGB(105, 155, 135),
			Accent = Color3.fromRGB(45, 190, 150),
			Ok = Color3.fromRGB(35, 205, 160),
		},
		["Gold"] = {
			BG = Color3.fromRGB(10, 9, 6),
			Surface = Color3.fromRGB(20, 18, 12),
			Border = Color3.fromRGB(38, 34, 24),
			Text = Color3.fromRGB(232, 225, 200),
			Sub = Color3.fromRGB(150, 138, 105),
			Accent = Color3.fromRGB(195, 165, 55),
			Ok = Color3.fromRGB(210, 175, 45),
		},
	}

	W.ThemePresets = ThemePresets
	W.CurrentTheme = "Default"

	function W:GetThemeNames()
		local names = {}
		for k, _ in pairs(ThemePresets) do
			names[#names + 1] = k
		end
		table.sort(names)
		return names
	end

	function W:SetTheme(name)
		local preset = ThemePresets[name]
		if not preset then return false end
		W.CurrentTheme = name
		local dur = 0.45
		local newC = {
			BG = preset.BG or C.BG,
			Surface = preset.Surface or C.Surface,
			Border = preset.Border or C.Border,
			Text = preset.Text or C.Text,
			Sub = preset.Sub or C.Sub,
			Accent = preset.Accent or C.Accent,
			Ok = preset.Ok or C.Ok,
		}
		local function safeTw(obj, props)
			if obj and obj.Parent then pcall(function() tw(obj, dur, props, Enum.EasingStyle.Quint) end) end
		end
		safeTw(main, {BackgroundColor3 = newC.BG})
		safeTw(bgMaster, {BackgroundColor3 = newC.BG})
		safeTw(topbar, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.5)})
		safeTw(sidebar, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.3)})
		safeTw(footer, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.5)})
		if logoIcon and logoIcon.Parent then
			safeTw(logoIcon, {ImageColor3 = newC.Accent})
		end
		if logoText and logoText.Parent then
			logoText.Text = string.format(
				'<font color="rgb(255,255,255)">Angel</font> <font color="rgb(30,30,30)">Ware</font>>',
				math.floor(newC.Text.R*255), math.floor(newC.Text.G*255), math.floor(newC.Text.B*255),
				math.floor(newC.Sub.R*255), math.floor(newC.Sub.G*255), math.floor(newC.Sub.B*255))
		end
		for _, ch in pairs(main:GetDescendants()) do
			pcall(function()
				if ch:IsA("Frame") or ch:IsA("CanvasGroup") then
					if ch.BackgroundTransparency < 0.15 then
						local bc = ch.BackgroundColor3
						local dBG = math.abs(bc.R - C.BG.R) + math.abs(bc.G - C.BG.G) + math.abs(bc.B - C.BG.B)
						local dSurf = math.abs(bc.R - C.Surface.R) + math.abs(bc.G - C.Surface.G) + math.abs(bc.B - C.Surface.B)
						if dBG < 0.15 then
							safeTw(ch, {BackgroundColor3 = newC.BG})
						elseif dSurf < 0.15 then
							safeTw(ch, {BackgroundColor3 = newC.Surface})
						end
					end
				end
				if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
					if ch.TextTransparency < 0.5 then
						local tc = ch.TextColor3
						local dText = math.abs(tc.R - C.Text.R) + math.abs(tc.G - C.Text.G) + math.abs(tc.B - C.Text.B)
						local dSub = math.abs(tc.R - C.Sub.R) + math.abs(tc.G - C.Sub.G) + math.abs(tc.B - C.Sub.B)
						local dDim = math.abs(tc.R - C.Dim.R) + math.abs(tc.G - C.Dim.G) + math.abs(tc.B - C.Dim.B)
						local dAcc = math.abs(tc.R - C.Accent.R) + math.abs(tc.G - C.Accent.G) + math.abs(tc.B - C.Accent.B)
						if dAcc < 0.1 then
							safeTw(ch, {TextColor3 = newC.Accent})
						elseif dText < 0.1 then
							safeTw(ch, {TextColor3 = newC.Text})
						elseif dSub < 0.15 or dDim < 0.15 then
							safeTw(ch, {TextColor3 = newC.Sub})
						end
					end
				end
				if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then
					if ch.ImageTransparency < 0.5 then
						local ic = ch.ImageColor3
						local dAcc = math.abs(ic.R - C.Accent.R) + math.abs(ic.G - C.Accent.G) + math.abs(ic.B - C.Accent.B)
						if dAcc < 0.15 then
							safeTw(ch, {ImageColor3 = newC.Accent})
						end
					end
				end
				if ch:IsA("UIStroke") then
					local sc = ch.Color
					local dBrd = math.abs(sc.R - C.Border.R) + math.abs(sc.G - C.Border.G) + math.abs(sc.B - C.Border.B)
					if dBrd < 0.15 then
						safeTw(ch, {Color = newC.Border})
					end
				end
				if ch:IsA("ScrollingFrame") then
					safeTw(ch, {ScrollBarImageColor3 = newC.Border})
				end
			end)
		end
		if activeOverlay and activeOverlay.Parent then
			safeTw(activeOverlay, {BackgroundColor3 = newC.Surface})
		end
		for _, ch in pairs(screenGui:GetDescendants()) do
			pcall(function()
				if ch:IsA("CanvasGroup") and ch.BackgroundTransparency < 0.3 then
					safeTw(ch, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.4)})
				end
			end)
		end
		C.BG = newC.BG
		C.Surface = newC.Surface
		C.Border = newC.Border
		C.Text = newC.Text
		C.Sub = newC.Sub
		C.Accent = newC.Accent
		C.Ok = newC.Ok
		C.BGAlt = lerpColor(newC.BG, newC.Surface, 0.4)
		C.TopbarBG = lerpColor(newC.BG, newC.Surface, 0.5)
		C.SidebarBG = lerpColor(newC.BG, newC.Surface, 0.3)
		C.FooterBG = lerpColor(newC.BG, newC.Surface, 0.5)
		C.Dim = lerpColor(newC.Sub, newC.BG, 0.3)
		C.AccentLit = lerpColor(newC.Accent, Color3.new(1,1,1), 0.15)
		C.AccentSub = lerpColor(newC.Accent, newC.BG, 0.7)
		return true
	end

	local keybindViewerVisible = false
	local keybindViewerFrame = Instance.new("CanvasGroup")
	noHit(keybindViewerFrame)
	keybindViewerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	keybindViewerFrame.BackgroundColor3 = C.BGAlt
	keybindViewerFrame.BackgroundTransparency = 0.05
	keybindViewerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	keybindViewerFrame.Size = UDim2.new(0, math.floor(320 * SC), 0, math.floor(400 * SC))
	keybindViewerFrame.ZIndex = 90
	keybindViewerFrame.Visible = false
	keybindViewerFrame.Parent = screenGui
	corner(keybindViewerFrame, 18)
	strokeInst(keybindViewerFrame, C.Border, 1, 0.3)
	addClayShadow(keybindViewerFrame, 18)

	local kbvHeader = Instance.new("TextLabel")
	noHit(kbvHeader)
	kbvHeader.BackgroundTransparency = 1
	kbvHeader.Size = UDim2.new(1, 0, 0, math.floor(42 * SC))
	kbvHeader.Font = Enum.Font.GothamBold
	kbvHeader.TextSize = math.floor(15 * SC)
	kbvHeader.Text = "Keybind List"
	kbvHeader.TextColor3 = C.Accent
	kbvHeader.ZIndex = 91
	kbvHeader.Parent = keybindViewerFrame

	local kbvSep = Instance.new("Frame")
	noHit(kbvSep)
	kbvSep.BackgroundColor3 = C.Border
	kbvSep.BackgroundTransparency = 0.5
	kbvSep.Size = UDim2.new(1, -24, 0, 1)
	kbvSep.Position = UDim2.new(0, 12, 0, math.floor(42 * SC))
	kbvSep.ZIndex = 91
	kbvSep.Parent = keybindViewerFrame

	local kbvScroll = Instance.new("ScrollingFrame")
	noHit(kbvScroll)
	kbvScroll.BackgroundTransparency = 1
	kbvScroll.Position = UDim2.new(0, 0, 0, math.floor(48 * SC))
	kbvScroll.Size = UDim2.new(1, 0, 1, -math.floor(48 * SC))
	kbvScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	kbvScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	kbvScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	kbvScroll.ScrollBarThickness = 3
	kbvScroll.ScrollBarImageColor3 = C.Accent
	kbvScroll.ScrollBarImageTransparency = 0.5
	kbvScroll.ZIndex = 91
	kbvScroll.Parent = keybindViewerFrame
	pad(kbvScroll, 8, 8, 14, 14)
	uiList(kbvScroll, 4, Enum.FillDirection.Vertical)

	local kbvClose = Instance.new("TextButton")
	kbvClose.AnchorPoint = Vector2.new(1, 0)
	kbvClose.BackgroundTransparency = 1
	kbvClose.Position = UDim2.new(1, -10, 0, 8)
	kbvClose.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(28 * SC))
	kbvClose.Text = "X"
	kbvClose.Font = Enum.Font.GothamBold
	kbvClose.TextSize = math.floor(16 * SC)
	kbvClose.TextColor3 = C.Sub
	kbvClose.AutoButtonColor = false
	kbvClose.ZIndex = 92
	kbvClose.Parent = keybindViewerFrame
	kbvClose.MouseButton1Click:Connect(function()
		keybindViewerVisible = false
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(keybindViewerFrame, 0.25, {Size = UDim2.new(0, math.floor(320 * SC), 0, 0), GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			keybindViewerFrame.Visible = false
			keybindViewerFrame.GroupTransparency = 0
		end)
	end)

	W._keybindEntries = {}

	local function refreshKeybindViewer()
		for _, c in pairs(kbvScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end

		local entries = W._keybindEntries
		if #entries == 0 then
			local emptyLabel = Instance.new("TextLabel")
			noHit(emptyLabel)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Size = UDim2.new(1, 0, 0, 40)
			emptyLabel.Font = Enum.Font.GothamMedium
			emptyLabel.TextSize = math.floor(12 * SC)
			emptyLabel.Text = "No keybinds registered"
			emptyLabel.TextColor3 = C.Sub
			emptyLabel.ZIndex = 92
			emptyLabel.Parent = kbvScroll
			return
		end

		for i, entry in ipairs(entries) do
			local row = Instance.new("Frame")
			noHit(row)
			row.BackgroundColor3 = C.Surface
			row.BackgroundTransparency = 0.4
			row.Size = UDim2.new(1, 0, 0, math.floor(32 * SC))
			row.LayoutOrder = i
			row.ZIndex = 92
			row.Parent = kbvScroll
			corner(row, 8)

			local keyBadge = Instance.new("Frame")
			noHit(keyBadge)
			keyBadge.AnchorPoint = Vector2.new(1, 0.5)
			keyBadge.BackgroundColor3 = C.AccentSub
			keyBadge.Position = UDim2.new(1, -8, 0.5, 0)
			keyBadge.Size = UDim2.new(0, math.floor(60 * SC), 0, math.floor(22 * SC))
			keyBadge.ZIndex = 93
			keyBadge.Parent = row
			corner(keyBadge, 6)
			strokeInst(keyBadge, C.Border, 1, 0.5)

			local keyText = Instance.new("TextLabel")
			noHit(keyText)
			keyText.BackgroundTransparency = 1
			keyText.Size = UDim2.new(1, 0, 1, 0)
			keyText.Font = Enum.Font.Code
			keyText.TextSize = math.floor(10 * SC)
			keyText.Text = entry.Key or "?"
			keyText.TextColor3 = C.Accent
			keyText.ZIndex = 94
			keyText.Parent = keyBadge

			local nameL = Instance.new("TextLabel")
			noHit(nameL)
			nameL.BackgroundTransparency = 1
			nameL.Position = UDim2.new(0, 10, 0, 0)
			nameL.Size = UDim2.new(0.6, 0, 1, 0)
			nameL.Font = Enum.Font.GothamMedium
			nameL.TextSize = math.floor(11 * SC)
			nameL.Text = entry.Name or ""
			nameL.TextColor3 = C.Text
			nameL.TextTransparency = 0.1
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.TextTruncate = Enum.TextTruncate.AtEnd
			nameL.ZIndex = 93
			nameL.Parent = row
		end
	end

	function W:ShowKeybindViewer()
		keybindViewerVisible = true
		refreshKeybindViewer()
		keybindViewerFrame.Visible = true
		keybindViewerFrame.Size = UDim2.new(0, math.floor(320 * SC), 0, 0)
		playSound(Sounds.expand, 0.08, 1.0)
		tw(keybindViewerFrame, 0.35, {Size = UDim2.new(0, math.floor(320 * SC), 0, math.floor(400 * SC))}, Enum.EasingStyle.Back)
	end

	function W:HideKeybindViewer()
		keybindViewerVisible = false
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(keybindViewerFrame, 0.25, {Size = UDim2.new(0, math.floor(320 * SC), 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			keybindViewerFrame.Visible = false
		end)
	end

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.B and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			if keybindViewerVisible then
				W:HideKeybindViewer()
			else
				W:ShowKeybindViewer()
			end
		end
	end))

	W._tabBadges = {}
	W._tabFeatureCounts = {}

	local function updateTabBadges()
		local counts = {}
		for name, val in pairs(W._activeFeatures) do
			if val then
				for _, elem in pairs(W._elems) do
					if elem.Name == name and elem.Tab then
						counts[elem.Tab] = (counts[elem.Tab] or 0) + 1
						break
					end
				end
			end
		end
		W._tabFeatureCounts = counts

		for tabName, badge in pairs(W._tabBadges) do
			local count = counts[tabName] or 0
			if count > 0 then
				badge.Visible = true
				badge._label.Text = tostring(count)
				if badge._lastCount ~= count then
					springBounce(badge, "Size",
						UDim2.new(0, math.floor(18 * SC), 0, math.floor(14 * SC)), 1.2)
					badge._lastCount = count
				end
			else
				badge.Visible = false
			end
		end
	end

	local origUpdateActivePanel = updateActivePanel
	updateActivePanel = function()
		origUpdateActivePanel()
		updateTabBadges()
	end

	local tooltipFrame = Instance.new("Frame")
	noHit(tooltipFrame)
	tooltipFrame.BackgroundColor3 = C.Surface
	tooltipFrame.BackgroundTransparency = 0.05
	tooltipFrame.Size = UDim2.new(0, 0, 0, math.floor(28 * SC))
	tooltipFrame.AutomaticSize = Enum.AutomaticSize.X
	tooltipFrame.ZIndex = 250
	tooltipFrame.Visible = false
	tooltipFrame.Parent = screenGui
	corner(tooltipFrame, 8)
	strokeInst(tooltipFrame, C.Border, 1, 0.4)
	addClayShadow(tooltipFrame, 8)

	local tooltipLabel = Instance.new("TextLabel")
	noHit(tooltipLabel)
	tooltipLabel.BackgroundTransparency = 1
	tooltipLabel.Size = UDim2.new(0, 0, 1, 0)
	tooltipLabel.AutomaticSize = Enum.AutomaticSize.X
	tooltipLabel.Font = Enum.Font.GothamMedium
	tooltipLabel.TextSize = math.floor(11 * SC)
	tooltipLabel.TextColor3 = C.Text
	tooltipLabel.TextTransparency = 0.1
	tooltipLabel.ZIndex = 251
	tooltipLabel.Parent = tooltipFrame
	pad(tooltipLabel, 4, 4, 10, 10)

	local tooltipVisible = false
	local tooltipTarget = nil
	local tooltipDelay = 0.6
	local tooltipTimer = 0

	function W:ShowTooltip(text, frame)
		tooltipLabel.Text = text
		tooltipTarget = frame
		tooltipVisible = true
		tooltipFrame.Visible = true
		tooltipFrame.GroupTransparency = 1
		tw(tooltipFrame, 0.2, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	function W:HideTooltip()
		tooltipVisible = false
		tw(tooltipFrame, 0.15, {GroupTransparency = 1}, Enum.EasingStyle.Quart)
		task.delay(0.15, function()
			if not tooltipVisible then
				tooltipFrame.Visible = false
			end
		end)
	end

	poolAdd(function(dt)
		if not tooltipFrame or not tooltipFrame.Parent then return false end
		if tooltipVisible and tooltipFrame.Visible then
			local mousePos = UserInputService:GetMouseLocation()
			tooltipFrame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - 32)
		end
		return true
	end)

	local miniMode = false
	local miniFrame = Instance.new("CanvasGroup")
	noHit(miniFrame)
	miniFrame.AnchorPoint = Vector2.new(0.5, 0)
	miniFrame.BackgroundColor3 = C.BG
	miniFrame.BackgroundTransparency = 0.1
	miniFrame.Position = UDim2.new(0.5, 0, 0, 16)
	miniFrame.Size = UDim2.new(0, math.floor(160 * SC), 0, math.floor(36 * SC))
	miniFrame.ZIndex = 60
	miniFrame.Visible = false
	miniFrame.Parent = screenGui
	corner(miniFrame, 10)
	strokeInst(miniFrame, C.Border, 1, 0.5)

	local miniAccent = Instance.new("Frame")
	noHit(miniAccent)
	miniAccent.BackgroundColor3 = C.Accent
	miniAccent.BackgroundTransparency = 0.5
	miniAccent.Size = UDim2.new(1, 0, 0, 2)
	miniAccent.ZIndex = 61
	miniAccent.Parent = miniFrame
	corner(miniAccent, 12)

	local miniText = Instance.new("TextLabel")
	noHit(miniText)
	miniText.BackgroundTransparency = 1
	miniText.Position = UDim2.new(0, 12, 0, 0)
	miniText.Size = UDim2.new(1, -48, 1, 0)
	miniText.Font = Enum.Font.GothamBold
	miniText.TextSize = math.floor(12 * SC)
	miniText.Text = title
	miniText.TextColor3 = C.Accent
	miniText.TextXAlignment = Enum.TextXAlignment.Left
	miniText.ZIndex = 62
	miniText.Parent = miniFrame

	local miniExpandBtn = Instance.new("TextButton")
	miniExpandBtn.AnchorPoint = Vector2.new(1, 0.5)
	miniExpandBtn.BackgroundColor3 = C.Surface
	miniExpandBtn.Position = UDim2.new(1, -8, 0.5, 0)
	miniExpandBtn.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(22 * SC))
	miniExpandBtn.Text = "+"
	miniExpandBtn.Font = Enum.Font.GothamBold
	miniExpandBtn.TextSize = math.floor(10 * SC)
	miniExpandBtn.TextColor3 = C.Text
	miniExpandBtn.AutoButtonColor = false
	miniExpandBtn.ZIndex = 63
	miniExpandBtn.Parent = miniFrame
	corner(miniExpandBtn, 6)

	miniExpandBtn.MouseButton1Click:Connect(function()
		if miniMode then
			W:ExitMiniMode()
		end
	end)

	makeDrag(miniFrame, miniFrame)

	local miniCountDot = Instance.new("Frame")
	noHit(miniCountDot)
	miniCountDot.AnchorPoint = Vector2.new(0, 0.5)
	miniCountDot.BackgroundColor3 = C.Ok
	miniCountDot.Position = UDim2.new(0, math.floor(130 * SC), 0.5, 0)
	miniCountDot.Size = UDim2.new(0, math.floor(8 * SC), 0, math.floor(8 * SC))
	miniCountDot.ZIndex = 62
	miniCountDot.Visible = false
	miniCountDot.Parent = miniFrame
	corner(miniCountDot, 99)

	local _miniAccum = 0
	poolAdd(function(dt)
		if not miniCountDot or not miniCountDot.Parent then return false end
		if not miniMode then return true end
		_miniAccum = _miniAccum + dt
		if _miniAccum < 0.5 then return true end
		_miniAccum = 0
		local count = 0
		for _, v in pairs(W._activeFeatures) do
			if v then count = count + 1 end
		end
		miniCountDot.Visible = count > 0
	end)

	function W:EnterMiniMode()
		miniMode = true
		playSound(Sounds.collapse, 0.08, 1.0)
		hideBlur()
		tw(main, 0.3, {GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			main.Visible = false
		end)
		miniFrame.Visible = true
		miniFrame.GroupTransparency = 1
		tw(miniFrame, 0.3, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	function W:ExitMiniMode()
		miniMode = false
		playSound(Sounds.expand, 0.08, 1.0)
		if blurEnabled then showBlur() end
		tw(miniFrame, 0.2, {GroupTransparency = 1}, Enum.EasingStyle.Quint)
		task.delay(0.2, function()
			miniFrame.Visible = false
		end)
		main.Visible = true
		main.GroupTransparency = 1
		tw(main, 0.35, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	function W:ToggleMiniMode()
		if miniMode then W:ExitMiniMode() else W:EnterMiniMode() end
	end

	local playerHudFrame = Instance.new("Frame")
	noHit(playerHudFrame)
	playerHudFrame.AnchorPoint = Vector2.new(0, 1)
	playerHudFrame.BackgroundColor3 = C.BG
	playerHudFrame.BackgroundTransparency = 0.12
	playerHudFrame.Position = UDim2.new(0, 16, 1, -16)
	playerHudFrame.Size = UDim2.new(0, math.floor(180 * SC), 0, math.floor(75 * SC))
	playerHudFrame.ZIndex = 55
	playerHudFrame.Visible = false
	playerHudFrame.Parent = screenGui
	corner(playerHudFrame, 10)
	strokeInst(playerHudFrame, C.Border, 1, 0.5)

	local hudAccent = Instance.new("Frame")
	noHit(hudAccent)
	hudAccent.BackgroundColor3 = C.Accent
	hudAccent.BackgroundTransparency = 0.6
	hudAccent.Size = UDim2.new(1, 0, 0, 2)
	hudAccent.ZIndex = 56
	hudAccent.Parent = playerHudFrame
	corner(hudAccent, 14)

	local hudName = Instance.new("TextLabel")
	noHit(hudName)
	hudName.BackgroundTransparency = 1
	hudName.Position = UDim2.new(0, 14, 0, 8)
	hudName.Size = UDim2.new(1, -28, 0, math.floor(18 * SC))
	hudName.Font = Enum.Font.GothamBold
	hudName.TextSize = math.floor(13 * SC)
	hudName.Text = "Player"
	hudName.TextColor3 = C.Text
	hudName.TextXAlignment = Enum.TextXAlignment.Left
	hudName.ZIndex = 56
	hudName.Parent = playerHudFrame

	local hudHealthBG = Instance.new("Frame")
	noHit(hudHealthBG)
	hudHealthBG.BackgroundColor3 = C.Surface
	hudHealthBG.Position = UDim2.new(0, 14, 0, math.floor(30 * SC))
	hudHealthBG.Size = UDim2.new(1, -28, 0, math.floor(8 * SC))
	hudHealthBG.ZIndex = 56
	hudHealthBG.Parent = playerHudFrame
	corner(hudHealthBG, 4)

	local hudHealthFill = Instance.new("Frame")
	noHit(hudHealthFill)
	hudHealthFill.BackgroundColor3 = C.Ok
	hudHealthFill.Size = UDim2.new(1, 0, 1, 0)
	hudHealthFill.ZIndex = 57
	hudHealthFill.Parent = hudHealthBG
	corner(hudHealthFill, 4)

	local hudHealthText = Instance.new("TextLabel")
	noHit(hudHealthText)
	hudHealthText.BackgroundTransparency = 1
	hudHealthText.Position = UDim2.new(0, 14, 0, math.floor(42 * SC))
	hudHealthText.Size = UDim2.new(1, -28, 0, math.floor(14 * SC))
	hudHealthText.Font = Enum.Font.GothamMedium
	hudHealthText.TextSize = math.floor(10 * SC)
	hudHealthText.Text = "HP: 100/100"
	hudHealthText.TextColor3 = C.Sub
	hudHealthText.TextXAlignment = Enum.TextXAlignment.Left
	hudHealthText.ZIndex = 56
	hudHealthText.Parent = playerHudFrame

	local hudPosText = Instance.new("TextLabel")
	noHit(hudPosText)
	hudPosText.BackgroundTransparency = 1
	hudPosText.Position = UDim2.new(0, 14, 0, math.floor(58 * SC))
	hudPosText.Size = UDim2.new(1, -28, 0, math.floor(14 * SC))
	hudPosText.Font = Enum.Font.GothamMedium
	hudPosText.TextSize = math.floor(10 * SC)
	hudPosText.Text = "Pos: 0, 0, 0"
	hudPosText.TextColor3 = C.Sub
	hudPosText.TextXAlignment = Enum.TextXAlignment.Left
	hudPosText.ZIndex = 56
	hudPosText.Parent = playerHudFrame

	local hudSpeedText = Instance.new("TextLabel")
	noHit(hudSpeedText)
	hudSpeedText.BackgroundTransparency = 1
	hudSpeedText.Position = UDim2.new(0, 14, 0, math.floor(72 * SC))
	hudSpeedText.Size = UDim2.new(1, -28, 0, math.floor(14 * SC))
	hudSpeedText.Font = Enum.Font.GothamMedium
	hudSpeedText.TextSize = math.floor(10 * SC)
	hudSpeedText.Text = "Speed: 16"
	hudSpeedText.TextColor3 = C.Sub
	hudSpeedText.TextXAlignment = Enum.TextXAlignment.Left
	hudSpeedText.ZIndex = 56
	hudSpeedText.Parent = playerHudFrame

	local _hudAccum = 0
	poolAdd(function(dt)
		if not playerHudFrame or not playerHudFrame.Parent then return false end
		if not playerHudFrame.Visible then return true end
		_hudAccum = _hudAccum + dt
		if _hudAccum < 0.15 then return true end
		_hudAccum = 0

		pcall(function()
			local char = Player.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local hp = math.floor(humanoid.Health)
					local maxHp = math.floor(humanoid.MaxHealth)
					local ratio = math.clamp(hp / maxHp, 0, 1)
					hudHealthText.Text = "HP: " .. hp .. "/" .. maxHp
					hudHealthFill.Size = UDim2.new(ratio, 0, 1, 0)

					if ratio > 0.6 then
						hudHealthFill.BackgroundColor3 = C.Ok
					elseif ratio > 0.3 then
						hudHealthFill.BackgroundColor3 = C.Warn
					else
						hudHealthFill.BackgroundColor3 = C.Err
					end

					hudSpeedText.Text = "Speed: " .. math.floor(humanoid.WalkSpeed)
				end

				local rootPart = char:FindFirstChild("HumanoidRootPart")
				if rootPart then
					local pos = rootPart.Position
					hudPosText.Text = "Pos: " .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z)
				end
			end

			hudName.Text = Player.DisplayName
		end)

		return true
	end)

	function W:SetPlayerHudVisible(vis)
		playerHudFrame.Visible = vis
	end

	W._quickActions = {}

	local quickBarFrame = Instance.new("Frame")
	noHit(quickBarFrame)
	quickBarFrame.AnchorPoint = Vector2.new(0.5, 1)
	quickBarFrame.BackgroundColor3 = C.BG
	quickBarFrame.BackgroundTransparency = 0.1
	quickBarFrame.Position = UDim2.new(0.5, 0, 1, -16)
	quickBarFrame.Size = UDim2.new(0, 0, 0, math.floor(36 * SC))
	quickBarFrame.AutomaticSize = Enum.AutomaticSize.X
	local qbSizeC = Instance.new("UISizeConstraint")
	qbSizeC.MaxSize = Vector2.new(math.floor(500 * SC), math.floor(36 * SC))
	qbSizeC.Parent = quickBarFrame
	quickBarFrame.ZIndex = 55
	quickBarFrame.Visible = false
	quickBarFrame.Parent = screenGui
	corner(quickBarFrame, 10)
	strokeInst(quickBarFrame, C.Border, 1, 0.5)
	pad(quickBarFrame, 6, 6, 8, 8)
	uiList(quickBarFrame, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center)

	function W:AddQuickAction(cfg)
		cfg = cfg or {}
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = C.Surface
		btn.BackgroundTransparency = 0.2
		btn.Size = UDim2.new(0, math.floor(34 * SC), 0, math.floor(28 * SC))
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 57
		btn.LayoutOrder = #W._quickActions + 1
		btn.Parent = quickBarFrame
		corner(btn, 8)

		local iconAsset = cfg.Icon and getIconAsset(cfg.Icon)
		if iconAsset then
			local ico = Instance.new("ImageLabel")
			noHit(ico)
			ico.BackgroundTransparency = 1
			ico.AnchorPoint = Vector2.new(0.5, 0.5)
			ico.Position = UDim2.new(0.5, 0, 0.5, 0)
			ico.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
			ico.Image = iconAsset
			ico.ImageColor3 = C.Accent
			ico.ScaleType = Enum.ScaleType.Fit
			ico.ZIndex = 58
			ico.Parent = btn
		else
			btn.Text = cfg.Label or "?"
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = math.floor(14 * SC)
			btn.TextColor3 = C.Accent
		end

		addHoverLift(btn, 2)

		btn.MouseButton1Click:Connect(function()
			playSound(Sounds.click, 0.08, 1.0)
			createRipple(btn, C.Accent)
			if cfg.Callback then
				task.spawn(cfg.Callback)
			end
		end)

		W._quickActions[#W._quickActions + 1] = btn
		quickBarFrame.Visible = #W._quickActions > 0
		return btn
	end

	function W:SetQuickBarVisible(vis)
		quickBarFrame.Visible = vis and #W._quickActions > 0
	end

	local changelogFrame = Instance.new("CanvasGroup")
	noHit(changelogFrame)
	changelogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	changelogFrame.BackgroundColor3 = C.BGAlt
	changelogFrame.BackgroundTransparency = 0.03
	changelogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	changelogFrame.Size = UDim2.new(0, math.floor(380 * SC), 0, math.floor(450 * SC))
	changelogFrame.ZIndex = 95
	changelogFrame.Visible = false
	changelogFrame.Parent = screenGui
	corner(changelogFrame, 18)
	strokeInst(changelogFrame, C.Border, 1, 0.3)
	addClayShadow(changelogFrame, 18)

	local clHeader = Instance.new("TextLabel")
	noHit(clHeader)
	clHeader.BackgroundTransparency = 1
	clHeader.Size = UDim2.new(1, 0, 0, math.floor(44 * SC))
	clHeader.Font = Enum.Font.GothamBold
	clHeader.TextSize = math.floor(16 * SC)
	clHeader.Text = "Changelog"
	clHeader.TextColor3 = C.Accent
	clHeader.ZIndex = 96
	clHeader.Parent = changelogFrame

	local clClose = Instance.new("TextButton")
	clClose.AnchorPoint = Vector2.new(1, 0)
	clClose.BackgroundTransparency = 1
	clClose.Position = UDim2.new(1, -10, 0, 8)
	clClose.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(28 * SC))
	clClose.Text = "X"
	clClose.Font = Enum.Font.GothamBold
	clClose.TextSize = math.floor(16 * SC)
	clClose.TextColor3 = C.Sub
	clClose.AutoButtonColor = false
	clClose.ZIndex = 97
	clClose.Parent = changelogFrame
	clClose.MouseButton1Click:Connect(function()
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(changelogFrame, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Quint)
		task.delay(0.25, function()
			changelogFrame.Visible = false
			changelogFrame.GroupTransparency = 0
		end)
	end)

	local clSep = Instance.new("Frame")
	noHit(clSep)
	clSep.BackgroundColor3 = C.Border
	clSep.BackgroundTransparency = 0.5
	clSep.Size = UDim2.new(1, -24, 0, 1)
	clSep.Position = UDim2.new(0, 12, 0, math.floor(44 * SC))
	clSep.ZIndex = 96
	clSep.Parent = changelogFrame

	local clScroll = Instance.new("ScrollingFrame")
	noHit(clScroll)
	clScroll.BackgroundTransparency = 1
	clScroll.Position = UDim2.new(0, 0, 0, math.floor(50 * SC))
	clScroll.Size = UDim2.new(1, 0, 1, -math.floor(50 * SC))
	clScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	clScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	clScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	clScroll.ScrollBarThickness = 3
	clScroll.ScrollBarImageColor3 = C.Accent
	clScroll.ScrollBarImageTransparency = 0.5
	clScroll.ZIndex = 96
	clScroll.Parent = changelogFrame
	pad(clScroll, 8, 8, 16, 16)
	uiList(clScroll, 8, Enum.FillDirection.Vertical)

	function W:ShowChangelog(entries)
		entries = entries or {}
		for _, c in pairs(clScroll:GetChildren()) do
			if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
		end

		for i, entry in ipairs(entries) do
			local versionFrame = Instance.new("Frame")
			noHit(versionFrame)
			versionFrame.BackgroundColor3 = C.AccentSub
			versionFrame.BackgroundTransparency = 0.5
			versionFrame.Size = UDim2.new(1, 0, 0, math.floor(28 * SC))
			versionFrame.LayoutOrder = i * 10
			versionFrame.ZIndex = 97
			versionFrame.Parent = clScroll
			corner(versionFrame, 8)

			local versionLabel = Instance.new("TextLabel")
			noHit(versionLabel)
			versionLabel.BackgroundTransparency = 1
			versionLabel.Position = UDim2.new(0, 10, 0, 0)
			versionLabel.Size = UDim2.new(0.5, 0, 1, 0)
			versionLabel.Font = Enum.Font.GothamBold
			versionLabel.TextSize = math.floor(12 * SC)
			versionLabel.Text = entry.Version or ""
			versionLabel.TextColor3 = C.Accent
			versionLabel.TextXAlignment = Enum.TextXAlignment.Left
			versionLabel.ZIndex = 98
			versionLabel.Parent = versionFrame

			local dateLabel = Instance.new("TextLabel")
			noHit(dateLabel)
			dateLabel.BackgroundTransparency = 1
			dateLabel.AnchorPoint = Vector2.new(1, 0)
			dateLabel.Position = UDim2.new(1, -10, 0, 0)
			dateLabel.Size = UDim2.new(0.4, 0, 1, 0)
			dateLabel.Font = Enum.Font.GothamMedium
			dateLabel.TextSize = math.floor(10 * SC)
			dateLabel.Text = entry.Date or ""
			dateLabel.TextColor3 = C.Sub
			dateLabel.TextXAlignment = Enum.TextXAlignment.Right
			dateLabel.ZIndex = 98
			dateLabel.Parent = versionFrame

			local changes = entry.Changes or {}
			for j, change in ipairs(changes) do
				local changeLabel = Instance.new("TextLabel")
				noHit(changeLabel)
				changeLabel.BackgroundTransparency = 1
				changeLabel.Size = UDim2.new(1, 0, 0, 0)
				changeLabel.AutomaticSize = Enum.AutomaticSize.Y
				changeLabel.Font = Enum.Font.GothamMedium
				changeLabel.TextSize = math.floor(11 * SC)
				changeLabel.Text = "  " .. change
				changeLabel.TextColor3 = C.Text
				changeLabel.TextTransparency = 0.15
				changeLabel.TextXAlignment = Enum.TextXAlignment.Left
				changeLabel.TextWrapped = true
				changeLabel.LayoutOrder = i * 10 + j
				changeLabel.ZIndex = 97
				changeLabel.Parent = clScroll
			end
		end

		changelogFrame.Visible = true
		changelogFrame.GroupTransparency = 1
		playSound(Sounds.expand, 0.08, 1.0)
		tw(changelogFrame, 0.3, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	local sessionStartTime = tick()
	W._sessionStart = sessionStartTime

	function W:GetSessionTime()
		local elapsed = tick() - sessionStartTime
		local hours = math.floor(elapsed / 3600)
		local minutes = math.floor((elapsed % 3600) / 60)
		local seconds = math.floor(elapsed % 60)
		if hours > 0 then
			return string.format("%dh %dm %ds", hours, minutes, seconds)
		elseif minutes > 0 then
			return string.format("%dm %ds", minutes, seconds)
		else
			return string.format("%ds", seconds)
		end
	end

	W._notifHistory = {}
	local MAX_NOTIF_HISTORY = 50

	local origNotify = W.Notify
	function W:Notify(nc)
		W._notifHistory[#W._notifHistory + 1] = {
			Title = nc.Title or "",
			Content = nc.Content or "",
			Type = nc.Type or "Info",
			Time = os.date("%H:%M:%S"),
		}
		while #W._notifHistory > MAX_NOTIF_HISTORY do
			table.remove(W._notifHistory, 1)
		end
		return origNotify(self, nc)
	end

	function W:GetNotifHistory()
		return W._notifHistory
	end

	local notifHistoryFrame = Instance.new("CanvasGroup")
	noHit(notifHistoryFrame)
	notifHistoryFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	notifHistoryFrame.BackgroundColor3 = C.BGAlt
	notifHistoryFrame.BackgroundTransparency = 0.03
	notifHistoryFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	notifHistoryFrame.Size = UDim2.new(0, math.floor(340 * SC), 0, math.floor(400 * SC))
	notifHistoryFrame.ZIndex = 95
	notifHistoryFrame.Visible = false
	notifHistoryFrame.Parent = screenGui
	corner(notifHistoryFrame, 18)
	strokeInst(notifHistoryFrame, C.Border, 1, 0.3)
	addClayShadow(notifHistoryFrame, 18)

	local nhHeader = Instance.new("TextLabel")
	noHit(nhHeader)
	nhHeader.BackgroundTransparency = 1
	nhHeader.Size = UDim2.new(1, 0, 0, math.floor(42 * SC))
	nhHeader.Font = Enum.Font.GothamBold
	nhHeader.TextSize = math.floor(15 * SC)
	nhHeader.Text = "Notification History"
	nhHeader.TextColor3 = C.Accent
	nhHeader.ZIndex = 96
	nhHeader.Parent = notifHistoryFrame

	local nhClose = Instance.new("TextButton")
	nhClose.AnchorPoint = Vector2.new(1, 0)
	nhClose.BackgroundTransparency = 1
	nhClose.Position = UDim2.new(1, -10, 0, 8)
	nhClose.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(28 * SC))
	nhClose.Text = "X"
	nhClose.Font = Enum.Font.GothamBold
	nhClose.TextSize = math.floor(16 * SC)
	nhClose.TextColor3 = C.Sub
	nhClose.AutoButtonColor = false
	nhClose.ZIndex = 97
	nhClose.Parent = notifHistoryFrame
	nhClose.MouseButton1Click:Connect(function()
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(notifHistoryFrame, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Quint)
		task.delay(0.25, function()
			notifHistoryFrame.Visible = false
			notifHistoryFrame.GroupTransparency = 0
		end)
	end)

	local nhScroll = Instance.new("ScrollingFrame")
	noHit(nhScroll)
	nhScroll.BackgroundTransparency = 1
	nhScroll.Position = UDim2.new(0, 0, 0, math.floor(48 * SC))
	nhScroll.Size = UDim2.new(1, 0, 1, -math.floor(48 * SC))
	nhScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	nhScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	nhScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	nhScroll.ScrollBarThickness = 3
	nhScroll.ScrollBarImageColor3 = C.Accent
	nhScroll.ScrollBarImageTransparency = 0.5
	nhScroll.ZIndex = 96
	nhScroll.Parent = notifHistoryFrame
	pad(nhScroll, 4, 8, 12, 12)
	uiList(nhScroll, 4, Enum.FillDirection.Vertical)

	function W:ShowNotifHistory()
		for _, c in pairs(nhScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end

		local typeColors = {
			Success = C.Ok,
			Warning = C.Warn,
			Error = C.Err,
			Info = C.Info,
		}

		local history = W._notifHistory
		for i = #history, 1, -1 do
			local entry = history[i]
			local row = Instance.new("Frame")
			noHit(row)
			row.BackgroundColor3 = C.Surface
			row.BackgroundTransparency = 0.4
			row.Size = UDim2.new(1, 0, 0, math.floor(42 * SC))
			row.LayoutOrder = #history - i + 1
			row.ZIndex = 97
			row.Parent = nhScroll
			corner(row, 8)

			local typeStripe = Instance.new("Frame")
			noHit(typeStripe)
			typeStripe.BackgroundColor3 = typeColors[entry.Type] or C.Info
			typeStripe.Position = UDim2.new(0, 0, 0, 0)
			typeStripe.Size = UDim2.new(1, 0, 0, 2)
			typeStripe.ZIndex = 98
			typeStripe.Parent = row
			corner(typeStripe, 8)

			local timeL = Instance.new("TextLabel")
			noHit(timeL)
			timeL.BackgroundTransparency = 1
			timeL.AnchorPoint = Vector2.new(1, 0)
			timeL.Position = UDim2.new(1, -8, 0, 4)
			timeL.Size = UDim2.new(0, 50, 0, 14)
			timeL.Font = Enum.Font.Code
			timeL.TextSize = math.floor(9 * SC)
			timeL.Text = entry.Time
			timeL.TextColor3 = C.Dim
			timeL.TextXAlignment = Enum.TextXAlignment.Right
			timeL.ZIndex = 98
			timeL.Parent = row

			local titleL = Instance.new("TextLabel")
			noHit(titleL)
			titleL.BackgroundTransparency = 1
			titleL.Position = UDim2.new(0, 12, 0, 4)
			titleL.Size = UDim2.new(0.7, 0, 0, 16)
			titleL.Font = Enum.Font.GothamBold
			titleL.TextSize = math.floor(11 * SC)
			titleL.Text = entry.Title
			titleL.TextColor3 = typeColors[entry.Type] or C.Text
			titleL.TextXAlignment = Enum.TextXAlignment.Left
			titleL.TextTruncate = Enum.TextTruncate.AtEnd
			titleL.ZIndex = 98
			titleL.Parent = row

			local contentL = Instance.new("TextLabel")
			noHit(contentL)
			contentL.BackgroundTransparency = 1
			contentL.Position = UDim2.new(0, 12, 0, 22)
			contentL.Size = UDim2.new(1, -24, 0, 16)
			contentL.Font = Enum.Font.GothamMedium
			contentL.TextSize = math.floor(10 * SC)
			contentL.Text = entry.Content
			contentL.TextColor3 = C.Sub
			contentL.TextXAlignment = Enum.TextXAlignment.Left
			contentL.TextTruncate = Enum.TextTruncate.AtEnd
			contentL.ZIndex = 98
			contentL.Parent = row
		end

		notifHistoryFrame.Visible = true
		notifHistoryFrame.GroupTransparency = 1
		playSound(Sounds.expand, 0.08, 1.0)
		tw(notifHistoryFrame, 0.3, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	W._elementStats = {
		Toggle = 0, Slider = 0, Dropdown = 0,
		Button = 0, Input = 0, Keybind = 0,
		ColorPicker = 0, Label = 0, Paragraph = 0,
		Separator = 0, Tab = 0, SubTab = 0, Group = 0,
	}

	function W:GetStats()
		local total = 0
		for _, v in pairs(W._elementStats) do
			total = total + v
		end
		return {
			Elements = total,
			Tabs = W._elementStats.Tab,
			SubTabs = W._elementStats.SubTab,
			Groups = W._elementStats.Group,
			ActiveFeatures = (function()
				local c = 0
				for _, v in pairs(W._activeFeatures) do
					if v then c = c + 1 end
				end
				return c
			end)(),
			Session = W:GetSessionTime(),
			NotifCount = #W._notifHistory,
		}
	end

	W._accentOverrides = {}

	function W:SetGlobalAccent(color)
		C.Accent = color
		C.AccentLit = Color3.new(
			math.min(color.R + 0.08, 1),
			math.min(color.G + 0.08, 1),
			math.min(color.B + 0.08, 1)
		)
		if false then
			local accentGrad = nil
			accentGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color),
				ColorSequenceKeypoint.new(0.5, C.ElecBlue),
				ColorSequenceKeypoint.new(1, C.Lilac),
			})
		end
	end

	local fpsGraphFrame = Instance.new("Frame")
	noHit(fpsGraphFrame)
	fpsGraphFrame.AnchorPoint = Vector2.new(0, 0)
	fpsGraphFrame.BackgroundColor3 = C.BGAlt
	fpsGraphFrame.BackgroundTransparency = 0.1
	fpsGraphFrame.Position = UDim2.new(0, 16, 0, math.floor(52 * SC))
	fpsGraphFrame.Size = UDim2.new(0, math.floor(120 * SC), 0, math.floor(30 * SC))
	fpsGraphFrame.ZIndex = 55
	fpsGraphFrame.Visible = false
	fpsGraphFrame.ClipsDescendants = true
	fpsGraphFrame.Parent = screenGui
	corner(fpsGraphFrame, 8)
	strokeInst(fpsGraphFrame, C.Border, 1, 0.5)

	local fpsGraphBars = {}
	local FPS_GRAPH_BARS = 30
	local fpsHistory = {}
	for i = 1, FPS_GRAPH_BARS do
		fpsHistory[i] = 60
		local bar = Instance.new("Frame")
		noHit(bar)
		bar.BackgroundColor3 = C.Ok
		bar.BackgroundTransparency = 0.3
		bar.AnchorPoint = Vector2.new(0, 1)
		bar.Position = UDim2.new((i - 1) / FPS_GRAPH_BARS, 0, 1, -2)
		bar.Size = UDim2.new(1 / FPS_GRAPH_BARS, -1, 0.5, 0)
		bar.ZIndex = 56
		bar.Parent = fpsGraphFrame
		fpsGraphBars[i] = bar
	end

	local fpsGraphLabel = Instance.new("TextLabel")
	noHit(fpsGraphLabel)
	fpsGraphLabel.BackgroundTransparency = 1
	fpsGraphLabel.Position = UDim2.new(0, 4, 0, 1)
	fpsGraphLabel.Size = UDim2.new(1, -8, 0, 12)
	fpsGraphLabel.Font = Enum.Font.Code
	fpsGraphLabel.TextSize = math.floor(8 * SC)
	fpsGraphLabel.Text = "FPS"
	fpsGraphLabel.TextColor3 = C.Sub
	fpsGraphLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsGraphLabel.ZIndex = 57
	fpsGraphLabel.Parent = fpsGraphFrame

	local fpsGraphCounter = 0
	poolAdd(function(dt)
		if not fpsGraphFrame or not fpsGraphFrame.Parent then return false end
		if not fpsGraphFrame.Visible then return true end
		fpsGraphCounter = fpsGraphCounter + dt
		if fpsGraphCounter < 0.25 then return true end
		fpsGraphCounter = 0

		local fps = math.floor(1 / math.max(dt, 0.001))
		table.remove(fpsHistory, 1)
		fpsHistory[FPS_GRAPH_BARS] = fps

		local maxFPS = 1
		for _, v in ipairs(fpsHistory) do
			if v > maxFPS then maxFPS = v end
		end

		for i, bar in ipairs(fpsGraphBars) do
			local ratio = math.clamp(fpsHistory[i] / maxFPS, 0.02, 1)
			bar.Size = UDim2.new(1 / FPS_GRAPH_BARS, -1, ratio * 0.85, 0)
			if fpsHistory[i] >= 50 then
				bar.BackgroundColor3 = C.Ok
			elseif fpsHistory[i] >= 30 then
				bar.BackgroundColor3 = C.Warn
			else
				bar.BackgroundColor3 = C.Err
			end
		end

		fpsGraphLabel.Text = "FPS " .. tostring(fps)
		return true
	end)

	function W:SetFpsGraphVisible(vis)
		fpsGraphFrame.Visible = vis
	end

	local crosshairFrame = Instance.new("Frame")
	noHit(crosshairFrame)
	crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshairFrame.BackgroundTransparency = 1
	crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	crosshairFrame.Size = UDim2.new(0, math.floor(40 * SC), 0, math.floor(40 * SC))
	crosshairFrame.ZIndex = 50
	crosshairFrame.Visible = false
	crosshairFrame.Parent = screenGui

	local chSize = math.floor(12 * SC)
	local chThick = math.floor(2 * SC)
	local chGap = math.floor(4 * SC)
	local chColor = Color3.new(1, 1, 1)

	local chTop = Instance.new("Frame")
	noHit(chTop)
	chTop.AnchorPoint = Vector2.new(0.5, 1)
	chTop.BackgroundColor3 = chColor
	chTop.Position = UDim2.new(0.5, 0, 0.5, -chGap)
	chTop.Size = UDim2.new(0, chThick, 0, chSize)
	chTop.ZIndex = 51
	chTop.Parent = crosshairFrame

	local chBot = Instance.new("Frame")
	noHit(chBot)
	chBot.AnchorPoint = Vector2.new(0.5, 0)
	chBot.BackgroundColor3 = chColor
	chBot.Position = UDim2.new(0.5, 0, 0.5, chGap)
	chBot.Size = UDim2.new(0, chThick, 0, chSize)
	chBot.ZIndex = 51
	chBot.Parent = crosshairFrame

	local chLeft = Instance.new("Frame")
	noHit(chLeft)
	chLeft.AnchorPoint = Vector2.new(1, 0.5)
	chLeft.BackgroundColor3 = chColor
	chLeft.Position = UDim2.new(0.5, -chGap, 0.5, 0)
	chLeft.Size = UDim2.new(0, chSize, 0, chThick)
	chLeft.ZIndex = 51
	chLeft.Parent = crosshairFrame

	local chRight = Instance.new("Frame")
	noHit(chRight)
	chRight.AnchorPoint = Vector2.new(0, 0.5)
	chRight.BackgroundColor3 = chColor
	chRight.Position = UDim2.new(0.5, chGap, 0.5, 0)
	chRight.Size = UDim2.new(0, chSize, 0, chThick)
	chRight.ZIndex = 51
	chRight.Parent = crosshairFrame

	local chDot = Instance.new("Frame")
	noHit(chDot)
	chDot.AnchorPoint = Vector2.new(0.5, 0.5)
	chDot.BackgroundColor3 = chColor
	chDot.Position = UDim2.new(0.5, 0, 0.5, 0)
	chDot.Size = UDim2.new(0, chThick + 1, 0, chThick + 1)
	chDot.ZIndex = 52
	chDot.Parent = crosshairFrame
	corner(chDot, 99)

	function W:SetCrosshairVisible(vis)
		crosshairFrame.Visible = vis
	end

	function W:SetCrosshairColor(col)
		chColor = col
		chTop.BackgroundColor3 = col
		chBot.BackgroundColor3 = col
		chLeft.BackgroundColor3 = col
		chRight.BackgroundColor3 = col
		chDot.BackgroundColor3 = col
	end

	function W:SetCrosshairSize(size, gap, thickness)
		local sz = math.floor(size * SC)
		local gp = math.floor(gap * SC)
		local th = math.floor(thickness * SC)
		chTop.Size = UDim2.new(0, th, 0, sz)
		chTop.Position = UDim2.new(0.5, 0, 0.5, -gp)
		chBot.Size = UDim2.new(0, th, 0, sz)
		chBot.Position = UDim2.new(0.5, 0, 0.5, gp)
		chLeft.Size = UDim2.new(0, sz, 0, th)
		chLeft.Position = UDim2.new(0.5, -gp, 0.5, 0)
		chRight.Size = UDim2.new(0, sz, 0, th)
		chRight.Position = UDim2.new(0.5, gp, 0.5, 0)
		chDot.Size = UDim2.new(0, th + 1, 0, th + 1)
	end

	local perfFrame = Instance.new("Frame")
	noHit(perfFrame)
	perfFrame.AnchorPoint = Vector2.new(1, 1)
	perfFrame.BackgroundColor3 = C.BG
	perfFrame.BackgroundTransparency = 0.12
	perfFrame.Position = UDim2.new(1, -16, 1, -16)
	perfFrame.Size = UDim2.new(0, math.floor(160 * SC), 0, math.floor(65 * SC))
	perfFrame.ZIndex = 55
	perfFrame.Visible = false
	perfFrame.Parent = screenGui
	corner(perfFrame, 10)
	strokeInst(perfFrame, C.Border, 1, 0.5)

	local perfTitle = Instance.new("TextLabel")
	noHit(perfTitle)
	perfTitle.BackgroundTransparency = 1
	perfTitle.Position = UDim2.new(0, 10, 0, 4)
	perfTitle.Size = UDim2.new(1, -20, 0, 16)
	perfTitle.Font = Enum.Font.GothamBold
	perfTitle.TextSize = math.floor(10 * SC)
	perfTitle.Text = "Performance"
	perfTitle.TextColor3 = C.Accent
	perfTitle.TextXAlignment = Enum.TextXAlignment.Left
	perfTitle.ZIndex = 56
	perfTitle.Parent = perfFrame

	local perfMemory = Instance.new("TextLabel")
	noHit(perfMemory)
	perfMemory.BackgroundTransparency = 1
	perfMemory.Position = UDim2.new(0, 10, 0, 22)
	perfMemory.Size = UDim2.new(1, -20, 0, 14)
	perfMemory.Font = Enum.Font.Code
	perfMemory.TextSize = math.floor(10 * SC)
	perfMemory.Text = "Memory: 0 MB"
	perfMemory.TextColor3 = C.Sub
	perfMemory.TextXAlignment = Enum.TextXAlignment.Left
	perfMemory.ZIndex = 56
	perfMemory.Parent = perfFrame

	local perfHeartbeat = Instance.new("TextLabel")
	noHit(perfHeartbeat)
	perfHeartbeat.BackgroundTransparency = 1
	perfHeartbeat.Position = UDim2.new(0, 10, 0, 38)
	perfHeartbeat.Size = UDim2.new(1, -20, 0, 14)
	perfHeartbeat.Font = Enum.Font.Code
	perfHeartbeat.TextSize = math.floor(10 * SC)
	perfHeartbeat.Text = "Heartbeat: 0ms"
	perfHeartbeat.TextColor3 = C.Sub
	perfHeartbeat.TextXAlignment = Enum.TextXAlignment.Left
	perfHeartbeat.ZIndex = 56
	perfHeartbeat.Parent = perfFrame

	local perfInstances = Instance.new("TextLabel")
	noHit(perfInstances)
	perfInstances.BackgroundTransparency = 1
	perfInstances.Position = UDim2.new(0, 10, 0, 54)
	perfInstances.Size = UDim2.new(1, -20, 0, 14)
	perfInstances.Font = Enum.Font.Code
	perfInstances.TextSize = math.floor(10 * SC)
	perfInstances.Text = "Instances: 0"
	perfInstances.TextColor3 = C.Sub
	perfInstances.TextXAlignment = Enum.TextXAlignment.Left
	perfInstances.ZIndex = 56
	perfInstances.Parent = perfFrame

	local perfCounter = 0
	poolAdd(function(dt)
		if not perfFrame or not perfFrame.Parent then return false end
		if not perfFrame.Visible then return true end
		perfCounter = perfCounter + dt
		if perfCounter < 1 then return true end
		perfCounter = 0

		pcall(function()
			local mem = math.floor(collectgarbage("count") / 1024 * 10) / 10
			perfMemory.Text = "Memory: " .. tostring(mem) .. " MB"

			local hb = math.floor(dt * 1000 * 10) / 10
			perfHeartbeat.Text = "Heartbeat: " .. tostring(hb) .. "ms"

			local instCount = 0
			pcall(function()
				instCount = #screenGui:GetDescendants()
			end)
			perfInstances.Text = "Instances: " .. tostring(instCount)
		end)

		return true
	end)

	function W:SetPerfMonitorVisible(vis)
		perfFrame.Visible = vis
	end

	function W:GetIconAsset(name)
		return getIconAsset(name)
	end

	function W:HasIcon(name)
		return IconAssets[name] ~= nil
	end

	function W:ListIconCategories()
		return {"action", "navigation", "notification", "home", "hardware", "maps", "device", "alert", "toggle", "editor", "media", "image", "communication", "file", "social", "content", "places"}
	end

	function W:CreateIconImage(parent, iconName, size, color, zIdx)
		return createIconImage(parent, iconName, size, color, zIdx)
	end

	function W:GetIconCount()
		local count = 0
		for _ in pairs(IconAssets) do count = count + 1 end
		return count
	end

	function W:Confirm(opts)
		opts = opts or {}
		local confirmed = false
		local dialogDone = false

		local overlay = Instance.new("TextButton")
		overlay.BackgroundColor3 = Color3.new(0, 0, 0)
		overlay.BackgroundTransparency = 0.4
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.Text = ""
		overlay.ZIndex = 150
		overlay.AutoButtonColor = false
		overlay.Parent = screenGui

		local dialog = Instance.new("Frame")
		dialog.AnchorPoint = Vector2.new(0.5, 0.5)
		dialog.BackgroundColor3 = C.BGAlt
		dialog.BackgroundTransparency = 0.03
		dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
		dialog.Size = UDim2.new(0, math.floor(280 * SC), 0, 0)
		dialog.ZIndex = 151
		dialog.ClipsDescendants = true
		dialog.Parent = screenGui
		corner(dialog, 18)
		strokeInst(dialog, C.Border, 1, 0.3)
		addClayShadow(dialog, 18)

		local dTitle = Instance.new("TextLabel")
		noHit(dTitle)
		dTitle.BackgroundTransparency = 1
		dTitle.Size = UDim2.new(1, 0, 0, math.floor(36 * SC))
		dTitle.Font = Enum.Font.GothamBold
		dTitle.TextSize = math.floor(15 * SC)
		dTitle.Text = opts.Title or "Confirm"
		dTitle.TextColor3 = C.Text
		dTitle.ZIndex = 152
		dTitle.Parent = dialog

		local dMsg = Instance.new("TextLabel")
		noHit(dMsg)
		dMsg.BackgroundTransparency = 1
		dMsg.Position = UDim2.new(0, 16, 0, math.floor(36 * SC))
		dMsg.Size = UDim2.new(1, -32, 0, math.floor(40 * SC))
		dMsg.Font = Enum.Font.GothamMedium
		dMsg.TextSize = math.floor(12 * SC)
		dMsg.Text = opts.Message or "Are you sure?"
		dMsg.TextColor3 = C.Sub
		dMsg.TextWrapped = true
		dMsg.ZIndex = 152
		dMsg.Parent = dialog

		local btnRow = Instance.new("Frame")
		noHit(btnRow)
		btnRow.BackgroundTransparency = 1
		btnRow.Position = UDim2.new(0, 16, 0, math.floor(82 * SC))
		btnRow.Size = UDim2.new(1, -32, 0, math.floor(32 * SC))
		btnRow.ZIndex = 152
		btnRow.Parent = dialog
		uiList(btnRow, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center)

		local cancelBtn = Instance.new("TextButton")
		cancelBtn.BackgroundColor3 = C.Surface
		cancelBtn.Size = UDim2.new(0, math.floor(100 * SC), 0, math.floor(30 * SC))
		cancelBtn.Text = "Cancel"
		cancelBtn.Font = Enum.Font.GothamBold
		cancelBtn.TextSize = math.floor(12 * SC)
		cancelBtn.TextColor3 = C.Sub
		cancelBtn.AutoButtonColor = false
		cancelBtn.ZIndex = 153
		cancelBtn.Parent = btnRow
		corner(cancelBtn, 8)

		local confirmBtn = Instance.new("TextButton")
		confirmBtn.BackgroundColor3 = opts.Type == "danger" and C.Err or C.Ok
		confirmBtn.Size = UDim2.new(0, math.floor(100 * SC), 0, math.floor(30 * SC))
		confirmBtn.Text = opts.ConfirmText or "Confirm"
		confirmBtn.Font = Enum.Font.GothamBold
		confirmBtn.TextSize = math.floor(12 * SC)
		confirmBtn.TextColor3 = Color3.new(1, 1, 1)
		confirmBtn.AutoButtonColor = false
		confirmBtn.ZIndex = 153
		confirmBtn.Parent = btnRow
		corner(confirmBtn, 8)

		playSound(Sounds.expand, 0.08, 1.1)
		tw(dialog, 0.3, {Size = UDim2.new(0, math.floor(280 * SC), 0, math.floor(124 * SC))}, Enum.EasingStyle.Back)

		local function closeDialog(result)
			if dialogDone then return end
			dialogDone = true
			confirmed = result
			playSound(Sounds.collapse, 0.06, 1.2)
			tw(dialog, 0.2, {Size = UDim2.new(0, math.floor(280 * SC), 0, 0)}, Enum.EasingStyle.Quint)
			tw(overlay, 0.2, {BackgroundTransparency = 1})
			task.delay(0.25, function()
				overlay:Destroy()
				dialog:Destroy()
			end)
			if result and opts.OnConfirm then
				task.spawn(opts.OnConfirm)
			elseif not result and opts.OnCancel then
				task.spawn(opts.OnCancel)
			end
		end

		cancelBtn.MouseButton1Click:Connect(function() closeDialog(false) end)
		confirmBtn.MouseButton1Click:Connect(function() closeDialog(true) end)
		overlay.MouseButton1Click:Connect(function() closeDialog(false) end)
	end

	function W:ShowProgress(opts)
		opts = opts or {}
		local duration = opts.Duration or 3
		local text = opts.Text or "Loading..."

		local progFrame = Instance.new("Frame")
		noHit(progFrame)
		progFrame.AnchorPoint = Vector2.new(0.5, 0)
		progFrame.BackgroundColor3 = C.BGAlt
		progFrame.BackgroundTransparency = 0.05
		progFrame.Position = UDim2.new(0.5, 0, 0, 16)
		progFrame.Size = UDim2.new(0, math.floor(260 * SC), 0, math.floor(48 * SC))
		progFrame.ZIndex = 80
		progFrame.Parent = screenGui
		corner(progFrame, 12)
		strokeInst(progFrame, C.Border, 1, 0.4)
		addClayShadow(progFrame, 12)

		local progText = Instance.new("TextLabel")
		noHit(progText)
		progText.BackgroundTransparency = 1
		progText.Position = UDim2.new(0, 14, 0, 4)
		progText.Size = UDim2.new(1, -28, 0, 18)
		progText.Font = Enum.Font.GothamBold
		progText.TextSize = math.floor(11 * SC)
		progText.Text = text
		progText.TextColor3 = C.Text
		progText.TextXAlignment = Enum.TextXAlignment.Left
		progText.ZIndex = 81
		progText.Parent = progFrame

		local progBarBG = Instance.new("Frame")
		noHit(progBarBG)
		progBarBG.BackgroundColor3 = C.Surface
		progBarBG.Position = UDim2.new(0, 14, 0, 28)
		progBarBG.Size = UDim2.new(1, -28, 0, math.floor(8 * SC))
		progBarBG.ZIndex = 81
		progBarBG.Parent = progFrame
		corner(progBarBG, 4)

		local progBarFill = Instance.new("Frame")
		noHit(progBarFill)
		progBarFill.BackgroundColor3 = opts.Color or C.Accent
		progBarFill.Size = UDim2.new(0, 0, 1, 0)
		progBarFill.ZIndex = 82
		progBarFill.Parent = progBarBG
		corner(progBarFill, 4)

		local percentLabel = Instance.new("TextLabel")
		noHit(percentLabel)
		percentLabel.BackgroundTransparency = 1
		percentLabel.AnchorPoint = Vector2.new(1, 0)
		percentLabel.Position = UDim2.new(1, -14, 0, 4)
		percentLabel.Size = UDim2.new(0, 40, 0, 18)
		percentLabel.Font = Enum.Font.Code
		percentLabel.TextSize = math.floor(10 * SC)
		percentLabel.Text = "0%"
		percentLabel.TextColor3 = C.Sub
		percentLabel.TextXAlignment = Enum.TextXAlignment.Right
		percentLabel.ZIndex = 81
		percentLabel.Parent = progFrame

		tw(progBarFill, duration, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Linear)

		local startTime = tick()
		local progPoolId = poolAdd(function(dt)
			if not progFrame or not progFrame.Parent then return false end
			local elapsed = tick() - startTime
			local pct = math.clamp(elapsed / duration, 0, 1)
			percentLabel.Text = math.floor(pct * 100) .. "%"
			if pct >= 1 then
				return false
			end
			return true
		end)

		task.delay(duration + 0.5, function()
			if progFrame and progFrame.Parent then
				tw(progFrame, 0.25, {BackgroundTransparency = 1})
				task.delay(0.3, function()
					if progFrame and progFrame.Parent then progFrame:Destroy() end
				end)
			end
			if opts.OnComplete then task.spawn(opts.OnComplete) end
		end)

		return {
			SetText = function(_, t) progText.Text = t end,
			SetProgress = function(_, pct)
				progBarFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
				percentLabel.Text = math.floor(pct * 100) .. "%"
			end,
			Dismiss = function()
				if progFrame and progFrame.Parent then
					progFrame:Destroy()
				end
			end,
		}
	end

	function W:SetTabBadge(tabName, count)
		if count and count > 0 then
			W._activeFeatures["[" .. tabName .. " Badge]"] = false
		end
		for tName, badge in pairs(W._tabBadges) do
			if tName == tabName then
				if count and count > 0 then
					badge.Visible = true
					badge._label.Text = tostring(count)
				else
					badge.Visible = false
				end
			end
		end
	end

	W._lastPosition = nil

	function W:SavePosition()
		if main then
			W._lastPosition = main.Position
		end
	end

	function W:RestorePosition()
		if W._lastPosition and main then
			main.Position = W._lastPosition
		end
	end

	function W:SetFlags(flagTable)
		for flag, value in pairs(flagTable) do
			local api = W._flags[flag]
			if api and api.Set then
				pcall(api.Set, api, value)
			end
		end
	end

	function W:GetFlags()
		local result = {}
		for flag, api in pairs(W._flags) do
			if api.Get then
				local ok, val = pcall(api.Get, api)
				if ok then result[flag] = val end
			end
		end
		return result
	end

	function W:ResetFlag(flag)
		local api = W._flags[flag]
		if api and api.Set then
			pcall(api.Set, api, false)
		end
	end

	function W:ResetAllFlags()
		for flag, api in pairs(W._flags) do
			if api.Set then
				pcall(api.Set, api, false)
			end
		end
	end

	W._scheduledTasks = {}

	function W:Schedule(name, delay, callback, repeating)
		if W._scheduledTasks[name] then
			W._scheduledTasks[name].cancelled = true
		end

		local taskInfo = {
			name = name,
			delay = delay,
			callback = callback,
			repeating = repeating or false,
			cancelled = false,
		}
		W._scheduledTasks[name] = taskInfo

		task.spawn(function()
			if repeating then
				while not taskInfo.cancelled do
					task.wait(delay)
					if not taskInfo.cancelled then
						pcall(callback)
					end
				end
			else
				task.wait(delay)
				if not taskInfo.cancelled then
					pcall(callback)
				end
			end
		end)

		return taskInfo
	end

	function W:CancelScheduled(name)
		if W._scheduledTasks[name] then
			W._scheduledTasks[name].cancelled = true
			W._scheduledTasks[name] = nil
		end
	end

	function W:CancelAllScheduled()
		for name, info in pairs(W._scheduledTasks) do
			info.cancelled = true
		end
		W._scheduledTasks = {}
	end

	pcall(function()
		if makefolder then
			local dirName = W.Config.HubName
			if isfolder and not isfolder(dirName) then
				makefolder(dirName)
			elseif not isfolder then
				makefolder(dirName)
			end
		end
	end)

	function W:FinishSetup()
		if not W.Config._loaded then
			pcall(function() W.Config:AutoLoad() end)
		end
		if not W.Config:GetAutoSaveStatus() then
			W.Config:EnableAutoSave(30)
		end
		W.AutoSaveEnabled = true
		if updateActivePanel then pcall(updateActivePanel) end

		task.defer(function()
			local autoMin = false
			pcall(function()
				local flag = W.Config.Flags["UIAutoMinimize"]
				if flag and flag.Get then autoMin = flag:Get() end
			end)
			if autoMin and not miniMode then
				W:EnterMiniMode()
			end
		end)
	end

	task.delay(3, function()
		if not W.Config._loaded then
			pcall(function() W:FinishSetup() end)
		end
	end)

	_G.__ExpensiveHub_Cleanup = function()
		for _, conn in pairs(W._conns) do
			pcall(function() conn:Disconnect() end)
		end
		pcall(function() hideBlur(); destroyBlur() end)
		pcall(function() screenGui:Destroy() end)
	end

	function W:SetAnimations(enabled)
		ANIM_ENABLED = enabled
		if not enabled then
			for k in pairs(Pool) do
				Pool[k] = nil
			end
			if bgMaster and bgMaster.Parent then
				for _, container in pairs(bgPresets) do
					container.Visible = false
				end
			end
		else
			if bgMaster and bgMaster.Parent then
				W:SetBackground(activeBG)
			end
		end
	end

	function W:GetAnimations()
		return ANIM_ENABLED
	end

	return W
end

return Library
end)()

-- ════════════════════════════════════════════════════════════════════════════
--  HOW TO USE:
--  In your script, keep everything down to and including:
--        return Library
--        end)()
--  Delete everything AFTER that line and paste this whole file in its place.
-- ════════════════════════════════════════════════════════════════════════════

-- ── SERVICES ──────────────────────────────────────────────────────────────────
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local CoreGui     = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local IS_MOBILE   = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ── WINDOW ────────────────────────────────────────────────────────────────────
local WINDOW_TITLE = "Slime Hub"
local Window = Library:CreateWindow({
    Title      = WINDOW_TITLE,
    Keybind    = Enum.KeyCode.RightControl,
    ConfigName = "GPOHub",
    Intro      = false,
})
local Config = Window.Config
-- start with the menu hidden; it only opens when you press the keybind
do
    local function findMain()
        for _, root in ipairs({game:GetService("CoreGui"), LocalPlayer:FindFirstChildOfClass("PlayerGui")}) do
            local gui = root and root:FindFirstChild("ExpensiveHub")
            if gui and gui:FindFirstChild("Main") then return gui.Main end
        end
    end
    local main = findMain()
    if main then
        main.Visible = false
        Window.Visible = false   -- so the first keybind press SHOWS it (instead of hiding)
        task.delay(0.7, function() -- after the library's own open animation has finished
            if main and main.Parent then main.GroupTransparency = 1 end
        end)
    end
end
-- the original grayscale look, registered as a selectable theme so the
-- Theme dropdown starts on it and nothing changes visually on first run
Window.ThemePresets["Original"] = {
    BG      = Color3.fromRGB(12, 12, 12),
    Surface = Color3.fromRGB(26, 26, 26),
    Border  = Color3.fromRGB(48, 48, 48),
    Text    = Color3.fromRGB(235, 235, 235),
    Sub     = Color3.fromRGB(160, 160, 160),
    Accent  = Color3.fromRGB(220, 220, 220),
    Ok      = Color3.fromRGB(220, 220, 220),
}
Window.CurrentTheme = "Original"

-- ── BRANDING (rename "Angel Ware") ────────────────────────────────────────────
-- The library hardcodes "Angel Ware" in a few places, so we find those labels
-- once right after the window is built and rewrite them when the name changes.
local DEFAULT_LOGO_RICH = '<font color="rgb(255,255,255)">Angel</font> <font color="rgb(30,30,30)">Ware</font>'
local brand = {
    custom  = false,
    name    = "",
    logo    = nil,  -- title bar logo text
    short   = {},   -- background labels that say "ANGEL"
    full    = {},   -- background labels that say "ANGEL WARE"
    plain   = {},   -- footer + mini-mode labels that say the window title
    wm      = nil,  -- watermark label
}

local function getGui()
    for _, root in ipairs({CoreGui, LocalPlayer:FindFirstChildOfClass("PlayerGui")}) do
        local gui = root and root:FindFirstChild("ExpensiveHub")
        if gui then return gui end
    end
    return nil
end

local function collectBrand()
    local gui = getGui()
    if not gui then return end
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextLabel") then
            local t = d.Text
            if d.RichText and d.Parent and d.Parent.Name == "Topbar" and t:find("Angel", 1, true) then
                brand.logo = d
            elseif t == "ANGEL" then
                brand.short[#brand.short + 1] = d
            elseif t == "ANGEL WARE" then
                brand.full[#brand.full + 1] = d
            elseif t == WINDOW_TITLE then
                brand.plain[#brand.plain + 1] = d
            elseif t:sub(1, #WINDOW_TITLE + 3) == WINDOW_TITLE .. " | " or t:sub(1, #WINDOW_TITLE + 5) == WINDOW_TITLE .. "  |  " then
                brand.wm = d
            end
        end
    end
end

local function xmlEscape(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function richLogo(name)
    local first, rest = name:match("^(%S+)%s*(.*)$")
    first = xmlEscape(first or name)
    if rest and rest ~= "" then
        return ('<font color="rgb(255,255,255)">%s</font> <font color="rgb(150,150,150)">%s</font>'):format(first, xmlEscape(rest))
    end
    return ('<font color="rgb(255,255,255)">%s</font>'):format(first)
end

local function applyBrand()
    local name = brand.custom and brand.name or nil

    if brand.logo and brand.logo.Parent then
        brand.logo.Text = name and richLogo(name) or DEFAULT_LOGO_RICH
    end

    local firstWord = name and (name:match("^%S+") or name):upper() or "ANGEL"
    for _, l in ipairs(brand.short) do
        if l.Parent then l.Text = firstWord end
    end
    for _, l in ipairs(brand.full) do
        if l.Parent then l.Text = name and name:upper() or "ANGEL WARE" end
    end
    for _, l in ipairs(brand.plain) do
        if l.Parent then l.Text = name or WINDOW_TITLE end
    end

    -- watermark: swap the prefix right now; the hook below keeps it swapped
    local wm = brand.wm
    if wm and wm.Parent and name then
        local t = wm.Text
        if t:sub(1, #WINDOW_TITLE) == WINDOW_TITLE then
            wm.Text = name .. t:sub(#WINDOW_TITLE + 1)
        end
    end
end

local function setBrand(v)
    local s = tostring(v or ""):gsub("^%s+", ""):gsub("%s+$", "")
    s = s:sub(1, 24)
    if s == "" then
        brand.custom = false
        brand.name = ""
    else
        brand.custom = true
        brand.name = s
    end
    applyBrand()
end

collectBrand()
brand.custom = true
brand.name = "Slime Hub"
applyBrand()

-- ══════════════════════════════════════════════════════════════════════════════
--  UI
-- ══════════════════════════════════════════════════════════════════════════════
local function note(title, content, kind)
    Window:Notify({Title = title, Content = content or "", Type = kind or "Success", Duration = 3})
end

-- ── SETTINGS (everything the library exposes) ─────────────────────────────────
local SetTab = Window:CreateTab({Name="Settings", Icon="settings"})

-- ·· Interface ················································································
local UI = SetTab:CreateSubTab({Name="Interface"})

local gTheme = UI:CreateGroup({Name="Theme & Background", Icon="palette"})
gTheme:CreateDropdown({Name="Theme", Options=Window:GetThemeNames(), Default="Original", Flag="Theme",
    Callback=function(v)
        if v ~= Window.CurrentTheme then Window:SetTheme(v) end
        applyBrand() -- SetTheme rewrites the title bar logo, so put the name back
    end})
gTheme:CreateDropdown({Name="Background", Options=Window:GetBackgroundNames(), Default="matrix", Flag="Background",
    Callback=function(v) Window:SetBackground(v) end})
gTheme:CreateToggle({Name="Show Background", Default=true, Flag="ShowBG", HideFromActive=true,
    Callback=function(v) Window:SetBGVisible(v) end})
gTheme:CreateToggle({Name="Animations", Default=true, Flag="Animations", HideFromActive=true,
    Callback=function(v) Window:SetAnimations(v) end})
gTheme:CreateToggle({Name="Background Blur", Default=false, Flag="Blur", HideFromActive=true,
    Callback=function(v) Window:SetBlurEnabled(v) end})
gTheme:CreateSlider({Name="UI Scale", Min=50, Max=150, Increment=5, Default=IS_MOBILE and 80 or 100, Suffix="%", Flag="UIScale",
    Callback=function(v) Window:SetUIScale(v/100) end})

local gShow = UI:CreateGroup({Name="Window Elements", Icon="visibility"})
gShow:CreateToggle({Name="Watermark", Default=true, Flag="Watermark", HideFromActive=true,
    Callback=function(v) Window:SetWatermarkVisible(v) end})
gShow:CreateToggle({Name="Footer Bar", Default=true, Flag="Footer", HideFromActive=true,
    Callback=function(v) Window:SetFooterVisible(v) end})
gShow:CreateToggle({Name="Active Features Panel", Default=true, Flag="ActivePanel", HideFromActive=true,
    Callback=function(v) Window:SetActivePanelVisible(v) end})
gShow:CreateToggle({Name="Quick Action Bar", Default=true, Flag="QuickBar", HideFromActive=true,
    Callback=function(v) Window:SetQuickBarVisible(v) end})

local gSnd = UI:CreateGroup({Name="Sound", Icon="volume_up"})
gSnd:CreateToggle({Name="UI Sounds", Default=true, Flag="Sounds", HideFromActive=true,
    Callback=function(v) Window:SetSoundsEnabled(v) end})
gSnd:CreateDropdown({Name="Sound Pack", Options=Window:GetSoundPackNames(), Default="Default", Flag="SoundPack",
    Callback=function(v) Window:SetSoundPack(v) end})

-- ·· Overlays ·················································································
local OV = SetTab:CreateSubTab({Name="Overlays"})

local gHud = OV:CreateGroup({Name="Monitors", Icon="speed"})
gHud:CreateToggle({Name="FPS Graph", Default=false, Flag="FpsGraph", HideFromActive=true,
    Callback=function(v) Window:SetFpsGraphVisible(v) end})
gHud:CreateToggle({Name="Performance Monitor", Default=false, Flag="PerfMon", HideFromActive=true,
    Callback=function(v) Window:SetPerfMonitorVisible(v) end})
gHud:CreateToggle({Name="Player HUD", Default=false, Flag="PlayerHud", HideFromActive=true,
    Callback=function(v) Window:SetPlayerHudVisible(v) end})

local chS, chG, chT = 12, 4, 2
local gCh = OV:CreateGroup({Name="Crosshair", Icon="center_focus_strong"})
gCh:CreateToggle({Name="Crosshair", Default=false, Flag="Crosshair", HideFromActive=true,
    Callback=function(v) Window:SetCrosshairVisible(v) end})
gCh:CreateColorPicker({Name="Crosshair Color", Default=Color3.new(1,1,1), Flag="CrosshairColor",
    Callback=function(c) Window:SetCrosshairColor(c) end})
gCh:CreateSlider({Name="Length", Min=2, Max=30, Default=chS, Flag="CrosshairLen",
    Callback=function(v) chS = v; Window:SetCrosshairSize(chS, chG, chT) end})
gCh:CreateSlider({Name="Gap", Min=0, Max=20, Default=chG, Flag="CrosshairGap",
    Callback=function(v) chG = v; Window:SetCrosshairSize(chS, chG, chT) end})
gCh:CreateSlider({Name="Thickness", Min=1, Max=6, Default=chT, Flag="CrosshairThick",
    Callback=function(v) chT = v; Window:SetCrosshairSize(chS, chG, chT) end})

-- ·· Keybinds & Windows ·······················································································
local KB = SetTab:CreateSubTab({Name="Keybinds"})

Window._keybindEntries = {
    {Name="Toggle Menu",      Key="RightControl"},
    {Name="Search Features",  Key="Ctrl + K"},
    {Name="Keybind List",     Key="Ctrl + B"},
    {Name="Mini Mode",        Key="RightShift"},
}
Window:RegisterKeybind("MiniMode", Enum.KeyCode.RightShift, function() Window:ToggleMiniMode() end)

local gBind = KB:CreateGroup({Name="Keybinds", Icon="keyboard"})
gBind:CreateKeybind({Name="Menu Toggle Key", Default=Enum.KeyCode.RightControl, Flag="MenuKey",
    Callback=function(k) Window:SetToggleKeybind(k); Window._keybindEntries[1].Key = k.Name end})
gBind:CreateKeybind({Name="Mini Mode Key", Default=Enum.KeyCode.RightShift, Flag="MiniKey",
    Callback=function(k) Window:SetKeybindKey("MiniMode", k); Window._keybindEntries[4].Key = k.Name end})

local gWin = KB:CreateGroup({Name="Windows", Icon="open_in_new"})
gWin:CreateButton({Name="Mini Mode",             Icon="minimize",      Callback=function() Window:EnterMiniMode() end})
gWin:CreateButton({Name="Keybind List",          Icon="keyboard",      Callback=function() Window:ShowKeybindViewer() end})
gWin:CreateButton({Name="Notification History",  Icon="notifications", Callback=function() Window:ShowNotifHistory() end})
gWin:CreateButton({Name="Changelog",             Icon="history",       Callback=function()
    Window:ShowChangelog({
        {Version="v1.3", Date=os.date("%Y-%m-%d"), Changes={
            "April event farm removed",
            "Branding: change the hub name from Settings",
        }},
        {Version="v1.2", Date="--", Changes={
            "Full settings menu: themes, backgrounds, sounds",
            "Overlays: FPS graph, perf monitor, player HUD, crosshair",
            "Profile system with autoload, import and export",
        }},
    })
end})

-- ·· Config ···················································································
local CF = SetTab:CreateSubTab({Name="Config"})
local gCfg = CF:CreateGroup({Name="Profiles", Icon="save"})

local nameBox = gCfg:CreateInput({Name="Profile Name", Placeholder="type a name..."})
local profDD
profDD = gCfg:CreateDropdown({Name="Profile", Options=Config:ListProfiles(), Default=Config.Active})
local boundLbl = gCfg:CreateLabel({Text="Autoload: none"})

local function refreshProfiles()
    local list = Config:ListProfiles()
    profDD:SetOptions(list)
    profDD:Set(Config.Active, true)
    boundLbl:Set("Autoload: " .. tostring(Config:GetBoundProfile() or "none"))
end
local function selectedProfile() return profDD:Get() end

gCfg:CreateButton({Name="Create Profile (from name)", Callback=function()
    local n = nameBox:Get():gsub("[^%w_%- ]", "")
    if n == "" then return note("Profile", "Type a name first.", "Warning") end
    Config:CreateProfile(n); Config.Active = n; refreshProfiles(); note("Profile created", n)
end})
gCfg:CreateButton({Name="Save Selected", Callback=function()
    local ok = Config:Save(selectedProfile()); note(ok and "Saved" or "Save failed", selectedProfile(), ok and "Success" or "Error")
end})
gCfg:CreateButton({Name="Load Selected", Callback=function()
    local ok = Config:Load(selectedProfile()); note(ok and "Loaded" or "Load failed", selectedProfile(), ok and "Success" or "Error")
end})
gCfg:CreateButton({Name="Delete Selected", Callback=function()
    local n = selectedProfile()
    if n == "Default" then return note("Profile", "Default can't be deleted.", "Warning") end
    Window:Confirm({Title="Delete profile", Message="Delete '"..n.."'?", Type="danger", ConfirmText="Delete",
        OnConfirm=function() Config:DeleteProfile(n); refreshProfiles(); note("Deleted", n, "Info") end})
end})
gCfg:CreateButton({Name="Set Selected As Autoload", Callback=function()
    Config:BindProfile(selectedProfile()); refreshProfiles(); note("Autoload set", selectedProfile())
end})
gCfg:CreateButton({Name="Clear Autoload", Callback=function()
    Config:UnbindProfile(); refreshProfiles(); note("Autoload cleared", "", "Info")
end})
gCfg:CreateButton({Name="Refresh List", Callback=refreshProfiles})

local gCfg2 = CF:CreateGroup({Name="Auto Save & Share", Icon="cloud_upload"})
gCfg2:CreateToggle({Name="Auto Save (30s)", Default=true, Flag="AutoSaveCfg", HideFromActive=true,
    Callback=function(v) if v then Config:EnableAutoSave(30) else Config:DisableAutoSave() end end})
gCfg2:CreateButton({Name="Copy Config To Clipboard", Callback=function()
    if typeof(setclipboard) == "function" then setclipboard(Config:Export()); note("Copied", "Config JSON copied.")
    else note("Clipboard", "Executor has no setclipboard.", "Warning") end
end})
gCfg2:CreateInput({Name="Import JSON (Enter)", Placeholder="paste JSON...", Callback=function(s)
    if Config:Import(s) then note("Imported", "Config applied.") else note("Import", "Invalid JSON.", "Error") end
end})

-- ·· Tools / Info ·············································································
local TL = SetTab:CreateSubTab({Name="Tools"})
local gInfo = TL:CreateGroup({Name="Session", Icon="info"})
local sessLbl  = gInfo:CreateLabel({Text="Session: 0s"})
local statsLbl = gInfo:CreateLabel({Text="Stats: --"})
Window:Schedule("SessionLabel", 1, function()
    sessLbl:Set("Session: " .. Window:GetSessionTime())
    local s = Window:GetStats()
    statsLbl:Set(("Elements: %d  |  Active: %d  |  Notifs: %d"):format(s.Elements, s.ActiveFeatures, s.NotifCount))
end, true)

local gTools = TL:CreateGroup({Name="Utilities", Icon="build"})
gTools:CreateButton({Name="Progress Bar Demo", Callback=function()
    Window:ShowProgress({Text="Working...", Duration=3, OnComplete=function() note("Done", "Progress finished.") end})
end})
gTools:CreateButton({Name="Reset All Toggles", Callback=function()
    Window:Confirm({Title="Reset toggles", Message="Turn every toggle off?", Type="danger", ConfirmText="Reset",
        OnConfirm=function() Window:ResetAllFlags(); note("Reset", "All flags reset.", "Info") end})
end})
gTools:CreateButton({Name="Unload UI", Callback=function()
    Window:Confirm({Title="Unload UI", Message="Close and remove the UI?", Type="danger", ConfirmText="Unload",
        OnConfirm=function() Window:CancelAllScheduled(); Window:Destroy() end})
end})
-- ══════════════════════════════════════════════════════════════════════════════
--  AUTO SUMMER EVENT + AUTO INFINITY CASTLE
--  Paste this ABOVE the "-- ── QUICK ACTION BAR" section (before Config:AutoLoad()).
--
--  States:  1) LOBBY  -> join the event / castle floor
--           2) MATCH  -> recognise the map -> vote start -> place units on the recorded spots -> upgrade
--           3) FINISH -> back to lobby (or next castle room) -> repeat
-- ══════════════════════════════════════════════════════════════════════════════
do
    if type(Window) ~= "table" or type(note) ~= "function" or not LocalPlayer then
        error("[SummerEvent] Paste this section BELOW 'local Window = Library:CreateWindow(...)' and the 'note' function, e.g. right above '-- QUICK ACTION BAR'. Do not run it as its own script.")
    end
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace         = game:GetService("Workspace")
    local TeleportService   = game:GetService("TeleportService")
    local VIM               = game:GetService("VirtualInputManager")

    local DEFAULT_UPGRADE_REMOTE = "upgrade_unit_ingame"     -- remote name inside client_to_server

    local Remotes
    do
        local ep = ReplicatedStorage:WaitForChild("endpoints", 15)
        Remotes = ep and ep:WaitForChild("client_to_server", 15)
    end
    local function getRemote(name) return Remotes and Remotes:FindFirstChild(name) end

    local function opt(flag, default)
        local api = Window._flags[flag]
        if api then
            local v = api:Get()
            if v ~= nil then return v end
        end
        return default
    end

    local function callRemote(r, ...)
        if r:IsA("RemoteFunction") then return r:InvokeServer(...) end
        r:FireServer(...)
        return true
    end

    -- ── WATCHDOG: infinite loading screen -> rejoin ──────────────────────────
    task.spawn(function()
        local badSince
        while true do
            task.wait(2)
            if opt("AutoRejoin", true) and (opt("AutoSummer", false) or opt("AutoCastle", false)) then
                local char = LocalPlayer.Character
                local stuck = not game:IsLoaded() or not (char and char:FindFirstChild("HumanoidRootPart"))
                if not stuck then
                    local name = tostring(opt("LoadingGuiName", "") or "")
                    if name ~= "" then
                        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                        local g = pg and pg:FindFirstChild(name)
                        stuck = g ~= nil and g:IsA("ScreenGui") and g.Enabled
                    end
                end
                if stuck then
                    badSince = badSince or tick()
                    if tick() - badSince >= opt("RejoinAfter", 90) then
                        badSince = tick()
                        local pid = tonumber(opt("RejoinPlaceId", "")) or game.PlaceId
                        warn("[SummerEvent] stuck loading, rejoining place " .. tostring(pid))
                        pcall(function() TeleportService:Teleport(pid, LocalPlayer) end)
                    end
                else
                    badSince = nil
                end
            else
                badSince = nil
            end
        end
    end)

    -- ── STATE / FLAGS FROM THE GAME ──────────────────────────────────────────
    local function dataVal(name)
        local d = Workspace:FindFirstChild("_DATA")
        local v = d and d:FindFirstChild(name)
        if v and v:IsA("ValueBase") then return v.Value end
        return nil
    end
    local function isStarted()  return dataVal("GameStarted")  == true end
    local function isFinished() return dataVal("GameFinished") == true end

    local function getUnitFolder()
        for _, n in ipairs({"_UNITS", "UNITS", "Units"}) do
            local f = Workspace:FindFirstChild(n)
            if f then return f end
        end
        return nil
    end

    local function inMatch()
        local d = Workspace:FindFirstChild("_DATA")
        return d ~= nil and d:FindFirstChild("GameStarted") ~= nil
            and (Workspace:FindFirstChild("_map") ~= nil or Workspace:FindFirstChild("_wave_num") ~= nil or getUnitFolder() ~= nil)
    end

    -- my units (enemies live in _UNITS too, but they have no _stats.player)
    local function mySet()
        local set = {}
        local f = getUnitFolder()
        if not f then return set, false end
        for _, u in ipairs(f:GetChildren()) do
            local st = u:FindFirstChild("_stats")
            local pv = st and st:FindFirstChild("player")
            if pv and tostring(pv.Value) == LocalPlayer.Name then set[u] = true end
        end
        return set, true
    end

    local function unitUuid(u)
        local st = u:FindFirstChild("_stats")
        local uu = st and st:FindFirstChild("uuid")
        return uu and tostring(uu.Value) or nil
    end

    local function unitLevel(u)
        local st = u:FindFirstChild("_stats")
        local up = st and st:FindFirstChild("upgrade")
        return up and tonumber(up.Value) or nil
    end

    -- ══════════════════════════════════════════════════════════════════════
    --  MAP DATA: how to recognise each map (names found inside workspace._map) and
    --  every placement spot you recorded: "ground" = Farm / DPS spots, "hill" = Hill spots.
    -- ══════════════════════════════════════════════════════════════════════
    local MAPS = {
        {
            name = "hellish city",
            sig = {"Big_Stairs", "wood stacks", "wires", "vending machines", "trash cans"},
            ground = {{-392.93,1,-554.33},{-395.53,1,-545.98},{-375.05,1,-538.72},{-373.31,1,-550.08},{-362.87,1,-539.56},{-361.56,1,-532.77},{-357.05,1,-532.03},{-353.93,1,-539.2},{-346.19,1,-549.36},{-341.26,1,-558.24},{-339.54,1,-548.46},{-342.44,1,-541.21},{-341.33,1,-538.88},{-336.2,1,-559.19},{-337.42,1,-562.09},{-330.15,1,-550.32},{-326.42,1,-555.71},{-328.57,1,-558.19},{-325.22,1,-561.38}},
            hill = {{-355.76,3.92,-545.46},{-357.71,3.92,-542.86},{-361.53,3.92,-542.85},{-364.32,3.92,-547.02},{-360.46,3.92,-549.41},{-355.7,3.92,-552.04},{-360.42,3.92,-556.77},{-360.76,3.92,-554.29},{-355.31,3.92,-553.95},{-381.98,6.13,-560.04},{-387.13,5.34,-557.41},{-392.37,5.38,-557.55},{-384.38,6.57,-561.49}},
        },
        {
            name = "planet namek",
            sig = {"namek grass model", "namek mushroom model", "namek trees model", "namek_details", "obstacles", "vines_model"},
            ground = {{-2948.43,91.81,-699.08},{-2940.52,93.36,-699.35},{-2944.18,93.36,-702.55},{-2947.9,91.81,-705.19},{-2944.06,91.81,-705.59},{-2940.21,91.81,-705.23},{-2948.38,91.81,-709.04},{-2944.74,91.81,-709.53},{-2941.5,91.81,-709.1},{-2959.4,91.81,-712.67},{-2955.21,91.81,-712.51},{-2952.06,91.81,-712.53},{-2961.7,91.81,-706.86},{-2956.77,91.81,-706.63},{-2954.18,91.81,-706.94},{-2954.23,91.81,-702.95},{-2954.1,91.81,-700.45},{-2953.88,91.81,-697.24},{-2943.4,91.81,-729.06},{-2942.11,91.81,-726.86},{-2940.44,91.81,-723.75},{-2940.31,91.81,-714.31},{-2943.88,91.81,-711.99},{-2939.53,91.81,-709.47}},
            hill = {{-2950.1,94.42,-726.86},{-2946.58,94.42,-726.99},{-2944.57,94.42,-725.45},{-2943.75,94.42,-722.49},{-2945.23,95.42,-721.39},{-2947.36,94.42,-721.36},{-2951.42,94.42,-720.02},{-2952.99,94.42,-717.52},{-2953.45,94.42,-720.97},{-2953.58,94.42,-723.33},{-2969.15,94.53,-700.81},{-2966.54,94.53,-702.37},{-2963.61,94.53,-700.79},{-2961.03,94.53,-699.17},{-2959.4,94.53,-695.38},{-2959.87,94.53,-692.82},{-2964.55,94.53,-691.9},{-2966.53,95.51,-693.72}},
        },
        {
            name = "walled city",
            sig = {"grass", "houses_new", "hq_new", "obstacles", "river towers", "towers_new"},
            ground = {{-3042.39,33.74,-686.47},{-3039.09,33.74,-686.44},{-3042.21,33.74,-682.06},{-3039.78,33.74,-682.03},{-3036.78,33.74,-681.78},{-3034.02,36.85,-685.66},{-3032.4,33.74,-685.56},{-3029.17,33.74,-685.38},{-3032.02,33.74,-681.37},{-3029.4,33.74,-681.19},{-3025.34,33.74,-685.19},{-3022.25,33.74,-684.74},{-3026.6,33.74,-680.87},{-3023.81,33.74,-680.18},{-3020.73,33.74,-679.99},{-3017.55,33.74,-679.4},{-3018.9,33.74,-683.83},{-3016.23,33.74,-683.64},{-3012.97,33.74,-684.24},{-3011.96,33.74,-679.32},{-3008.36,33.74,-681.01},{-3010.07,33.74,-685.31}},
            hill = {{-3030.07,38.42,-677.75},{-3030.03,38.42,-675.51},{-3028.03,38.42,-675.56},{-3027.6,38.42,-677.41},{-3025.08,38.42,-677.66},{-3024.76,38.42,-675.43},{-3020.53,38.42,-690.08},{-3020.4,38.42,-688.17},{-3017.93,38.42,-688.13},{-3017.77,38.42,-689.75},{-3015.03,38.42,-689.96},{-3014.75,38.42,-688.29}},
        },
        {
            name = "snowy town",
            sig = {"obstacles", "snow grass", "WallTorch", "flowers", "hut"},
            ground = {{-2857.04,34.35,-124.73},{-2860.13,34.35,-124.26},{-2865.03,34.35,-125.56},{-2856.67,34.35,-127.38},{-2860.48,34.35,-127.83},{-2865.22,34.35,-129.9},{-2856.93,34.35,-133.24},{-2861.92,34.35,-132.86},{-2866.9,34.35,-132.81},{-2869.35,34.35,-135.81},{-2865.03,34.35,-138.18},{-2861.07,34.35,-140.33},{-2865.11,34.35,-141.02},{-2868.6,34.35,-140.91},{-2870.47,34.35,-139.49},{-2873.52,34.35,-138.92},{-2857.06,34.35,-118.28},{-2861.42,34.35,-118.75},{-2859.03,34.35,-115.27},{-2864.98,34.35,-116.97},{-2866.6,34.35,-119.36},{-2869.16,34.35,-120.5},{-2871.2,34.35,-118.71},{-2871.19,34.35,-123.55},{-2872.63,34.35,-125.89},{-2873.37,34.35,-127.89},{-2873.51,34.35,-131.09},{-2874.59,34.35,-131.44},{-2877.7,34.35,-131.76},{-2878.04,34.35,-135.29},{-2876.53,34.35,-134.51},{-2878.82,34.35,-140.49},{-2881.37,34.35,-141.39},{-2882.59,34.35,-142.54},{-2883.85,34.35,-135.17},{-2885.71,34.35,-137.33},{-2885.5,34.35,-132.14}},
            hill = {{-2876.45,39.73,-121.82},{-2878.69,39.52,-121.6},{-2880.39,39.39,-121.47},{-2882.1,39.75,-121.84},{-2883.93,39.77,-121.86},{-2876.43,39.93,-123.89},{-2879.03,39.77,-124.05},{-2880.79,39.52,-124.31},{-2882.91,39.61,-124.22},{-2884.44,39.55,-124.27},{-2869.49,37.25,-148.62},{-2872.55,37.25,-148.72},{-2875,37.25,-148.8},{-2877.2,37.25,-149.61},{-2878.27,37.25,-151.62},{-2878.48,37.25,-153.75},{-2878.73,37.25,-155.81},{-2878.4,37.25,-157.8},{-2876.52,37.25,-159.08},{-2875.26,37.25,-156.79},{-2876.69,37.25,-155.57},{-2875.6,37.25,-154.44},{-2873.57,37.25,-154.23},{-2871.72,37.25,-152.7},{-2873.59,37.25,-151.48},{-2870.88,37.25,-150.84},{-2869.13,37.25,-150.33}},
        },
        {
            name = "hidden sand village",
            sig = {"desert_houses", "innerterrain", "market deco", "obstacles", "ropes", "KazekageMansion"},
            ground = {{-889.15,25.36,341.19},{-889.13,25.36,337.24},{-884.82,25.36,340.06},{-885.2,25.36,335.11},{-883.16,25.36,336.38},{-883.41,25.36,332.13},{-885.11,25.36,331.85},{-885.28,25.36,328.58},{-883.83,25.36,328.34},{-884.52,25.36,324.88},{-882.52,25.36,322.93},{-880.73,25.36,321.94},{-879.19,25.36,321.01},{-879.64,25.36,318.49},{-881.89,25.36,319.1},{-886.25,25.36,319.04},{-885.89,25.36,315.72},{-882.48,25.36,315.85},{-879.26,25.36,316.54},{-889.36,25.36,331.78},{-889.69,25.36,328.31},{-889.3,25.36,324.49},{-889.19,25.36,322.39},{-889.11,25.36,318.74},{-889.24,25.36,316.2},{-891.65,25.36,307.34},{-885.09,25.36,307.59},{-885.84,25.36,301.83},{-891.21,25.36,301.8},{-891.38,25.36,297.25},{-886.26,25.36,297.07},{-886.97,25.36,292.95},{-892.06,25.36,292.63},{-891.92,25.36,289.09},{-887.73,25.36,289.23}},
            hill = {{-893.77,29.57,324.78},{-893.48,29.57,320.36},{-896.82,29.57,318.66},{-896.1,29.57,321.75},{-899.71,29.57,320.62},{-878.59,32.28,330.69},{-880.38,31.98,328.18},{-878.24,31.98,327.09},{-876.99,32.21,329.24},{-878.31,32.07,329.05},{-909.72,33.32,295.29},{-908.02,33.3,293.36},{-910.21,33.1,291.85},{-911.24,33.1,293.13},{-909.69,33.13,293.19}},
        },
        {
            name = "navy bay",
            sig = {"deco", "grass", "ice spikes", "icebergs", "marine ships", "marineford_houses", "small ice spikes"},
            ground = {{-2526.01,25.21,-38.88},{-2526.78,25.21,-41.89},{-2528.55,25.21,-41.27},{-2528,25.21,-37.18},{-2531.94,25.21,-41.44},{-2532.33,25.21,-38.34},{-2532.49,25.21,-34.54},{-2535.45,25.21,-34.57},{-2538.59,25.21,-34.43},{-2542.03,25.21,-34.17},{-2545.35,25.21,-34.8},{-2542.3,25.21,-36.36},{-2540.54,25.21,-38.46},{-2541.13,25.21,-41.81},{-2542.04,25.21,-44.44},{-2539.36,25.21,-45.06},{-2537.12,25.21,-45.02},{-2535.9,25.21,-42.65},{-2538.33,25.21,-41.76},{-2546.86,25.21,-31.31},{-2544.07,26.72,-29.79},{-2543.46,25.21,-26.9},{-2541.29,25.21,-29.15},{-2541.17,25.21,-24.87},{-2539.34,25.21,-28.28},{-2536.05,25.21,-28.32},{-2533.31,25.21,-28.78},{-2530.7,25.21,-29.7},{-2527.2,25.21,-31.37},{-2524.07,25.21,-33.17},{-2531.46,25.21,-26.74},{-2535.88,25.21,-26.6},{-2535.48,25.21,-23.42},{-2531.46,25.21,-23.87},{-2531.83,25.21,-25.65},{-2534.64,25.21,-25.66},{-2554.19,25.21,-39.69},{-2554.13,25.21,-42.65},{-2553.44,25.21,-44.97},{-2556.51,25.21,-45.82},{-2557.11,25.21,-43.85},{-2557.23,25.21,-41.3},{-2559.34,25.21,-43.13},{-2560.92,25.21,-45.85},{-2560.37,25.21,-47.7},{-2558.02,25.21,-47.73},{-2558.17,25.21,-46.28},{-2560.22,25.21,-37.97},{-2560.59,25.21,-35.31},{-2558.7,25.21,-34.48},{-2557.71,25.21,-35.8},{-2554.54,25.21,-33.89},{-2555.21,25.21,-31.97},{-2557.17,25.21,-31.39},{-2560.11,25.21,-31.02},{-2558.03,25.21,-29.67}},
            hill = {{-2570.64,29.5,-48.8},{-2577.15,29.5,-52.53},{-2574.9,29.5,-48.46},{-2575.58,29.5,-46.22},{-2575.79,29.5,-43.29},{-2572.81,29.5,-39.85},{-2572.77,29.5,-41.93},{-2571.58,29.5,-44.23},{-2570.47,29.5,-45.51}},
        },
        {
            name = "fiend city",
            sig = {"Crashed Heli", "Crane", "Helicopter Pad", "Radio Tower", "Flood Light"},
            ground = {{-2962.41,58.59,-42.35},{-2959.11,58.59,-42.59},{-2962.78,58.59,-38.14},{-2959.55,58.59,-37.41},{-2963.2,58.59,-33.93},{-2959.49,58.59,-33.37},{-2963.42,58.59,-30.66},{-2960.43,58.59,-29.65},{-2954.66,58.59,-33.99},{-2981.03,58.59,-42.97},{-2975.36,58.59,-42.66},{-2976.95,58.59,-47.92},{-2977.01,58.59,-50.55},{-2980.2,58.59,-50.71},{-2980.01,58.59,-46.72},{-2980.23,58.59,-45.1},{-2986.61,58.59,-50.83},{-2980.02,68.41,-46.42},{-2986.86,58.59,-44.33},{-2980.02,76.7,-42.79},{-2980.02,78.56,-43.85},{-2980.02,79.55,-44.75},{-2980.02,80.46,-46.06},{-2980.02,81.16,-47.02},{-2980.02,81.5,-46.72},{-2980.02,81.34,-45.78},{-2980.02,80.81,-44.16},{-2980.02,80.09,-43.38},{-2980.02,78.98,-43.01},{-2980.02,80.28,-44.48},{-2993.59,58.59,-54.91},{-2998.55,58.59,-54.45},{-3004.3,58.59,-55.43},{-3004.71,58.59,-59.22},{-3000.27,58.59,-59.18},{-2995.66,58.59,-58.96},{-2994.19,58.59,-65.75},{-2999.05,58.59,-66.03},{-3004.37,58.59,-66.04},{-2997.89,58.59,-61.63},{-3005.35,58.59,-61.72}},
            hill = {{-2946.89,62.82,-48.11},{-2950.02,62.82,-47.9},{-2952.98,62.82,-47.85},{-2956.91,62.82,-48.17},{-2957.21,62.82,-51.4},{-2956.83,62.82,-54.33},{-2957.23,62.82,-56.82},{-2957.54,62.82,-60.19},{-2952.54,62.82,-60.03},{-2952.51,62.82,-56.58},{-2952.12,62.82,-51.91},{-2948.46,62.82,-52.51},{-2948.84,62.82,-57.27},{-2949.13,62.82,-59.38},{-2942.14,62.82,-51.82},{-2945.16,62.82,-52.49},{-2934.24,62.07,-22.67},{-2934.06,62.07,-25.47},{-2934.47,62.07,-27.69},{-2931.16,62.07,-27.54},{-2930.6,62.07,-25.87},{-2930.22,62.07,-22.95},{-2927.54,62.07,-31.19},{-2928.96,62.07,-31.13},{-2931.22,62.07,-31.33},{-2930.99,62.07,-33.01},{-2930.92,62.07,-35.09},{-2927.69,62.07,-35.67},{-2927.02,62.07,-33.87},{-2928.59,62.07,-33.43}},
        },
        {
            name = "spirit world",
            sig = {"Void", "moon", "dust", "Bones/dust", "more castle"},
            ground = {{-198.78,132.68,-767.92},{-201.7,132.68,-767.55},{-203.51,132.68,-767.37},{-202.42,132.68,-763.79},{-201.02,132.68,-763.96},{-198.89,132.66,-764.2},{-197.66,132.66,-761.02},{-200.27,132.66,-759.99},{-199.68,132.66,-756.37},{-197.26,132.66,-755.79},{-196.05,132.66,-752.44},{-197.08,132.66,-751},{-195.97,132.66,-747.38},{-193.5,132.66,-744.81},{-191.23,132.66,-743.85},{-190.97,132.66,-744.77},{-194.09,132.66,-747.37},{-194.41,132.66,-748.91},{-185.92,132.66,-752.54},{-187.55,132.66,-751.65},{-184.1,132.66,-750.81},{-186.07,135.38,-745.53},{-181.42,132.66,-749.53},{-182.41,132.66,-746.04},{-179.14,132.66,-749.98},{-179.64,132.66,-745.29},{-176.35,132.66,-747.81},{-177.01,132.66,-743.75},{-173.29,132.66,-744.51},{-173.87,132.66,-740.76},{-169.11,132.66,-741.51},{-170.31,132.66,-737.89},{-165.74,132.66,-737.78},{-166.29,132.66,-733.25},{-172.67,132.66,-730.15},{-172.63,132.66,-726.05},{-169.45,132.66,-723.98},{-169.99,132.66,-721.16},{-177.4,132.66,-734.42},{-178.15,132.66,-731.08},{-181.33,132.66,-736.15},{-181.18,132.66,-731.58},{-166.27,132.66,-718.87},{-168.33,132.66,-716.76},{-157.07,132.66,-728.15},{-160.19,132.66,-724.71},{-158.35,132.66,-734.96},{-162.32,132.66,-728.33},{-160.96,132.66,-736.89},{-164.76,132.66,-732.64},{-157.57,132.66,-720.84},{-156.79,132.66,-714.81},{-163.71,132.66,-713.1},{-164.16,132.66,-707.67},{-167,132.66,-704.14},{-169.49,132.66,-704.92},{-166.71,132.66,-710.08}},
            hill = {{-181.92,136.34,-769.92},{-182.67,136.34,-766.22},{-184.14,136.34,-767.9},{-186.3,136.34,-764.64},{-185.56,136.34,-761.79},{-185.43,136.34,-759.02},{-183.67,136.34,-755.61},{-180.7,136.34,-753.84},{-178.46,136.34,-754.71},{-177.35,136.34,-756.83},{-179.78,136.34,-757.52},{-180.89,136.34,-756.27},{-182.05,136.34,-758.37},{-183.42,136.34,-758.25},{-181.62,136.34,-761.4},{-178.97,136.34,-759.25},{-182.91,136.34,-764.99},{-182.99,136.34,-763.35},{-213.9,136.73,-766.44},{-209.56,137.02,-763.02},{-211.47,137.02,-762.29},{-210.06,137.02,-758.24},{-206.98,137.02,-759.08},{-204.76,137.02,-754.93},{-207.68,137.02,-753.42},{-206.98,137.02,-750.47},{-204.04,137.02,-750.23},{-203.71,137.02,-747.74},{-207.55,137.02,-746.7},{-207.68,137.02,-744.21},{-204,137.02,-743.93},{-200.52,137.02,-741.54},{-200.15,137.02,-738.02},{-200.86,137.02,-735.22},{-201.22,137.02,-733.21},{-200.19,136.73,-730.83},{-199.48,136.64,-733.19}},
        },
        {
            name = "ant kingdom",
            sig = {"Ant Nest", "shed", "fence", "campfire", "Village Path", "City Glow"},
            ground = {{-192.03,23.01,2962.52},{-192.54,23.01,2959.58},{-188.54,23.01,2958.05},{-188.01,23.01,2961.49},{-183.64,23.01,2959.97},{-185.11,23.01,2955.89},{-181.36,23.01,2955.19},{-180.86,23.01,2958.76},{-175.65,23.01,2955.16},{-176.47,23.01,2951.97},{-178.73,23.01,2953.99},{-183.17,23.01,2950.19},{-179.44,23.01,2949.92},{-176.38,23.01,2948.9},{-189.93,23.01,2967.04},{-187.89,23.01,2969.22},{-184.91,23.01,2966.5},{-186.92,23.01,2965.67},{-181.34,23.01,2963.75},{-181.29,23.01,2965.01},{-177.74,23.01,2963.67},{-177.42,23.01,2961.63},{-174.99,23.01,2960.26},{-174.46,23.01,2962.71},{-172.47,23.01,2961.26},{-172.95,23.01,2958.91},{-169.19,23.01,2957.66},{-169.35,23.01,2961.56},{-166.29,23.01,2959.93},{-166.31,23.01,2957.56},{-163.79,23.01,2958.81},{-164.32,23.01,2960.35},{-161.91,23.01,2960.8},{-160.91,23.01,2959.89},{-163.15,23.01,2962.57},{-161.1,23.01,2965.7},{-163.21,23.01,2967.61},{-159.16,23.01,2964.65},{-158.07,23.01,2963.36},{-157.48,23.01,2966.39},{-155.79,23.01,2965.77},{-157.43,23.01,2968.14},{-155.34,23.01,2970.5},{-154.17,23.01,2968.86},{-170.01,23.01,2951.98},{-170.54,23.01,2948.13},{-166.14,23.01,2948.18},{-165.9,23.01,2951.75},{-161.88,23.01,2951.53},{-162.72,23.01,2946.92},{-160.5,23.01,2953.68},{-156.17,23.01,2955.84},{-158.68,23.01,2949.31},{-159.13,23.01,2946.62},{-157.28,23.01,2945.81}},
            hill = {{-190.5,27.21,2952.67},{-193.47,27.21,2955.36},{-198.5,27.21,2952.87},{-195.76,27.21,2951.79},{-192.73,27.21,2951.23},{-196.14,27.21,2954.85},{-194.44,27.21,2949.06},{-182.77,27.21,2983.01},{-184.96,27.21,2976.58},{-183.68,27.21,2980.12},{-181.63,27.21,2975.09},{-182.64,27.21,2972.71},{-179.03,27.21,2971.5},{-178.39,27.21,2974.41},{-176.03,27.21,2970.95},{-163.26,31.19,2980.64},{-165.66,31.19,2976.31},{-169.25,31.19,2974.22},{-172.78,31.19,2974.32},{-176.43,31.19,2978.92},{-176.65,31.19,2981.47},{-163.82,26.23,2991.3},{-162.06,26.23,2990.58},{-160.52,26.23,2985.84},{-159.36,26.23,2982.32},{-157.8,26.23,2984.84},{-159.42,26.23,2989.03},{-145.07,26.73,2966.59},{-147.21,26.73,2964.2},{-146.77,26.73,2961.62},{-146.79,26.73,2957.46},{-148.38,26.73,2959.99},{-148.53,26.59,2955.99},{-145.57,26.73,2962.29}},
        },
        {
            name = "magic town",
            sig = {"wheelbarrows", "wooden stacks", "streamers", "light poles", "park", "tents", "docks"},
            ground = {{-585.95,6.74,-818.61},{-589.12,6.74,-818.66},{-592.28,6.74,-818.9},{-595,6.74,-818.88},{-597.66,6.74,-818.79},{-600.4,6.74,-819.06},{-602.52,6.74,-818.8},{-584.39,6.74,-811.83},{-587.06,6.74,-811.61},{-589.64,6.74,-811.59},{-591.89,6.74,-811.76},{-594.17,6.74,-811.85},{-597,6.74,-811.79},{-599.74,6.74,-811.85},{-602.96,6.74,-811.96},{-606.08,6.74,-811.91},{-607.23,6.74,-811.67},{-603.57,6.74,-839.91},{-603.63,6.74,-835.16},{-603.12,6.74,-831.7},{-603.78,6.74,-827.77},{-603.56,6.74,-823.22},{-603.59,6.74,-854.53},{-603.59,6.74,-848.55},{-620.39,6.87,-827.44},{-618.29,6.87,-827.64},{-616,6.87,-827.41},{-613.74,6.87,-827.49},{-612.7,6.87,-827.53},{-612.04,6.87,-828.97},{-611.27,6.87,-839.19},{-611.16,6.87,-838.12},{-611.14,6.87,-836.47},{-611.06,6.87,-835.75},{-619.36,6.87,-847.18},{-615.34,6.87,-846.64},{-612.67,6.87,-846.98},{-612.58,6.87,-844.5},{-615.15,6.87,-844.38},{-617.85,6.87,-844.41},{-620.83,6.87,-846.35},{-621.33,6.87,-842.74},{-621.37,6.87,-840.41},{-624.47,6.87,-841.05},{-624.27,6.87,-843.01}},
            hill = {{-586.3,16.15,-826.99},{-586.59,15.29,-825.51},{-586.53,13.75,-824.1},{-588.49,13.91,-824.25},{-588.32,15.07,-825.31},{-588.33,16.03,-826.19},{-588.02,16.15,-826.97},{-590.08,16.15,-826.96},{-590.41,15.66,-825.85},{-591.11,14.52,-824.81},{-591.16,13.67,-824.04},{-592.4,13.8,-824.15},{-592.94,14.75,-825.02},{-592.22,15.71,-825.9},{-591.99,16.15,-826.99},{-592.97,13.27,-830.09},{-594.78,15.73,-825.92},{-595.15,14.25,-824.57},{-595.09,13.33,-823.72},{-593.53,13.6,-823.97},{-593.55,15.01,-825.26},{-593.32,16.15,-826.91},{-631.74,14.41,-824.06},{-628.97,16.47,-823.94},{-627.22,14.21,-823.84},{-627.23,14.22,-821.18},{-628.49,15.85,-821.11},{-632.33,13.65,-820.64},{-633.03,12.75,-817.28},{-629.45,17.09,-817.87},{-627.77,14.93,-817.28},{-626.29,13.01,-816.94},{-626.68,13.52,-815.25},{-626.85,13.74,-812.24}},
        },
        {
            name = "haunted academy",
            sig = {"LanternsSky", "LanternsGround", "notice boards and paper", "deco", "cables", "Bridge", "Meshes/terrainv4_Cube.046"},
            ground = {{386.64,121.92,-65.58},{389.86,121.92,-65.56},{393.7,121.91,-65.61},{385.22,121.92,-59.71},{389.26,121.92,-59.56},{393.21,121.91,-59.62},{387.28,121.92,-57.12},{386.64,121.92,-54.36},{389.36,121.92,-54.33},{389.47,121.92,-56.82},{392.75,121.91,-56.86},{392,121.91,-54.34},{396.29,121.91,-53.65},{396.38,121.91,-56.51},{400.3,121.91,-53.19},{401.28,121.91,-55.8},{388.7,121.92,-68.72},{393.18,121.91,-68.43},{393.69,121.91,-70.74},{396.85,121.91,-70.27},{398.57,121.91,-68.38},{400.26,121.91,-68.77},{390.44,121.91,-73.01},{389.41,121.92,-70.82},{388.31,121.92,-72.75},{388.75,121.92,-76},{387.97,121.92,-80.55},{388.04,121.92,-83.63},{387.97,121.92,-86.85},{367.7,121.93,-65.25},{371.01,121.93,-64.83},{374.12,121.93,-64.91},{377.65,121.92,-64.91},{368.12,121.93,-68.2},{372.98,121.93,-67.92},{375.87,121.92,-68},{379,121.92,-67.65},{369.14,121.98,-70.37},{374.06,121.98,-70.31},{379.02,121.98,-69.55},{362.05,121.93,-60.11},{368.17,121.93,-60.15},{370.86,121.93,-59.88},{375.42,121.92,-59.56},{378.33,121.92,-59.56},{381.35,121.92,-59.72},{364,121.93,-56.92},{367.73,121.93,-56.68},{371.39,121.93,-56.67},{375.19,121.93,-56.41},{378.56,121.92,-56.83}},
            hill = {{407.71,125.17,-76.89},{408.55,125.17,-74.75},{405.34,125.17,-78.35},{405.33,125.17,-75.07},{406.75,125.17,-72.89},{403.1,125.17,-76.65},{402.86,125.17,-74},{404.85,125.17,-71.86},{399.38,125.17,-76.93},{401.29,125.17,-73.3},{396.14,124.44,-76.65},{397.25,124.44,-74.27},{396.34,124.44,-73.67},{394.5,124.44,-76.74},{393.58,124.44,-77.03},{393.61,124.44,-74.26},{392.33,124.44,-76.71},{390.54,124.44,-82.18},{391.85,124.44,-79.85},{393.66,125.9,-86.84},{393.11,125.9,-84.11},{395.61,125.9,-80.13},{399.2,125.9,-79.62},{402.78,125.9,-80.27},{406.49,125.9,-81.39},{410.14,125.9,-83.83},{408.03,125.9,-89.39},{406.17,125.9,-90.82},{404.21,125.9,-90.94},{402.03,125.9,-91.22},{398.07,125.9,-91.67},{399.87,125.9,-89.29},{402.14,125.9,-89.76},{404.81,125.9,-88.89},{404.62,125.9,-84.67},{400.44,125.9,-86.01},{401.78,125.9,-83.24},{395.21,125.9,-87.99},{400.75,125.9,-83.76},{399.32,125.9,-79.23},{397.57,125.9,-79.45},{395.34,125.9,-80.48},{387.07,121.92,-67.31}},
        },
        {
            name = "magic hills",
            sig = {"notice boards", "Paper Floor Texture", "misc deco", "fences", "dust", "boat", "Embers", "wall3"},
            ground = {{-189.63,1.23,27.7},{-187.57,1.23,23.51},{-187.38,1.23,28.67},{-186.25,1.23,25.46},{-183.07,1.23,27.61},{-180.04,1.23,30.28},{-180.01,1.23,26.45},{-180.43,1.23,22.68},{-183.53,1.23,18.27},{-181.84,1.23,17.95},{-194.2,1.23,24.47},{-190.98,1.23,20.98},{-188.14,1.23,16.57},{-185.74,1.23,12.56},{-183.5,1.23,7.42},{-183.73,1.23,2.52},{-187.15,1.23,1.39},{-187.08,1.23,4.72},{-196.12,1.23,21.13},{-193.04,1.23,17.45},{-191.49,1.23,16.15},{-183.27,1.23,18.13},{-181.04,1.23,17.62},{-180.92,1.23,14.97},{-179.06,1.23,10.89},{-178.87,1.23,6.84},{-178.58,1.23,0.87},{-175.72,1.23,4.3},{-177.04,1.23,8.87},{-175.54,1.23,11.04},{-176.52,1.23,17.18},{-173.58,1.23,15.41},{-187.98,1.23,4.8},{-182.84,1.23,2.3},{-188.14,1.23,0.4},{-182.3,1.23,-2.58},{-189.32,1.23,-3.24},{-180.8,1.23,-7.33},{-178.37,1.23,3.15},{-173.77,1.23,2.16},{-178.28,1.23,0.72},{-174.03,1.23,-0.49},{-171.08,1.23,-1.9},{-172.41,1.23,-6.64},{-175.33,1.23,-4.96},{-174.56,1.23,-8.35},{-184.69,1.23,-7.28},{-180.53,1.23,-8.72},{-185.78,1.23,-12.33},{-179.32,1.23,-13.24}},
            hill = {{-207,4.5,14.03},{-205.96,4.5,11.38},{-205.04,4.5,14.73},{-203.57,4.5,12.36},{-203.22,4.5,15.16},{-201.18,4.5,12.78},{-201.64,4.5,16.02},{-198.72,4.5,14.41},{-200,4.5,17.18},{-197.24,4.5,16.52},{-195.32,4.5,13.11},{-193.44,4.5,9.79},{-193.57,4.5,6.91},{-194.36,4.5,9.47},{-197.33,4.5,10.36},{-200.43,4.5,10.45},{-200.02,4.5,12.49},{-197.96,4.5,12.32},{-199.15,4.5,14.16},{-195.91,4.5,14.07},{-197.77,5.61,7.29},{-195.52,5.61,7.32},{-197.52,5.61,5.34},{-195.82,5.61,3.64},{-197.5,5.61,2.19},{-196.9,5.61,0.58},{-200.64,5.61,0.69},{-203.04,5.61,1.21},{-204.56,5.61,-2.6},{-202.37,5.61,-2.77},{-200.94,5.61,-3.09},{-208.64,5.61,4.44},{-209.16,5.61,0.06},{-206.14,6.53,-1.22},{-205.45,5.61,2.19},{-205.74,5.61,-2.47},{-196.47,4.66,52.41},{-194.93,4.66,50.05},{-196.75,4.66,48.29},{-195.62,4.66,43.88},{-193.91,4.66,38.82},{-197.46,4.66,40.53},{-197.33,4.66,37.63},{-191.6,4.66,35.67},{-189.26,4.66,31.82},{-186.55,4.66,30.95},{-185.52,4.66,33.64},{-183.83,4.66,33.19},{-181.74,4.66,32.18},{-184.89,4.66,29.87}},
        },
        {
            name = "space center",
            sig = {"SpaceCenter", "_helicopters", "background buildings", "faketerrain", "bushes", "Cargo Ship", "Tables"},
            ground = {{-117.27,15.17,-501.31},{-120.35,15.17,-500.7},{-124.74,15.17,-500.56},{-127.19,15.17,-500.81},{-126.43,15.18,-505.8},{-122.44,15.18,-505.4},{-119.51,15.18,-505.14},{-115.32,15.18,-504.98},{-113.73,15.18,-508.01},{-109.65,15.17,-507.46},{-109.35,15.17,-510.21},{-102.86,15.17,-499.97},{-103.18,15.17,-503.68},{-99.06,15.19,-499.49},{-99.2,15.17,-502.67},{-97.02,15.17,-499.94},{-96.58,15.17,-503.59},{-94.24,15.17,-499.79},{-93.52,15.17,-503.31},{-91.49,15.17,-499.71},{-91.75,15.17,-501.8},{-93.21,15.17,-504.49},{-93.78,15.17,-506.86},{-95.39,15.28,-504.34},{-96.01,15.17,-507.85},{-96.74,15.28,-504.39},{-97.98,15.17,-507.83},{-98.78,15.17,-504.61},{-99.49,15.17,-508.66},{-100.38,15.17,-505.58},{-100.86,15.17,-508.22},{-101.8,15.17,-505.46},{-102.88,15.17,-508.89},{-103.98,15.17,-510.36},{-104.61,15.17,-513.29},{-102.01,15.17,-510.83},{-101.82,15.17,-512.96},{-99.54,15.17,-510.61},{-99.16,15.17,-512.74},{-97.46,15.17,-509.75},{-96.6,15.17,-511.67},{-95.05,15.28,-509.25},{-93.81,15.17,-512.54},{-113.49,15.18,-507.98},{-112.45,15.18,-511.34},{-116.81,15.18,-509.92},{-115.22,15.18,-513.49},{-119.15,15.18,-511.92},{-117.92,15.18,-514.6},{-124.1,15.18,-514.95},{-120.86,15.18,-517.69},{-117.77,15.18,-521.34},{-114.44,15.18,-525},{-114.72,15.18,-520.22},{-111.34,15.18,-523.27},{-111.18,15.18,-519.28},{-108.64,15.18,-521.08},{-108.57,15.18,-517.56},{-106.7,15.18,-519.02}},
            hill = {{-111.83,19.62,-493.31},{-114.16,19.62,-493.8},{-113.67,19.62,-496.37},{-111.56,19.62,-495.42},{-111.12,19.62,-498.01},{-112.7,19.62,-498.07},{-112.58,19.62,-501.36},{-110.64,19.62,-500.1},{-109.48,19.62,-502.03},{-112.29,19.62,-502.68},{-112.03,19.62,-504.95},{-109.84,19.62,-504.41},{-102.04,19.62,-521.29},{-101.01,19.63,-522.61},{-103.43,19.62,-521.92},{-102.44,19.63,-524.17},{-105.9,19.62,-522.79},{-104.68,19.62,-525.35},{-106.98,19.62,-524.26},{-105.98,19.62,-526.77},{-109.23,19.62,-525.26},{-107.34,19.62,-527.72},{-110.16,19.62,-526.43},{-109.49,19.62,-528.22},{-112.71,19.05,-526.52},{-110.99,19.62,-528.76},{-113.36,19.62,-527.88},{-110.94,19.62,-530.04}},
        },
        {
            name = "alien spaceship",
            sig = {"Capybara", "Forest_Grass", "wires", "vents", "secret", "pole"},
            ground = {{-341.77,361.21,1389.34},{-341.25,361.21,1391.77},{-340.5,361.21,1394.86},{-341.48,361.21,1396.05},{-339.41,361.21,1394.81},{-338.44,361.21,1397.11},{-338.98,361.21,1398.2},{-335.57,361.21,1399.77},{-333.99,361.21,1401.9},{-332.91,361.21,1401.14},{-330.05,361.21,1402.02},{-331.07,361.21,1402.53},{-340.35,361.21,1385.88},{-341.78,361.21,1385.26},{-339.63,361.21,1383.15},{-342.19,361.21,1383.26},{-339.68,361.21,1380.31},{-341.9,361.21,1381.04},{-339.88,361.21,1377.17},{-340.81,361.21,1378.84},{-345.53,362.18,1395.23},{-345.17,361.21,1397.76},{-343.01,361.21,1400.46},{-340.69,361.21,1402.19},{-336.77,361.21,1405.31},{-338.28,361.21,1404.01},{-338.24,361.21,1406.44},{-345.34,361.21,1401.77},{-324.98,361.21,1407.56},{-321.31,361.21,1410.94},{-324.35,361.21,1412.87},{-326.26,361.21,1408.89},{-331.73,361.21,1407.8},{-329.32,361.21,1408.15},{-328.33,361.21,1410.2}},
            hill = {{-333.24,368.02,1410.04},{-321.06,365.26,1393.71},{-324.88,368.52,1394.28},{-323.01,365.26,1394.54},{-321.52,365.26,1395.42},{-323.73,365.26,1396.4},{-324.75,365.26,1394.73},{-326.72,365.26,1395.43},{-326.61,365.26,1396.99},{-329.01,365.26,1397.39},{-329.23,365.26,1394.77},{-332.32,365.26,1395.35},{-330.85,365.26,1393.08},{-334.37,365.26,1394.45},{-332.69,365.26,1391.2},{-334.62,365.26,1391.78},{-333.83,365.42,1390.23},{-335.95,365.26,1389.67},{-334.91,366.12,1387.71},{-353.11,368.02,1414.58},{-352.85,368.02,1411.37},{-349.88,368.02,1413.8},{-350.26,368.02,1410.61},{-347,368.02,1412.3},{-346.8,368.02,1410.06},{-344.32,368.02,1412.5},{-343.28,368.02,1410.35},{-342.22,368.02,1413.3},{-339.83,368.02,1410.34},{-340.08,368.02,1414},{-338.35,368.02,1412.44},{-338.1,368.02,1415.36},{-335.21,368.02,1414.65},{-335.92,368.02,1417.6},{-332.98,368.02,1416.79},{-334.63,368.02,1420.27},{-331.69,368.02,1420.7},{-333.88,368.02,1423.35},{-330.95,368.02,1424.18},{-333.23,368.02,1427.18},{-332.04,368.02,1430.23}},
        },
        {
            name = "fabled kingdom",
            sig = {"_secretthing", "bushes", "fence", "flag streamers", "misc noncollide no obstacle"},
            ground = {{-108.88,212.96,-168.94},{-104.68,212.96,-169.14},{-106.3,212.96,-171.21},{-109.64,212.96,-171.79},{-109.87,212.96,-174.16},{-109.97,212.96,-178.09},{-107.53,212.96,-177.65},{-107.49,212.96,-175.64},{-107.29,212.96,-174.64},{-109.13,212.96,-180.5},{-107.21,212.96,-179.85},{-106.87,212.96,-182.21},{-107.45,212.96,-184.41},{-107,212.96,-186.41},{-107,212.96,-188.43},{-107.06,212.96,-190.53},{-103.38,212.96,-174.39},{-102.05,212.96,-176.83},{-101.44,212.96,-173.48},{-99.38,212.96,-177.04},{-99.49,212.96,-171.71},{-97.26,212.96,-176.41},{-96.23,212.96,-171.68},{-95.31,212.96,-177.13},{-102.73,212.96,-182.11},{-99.35,212.96,-181.85},{-95.69,212.96,-180.97},{-103.26,212.96,-184.97},{-100.5,212.96,-184.97},{-97.45,212.96,-184.9},{-97.86,212.96,-188.57},{-100.44,212.96,-188.31},{-103.45,212.96,-188.42},{-103.23,212.96,-192.75},{-103.09,212.96,-195.92},{-101.51,212.96,-196.73},{-100.77,212.96,-193.54},{-98.37,212.96,-196.54},{-97.3,212.96,-192.08},{-110.83,212.96,-196.96},{-107.57,212.96,-195.6},{-110.03,212.96,-195.26},{-109.81,212.96,-193.13},{-106.96,212.96,-193.26}},
            hill = {{-97.08,225.42,-162.93},{-99.31,225.47,-162.9},{-101.08,225.48,-162.9},{-102.84,225.53,-162.87},{-104.52,225.5,-162.89},{-106.2,225.47,-162.9},{-106.33,223.82,-163.87},{-104.44,223.71,-163.95},{-103.07,223.84,-163.86},{-101.42,223.86,-163.84},{-99.42,223.91,-163.8},{-96.78,223.85,-163.85},{-94.3,223.89,-163.82},{-94.3,222.41,-164.94},{-96.14,222.42,-164.93},{-97.66,222.49,-164.87},{-99.36,222.54,-164.84},{-101.01,222.54,-164.83},{-102.73,222.59,-164.8},{-104.33,222.59,-164.79},{-106.42,222.72,-164.7},{-106.61,221.7,-165.67},{-104.79,221.66,-165.71},{-103.17,221.62,-165.75},{-102.08,221.6,-165.77},{-100.51,221.59,-165.78},{-97.08,221.57,-165.8},{-95.36,221.57,-165.81},{-94.08,221.6,-165.77},{-94.3,220.56,-166.89},{-96.53,220.7,-166.74},{-98.4,220.65,-166.79},{-100.44,220.64,-166.8},{-102.3,220.62,-166.82},{-104.15,220.63,-166.81},{-106.05,220.65,-166.79},{-109.84,223.14,-179.74},{-109.9,223.2,-178.03},{-109.86,223.17,-176.14},{-109.87,223.17,-174.64},{-109.76,223.07,-171.97},{-109.71,223.02,-169.03},{-109.73,223.04,-165.52},{-109.75,223.06,-164.78},{-111.84,225.09,-164.74},{-112.64,225.93,-165.06},{-112.85,228.21,-165.96},{-112.45,225.67,-172.28},{-113.1,226.54,-172.32},{-113.7,227.33,-172.53},{-114.15,227.93,-171.11},{-114.26,228.08,-173.69},{-115.01,229.42,-179.85},{-114.29,228.12,-179.95}},
        },
        {
            name = "ruined city",
            sig = {"Graffiti", "parking_spots", "sky bridges", "store", "vending", "bricks", "bridge nocollide"},
            ground = {{-20.19,-13.24,23.85},{-18.51,-13.24,22.42},{-21.99,-13.24,21.66},{-20.75,-13.24,20.34},{-23.7,-13.24,20.07},{-22.56,-13.24,18.45},{-26.16,-13.24,18.04},{-24.75,-13.24,16.64},{-28.32,-13.24,16.61},{-27.23,-13.24,14.93},{-29.66,-13.24,15.37},{-28.61,-13.24,13.53},{-31.38,-13.24,14.63},{-30.2,-13.24,12.5},{-33.08,-13.24,14.11},{-31.84,-13.24,11.22},{-31.44,-13.24,10.75},{-31.18,-13.24,9.58},{-29.51,-13.24,9.87},{-27.45,-13.24,10.54},{-25.99,-13.24,10.96},{-27.36,-13.24,7.29},{-24.39,-13.24,7.86},{-27.69,-13.24,5.67},{-26.19,-13.24,4.7},{-30.18,-13.24,4.08},{-29.72,-13.24,2.87},{-21.16,-13.24,13.96},{-18.86,-13.24,13.23},{-21.45,-13.24,12.02},{-18.57,-13.24,10.89},{-21.72,-13.24,10.18},{-19.35,-13.24,8.88},{-21.7,-13.24,8.34},{-19.71,-13.24,6.85},{-21.02,-13.24,6.2},{-19.05,-13.24,4.89},{-21.84,-13.24,3.75},{-21.08,-13.24,2.96},{-22.7,-13.24,2.81},{-22,-13.24,0.98},{-24.47,-13.24,1.19},{-23.49,-13.24,-0.33},{-16.08,-13.24,29.35},{-16.09,-13.24,27.06},{-15.41,-13.24,24.48},{-21.26,-13.24,29.08},{-18.4,-13.24,28.67},{-19.87,-13.24,26.3},{-18.49,-13.24,25.81},{-12.92,-13.24,29.68},{-12.85,-13.24,26.76},{-12.25,-13.24,25.16},{-12.09,-13.24,20.64},{-11.78,-13.24,17.36},{-9.06,-13.23,16.9},{-9.5,-13.24,19.23},{-9.84,-13.24,21.28},{-7.71,-13.23,21.34},{-7.02,-13.23,18.64},{-6.74,-13.23,17.37}},
            hill = {{-28.87,-10.02,21.21},{-30.28,-10.02,19.74},{-30.98,-10.02,19.02},{-33.01,-10.02,19.03},{-34.05,-10.02,21.54},{-34.8,-10.02,23.9},{-35.53,-10.02,26.05},{-34.65,-10.02,27.23},{-31.34,-10.02,28.06},{-29.56,-7.65,27.09},{-28.32,-7.98,26.27},{-30.01,-8.58,25.88},{-31.56,-10.02,26.67},{-32.02,-10.02,24.03},{-30.33,-10.02,24.59},{-28.44,-9.61,24.66},{-30.17,-10.02,23.29},{-10.71,-9.13,10.4},{-12.72,-8.95,11.35},{-15,-8.52,13.24},{-11.67,-9.62,8.79},{-13.35,-9.42,9.75},{-15.26,-9.2,10.84},{0.75,-8.9,8.24},{-0.64,-8.9,8.98},{-0.46,-8.9,6.72},{-2.06,-8.9,7.35},{-1.67,-8.9,5.18},{-3.01,-8.9,6.08},{-2.7,-8.9,3.88},{-3.75,-8.9,4.1},{-2.95,-8.9,2.02},{-4.71,-8.9,2.15},{-3.78,-8.9,0.5},{-5.7,-8.9,0.38},{-4.61,-8.89,-1.42},{-6.2,-8.9,-0.69}},
        },
        {
            name = "puppet island",
            sig = {"hay", "lamps", "linings", "paper", "tables and tents", "wood stacks", "colleseum", "factory"},
            ground = {{-54.56,2.6,-222.19},{-52.56,2.6,-222.16},{-50.48,2.6,-222.07},{-48.69,2.6,-222.1},{-46.82,2.6,-222.1},{-44.98,2.6,-222.02},{-42.4,2.6,-221.77},{-40.57,2.6,-221.08},{-39.05,2.6,-219.85},{-39.31,2.6,-218.57},{-37.73,5.99,-217.19},{-36.74,2.6,-216.15},{-37.39,2.6,-218.17},{-63.21,2.6,-230.08},{-60.19,2.6,-227.29},{-56.62,2.6,-227.38},{-57.23,2.6,-229.5},{-55.5,2.6,-232.01},{-53.26,2.6,-231.68},{-53.38,2.6,-229.18},{-53.13,2.6,-227.19},{-50.07,2.6,-226.89},{-50.16,2.6,-228.94},{-49.95,2.6,-231.14},{-46.64,2.6,-231.25},{-46.81,2.6,-228.94},{-46.17,2.6,-227.2},{-43.11,2.6,-226.1},{-43.08,2.6,-229.05},{-43.53,2.6,-231.17},{-38.87,2.6,-226},{-35.49,2.6,-223.16},{-32.98,2.6,-221.73},{-28.32,2.6,-221.06},{-24.76,2.6,-221},{-24.86,2.6,-223.88},{-26.93,2.6,-224.5},{-29.36,2.6,-224.7},{-32.32,2.6,-224.95},{-30.36,2.6,-206.48},{-26.64,2.6,-205.93},{-30.64,2.6,-208.03},{-26.39,2.6,-208.38},{-30.82,2.6,-210.61},{-27.23,2.6,-210.9},{-29.16,2.6,-212.24},{-25.89,2.6,-212.88},{-23.85,2.6,-211.29},{-24.01,2.6,-206.18},{-24.22,2.84,-204.88}},
            hill = {{-64.25,6.88,-218.49},{-64.96,6.1,-216.82},{-64.61,5.98,-214.78},{-61.89,5.98,-213.49},{-61.62,5.98,-215.34},{-60.63,5.98,-218.11},{-58.63,5.98,-212.98},{-57.91,5.98,-215.2},{-57.36,5.98,-217.88},{-56.1,5.98,-212.6},{-55.56,5.98,-215.49},{-54.6,5.98,-218.15},{-53.76,5.98,-213.01},{-52.47,5.98,-215.92},{-51.81,5.98,-217.92},{-50.66,5.98,-213.16},{-50.18,5.98,-216.04},{-49.43,5.98,-218.55},{-46.28,5.98,-218.21},{-44.17,5.98,-217.64},{-42.4,5.98,-217.44},{-39.46,5.99,-213.2},{-37.49,5.99,-212.49},{-35.46,5.99,-212.15},{-33.01,6.1,-212.36}},
        },
        {
            name = "virtual dungeon",
            sig = {"fish", "light", "torches", "water beams", "Logo", "dragon skeleton"},
            ground = {{169.62,37.41,22.16},{172.13,37.41,21.21},{171.32,37.41,18.53},{168.52,37.41,19.27},{168.89,37.41,16.26},{170.56,37.41,15.45},{169.94,37.41,13.24},{166.53,37.41,15.34},{167.32,37.41,12.6},{164.61,37.41,14.31},{165.48,37.41,11.1},{163.35,37.41,12.71},{163.21,37.41,10.05},{161.33,37.41,13.1},{161.09,37.41,8.18},{159.08,37.41,12.86},{158.97,37.41,9.1},{158.01,37.41,12.79},{157.36,37.41,7.94},{156.22,37.41,12.47},{155.28,37.41,7.31},{154.73,37.41,14.06},{153.18,37.41,10.33},{152.78,37.41,14.55},{150.65,37.41,11.89},{150.38,37.41,14.39},{149.1,37.41,12.68},{177.22,37.41,26.84},{178.67,37.41,26.07},{180.32,37.41,25.46},{181.13,37.41,22.62},{182.15,37.41,20.95},{176.5,37.41,24.99},{178.56,37.41,23.57},{178.06,37.41,20.38},{176.58,37.41,22.22},{176.77,37.41,18.64},{180.53,37.41,17.66},{181.69,37.41,16.42},{180.03,37.41,13.87},{177.75,37.41,15.23},{176.63,37.41,13.8},{175.47,37.41,16.09},{174.71,37.41,13.53},{176.48,37.41,11.41},{178.5,37.41,10.57},{180.47,37.41,11.7},{176.28,37.41,8.15},{174.09,37.41,9.88},{174.15,37.41,7.98},{171.51,37.41,9.46},{171.2,37.41,6.1},{170.46,37.41,7.56},{168.62,37.41,5.07},{168.17,37.41,6.09},{167.37,37.41,3.33},{165.92,37.41,4.54}},
            hill = {{163.2,41.68,31.07},{165.17,41.68,29.8},{165.82,41.68,27.41},{167.03,41.68,26.07},{166.58,41.68,23.64},{166.08,41.68,22},{165.87,41.68,20.61},{164.62,41.68,19.47},{162.86,41.68,18.82},{161.1,41.68,18.24},{159.78,41.68,17.44},{156.47,41.68,17.41},{154.88,41.68,17.85},{152.52,41.68,18.31},{150.8,41.68,18.85},{149.96,41.68,20.3},{152.48,41.68,19.35},{153.97,41.68,19},{155.24,41.68,19.88},{156.29,41.68,19.04},{156.99,41.68,20.1},{158.81,41.68,19},{158.47,41.68,20.66},{160.41,41.68,19.6},{160.03,41.68,21.27},{161.71,41.68,20.18},{161.18,41.68,21.28},{161.6,41.68,23.12},{163.52,41.68,22.24},{162.4,41.68,25},{164.21,41.68,24.22},{162.65,41.68,30.03}},
        },
        {
            name = "snowy kingdom",
            sig = {"Wheelbarrow", "Window_Wood", "camp", "swords", "snow", "SMOKEPARTICLES"},
            ground = {{-193.16,-0.07,-54.29},{-195.68,-0.07,-54.79},{-198.26,-0.07,-54.55},{-192.39,-0.07,-56.74},{-194.26,-0.07,-57.14},{-197.66,-0.07,-57.08},{-192.01,-0.07,-49.67},{-194.98,-0.07,-50.01},{-198.73,-0.07,-49.62},{-201.09,-0.07,-49.71},{-191.8,1.02,-46.86},{-193.24,-0.07,-47.12},{-195.87,-0.07,-47.8},{-203.85,-0.07,-52.67},{-204.59,-0.07,-53.79},{-207,-0.07,-52.34},{-205.73,-0.07,-51.16},{-207.7,-0.07,-49.22},{-209.41,-0.07,-50.49},{-211.08,-0.07,-50.87},{-209.82,-0.07,-48.39},{-209.07,-0.07,-46.58},{-212.78,-0.07,-43.79},{-212.84,-0.07,-46.75},{-213.24,-0.07,-48.27},{-213.78,-0.07,-49.84},{-215.9,-0.07,-46.06},{-214.31,-0.07,-43.6},{-216.31,-0.07,-43.08},{-214.77,-0.07,-41.21},{-216.93,-0.07,-41.58},{-216.38,-0.07,-40.24},{-207.27,-0.07,-38.79},{-208.86,-0.07,-41.23},{-209.01,-0.07,-36.39},{-212.47,-0.07,-38.5},{-209.84,-0.07,-35.76},{-213.94,-0.07,-36},{-211.92,-0.07,-33.17},{-214.81,-0.07,-32.59},{-211.6,-0.07,-29.46},{-214.33,-0.07,-29.24},{-211.86,-0.07,-26.01},{-213.29,-0.07,-25.81}},
            hill = {{-200.33,3.81,-64.86},{-202.77,3.81,-66.27},{-203.77,3.81,-63.72},{-201.6,3.81,-62.99},{-199.21,3.52,-61.85},{-201.63,3.81,-59.79},{-205.11,3.81,-60.85},{-205.85,3.81,-58.17},{-208.54,3.81,-61.05},{-209.17,3.81,-57.27},{-210.67,3.81,-61.24},{-212.95,3.81,-57.31},{-213.56,3.81,-61.73},{-216.87,3.81,-60.49},{-216.95,3.81,-63.42},{-216.22,3.81,-56.04},{-213.91,3.81,-54.7},{-211.11,3.81,-54.04},{-208.17,3.81,-54.91},{-204.62,3.41,-56.89},{-208.55,3.81,-57.33},{-211.19,3.81,-56.32},{-213.75,3.81,-57.35},{-217.46,3.81,-65.04},{-218.67,3.81,-67.12}},
        },
        {
            name = "dungeon throne",
            sig = {"_deathknights", "torches", "Arch_2", "Chandelier", "Spear_Flag", "Arch_1", "throne", "darkness top"},
            ground = {{218.62,1.09,46.66},{219.54,1.09,45.56},{220.52,1.09,44.5},{221.66,1.09,43.14},{222.3,1.09,42.37},{223.38,1.09,41.46},{224.52,1.09,40.58},{226.08,1.09,42.57},{225,1.09,43.96},{224.21,1.09,44.79},{222.58,1.09,46.24},{221.85,1.09,47.11},{220.78,1.09,48.29},{219.46,1.09,49.76},{218.44,1.09,50.97},{216.73,1.09,53.01},{210.25,1.09,49.18},{211.61,1.09,47.47},{212.76,1.09,46.36},{214.53,1.09,44.43},{215.65,1.09,43.36},{217.12,1.09,41.6},{219.05,1.09,39.66},{220.86,1.09,38.21},{219.23,1.09,36.28},{218.07,1.09,37.57},{215.89,1.09,39.59},{213.73,1.09,42.15},{212.72,1.09,43.36},{211.58,1.09,44.79},{209.26,1.09,47.56},{236.04,1.09,36.12},{233.05,1.09,36.05},{231.04,1.09,35.79},{228.67,1.09,35.58},{225.8,1.09,35.61},{237.03,1.09,40.71},{233.57,1.09,41.08},{230.69,1.09,41.49},{228.23,1.09,41.22},{225.27,1.09,41.63},{236.11,1.09,30.98},{233.12,1.09,31.65},{231.26,1.09,31.32},{228.82,1.09,31.59},{225.93,1.09,32.2},{223.41,1.09,32.87},{235.05,1.09,28.17},{231.73,1.09,27.78},{234.99,1.09,25.74},{233.58,1.09,25.57}},
            hill = {{220.87,5.52,24.23},{214.62,5.52,25.2},{218.16,5.52,29.22},{219.19,5.52,24.67},{219.77,5.52,27.68},{213.78,5.52,27.21},{214.69,5.52,30.25},{212.22,5.52,27.9},{211.51,5.52,30.13},{209.49,5.52,30.77},{245.17,9.78,57.82},{247.45,9.78,54.78},{250.09,9.78,53.69},{251.83,9.78,52.34},{259.66,9.78,48.78},{255.7,9.78,50.52},{254.29,9.78,51.67},{264.17,9.78,50.99}},
        },
        {
            name = "mountain temple",
            sig = {"Bus_Stop", "bus", "Fireflies_Big", "Grail_Textured_V4", "Gate"},
            ground = {{-190.26,54.9,-459.66},{-186.98,54.9,-459.53},{-189.9,54.9,-461.75},{-186.85,54.9,-461.42},{-190.35,54.9,-463.92},{-189.7,54.9,-466.35},{-193.04,54.83,-462.63},{-193.77,54.83,-466.29},{-193.51,54.83,-469.29},{-196.14,54.83,-463.21},{-196.17,54.83,-465.87},{-195.77,54.83,-470.47},{-198.75,54.83,-462.96},{-199.44,54.83,-466.89},{-198.44,54.83,-470.76},{-201.21,54.83,-465.9},{-202.01,54.83,-468.65},{-205.48,54.92,-469.48},{-206.37,54.83,-472.71},{-202.81,54.83,-472.63},{-206.87,54.83,-475.25},{-203.71,54.83,-475.53},{-208.07,54.83,-477.72},{-206.07,54.83,-478.5},{-203.62,54.83,-479.87},{-201.13,54.83,-477.58},{-197.91,54.83,-474.79},{-192.84,54.83,-475.03},{-195.16,54.83,-476.9},{-196.21,54.83,-478.25},{-197.6,54.83,-479.5},{-200.31,54.83,-482.07},{-187.78,54.9,-473.28},{-184.81,54.9,-472.38},{-189.15,54.9,-476.04},{-185.47,54.9,-475.01},{-189.59,54.9,-478.17},{-186.23,54.9,-478.3},{-193.08,54.83,-478.5},{-193.09,54.83,-482.11},{-193.87,54.83,-483.93},{-195.89,54.83,-484.43},{-198.88,54.83,-484.02}},
            hill = {{-173.62,58.58,-465.2},{-170.78,58.58,-465.39},{-169.96,58.58,-463.85},{-170.47,58.58,-467.19},{-174.93,58.58,-467.41},{-171.49,58.58,-469.39},{-175.68,58.58,-469.79},{-172.48,58.58,-471.51},{-175.77,58.58,-471.98},{-173.8,58.58,-476.43},{-176.75,58.58,-475.67},{-174.9,58.58,-478.91},{-178.15,58.58,-478.87},{-175.81,58.58,-480.83},{-177.79,58.58,-481.4},{-174.6,58.58,-480.67},{-175.46,58.58,-482.5},{-171.57,58.58,-478.39},{-170.66,58.58,-474.87},{-170.77,58.58,-471.64},{-169.87,58.58,-469.2},{-167.67,58.58,-470.88},{-167.24,58.58,-468.94},{-166.3,58.58,-467.01},{-163.51,58.58,-464.05},{-161.68,58.58,-463.8},{-164.84,58.58,-464.87}},
        },
        {
            name = "rain village",
            sig = {"_rain", "rain", "Clothing_Rack1", "Support", "Supports", "Water_Tower", "shoparea"},
            ground = {{-134.02,4.29,2.49},{-131.82,4.29,3.11},{-132.25,4.29,0.17},{-129.3,4.29,5.04},{-129.54,4.29,3.21},{-130.2,4.29,-0.39},{-129.69,4.29,0.96},{-127.96,4.29,-0.49},{-128.04,4.29,-3},{-123.94,4.29,-2.05},{-126.31,4.29,-4.24},{-122.77,4.29,-2.73},{-122.75,4.29,-5.12},{-124.82,4.29,-5.52},{-120.83,4.29,-2.5},{-120.44,4.29,-4.41},{-120.47,4.29,-5.7},{-138.31,4.29,-0.11},{-139.96,4.29,-2.23},{-136.52,4.29,-1.86},{-138.35,4.29,-3.86},{-133.93,4.29,-3.28},{-135.8,4.29,-5.43},{-132.59,4.29,-5.09},{-134.54,4.29,-7.92},{-131.54,4.29,-6.78},{-133.73,4.29,-9.6},{-128.9,4.29,-7.95},{-132.06,4.29,-11.47},{-128.49,4.29,-9.66},{-130,4.29,-11.05},{-125.19,4.29,-10.2},{-123.06,4.29,-10.47},{-120.89,4.29,-10.37},{-118.61,4.29,-10.08},{-123.68,4.29,-12.32},{-121.63,4.29,-12.62},{-119.55,4.29,-13.02}},
            hill = {{-125.02,9.12,3.89},{-124.99,8.94,2.34},{-125.36,8.7,0.3},{-122.96,9.14,3.7},{-122.87,9,2.49},{-122.68,8.72,-0.01},{-120.88,9.18,3.69},{-120.64,8.99,1.97},{-120.93,8.73,-0.22},{-119.04,9.12,2.84},{-118.67,8.92,1.03},{-118.58,8.75,-0.46},{-128.19,9.12,13.26},{-130,8.9,12.81},{-132.05,8.66,12.48},{-128.29,9.08,11.72},{-130.13,8.86,11.11},{-131.79,8.66,10.56},{-127.34,9.15,8.8},{-129.07,8.95,8.46},{-131.19,8.7,8.14},{-127.4,9.12,7.08},{-129,8.92,6.46},{-130.77,8.72,6.32},{-148.17,10.49,0.56},{-148.11,10.48,-0.88},{-148.36,10.53,-3.39},{-146.88,10.23,0.35},{-146.78,10.21,-1.26},{-146.68,10.19,-4.63},{-145.08,9.87,0.63},{-144.73,9.8,-2.06},{-144.84,9.83,-3.13}},
        },
        {
            name = "shibuya district",
            sig = {"Folder", "smalls", "smoke"},
            ground = {{225.12,97.97,-1184.36},{230.33,97.97,-1183.86},{226.47,97.97,-1187.4},{229.95,97.97,-1186.85},{224.65,97.97,-1179.75},{229.13,97.97,-1177.65},{224.02,97.97,-1177.05},{226.93,97.97,-1175.6},{233.13,97.97,-1178.07},{236.97,97.97,-1178.35},{239.7,97.97,-1178.79},{235.61,97.97,-1175.95},{239.09,97.97,-1176.13},{241.81,97.97,-1176.66},{232.52,97.97,-1184.1},{232.91,97.97,-1186.1},{233.37,97.97,-1189.35},{237.21,97.97,-1184.02},{237.17,97.97,-1186.76},{236.97,97.97,-1188.49},{240.67,97.97,-1184.61},{239.49,97.97,-1186.94},{239.23,97.97,-1188.35},{298.99,97.97,-1204.74},{299.62,98.05,-1207.56},{301.94,97.97,-1203.9},{303.46,97.97,-1207.25},{304.83,97.97,-1203.73},{307.22,98.75,-1210.21},{308.37,98.05,-1202.55},{308.56,97.97,-1206.26},{312.08,97.97,-1200.73},{313,97.97,-1208.57},{315.64,97.97,-1202.08},{315.84,97.97,-1208.12},{295.6,98.5,-1123.53},{296.67,97.97,-1128.69},{296.34,97.97,-1133.28},{295.36,98.05,-1137.56},{293.99,98.05,-1141.75},{295.16,98.05,-1146.62},{291.51,98.05,-1146.27},{293.16,98.05,-1149.97},{293.6,97.97,-1153.94},{296.7,97.97,-1155.95},{295.88,98.05,-1153},{298.9,97.97,-1154.33},{298.98,97.97,-1156.84},{301.27,98.05,-1154.68},{301.87,97.97,-1157.96},{304.32,98.05,-1156.18},{305.28,97.97,-1158.65},{306.88,97.97,-1155.92},{308.19,98.05,-1158.08},{309.24,98.05,-1155},{312.05,97.97,-1157.05},{312.09,97.97,-1153.58},{314.14,98.05,-1156.28},{286.18,98.05,-1145.92},{284.39,97.97,-1147.07}},
            hill = {{290.68,104.9,-1212.08},{288.92,104.9,-1213.22},{287.71,104.9,-1214.31},{286.55,104.9,-1211.92},{288.61,104.9,-1210.46},{285.82,104.9,-1210.02},{287.03,104.9,-1208.57},{284.58,104.9,-1208.39},{285.97,104.9,-1207.06},{283.17,104.9,-1207.14},{285.12,104.9,-1205.26},{282.63,104.9,-1205.41},{284.86,104.9,-1203.26},{280.2,104.9,-1203.02},{282.98,104.9,-1200.97},{279.37,104.9,-1201.07},{281.49,104.9,-1199.34},{281.14,104.9,-1199.59},{278.4,104.42,-1201.36},{275.49,101.75,-1246.62},{276.27,101.75,-1243.09},{275.96,101.75,-1240.63},{275.99,101.75,-1237.71},{273.96,101.75,-1236.09},{271.48,101.75,-1235.42},{268.6,101.75,-1234.93},{324,106.18,-1233.9},{324.22,106.44,-1232.18},{321.99,107.1,-1233.46},{321.7,107.4,-1231.46},{340.46,101.75,-1211.96},{337.44,101.75,-1213.38},{333.75,101.75,-1213.36},{331.73,101.75,-1211.9},{329.72,101.75,-1209.79},{335.92,101.75,-1204.25},{333.37,101.75,-1206.94},{337.99,101.75,-1205.58},{339.55,101.75,-1208.46},{340.23,101.75,-1210.39},{336.83,101.75,-1208.55}},
        },
        {
            name = "assasin park",
            sig = {"_moving", "Bankje", "Bunny Repainted Low", "Booth game", "Hotdog_Stand", "Merry_Go_Round_Complete", "Monorail", "for aa", "Water_Ride", "Roller_Coaster"},
            ground = {{211.54,0.82,-22.24},{213.89,0.82,-22.38},{215.96,0.82,-22.37},{218.13,0.82,-22.29},{220.07,0.82,-22.1},{222.22,0.82,-22.16},{223.95,0.82,-22.1},{225.59,0.82,-22.2},{227.17,0.82,-22.14},{229.16,0.82,-22.11},{231.19,0.82,-22},{234.27,0.82,-22.05},{236.81,0.82,-22.03},{209.93,0.82,-26.28},{209.85,0.82,-28.58},{211.88,0.82,-26.53},{213,0.82,-28.89},{214.06,0.82,-26.83},{215.28,0.82,-28.55},{217.03,0.82,-26.28},{218.68,0.82,-27.78},{220.31,0.82,-26.46},{222.11,0.82,-27.97},{224.28,0.82,-26.11},{225.22,0.82,-28.03},{226.74,0.82,-26.88},{227.91,0.82,-29.3},{229.21,0.82,-26.97},{229.99,0.82,-28.66},{231.08,0.82,-26.76},{232.05,0.82,-28.16},{233.05,0.82,-26.88},{233.56,0.82,-27.3},{214.36,0.82,-13.24},{214.46,0.82,-15.7},{216.12,0.82,-13.78},{216.29,0.82,-15.79},{218.01,0.82,-14.73},{218.8,0.82,-15.94},{221.06,0.82,-15.6},{223.2,0.82,-15.69},{223.65,0.82,-14.55},{226.39,0.82,-14},{227.84,0.82,-13.96},{225.1,0.82,-16.05},{226.97,0.82,-15.4},{229.47,0.82,-13.16},{229.36,0.82,-15.81},{231.29,0.82,-13.45},{231.02,0.82,-15.99},{233.31,0.82,-14.06},{233.05,0.82,-15.35},{234.9,0.82,-13.64},{234.13,0.82,-16.47},{235.18,0.82,-15.98},{234.79,0.82,-18.32},{233.32,0.82,-18.67},{231.64,0.82,-11.97},{233.88,0.82,-9.81},{235.12,2.32,-8.19}},
            hill = {{218.18,15.42,-10.75},{219.41,15.38,-10.85},{220.88,15.38,-10.85},{222.08,15.38,-10.85},{224.11,15.37,-10.88},{226.36,15.36,-10.92},{235.25,15.15,-4.07},{233.06,15.33,-5.65},{231.41,15.37,-7.17},{229.94,15.34,-8.72},{228.86,15.33,-9.84},{216.65,15.28,-10.51},{215.41,15.29,-9.25},{214.21,15.2,-8.38},{212.93,15.16,-7.22},{210.35,15.16,-4.64},{211.92,15.97,-3.43},{212.89,15.99,-4.35},{214.09,16.04,-5.36},{215.8,16.16,-6.67},{216.69,16.2,-7.44},{218.9,16.13,-9.05},{220.43,16.16,-8.98},{222.21,16.16,-8.98},{223.4,16.1,-9.11},{224.73,16.1,-9.11},{226.19,16.1,-9.11},{228.24,16.09,-7.86},{229.91,16.11,-6.11},{231.11,16.08,-5.01},{232.28,15.96,-4.25},{233.25,15.86,-3.62},{231.21,16.75,-2.64},{229.67,16.85,-3.83},{228.31,17,-4.69},{226.63,17.21,-5.64},{224.85,17.32,-6.19},{222.78,17.28,-6.28},{221.05,17.3,-6.22},{219.84,17.3,-6.22},{212.92,16.49,-2.67},{217.08,17.32,-4},{218.07,17.2,-5.39},{215.17,17.39,-1.84},{216.54,17.57,-2.61},{217.69,17.63,-3.55},{218.79,17.74,-4.27},{220.87,17.75,-5.13},{222.29,17.71,-5.22},{223.71,17.63,-5.43},{224.62,17.72,-5.2},{226.75,17.49,-4.57},{227.58,17.72,-2.96},{228.32,17.78,-2.01},{228.54,17.89,-1.42},{225.92,18.74,-1.14},{225.17,18.77,-1.79},{222.44,19.08,-1.92},{221.62,19.07,-1.96},{219.88,18.93,-1.29},{218.98,18.87,-0.61},{218,18.69,3.04},{218.17,18.76,1.72}},
        },
        {
            name = "cursed festival",
            sig = {"grass things", "houses outer (collision)", "lamps", "lanterns", "Support_Beam", "wires", "paper textures"},
            ground = {{-148.56,495.6,-79.21},{-148.66,495.6,-81.2},{-148.79,495.6,-82.34},{-148.65,495.6,-83.86},{-148.47,495.6,-86},{-148.37,495.6,-87.61},{-150.48,495.6,-87.94},{-150.87,495.6,-86.45},{-150.75,495.6,-84.2},{-150.65,495.6,-82.97},{-150.77,495.6,-80.95},{-150.84,495.6,-79.3},{-156.16,495.6,-79.25},{-155.5,495.6,-81.92},{-155.76,495.6,-84.64},{-156.03,495.6,-86.8},{-156.33,495.6,-88.83},{-147.7,495.76,-73.09},{-151.44,495.76,-73.42},{-148.27,495.76,-70.81},{-151.52,495.76,-70.72},{-149.05,495.76,-68.76},{-152.09,495.76,-68.63},{-149.04,495.76,-66.49},{-151.28,495.76,-65.67},{-156.67,495.76,-67.58},{-159.62,495.76,-66.92},{-162.65,495.76,-66.78},{-162.3,495.76,-70.71},{-160.03,495.76,-70.61},{-157.74,495.76,-71.18},{-156.03,495.76,-71.19},{-156.9,495.76,-74.1},{-159.8,495.76,-75.26},{-162.05,495.76,-75.29},{-151.34,495.6,-96.66},{-154.91,495.6,-96.36},{-152.32,495.6,-95.52},{-155.89,495.6,-94.28},{-154.21,495.6,-93.62},{-156.98,495.6,-92.9},{-155.4,495.6,-91.43},{-158.46,495.6,-91.2},{-146.31,495.6,-90.65},{-151.81,495.6,-91.42},{-146.55,495.6,-92.22},{-149.47,495.6,-93.35},{-145.04,495.6,-93.91},{-147.79,495.6,-94.64}},
            hill = {{-150.12,505.03,-76.13},{-151.46,504.46,-76.14},{-150.12,505.04,-77.56},{-152.09,504.18,-78.06},{-150.1,505.04,-79.36},{-152.08,504.19,-79.59},{-149.98,505.09,-81.11},{-151.62,504.39,-81.85},{-149.71,505.21,-83.22},{-151.16,504.59,-84.08},{-150.12,505.03,-85.1},{-151.46,504.46,-85.98},{-149.53,505.2,-87.47},{-151.22,504.56,-88.38},{-149.65,505.2,-89.23},{-151.51,504.44,-90.61},{-149.99,505.09,-90.97},{-151.54,504.41,-92.98},{-150.12,505.15,-92.45},{-151.8,504.39,-94.19},{-147.94,505.2,-75.74},{-148.79,504.66,-74.22},{-145.63,505.19,-75.45},{-146.12,504.49,-73.77},{-142.73,504.77,-74.49},{-142.79,504.28,-73.34}},
        },
        {
            name = "strange town",
            sig = {"morioh_grass", "idkwhatitscalled", "railtrack", "Transmitters", "ground MOVEBACKIFNEC", "outline", "roadmarkings"},
            ground = {{-479.93,32.78,-126.89},{-478.4,32.78,-126.82},{-476.85,32.78,-126.89},{-480.57,32.78,-124.46},{-479.07,32.78,-124.43},{-477.27,32.78,-124.29},{-480.33,32.78,-122.43},{-478.23,32.78,-122.47},{-476.86,32.78,-122.46},{-480.39,32.78,-120.6},{-478.18,32.78,-120.46},{-476.85,32.78,-120.54},{-480.43,32.78,-118.37},{-478.75,32.78,-118.16},{-476.66,32.78,-118.05},{-480.79,32.78,-116.13},{-478.72,32.78,-115.85},{-477.01,32.78,-115.81},{-480.21,32.78,-114.38},{-478.01,32.78,-114.33},{-476.34,32.78,-114.13},{-480.42,32.78,-112.51},{-478.67,32.78,-112.38},{-476.91,32.78,-112.34},{-474.3,32.4,-111.96},{-472.33,32.4,-111.55},{-474.63,32.4,-112.99},{-472.68,32.4,-113.27},{-475.14,32.56,-115.37},{-472.87,32.4,-114.91},{-474.43,32.4,-117.03},{-472.08,32.4,-116.69},{-473.99,32.4,-118.95},{-471.36,32.4,-118.67},{-474.72,32.4,-109.73},{-473.67,32.4,-108.95},{-476.64,32.4,-109.36},{-477.01,32.4,-107.35},{-478.31,32.4,-109.34},{-478.69,32.4,-107.83},{-479.82,32.4,-109.52},{-480.58,32.4,-107.68},{-481.39,32.4,-109.24},{-481.93,32.4,-107.58},{-484.16,32.4,-109.76},{-484.53,32.4,-107.41},{-486.03,32.4,-109},{-486.53,32.4,-107.51},{-487.45,32.4,-109.62},{-487.89,32.4,-107.14},{-489.08,32.4,-109.05},{-489.6,32.4,-107.4},{-490.32,32.4,-109.39},{-491.02,32.4,-107.48},{-492.19,32.4,-109.6},{-492.47,32.4,-107.41},{-493.74,32.4,-109.23},{-494.18,32.4,-106.81},{-495.8,32.4,-109.77},{-496.18,32.4,-106.95}},
            hill = {{-490.28,41.41,-94.35},{-491.65,41.58,-94.16},{-493.32,41.46,-94.3},{-498.28,41.41,-94.41},{-500.36,41.39,-94.45},{-502.04,41.29,-94.58},{-500.14,42.7,-92.94},{-498.87,42.77,-92.85},{-494.29,42.96,-92.58},{-492.45,43.07,-92.45},{-467.12,37.02,-136.4},{-467.71,37.02,-135.56},{-468.6,37.02,-137.25},{-469.32,37.02,-136.17},{-470.34,37.02,-137.53},{-471.31,37.02,-136.54},{-472.16,37.02,-138.18},{-473.3,37.02,-137.13},{-474.07,37.02,-139.25},{-475.08,37.02,-138.73},{-475.77,37.02,-139.94},{-477.27,37.02,-139.09},{-477.28,37.02,-140.2},{-478.37,37.02,-140.03}},
        },
        {
            name = "storm hideout",
            sig = {"ThreeDTextObject", "algae", "Particles", "Tp1", "Tp2", "Pillars_lp"},
            ground = {{315.35,536.9,-600.71},{316.14,536.9,-601.74},{314.31,536.9,-602.07},{314.64,536.9,-603.44},{312.25,536.9,-603.26},{313.24,536.9,-604.49},{309.54,536.9,-603.47},{310.94,536.9,-605.69},{307.52,536.9,-603.59},{307.38,536.9,-605.95},{305.21,536.9,-604.47},{304.77,536.9,-605.38},{305.92,537.05,-609.81},{309.04,536.9,-610.52},{311.26,536.9,-610.61},{313.83,536.9,-610.42},{315.15,536.9,-609.01},{316.95,536.9,-607.65},{318.6,536.9,-605.83},{304.13,536.9,-603.36},{302.78,536.9,-604.84},{303,536.9,-602.54},{301.43,536.9,-603.31},{300.29,536.9,-602.17},{302.04,536.9,-601.01},{297.56,536.9,-604.68},{298.84,536.9,-606.16},{301.51,536.9,-608.6},{296.64,536.9,-606.59},{298.8,536.9,-609.44},{294.03,536.9,-607.71},{297.02,536.9,-610.49},{301.71,536.9,-598.83},{300.34,536.9,-598.55},{301.65,536.9,-595.77},{300.48,536.9,-595.68},{300.93,536.9,-593.04},{300.29,536.9,-593.67},{299.92,536.9,-590.84},{298.16,536.9,-592.27},{297.76,536.9,-587.7},{296.47,536.9,-589.71},{295.68,536.9,-585.34},{294.8,536.9,-587.36},{292.29,536.9,-584.11},{292.12,536.9,-586.74},{292.87,536.9,-591.68},{290.45,536.9,-595.22},{294.57,536.9,-593.47},{292.56,536.9,-596.5},{295.9,536.9,-595.53},{293.78,536.9,-598.4},{291.76,536.9,-594.57},{294.53,536.9,-596.76},{295.73,536.9,-600.22},{295.11,536.9,-602.93}},
            hill = {{316.08,539.9,-592.24},{314.56,539.9,-593.44},{315,539.9,-594.74},{313.1,539.9,-596.33},{311.47,539.9,-596.77},{310.43,539.9,-595.66},{311.93,539.9,-594.62},{313.37,539.9,-594.08},{314.41,539.9,-591.97},{312.48,539.9,-590.62},{311.47,539.9,-593.19},{309.92,539.9,-594.11},{308.45,539.9,-592.72},{311.05,539.9,-590.41},{312.46,539.9,-589.39},{304.45,539.9,-593.76},{303.91,539.9,-592.09},{303.51,539.9,-589.55},{304.61,539.9,-586.92},{306.79,539.9,-584.79},{308.74,539.9,-583.37},{309.45,539.9,-584.87},{307.02,539.9,-587.4},{304.72,539.9,-588.93},{307.28,539.9,-589.47},{309.09,539.9,-588.57},{310.99,539.9,-587.15},{311.6,539.9,-589.19},{308.3,539.9,-591.54},{306.19,539.9,-591.45},{305.24,539.9,-590.44}},
        },
        {
            name = "nightmare train",
            sig = {"snow grass", "lamp", "streetlight", "main", "obstacles", "flowers"},
            ground = {{-3.11,-15.08,366.66},{-1.45,-15.08,368.55},{0.29,-15.08,370.66},{3.1,-15.08,368.94},{1.34,-15.08,366.94},{-0.41,-15.08,365.32},{0.64,-15.08,362.79},{2.27,-15.08,364.38},{4.24,-15.08,366.21},{7.43,-15.08,363.95},{5.7,-15.08,362.74},{3.18,-15.08,360.96},{-9.45,-15.08,381.86},{-10.71,-15.08,386.5},{-6.67,-15.08,385.88},{-6.47,-15.08,381.28},{-4.12,-15.08,384.69},{-3.28,-15.08,380.3},{-1.08,-15.08,383.53},{-0.54,-15.08,379.05},{2.37,-15.08,381.63},{1.07,-15.08,378.82},{5.93,-15.08,379.6},{4.31,-15.08,375.61},{8.76,-15.08,377.02},{6.61,-15.08,374.15},{10.03,-15.08,374.44},{8.01,-15.08,372.18},{12.88,-15.08,372.26},{10.13,-13.89,369.19},{15.76,-12.83,369.25},{12.24,-15.08,365.84},{14.09,-15.08,362.86},{15.92,-13.58,364.67},{17.14,-15.08,362.57},{15.31,-15.08,361.33},{16.3,-15.08,359.88},{19.34,-15.08,361.57},{19.89,-15.08,359.37},{17.77,-15.08,357.66}},
            hill = {{-13.18,-12.08,358.43},{-14.15,-12.08,360.25},{-11.99,-12.08,362.42},{-9.4,-12.08,363.22},{-9.57,-12.08,360.33},{-7.47,-12.08,358.41},{-6.26,-12.08,360.81},{-4.37,-12.08,362.7},{-2.54,-12.08,359.65},{-2.19,-12.08,356.99},{-4.2,-12.08,359.36},{-2.55,-10.02,353.34},{0.79,-10.02,353.42},{2.9,-10.02,352.06},{5,-10.02,348.7},{6.1,-10.02,345.82},{3.66,-10.02,345.31},{2.33,-10.02,348.71},{1.05,-10.02,350.86},{-1.22,-10.02,351.75},{-2.8,-10.02,351.72},{-1.11,-7.63,341.84},{2.48,-7.63,341.54},{4.38,-7.63,342.39},{6.45,-7.63,340.7},{7.12,-7.63,337.74},{6.49,-7.63,335.42},{5.41,-7.63,334.4},{0.95,-10,325.07},{3.47,-10,326.47},{2.44,-10,329.44},{45.05,-8.96,332.88},{42.14,-10.6,329.75},{40.18,-10.49,333.17},{43.68,-8.84,335.74},{41.23,-9.02,338.43},{38.58,-10.34,336.03},{37.15,-10.2,338.96},{39.5,-8.88,341.7},{38.36,-8.91,343.53},{35.06,-11.01,339.54}},
        },
        {
            name = "sacred planet",
            sig = {"terrain bg", "WIND", "Pink_Small_Tree", "Portal1", "Ripples", "Water"},
            ground = {{-124.59,109.64,-111.65},{-131.61,109.68,-112.57},{-131.49,109.68,-108.19},{-127.09,109.67,-106.92},{-124.75,109.64,-106.74},{-130.73,109.68,-104},{-126.87,109.68,-102.54},{-124.61,109.64,-101.65},{-130.1,109.68,-100.33},{-126.48,109.68,-98.23},{-123.85,109.68,-96.83},{-130.92,109.68,-94.49},{-126.75,109.68,-93.12},{-124.05,109.68,-92.26},{-127.61,109.68,-90.35},{-124.61,109.68,-89.86},{-125.04,109.68,-87.38},{-123.32,109.68,-87.46},{-123.1,109.68,-85.16},{-121.25,109.68,-86.01},{-121.22,109.68,-83.61},{-120.04,109.68,-84.64},{-118.7,109.64,-90.73},{-118.42,109.64,-93.1},{-118.11,109.64,-95.85},{-118.24,109.64,-98.49},{-118.35,109.64,-102.29},{-116.3,109.64,-100.85},{-115.93,109.64,-96.61},{-115.53,109.64,-93.76},{-116.41,109.64,-90.46},{-113.98,109.64,-99.19},{-113.64,109.64,-94.17},{-111.39,109.64,-91.69},{-109.93,109.64,-89.6},{-111.33,109.64,-87.61},{-112.89,109.64,-89.9},{-110.76,109.64,-84.5},{-109.07,109.64,-82.43},{-108.72,109.64,-85.8},{-106.83,109.64,-83.56},{-106.98,109.64,-86.5},{-113.93,109.64,-80.14},{-111.29,109.64,-78.59},{-108.83,109.64,-76.91},{-104.81,109.64,-75.81},{-101.5,109.64,-76.54},{-99.58,109.64,-76.81},{-102.61,109.64,-74.29},{-101.42,109.64,-74.47}},
            hill = {{-115.4,114.1,-131.87},{-118.67,114.1,-129.55},{-120.42,114.03,-126.59},{-118.13,114.1,-124.13},{-116.51,114.1,-126.56},{-114.08,114.1,-127.84},{-110.89,114.1,-129},{-111.23,114.1,-124.88},{-114.37,114.1,-122.98},{-117.87,114.1,-121.63},{-116.42,114.1,-119.05},{-113.34,114.1,-121.57},{-110.81,114.1,-122.7},{-115.28,114.1,-116.7},{-113.74,114.1,-114.42},{-110.49,114.1,-113.86},{-110.87,114.1,-116.8},{-112.61,114.1,-117.26},{-111.25,114.1,-119.18},{-114.59,114.1,-119.73},{-109.17,114.1,-119.47},{-143.31,114.1,-117.14},{-140.27,114.1,-117.29},{-136.65,114.1,-115.98},{-135.13,114.1,-113.51},{-134.76,114.1,-110.19},{-134.19,114.1,-106.9},{-134.13,114.1,-105.17},{-133.89,114.1,-102.63},{-137.22,114.1,-100.15},{-139.02,114.1,-99.78},{-139.47,114.1,-103.44},{-138.93,114.1,-106.33},{-139.75,114.1,-108.85},{-140.02,114.1,-111.41},{-140.05,114.1,-113.89},{-142.33,114.1,-113.72},{-108.74,113.98,-102.34},{-110.05,114.26,-100.05},{-109.61,114.26,-96.85},{-109.01,114.26,-94.53},{-107.51,114.22,-92.53},{-105.47,113.98,-89.26},{-103.84,114.12,-86.57},{-100.91,114.26,-85.78},{-98.44,114.26,-85.55},{-95.99,114.26,-86.65},{-99.49,114.26,-87.48},{-101.29,114.26,-88.17}},
        },
        {
            name = "future city",
            sig = {"deco", "s", "sign", "construction barrier"},
            ground = {{-2324.02,19.76,-127.14},{-2321.99,19.76,-126.87},{-2320.23,19.76,-126.82},{-2323.81,19.76,-124.52},{-2321.84,19.76,-123.97},{-2320.31,19.76,-123.69},{-2323.49,19.76,-122},{-2321.96,19.76,-121.49},{-2320.57,19.76,-121.26},{-2324.05,19.76,-119.48},{-2321.54,19.76,-118.46},{-2319.09,19.76,-117.84},{-2323.94,19.76,-117.3},{-2321.78,19.76,-116.21},{-2319.78,19.76,-115.21},{-2324.06,19.76,-115.34},{-2321.95,19.76,-113.88},{-2320.22,19.76,-112.7},{-2326.2,20.31,-113.97},{-2322.35,19.76,-110.62},{-2319.82,19.76,-108.11},{-2325.25,19.76,-111.22},{-2323.85,19.76,-108.52},{-2322.95,19.76,-106.86},{-2327.65,19.76,-110.28},{-2327.54,19.76,-107.9},{-2330.35,19.76,-109.14},{-2330.49,19.76,-106.75},{-2332.2,19.76,-108.89},{-2333.65,19.76,-105.82},{-2335.21,19.76,-108.62},{-2335.64,19.76,-107.13},{-2337.64,19.76,-109.48},{-2338.76,19.76,-106.02},{-2311.68,19.86,-122.75},{-2310.54,19.86,-122.51},{-2311.24,19.86,-120.85},{-2310.27,19.86,-120.11},{-2311.53,19.86,-118},{-2310.26,19.86,-117.57},{-2311.58,19.86,-116.19},{-2310.46,19.86,-115.21},{-2311.26,19.86,-113.87},{-2309.71,19.86,-113.05},{-2312.06,19.86,-110.94},{-2311.12,19.86,-110.48},{-2312.15,19.86,-108.38},{-2310.52,19.86,-108.1},{-2310.91,19.86,-104.61},{-2309.07,19.86,-104.44},{-2310.73,19.89,-102.59},{-2309.37,19.86,-102.16},{-2310.89,19.86,-100.99},{-2309.8,19.86,-100.83},{-2310.08,19.86,-98.85},{-2310.95,19.86,-97.51},{-2313.31,19.86,-97.87},{-2316.35,19.86,-97.19},{-2318.76,19.86,-97.39}},
            hill = {{-2326.91,23.78,-123.29},{-2329.58,23.78,-123.75},{-2332.04,23.78,-123.88},{-2334.61,23.78,-123.96},{-2334.58,23.78,-122.25},{-2332.05,23.78,-121.52},{-2329.31,23.78,-121.26},{-2326.88,23.78,-120.9},{-2327.38,23.78,-118.38},{-2329.25,23.78,-118.7},{-2331.51,23.78,-118.69},{-2334.31,23.78,-119.33},{-2333.99,23.78,-116.65},{-2330.99,23.78,-115.87},{-2328.41,23.78,-115.99},{-2330.4,23.78,-114.29},{-2332.36,23.78,-114.65},{-2335.4,23.78,-115.25},{-2335.96,23.78,-112.88},{-2333.33,23.78,-112.47},{-2330.3,23.78,-112.63},{-2344.62,23.78,-116.36},{-2344.3,23.78,-114.58},{-2342.61,23.78,-116.1},{-2341.88,23.05,-111.44},{-2340.59,23.78,-116.57},{-2338.49,23.78,-114.13},{-2300.47,23.46,-124.99},{-2301.92,23.3,-121.93},{-2299.7,23.3,-119.22},{-2301.7,23.3,-119.02},{-2297.87,23.3,-117.32},{-2301.02,23.3,-116.93},{-2297.18,23.3,-115.83},{-2300.03,23.3,-114.51},{-2296.06,23.3,-114.61},{-2298.47,23.3,-113.06},{-2294.43,23.3,-113.09},{-2296.73,23.3,-110.69},{-2292.16,23.3,-111.29}},
        },
        {
            name = "sky island",
            sig = {"Bush", "Folder", "lights", "obstacles", "trees", "Union"},
            ground = {{-1670.66,183.45,-119.58},{-1674.02,183.45,-120.05},{-1676.77,183.45,-120.08},{-1678.65,183.45,-119.8},{-1681.13,183.45,-119.63},{-1683.37,183.45,-119.7},{-1686.18,183.45,-119.97},{-1688.59,183.45,-120.02},{-1688.69,183.45,-114.2},{-1685.11,183.45,-114.05},{-1683.53,183.45,-113.75},{-1681.1,183.45,-113.64},{-1678.18,183.45,-114.1},{-1675.79,183.45,-114.31},{-1674.23,183.45,-113.61},{-1670.58,183.45,-113.71},{-1668.23,183.45,-113.87},{-1665.75,183.45,-113.7},{-1662.16,183.45,-119.4},{-1661.94,183.45,-122.21},{-1661.91,183.45,-124.19},{-1661.9,183.45,-126.04},{-1661.96,183.45,-128.08},{-1662.07,183.45,-130.92},{-1662.34,183.45,-132.86},{-1662.09,183.45,-134.63},{-1662.2,183.45,-136.93},{-1661.8,183.45,-144.42},{-1661.32,183.45,-142.2},{-1661.37,183.45,-139.85},{-1661.05,183.45,-146.48},{-1661.43,183.45,-149.33},{-1661.97,183.45,-150.94},{-1660.83,183.45,-153.43},{-1660.97,183.45,-156.13},{-1656.21,183.45,-156.77},{-1656.29,183.45,-153.54},{-1656.41,183.45,-151.45},{-1656.52,183.45,-147.72},{-1656.61,183.45,-146.11},{-1656.46,183.45,-144.04},{-1656.5,183.45,-142.48},{-1655.38,183.45,-103.3},{-1655.82,183.45,-105.87},{-1655.05,183.45,-107.6},{-1654.86,183.45,-110},{-1654.5,183.45,-111.85},{-1655.47,183.45,-114.46},{-1655.79,183.45,-116.98},{-1655.7,183.45,-117.62},{-1654.72,183.45,-120.63},{-1654.52,183.45,-124.63},{-1655.23,183.45,-126.9}},
            hill = {{-1634.86,192.5,-131.4},{-1649.83,197.8,-117.68},{-1649.89,195.47,-120.42},{-1650.1,193.78,-122.49},{-1646.86,193.61,-122.68},{-1646.74,195.17,-120.78},{-1646.63,196.67,-118.95},{-1644.38,197.19,-118.32},{-1644.03,195.21,-120.74},{-1644.46,193.42,-122.93},{-1673.73,200.59,-143.66},{-1673.59,200.59,-139.42},{-1673.59,200.59,-137.55},{-1673.57,200.59,-134.33},{-1673.77,200.59,-131.18},{-1674.09,200.59,-127.36},{-1678.77,200.59,-129.14},{-1681.15,200.59,-129},{-1682.89,200.59,-129.07},{-1686.29,200.59,-128.92},{-1683.98,189.12,-107.5},{-1680.05,189.13,-108.35},{-1677.52,189.13,-108.76},{-1674.83,189.13,-107.75},{-1673.25,189.12,-106.99},{-1670.67,189.12,-105.23},{-1669.58,189.12,-103.29},{-1697.26,191.2,-104.46},{-1693.69,191.2,-105.82},{-1690.49,191.2,-105.66},{-1687.76,191.2,-104.71},{-1685.1,191.2,-104.07},{-1640.23,201.65,-158.87},{-1643.05,201.59,-158.88},{-1645.8,201.49,-158.71},{-1648.52,201.34,-159.24},{-1650.44,201.19,-158.94},{-1650.32,201.3,-162.61},{-1650.21,201.33,-164.01},{-1650.37,201.32,-167.61}},
        },
        {
            name = "otherworld plane",
            sig = {"Folder", "Storm", "campfire", "flag", "Union", "Sparks"},
            ground = {{-17,68,123},{-15,68,128},{-6,68,132},{-7,68,139},{-16,68,116},{-9,68,115},{-6,68,110},{-27,68,114},{-22,68,112},{-24,68,106},{-19,68,111},{-14,68,139}},
            hill = {{1,75,125},{-2,75,120},{1,75,116},{8,75,120}},
        },
        {
            name = "sky aircraft",
            sig = {"Airship", "Arckz_Was_Here", "Barrel", "Big Crate", "Brick_Pile", "BrokenTv/mesh", "Capybara", "Casino_Doors", "Casino_Walls", "Electricity Thing", "Meshes/carpet1", "Old Sofa", "Paper Floor Texture", "Sand_Bags", "Support", "Support_2", "TrafficCone", "Trash Block", "Trash_Can", "Vending Machine", "Wooden Stack"},
            ground = {{1984,501,-1471},{1977,501,-1453},{1980,501,-1453},{1984,501,-1453},{1977,501,-1448},{1977,501,-1476},{1972,501,-1479},{1968,501,-1475},{1970,501,-1445}},
            hill = {{1987,505,-1455},{1987,505,-1458},{1991,505,-1460},{1991,505,-1454},{1988,505,-1450},{1988,505,-1445}},
        },
    }

    -- ── LOOP CONTROL ─────────────────────────────────────────────────────────
    local running, runToken, currentMode = false, 0, "summer" -- mode: "summer" | "castle"
    local placed, usedPos = {}, {}
    local clickBusy = false -- true while a click-placement is running (anti-afk must not click then)
    local maxed, upgradeCount, unitSlot = {}, {}, {}
    local failStreak, failSince, upgLog = {}, {}, 0

    local function live(token) return running and token == runToken end
    local function playing(token) return live(token) and not isFinished() end

    local stateLbl, castleLbl, mapLbl
    local function setState(s)
        if stateLbl then stateLbl:Set("State: " .. s) end
        if castleLbl then castleLbl:Set("State: " .. s) end
    end

    -- ── MAP RECOGNITION ──────────────────────────────────────────────────────
    local currentMap = nil

    -- Looks at the names inside workspace._map and picks the map whose recorded names match best.
    local function detectMap()
        local folder = Workspace:FindFirstChild("_map")
        if not folder then return nil, 0, nil end
        local present, n = {}, 0
        for _, c in ipairs(folder:GetChildren()) do present[c.Name] = true; n = n + 1 end
        if n == 0 then return nil, 0, present end
        local best, bestScore, bestHits = nil, -1, -1
        for _, m in ipairs(MAPS) do
            local hits = 0
            for _, name in ipairs(m.sig) do
                if present[name] then hits = hits + 1 end
            end
            local score = hits / #m.sig
            if score > bestScore or (score == bestScore and hits > bestHits) then
                best, bestScore, bestHits = m, score, hits
            end
        end
        if best and bestScore >= 0.75 then return best, bestScore, present end
        return nil, bestScore, present
    end

    local function resolveMap(token)
        currentMap = nil
        local t0 = tick()
        local lastPresent
        while live(token) and tick() - t0 < 25 do
            local m, score, present = detectMap()
            if m then
                currentMap = m
                local txt = ("Map: %s (%d%% match) - %d ground / %d hill spots"):format(m.name, math.floor(score * 100), #m.ground, #m.hill)
                if mapLbl then mapLbl:Set(txt) end
                print("[SummerEvent] " .. txt)
                return m
            end
            lastPresent = present
            task.wait(1)
        end
        local names = {}
        for k in pairs(lastPresent or {}) do names[#names + 1] = k end
        table.sort(names)
        if mapLbl then mapLbl:Set("Map: NOT RECOGNISED") end
        print("[SummerEvent] map not recognised. workspace._map contains: " .. table.concat(names, ", "))
        note("Map", "Map not recognised (see console F9).", "Warning")
        return nil
    end

    -- the recorded spots for a role: Farm / DPS use the ground list, Hill uses the hill list
    local function spotList(kind)
        local m = currentMap
        if not m then return {} end
        local isHill = (kind == "Hill")
        local raw = isHill and m.hill or m.ground
        local pfx = isHill and "Hill" or "Ground"
        local from = math.max(1, opt(pfx .. "SpotFrom", 1))
        local to = opt(pfx .. "SpotTo", 0)
        if to <= 0 or to > #raw then to = #raw end
        local order = opt(kind .. "SpotOrder", (kind == "Farm") and "Last to First" or "First to Last")
        local list = {}
        for i = from, to do
            local t = raw[i]
            list[#list + 1] = Vector3.new(t[1], t[2], t[3])
        end
        if order == "Last to First" then
            local r = {}
            for i = #list, 1, -1 do r[#r + 1] = list[i] end
            list = r
        elseif order == "Random" then
            for i = #list, 2, -1 do
                local j = math.random(1, i)
                list[i], list[j] = list[j], list[i]
            end
        end
        return list
    end

    local function isUsed(p)
        for _, q in ipairs(usedPos) do
            if (Vector3.new(p.X, 0, p.Z) - Vector3.new(q.X, 0, q.Z)).Magnitude < 3 then return true end
        end
        return false
    end

    -- ── SLOT HELPERS ─────────────────────────────────────────────────────────
    local function slotKind(i) return opt("SlotType" .. i, "Off") end

    local function resolveId(i)
        local raw = tostring(opt("SlotId" .. i, "") or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if raw == "" then return nil end
        if raw:match("^%d+$") then return tonumber(raw) end
        return raw
    end

    local function orderedSlots()
        local list = {}
        for i = 1, 6 do
            local k = slotKind(i)
            if k ~= "Off" then list[#list + 1] = {slot = i, kind = k} end
        end
        local ord = opt("PlaceOrder", "Slot Order")
        if ord ~= "Slot Order" then
            local first = (ord == "Farm First" and "Farm") or (ord == "DPS First" and "DPS") or "Hill"
            local a, b = {}, {}
            for _, e in ipairs(list) do
                if e.kind == first then a[#a + 1] = e else b[#b + 1] = e end
            end
            for _, e in ipairs(b) do a[#a + 1] = e end
            list = a
        end
        return list
    end

    -- ── UNIT IDS: read the equipped team straight from the game (slot -> uuid) ──
    local function readEquipped()
        local out = {}
        pcall(function()
            local Loader = require(ReplicatedStorage.src.Loader)
            local svc = Loader.load_client_service(script, "ItemInventoryServiceClient")
            for _, v in pairs(svc.session.collection.collection_profile_data.owned_units) do
                local slot = tonumber(v.equipped_slot)
                if slot and v.uuid then out[slot] = {uuid = tostring(v.uuid), id = tostring(v.unit_id)} end
            end
        end)
        if next(out) == nil and getgc then
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "xp") and rawget(v, "uuid") and rawget(v, "equipped_slot") then
                        local slot = tonumber(rawget(v, "equipped_slot"))
                        if slot then
                            out[slot] = {uuid = tostring(rawget(v, "uuid")), id = tostring(rawget(v, "unit_id"))}
                        end
                    end
                end
            end)
        end
        return out
    end

    local function autoFillIds(silent)
        local eq = readEquipped()
        local n = 0
        for slot = 1, 6 do
            local e = eq[slot]
            local api = Window._flags["SlotId" .. slot]
            if e and api then
                api:Set(e.uuid, true)
                n = n + 1
                print(("[SummerEvent] slot %d = %s %s"):format(slot, e.id, e.uuid))
            end
        end
        if not silent then
            note("Unit IDs", n > 0 and ("Detected " .. n .. " equipped units.") or "Could not read your equipped units.", n > 0 and "Success" or "Warning")
        end
        return n
    end

    -- ── PLACING ──────────────────────────────────────────────────────────────
    local HOTKEYS = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three,
                     Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six}

    -- finds the NEW unit of mine that appeared after a placement (exact match by _stats.uuid)
    local function detectNew(before, pos, timeout, id)
        local t0 = tick()
        repeat
            task.wait(0.1)
            local now = mySet()
            for u in pairs(now) do
                if not before[u] then
                    local uu = unitUuid(u)
                    if id and uu then
                        if uu == tostring(id) then return u end
                    else
                        local okp, up = pcall(function() return u:GetPivot().Position end)
                        if okp and (Vector3.new(up.X, 0, up.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude < 8 then
                            return u
                        end
                    end
                end
            end
        until tick() - t0 > timeout
        return nil
    end

    -- method REMOTE: spawn_unit(uuid, CFrame) - instant, no walking / zoom / clicking
    local function trySpawnRemote(id, pos)
        local remote = getRemote("spawn_unit")
        if not remote then return nil end
        local before, hasFolder = mySet()
        local ok, ret = pcall(callRemote, remote, id, CFrame.new(pos))
        if not ok or ret == false then return nil end
        if typeof(ret) == "Instance" and ret:IsA("Model") then return ret end
        if not hasFolder then return true end
        return detectNew(before, pos, 1.0, id)
    end

    -- method CLICK: zoom out, walk near the spot, press the hotbar key, hover, click
    local zoomApplied, oldZoom = false, nil

    local function applyZoom()
        local d = opt("ZoomDistance", 150)
        if not oldZoom then
            oldZoom = {min = LocalPlayer.CameraMinZoomDistance, max = LocalPlayer.CameraMaxZoomDistance}
        end
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = d
            LocalPlayer.CameraMinZoomDistance = d -- min = max forces the camera out to exactly this distance
        end)
        if not zoomApplied then
            zoomApplied = true
            task.wait(0.8)
        end
    end

    local function restoreZoom()
        zoomApplied = false
        if oldZoom then
            pcall(function()
                LocalPlayer.CameraMinZoomDistance = oldZoom.min
                LocalPlayer.CameraMaxZoomDistance = oldZoom.max
            end)
            oldZoom = nil
        end
    end

    local function doJump(hum)
        pcall(function()
            if hum.UseJumpPower then
                if hum.JumpPower < 20 then hum.JumpPower = 50 end
            else
                if hum.JumpHeight < 3 then hum.JumpHeight = 7.2 end
            end
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum.Jump = true
            if hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    local function walkNear(token, pos, radiusOverride)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return end
        local alwaysJump = opt("AlwaysJump", true)
        local radius  = radiusOverride or opt("WalkRadius", 20)
        local timeout = opt("WalkTimeout", 10)
        local function dist()
            return (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
        end
        if dist() <= radius then return end

        local t0 = tick()
        local lastPos, lastMove = hrp.Position, tick()
        if alwaysJump then pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end) end
        hum:MoveTo(pos)
        while playing(token) and dist() > radius and tick() - t0 < timeout do
            task.wait(0.15)
            hum:MoveTo(pos)
            if alwaysJump then doJump(hum) end
            if (hrp.Position - lastPos).Magnitude < 0.5 then
                if tick() - lastMove > 1.5 then
                    local ang = math.random() * math.pi * 2
                    hum:MoveTo(hrp.Position + Vector3.new(math.cos(ang), 0, math.sin(ang)) * 10)
                    doJump(hum)
                    task.wait(0.6)
                    lastMove = tick()
                end
            else
                lastPos, lastMove = hrp.Position, tick()
            end
        end
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
        hum:MoveTo(hrp.Position)
        task.wait(0.2)
    end

    local function pressKey(code)
        VIM:SendKeyEvent(true, code, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, code, false, game)
    end

    local function clickAt(x, y)
        local hover = opt("HoverTime", 0.5)
        local t0, i = tick(), 0
        repeat
            i = i + 1
            VIM:SendMouseMoveEvent(x + (i % 2), y, game) -- tiny nudge so every move event registers
            task.wait(0.05)
        until tick() - t0 >= hover
        VIM:SendMouseMoveEvent(x, y, game)
        task.wait(0.1)
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.08)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end

    local function cancelPlacing()
        local k = tostring(opt("CancelKey", "Q")):gsub("%s", "")
        if k == "" then return end
        local ok, code = pcall(function() return Enum.KeyCode[k:sub(1, 1):upper() .. k:sub(2)] end)
        if ok and code then pressKey(code) end
    end

    local function trySpawnClickInner(token, slot, kind, pos)
        applyZoom()
        walkNear(token, pos)
        if not playing(token) then return nil end

        local cam = Workspace.CurrentCamera
        local function screenPos()
            local v, onScreen = cam:WorldToViewportPoint(pos)
            local vp = cam.ViewportSize
            local top = opt("ScreenTopMargin", 25) / 100
            local bot = opt("ScreenBottomMargin", 10) / 100
            local safe = onScreen and v.Z > 0
                and v.Y >= vp.Y * top and v.Y <= vp.Y * (1 - bot)
                and v.X >= vp.X * 0.05 and v.X <= vp.X * 0.95
            return v, safe
        end
        local v, safe = screenPos()
        if not safe then
            walkNear(token, pos, 6) -- the spot is near the edge / top of the screen: get closer
            task.wait(0.3)
            v, safe = screenPos()
        end
        if not safe then return nil, true end

        -- view check: a click here must really land on the spot (not on a house / tree in front of it)
        if opt("ViewCheck", true) then
            local ray = cam:ViewportPointToRay(v.X, v.Y)
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.RespectCanCollide = true
            local ex = {}
            if LocalPlayer.Character then ex[#ex + 1] = LocalPlayer.Character end
            local uf = getUnitFolder()
            if uf then ex[#ex + 1] = uf end
            rp.FilterDescendantsInstances = ex
            local r
            for _ = 1, 6 do
                r = Workspace:Raycast(ray.Origin, ray.Direction * 2000, rp)
                if r and r.Instance.Transparency >= 0.9 then
                    ex[#ex + 1] = r.Instance
                    rp.FilterDescendantsInstances = ex
                else
                    break
                end
            end
            local good = false
            if r then
                local off = (Vector3.new(r.Position.X, 0, r.Position.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
                good = off <= 6
            end
            if not good then return nil, true end
        end

        local before, hasFolder = mySet()
        pressKey(HOTKEYS[slot])
        task.wait(0.25)
        clickAt(v.X, v.Y)
        if not hasFolder then return true end
        local u = detectNew(before, pos, 1.8, resolveId(slot))
        if not u then cancelPlacing() end
        return u
    end

    local function trySpawnClick(token, slot, kind, pos)
        clickBusy = true
        local ok, a, b = pcall(trySpawnClickInner, token, slot, kind, pos)
        clickBusy = false
        if not ok then error(a) end
        return a, b
    end

    local function tryPlace(token, slot, kind, id, pos)
        if opt("PlaceMethod", "Remote") == "Click" then
            return trySpawnClick(token, slot, kind, pos)
        end
        return trySpawnRemote(id, pos)
    end

    -- places ONE unit of this slot on the next free recorded spot
    local function placeSlot(token, slot, kind)
        local id = resolveId(slot)
        local remoteMode = opt("PlaceMethod", "Remote") ~= "Click"
        if remoteMode and not id then
            note("Summer Event", "Slot " .. slot .. " has no Unit ID.", "Warning")
            return nil
        end
        local spots = spotList(kind)
        if #spots == 0 then
            note("Summer Event", "No " .. kind .. " spots for this map.", "Warning")
            return nil
        end
        local retries = opt("RetriesPerSpot", 2)
        local delay   = opt("PlaceDelay", 0.4)
        local limit   = opt("PlaceTimeout", 180)
        local tStart  = tick()
        local function timedOut() return tick() - tStart >= limit end

        while playing(token) and not timedOut() do
            local attempts, failsInRow = 0, 0
            local bad = {}
            for _, c in ipairs(spots) do
                if not playing(token) or timedOut() then break end
                if not isUsed(c) then
                    for _ = 1, retries do
                        if timedOut() or not playing(token) then break end
                        attempts = attempts + 1
                        local u, skip = tryPlace(token, slot, kind, id, c)
                        if u then
                            usedPos[#usedPos + 1] = c
                            return u
                        end
                        if skip then break end
                        task.wait(delay)
                    end
                    bad[#bad + 1] = c
                    failsInRow = failsInRow + 1
                    -- several spots in a row failing usually means "not enough money yet": give it time
                    if failsInRow >= 3 then task.wait(3) end
                end
            end
            if attempts == 0 then
                note("Summer Event", ("No free %s spot left for slot %d, moving on."):format(kind, slot), "Warning")
                return nil
            end
            task.wait(2) -- whole pass failed: try again from the top
        end
        if timedOut() then
            note("Summer Event", ("Gave up on slot %d (%s) after %ds, moving on."):format(slot, kind, limit), "Warning")
        end
        return nil
    end

    local function placeAll(token)
        if opt("AutoDetectIds", true) then autoFillIds(true) end
        -- everything of mine already on the map blocks its spot (e.g. after a script restart)
        for u in pairs((mySet())) do
            local okp, up = pcall(function() return u:GetPivot().Position end)
            if okp then usedPos[#usedPos + 1] = up end
        end
        for _, e in ipairs(orderedSlots()) do
            local count = opt("SlotCount" .. e.slot, 1)
            placed[e.slot] = {}
            local id = resolveId(e.slot)
            if id then
                for u in pairs((mySet())) do
                    if unitUuid(u) == tostring(id) then
                        table.insert(placed[e.slot], u)
                        unitSlot[u] = e.slot
                    end
                end
            end
            for n = #placed[e.slot] + 1, count do
                if not playing(token) then return end
                setState(("In match - placing slot %d (%s) %d/%d"):format(e.slot, e.kind, n, count))
                local u = placeSlot(token, e.slot, e.kind)
                if not u then break end -- couldn't place this one: skip the rest of this slot
                local list = placed[e.slot]
                list[#list + 1] = u
                if typeof(u) == "Instance" then unitSlot[u] = e.slot end
                task.wait(opt("PlaceDelay", 0.4))
            end
        end
    end

    -- ── UPGRADING ────────────────────────────────────────────────────────────
    -- upgrade_unit_ingame:InvokeServer(unitModel). A unit counts as upgraded when its _stats.upgrade level
    -- really goes up. A failed try is usually just "not enough money": a unit is only dropped when it reached
    -- its max level (from the unit data) or made no progress for a long time.
    local unitDataCache = {}
    local function unitMaxLevel(u)
        local st = u:FindFirstChild("_stats")
        local idv = st and st:FindFirstChild("id")
        if not idv then return nil end
        local key = tostring(idv.Value)
        if unitDataCache[key] == nil then
            local ok, data = pcall(function()
                return require(ReplicatedStorage.src.Data.Units)[key]
            end)
            unitDataCache[key] = (ok and type(data) == "table" and type(data.upgrade) == "table") and #data.upgrade or false
        end
        return unitDataCache[key] or nil
    end

    local function unitState(u)
        local lvl = unitLevel(u)
        if lvl then return {level = lvl, n = 1} end
        local snap, n = {}, 0
        local root = u:FindFirstChild("_stats") or u
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("ValueBase") then snap[d] = d.Value; n = n + 1 end
        end
        for k, v in pairs(u:GetAttributes()) do snap["a:" .. k] = v; n = n + 1 end
        return {snap = snap, n = n}
    end

    local function unitChanged(u, before)
        if before.level then
            local now = unitLevel(u)
            return now ~= nil and now > before.level
        end
        for k, v in pairs(before.snap) do
            if type(k) == "string" then
                if u:GetAttribute(k:sub(3)) ~= v then return true end
            elseif k.Parent and k.Value ~= v then
                return true
            end
        end
        return false
    end

    local function capReached(u)
        local slot = unitSlot[u]
        if not slot then return false end
        local cap = opt(slotKind(slot) .. "MaxUpgrades", 0)
        local lvl = unitLevel(u) or upgradeCount[u] or 0
        return cap > 0 and lvl >= cap
    end

    local function noteFail(u, lvl)
        failStreak[u] = (failStreak[u] or 0) + 1
        failSince[u] = failSince[u] or tick()
        local dm = unitMaxLevel(u)
        if lvl and dm and lvl >= dm and failStreak[u] >= 3 then
            maxed[u] = true
            return
        end
        if tick() - failSince[u] >= opt("MaxedAfter", 120) then
            maxed[u] = true
        end
    end

    local function tryUpgrade(u)
        if maxed[u] then return false end
        if capReached(u) then maxed[u] = true; return false end
        local r = getRemote(opt("UpgradeRemote", DEFAULT_UPGRADE_REMOTE))
        if not r then return false end

        local before = unitState(u)
        local lvl0 = unitLevel(u)
        local ok, ret = pcall(callRemote, r, u)
        if upgLog < 8 then
            upgLog = upgLog + 1
            print(("[SummerEvent] upgrade %s: level %s, remote ok=%s returned=%s"):format(
                tostring(u.Name), tostring(lvl0), tostring(ok), tostring(ret)))
        end
        if not ok or ret == false then noteFail(u, lvl0); return false end

        local success = false
        if before.n == 0 then
            success = true
        else
            local t0 = tick()
            repeat
                task.wait(0.1)
                if unitChanged(u, before) then success = true; break end
            until tick() - t0 > 1.0
        end
        if success then
            upgradeCount[u] = (upgradeCount[u] or 0) + 1
            failStreak[u], failSince[u] = 0, nil
            return true
        end
        noteFail(u, lvl0)
        return false
    end

    -- my units on the map belong to the slot whose uuid they carry
    local function adoptUnits()
        local byUuid = {}
        for slot = 1, 6 do
            local id = resolveId(slot)
            if id then byUuid[tostring(id)] = slot end
        end
        for u in pairs((mySet())) do
            local uu = unitUuid(u)
            local slot = uu and byUuid[uu]
            if slot then
                unitSlot[u] = slot
                local list = placed[slot]
                if not list then list = {}; placed[slot] = list end
                local known = false
                for _, x in ipairs(list) do if x == u then known = true; break end end
                if not known then list[#list + 1] = u end
            end
        end
    end

    local function unitsFor(target)
        adoptUnits()
        local list = {}
        for slot = 1, 6 do
            local kind = slotKind(slot)
            if target == "All" or target == kind or target == ("Slot " .. slot) then
                for _, u in ipairs(placed[slot] or {}) do
                    if typeof(u) == "Instance" and u.Parent and not maxed[u] then
                        list[#list + 1] = {slot = slot, unit = u}
                    end
                end
            end
        end
        return list
    end

    local function upgradeWithRetry(token, u)
        while playing(token) do
            if not u.Parent or maxed[u] then return false end
            if tryUpgrade(u) then
                task.wait(opt("UpgradeDelay", 0.3))
                return true
            end
            if maxed[u] then return false end
            task.wait(math.min(opt("UpgradeDelay", 0.3) + (failStreak[u] or 0) * 0.05, 2))
        end
        return false
    end

    local function runStep(token, n)
        local target = opt("StepTarget" .. n, "None")
        local levels = opt("StepLevels" .. n, 0)
        if target == "None" or levels <= 0 then return end
        local list = unitsFor(target)
        if #list == 0 then
            print(("[SummerEvent] upgrade step %d (%s): no placed units for this target"):format(n, target))
            return
        end
        setState(("In match - upgrade step %d (%s x%d)"):format(n, target, levels))

        if opt("UpgradeStyle", "Round Robin") == "Round Robin" then
            for _ = 1, levels do
                for _, e in ipairs(list) do
                    if not playing(token) then return end
                    if not maxed[e.unit] then upgradeWithRetry(token, e.unit) end
                end
            end
        else
            for _, e in ipairs(list) do
                for _ = 1, levels do
                    if not playing(token) then return end
                    if maxed[e.unit] or not upgradeWithRetry(token, e.unit) then break end
                end
            end
        end
    end

    local function finalPhase(token)
        local target = opt("AfterSteps", "Stop")
        if target == "Stop" then return end
        setState("In match - upgrading " .. target .. " (endless)")
        while playing(token) do
            local list = unitsFor(target)
            local any = false
            for _, e in ipairs(list) do
                if not playing(token) then return end
                if tryUpgrade(e.unit) then any = true end
                task.wait(opt("UpgradeDelay", 0.3))
            end
            if #list == 0 then setState("In match - all " .. target .. " units maxed / none placed") end
            if not any then task.wait(1) end
        end
    end

    -- ── WEBHOOK: results, rewards and session stats ──────────────────────────
    local HttpService = game:GetService("HttpService")
    local SESSION_FILE = "SlimeHub_session_" .. tostring(LocalPlayer.UserId) .. ".json"
    local function newSessionTable()
        return {start = os.time(), last = os.time(), runs = 0, wins = 0, losses = 0, secs = 0, gold = 0, gems = 0, items = {}}
    end
    local session = newSessionTable()

    -- the script restarts after every teleport, so the session lives in a file
    pcall(function()
        if isfile and isfile(SESSION_FILE) then
            local d = HttpService:JSONDecode(readfile(SESSION_FILE))
            if type(d) == "table" and d.start and d.last then
                d.items = type(d.items) == "table" and d.items or {}
                session = d
            end
        end
    end)
    local function saveSession()
        pcall(function()
            if writefile then writefile(SESSION_FILE, HttpService:JSONEncode(session)) end
        end)
    end
    local function resetSession()
        session = newSessionTable()
        saveSession()
    end

    local function comma(n)
        local s2 = tostring(math.floor(n + 0.5))
        local k
        repeat s2, k = s2:gsub("^(-?%d+)(%d%d%d)", "%1,%2") until k == 0
        return s2
    end
    local function fmtTime(sec)
        sec = math.max(0, math.floor(sec))
        return ("%d:%02d:%02d"):format(math.floor(sec / 3600), math.floor(sec % 3600 / 60), sec % 60)
    end

    -- readable names for items / units
    local nameCache
    local function itemName(id)
        if not nameCache then
            nameCache = {}
            pcall(function()
                for _, m in ipairs(ReplicatedStorage.src.Data.Items:GetDescendants()) do
                    if m:IsA("ModuleScript") then
                        for k, v in pairs(require(m)) do
                            if type(v) == "table" and v.name then nameCache[k] = tostring(v.name) end
                        end
                    end
                end
                for k, v in pairs(require(ReplicatedStorage.src.Data.Units)) do
                    if type(v) == "table" and v.name then nameCache[k] = tostring(v.name) end
                end
            end)
        end
        return nameCache[id] or tostring(id)
    end

    -- inventory + currencies right now (compared before / after a match to find the drops)
    local function inventorySnapshot()
        local snap = {items = {}, units = {}, gold = 0, gems = 0}
        pcall(function()
            local Loader = require(ReplicatedStorage.src.Loader)
            local svc = Loader.load_client_service(script, "ItemInventoryServiceClient")
            local inv = svc.session.inventory.inventory_profile_data
            for id, n in pairs(inv.normal_items) do snap.items[tostring(id)] = tonumber(n) or 0 end
            for _, it in pairs(inv.unique_items) do
                local id = tostring(it.item_id)
                snap.items[id] = (snap.items[id] or 0) + 1
            end
            for _, u in pairs(svc.session.collection.collection_profile_data.owned_units) do
                local key = tostring(u.unit_id) .. (u.shiny and "|shiny" or "")
                snap.units[key] = (snap.units[key] or 0) + 1
            end
        end)
        pcall(function()
            local st = LocalPlayer:FindFirstChild("_stats")
            local g, m = st and st:FindFirstChild("gold_amount"), st and st:FindFirstChild("gem_amount")
            snap.gold = g and tonumber(g.Value) or 0
            snap.gems = m and tonumber(m.Value) or 0
        end)
        return snap
    end

    local function diffSnapshots(a, b)
        local out = {items = {}, units = {}, gold = math.max(0, b.gold - a.gold), gems = math.max(0, b.gems - a.gems)}
        for id, n in pairs(b.items) do
            local d = n - (a.items[id] or 0)
            if d > 0 then out.items[#out.items + 1] = {name = itemName(id), n = d} end
        end
        for key, n in pairs(b.units) do
            local d = n - (a.units[key] or 0)
            if d > 0 then
                local id, shiny = key:match("^(.-)|shiny$")
                out.units[#out.units + 1] = {name = itemName(id or key) .. (shiny and " (Shiny)" or ""), n = d}
            end
        end
        table.sort(out.items, function(x, y) return x.name < y.name end)
        table.sort(out.units, function(x, y) return x.name < y.name end)
        return out
    end

    -- what the results screen says (result, waves, time, every reward box)
    local function readResults()
        local out = {result = "UNKNOWN", rewards = {}}
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            local ui = pg and pg:FindFirstChild("ResultsUI")
            local h = ui and ui:FindFirstChild("Holder")
            if not h then return end
            local t = h:FindFirstChild("Title")
            if t then out.result = tostring(t.Text):upper() end
            local mid = h:FindFirstChild("Middle")
            local w = mid and mid:FindFirstChild("WavesCompleted")
            local ti = mid and mid:FindFirstChild("Timer")
            if w then out.waves = tostring(w.Text) end
            if ti then out.time = tostring(ti.Text) end
            local lr = h:FindFirstChild("LevelRewards")
            if lr then
                for _, d in ipairs(lr:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Name == "Amount" and d.Text ~= "" and d.Text ~= "+99999" and d.Text ~= "+0" then
                        local label
                        local cur = d.Parent
                        while cur and cur ~= lr do
                            if cur.Name:match("Reward$") then label = (cur.Name:gsub("Reward$", "")); break end
                            cur = cur.Parent
                        end
                        label = label or (d.Parent and d.Parent.Parent and d.Parent.Parent.Name) or "Reward"
                        out.rewards[#out.rewards + 1] = {label, tostring(d.Text)}
                    end
                end
            end
        end)
        return out
    end

    local reportThis, matchSnap, matchStartTick = false, nil, nil

    local function httpPost(url, body)
        local req = request or http_request or (syn and syn.request) or (http and http.request) or HttpPost
        if not req then return false, "your executor has no request function" end
        local ok, res = pcall(req, {Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body})
        if not ok then return false, tostring(res) end
        local code = type(res) == "table" and (res.StatusCode or res.status_code) or nil
        if code and code >= 300 then return false, "HTTP " .. tostring(code) end
        return true
    end

    local function limit(text, n)
        if #text > n then return text:sub(1, n - 4) .. "\n..." end
        return text
    end

    -- res = readResults() table, gained = diffSnapshots(), dur = match seconds, mode/mapName = text
    local function sendWebhook(res, gained, dur, mode, mapName, isTest)
        local url = tostring(opt("WebhookUrl", "") or "")
        if not url:match("^https://[%w%.]*discord[app]*%.com/api/webhooks/") then
            note("Webhook", "Set a valid Discord webhook URL first.", "Warning")
            return false
        end

        local won = res.result:find("VICTORY") ~= nil
        local lost = res.result:find("DEFEAT") ~= nil
        local color = won and 3066993 or (lost and 15158332 or 9807270)
        local title = won and "Victory" or (lost and "Defeat" or ("Match finished (" .. res.result .. ")"))
        if isTest then title = "Test message" end

        -- rewards of this run
        local lines = {}
        for _, r in ipairs(res.rewards) do lines[#lines + 1] = ("• %s: %s"):format(r[1], r[2]) end
        if #res.rewards == 0 then
            if gained.gold > 0 then lines[#lines + 1] = "• Gold: +" .. comma(gained.gold) end
            if gained.gems > 0 then lines[#lines + 1] = "• Gems: +" .. comma(gained.gems) end
        end
        for _, u in ipairs(gained.units) do lines[#lines + 1] = ("• NEW UNIT: %s x%d"):format(u.name, u.n) end
        if opt("WebhookShowItems", true) then
            for _, it in ipairs(gained.items) do lines[#lines + 1] = ("• %s x%d"):format(it.name, it.n) end
        end
        local rewardText = #lines > 0 and limit(table.concat(lines, "\n"), 1000) or "No rewards detected"

        -- match info
        local info = {("Mode: **%s**"):format(mode)}
        if mapName then info[#info + 1] = ("Map: **%s**"):format(mapName) end
        if res.waves then info[#info + 1] = res.waves end
        if dur then info[#info + 1] = "Match time: " .. fmtTime(dur) elseif res.time then info[#info + 1] = res.time end

        -- session
        local secs = os.time() - session.start
        local total = session.wins + session.losses
        local sess = {
            ("Runs: **%d**  (W %d / L %d%s)"):format(session.runs, session.wins, session.losses,
                total > 0 and (", " .. math.floor(session.wins / total * 100 + 0.5) .. "%% wins"):format() or ""),
            "Session time: **" .. fmtTime(secs) .. "**",
        }
        if secs > 60 and session.runs > 0 then
            sess[#sess + 1] = ("Runs per hour: %.1f"):format(session.runs / (secs / 3600))
        end
        if session.runs > 0 then sess[#sess + 1] = "Average run: " .. fmtTime(session.secs / session.runs) end
        if session.gold > 0 or session.gems > 0 then
            sess[#sess + 1] = ("Gained: %s gold, %s gems"):format(comma(session.gold), comma(session.gems))
        end

        local fields = {
            {name = "Match", value = table.concat(info, "\n"), inline = true},
            {name = "Rewards (this run)", value = rewardText, inline = false},
            {name = "Session", value = table.concat(sess, "\n"), inline = true},
        }
        if opt("WebhookShowItems", true) then
            local arr = {}
            for name, n in pairs(session.items) do arr[#arr + 1] = {name = name, n = n} end
            table.sort(arr, function(x, y) return x.n > y.n end)
            local txt = {}
            for i = 1, math.min(#arr, 12) do txt[#txt + 1] = ("• %s x%s"):format(arr[i].name, comma(arr[i].n)) end
            if #txt > 0 then fields[#fields + 1] = {name = "Session drops", value = limit(table.concat(txt, "\n"), 1000), inline = false} end
        end

        local who = LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name
        if opt("WebhookHideName", true) then who = "||" .. who .. "||" end

        local content = ""
        local pingId = tostring(opt("WebhookPingId", "") or ""):gsub("%D", "")
        if pingId ~= "" and #gained.units > 0 then content = "<@" .. pingId .. ">" end

        local payload = {
            content = content,
            username = "Slime Hub",
            embeds = {{
                title = title,
                description = "Player: " .. who,
                color = color,
                fields = fields,
                footer = {text = "Slime Hub"},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }},
        }
        local ok, err = httpPost(url, HttpService:JSONEncode(payload))
        if not ok then warn("[SummerEvent] webhook failed: " .. tostring(err)) end
        return ok, err
    end

    -- called once when a match is over (before leaving): counts the run, updates the session, posts the webhook
    local function reportMatch(token)
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local t0 = tick()
        while live(token) and tick() - t0 < 10 do -- wait for the results screen
            local ru = pg and pg:FindFirstChild("ResultsUI")
            if ru and ru.Enabled then break end
            task.wait(0.5)
        end
        task.wait(opt("WebhookDelay", 2.5)) -- rewards are added to the inventory a moment later

        local res = readResults()
        local after = inventorySnapshot()
        local gained = diffSnapshots(matchSnap or after, after)
        local dur = matchStartTick and (tick() - matchStartTick) or nil

        local castleHard = currentMode == "castle" and opt("CastleMode", "Normal") == "Hard"
        local hardFloor = opt("CastleHardFloor", 1)

        -- a long pause means a new session
        if os.time() - session.last > opt("SessionIdleMin", 30) * 60 then resetSession() end
        session.runs = session.runs + 1
        if res.result:find("VICTORY") then session.wins = session.wins + 1
        elseif res.result:find("DEFEAT") then session.losses = session.losses + 1 end
        session.secs = session.secs + (dur or 0)
        session.gold = session.gold + gained.gold
        session.gems = session.gems + gained.gems
        for _, it in ipairs(gained.items) do session.items[it.name] = (session.items[it.name] or 0) + it.n end
        for _, u in ipairs(gained.units) do session.items[u.name] = (session.items[u.name] or 0) + u.n end
        session.last = os.time()
        saveSession()

        -- Hard castle: a win clears floor N and N+1, so the next run starts at N+2 (a loss retries N)
        if castleHard and res.result:find("VICTORY") and opt("CastleHardAdvance", true) then
            local api = Window._flags["CastleHardFloor"]
            if api then
                api:Set(hardFloor + 2, true)
                pcall(function() Window.Config:Save() end) -- the script restarts after teleports: save now
            end
        end

        if not opt("WebhookEnabled", false) then return end
        local sendOn = opt("WebhookSendOn", "Wins and Losses")
        local won = res.result:find("VICTORY") ~= nil
        if sendOn == "Wins Only" and not won then return end
        if sendOn == "Losses Only" and won then return end

        local mode = "Summer Event"
        if currentMode == "castle" then
            mode = castleHard and ("Infinity Castle (Hard, floors %d-%d)"):format(hardFloor, hardFloor + 1) or "Infinity Castle"
        end
        task.spawn(function() sendWebhook(res, gained, dur, mode, currentMap and currentMap.name or nil, false) end)
        task.wait(1) -- give the request a head start before we teleport away
    end

    -- ── PHASES ───────────────────────────────────────────────────────────────
    local function returnToLobby(token)
        setState("Match finished - returning to lobby")
        task.wait(opt("ReturnDelay", 2))
        while live(token) and inMatch() do
            local r = getRemote("teleport_back_to_lobby")
            if r then pcall(function() r:InvokeServer() end) end
            for _ = 1, 40 do
                task.wait(0.5)
                if not live(token) or not inMatch() then return end
            end
        end
    end

    -- Infinity Castle: after a room
    local function castleFinish(token)
        setState("Castle room finished")
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local t0 = tick()
        while live(token) and tick() - t0 < 10 do
            local ru = pg and pg:FindFirstChild("ResultsUI")
            if ru and ru.Enabled then break end
            task.wait(0.5)
        end
        task.wait(opt("ReturnDelay", 2))

        if opt("CastleAfter", "Next Room") == "Next Room" and opt("CastleMode", "Normal") ~= "Hard" then
            local r = getRemote("request_start_infinite_tower_from_game")
            if r then
                for attempt = 1, 3 do
                    if not live(token) then return end
                    setState("Castle - starting next room (try " .. attempt .. ")")
                    pcall(function() r:InvokeServer("NextRetry") end)
                    local t1 = tick()
                    while live(token) and tick() - t1 < 8 do
                        task.wait(0.5)
                        if not inMatch() or not isFinished() then
                            local t2 = tick()
                            while live(token) and inMatch() and isStarted() and tick() - t2 < 20 do task.wait(0.5) end
                            return
                        end
                    end
                end
            end
        end
        returnToLobby(token)
    end

    local function finishMatch(token)
        if reportThis then
            reportThis = false
            pcall(reportMatch, token)
        end
        if currentMode == "castle" then castleFinish(token) else returnToLobby(token) end
    end

    local function matchPhase(token)
        placed, usedPos = {}, {}
        maxed, upgradeCount, unitSlot = {}, {}, {}
        failStreak, failSince, upgLog = {}, {}, 0
        zoomApplied = false
        local tIn = tick()
        -- a fresh match: remember the inventory now, to find out what we got at the end
        reportThis = not isFinished()
        matchSnap = reportThis and inventorySnapshot() or nil
        matchStartTick = nil

        setState("In match - recognising the map")
        resolveMap(token)

        setState("In match - waiting for start")
        local voted = false
        while live(token) and not isStarted() and not isFinished() do
            -- vote to start once, a few seconds after arriving; then keep waiting for GameStarted
            -- (not everyone votes, the game can still take up to ~60s to start by itself)
            if not voted and opt("AutoVote", true) and tick() - tIn >= opt("VoteDelay", 5) then
                voted = true
                setState("In match - voted to start, waiting for game")
                local vr = getRemote("vote_start")
                if vr then task.spawn(function() pcall(function() vr:InvokeServer() end) end) end
            end
            task.wait(0.5)
        end
        if not live(token) then return end
        matchStartTick = tick()

        if not isFinished() then
            placeAll(token)
            for n = 1, 6 do
                if not playing(token) then break end
                runStep(token, n)
            end
            finalPhase(token)
            if playing(token) then setState("In match - waiting for finish") end
            while playing(token) do task.wait(0.5) end
        end
        if live(token) then finishMatch(token) end
    end

    -- Infinity Castle: lobby
    local CASTLE_CFRAME = CFrame.new(12423.1855, 155.24025, 3198.07593, -1.34111269e-06, -2.02512282e-08, 1,
        3.91705386e-13, 1, 2.02512282e-08, -1, 4.18864542e-13, -1.34111269e-06)

    local function nextCastleRoom()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local ui = pg and pg:FindFirstChild("InfiniteTowerUI")
        local ls = ui and ui:FindFirstChild("LevelSelect")
        local info = ls and ls:FindFirstChild("InfoFrame")
        local btns = info and info:FindFirstChild("LevelButtons")
        if not btns then return nil end
        local best
        for _, v in ipairs(btns:GetChildren()) do
            if v.Name == "FloorButton" then
                local ok, room = pcall(function()
                    if v.clear.Visible == false and v.Locked.Visible == false then
                        return tonumber(string.split(v.Main.text.Text, " ")[2])
                    end
                end)
                if ok and room and (not best or room < best) then best = room end
            end
        end
        return best
    end

    -- Infinity Castle HARD: open_infinite_tower_portal(floor, "Hard", {friends_only}) - one run plays floor N and N+1
    local function startMyPortalLobby()
        -- if a portal lobby owned by me already exists, start it (some portals need this extra step)
        local started = false
        pcall(function()
            for _, v in ipairs(Workspace._PORTALS.Lobbies:GetDescendants()) do
                if v.Name == "Owner" and tostring(v.Value) == LocalPlayer.Name then
                    local r = getRemote("request_start_game")
                    if r then
                        pcall(function() r:InvokeServer(tostring(v.Parent.Name)) end)
                        started = true
                    end
                    break
                end
            end
        end)
        return started
    end

    local function castleHardLobby(token)
        local floor = math.max(1, opt("CastleHardFloor", 1))
        if startMyPortalLobby() then
            setState("In lobby - starting Hard portal (floor " .. floor .. ")")
        else
            setState("In lobby - opening Hard floor " .. floor .. " (+" .. (floor + 1) .. ")")
            local r = getRemote("open_infinite_tower_portal")
            if r then
                local ok, ret = pcall(function()
                    return r:InvokeServer(floor, "Hard", {friends_only = opt("CastleHardFriends", false)})
                end)
                print(("[SummerEvent] open_infinite_tower_portal(%d, Hard) ok=%s returned=%s"):format(floor, tostring(ok), tostring(ret)))
            end
            task.wait(2)
            if not inMatch() then startMyPortalLobby() end
        end
        local t0 = tick()
        while live(token) and tick() - t0 < math.max(opt("CastleRetry", 10), 15) do
            task.wait(0.5)
            if inMatch() then return end
        end
    end

    local function castleLobbyPhase(token)
        if opt("CastleMode", "Normal") == "Hard" then return castleHardLobby(token) end
        local room = opt("CastleFloor", 0)
        if room <= 0 then
            setState("In lobby - looking for the next castle floor")
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if opt("CastleTeleport", true) and hrp then
                hrp.CFrame = CASTLE_CFRAME
                task.wait(1)
            end
            room = nil
            for _ = 1, 12 do
                room = nextCastleRoom()
                if room or not live(token) then break end
                task.wait(0.5)
            end
        end
        if not room then
            setState("Castle: no open floor found (UI not loaded?) - retrying")
            task.wait(3)
            return
        end
        setState("In lobby - starting castle floor " .. room)
        local r = getRemote("request_start_infinite_tower")
        if r then pcall(function() r:InvokeServer(room) end) end
        local t0 = tick()
        while live(token) and tick() - t0 < opt("CastleRetry", 10) do
            task.wait(0.5)
            if inMatch() then return end
        end
    end

    local function lobbyPhase(token)
        if currentMode == "castle" then return castleLobbyPhase(token) end
        local event = tostring(opt("SummerEventName", "summer2_event"))
        setState("In lobby - joining " .. event)
        local r = getRemote("request_matchmaking")
        if r then pcall(function() r:InvokeServer(event) end) end
        local t0 = tick()
        while live(token) and tick() - t0 < opt("JoinRetry", 10) do
            task.wait(0.5)
            if inMatch() then return end
        end
    end

    local function stopLoop()
        running = false
        runToken = runToken + 1
        restoreZoom()
    end

    local function startLoop(mode)
        if running then
            if currentMode == mode then return end
            stopLoop()
        end
        currentMode = mode
        running = true
        runToken = runToken + 1
        local token = runToken
        task.spawn(function()
            if not game:IsLoaded() then game.Loaded:Wait() end
            task.wait(opt("StartupDelay", 3))
            while live(token) do
                local ok, err = pcall(function()
                    if inMatch() then matchPhase(token) else lobbyPhase(token) end
                end)
                if not ok then warn("[SummerEvent] " .. tostring(err)); task.wait(2) end
                task.wait(0.5)
            end
            setState("Stopped")
        end)
    end

    -- ── ANTI AFK: a click at a random place through VirtualUser ──────────────
    local VirtualUser = game:GetService("VirtualUser")
    local function afkClick()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local pos = Vector2.new(
            math.random(math.floor(vp.X * 0.1), math.floor(vp.X * 0.9)),
            math.random(math.floor(vp.Y * 0.2), math.floor(vp.Y * 0.8)))
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(pos, cam.CFrame)
            task.wait(0.05)
            VirtualUser:Button1Up(pos, cam.CFrame)
        end)
    end

    LocalPlayer.Idled:Connect(function()
        if opt("AntiAFK", true) then afkClick() end
    end)

    task.spawn(function()
        local last = tick()
        while true do
            task.wait(1)
            if opt("AntiAFK", true) and tick() - last >= opt("AFKInterval", 60) then
                last = tick()
                if not clickBusy then afkClick() end
            end
        end
    end)

    -- ── MEGUMIN: use her ability from upgrade level 6 on, centred on her exact position ──
    local lastMegumin = {}
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if not opt("MeguminAbility", true) then return end
                if not (running and inMatch() and isStarted() and not isFinished()) then return end
                local r = getRemote("use_active_attack")
                if not r then return end
                for u in pairs((mySet())) do
                    local st = u:FindFirstChild("_stats")
                    local idv = st and st:FindFirstChild("id")
                    if idv and tostring(idv.Value) == "megumin" then
                        local stateV = st:FindFirstChild("state")
                        local ready = (not opt("MeguminOnlyAttack", true)) or (not stateV) or tostring(stateV.Value) == "attack"
                        if (unitLevel(u) or 0) >= opt("MeguminMinLevel", 6) and ready
                            and tick() - (lastMegumin[u] or 0) >= opt("MeguminEvery", 5) then
                            lastMegumin[u] = tick()
                            local root = u:FindFirstChild("HumanoidRootPart")
                            local p = root and root.Position or u:GetPivot().Position
                            local point = (vector and vector.create) and vector.create(p.X, p.Y, p.Z) or Vector3.new(p.X, p.Y, p.Z)
                            task.spawn(function() pcall(function() r:InvokeServer(u, {aoe_point = point}) end) end)
                        end
                    end
                end
            end)
        end
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    --  UI
    -- ══════════════════════════════════════════════════════════════════════════
    local SumTab = Window:CreateTab({Name = "Summer Event", Icon = "beach_access"})

    -- ·· Main ····················································································
    local MN = SumTab:CreateSubTab({Name = "Main"})
    local gMain = MN:CreateGroup({Name = "Auto Summer Event", Icon = "play_arrow"})
    gMain:CreateToggle({Name = "Auto Summer Event", Default = false, Flag = "AutoSummer",
        Callback = function(v)
            if v then
                local c = Window._flags["AutoCastle"]
                if c and c:Get() then c:Set(false, true) end -- only one feature at a time
                startLoop("summer")
            elseif currentMode == "summer" then
                stopLoop()
            end
        end})
    stateLbl = gMain:CreateLabel({Text = "State: Idle"})
    gMain:CreateInput({Name = "Event Name (Enter)", Default = "summer2_event", Flag = "SummerEventName"})

    local gMap = MN:CreateGroup({Name = "Map", Icon = "map"})
    mapLbl = gMap:CreateLabel({Text = "Map: (recognised when a match starts)"})
    gMap:CreateButton({Name = "Detect Map Now", Icon = "search", Callback = function()
        local m, score, present = detectMap()
        if m then
            currentMap = m
            local txt = ("Map: %s (%d%% match) - %d ground / %d hill spots"):format(m.name, math.floor(score * 100), #m.ground, #m.hill)
            mapLbl:Set(txt)
            print("[SummerEvent] " .. txt)
            note("Map", m.name, "Success")
        else
            local names = {}
            for k in pairs(present or {}) do names[#names + 1] = k end
            table.sort(names)
            print("[SummerEvent] map not recognised. workspace._map contains: " .. table.concat(names, ", "))
            note("Map", "Not recognised (see console F9).", "Warning")
        end
    end})

    local gTime = MN:CreateGroup({Name = "Timing", Icon = "timer"})
    gTime:CreateSlider({Name = "Startup Delay", Min = 0, Max = 20, Default = 3, Suffix = "s", Flag = "StartupDelay"})
    gTime:CreateSlider({Name = "Join Retry Every", Min = 3, Max = 30, Default = 10, Suffix = "s", Flag = "JoinRetry"})
    gTime:CreateToggle({Name = "Auto Vote Start", Default = true, Flag = "AutoVote", HideFromActive = true})
    gTime:CreateSlider({Name = "Vote Start After", Min = 0, Max = 30, Default = 5, Suffix = "s", Flag = "VoteDelay"})
    gTime:CreateSlider({Name = "Return To Lobby Delay", Min = 0, Max = 15, Default = 2, Suffix = "s", Flag = "ReturnDelay"})

    local gSafe = MN:CreateGroup({Name = "Auto Rejoin (stuck loading)", Icon = "refresh"})
    gSafe:CreateToggle({Name = "Rejoin If Stuck Loading", Default = true, Flag = "AutoRejoin", HideFromActive = true})
    gSafe:CreateSlider({Name = "Rejoin After", Min = 30, Max = 300, Increment = 10, Default = 90, Suffix = "s", Flag = "RejoinAfter"})
    gSafe:CreateInput({Name = "Rejoin Place ID (Enter)", Placeholder = "empty = current place", Flag = "RejoinPlaceId"})
    local gAfk = MN:CreateGroup({Name = "Anti AFK", Icon = "touch_app"})
    gAfk:CreateToggle({Name = "Anti AFK", Default = true, Flag = "AntiAFK", HideFromActive = true})
    gAfk:CreateSlider({Name = "Random Click Every", Min = 10, Max = 300, Increment = 5, Default = 60, Suffix = "s", Flag = "AFKInterval"})

    gSafe:CreateInput({Name = "Loading GUI Name (Enter)", Placeholder = "optional, exact ScreenGui name", Flag = "LoadingGuiName"})

    -- ·· Units ···················································································
    local UN = SumTab:CreateSubTab({Name = "Units"})
    local gTypes = UN:CreateGroup({Name = "Hotbar Role (Farm / DPS use ground spots, Hill uses hill spots)", Icon = "groups"})
    for i = 1, 6 do
        gTypes:CreateDropdown({Name = "Slot " .. i, Options = {"Farm", "DPS", "Hill", "Off"},
            Default = (i <= 2) and "Farm" or "DPS", Flag = "SlotType" .. i})
    end
    gTypes:CreateDropdown({Name = "Place Order", Options = {"Slot Order", "Farm First", "DPS First", "Hill First"},
        Default = "Slot Order", Flag = "PlaceOrder"})

    local gCount = UN:CreateGroup({Name = "How Many To Place Per Slot", Icon = "format_list_numbered"})
    gCount:CreateLabel({Text = "0 skips the slot. All copies of a slot get the same role and the same upgrades."})
    for i = 1, 6 do
        gCount:CreateSlider({Name = "Slot " .. i .. " Count", Min = 0, Max = 12, Default = 1, Flag = "SlotCount" .. i})
    end

    local gIds = UN:CreateGroup({Name = "Unit IDs (read from your equipped team)", Icon = "badge"})
    gIds:CreateToggle({Name = "Auto Detect Unit IDs", Default = true, Flag = "AutoDetectIds", HideFromActive = true})
    gIds:CreateButton({Name = "Detect Unit IDs Now", Icon = "search", Callback = function() autoFillIds(false) end})
    for i = 1, 6 do
        gIds:CreateInput({Name = "Slot " .. i .. " ID", Placeholder = "unit id", Flag = "SlotId" .. i})
    end

    -- ·· Upgrades ················································································
    local UP = SumTab:CreateSubTab({Name = "Upgrades"})
    local targets = {"None", "Farm", "DPS", "Hill", "All", "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5", "Slot 6"}
    local defTargets = {"Farm", "DPS", "Farm", "DPS", "None", "None"}
    local defLevels  = {3, 3, 3, 5, 0, 0}

    local gSteps = UP:CreateGroup({Name = "Upgrade Order (runs top to bottom)", Icon = "trending_up"})
    gSteps:CreateLabel({Text = "Each step upgrades the chosen group N times per unit. Units are always all placed first."})
    for n = 1, 6 do
        gSteps:CreateDropdown({Name = "Step " .. n .. " Target", Options = targets, Default = defTargets[n], Flag = "StepTarget" .. n})
        gSteps:CreateSlider({Name = "Step " .. n .. " Levels", Min = 0, Max = 25, Default = defLevels[n], Flag = "StepLevels" .. n})
    end

    local gUpOpt = UP:CreateGroup({Name = "Upgrade Options", Icon = "tune"})
    gUpOpt:CreateDropdown({Name = "Style", Options = {"Round Robin", "One By One"}, Default = "Round Robin", Flag = "UpgradeStyle"})
    gUpOpt:CreateDropdown({Name = "After All Steps", Options = {"Stop", "Farm", "DPS", "Hill", "All"}, Default = "Stop", Flag = "AfterSteps"})
    gUpOpt:CreateSlider({Name = "Upgrade Delay", Min = 0.1, Max = 3, Increment = 0.1, Default = 0.3, Suffix = "s", Flag = "UpgradeDelay"})
    gUpOpt:CreateSlider({Name = "Mark Unit Maxed After No Progress", Min = 20, Max = 900, Increment = 10, Default = 120, Suffix = "s", Flag = "MaxedAfter"})
    gUpOpt:CreateSlider({Name = "Farm Max Upgrades (0 = auto)", Min = 0, Max = 30, Default = 0, Flag = "FarmMaxUpgrades"})
    gUpOpt:CreateSlider({Name = "DPS Max Upgrades (0 = auto)", Min = 0, Max = 30, Default = 0, Flag = "DPSMaxUpgrades"})
    gUpOpt:CreateSlider({Name = "Hill Max Upgrades (0 = auto)", Min = 0, Max = 30, Default = 0, Flag = "HillMaxUpgrades"})
    gUpOpt:CreateInput({Name = "Upgrade Remote (Enter)", Default = DEFAULT_UPGRADE_REMOTE, Flag = "UpgradeRemote"})

    local gAb = UP:CreateGroup({Name = "Abilities", Icon = "bolt"})
    gAb:CreateToggle({Name = "Megumin: Use Ability", Default = true, Flag = "MeguminAbility"})
    gAb:CreateSlider({Name = "Megumin: Min Upgrade Level", Min = 0, Max = 30, Default = 6, Flag = "MeguminMinLevel"})
    gAb:CreateSlider({Name = "Megumin: Use At Most Every", Min = 1, Max = 60, Default = 5, Suffix = "s", Flag = "MeguminEvery"})
    gAb:CreateToggle({Name = "Megumin: Only While Attacking", Default = true, Flag = "MeguminOnlyAttack", HideFromActive = true})

    -- ·· Placement ···············································································
    local PL = SumTab:CreateSubTab({Name = "Placement"})

    local gMeth = PL:CreateGroup({Name = "Placing Method", Icon = "touch_app"})
    gMeth:CreateDropdown({Name = "Method", Options = {"Remote", "Click"}, Default = "Remote", Flag = "PlaceMethod"})
    gMeth:CreateLabel({Text = "Remote: instant, uses spawn_unit on the recorded spots. Click: zooms out, walks near the spot, presses the hotbar key (1-6) and clicks the spot on screen."})
    gMeth:CreateSlider({Name = "Click: Zoom Out Distance", Min = 20, Max = 500, Increment = 10, Default = 150, Suffix = " st", Flag = "ZoomDistance"})
    gMeth:CreateSlider({Name = "Click: Hover Time Before Click", Min = 0.1, Max = 2, Increment = 0.1, Default = 0.5, Suffix = "s", Flag = "HoverTime"})
    gMeth:CreateSlider({Name = "Click: Walk Until Within", Min = 5, Max = 80, Default = 20, Suffix = " st", Flag = "WalkRadius"})
    gMeth:CreateSlider({Name = "Click: Walk Timeout", Min = 2, Max = 30, Default = 10, Suffix = "s", Flag = "WalkTimeout"})
    gMeth:CreateToggle({Name = "Click: Keep Jumping While Walking", Default = true, Flag = "AlwaysJump", HideFromActive = true})
    gMeth:CreateSlider({Name = "Click: Ignore Top Of Screen", Min = 0, Max = 50, Default = 25, Suffix = "%", Flag = "ScreenTopMargin"})
    gMeth:CreateSlider({Name = "Click: Ignore Bottom Of Screen", Min = 0, Max = 40, Default = 10, Suffix = "%", Flag = "ScreenBottomMargin"})
    gMeth:CreateToggle({Name = "Click: Skip Spots Blocked From View", Default = true, Flag = "ViewCheck", HideFromActive = true})
    gMeth:CreateInput({Name = "Click: Cancel Key (Enter)", Default = "Q", Placeholder = "key to cancel placing", Flag = "CancelKey"})

    local gSp = PL:CreateGroup({Name = "Which Recorded Spots To Use", Icon = "place"})
    gSp:CreateLabel({Text = "Farm and DPS share the ground spots, Hill uses the hill spots. Spots are numbered in the order they were recorded."})
    gSp:CreateSlider({Name = "Ground Spots: From #", Min = 1, Max = 150, Default = 1, Flag = "GroundSpotFrom"})
    gSp:CreateSlider({Name = "Ground Spots: To # (0 = all)", Min = 0, Max = 150, Default = 0, Flag = "GroundSpotTo"})
    gSp:CreateSlider({Name = "Hill Spots: From #", Min = 1, Max = 150, Default = 1, Flag = "HillSpotFrom"})
    gSp:CreateSlider({Name = "Hill Spots: To # (0 = all)", Min = 0, Max = 150, Default = 0, Flag = "HillSpotTo"})
    gSp:CreateDropdown({Name = "DPS Spot Order", Options = {"First to Last", "Last to First", "Random"}, Default = "First to Last", Flag = "DPSSpotOrder"})
    gSp:CreateDropdown({Name = "Farm Spot Order", Options = {"First to Last", "Last to First", "Random"}, Default = "Last to First", Flag = "FarmSpotOrder"})
    gSp:CreateDropdown({Name = "Hill Spot Order", Options = {"First to Last", "Last to First", "Random"}, Default = "First to Last", Flag = "HillSpotOrder"})

    local gTry = PL:CreateGroup({Name = "Retries / Timeouts", Icon = "timer"})
    gTry:CreateSlider({Name = "Tries Per Spot", Min = 1, Max = 10, Default = 2, Flag = "RetriesPerSpot"})
    gTry:CreateSlider({Name = "Delay Between Tries", Min = 0.1, Max = 3, Increment = 0.1, Default = 0.4, Suffix = "s", Flag = "PlaceDelay"})
    gTry:CreateSlider({Name = "Give Up On A Unit After", Min = 30, Max = 600, Increment = 10, Default = 180, Suffix = "s", Flag = "PlaceTimeout"})

    -- ══════════════════════════════════════════════════════════════════════════
    --  WEBHOOK TAB
    -- ══════════════════════════════════════════════════════════════════════════
    local WhTab = Window:CreateTab({Name = "Webhook", Icon = "send"})
    local WH = WhTab:CreateSubTab({Name = "Main"})

    local gWh = WH:CreateGroup({Name = "Discord Webhook", Icon = "send"})
    gWh:CreateToggle({Name = "Send Webhook After Each Match", Default = false, Flag = "WebhookEnabled", HideFromActive = true})
    gWh:CreateInput({Name = "Webhook URL (Enter)", Placeholder = "https://discord.com/api/webhooks/...", Flag = "WebhookUrl"})
    gWh:CreateDropdown({Name = "Send On", Options = {"Wins and Losses", "Wins Only", "Losses Only"}, Default = "Wins and Losses", Flag = "WebhookSendOn"})
    gWh:CreateToggle({Name = "Hide My Name (spoiler)", Default = true, Flag = "WebhookHideName", HideFromActive = true})
    gWh:CreateToggle({Name = "List Item Drops", Default = true, Flag = "WebhookShowItems", HideFromActive = true})
    gWh:CreateInput({Name = "Ping Discord User ID On New Unit (Enter)", Placeholder = "optional", Flag = "WebhookPingId"})
    gWh:CreateSlider({Name = "Wait Before Reading Rewards", Min = 0, Max = 10, Increment = 0.5, Default = 2.5, Suffix = "s", Flag = "WebhookDelay"})
    gWh:CreateButton({Name = "Send Test Webhook", Icon = "send", Callback = function()
        local ok, err = sendWebhook({result = "TEST", rewards = {{"Gold", "+1,000"}, {"Gems", "+50"}}, waves = "Waves Completed: 15"},
            {items = {}, units = {}, gold = 0, gems = 0}, 600, "Summer Event", currentMap and currentMap.name or "test map", true)
        if ok then note("Webhook", "Test message sent.", "Success")
        elseif err then note("Webhook", "Failed: " .. tostring(err), "Error") end
    end})

    local gSess = WH:CreateGroup({Name = "Session", Icon = "timer"})
    local sessLbl = gSess:CreateLabel({Text = "Session: no runs yet"})
    gSess:CreateSlider({Name = "New Session After Idle", Min = 5, Max = 240, Increment = 5, Default = 30, Suffix = " min", Flag = "SessionIdleMin"})
    gSess:CreateButton({Name = "Reset Session Stats", Icon = "refresh", Callback = function()
        resetSession()
        note("Session", "Session stats reset.", "Info")
    end})
    task.spawn(function()
        while true do
            local total = session.wins + session.losses
            sessLbl:Set(("Runs %d | W %d / L %d | %s | gold +%s | gems +%s"):format(
                session.runs, session.wins, session.losses, fmtTime(os.time() - session.start), comma(session.gold), comma(session.gems)))
            task.wait(5)
        end
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    --  INFINITY CASTLE TAB (uses the SAME units / upgrades / placement settings as the Summer Event tab)
    -- ══════════════════════════════════════════════════════════════════════════
    local CasTab = Window:CreateTab({Name = "Infinity Castle", Icon = "domain"})
    local CS = CasTab:CreateSubTab({Name = "Main"})

    local gCas = CS:CreateGroup({Name = "Auto Infinity Castle", Icon = "play_arrow"})
    gCas:CreateToggle({Name = "Auto Infinity Castle", Default = false, Flag = "AutoCastle",
        Callback = function(v)
            if v then
                local c = Window._flags["AutoSummer"]
                if c and c:Get() then c:Set(false, true) end
                startLoop("castle")
            elseif currentMode == "castle" then
                stopLoop()
            end
        end})
    castleLbl = gCas:CreateLabel({Text = "State: Idle"})
    gCas:CreateLabel({Text = "Units, upgrade steps, placement and timing use the same settings as the Summer Event tab."})

    local gCasMode = CS:CreateGroup({Name = "Mode", Icon = "layers"})
    gCasMode:CreateDropdown({Name = "Difficulty", Options = {"Normal", "Hard"}, Default = "Normal", Flag = "CastleMode"})
    gCasMode:CreateLabel({Text = "Hard plays two floors per run (floor N and N+1). It always returns to the lobby and opens the next Hard portal."})
    gCasMode:CreateSlider({Name = "Hard: Floor To Start", Min = 1, Max = 200, Default = 1, Flag = "CastleHardFloor"})
    gCasMode:CreateToggle({Name = "Hard: Move On By 2 After A Win", Default = true, Flag = "CastleHardAdvance", HideFromActive = true})
    gCasMode:CreateToggle({Name = "Hard: Friends Only", Default = false, Flag = "CastleHardFriends", HideFromActive = true})

    local gCasOpt = CS:CreateGroup({Name = "Normal Mode Options", Icon = "tune"})
    gCasOpt:CreateSlider({Name = "Floor (0 = next uncleared)", Min = 0, Max = 200, Default = 0, Flag = "CastleFloor"})
    gCasOpt:CreateDropdown({Name = "After A Room", Options = {"Next Room", "Return To Lobby"}, Default = "Next Room", Flag = "CastleAfter"})
    gCasOpt:CreateToggle({Name = "Teleport To Castle First (loads the floor UI)", Default = true, Flag = "CastleTeleport", HideFromActive = true})
    gCasOpt:CreateSlider({Name = "Retry Start Every", Min = 3, Max = 30, Default = 10, Suffix = "s", Flag = "CastleRetry"})
end
-- ── QUICK ACTION BAR ──────────────────────────────────────────────────────────
Window:AddQuickAction({Icon="minimize",      Callback=function() Window:EnterMiniMode() end})
Window:AddQuickAction({Icon="notifications", Callback=function() Window:ShowNotifHistory() end})
Window:AddQuickAction({Icon="keyboard",      Callback=function() Window:ShowKeybindViewer() end})

-- ── FINISH ────────────────────────────────────────────────────────────────────
-- load saved config only AFTER every element exists
Config:AutoLoad()
Window:FinishSetup()
refreshProfiles()
