local IELoot = {}
IELoot.frame = CreateFrame('Frame')
IELoot.loot = {}
IELoot.debug = nil

SLitmCountd1 = '/ieloot'


function IELoot.createUi()
  local frame = CreateFrame('Frame', 'ieloot.uipanel', UIParent)
	frame:SetFrameStrata('HIGH')
	frame:Hide()
	frame:SetSize(370,37)
	frame:SetPoint('TOPLEFT')
	frame:SetBackdrop({bgFile = 'Interface/Tooltips/UI-Tooltip-Background', edgeFile = 'Interface/Tooltips/UI-Tooltip-Border', tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, bottom = 4 }})
	frame:SetBackdropColor(0,0,0,1)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag('LeftButton')
	frame:SetScript('OnDragStart', function() frame:StartMoving() end)
	-- TODO: save position after moving the frame
	frame:SetScript('OnDragStop', function() frame:StopMovingOrSizing() end)
	
--	local titleRegion = frame:CreateTitleRegion()
--	titleRegion:SetSize(30, 30)
--	titleRegion:SetPoint('BOTTOMRIGHT')
--	
--	local titleRegionTexture = frame:CreateTexture('ieloot.titleRegionTexture', 'ARTWORK')
--	titleRegionTexture:SetSize(30, 30)
--	titleRegionTexture:SetPoint('BOTTOMRIGHT')
--	titleRegionTexture:SetColorTexture( .3, .3 , .3, .5)
	
	local listButton = CreateFrame('Button', 'ieloot.listButton', frame, 'UIPanelButtonTemplate')
  listButton:SetPoint('BOTTOMLEFT', 10, 5)
  listButton:SetWidth(50)
  listButton:SetHeight(25)
  listButton:SetText('List')
  listButton:SetScript('OnClick', function() IELoot.listItems() end)
	
	local postButton = CreateFrame('Button', 'ieloot.postButton', frame, 'UIPanelButtonTemplate')
	postButton:SetPoint('BOTTOMLEFT', 70 , 5)
	postButton:SetWidth(50)
	postButton:SetHeight(25)
	postButton:SetText('Post')
	postButton:SetScript('OnClick', function() IELoot.post() end)
	
	local deleteButton = CreateFrame('Button', 'ieloot.deleteButton', frame, 'UIPanelButtonTemplate')
	deleteButton:SetPoint('BOTTOMLEFT', 130, 5)
	deleteButton:SetWidth(50)
	deleteButton:SetHeight(25)
	deleteButton:SetText('Delete')
	deleteButton:SetScript('OnClick', function() IELoot.delete() end)

  local resetButton = CreateFrame('Button', 'ieloot.resetButton', frame, 'UIPanelButtonTemplate')
  resetButton:SetPoint('BOTTOMLEFT', 190, 5)
  resetButton:SetWidth(50)
  resetButton:SetHeight(25)
  resetButton:SetText('Reset')
  resetButton:SetScript('OnClick', function() IELoot.resetItems() end)

  local toggleButton = CreateFrame('Button', 'ieloot.toggleButton', frame, 'UIPanelButtonTemplate')
  toggleButton:SetPoint('BOTTOMLEFT', 250, 5)
  toggleButton:SetWidth(50)
  toggleButton:SetHeight(25)
  toggleButton:SetText('Enable')
  toggleButton:SetScript('OnClick', IELoot.onClickToggleButton)
  
  local hideButton = CreateFrame('Button', 'ieloot.hideButton', frame, 'UIPanelButtonTemplate')
  hideButton:SetPoint('BOTTOMLEFT', 310, 5)
  hideButton:SetWidth(52)
  hideButton:SetHeight(25)
  hideButton:SetText('Hide')
  hideButton:SetScript('OnClick', function() IELoot.toggleGui() end)

	IELoot.guiFrame = frame
	IELoot.titleRegion = titleRegion
end


function IELoot.createMiniMapButton()
  local mmicon = CreateFrame('Button', 'ieloot.minimapbutton', Minimap)
  mmicon:SetFrameStrata('MEDIUM')
  mmicon:ClearAllPoints()
  mmicon:SetPoint('CENTER', Minimap, 'CENTER', -76, -22)
  mmicon:SetSize(31, 31)
  mmicon:SetFrameLevel(8)
  mmicon:SetHighlightTexture(136477)
  mmicon:RegisterForDrag('LeftButton')
  
  mmicon.overlay = mmicon:CreateTexture(nil, 'OVERLAY')
  mmicon.overlay:SetSize(53, 53)
  mmicon.overlay:SetTexture(136430)
  mmicon.overlay:SetPoint('TOPLEFT')

  --mmicon.bg = mmicon:CreateTexture(nil, 'BACKGROUND')
  --mmicon.bg:SetSize(40, 40)
  --mmicon.bg:SetTexture(136467)
  --mmicon.bg:SetTexture(1, 1, 1)
  --mmicon.bg:SetPoint('TOPLEFT')

  mmicon.icon = mmicon:CreateTexture(nil, 'ARTWORK')
  mmicon.icon:SetTexture('Interface\\AddOns\\IELoot\\media\\icon.tga')
  mmicon.icon:SetSize(17,17)
  mmicon.icon:SetPoint('TOPLEFT',7,-6)

  mmicon:RegisterForClicks('anyUp')

  mmicon:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
    GameTooltip:AddLine('IELoot')
    GameTooltip:AddLine('Click to show UI.')
    GameTooltip:Show()
    end)
  mmicon:SetScript('OnLeave', function(self)
    GameTooltip:Hide()
  end)
  mmicon:SetScript('OnClick', function()
    IELoot.toggleGui()
  end)
end


function IELoot.toggleGui()
  if IELoot.guiFrame:IsVisible() then
  	IELoot.guiFrame:Hide()
	else
    IELoot.guiFrame:Show()
  end
end


function IELoot.enable()
  if IELoot.active then return end
  IELoot.frame:RegisterEvent('CHAT_MSG_WHISPER')
  IELoot.active = true
  print('IELoot enabled.')
end


function IELoot.disable()
  IELoot.frame:UnregisterEvent('CHAT_MSG_WHISPER')
  IELoot.active = nil
  print('IELoot disabled.')
end


function IELoot.onClickToggleButton(this)
  if IELoot.active then
    IELoot.disable()
    this:SetText('Enable')
  else
    IELoot.enable()
    this:SetText('Disable')
  end
end


function IELoot.post()
  local itmCount = #IELoot.loot
  if not itmCount or itmCount < 1 then
    print('Nothing to post!')
  else
    if UnitInRaid('player') then
      SendChatMessage(IELoot.loot[1], 'raid', nil, nil)
      table.remove(IELoot.loot, 1)
    else
      print('You are not in a raidgroup.')
      if not IELoot.debug then return end
      print(IELoot.loot[1])
      table.remove(IELoot.loot, 1)
    end
  end
end


function IELoot.delete()
  local itmCount = #IELoot.loot
  if itmCount > 0 then
    print('Deleting ' .. IELoot.loot[itmCount])
    table.remove(IELoot.loot,itmCount)
  else
    print('List is empty!')
   end
end


function IELoot.resetItems()
  wipe(IELoot.loot)
  print('Items have been reset.')
end


function IELoot.listItems()
  local itmCount = #IELoot.loot
  print('Total Items: ' .. itmCount)
  local i = 1
  while i <= itmCount do
    print('#' .. i .. ': ' .. IELoot.loot[i])
    i = i + 1
  end
end


--[[local function LootReceivedEvent(self, event, ...)
  local message, _, _, _, looter = ...
  
  local _, _, lootedItem = string.find(message, '(|.+|r)')
  
  print('GZ' .. looter .. '. ' .. lootedItem)
end]]


function IELoot.onEvent(self, event, ...)
  if event == 'CHAT_MSG_WHISPER' then
    --tprint(table.pack(...))
    local msg, playerFull,_ ,_ , player = ...
    if not player then
      local split = {strsplit("-", playerFull)}
      player = split[1]
    end
    local lootString = msg .. ' - ' .. player
    table.insert(IELoot.loot, lootString)
    print(msg .. ' added to the list.')
  elseif event == 'ADDON_LOADED' then
    local addonName = ...
    print(...)
    if addonName == 'IELoot' then
      print('IELoot loaded')
      IELoot.createUi()
      IELoot.createMiniMapButton()
      IELoot.frame:UnregisterEvent('ADDON_LOADED')
    end
  end
end


function SlashCmdList.IELootCommand(msg, editbox)
  if msg == 'enable' then
    IELoot.toggleGui()
    IELoot.enable()
  else 
    print('Unknown Command')
  end
end


IELoot.frame:RegisterEvent('ADDON_LOADED')
IELoot.frame:SetScript('OnEvent', IELoot.onEvent)


-- print contents of tbl with (initial) indentation
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))    
    else
      print(formatting .. v)
    end
  end
end

-- packs vararg into table
function table.pack(...)
  return { n = select("#", ...), ... }
end