LubosPBSaved = {};

turn = 0;

local opt_frm;
local main_edb;
local opt_frm_fs_script;

local chosen_script;
local loaded = false;

local DEFAULT_CODE = "--You can write your script here.";
PLAYER = 1;
ENEMY = 2;

weather = {};	
weather_count = 0;

buffs = {};
buffs_count = 0;

my_abilities = {};
enemy_abilities = {};

buff_index = 0;

function LubosPBMainFunction()
	if C_PetBattles.IsInBattle() and (C_PetBattles.IsSkipAvailable() or  C_PetBattles.GetHealth(PLAYER, GetActivePet(PLAYER)) == 0) then	
	--if we are in pet battle and if it's our time to move or if the current pet is dead, so we can switch it
		GetCurrentAbilityState();	--populate my_abilities and enemy_abilities with Ability States (0]isUsable, [1]currentCooldown, [2]currentLockdown)
		GetCurrentPetBuffs();	--populate buffs and set buffs_count with buffs present on player's pet ([0]auraID, [1]timeRemaining)
		GetWeather();			--populate weather and weather_count with weather effects, there should only be one weather effect at a time, but w/e
		--We got all info we need to make educated decision
		--here we should unload user script
		--[[
		if GetActivePet(PLAYER) == 1 then
			if GetPetCurrentHP(PLAYER, 1) == 0 then
				ChangeToPet(2);
				MyMod();
			elseif GetActivePet(ENEMY) == 1 or GetActivePet(ENEMY) == 2 then
				if turn == 0 then
					UseAbility(1);
				elseif turn == 1 then
					UseAbility(2);
				elseif BuffExists(823, buffs, buffs_count) then			
					if buffs[buff_index][1] == 1 then
						UseAbility(2);
					else
						UseAbility(1);
					end
				else 
					print("Error: xd");
				end
			elseif GetActivePet(ENEMY) == 3 then
				if BuffExists(823, buffs, buffs_count) then			
					if buffs[buff_index][1] == 1 then
						UseAbility(2);
					elseif buffs[buff_index][1] >= 4 and GetPetCurrentHP(PLAYER, 1) < 1300 then
						UseAbility(3);
					else
						UseAbility(1);
					end
				end
			end
		elseif GetActivePet(PLAYER) == 2 then
			if GetPetCurrentHP(PLAYER, 2) == 0 then
				ChangeToPet(3);
			elseif GetActivePet(ENEMY) == 2 then
				UseAbility(1);
			elseif GetActivePet(ENEMY) == 3 then
				if turn == 0 then
					UseAbility(1);
				elseif turn == 1 then
					UseAbility(2);
				elseif turn == 2 then
					UseAbility(3);
				end
			end
		elseif GetActivePet(PLAYER) == 3 then
			UseAbility(3);
			UseAbility(1);
		end		--]]
		ExecuteFromString(chosen_script);
	end	
end 



function BuffExists(key, t, max_index)
	 for i = 1,max_index do 
		if t[i][0] == key then
			buff_index = i;
			return true;
		end
	 end
	 return false;
end

function GetCurrentPetBuffs()
	local active_pet = C_PetBattles.GetActivePet(PLAYER);
	buffs_count = C_PetBattles.GetNumAuras(PLAYER, active_pet);
	GetAuras(PLAYER,active_pet,buffs, buffs_count);
end

function GetWeather()
	weather_count = C_PetBattles.GetNumAuras(0, 0);
	GetAuras(0,0,weather, weather_count);
end

function GetAuras(playerIndex, petIndex, auras, num_of_effects)
	for i = 1, num_of_effects do 
		local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(1, petIndex, i);
		auras[i] = {};
		auras[i][0] = auraID;
		auras[i][1] = turnsRemaining;
	end
end

function GetPetCurrentHP(owner, petIndex)
	return C_PetBattles.GetHealth(owner, petIndex);
end

function GetPetMaxHP(owner, petIndex)
	return C_PetBattles.GetMaxHealth(owner, petIndex);
end

function GetCurrentAbilityState()
	for i = 1,3 do 
		my_abilities[0], my_abilities[1], my_abilities[2] = C_PetBattles.GetAbilityState(1, C_PetBattles.GetActivePet(PLAYER), i); --[0]isUsable, [1]currentCooldown, [2]currentLockdown
		enemy_abilities[0], enemy_abilities[1], enemy_abilities[2] = C_PetBattles.GetAbilityState(2, C_PetBattles.GetActivePet(ENEMY), i); --[0]isUsable, [1]currentCooldown, [2]currentLockdown
	end
end

function GetActivePet(person)
	return C_PetBattles.GetActivePet(person);
end

function UseAbility(index)
	C_PetBattles.UseAbility(index);
end

function ChangeToPet(index)
	C_PetBattles.ChangePet(index);
end

function Start()
	turn = -1;
end

function ActionPerformed()
	turn = turn + 1;
end

function PetChanged(self, event, ...)
	if select(1, ...) == 2 then
		turn = 0;
	end
end

function CreateGUI(msg, editbox)
	if not loaded then
		InitMyGUI();
		loaded = true;
	end
		opt_frm:Show();
end



function InitMyGUI()
	opt_frm = CreateFrame("Frame","OptFrame",UIParent,"BasicFrameTemplate");
		opt_frm:SetWidth(800);
		opt_frm:SetHeight(600);
		opt_frm:SetPoint("CENTER",0,0);
	local opt_frm_fs_name = opt_frm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		opt_frm_fs_name:SetPoint("TOP",0,-5);
		opt_frm_fs_name:SetText("Pet Battle Script settings");
	local opt_frm_fs_options = opt_frm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		opt_frm_fs_options:SetPoint("TOPLEFT",5,-25);
		opt_frm_fs_options:SetText("Select script");
	opt_frm_fs_script = opt_frm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		opt_frm_fs_script:SetPoint("BOTTOM",0,20);

	-- Movable
	opt_frm:SetMovable(true)
	opt_frm:SetClampedToScreen(true)
	opt_frm:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			self:StartMoving()
		end
	end)
	opt_frm:SetScript("OnMouseUp", opt_frm.StopMovingOrSizing)

	local edb_sf = CreateFrame("ScrollFrame", "EDB_SF", OptFrame, "UIPanelScrollFrameTemplate")
		edb_sf:SetPoint("LEFT", 150, 0)
		edb_sf:SetPoint("RIGHT", -30, 0)
		edb_sf:SetPoint("TOP", 0, -30)
		edb_sf:SetPoint("BOTTOM", 0, 50)
		edb_sf:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        })

	main_edb = CreateFrame("EditBox", "MainEDB", OptFrame);
		main_edb:SetSize(edb_sf:GetSize());
		main_edb:SetMultiLine(true);
		main_edb:SetAutoFocus(false) -- dont automatically focus
		main_edb:SetFontObject("ChatFontNormal")
		main_edb:SetScript("OnEscapePressed", CloseOpt_frame)
		edb_sf:SetScrollChild(main_edb);
		main_edb:SetText(DEFAULT_CODE);

	local apply_btn = CreateFrame("Button","ApplyBTN",OptFrame,"UIPanelButtonTemplate");
		apply_btn:SetWidth(60);
		apply_btn:SetHeight(25);
		apply_btn:SetPoint("BOTTOMRIGHT",-20,20);
		apply_btn:SetText("Apply");
		apply_btn:SetScript("OnClick", function()
		SaveTheString(chosen_script);
		end);

	local storno_btn = CreateFrame("Button","StornoBTN",OptFrame,"UIPanelButtonTemplate");
		storno_btn:SetWidth(60);
		storno_btn:SetHeight(25);
		storno_btn:SetPoint("BOTTOMRIGHT",-85,20);
		storno_btn:SetText("Storno");
		storno_btn:SetScript("OnClick", CloseOpt_frame);

	-- Resizable
	opt_frm:SetResizable(true);
	opt_frm:SetMinResize(300, 200);

	local resize_btn = CreateFrame("Button", "ResizeBTN", OptFrame)
		resize_btn:SetPoint("BOTTOMRIGHT", -6, 4)
		resize_btn:SetSize(16, 16)
		resize_btn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		resize_btn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		resize_btn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
		resize_btn:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				opt_frm:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- more noticeable
			end
		end)
		resize_btn:SetScript("OnMouseUp", function(self, button)
			opt_frm:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			main_edb:SetWidth(edb_sf:GetWidth())
		end)
	
	local script_btn_sf = CreateFrame("ScrollFrame", "Script_SF", OptFrame, "UIPanelScrollFrameTemplate");
		script_btn_sf:SetPoint("LEFT", 5, 0)
		script_btn_sf:SetPoint("TOP", 0, -40)
		script_btn_sf:SetPoint("BOTTOM", 0, 50)
		script_btn_sf:SetWidth(120);
		
	local script_btn_frame = CreateFrame("Frame", "Script_Frame", OptFrame);
		script_btn_frame:SetPoint("LEFT", 5, 0)
		script_btn_frame:SetPoint("TOP", 0, -40)
		script_btn_frame:SetPoint("BOTTOM", 0, 50)
		script_btn_frame:SetWidth(120);
		script_btn_frame:SetHeight(400);
		script_btn_sf:SetScrollChild(script_btn_frame);
	
	local add_script_btn = CreateFrame("Button","AddBTN",OptFrame,"UIPanelButtonTemplate");
		add_script_btn:SetWidth(120);
		add_script_btn:SetHeight(35);
		add_script_btn:SetPoint("BOTTOMLEFT",5,5);
		add_script_btn:SetText("+ ADD");
		add_script_btn:SetScript("OnClick", (function()
			CreateTemplBtn(getn(LubosPBSaved)+1);
			LubosPBSaved[getn(LubosPBSaved)+1] = DEFAULT_CODE;
			end));
	local script0_btn = CreateTemplBtn(0);
	CreateExistingBtns();
		
		
	opt_frm:Show()
	script_btn_frame:Show();
	script0_btn:Click();
end

function CreateExistingBtns()
	for i=1,getn(LubosPBSaved) do 
		CreateTemplBtn(i);
	end
end

function CreateTemplBtn(i)
	local f = CreateFrame("Button", "ScriptBTN"..i, Script_Frame, "OptionsListButtonTemplate");
		f:SetPoint("TOPLEFT",0,i*(-25));
		f:SetSize(120,25);
		f:SetText("Script"..i);
		f:SetScript("OnClick", (function() 
			opt_frm_fs_script:SetText("Selected Script: "..f:GetText()); 
			chosen_script = i;
			Load_string_main_edb(i);
			end));
	return f;
end

function Load_string_main_edb(i)
	main_edb:SetText(LubosPBSaved[i]);
end

function ExecuteFromString(i)
	local func = loadstring(LubosPBSaved[i]);
	setfenv( func, getfenv() )
	func();
end

function SaveTheString(i)
	LubosPBSaved[i] = main_edb:GetText();
end

function CloseOpt_frame()
	opt_frm:Hide();
end

function PetBattleEnded()
	PlaySoundFile("Interface\\AddOns\\LubosPB\\Sound\\Victory.ogg", "Master");
end

SLASH_LubosPB1 = "/lubos"
SLASH_LubosPB2 = "/lubospb"
SlashCmdList["LubosPB"] = CreateGUI
