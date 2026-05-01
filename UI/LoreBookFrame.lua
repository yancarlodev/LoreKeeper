SLASH_LOREBOOK1 = "/lb"
SLASH_LOREBOOK2 = "/lorebook"
SlashCmdList['LOREBOOK'] = function(_)
    LoreBookFrame:Show()
end

MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);
BOOKTYPE_SPELL = "spell";
SPELLBOOK_PAGENUMBERS = {};
 
function ToggleLoreBook(bookType)
  local isVisible = LoreBookFrame:IsVisible();
  HideUIPanel(LoreBookFrame);
  if ( (not isVisible or (LoreBookFrame.bookType ~= bookType)) ) then
    LoreBookFrame.bookType = bookType;
    ShowUIPanel(LoreBookFrame);
  end
  local currentPage, maxPages = SpellBook_GetCurrentPage();
  if ( currentPage > maxPages ) then
    SPELLBOOK_PAGENUMBERS[LoreBookFrame.selectedSkillLine] = maxPages;
    currentPage = maxPages;
    UpdateSpells();
  end
  SpellBook_UpdatePageArrows()
  LoreBookPageText:SetText(format(TEXT(PAGE_NUMBER), currentPage));
end
 
function LoreBookFrame_OnLoad()
  this:RegisterEvent("SPELLS_CHANGED");
 
  LoreBookFrame.bookType = BOOKTYPE_SPELL;
  -- Init page nums
  SPELLBOOK_PAGENUMBERS[1] = 1;
  
  -- Set to the first tab by default
  SpellBookSkillLineTab_OnClick(1);
 
  -- Initialize tab flashing
  LoreBookFrame.flashTabs = nil;
end
 
function LoreBookFrame_OnEvent()
  if ( event == "SPELLS_CHANGED" ) then
    if ( LoreBookFrame:IsVisible() ) then
      SpellBookFrame_Update();
      SpellBook_UpdatePageArrows();
    end
  end
end
 
function LoreBookFrame_OnShow()
  UpdateMicroButtons();
  SpellBookFrame_Update(1);
end
 
function SpellBookFrame_Update(showing)
  -- Setup skillline tabs
  if ( showing ) then
    SpellBookSkillLineTab_OnClick(LoreBookFrame.selectedSkillLine);
    UpdateSpells();
  end

  if ( showing ) then
    PlaySound("igSpellBookOpen");
  end
end
 
function LoreBookFrame_OnHide()
  PlaySound("igSpellBookClose");

  UpdateMicroButtons();
end
 
function SpellButton_OnLoad() 
  this:RegisterEvent("SPELLS_CHANGED");
  this:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
  this:RegisterEvent("SPELL_UPDATE_COOLDOWN");
  this:RegisterEvent("CRAFT_SHOW");
  this:RegisterEvent("CRAFT_CLOSE");
  this:RegisterEvent("TRADE_SKILL_SHOW");
  this:RegisterEvent("TRADE_SKILL_CLOSE");
  this:RegisterForDrag("LeftButton");
  this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
  SpellButton_UpdateButton();
end
 
function SpellButton_OnEvent(event) 
  if ( event == "SPELLS_CHANGED" or event == "SPELL_UPDATE_COOLDOWN" ) then 
    SpellButton_UpdateButton();
  elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
    SpellButton_UpdateSelection();
  elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
    SpellButton_UpdateSelection();
  end
 
end
 
function SpellButton_OnEnter()
  local id = SpellBook_GetSpellID(this:GetID());
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
  if ( GameTooltip:SetSpell(id, LoreBookFrame.bookType) ) then
    this.updateTooltip = TOOLTIP_UPDATE_TIME;
  else
    this.updateTooltip = nil;
  end
end
 
function SpellButton_OnUpdate(elapsed)
  if ( not this.updateTooltip ) then
    return;
  end
 
  this.updateTooltip = this.updateTooltip - elapsed;
  if ( this.updateTooltip > 0 ) then
    return;
  end
 
  if ( GameTooltip:IsOwned(this) ) then
    SpellButton_OnEnter();
  else
    this.updateTooltip = nil;
  end
end
 
function SpellButton_OnClick(drag) 
  local id = SpellBook_GetSpellID(this:GetID());
  if ( id > MAX_SPELLS ) then
    return;
  end
  this:SetChecked("false");
  if ( drag ) then
    PickupSpell(id, LoreBookFrame.bookType);
  elseif ( IsShiftKeyDown() ) then
    if ( MacroFrame and MacroFrame:IsVisible() ) then
      local spellName, subSpellName = GetSpellName(id, LoreBookFrame.bookType);
      if ( spellName and not IsSpellPassive(id, LoreBookFrame.bookType) ) then
        if ( subSpellName and (strlen(subSpellName) > 0) ) then
          MacroFrame_AddMacroLine(TEXT(SLASH_CAST1).." "..spellName.."("..subSpellName..")");
        else
          MacroFrame_AddMacroLine(TEXT(SLASH_CAST1).." "..spellName);
        end
      end
    else
      PickupSpell(id, LoreBookFrame.bookType );
    end
  else
    CastSpell(id, LoreBookFrame.bookType);
    SpellButton_UpdateSelection();
  end
end
 
function SpellButton_UpdateSelection()
  local _, _, offset, numSpells = GetSpellTabInfo(LoreBookFrame.selectedSkillLine);
  local id = SpellBook_GetSpellID(this:GetID());
  if ( (id > (offset + numSpells)) ) then
    this:SetChecked("false");
    return;
  end
 
  if ( IsCurrentCast(id,  LoreBookFrame.bookType) ) then
    this:SetChecked("true");
  else
    this:SetChecked("false");
  end
end
 
function LoreButton_UpdateButton()
  if ( not this:IsVisible() ) then
    return;
  end
  if ( GameTooltip:IsOwned(this) ) then
    SpellButton_OnEnter();
  end
 
  if ( not LoreBookFrame.selectedSkillLine ) then
    LoreBookFrame.selectedSkillLine = 1;
  end
  local _, _, offset, numSpells = GetSpellTabInfo(LoreBookFrame.selectedSkillLine);
  LoreBookFrame.selectedSkillLineOffset = offset;
  local id = SpellBook_GetSpellID(this:GetID());
  local name = this:GetName();
  local iconTexture = getglobal(name.."IconTexture");
  local spellString = getglobal(name.."SpellName");
  local subSpellString = getglobal(name.."SubSpellName");
  if ( (id > (offset + numSpells)) ) then
    this:Disable();
    iconTexture:Hide();
    spellString:Hide();
    subSpellString:Hide();
    this:SetChecked(0);
    getglobal(name.."NormalTexture"):SetVertexColor(1.0, 1.0, 1.0);
    return;
  else
    this:Enable();
  end
  local texture = GetSpellTexture(id, LoreBookFrame.bookType);
  local highlightTexture = getglobal(name.."Highlight");
  local normalTexture = getglobal(name.."NormalTexture");
  -- If no spell, hide everything and return
  if ( not texture or (strlen(texture) == 0) ) then
    iconTexture:Hide();
    spellString:Hide();
    subSpellString:Hide();
    highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
    this:SetChecked(0);
    normalTexture:SetVertexColor(1.0, 1.0, 1.0);
    return;
  end
 
  local spellName, subSpellName = GetSpellName(id, LoreBookFrame.bookType);

  normalTexture:SetVertexColor(1.0, 1.0, 1.0);
  highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
  spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

  iconTexture:SetTexture(texture);
  spellString:SetText(spellName);
  subSpellString:SetText(subSpellName);
  if ( subSpellName ~= "" ) then
    spellString:SetPoint("LEFT", this, "RIGHT", 4, 4);
  else
    spellString:SetPoint("LEFT", this, "RIGHT", 4, 2);
  end
 
  iconTexture:Show();
  spellString:Show();
  subSpellString:Show();
  SpellButton_UpdateSelection();
end
 
function PrevPageButton_OnClick()
  local pageNum = SpellBook_GetCurrentPage() - 1;
  SPELLBOOK_PAGENUMBERS[LoreBookFrame.selectedSkillLine] = pageNum;
  SpellBook_UpdatePageArrows();
  LoreBookPageText:SetText(format(TEXT(PAGE_NUMBER), pageNum));
  UpdateSpells();

  PlaySound("igAbiliityPageTurn");
end
 
function NextPageButton_OnClick()
  local pageNum = SpellBook_GetCurrentPage() + 1;
  SPELLBOOK_PAGENUMBERS[LoreBookFrame.selectedSkillLine] = pageNum;
  SpellBook_UpdatePageArrows();
  LoreBookPageText:SetText(format(TEXT(PAGE_NUMBER), pageNum));
  UpdateSpells();

  PlaySound("igAbiliityPageTurn");
end
 
function SpellBookSkillLineTab_OnClick(id)
  local update;
  if ( not id ) then
    update = 1;
    id = this:GetID();
  end
  LoreBookFrame.selectedSkillLine = id;
  local _, _, offset, numSpells = GetSpellTabInfo(LoreBookFrame.selectedSkillLine);
  LoreBookFrame.selectedSkillLineOffset = offset;
  LoreBookFrame.selectedSkillLineNumSpells = numSpells;
  SpellBook_UpdatePageArrows();
  SpellBookFrame_Update();
  LoreBookPageText:SetText(format(TEXT(PAGE_NUMBER), SpellBook_GetCurrentPage()));
  if ( update ) then
    UpdateSpells();
  end
  -- Stop tab flashing
  local tabFlash = getglobal(this:GetName().."Flash");
  if ( tabFlash ) then
    tabFlash:Hide();
  end
end
 
function SpellBook_GetSpellID(id)
  return id + LoreBookFrame.selectedSkillLineOffset + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[LoreBookFrame.selectedSkillLine] - 1));
end
 
function SpellBook_UpdatePageArrows()
  local currentPage, maxPages = SpellBook_GetCurrentPage();

  if ( currentPage > maxPages ) then
    currentPage = maxPages;
  end

  if ( currentPage== 1 ) then
    LoreBookPrevPageButton:Disable();
  else
    LoreBookPrevPageButton:Enable();
  end
  if ( currentPage == maxPages ) then
    LoreBookNextPageButton:Disable();
  else
    LoreBookNextPageButton:Enable();
  end
end
 
function SpellBook_GetCurrentPage()
  local currentPage, maxPages;

  currentPage = SPELLBOOK_PAGENUMBERS[LoreBookFrame.selectedSkillLine];
  local _, _, _, numSpells = GetSpellTabInfo(LoreBookFrame.selectedSkillLine);
  maxPages = ceil(numSpells/SPELLS_PER_PAGE);

  return currentPage, maxPages;
end