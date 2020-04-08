----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------
if not PP then PP = {} end

PP.settings = {
	persistent = false,
	ordering = { L"Default", L"Name", L"Count" },
	filter = "",

	windows = {
		["main"] = { name = "PPMain", width = 0, height = 0, x = 0, y = 0, minimized = false, anchor = {} }
	},
	--items = {15,9,10,13,6,7,14,8}
	items = {
		{ slot = 15, iconNum = 11, dyes = {} },
		{ slot = 9, iconNum = 9, dyes = {} },
		{ slot = 10, iconNum = 10, dyes = {} },
		{ slot = 13, iconNum = 13, dyes = {} },
		{ slot = 6, iconNum = 6, dyes = {} },
		{ slot = 7, iconNum = 7, dyes = {} },
		{ slot = 14, iconNum = 14, dyes = {} },
		{ slot = 8, iconNum = 8, dyes = {} }
	},
	itemsPersist = {
		{ slot = 15, iconNum = 11, dyes = {} },
		{ slot = 9, iconNum = 9, dyes = {} },
		{ slot = 10, iconNum = 10, dyes = {} },
		{ slot = 13, iconNum = 13, dyes = {} },
		{ slot = 6, iconNum = 6, dyes = {} },
		{ slot = 7, iconNum = 7, dyes = {} },
		{ slot = 14, iconNum = 14, dyes = {} },
		{ slot = 8, iconNum = 8, dyes = {} }
	},
	items_defaults = {
		["primary"] = {r=0, g=0, b=0, a=0.1},
		["secondary"] = {r=0, g=0, b=0, a=0.1}
	}
}
PP.selectedDyeIndex = 1

PP.introText = L"This addon lets you preview all available dyes in game."
PP.introGuide = L"1. Select a dye from the Dye Picker. A specific dye can be located by entering the name of the dye into the Name filter, or by changing the Ordering method for the list. \n2. Apply the selected dye to an item slot using left/right mouse buttons. Alternatively color the All slot, to apply the same dyes to all item slots. \n3. The character model is now recolored with the selected dyes."
PP.itemWindowGuide = L"Click an item slot to apply a selected dye.\n\nLeft Click: Set primary color\nRight Click: Set secondary color\n\nClick twice to remove the dye"
PP.toolTips = {
	items = {
		[15] = L"Apply dye to all Items.\n\nThis has lower priorty then setting a color for a specific item slot.",
		[9] = L"Helm",
		[10] = L"Shoulders",
		[13] = L"Back",
		[6] = L"Body",
		[7] = L"Gloves",
		[14] = L"Belt",
		[8] = L"Boots",
	}
}

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local pp_debug = false

if (pp_debug) then
d("HighlightWindow( window ) : available")
function HighlightWindow( window )
	if( WindowGetShowing( HelpTips.FOCUS_WINDOW_NAME ) ) then
		WindowStopAlphaAnimation( HelpTips.FOCUS_WINDOW_NAME )
		WindowSetShowing( HelpTips.FOCUS_WINDOW_NAME, false )
	end
	HelpTips.SetFocusOnWindow( window )
end
end

----------------------------------------------------------------
-- Main
----------------------------------------------------------------



--
--	Initialize everything
--
function PP.Initialize()

	local mainWindow = "PPMain"
	
	-- Register /pp slash command
	LibSlash.RegisterSlashCmd("pp", function()
		WindowSetShowing(mainWindow, true)
	end )
	TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, L"Pocket Palette: Type /PP to show window")

	-- Update items when a item is equipped
	--WindowRegisterEventHandler(mainWindow, SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "PP.UpdateItemSlots")
	RegisterEventHandler(SystemData.Events.ITEM_SET_DATA_ARRIVED, "PP.UpdateItemSlots")
	RegisterEventHandler(SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "PP.UpdateItemSlots")
	RegisterEventHandler(SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED, "PP.UpdateItemSlots")
--	RegisterEventHandler(SystemData.Events.VISIBLE_EQUIPMENT_UPDATED, "PP.UpdateItemSlots")
	

	PP.CreateWindow()
	PP.PersistentSettings()
	PP.GetDyeData()
	PP.UpdateDyeList()
--	PP.PreviewDyes()
	RegisterEventHandler(SystemData.Events.LOADING_END, "PP.PreviewDyes")
end


	function PP.OnShown()
		if (pp_debug) then d("PP.OnShown") end
		PP.PreviewDyes()
		PP.UpdateDyeCounts()
		PP.UpdateItemSlots()
	end
	function PP.OnClose()
		if (pp_debug) then d("PP.OnClose") end
		PP.ResetPreviewDyes()
		WindowSetShowing(PP.settings.windows.main.name, false)
	end

--
--	Create main window
--
function PP.CreateWindow()
	if (pp_debug) then d("PP CreateWindow") end
	
	local mainWindow = "PPMain"
	
	CreateWindow(mainWindow,false)
	
	-- Main Window
	LabelSetText(mainWindow.."TitleBarText", L"Pocket Palette by Eibon")
--	ButtonSetText(mainWindow.."RefreshBtn", L"Refresh")
	ButtonSetText(mainWindow.."CharacterWindowBtn", L"Paperdoll")
	ButtonSetText(mainWindow.."TogglePickerBtn", L"Hide")
	
	LabelSetText(mainWindow.."IntroText", PP.introText)
	LabelSetText(mainWindow.."IntroGuide", PP.introGuide)

	LabelSetText(mainWindow.."SaveSettingsLabel", L"Persistent settings")
	ButtonSetPressedFlag(mainWindow.."SaveSettingsButton", PP.settings.persistent);

	-- Dye window
	local dyeWindow = "DyeWindow"
	LabelSetText(dyeWindow.."TitleBarText", L"Dye Picker")
	LabelSetText(dyeWindow.."SelectedDye", L"Selected Dye")

	LabelSetText(dyeWindow.."Filter", L"Name filter:")
	LabelSetText(dyeWindow.."DyeOrder", L"Ordering:")

	for k, v in pairs(PP.settings.ordering) do
		ComboBoxAddMenuItem (dyeWindow.."DyeOrderCombo", v)
	end
	ComboBoxSetSelectedMenuItem (dyeWindow.."DyeOrderCombo", 1)
	
	-- Item slot window
	local itemWindow = "ItemWindow"
	LabelSetText(itemWindow.."TitleBarText", L"Item Slots")
	LabelSetText(itemWindow.."Guide", PP.itemWindowGuide)

--	PP.UpdateItemSlots()

	-- Save window settings		
	PP.settings.windows["main"].width, PP.settings.windows["main"].height = WindowGetDimensions(PP.settings.windows["main"].name)
	--PP.settings.windows["main"].x, PP.settings.windows["main"].y = WindowGetScreenPosition(PP.settings.windows["main"].name)
	local point,relpoint,relwin,x,y = WindowGetAnchor(PP.settings.windows["main"].name, 1)
	PP.settings.windows["main"].anchor.x = x
	PP.settings.windows["main"].anchor.y = y
	
end

function PP.PersistentSettings()
--	local isChecked = ButtonGetPressedFlag(CheckBox) == false;
	if (PP.settings.persistent == false) then
		PP.settings.items = PP.settings.itemsPersist
	end
end

function PP.PersistantToggle()
	local CheckBox = "PPMain" .. "SaveSettings" .. "Button"
	PP.settings.persistent = PP.settings.persistent == false;
	ButtonSetPressedFlag(CheckBox, PP.settings.persistent);
end

--
--	Load dye data
--
function PP.GetDyeData()

	local function isBadDye(s)
		return
			s == nil
			or s == ''
			or s == '0'
			or s == 0
			or s == 'PLAYER DYES'
--			or s == 'color'
			or string.match(s, "color?.\d*")
			-- Remove opposite realm colors
--			or (GameData.Player.realm == 1 and string.match(s, ".*\(D\)") or string.match(s, ".*\(O\)"))
	end

	

	local realm = GameData.Player.realm	-- 1 = Order, 2 = Destru, 3 = undecided

	--
	-- This could maybe be done better, but currently requires a "fixed" csv column header: data.myp:\data\csv\A853C6CE_A8E69F8E16A61412.csv
	--		Fixed CSV header: ID,Name,Red,Green,Blue,Intensity
	--
	--	BuildTableFromCSV("data\\gamedata\\TintPalette_Equipment.csv", "DyeData")
	--	LoadStringTable("MyTP", "data/gamedata", "TintPalette_Equipment.csv", "cache/<LANG>", "data.MyTP")
	--	BuildTableFromCSV("data\\gamedata\\TintPalette_Equipment.csv", "MyTP")		-- Works, but seem to lack color name and rgb values
	--	LoadStringTable("MyTP", "Interface/Addons/PocketPalette", "PocketPalette.csv", "cache/<LANG>", "StringTables.MyTP")		-- Requireing csv file to be saved as UTF-16
	--	UnloadStringTable("MyTP")

	-- Load dye data from CSV
	if PP.DyeData == nil then PP.DyeData = {} end
	BuildTableFromCSV("Interface/Addons/PocketPalette/PocketPalette.csv", "PP._DyeData")
	-- if (pp_debug) then d(PP._DyeData[1]) end

	-- TODO: Check if GetDyeName compared to loaded list is off, eg. if any dyes are missing
	-- for i = 0,600 do
	--		local dyeName = tostring(GetDyeNameString(i))
	-- end


	-- Also load additional dye data 
	if PP.TintPalette == nil then PP.TintPalette = {} end
	BuildTableFromCSV("data\\gamedata\\TintPalette_Equipment.csv", "PP._TintPalette")
	-- if (pp_debug) then d(PP._TintPalette[1]) end
	for index, data in pairs(PP._DyeData) do

		-- Include only "valid" dyes
		if (not isBadDye(PP._DyeData[index].Name)) then
			if (PP._DyeData[index]) then

				-- Fix realm specific variants
--				PP._DyeData[index].Name = string.gsub(PP._DyeData[index].Name, ' %(.*%)', '')

				PP.DyeData[index] = PP._DyeData[index]
				for k,v in pairs(PP._TintPalette[index]) do PP.DyeData[index][k] = v end
				PP.DyeData[index].Count = 0
			end
		end
	end
	PP._DyeData = nil		-- null tmp table
	PP._TintPalette = nil	-- null tmp table
	-- if (pp_debug) then d(PP.DyeData[1]) end

	PP.UpdateDyeCounts()
end

function PP.UpdateDyeCounts()
	--d("Updating Dye Counts")

	-- Get dye counts from bank and inventory
	local ownedDyes = {};
	local _d = GetInventoryItemData()
	--GetBankData
	-- itemData.type == GameData.ItemTypes.DYE
	for index, data in ipairs(_d) do
		if (data.id ~= 0 and data.type == GameData.ItemTypes.DYE) then
			if (ownedDyes[data.uniqueID]) then
				ownedDyes[data.uniqueID].count = ownedDyes[data.uniqueID].count + data.stackCount
			else
				ownedDyes[data.uniqueID] = { name = tostring(data.name), id = data.uniqueID, count = data.stackCount }
			end
		end
	end
	_d = nil
	_d = GetBankData()
	for index, data in ipairs(_d) do
		if (data.id ~= 0 and data.type == GameData.ItemTypes.DYE) then
			if (ownedDyes[data.uniqueID]) then
				ownedDyes[data.uniqueID].count = ownedDyes[data.uniqueID].count + data.stackCount
			else
				ownedDyes[data.uniqueID] = { name = tostring(data.name), id = data.uniqueID, count = data.stackCount }
			end			
		end
	end
	_d = nil

	if (pp_debug) then ownedDyes["TEST"] = { name = tostring("Chaos Black Dye"), id = 99, count = 999 } end

	for index, data in pairs(PP.DyeData) do
		for _i, _d in pairs(ownedDyes) do
			-- expect string, and not wstring
			-- Should have better way to match up dyes, but this will have to do for now
			if (string.gsub(data.Name, ' %(.*%)', '').." Dye" == _d.name) then
				PP.DyeData[index].Count = _d.count
			end
		end
	end

end

--
--	MainButtons
--
function PP.ShowPaperDoll()
	if (WindowGetShowing("CharacterWindow")) then
		WindowSetShowing("CharacterWindow", false)
	else
		WindowSetShowing("CharacterWindow", true)
	end
end

function PP.ToggleWindow()

	local window = PP.settings.windows["main"].name
	local x, y = WindowGetScreenPosition(window)
	local w, w = WindowGetDimensions(window)

	local anchors = {}
	local anchorCount = WindowGetAnchorCount(window)
	for i=1,anchorCount do
		table.insert( anchors, { WindowGetAnchor(window, i) } )
--		if( anchors[i][1] == point ) then					-- center
----		[2] = relpoint									-- center
----		[3] = relwin									-- Root
--			anchors[i][4] = anchors[i][4] + xOffset			-- 0
--			anchors[i][5] = anchors[i][5] + yOffset			-- 0
--		end
	end

-- InterfaceCore.GetScale()
	local newHeight = 200
	if (PP.settings.windows["main"].minimized) then
		-- Show full window
		WindowSetShowing("DyeWindow", true)
		WindowSetShowing("ItemWindow", true)

		WindowClearAnchors(window)
		local newAY = anchors[1][5] - ((newHeight / 2) - (PP.settings.windows["main"].height / 2))					-- Because or center origin
		WindowAddAnchor(window, anchors[1][1], anchors[1][3], anchors[1][2], anchors[1][4], newAY)
		WindowSetDimensions (window, PP.settings.windows["main"].width, PP.settings.windows["main"].height)
		WindowForceProcessAnchors(window)

		ButtonSetText(window.."TogglePickerBtn", L"Hide")
		PP.settings.windows["main"].minimized = false
	else
		-- Hide partial window
		WindowSetShowing("DyeWindow", false)
		WindowSetShowing("ItemWindow", false)

		WindowClearAnchors(window)
		local newAY = anchors[1][5] - ((PP.settings.windows["main"].height / 2) - (newHeight / 2))		-- Because or center origin
		WindowAddAnchor(window, anchors[1][1], anchors[1][3], anchors[1][2], anchors[1][4], newAY)
		WindowSetDimensions (window, PP.settings.windows["main"].width, newHeight)
		WindowForceProcessAnchors(window)

		ButtonSetText(window.."TogglePickerBtn", L"Show")
		PP.settings.windows["main"].minimized = true
	end
end


--
--	DyeWindow
--
function PP.DyeWindowPopulateDisplay()
	if (not DyeWindowList.PopulatorIndices) then
		if (pp_debug) then d("DyeWindowList: List was empty") end
		return;
	end

	--d("Dye populating")

	for rowIndex, dataIndex in ipairs( DyeWindowList.PopulatorIndices ) 
	do
		local windowId = "DyeWindow"
		local rowName = windowId .. "ListRow" .. rowIndex;
--		WindowSetId(rowName, dataIndex);
		local entry = PP.DyeData[dataIndex];

		WindowSetTintColor(rowName .. "Color", entry.Red, entry.Green, entry.Blue);
		WindowSetAlpha(rowName .. "Color", entry.Intensity);

		LabelSetText(rowName .. "Name", towstring(entry.Name))
		LabelSetText(rowName .. "Count", towstring(entry.Count))
--		LabelSetAlpha(rowName .. "Name", entry.Intensity);

		PP.UpdateListRow(dataIndex, rowName)

	end 

end

	function PP.UpdateListRow(dataIndex, rowName)
		rowName = rowName or nil

	--	if (rowName == nil) then
	--	else
	--	end

		if (dataIndex == PP.selectedDyeIndex) then
			WindowSetTintColor(rowName .. "Background", 200, 200, 200);
			WindowSetAlpha(rowName .. "Background", 0.4);

			WindowSetTintColor("DyeWindowSelectedDyeColor", PP.DyeData[PP.selectedDyeIndex].Red, PP.DyeData[PP.selectedDyeIndex].Green, PP.DyeData[PP.selectedDyeIndex].Blue);
			WindowSetAlpha("DyeWindowSelectedDyeColor", PP.DyeData[PP.selectedDyeIndex].Intensity/2);
			LabelSetText("DyeWindowSelectedDyeName", towstring(PP.DyeData[PP.selectedDyeIndex].Name))
			LabelSetText("DyeWindowSelectedDyeCount", towstring(PP.DyeData[PP.selectedDyeIndex].Count))
		else		
			WindowSetAlpha(rowName .. "Background", 0);
		end

	end

--
--	Update dye window list w. filter & ordering
--
function PP.UpdateDyeList()

	local sortByValue = function(t,key,ot, reversed)
		direction = direction or false
		
		local sorted = {}
		-- create index table with only key value, eg. index:value
		for k, v in pairs(t) do
			table.insert(sorted,{k,v[key]})
		end
		-- sort new table by 2nd param which is value
		if (not reversed) then
			table.sort(sorted, function(a,b) return a[2] < b[2] end)
		else
			table.sort(sorted, function(a,b) return a[2] > b[2] end)
		end
		for index, data in pairs(sorted) do table.insert(ot, data[1]) end
	end

	local function copy(obj, seen)
		if type(obj) ~= 'table' then return obj end
		if seen and seen[obj] then return seen[obj] end
		local s = seen or {}
		local res = setmetatable({}, getmetatable(obj))
		s[obj] = res
		for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
		return res
	end

	-- Deep copy of entire DyeDate object
	--DataUtils.CopyTable(src, dst)
	PP.DyeDataVisible = copy(PP.DyeData)

	if (PP.settings.filter ~= "") then
		for k, v in pairs(PP.DyeDataVisible) do
			if (string.find(string.lower(tostring(v.Name)), PP.settings.filter)) then
--				PP.DyeDataVisible[k] = PP.DyeData[k]
			else
				PP.DyeDataVisible[k] = nil
			end
		end
	end



	local displayOrder = {}

	local switch = {
		-- Default
		[1] = function()
			for index, data in pairs(PP.DyeDataVisible) do table.insert(displayOrder, index) end
		end,
		-- Name
		[2] = function()
			sortByValue(PP.DyeDataVisible, "Name", displayOrder)
		end,
		-- Count
		[3] = function()
			sortByValue(PP.DyeDataVisible, "Count", displayOrder, true)
		end,
		-- Default reversed
		[4] = function()
			for index, data in pairs(PP.DyeDataVisible) do table.insert(displayOrder, 1, index) end
		end,
	}
	local sortMethod = switch[ComboBoxGetSelectedMenuItem("DyeWindowDyeOrderCombo")]
	if (sortMethod) then
		sortMethod()
	else
--		d("Default")
		switch[1]()
	end

	ListBoxSetDisplayOrder("DyeWindowList", displayOrder)
end

function PP.UpdateDyeFilter()
	PP.settings.filter = string.lower(tostring(TextEditBoxGetText("DyeWindowFilterEditBox")))
	PP.UpdateDyeList()
end


function PP.SelectDye()
	local selectedRow = WindowGetId(SystemData.MouseOverWindow.name)
	PP.selectedDyeIndex = ListBoxGetDataIndex("DyeWindowList", selectedRow)

--	PP.DyeWindowPopulateDisplay()
	local windowId = "DyeWindow"	
	for rowIndex, dataIndex in ipairs( DyeWindowList.PopulatorIndices ) do
		local rowName = windowId .. "ListRow" .. rowIndex;
		PP.UpdateListRow(dataIndex, rowName)
	end

end


--
--	ItemWindow
--

function PP.UpdateItemSlots()

	--local equipment = DataUtils.GetEquipmentData()
	local equipment = GetEquipmentData()
	
	local itemWindow = "ItemWindow"
	for i, item in ipairs(PP.settings.items) do
		local iconNum = 0
		if (item.slot ~= 15 and equipment[item.slot].iconNum ~= 0) then
			iconNum = equipment[item.slot].iconNum
		else
			iconNum = CharacterWindow.EquipmentSlotInfo[item.iconNum].iconNum
		end
		local texture, x, y = GetIconData(iconNum)
		DynamicImageSetTexture(itemWindow.."EquipmentSlot"..item.slot.."IconBase", texture, x, y)
--		local texture, x, y = GetIconData(CharacterWindow.EquipmentSlotInfo[item.iconNum].iconNum)
--		DynamicImageSetTexture(itemWindow.."EquipmentSlot"..item.slot.."IconBase", texture, x, y)
		WindowSetTintColor(itemWindow.."EquipmentSlot"..item.slot.."IconPri", PP.settings.items_defaults.primary.r, PP.settings.items_defaults.primary.g, PP.settings.items_defaults.primary.b);
		WindowSetAlpha(itemWindow.."EquipmentSlot"..item.slot.."IconPri", PP.settings.items_defaults.primary.a);
		WindowSetTintColor(itemWindow.."EquipmentSlot"..item.slot.."IconSec", PP.settings.items_defaults.secondary.r, PP.settings.items_defaults.secondary.g, PP.settings.items_defaults.secondary.b);
		WindowSetAlpha(itemWindow.."EquipmentSlot"..item.slot.."IconSec", PP.settings.items_defaults.secondary.a);

	end

	PP.UpdateItemDyes()
end


function PP.UpdateItemDyes()
	-- Render colors
	local window = "ItemWindow"
	for i, item in ipairs(PP.settings.items) do
		local iconCol = window.."EquipmentSlot"..item.slot
		
		if (item.dyes.primary == nil) then
			WindowSetTintColor(iconCol.."IconPri", PP.settings.items_defaults.primary.r, PP.settings.items_defaults.primary.g, PP.settings.items_defaults.primary.b);
			WindowSetAlpha(iconCol.."IconPri", PP.settings.items_defaults.primary.a);
		else
			WindowSetTintColor(iconCol.."IconPri", PP.DyeData[item.dyes.primary].Red, PP.DyeData[item.dyes.primary].Green, PP.DyeData[item.dyes.primary].Blue);
			WindowSetAlpha(iconCol.."IconPri", PP.DyeData[item.dyes.primary].Intensity);
		end

		if (item.dyes.secondary == nil) then
			WindowSetTintColor(iconCol.."IconSec", PP.settings.items_defaults.secondary.r, PP.settings.items_defaults.secondary.g, PP.settings.items_defaults.secondary.b);
			WindowSetAlpha(iconCol.."IconSec", PP.settings.items_defaults.secondary.a);
		else
			WindowSetTintColor(iconCol.."IconSec", PP.DyeData[item.dyes.secondary].Red, PP.DyeData[item.dyes.secondary].Green, PP.DyeData[item.dyes.secondary].Blue);
			WindowSetAlpha(iconCol.."IconSec", PP.DyeData[item.dyes.secondary].Intensity);
		end

	end
end

function PP.ItemSlotMouseOver()
	local slot = WindowGetId(SystemData.ActiveWindow.name)
	--local text = CharacterWindow.EquipmentSlotInfo[slot].name

	local text = PP.toolTips.items[slot]

	-- Add item specific name to tooltip
	local TTCol = Tooltips.COLOR_HEADING
	if (slot == 15 or CharacterWindow.equipmentData[slot].id == 0) then
		TTCol = Tooltips.COLOR_ITEM_DEFAULT_GRAY
	else
		-- Display item name
		text = text .. L" : " .. CharacterWindow.equipmentData[slot].name
		-- Display if the item is able to be dyed
		if (PP.ItemIsDyable(CharacterWindow.equipmentData[slot])) then
--			text = text .. L"\n\n" .. GetString( StringTables.Default.TEXT_DYEABLE_ITEM)
		else
			text = text .. L"\n\n" .. GetString( StringTables.Default.TEXT_CANNOT_DYE_ITEM)
			TTCol = Tooltips.COLOR_FAILS_REQUIREMENTS
		end
	end

	for i, item in ipairs(PP.settings.items) do
		if (item.slot == slot) then

			local dyeColorText = L""
			if( (item.dyes.primary ~= nil) and (item.dyes.secondary ~= nil) ) then
				local dyeAText = GetDyeNameString(item.dyes.primary)
				local dyeBText = GetDyeNameString(item.dyes.secondary)
				dyeColorText = GetStringFormat( StringTables.Default.TEXT_TWO_DYE_COLOR, {dyeAText , dyeBText} )
			elseif ( item.dyes.primary ~= nil ) then
				local dyeTintAText = GetDyeNameString(item.dyes.primary)
				dyeColorText = GetStringFormat( StringTables.Default.TEXT_ONE_DYE_COLOR, {dyeTintAText} )
			elseif ( item.dyes.secondary ~= nil ) then
				local dyeTintBText = GetDyeNameString(item.dyes.secondary)
				dyeColorText = GetStringFormat( StringTables.Default.TEXT_ONE_DYE_COLOR, {dyeTintBText} )
			end
			text = text..L"\n\n"..dyeColorText
		end
	end
	
	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, text)
	-- ANCHOR_CURSOR, ANCHOR_WINDOW_RIGHT
	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)

	---
	--	COLOR_ITEM_DEFAULT_GRAY = { r = 150, g = 150, b = 150 }
	--	COLOR_FAILS_REQUIREMENTS
	--	COLOR_WARNING 
	--	COLOR_ACTION 
	-- 
	--	Tooltips.SetTooltipText (1, 1, GetGuildString( StringTables.Guild.TOOLTIP_CALENDAR_NEW_EVENT_BUTTON) )
	Tooltips.SetTooltipColorDef (1, 1, TTCol)

	Tooltips.Finalize();

--	Tooltips.CreateTextOnlyTooltip(windowName, nil);
--	Tooltips.SetTooltipText( 1, 1, L"CharacterWindow.EquipmentSlotInfo[slot].name" )
--	Tooltips.SetTooltipColor( 1, 1, 123, 172, 220 )
--	Tooltips.Finalize();
--	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )

end


function PP.ItemSlotLMouse()
	PP.SetItemDye(true)
end
function PP.ItemSlotRMouse()
	PP.SetItemDye(false)
end
function PP.SetItemDye(primary)
	local slot = WindowGetId(SystemData.ActiveWindow.name)
--	local text = CharacterWindow.EquipmentSlotInfo[slot].name

	local prisec = (primary and 'primary' or 'secondary')		-- lua instead of ternary operators : 	(x < 0 and 'negative' or 'non-negative')

	-- Why are we iterating these, we know the slot number - TODO: Refactor
	for i, item in ipairs(PP.settings.items) do
		if (slot == item.slot) then
			if (PP.settings.items[i].dyes[prisec] == nil or PP.settings.items[i].dyes[prisec] ~= PP.selectedDyeIndex) then
				PP.settings.items[i].dyes[prisec] = PP.selectedDyeIndex
			else
				PP.settings.items[i].dyes[prisec] = nil
			end
		end
	end
	PP.UpdateItemDyes()

	PP.ItemSlotMouseOver()

	PP.PreviewDyes()
end


function PP.ResetPreviewDyes()
	if (PP.settings.persistent == false) then
		RevertAllDyePreview()
	end
end

function PP.PreviewDyes()

	PP.ResetPreviewDyes()

	-- All items
	-- 		DyeMerchantPreviewAll(pri, sec)
	local priAll = 0
	local secAll = 0
	for i, item in ipairs(PP.settings.items) do

		if (item.slot == 15) then
			priAll = (item.dyes.primary ~= nil and item.dyes.primary or priAll)
			secAll = (item.dyes.secondary ~= nil and item.dyes.secondary or secAll)
		end

	end

	for i, item in ipairs(PP.settings.items) do
		--
		--	DyeMerchantPreview(GameData.ItemLocs.EQUIPPED, itemSlot, primaryColorIndex, secondaryColorIndex)
		--
		local pri = 0
		local sec = 0
		if (item.slot ~= 15) then
			-- Not entirely sure this is correct, what about already applied dyes?
			local pri = (priAll ~= 0 and priAll or CharacterWindow.equipmentData[item.slot].dyeTintA)
			local sec = (secAll ~= 0 and secAll or CharacterWindow.equipmentData[item.slot].dyeTintB)

			if (item.dyes.primary ~= nil) then
				pri = item.dyes.primary
			end
			if (item.dyes.secondary ~= nil) then
				sec = item.dyes.secondary
			end

			DyeMerchantPreview(GameData.ItemLocs.EQUIPPED, item.slot, pri, sec)
		end

	end
end


function PP.ItemIsDyable(itemData)
    local tintMasks = GetDyeTintMasks( itemData.id )
    return( itemData.flags[GameData.Item.EITEMFLAG_DYE_ABLE] == true and tintMasks ~= GameData.TintMasks.NONE and not itemData.broken )
end
function PP.ItemIsBleachable(itemData)
    return( UseItemTargeting.ItemIsDyable(itemData) and
            ( itemData.dyeTintA ~= 0 or itemData.dyeTintB ~= 0 ) )
end