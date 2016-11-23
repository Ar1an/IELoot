local lootWhisper = CreateFrame('Frame')
local addonLoadedFrame = CreateFrame('Frame')
local loot = {'end'}
local _frame
local _label


SLASH_IELootCommand1 = '/ieloot'


--[[local function LootReceivedEvent(self, event, ...)
	local message, _, _, _, looter = ...
	
	local _, _, lootedItem = string.find(message, '(|.+|r)')
	
	print('GZ' .. looter .. '. ' .. lootedItem)
end]]



local function post()
	if loot[#loot] == 'end' then
		print('End of List')
	else
		if UnitInRaid('player') then
			SendChatMessage(loot[#loot],'raid',nil, nil)
			table.remove(loot,#loot)
		else
			print('You are not in a raidgroup.')
		end
	end
end


local function lootWhisperEvent(self, event, ...)
	local arg1, arg2 = ...
	local t = {strsplit("-", arg2)}
	arg2 = t[1]
	local arg3 = arg1 .. ' - ' .. arg2
	table.insert(loot,arg3)
	print(arg1 .. ' added to the list.')
end



local function disable()
	lootWhisper:UnregisterAllEvents()
end

local function erase()
	table.remove(loot,#loot)
end

local function showUi()
	local frame = CreateFrame('Frame', 'MyFrame', UIParent)
	frame:SetFrameStrata('HIGH')
	frame:Hide()
	frame:SetSize(310,35)
	frame:SetPoint('TOPLEFT')
	frame:SetBackdrop({bgFile = 'Interface/Tooltips/UI-Tooltip-Background', edgeFile = 'Interface/Tooltips/UI-Tooltip-Border', tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, bottom = 4 }})
	frame:SetBackdropColor(0,0,0,1)
	frame:EnableMouse(true)


	local hideButton = CreateFrame('Button', 'Text for hideButton', frame, 'UIPanelButtonTemplate')
	hideButton:SetPoint('BOTTOMLEFT', 250, 5)
	hideButton:SetWidth(50)
	hideButton:SetHeight(25)
	hideButton:SetText('Hide')
	hideButton:SetScript('OnClick', hideButtonOnClick)
	
	local resetButton = CreateFrame('Button', 'Text for resetButton', frame, 'UIPanelButtonTemplate')
	resetButton:SetPoint('BOTTOMLEFT', 190, 5)
	resetButton:SetWidth(50)
	resetButton:SetHeight(25)
	resetButton:SetText('Reset')
	resetButton:SetScript('OnClick', resetButtonOnClick)
	
	local postButton = CreateFrame('Button', 'Text for postButton', frame, 'UIPanelButtonTemplate')
	postButton:SetPoint('BOTTOMLEFT', 70 , 5)
	postButton:SetWidth(50)
	postButton:SetHeight(25)
	postButton:SetText('Post')
	postButton:SetScript('OnClick', postButtonOnClick)
	
	local eraseButton = CreateFrame('Button', 'Text for eraseButton', frame, 'UIPanelButtonTemplate')
	eraseButton:SetPoint('BOTTOMLEFT', 130, 5)
	eraseButton:SetWidth(50)
	eraseButton:SetHeight(25)
	eraseButton:SetText('Erase')
	eraseButton:SetScript('OnClick', eraseButtonOnClick)
	
	local showButton = CreateFrame('Button', 'Text for showButton', frame, 'UIPanelButtonTemplate')
	showButton:SetPoint('BOTTOMLEFT', 10, 5)
	showButton:SetWidth(50)
	showButton:SetHeight(25)
	showButton:SetText('Show')
	showButton:SetScript('OnClick', showButtonOnClick)
	
	minmapicon_create()
	
	return frame
end

function hideButtonOnClick(self, button, ...)
	_frame:Hide()
	disable()
end

function postButtonOnClick(self, button, ...)
	post()
end

function eraseButtonOnClick(self, button, ...)
	erase()
end

function showButtonOnClick(self, button, ...)
	local counter = #loot
	print('Total Items: ' .. counter-1)
	while counter>1 do
		print(counter .. ': ' .. loot[counter])
		counter = counter-1
	end
	
end

function resetButtonOnClick(self, button, ...)
	wipe(loot)
	loot[1]= 'end'
end

local function enable()
	lootWhisper:RegisterEvent('CHAT_MSG_WHISPER')
	lootWhisper:SetScript('OnEvent', lootWhisperEvent)
	_frame:Show()
end

	
function SlashCmdList.IELootCommand(msg, editbox)
	if msg == 'enable' then
		enable()
	else 
		print('Unknown Command')
	end
end


local function Initialize(self, event, addonName, ...)
	if addonName == 'IELoot' then
		print('IELoot loaded')
	end
	local frame = showUi()
	_frame = frame
end

function minmapicon_create()
	local mmicon = CreateFrame('Button', 'ltdm.addon.minimapicon', Minimap)
	mmicon:SetFrameStrata('MEDIUM')
	mmicon:ClearAllPoints()
	mmicon:SetPoint('CENTER', Minimap, 'CENTER', -76, -22)
	mmicon:SetSize(31, 31)
	mmicon:SetFrameLevel(8)
	mmicon:SetHighlightTexture(136477)
	mmicon:RegisterForDrag('LeftButton')
	

	--[[overlay = mmicon:CreateTexture(nil, 'OVERLAY')
	overlay:SetSize(53, 53)
	overlay:SetTexture(136430)
	overlay:SetPoint('TOPLEFT')

	mmicon.bg = mmicon:CreateTexture(nil, 'BACKGROUND')
	mmicon.bg:SetSize(20, 20)
	mmicon.bg:SetTexture(136467)
	mmicon.bg:SetPoint('TOPLEFT', 7, -5)]]

	mmicon.icon = mmicon:CreateTexture(nil, 'ARTWORK')
	mmicon.icon:SetTexture('Interface\\AddOns\\IELoot\\media\\icon.tga')
	mmicon.icon:SetSize(17,17)
	mmicon.icon:SetPoint('TOPLEFT',7,-6)

	mmicon:RegisterForClicks('anyUp')

	mmicon:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
		GameTooltip:AddLine('IELoot')
		GameTooltip:AddLine('Click to show Frame.')
		GameTooltip:Show()
		end)
	mmicon:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)
	mmicon:SetScript('OnClick', function()
		enable()

	end)
end

addonLoadedFrame:RegisterEvent('ADDON_LOADED')
addonLoadedFrame:SetScript('OnEvent', Initialize)
