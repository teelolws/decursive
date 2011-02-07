--[[
    This file is part of Decursive.
    
    Decursive (v @project-version@) add-on for World of Warcraft UI
    Copyright (C) 2006-2007-2008-2009 John Wellesz (archarodim AT teaser.fr) ( http://www.2072productions.com/to/decursive.php )

    Starting from 2009-10-31 and until said otherwise by its author, Decursive
    is no longer free software, all rights are reserved to its author (John Wellesz).

    The only official and allowed distribution means are www.2072productions.com, www.wowace.com and curse.com.
    To distribute Decursive through other means a special authorization is required.
    

    Decursive is inspired from the original "Decursive v1.9.4" by Quu.
    The original "Decursive 1.9.4" is in public domain ( www.quutar.com )

    Decursive is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY.
--]]
-------------------------------------------------------------------------------

local addonName, T = ...;
-- big ugly scary fatal error message display function {{{
if not T._FatalError then
-- the beautiful error popup : {{{ -
StaticPopupDialogs["DECURSIVE_ERROR_FRAME"] = {
    text = "|cFFFF0000Decursive Error:|r\n%s",
    button1 = "OK",
    OnAccept = function()
        return false;
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    showAlert = 1,
    }; -- }}}
T._FatalError = function (TheError) StaticPopup_Show ("DECURSIVE_ERROR_FRAME", TheError); end
end
-- }}}
if not T._LoadedFiles or not T._LoadedFiles["Dcr_utils.lua"] then
    if not DecursiveInstallCorrupted then T._FatalError("Decursive installation is corrupted! (Dcr_utils.lua not loaded)"); end;
    DecursiveInstallCorrupted = true;
    return;
end

local D = Dcr;

local L  = D.L;
local LC = D.LC;
local DC = DcrC;
local DS = DC.DS;
local icon = LibStub("LibDBIcon-1.0", true)

local pairs             = _G.pairs;
local ipairs            = _G.ipairs;
local type              = _G.type;
local table             = _G.table;
local str_format        = _G.string.format;
local str_gsub          = _G.string.gsub;
local str_sub           = _G.string.sub;
local abs               = _G.math.abs;
local GetNumRaidMembers         = _G.GetNumRaidMembers;
local GetNumPartyMembers        = _G.GetNumPartyMembers;
local InCombatLockdown  = _G.InCombatLockdown;
local _;
-- Default values for the option

D:GetSpellsTranslations(false); -- Register spell translations

function D:GetDefaultsSettings()
    return {
        -- default settings {{{
        class = {
            -- Curring order (1 is the most important, 6 the lesser...)
            CureOrder = {
                [DC.MAGIC]      = 1,
                [DC.CURSE]      = 2,
                [DC.POISON]     = 3,
                [DC.DISEASE]    = 4,
                [DC.ENEMYMAGIC] = 5,
                [DC.CHARMED]    = 6,
            },
        },

        global = {
            debug = false,
            NonRealease = false,
            LastExpirationAlert = 0,
            NewerVersionDetected = D.VersionTimeStamp,
            NewerVersionName = false,
            NewerVersionAlert = 0,
            NewVersionsBugMeNot = false,
            LastVersionAnnounce = 0,
            --@debug@
            LastChekOutAlert = 0,
            --@end-debug@

            -- the key to bind the macro to
            MacroBind = false,
            NoStartMessages = false,

            AvailableButtons = {
                "%s1", -- left mouse button
                "%s2", -- right mouse button
                "ctrl-%s1",
                "ctrl-%s2",
                "shift-%s1",
                "shift-%s2",
                "shift-%s3",
                "alt-%s1",
                "alt-%s2",
                "alt-%s3",
                "%s3",       -- the last two entries are always target and focus
                "ctrl-%s3",
            },
        },

        profile = {
            -- this is the priority list of people to cure
            PriorityList = { },
            PriorityListClass = { },
            PrioGUIDtoNAME = { },

            -- this is the people to skip
            SkipList = { },
            SkipListClass = { },
            SkipGUIDtoNAME = { },

            -- The micro units debuffs frame
            ShowDebuffsFrame = true,

            -- Setting to hide the MUF handle (render it mouse-non-interactive)
            HideMUFsHandle = false,

            AutoHideMUFs = 1,

            -- The maximum number of MUFs to be displayed
            DebuffsFrameMaxCount = 80,

            DebuffsFrameElemScale = 1,

            DebuffsFrameElemAlpha = .35,

            DebuffsFrameElemBorderShow = true,

            DebuffsFrameElemBorderAlpha = .2,

            DebuffsFrameElemTieTransparency = true,

            DebuffsFramePerline = 10,

            DebuffsFrameTieSpacing = true,

            DebuffsFrameXSpacing = 3,

            DebuffsFrameYSpacing = 3,

            DebuffsFrameStickToRight = false,

            -- The time between each MUF update
            DebuffsFrameRefreshRate = 0.10,

            -- The number of MUFs updated every DebuffsFrameRefreshRate
            DebuffsFramePerUPdate = 10,

            DebuffsFrameShowHelp = true,

            -- position x save
            DebuffsFrame_x = false,

            -- position y save
            DebuffsFrame_y = false,

            -- reverse MUFs disaplay
            DebuffsFrameGrowToTop = false,

            -- display chronometer on MUFs
            DebuffsFrameChrono = true,

            DebuffsFrameTimeLeft = true,

            -- this is wether or not to show the live-list  
            HideLiveList = false,

            LiveListAlpha = 0.7,

            LiveListScale = 1.0,

            -- position of the "Decursive" main bar, the live-list is anchored to this bar.
            MainBarX = false,

            MainBarY = false,

            -- This will turn on and off the sending of messages to the default chat frame
            Print_ChatFrame = true,

            -- this will send the messages to a custom frame that is moveable       
            Print_CustomFrame = true,

            -- this will disable error messages
            Print_Error = true,

            -- should we scan pets
            Scan_Pets = true,

            -- should we ignore stealthed units? A useless option since a very long time.
            Ingore_Stealthed = false,

            Show_Stealthed_Status = true,

            -- how many to show in the livelist
            Amount_Of_Afflicted = 3,

            -- The live-list will only display units in range of your curring spell
            LV_OnlyInRange = true,

            -- how many seconds to "black list" someone with a failed spell
            CureBlacklist = 5.0,

            -- how often to poll for afflictions in seconds (for the live-list only)
            ScanTime = 0.3,

            -- Are prio list members protected from blacklisting?
            DoNot_Blacklist_Prio_List = false,

            -- Play a sound when there is something to decurse
            PlaySound = true,

            -- The sound file to use
            SoundFile = DC.AfflictionSound,

            -- Example to change the sound : /run Dcr.profile.SoundFile = "Sound\\interface\\AuctionWindowOpen.wav"

            -- Hide the buttons
            HideButtons = false,

            -- Display text above in the custom frame
            CustomeFrameInsertBottom = false,

            -- Disable tooltips in affliction list
            AfflictionTooltips = true,

            -- Reverse LiveList Display
            ReverseLiveDisplay = false,

            -- Hide the "Decursive" bar
            Hidden = false,

            -- if true then the live list will show only if the "Decursive" bar is shown
            LiveListTied = false,

            -- allow to changes the default output window
            OutputWindow = "DEFAULT_CHAT_FRAME", -- ACEDB CRASHES if we set it directly


            MiniMapIcon = {hide=true},

            -- Display a warning if no key is mapped.
            NoKeyWarn = false,

            -- Disable macro creation
            DisableMacroCreation = false,

            -- Allow Decursive's macro editing
	    AllowMacroEdit = false,

            -- Those are the different colors used for the MUFs main textures
            MF_colors = {
                [1]                 =   {  .8 , 0   , 0    ,  1     }, -- red
                [2]                 =   {  .3 ,  .3 ,  .8  ,  1     }, -- blue
                [3]                 =   {  .8 ,  .5 ,  .25 ,  1     }, -- orange
                [4]                 =   { 1   , 0   , 1    ,  1     }, -- purple
                [5]                 =   { 1   , 1   , 1    ,  1     }, -- white for undefined
                [6]                 =   { 1   , 1   , 1    ,  1     }, -- white for undefined
                [DC.NORMAL]         =   {  .0 ,  .3 ,  .1  ,   .9   }, -- dark green
                [DC.BLACKLISTED]    =   { 0   , 0   , 0    ,  1     }, -- black
                [DC.ABSENT]         =   {  .4 ,  .4 ,  .4  ,   .9   }, -- transparent grey
                [DC.FAR]            =   {  .4 ,  .1 ,  .4  ,   .85  }, -- transparent purple
                [DC.STEALTHED]      =   {  .4 ,  .6 ,  .4  ,  1     }, -- pale green
                [DC.CHARMED_STATUS] =   { 0   , 1   , 0    ,  1     }, -- full green
                ["COLORCHRONOS"]    =   { 0.6 , 0.1 , 0.2  ,   .6   }, -- medium red
            },

            -- Debuffs {{{
            -- those debuffs prevent us from curing the unit
            DebuffsToIgnore = {
                [DS["Banish"]]                      = true,
                [DS["Frost Trap Aura"]]             = true,
            },

            -- thoses debuffs are in fact buffs...
            BuffDebuff = {
                [DS["DREAMLESSSLEEP"]]      = true,
                [DS["GDREAMLESSSLEEP"]]     = true,
                [DS["MDREAMLESSSLEEP"]]     = true,
                [DS["DCR_LOC_MINDVISION"]]  = true,
                [DS["MUTATINGINJECTION"]]   = true,
                [DS["Arcane Blast"]]                = true,
            },

            DebuffAlwaysSkipList = {
            },

            DebuffsSkipList = {
                DS["DCR_LOC_SILENCE"],
                DS["ANCIENTHYSTERIA"],
                DS["IGNITE"],
                DS["TAINTEDMIND"],
                DS["MAGMASHAKLES"],
                DS["CRIPLES"],
                DS["DUSTCLOUD"],
                DS["WIDOWSEMBRACE"],
                DS["CURSEOFTONGUES"],
                DS["SONICBURST"],
                DS["DELUSIONOFJINDO"]
            },

            skipByClass = {
                ["WARRIOR"] = {
                    [DS["ANCIENTHYSTERIA"]]   = true,
                    [DS["IGNITE"]]        = true,
                    [DS["TAINTEDMIND"]]       = true,
                    [DS["WIDOWSEMBRACE"]]    = true,
                    [DS["CURSEOFTONGUES"]]   = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["ROGUE"] = {
                    [DS["DCR_LOC_SILENCE"]]           = true,
                    [DS["ANCIENTHYSTERIA"]]   = true,
                    [DS["IGNITE"]]        = true,
                    [DS["TAINTEDMIND"]]       = true,
                    [DS["WIDOWSEMBRACE"]]    = true,
                    [DS["CURSEOFTONGUES"]]   = true,
                    [DS["SONICBURST"]]        = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["HUNTER"] = {
                    [DS["MAGMASHAKLES"]]     = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["MAGE"] = {
                    [DS["MAGMASHAKLES"]]     = true,
                    [DS["CRIPLES"]]            = true,
                    [DS["DUSTCLOUD"]]         = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["WARLOCK"] = {
                    [DS["CRIPLES"]]            = true,
                    [DS["DUSTCLOUD"]]         = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["DRUID"] = {
                    [DS["CRIPLES"]]            = true,
                    [DS["DUSTCLOUD"]]         = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["PALADIN"] = {
                    [DS["CRIPLES"]]            = true,
                    [DS["DUSTCLOUD"]]         = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["PRIEST"] = {
                    [DS["CRIPLES"]]            = true,
                    [DS["DUSTCLOUD"]]         = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["SHAMAN"] = {
                    [DS["CRIPLES"]]            = true,
                    [DS["DUSTCLOUD"]]         = true,
                    [DS["DELUSIONOFJINDO"]]= true,
                },
                ["DEATHKNIGHT"] = {
                }
            }
            -- }}}
        }
    } -- }}}
end

local OptionsPostSetActions = { -- {{{
    ["debug"] = function(v)  D.debug = v end,
    ["HideMUFsHandle"] = function(v) D.MFContainerHandle:EnableMouse(not v); D:Print(v and "MUFs handle disabled" or "MUFs handle enabled"); end,
    ["AfflictionTooltips"] = function(v) for id,lvitem in ipairs(D.LiveList.ExistingPerID) do lvitem.Frame:EnableMouse(v); end end,
    ["Amount_Of_Afflicted"] = function(v) D.LiveList:RestAllPosition(); end,
    ["ScanTime"] = function(v) D:ScheduleRepeatedCall("Dcr_LLupdate", D.LiveList.Update_Display, v, D.LiveList); D:Debug("LV scan delay changed:", v); end,
    ["ReverseLiveDisplay"] = function(v) D.LiveList:RestAllPosition(); end,
    ["LiveListScale"] = function(v) D:SetLLScale(v); end,
    ["AutoHideMUFs"] = function(v) D:AutoHideShowMUFs(); end,
    ["DebuffsFrameGrowToTop"] = function(v) D.MicroUnitF:SavePos(); D.MicroUnitF:ResetAllPositions (); D.MicroUnitF:Place (); end,
    ["DebuffsFrameStickToRight"] = function(v) D.MicroUnitF:SavePos(); D.MicroUnitF:Delayed_MFsDisplay_Update(); end,
    ["DebuffsFrameMaxCount"] = function(v) D.MicroUnitF.MaxUnit = v; D.MicroUnitF:Delayed_MFsDisplay_Update(); end,
    ["DebuffsFramePerline"] = function(v)  D.MicroUnitF:ResetAllPositions (); D.MicroUnitF:Place (); end,
    ["DebuffsFrameElemScale"] = function(v) D.MicroUnitF:SetScale(D.profile.DebuffsFrameElemScale); end,
    ["DebuffsFrameRefreshRate"] = function(v) D:ScheduleRepeatedCall("Dcr_MUFupdate", D.DebuffsFrame_Update, D.profile.DebuffsFrameRefreshRate, D); D:Debug("MUFs refresh rate changed:", D.profile.DebuffsFrameRefreshRate, v); end,

    ["Scan_Pets"] = function(v) D:GroupChanged ("opt CURE_PETS"); end,
    ["DisableMacroCreation"] = function(v) if v then D:SetMacroKey (nil); D:Debug("SetMacroKey (nil)"); end end,
} -- }}}

function D.GetHandler (info, value) -- {{{
    local source = D.db.global;

    if D.db.profile[info[#info]]~=nil then

        source = D.db.profile;

    elseif D.db.class[info[#info]]~=nil then

        source = D.db.class;

    end

    return source[info[#info]];

end -- }}}
-- Used in Ace3 option table to get feedback when setting options through command line
function D.SetHandler (info, value) -- {{{


    local target = D.db.global;

    if D.db.profile[info[#info]]~=nil then

        target = D.db.profile;

    elseif D.db.class[info[#info]]~=nil then

        target = D.db.class;

    end

    target[info[#info]] = value;

    if OptionsPostSetActions[info[#info]] then
        OptionsPostSetActions[info[#info]](value);
        D:Debug("PostAction executed");
    end

    if info["uiType"] == "cmd" then

        if value == true then
            value = L["OPT_CMD_ENABLED"];
        elseif value == false then
            value = L["OPT_CMD_DISBLED"];
        end

        D:Print(D:ColorText(D:GetOPtionPath(info), "FF00DD00"), "=>", D:ColorText(value, "FF3399EE"));
    end
end -- }}}

local function GetStaticOptions ()
    return {
        -- {{{
        type = "group",
        name = D.name,
       
        get = D.GetHandler,
        set = D.SetHandler,
        hidden = function () return not D:IsEnabled(); end,
        disabled = function () return not D:IsEnabled(); end,
        args = {
            -- enable and disable
            enable = {
                type = 'toggle',
                name = L["OPT_ENABLEDECURSIVE"],
                hidden = function() return D:IsEnabled(); end,
                disabled = function() return D:IsEnabled(); end,
                set = function() D.Status.Enabled = D:Enable(); return D.Status.Enabled; end,
                get = function() return D:IsEnabled(); end,
                order = -2,
            },
            disable = {
                type = 'toggle',
                guiHidden  = true,
                disabled = function() return not D:IsEnabled(); end,
                name = 'disable',
                set = function() D.Status.Enabled = not D:Disable(); return not D.Status.Enabled; end,
                get = function() return not D:IsEnabled(); end,
                order = -3,
            },
            HideMUFsHandle = {
                type = 'toggle',
                name = L["OPT_HIDEMUFSHANDLE"],
                desc = L["OPT_HIDEMUFSHANDLE_DESC"],
                guiHidden   = true,
                disabled = function() return not D:IsEnabled() or not D.profile.ShowDebuffsFrame; end,
                
                get = function(info) return not D.MFContainerHandle:IsMouseEnabled(); end,
                order = -4,
            },
            debug = {
                type = "toggle",
                name = L["OPT_ENABLEDEBUG"],
                desc = L["OPT_ENABLEDEBUG_DESC"],
                guiHidden = true,
                order = -5,
            },
            -- Atticus Ross rules!
 
            general = {
                -- {{{
                type = 'group',
                name = L["OPT_GENERAL"],
                order = 1,
                icon = DC.IconON,
                args = {
                    version = {
                        type = 'description',
                        name = D.version,
                        image = DC.IconON,
                        order = 0,
                    },
                    newVersion = {
                        type = 'description',
                        name = "|cFFEE0022" .. (L["NEW_VERSION_ALERT"]):format(D.db.global.NewerVersionName or "none", date("%Y-%m-%d", D.db.global.NewerVersionDetected)) .. "|r",
                        hidden = function() return not D.db.global.NewerVersionName end,
                        order = 2,
                    },
                    ShowDebuffsFrame = {
                        type = "toggle",
                        name = L["OPT_SHOWMFS"],
                        desc = L["OPT_SHOWMFS_DESC"],
                        set = function()
                            D:ShowHideDebuffsFrame ();
                        end,
                        disabled = function() return D.Status.Combat end,
                        order = 5,
                    },
                    AutoHideMUFs = {
                        type = "select",
                        style = "dropdown",
                        name = L["OPT_AUTOHIDEMFS"],
                        desc = L["OPT_AUTOHIDEMFS_DESC"] .. "\n\n" .. ("%s: %s\n%s: %s\n%s: %s"):format(D:ColorText(L["OPT_HIDEMFS_NEVER"], "FF88CCAA"), L["OPT_HIDEMFS_NEVER_DESC"], D:ColorText(L["OPT_HIDEMFS_SOLO"], "FF88CCAA"), L["OPT_HIDEMFS_SOLO_DESC"], D:ColorText(L["OPT_HIDEMFS_GROUP"], "FF88CCAA"), L["OPT_HIDEMFS_GROUP_DESC"]),
                        values = {L["OPT_HIDEMFS_NEVER"], L["OPT_HIDEMFS_SOLO"], L["OPT_HIDEMFS_GROUP"]},
                        order = 6,
                    },
                    HideLiveList = {
                        type = "toggle",
                        name = L["HIDE_LIVELIST"],
                        desc = L["OPT_HIDELIVELIST_DESC"],
                        set = function()
                            D:ShowHideLiveList()
                            if D.profile.HideLiveList and not D.profile.ShowDebuffsFrame or not D.Status.HasSpell then
                                D:SetIcon(DC.IconOFF);
                            else
                                D:SetIcon(DC.IconON);
                            end
                        end,
                        order = 7,
                    },
                    PlaySound = {
                        type = "toggle",
                        disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame or not D:IsEnabled(); end,
                        name = L["PLAY_SOUND"],
                        desc = L["OPT_PLAYSOUND_DESC"],
                        
                        order = 10,
                    },
                    AfflictionTooltips = {
                        type = "toggle",
                        disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame or not D:IsEnabled(); end,
                        name = L["SHOW_TOOLTIP"],
                        desc = L["OPT_SHOWTOOLTIP_DESC"],
                        order = 20,
                    },
                    minimap = {
                        type = "toggle",
                        name = L["OPT_SHOWMINIMAPICON"],
                        desc = L["OPT_SHOWMINIMAPICON_DESC"],
                        get = function() return not D.profile.MiniMapIcon or not D.profile.MiniMapIcon.hide end,
                        set = function(info,v)
                            local hide = not v;
                            D.profile.MiniMapIcon.hide = hide;
                            if hide then
                                icon:Hide("Decursive");
                            else
                                icon:Show("Decursive");
                            end
                        end,
                        order = 30,
                    },
                    CureBlacklist = {
                        type = 'range',
                        name = L["BLACK_LENGTH"],
                        desc = L["OPT_BLACKLENTGH_DESC"],
                        min = 1,
                        max = 20,
                        step = 0.1,
                        order = 40,
                    },
                    SysOps = {
                        type = 'header',
                        name = "",
                        order = 50
                    },
                    TestItemDisplayed = {
                        type = "toggle",
                        name = L["OPT_CREATE_VIRTUAL_DEBUFF"],
                        desc = L["OPT_CREATE_VIRTUAL_DEBUFF_DESC"],
                        get = function() return  D.LiveList.TestItemDisplayed end,
                        set = function()
                            if not D.LiveList.TestItemDisplayed then
                                D.LiveList:DisplayTestItem();
                            else
                                D.LiveList:HideTestItem();
                            end
                        end,
                        disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame or not D.Status.HasSpell or not D.Status.Enabled end,
                        order = 60
                    },
                    NoStartMessages = {
                        type = "toggle",
                        name = L["OPT_NOSTARTMESSAGES"],
                        desc = L["OPT_NOSTARTMESSAGES_DESC"],
                        order = 70
                    },
                    NewerVersionAlerts ={
                        type = "toggle",
                        name = L["OPT_NEWVERSIONBUGMENOT"],
                        desc = L["OPT_NEWVERSIONBUGMENOT_DESC"],
                        get = function() return not D.db.global.NewVersionsBugMeNot end,
                        set = function(info,v)
                            D.db.global.NewVersionsBugMeNot = v == false and D.VersionTimeStamp or false;
                        end,
                        order = 75
                    },
                    report = {
                        type = "execute",
                        name = D:ColorText(L["DECURSIVE_DEBUG_REPORT_SHOW"], "FFFF0000"),
                        desc = L["DECURSIVE_DEBUG_REPORT_SHOW_DESC"],
                        func = function ()
                            LibStub("AceConfigDialog-3.0"):Close(D.name);
                            GameTooltip:Hide();
                            D:ShowDebugReport();
                        end,
                        hidden = function() return  #T._DebugTextTable < 1 end,
                        order = 1000
                    },
                    
                    GlorfindalMemorium = {
                        type = "execute",
                        name = D:ColorText(L["GLOR1"], "FF" .. D:GetClassHexColor( "WARRIOR" )),
                        desc = L["GLOR2"],
                        func = function ()

                        -- {{{
                            LibStub("AceConfigDialog-3.0"):Close(D.name);
                            GameTooltip:Hide();
                            if not D.MemoriumFrame then
                                D.MemoriumFrame = CreateFrame("Frame", nil, UIParent);
                                local f = D.MemoriumFrame;
                                local w = 512; local h = 390;

                                f:SetFrameStrata("TOOLTIP");
                                f:EnableKeyboard(true);
                                f:SetScript("OnKeyUp", function (frame, event, arg1, arg2) D.MemoriumFrame:Hide(); end);
                                --[[
                                f:SetScript("OnShow",
                                function ()
                                -- I wanted to make the shadow to move over the marble very slowly as clouds
                                -- I tried to make it rotate but the way I found would only make it rotate around its origin (which is rarely useful)
                                -- so leaving it staedy for now... if someone got an idea, let me know.
                                D:ScheduleRepeatingEvent("Dcr_GlorMoveShadow",
                                function (f)
                                local cos, sin = math.cos, math.sin;
                                f.Shadow.Angle = f.Shadow.Angle + 1;
                                if f.Shadow.Angle == 360 then f.Shadow.Angle = 0; end
                                local angle = math.rad(f.Shadow.Angle);
                                D:SetCoords(f.Shadow, cos(angle), sin(angle), 0, -sin(angle), cos(angle), 0);

                                end
                                , 1/50, f);
                                end);
                                f:SetScript("OnHide", function() D:CancelDelayedCall("Dcr_GlorMoveShadow"); end)
                                --]]

                                f:SetWidth(w);
                                f:SetHeight(h);
                                f.tTL = f:CreateTexture(nil,"BACKGROUND")
                                f.tTL:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-TopLeft")
                                f.tTL:SetWidth(w - w / 5);
                                f.tTL:SetHeight(h - h / 3);
                                f.tTL:SetTexCoord(0, 1, 5/256, 1);
                                f.tTL:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -10);

                                f.tTR = f:CreateTexture(nil,"BACKGROUND")
                                f.tTR:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-TopRight")
                                f.tTR:SetWidth(w / 5 - 3);
                                f.tTR:SetHeight(h - h / 3);
                                f.tTR:SetTexCoord(0, 1, 5/256, 1);
                                f.tTR:SetPoint("TOPLEFT", f.tTL, "TOPRIGHT", 0, 0);

                                f.tBL = f:CreateTexture(nil,"BACKGROUND")
                                f.tBL:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-BotLeft")
                                f.tBL:SetWidth(w - w / 5);
                                f.tBL:SetHeight(h / 3 - 20);
                                f.tBL:SetTexCoord(0,1,0, 408/512);
                                f.tBL:SetPoint("TOPLEFT", f.tTL, "BOTTOMLEFT", 0, 0);

                                f.tBR = f:CreateTexture(nil,"BACKGROUND")
                                f.tBR:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-BotRight")
                                f.tBR:SetWidth(w / 5 - 3);
                                f.tBR:SetHeight(h / 3 - 20);
                                f.tBR:SetTexCoord(0,1,0, 408/512);
                                f.tBR:SetPoint("TOPLEFT", f.tBL, "TOPRIGHT", 0, 0);

                                f.Shadow = f:CreateTexture(nil, "ARTWORK");
                                f.Shadow:SetTexture("Interface\\TabardFrame\\TabardFrameBackground")
                                f.Shadow:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -9);
                                f.Shadow:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 9);
                                f.Shadow:SetAlpha(0.1);

                                ---[[
                                f.fB = f:CreateTexture(nil,"OVERLAY")
                                f.fB:SetTexture("Interface\\AddOns\\Decursive\\Textures\\GoldBorder")
                                f.fB:SetTexCoord(5/512, 324/512, 6/512, 287/512);
                                f.fB:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
                                f.fB:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
                                --]]

                                f.FSt = f:CreateFontString(nil,"OVERLAY", "MailTextFontNormal");
                                f.FSt:SetFont("Fonts\\MORPHEUS.TTF", 18 );
                                f.FSt:SetTextColor(0.18, 0.12, 0.06, 1);
                                f.FSt:SetPoint("TOPLEFT", f.tTL, "TOPLEFT", 5, -20);
                                f.FSt:SetPoint("TOPRIGHT", f.tTR, "TOPRIGHT", -5, -20);
                                f.FSt:SetJustifyH("CENTER");
                                f.FSt:SetText(L["GLOR3"]);
                                f.FSt:SetAlpha(0.80);

                                f.FSc = f:CreateFontString(nil,"OVERLAY", "MailTextFontNormal");
                                f.FSc:SetFont("Fonts\\MORPHEUS.TTF", 15 );
                                f.FSc:SetTextColor(0.18, 0.12, 0.06, 1);
                                f.FSc:SetHeight(h - 30 - 60);
                                f.FSc:SetPoint("TOP", f.FSt, "BOTTOM", 0, -28);
                                f.FSc:SetPoint("LEFT", f.tTL, "LEFT", 30, 0);
                                f.FSc:SetPoint("RIGHT", f.tTR, "RIGHT", -30, 0);
                                f.FSc:SetJustifyH("CENTER");
                                f.FSc:SetJustifyV("TOP");
                                f.FSc:SetSpacing(5);

                                f.FSc:SetText(L["GLOR4"]);


                                f.FSc:SetAlpha(0.80);

                                f.FSl = f:CreateFontString(nil,"OVERLAY", "MailTextFontNormal");
                                f.FSl:SetFont("Fonts\\MORPHEUS.TTF", 15 );
                                f.FSl:SetTextColor(0.18, 0.12, 0.06, 1);
                                f.FSl:SetJustifyH("LEFT");
                                f.FSl:SetJustifyV("BOTTOM");
                                f.FSl:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 30, 33);
                                f.FSl:SetAlpha(0.80);
                                f.FSl:SetText(L["GLOR5"]);

                                f:SetPoint("CENTER",0,0);

                            end
                            D.MemoriumFrame:Show();

                            --[[

                            In remembrance of Bertrand Sense
                            1969 - 2007


                            Friendship and affection can take their roots anywhere, those
                            who met Glorfindal in World of Warcraft knew a man of great
                            commitment and a charismatic leader.

                            He was in life as he was in game, selfless, generous, dedicated
                            to his friends and most of all, a passionate man.

                            He left us at the age of 38 leaving behind him not just
                            anonymous players in a virtual world, but a group of true
                            friends who will miss him forever.

                            He will always be remembered...

                            --

                            En souvenir de Bertrand Sense
                            1969 - 2007

                            L'amitié et l'affection peuvent prendre naissance n'importe où,
                            ceux qui ont rencontré Glorfindal dans World Of Warcraft on
                            connu un homme engagé et un leader charismatique.

                            Il était dans la vie comme dans le jeux, désintéressé,
                            généreux, dévoué envers les siens et surtout un homme passionné.

                            Il nous a quitté à l'âge de 38 ans laissant derrière lui pas
                            seulement des joueurs anonymes dans un monde virtuel, mais un
                            groupe de véritables amis à qui il manquera eternellement.

                            On ne l'oubliera jamais...

                            --]]
                            -- }}}
                        end,
                        order = 100,
                    },
                }
            }, -- }}}

            livelistoptions = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_LIVELIST"], "FF22EE33"),
                desc = L["OPT_LIVELIST_DESC"],
                hidden = function () return not D:IsEnabled() or D.profile.HideLiveList; end,
                disabled = function () return not D:IsEnabled() or D.profile.HideLiveList; end,
                order = 2,

                args = {
                    description = {
                        type = "description",
                        name = L["OPT_LIVELIST_DESC"],
                        order = 0,
                    },
                    LV_OnlyInRange = {
                        type = "toggle",
                        name = L["OPT_LVONLYINRANGE"],
                        desc = L["OPT_LVONLYINRANGE_DESC"],
                        order = 100
                    },
                    Amount_Of_Afflicted = {
                        type = 'range',
                        name = L["AMOUNT_AFFLIC"],
                        desc = L["OPT_AMOUNT_AFFLIC_DESC"],
                        min = 1,
                        max = D.CONF.MAX_LIVE_SLOTS,
                        step = 1,
                        order = 104,
                    },
                    ScanTime = {
                        type = 'range',
                        name = L["SCAN_LENGTH"],
                        desc = L["OPT_SCANLENGTH_DESC"],
                        min = 0.1,
                        max = 1,
                        step = 0.1,
                        order = 106,
                    },
                    ReverseLiveDisplay = {
                        type = "toggle",
                        name = L["REVERSE_LIVELIST"],
                        desc = L["OPT_REVERSE_LIVELIST_DESC"],
                        order = 107
                    },
                    LiveListScale = {
                        type = 'range',
                        disabled = function() return D.profile.HideLiveList or D.profile.Hidden end,
                        name = L["OPT_LLSCALE"],
                        desc = L["OPT_LLSCALE_DESC"],
                        min = 0.3,
                        max = 4,
                        step = 0.01,
                        isPercent = true,
                        order = 1009,
                    },
                    AlphaLL = {
                        type = 'range',
                        disabled = function() return D.profile.HideLiveList or D.profile.Hidden end,
                        name = L["OPT_LLALPHA"],
                        desc = L["OPT_LLALPHA_DESC"],
                        get = function() return 1 - D.profile.LiveListAlpha end,
                        set = function(info,v) 
                            if (v ~= D.profile.LiveListAlpha) then
                                D.profile.LiveListAlpha = 1 - v;
                                DecursiveMainBar:SetAlpha(D.profile.LiveListAlpha);
                                DcrLiveList:SetAlpha(D.profile.LiveListAlpha);
                            end
                        end,
                        min = 0,
                        max = 0.8,
                        step = 0.01,
                        isPercent = true,
                        order = 1010,
                    },
                },
            }, -- // }}}

            MessageOptions = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_MESSAGES"], "FF229966"),
                desc = L["OPT_MESSAGES_DESC"],
                order = 3,
                disabled = function() return  not D.Status.Enabled end,
                args = {
                    description = {name = L["OPT_MESSAGES_DESC"], order = 1, type = "description"},
                    Print_ChatFrame = {
                        type = "toggle",
                        width = 'full',
                        name =  L["PRINT_CHATFRAME"],
                        desc = L["OPT_CHATFRAME_DESC"],
                        order = 120
                    },
                    Print_CustomFrame = {
                        type = "toggle",
                        width = 'full',
                        name =  L["PRINT_CUSTOM"],
                        desc = L["OPT_PRINT_CUSTOM_DESC"],
                        order = 121
                    },
                    Print_Error = {
                        type = "toggle",
                        width = 'full',
                        name =  L["PRINT_ERRORS"],
                        desc =  L["OPT_PRINT_ERRORS_DESC"],
                        order = 122
                    },
                    ShowCustomFAnchor = {
                        type = "toggle",
                        width = 'full',
                        name =  L["ANCHOR"],
                        desc = L["OPT_ANCHOR_DESC"],
                        get = function() return DecursiveAnchor:IsVisible() end,
                        set = function()
                            D:ShowHideTextAnchor();
                        end,
                        order = 123
                    },
                }
            }, -- }}}

            MicroFrameOpt = {
                -- {{{
                type = "group",
                childGroups = "tab",
                name = D:ColorText(L["OPT_MFSETTINGS"], "FFBBCC33"),
                desc = L["OPT_MFSETTINGS_DESC"],
                disabled = function () return not D:IsEnabled() or not D.profile.ShowDebuffsFrame; end,
                hidden = function () return not D:IsEnabled() or not D.profile.ShowDebuffsFrame; end,
                order = 4,
                args = {
                    hint = {
                        type = 'description',
                        name = D:ColorText(L["OPT_MUFHANDLE_HINT"], "FF00EF00"),
                        order = 0,
                    },
                    displayOpts = {
                        type = "group",
                        name = L["OPT_DISPLAYOPTIONS"],
                        desc = L["OPT_MFSETTINGS_DESC"],
                        handler = {
                            ["disabled"] = function () return D.Status.Combat or not D:IsEnabled() or not D.profile.ShowDebuffsFrame; end,
                        },
                        order = 1,
                        args = {
                            -- {{{
                            DebuffsFrameGrowToTop = {
                                type = "toggle",
                                name = L["OPT_GROWDIRECTION"],
                                desc = L["OPT_GROWDIRECTION_DESC"],
                                disabled = "disabled",
                                order = 1300,
                            },
                            DebuffsFrameStickToRight = {
                                type = "toggle",
                                name = L["OPT_STICKTORIGHT"],
                                desc = L["OPT_STICKTORIGHT_DESC"],
                                disabled = "disabled",
                                order = 1310,
                            },
                            DebuffsFrameElemBorderShow = {
                                type = "toggle",
                                name = L["OPT_SHOWBORDER"],
                                desc = L["OPT_SHOWBORDER_DESC"],
                                order = 1350,
                            },
                            DebuffsFrameChrono = {
                                type = "toggle",
                                name = L["OPT_SHOWCHRONO"],
                                desc = L["OPT_SHOWCHRONO_DESC"],
                                order = 1360,
                                disabled = false,
                            },
                            DebuffsFrameTimeLeft = {
                                type = "toggle",
                                disabled = function () return not D.profile.DebuffsFrameChrono end,
                                name = L["OPT_SHOWCHRONOTIMElEFT"],
                                desc = L["OPT_SHOWCHRONOTIMElEFT_DESC"],
                                order = 1365,
                            },
                            Show_Stealthed_Status = {
                                type = "toggle",
                                name =  L["OPT_SHOW_STEALTH_STATUS"],
                                desc = L["OPT_SHOW_STEALTH_STATUS_DESC"],
                                order = 1370,
                                disabled = false,
                            },
                            AfflictionTooltips = {
                                type = "toggle",
                                name = L["SHOW_TOOLTIP"],
                                desc = L["OPT_SHOWTOOLTIP_DESC"],
                                disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame end,
                                order = 1400,
                            },
                            DebuffsFrameShowHelp = {
                                type = "toggle",
                                name = L["OPT_SHOWHELP"],
                                desc = L["OPT_SHOWHELP_DESC"],
                                disabled = false,
                                order = 1450,
                            },
                            DebuffsFrameMaxCount = {
                                type = 'range',
                                name = L["OPT_MAXMFS"],
                                desc = L["OPT_MAXMFS_DESC"],
                                min = 1,
                                max = 82,
                                step = 1,
                                disabled = "disabled",
                                order = 1500,
                            },
                            DebuffsFramePerline = {
                                type = 'range',
                                name = L["OPT_UNITPERLINES"],
                                desc = L["OPT_UNITPERLINES_DESC"],
                                min = 1,
                                max = 40,
                                step = 1,
                                disabled = "disabled",
                                order = 1600,
                            },
                            DebuffsFrameElemScale = {
                                type = 'range',
                                name = L["OPT_MFSCALE"],
                                desc = L["OPT_MFSCALE_DESC"],
                                min = 0.3,
                                max = 4,
                                step = 0.01,
                                isPercent = true,
                                disabled = "disabled",
                                order = 1800,
                            },
                            DebuffsFrameElemAlpha = {
                                type = 'range',
                                name = L["OPT_MFALPHA"],
                                desc = L["OPT_MFALPHA_DESC"],
                                get = function() return 1 - D.profile.DebuffsFrameElemAlpha end,
                                set = function(info,v)
                                    D.SetHandler(info, 1 - v);
                                    D.profile.DebuffsFrameElemBorderAlpha = (1 - v) / 2;
                                end,
                                disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame or not D.profile.DebuffsFrameElemTieTransparency end,
                                min = 0,
                                max = 1,
                                step = 0.01,
                                isPercent = true,
                                order = 1900,
                            },
                            TestLayout = {
                                type = "toggle",
                                name = L["OPT_TESTLAYOUT"],
                                desc = L["OPT_TESTLAYOUT_DESC"],
                                get = function() return D.Status.TestLayout end,
                                set = function(info,v)
                                    D.Status.TestLayout = v;
                                    D:GroupChanged("Test Layout");
                                end,
                                disabled = "disabled",
                                order = 1950,
                            },
                            TestLayoutUNum = {
                                type = 'range',
                                name = L["OPT_TESTLAYOUTUNUM"],
                                desc = L["OPT_TESTLAYOUTUNUM_DESC"],
                                get = function() return D.Status.TestLayoutUNum end,
                                set = function(info,v) 
                                    D.Status.TestLayoutUNum = v;
                                    D:GroupChanged("Test Layout num changed");
                                end,
                                disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame or not D.Status.TestLayout end,
                                min = 1,
                                max = 82,
                                step = 1,
                                order = 2000,
                            },
                            -- }}}
                        },
                    },

                    AdvDispOptions = {
                        type = "group",
                        name = L["OPT_ADVDISP"],
                        desc = L["OPT_ADVDISP_DESC"],
                        order = 2,
                        args = {
                            -- {{{
                            TransparencyOpts = {
                                type = 'group',
                                inline = true,
                                name = " ",
                                args = {
                                    DebuffsFrameElemTieTransparency = {
                                        type = "toggle",
                                        name = L["OPT_TIECENTERANDBORDER"],
                                        desc = L["OPT_TIECENTERANDBORDER_OPT"],
                                        set = function(info,v)
                                            D.SetHandler(info,v);
                                            if v then
                                                D.profile.DebuffsFrameElemBorderAlpha = (D.profile.DebuffsFrameElemAlpha / 2);
                                            end
                                        end,
                                        order = 100
                                    },
                                    DebuffsFrameElemBorderAlpha = {
                                        type = 'range',
                                        name = L["OPT_BORDERTRANSP"],
                                        desc = L["OPT_BORDERTRANSP_DESC"],
                                        get = function() return 1 - D.profile.DebuffsFrameElemBorderAlpha end,
                                        set = function(info,v) 
                                            D.SetHandler(info,1 - v);
                                        end,
                                        disabled = function() return D.profile.DebuffsFrameElemTieTransparency end,
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        isPercent = true,
                                        order = 102,
                                    },
                                    DebuffsFrameElemAlpha = {
                                        type = 'range',
                                        name = L["OPT_CENTERTRANSP"],
                                        desc = L["OPT_CENTERTRANSP_DESC"],
                                        get = function() return 1 - D.profile.DebuffsFrameElemAlpha end,
                                        set = function(info,v) 
                                            D.SetHandler(info,1 - v);

                                            if D.profile.DebuffsFrameElemTieTransparency then
                                                D.profile.DebuffsFrameElemBorderAlpha = (1 - v) / 2;
                                            end
                                        end,
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        isPercent = true,
                                        order = 101,
                                    },
                                },
                            },
                            SpacingOpts = {
                                type = 'group',
                                inline = true,
                                name = " ",
                                disabled = function() return D.Status.Combat end,
                                args = {
                                    DebuffsFrameTieSpacing = {
                                        type = "toggle",
                                        name = L["OPT_TIEXYSPACING"],
                                        desc = L["OPT_TIEXYSPACING_DESC"],
                                        set = function(info,v)
                                            D.SetHandler(info, v);
                                            if v then
                                                D.profile.DebuffsFrameYSpacing = D.profile.DebuffsFrameXSpacing;
                                            end
                                            D.MicroUnitF:ResetAllPositions ();
                                        end,
                                        order = 104
                                    },
                                    DebuffsFrameXSpacing = {
                                        type = 'range',
                                        name = L["OPT_XSPACING"],
                                        desc = L["OPT_XSPACING_DESC"],
                                        set = function(info,v) 
                                            D.SetHandler(info, v);
                                            if D.profile.DebuffsFrameTieSpacing then
                                                D.profile.DebuffsFrameYSpacing = v;
                                            end
                                            D.MicroUnitF:ResetAllPositions ();
                                            D.MicroUnitF:Place ();
                                        end,
                                        min = 0,
                                        max = 100,
                                        step = 1,
                                        order = 105,
                                    },
                                    DebuffsFrameYSpacing = {
                                        type = 'range',
                                        name = L["OPT_YSPACING"],
                                        desc = L["OPT_YSPACING_DESC"],
                                        set = function(info,v) 
                                            D.SetHandler(info, v);

                                            D.MicroUnitF:ResetAllPositions ();
                                            D.MicroUnitF:Place ();
                                        end,
                                        disabled = function() return D.Status.Combat or D.profile.DebuffsFrameTieSpacing end,
                                        min = 0,
                                        max = 100,
                                        step = 1,
                                        order = 106,
                                    }, -- }}}
                                },
                            },
                        },
                    },

                    MUFsColors = {
                        type = "group",
                        name = L["OPT_MUFSCOLORS"],
                        desc = L["OPT_MUFSCOLORS_DESC"],
                        order = 3,
                        disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame or not D:IsEnabled() end,
                        hidden = function () return not D:IsEnabled(); end,
                        args = {}
                    },

                    MUFsMouseButtons = {
                        type = "group",
                        name = L["OPT_MUFMOUSEBUTTONS"],
                        desc = L["OPT_MUFMOUSEBUTTONS_DESC"],
                        order = 4,
                        disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame or not D:IsEnabled() end,
                        hidden = function () return not D:IsEnabled(); end,
                        args = {},
                    },

                    PerfOptions = {
                        type = "group",
                        name = L["OPT_MFPERFOPT"],
                        --desc = L["OPT_ADVDISP_DESC"],
                        order = 5,
                        --disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame end,
                        args = {
                            -- {{{
                            Warning = {
                                type = "description",
                                name = D:ColorText(L["OPT_PERFOPTIONWARNING"], "FFFF0000"),
                                order = 2500,
                            },
                            DebuffsFrameRefreshRate = {
                                type = 'range',
                                name = L["OPT_MFREFRESHRATE"],
                                desc = L["OPT_MFREFRESHRATE_DESC"],
                                min = 0.017,
                                max = 0.2,
                                step = 0.01,
                                order = 2600,
                            },
                            DebuffsFramePerUPdate = {
                                type = 'range',
                                name = L["OPT_MFREFRESHSPEED"],
                                desc = L["OPT_MFREFRESHSPEED_DESC"],
                                min = 1,
                                max = 82,
                                step = 1,
                                order = 2700,
                            },
                        },
                    }, -- }}}
                },
            }, -- }}}

            CureOptions = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_CURINGOPTIONS"], "FFFF5533"),
                desc = L["OPT_CURINGOPTIONS_DESC"],
                order = 5,
                disabled = function() return D.Status.Combat end,
                args = {
                    description = {name = L["OPT_CURINGOPTIONS_DESC"], order = 1, type = "description"},
                    DoNot_Blacklist_Prio_List = {
                        type = "toggle",
                        width = 'full',
                        name =  L["DONOT_BL_PRIO"],
                        desc = L["OPT_DONOTBLPRIO_DESC"],
                        order = 131
                    },
                    Scan_Pets = {
                        type = "toggle",
                        width = 'full',
                        name = L["CURE_PETS"],
                        desc = L["OPT_CUREPETS_DESC"],
                        order = 133
                    },

                    Title2 = {
                        type="header",
                        name = L["OPT_CURINGORDEROPTIONS"],
                        order = 139,
                    },
                    description = {
                        type = "description",
                        name = L["OPT_CURINGOPTIONS_EXPLANATION"],
                        order = 140,
                    },
                    CureMagic = {
                        type = "toggle",
                        name = "  "..L["MAGIC"],
                        desc = L["OPT_MAGICCHECK_DESC"],
                        get = function() return D:GetCureTypeStatus(DC.MAGIC) end,
                        set = function()
                            D:SetCureOrder (DC.MAGIC);
                        end,
                        disabled = function() return not D.Status.CuringSpells[DC.MAGIC] end,
                        order = 141
                    },
                    CureEnemyMagic = {
                        type = "toggle",
                        name = "  "..L["MAGICCHARMED"],
                        desc = L["OPT_MAGICCHARMEDCHECK_DESC"],
                        get = function() return D:GetCureTypeStatus(DC.ENEMYMAGIC) end,
                        set = function()
                            D:SetCureOrder (DC.ENEMYMAGIC);
                        end,
                        disabled = function() return not D.Status.CuringSpells[DC.ENEMYMAGIC] end,
                        order = 142
                    },
                    CurePoison = {
                        type = "toggle",
                        name = "  "..L["POISON"],
                        desc = L["OPT_POISONCHECK_DESC"],
                        get = function() return D:GetCureTypeStatus(DC.POISON) end,
                        set = function()
                            D:SetCureOrder (DC.POISON);
                        end,
                        disabled = function() return not D.Status.CuringSpells[DC.POISON] end,
                        order = 143
                    },
                    CureDisease = {
                        type = "toggle",
                        name = "  "..L["DISEASE"],
                        desc = L["OPT_DISEASECHECK_DESC"],
                        get = function() return D:GetCureTypeStatus(DC.DISEASE) end,
                        set = function()
                            D:SetCureOrder (DC.DISEASE);
                        end,
                        disabled = function() return not D.Status.CuringSpells[DC.DISEASE] end,
                        order = 144
                    },
                    CureCurse = {
                        type = "toggle",
                        name = "  "..L["CURSE"],
                        desc = L["OPT_CURSECHECK_DESC"],
                        get = function() return D:GetCureTypeStatus(DC.CURSE) end,
                        set = function()
                            D:SetCureOrder (DC.CURSE);
                        end,
                        disabled = function() return not D.Status.CuringSpells[DC.CURSE] end,
                        order = 145
                    },
                    CureCharmed = {
                        type = "toggle",
                        name = "  "..L["CHARM"],
                        desc = L["OPT_CHARMEDCHECK_DESC"],
                        get = function() return D:GetCureTypeStatus(DC.CHARMED) end,
                        set = function()
                            D:SetCureOrder (DC.CHARMED);
                        end,
                        disabled = function() return not D.Status.CuringSpells[DC.CHARMED] end,
                        order = 146
                    },
                }
            }, -- }}}

            DebuffSkip = {
                -- {{{
                type = "group",
                hidden = function () return not D:IsEnabled(); end,
                disabled = function () return not D:IsEnabled(); end,
                name = D:ColorText(L["OPT_DEBUFFFILTER"], "FF99CCAA"),
                desc = L["OPT_DEBUFFFILTER_DESC"],
                order = 6,
                childGroups= "select",
                args = {}
            }, -- }}}

            Macro = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_MACROOPTIONS"], "FFCC99BB"),
                desc = L["OPT_MACROOPTIONS_DESC"],
                order = 7,
                disabled = function() return  not D.Status.Enabled or D.Status.Combat end,
                args = {
                    description = {name = L["OPT_MACROOPTIONS_DESC"], order = 1, type = "description"},
                    SetKey = {
                        type = "keybinding",
                        name = L["OPT_MACROBIND"],
                        desc = L["OPT_MACROBIND_DESC"],
                        get = function ()
                            local key = (GetBindingKey(D.CONF.MACROCOMMAND));
                            D.db.global.MacroBind = key;
                            return key;
                        end,
                        set = function (info,key)
                            if key ~= "BUTTON1" and key ~= "BUTTON2" then
                                D:SetMacroKey ( key );
                            end
                        end,
                        disabled = function () return D.profile.DisableMacroCreation end,
                        order = 200,
                    },
                    NoKeyWarn = {
                        type = "toggle",
                        name = L["OPT_NOKEYWARN"],
                        desc = L["OPT_NOKEYWARN_DESC"],
                        disabled = function () return D.profile.DisableMacroCreation end,
                        order = 300
                    },
		    AllowMacroEdit = {
                        type = "toggle",
                        name = L["OPT_ALLOWMACROEDIT"],
                        desc = L["OPT_ALLOWMACROEDIT_DESC"],
                        disabled = function () return D.profile.DisableMacroCreation end,
                        order = 350
                    },
                    DisableMacroCreation = {
                        type = "toggle",
                        name = L["OPT_DISABLEMACROCREATION"],
                        desc = L["OPT_DISABLEMACROCREATION_DESC"],
                        order = 400
                    }
                }
            }, -- }}}

            About = {
                type = "group",
                name = D:ColorText(L["OPT_ABOUT"], "FFFFFFFF"),
                order = -1,
                args = {
                    -- Decursive vxx by x released on XX
                    Title = {
                        type = 'description',
                        name = (
                                    "\n\n\n\nDecursive |cFFDD0000 v%s |r by |cFFDD0000 %s |r released on |cFFDD0000 %s |r"..
                                    "\n\n      |cFF55DDDD %s |r"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"
                                ):format(
                                    "@project-version@", "@project-author@", ("@project-date-iso@"):sub(1,10),
                                    L["ABOUT_NOTES"],
                                    L["ABOUT_LICENSE"],         GetAddOnMetadata("Decursive", "X-License"),
                                    L["ABOUT_SHAREDLIBS"],      GetAddOnMetadata("Decursive", "X-Embeds"),
                                    L["ABOUT_OFFICIALWEBSITE"], GetAddOnMetadata("Decursive", "X-Website"),
                                    L["ABOUT_AUTHOREMAIL"],     GetAddOnMetadata("Decursive", "X-eMail"),
                                    L["ABOUT_CREDITS"],         GetAddOnMetadata("Decursive", "X-Credits")
                                ),
                        order = 0,
                    },
                    Sep1 = {
                        type = "header",
                        name = "",
                        order = 5,
                    },
                    CheckVersions = {
                        type = "execute",
                        name = L["OPT_CHECKOTHERPLAYERS"],
                        desc = L["OPT_CHECKOTHERPLAYERS_DESC"],
                        hidden = function () return not DC.COMMAVAILABLE; end,
                        disabled = function () return InCombatLockdown() or GetTime() - T.LastVCheck < 60; end,
                        func = function () if D:AskVersion() then D.versions = false; end GameTooltip:Hide(); end,
                        order = 10,
                    },
                    VersionsDisplay = {
                        type = "description",
                        name = D.ReturnVersions,
                        hidden = function () return not D.versions; end,
                        order = 30,
                    },
                   
                }
            }
        },
    } -- }}}
end

local function GetOptions()

    local options = GetStaticOptions();

    local CureCheckBoxes = {
        [DC.ENEMYMAGIC]     = options.args.CureOptions.args.CureEnemyMagic,
        [DC.MAGIC]          = options.args.CureOptions.args.CureMagic,
        [DC.CURSE]          = options.args.CureOptions.args.CureCurse,
        [DC.POISON]         = options.args.CureOptions.args.CurePoison,
        [DC.DISEASE]        = options.args.CureOptions.args.CureDisease,
        [DC.CHARMED]        = options.args.CureOptions.args.CureCharmed,
    }

    -- Add the green number infront of the checkboxes
    for Type, CheckBox in pairs(CureCheckBoxes) do
        D:SetCureCheckBoxNum(Type, CheckBox);
    end

    -- create per class filters menus
    options.args.DebuffSkip.args = D:CreateDropDownFiltersMenu();
    -- create MUF color configuration menus
    options.args.MicroFrameOpt.args.MUFsColors.args = D:CreateDropDownMUFcolorsMenu();
    -- create MUF's mouse buttons configuration menus
    options.args.MicroFrameOpt.args.MUFsMouseButtons.args = D:CreateModifierOptionMenu();

    -- Create profile options
    options.args.general.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(D.db);
    options.args.general.args.profiles.order = -1;
    options.args.general.args.profiles.inline = true;
    options.args.general.args.profiles.hidden = function() return not D:IsEnabled(); end;
    options.args.general.args.profiles.disabled = function() return D.Status.Combat or not D:IsEnabled(); end;

    return options;

end

function D:ExportOptions ()
    -- Export the option table to Blizz option UI and to Ace3 option UI

    LibStub("AceConfig-3.0"):RegisterOptionsTable(D.name,  GetOptions, 'dcr');

    
    
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(D.name, D.name, nil, "general");

    local SubGroups_ToBlizzOptions = {
        [D:ColorText(L["OPT_LIVELIST"], "FF22EE33")] = "livelistoptions",
        [D:ColorText(L["OPT_MESSAGES"], "FF229966")] = "MessageOptions",
        [D:ColorText(L["OPT_MFSETTINGS"], "FFBBCC33")] = "MicroFrameOpt",
        [D:ColorText(L["OPT_CURINGOPTIONS"], "FFFF5533")] = "CureOptions",
        [D:ColorText(L["OPT_DEBUFFFILTER"], "FF99CCAA")] = "DebuffSkip",
        [D:ColorText(L["OPT_MACROOPTIONS"], "FFCC99BB")] = "Macro",
        [D:ColorText(L["OPT_ABOUT"], "FFFFFFFF")] = "About",
    };

    for key,value in pairs(SubGroups_ToBlizzOptions) do
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(D.name, key, D.name, value);
    end
end



function D:GetCureTypeStatus (Type)
    return D.classprofile.CureOrder[Type] and D.classprofile.CureOrder[Type] > 0;
end

local TypesToUName = {
    [DC.ENEMYMAGIC]     = "MAGICCHARMED",
    [DC.MAGIC]          = "MAGIC",
    [DC.CURSE]          = "CURSE",
    [DC.POISON]         = "POISON",
    [DC.DISEASE]        = "DISEASE",
    [DC.CHARMED]        = "CHARM",
}

local CureCheckBoxes = false;
function D:SetCureCheckBoxNum (Type, checkBox)
    -- add the number in green before the name if we have a spell available and if we checked the box
    if (D:GetCureTypeStatus(Type)) then
        checkBox.name = D:ColorText(D.classprofile.CureOrder[Type], "FF00FF00") .. " " .. L[TypesToUName[Type]];
    else
        checkBox.name = "  " .. L[TypesToUName[Type]];
    end

end

function D:CheckCureOrder ()

    D:Debug("Verifying CureOrder...");

    local TempTable = {};
    local AuthorizedKeys = {
        [DC.ENEMYMAGIC]   = 1,
        [DC.MAGIC]          = 2,
        [DC.CURSE]          = 3,
        [DC.POISON]         = 4,
        [DC.DISEASE]        = 5,
        [DC.CHARMED]        = 6,
    };
    local AuthorizedValues = {
        [false] = true; -- LOL Yes, it's TRUE tnat FALSE is an authorized value xD
        -- Other <0  values are used when there used to be a spell...
        [1]     = DC.ENEMYMAGIC,
        [-11]   = DC.ENEMYMAGIC,
        [2]     = DC.MAGIC,
        [-12]   = DC.MAGIC,
        [3]     = DC.CURSE,
        [-13]   = DC.CURSE,
        [4]     = DC.POISON,
        [-14]   = DC.POISON,
        [5]     = DC.DISEASE,
        [-15]   = DC.DISEASE,
        [6]     = DC.CHARMED,
        [-16]   = DC.CHARMED,
    };
    local GivenValues = {};


    -- add missing entries...
    for key, value in pairs(AuthorizedKeys) do
        if not D.classprofile.CureOrder[key] then
            D.classprofile.CureOrder[key] = false;
        end
    end

    -- Validate existing entries
    local WrongValue = 0;
    for key, value in pairs(D.classprofile.CureOrder) do

        if (AuthorizedKeys[key]) then -- is this a correct type ?
            if (AuthorizedValues[value] and not GivenValues[value]) then -- is this value authorized and not already given?
                GivenValues[value] = true;

            elseif (value) then -- FALSE is the only value that can be given several times
                D:Debug("Incoherent value for (key, value, Duplicate?)", key, value, GivenValues[value]);

                D.classprofile.CureOrder[key] = -20 - WrongValue; -- if the value was wrong or already given to another type
                WrongValue = WrongValue + 1;
            end
        else
            D.classprofile.CureOrder[key] = nil; -- remove it from the table
        end
    end

end

function D:SetCureOrder (ToChange)


    local CureOrder = D.classprofile.CureOrder;
    local tmpTable = {};
    D:Debug("SetCureOrder called for prio ", CureOrder[ToChange]);

    if (ToChange) then
        -- if there is a positive value, it means we want to disable this type, set it to false (see GetCureTypeStatus())
        if (D:GetCureTypeStatus(ToChange)) then
            CureOrder[ToChange] = false;
            D:Debug("SetCureOrder(): set to false");
        else -- else if there was no value (or a negative one), add this type at the end (see GetCureTypeStatus())
            CureOrder[ToChange] = 20; -- this will cause the spell to be added at the end
            D:Debug("SetCureOrder(): set to 20");
        end
    end

    local LostSpells = {}; -- an orphanage for the lost spells :'(
    local FoundSpell = 0; -- we wouldn't need that if #table was always returning something meaningful...

    -- re-compute the position of each spell type
    for Type, Num in pairs (CureOrder) do

        -- if we have a spell or if we did not unchecked the checkbox (note the difference between "checked" and "not unchecked")
        if (D.Status.CuringSpells[Type] and CureOrder[Type]) then
            tmpTable[abs(CureOrder[Type])] = Type; -- CureOrder[Type] can have a <0 value if the spell was lost
            FoundSpell = FoundSpell + 1;
        elseif (CureOrder[Type]) then -- if we don't have a spell for this type
            LostSpells[abs(CureOrder[Type])] = Type;  -- save the position
        end
    end

   -- take care of the lost spells here
   -- Sort the lost spells so that they can be readded in the correct order
   LostSpells =  D:tSortUsingKeys(LostSpells);

   -- Place the lost spells after the found ones but with <0 values so they
   -- can be readded later using their former priorities
   local AvailableSpot = (FoundSpell + 10 + 1) * -1; -- we add 10 so that they'll be re-added after any not-lost spell...

   -- D:PrintLiteral(LostSpells);
   for FormerPrio, Type in ipairs(LostSpells) do
       CureOrder[Type] = AvailableSpot
       AvailableSpot = AvailableSpot - 1;
   end

    -- we sort the tables
    tmpTable = D:tSortUsingKeys(tmpTable);

    -- apply the new priority to the types we can handle, leave their negative value to the others
    for Num, Type in ipairs (tmpTable) do
        CureOrder[Type] = Num;
    end

    -- create / update the ReversedCureOrder table (prio => type, ..., )
    D.Status.ReversedCureOrder = D:tReverse(CureOrder);

    -- Create spell priority table
    D.Status.CuringSpellsPrio = {};

    -- some shortcuts
    local CuringSpellsPrio = D.Status.CuringSpellsPrio;
    local ReversedCureOrder = D.Status.ReversedCureOrder;
    local CuringSpells  = D.Status.CuringSpells;

    local DebuffType;
    -- set the priority for each spell, Micro frames will use this to determine which button to map
    local affected = 1;
    for i=1,6 do
        DebuffType = ReversedCureOrder[i]; -- there is no gap between indexes
        if (DebuffType and not CuringSpellsPrio[ CuringSpells[DebuffType] ] ) then
            CuringSpellsPrio[ CuringSpells[DebuffType] ] = affected;
            affected = affected + 1;
        end
    end

    -- Set the spells shortcut (former decurse key)
    D:UpdateMacro();
    D:Debug("Spell changed");
    D.Status.SpellsChanged = GetTime();

    -- If no spell is selected or none is available set Decursive icon to off
    if FoundSpell ~= 0 then
        D:Debug("icon changed to ON");
        D:SetIcon(DC.IconON);
    else
        D:Debug("icon changed to OFF");
        D:SetIcon(DC.IconOFF);
    end



end

function D:ShowHideDebuffsFrame ()

    if InCombatLockdown() or not D.DcrFullyInitialized then
        return
    end

    D.profile.ShowDebuffsFrame = not D.profile.ShowDebuffsFrame;

    if (D.MFContainer:IsVisible()) then
        D.MFContainer:Hide();
        D.profile.ShowDebuffsFrame = false;
    else
        D.MFContainer:Show();
        D.MFContainer:SetScale(D.profile.DebuffsFrameElemScale);
        D.MicroUnitF:Place ();
        D.profile.ShowDebuffsFrame = true;
        D.MicroUnitF:Delayed_MFsDisplay_Update ();
    end

    if (not D.profile.ShowDebuffsFrame) then
        D:CancelDelayedCall("Dcr_MUFupdate");
    else
        D:ScheduleRepeatedCall("Dcr_MUFupdate", D.DebuffsFrame_Update, D.profile.DebuffsFrameRefreshRate, D);
    end

    -- set Icon
    if not D.Status.HasSpell or D.profile.HideLiveList and not D.profile.ShowDebuffsFrame then
        D:SetIcon(DC.IconOFF);
    else
        D:SetIcon(DC.IconON);
    end

end

function D:ShowHideTextAnchor() --{{{
    if (DecursiveAnchor:IsVisible()) then
        DecursiveAnchor:Hide();
    else
        DecursiveAnchor:Show();
    end
end --}}}

function D:ChangeTextFrameDirection(bottom) --{{{
    local button = DecursiveAnchorDirection;
    if (bottom) then
        DecursiveTextFrame:SetInsertMode("BOTTOM");
        button:SetText("v");
    else
        DecursiveTextFrame:SetInsertMode("TOP");
        button:SetText("^");
    end
end --}}}

do -- All this block predates Ace3, it could be recoded in a much more effecicent and cleaner way now (memory POV) thanks to the "info" table given to all callbacks in Ace3.
   -- A good example would be the code creating the MUF color configuration menu or the click assigment settings right after this block.

    local DebuffsSkipList, DefaultDebuffsSkipList, skipByClass, AlwaysSkipList, DefaultSkipByClass;

    local spacer = function(num) return { name="",type="header", order = 100 + num } end;

    local RemoveFunc = function (handler)
        D:Debug("Removing '%s'...", handler["Debuff"]);


        D:tremovebyval(D.profile.DebuffsSkipList, handler["Debuff"])

        skipByClass  = D.profile.skipByClass;
        for class, debuffs in pairs (skipByClass) do
            skipByClass[class][handler["Debuff"]] = nil;
        end

        D.profile.DebuffAlwaysSkipList[handler["Debuff"]] = nil; -- remove it from the table

        D:Debug("%s removed!", handler["Debuff"]);

    end

    local AddToAlwaysSkippFunc = function (handler, v)
        AlwaysSkipList[handler["Debuff"]] = v;
    end

    local ResetFunc = function (handler)
        local DebuffName = handler["Debuff"];

        D:Debug("Resetting '%s'...", handler["Debuff"]);

        skipByClass  = D.profile.skipByClass;
        for Classe, Debuffs in pairs(skipByClass) do
            if (DefaultSkipByClass[Classe][DebuffName]) then
                skipByClass[Classe][DebuffName] = true;
            else
                skipByClass[Classe][DebuffName] = nil; -- Removes it
            end
        end
    end

    local function ClassCheckbox (Class, DebuffName, num)
        local CheckedByDefault = false;

        if (DefaultSkipByClass[Class][DebuffName]) then
            CheckedByDefault = true;
        end

        return {
            type = "toggle",
            name = D:ColorText( LC[Class], "FF"..DC.HexClassColor[Class]) ..
            (CheckedByDefault and D:ColorText("  *", "FFFFAA00") or ""),
            desc = str_format(L["OPT_AFFLICTEDBYSKIPPED"], LC[Class], DebuffName) ..
            (CheckedByDefault and D:ColorText(L["OPT_DEBCHECKEDBYDEF"], "FFFFAA00") or "");
            handler = {
                ["Debuff"]=DebuffName,
                ["Class"]=Class,
                ["get"] = function  (handler)
                    skipByClass = D.profile.skipByClass;
                    return skipByClass[handler["Class"]][handler["Debuff"]]; 
                end,
                ["set"] = function  (handler, info, v)
                    skipByClass = D.profile.skipByClass;
                    skipByClass[handler["Class"]][string.trim(handler["Debuff"])] = v;
                end
            },
            get = "get",
            set = "set",
            order = 100 + num;
        }
    end

    local function ClassValues(DebuffName)
        local values = {};

        for i, class in pairs (DC.ClassNumToUName) do
            values[i] = D:ColorText( LC[class], "FF"..DC.HexClassColor[class]) ..
            (DefaultSkipByClass[class][DebuffName] and D:ColorText("  *", "FFFFAA00") or "");
        end

        --D:Debug(unpack (values));
        return values;

    end

    local function DebuffSubmenu (DebuffName, num)
        local classes = {};

        classes["header"] = {
            type = "description",
            name = (L["OPT_FILTEROUTCLASSES_FOR_X"]):format(D:ColorText(DebuffName, "FF77CC33")),
            order = 0,
        }

        skipByClass = D.profile.skipByClass;
         classes[DebuffName] = {
             type = "multiselect",
             name = "",
             --desc = "test desc",
             values = ClassValues(DebuffName),
             order = num,
             get = "get",
             set = "set",

             handler = {
                ["Debuff"]=DebuffName,
                ["get"] = function  (handler, info, Classnum)
                    return skipByClass[DC.ClassNumToUName[Classnum]][handler["Debuff"]]; 
                end,
                ["set"] = function  (handler, info, Classnum, state)
                    skipByClass[DC.ClassNumToUName[Classnum]][string.trim(handler["Debuff"])] = state;
                end
            };

         };

        --classes["spacer1"] = spacer(num);

        num = num + 1;

        classes["PermIgnore"] = {
            type = "toggle",
            name = D:ColorText(L["OPT_ALWAYSIGNORE"], "FFFF9900"),
            desc = str_format(L["OPT_ALWAYSIGNORE_DESC"], DebuffName),
            handler = {
                ["Debuff"] = DebuffName,
                ["get"] = function (handler)
                    return AlwaysSkipList[handler["Debuff"]];
                end,
                ["set"] = function (handler,info,v) AddToAlwaysSkippFunc(handler,v) end,
            },
            get = "get",
            set = "set",
            order = 100 + num;

        };

        num = num + 1;

        --classes["spacer1p5"] = spacer(num);

        num = num + 1;

        classes["remove"] = {
            type = "execute",
            name = D:ColorText(L["OPT_REMOVETHISDEBUFF"], "FFFF0000"),
            desc = str_format(L["OPT_REMOVETHISDEBUFF_DESC"], DebuffName),
            handler = {
                ["Debuff"] = DebuffName,
                ["remove"] = RemoveFunc,
            },
            confirm = true,
            func = "remove",
            order = 100 + num,

        };

        num = num + 1;

        --classes["spacer2"] = spacer(num);

        num = num + 1;

        local resetDisabled = false;

        if (not D:tcheckforval(DefaultDebuffsSkipList, DebuffName)) then
            resetDisabled = true;
        end

        classes["reset"] = {
            type = "execute",
            -- the two statements below are like (()?:) in C
            name = not resetDisabled and D:ColorText(L["OPT_RESETDEBUFF"], "FF11FF00") or L["OPT_RESETDEBUFF"],
            desc = not resetDisabled and str_format(L["OPT_RESETDTDCRDEFAULT"], DebuffName) or L["OPT_USERDEBUFF"],
            handler = {
                ["Debuff"] = DebuffName,
                ["reset"] = ResetFunc,
            },
            func = "reset";
            disabled = resetDisabled,
            order = 100 + num;

        };

        num = num + 1;

        --classes["spacer3"] = spacer(num);

        return classes;
    end



    --Entry Templates
    local function DebuffEntryGroup (DebuffName, num)
        local IsADefault = D:tcheckforval(DefaultDebuffsSkipList, DebuffName);
        return {
            type = "group",
            name = IsADefault and D:ColorText(DebuffName, "FFFFFFFF") or D:ColorText(DebuffName, "FF99FFFF"),
            desc = L["OPT_DEBUFFENTRY_DESC"],
            order = num,
            args = DebuffSubmenu(DebuffName, num),
        }
    end

    local AddFunc = function (NewDebuff)
        if (not D:tcheckforval(DebuffsSkipList, NewDebuff)) then
            table.insert(DebuffsSkipList, strtrim(NewDebuff));
            D:Debug("'%s' added to debuff skip list", strtrim(NewDebuff));
        end
    end


    local ReAddDefaultsDebuffs = function ()

        for _, Debuff in ipairs(DefaultDebuffsSkipList) do

            if (not D:tcheckforval(DebuffsSkipList, Debuff)) then

                table.insert(DebuffsSkipList, Debuff);

                ResetFunc({["Debuff"] = Debuff});

            end
        end

    end

    local CheckDefaultsPresence = function ()
        for _, Debuff in ipairs(DefaultDebuffsSkipList) do
            if (not D:tcheckforval(DebuffsSkipList, Debuff)) then

                return false;
            end
        end
        return true;
    end

    local DebuffHistTable = {};
    local First = "";

    local GetHistoryDebuff = function ()
        local DebuffName, exists, index;

        for index=1, DC.DebuffHistoryLength do
            DebuffName, exists = D:Debuff_History_Get (index, true);

            if not exists or index == 1 and DebuffName == First then
                break;
            end

            if index == 1 then
                First = DebuffName;
            end

            DebuffHistTable[index] = DebuffName;
            index = index + 1;
        end

        return DebuffHistTable;
    end

    function D:CreateDropDownFiltersMenu()
        DebuffsSkipList             = D.profile.DebuffsSkipList;
        DefaultDebuffsSkipList      = D.defaults.profile.DebuffsSkipList;

        skipByClass                 = D.profile.skipByClass;
        AlwaysSkipList              = D.profile.DebuffAlwaysSkipList;
        DefaultSkipByClass          = D.defaults.profile.skipByClass;

        local DebuffsSubMenu = {};
        local num = 1;


        for _, Debuff in ipairs(DebuffsSkipList) do
            DebuffsSubMenu[str_gsub(Debuff, " ", "")] = DebuffEntryGroup(Debuff, num);
            num = num + 1;
        end

        DebuffsSubMenu["description"] = {
            type = "description",
            name = L["OPT_DEBUFFFILTER_DESC"],
            order = 0,
        };
        num = num + 1;

        DebuffsSubMenu["add"] = {
            type = "input",
            name = D:ColorText(L["OPT_ADDDEBUFF"], "FFFF3300"),
            desc = L["OPT_ADDDEBUFF_DESC"],
            usage = L["OPT_ADDDEBUFF_USAGE"],
            get = false,
            set = function(info,value) AddFunc(value) end,
            order = 100 + num,
        };

        num = num + 1;

        DebuffsSubMenu["addFromHist"] = {
            type = "select",
            name = L["OPT_ADDDEBUFFFHIST"], --"Add from Debuff history",
            desc = L["OPT_ADDDEBUFFFHIST_DESC"], --"Add a recently seen debuff",
            disabled = function () GetHistoryDebuff(); return (#DebuffHistTable == 0) end,
            values = GetHistoryDebuff;
            get = function() GetHistoryDebuff(); return false; end,
            set = function(info,value)
                AddFunc(D:RemoveColor(GetHistoryDebuff()[value])); end,
            order = 100 + num,
            --validate = DebuffHistTable, --GetHistoryDebuff(),
        };


        local ReaddIsDisabled = CheckDefaultsPresence();
        num = num + 1;
        DebuffsSubMenu["ReAddDefaults"] = {
            type = "execute",
            name = not ReaddIsDisabled and D:ColorText(L["OPT_READDDEFAULTSD"], "FFA75728") or L["OPT_READDDEFAULTSD"],
            desc = not ReaddIsDisabled and L["OPT_READDDEFAULTSD_DESC1"]
            or L["OPT_READDDEFAULTSD_DESC2"],
            func = ReAddDefaultsDebuffs,
            disabled = CheckDefaultsPresence;
            order = 100 + num,
        };

        return DebuffsSubMenu;
    end
end

do

    local tonumber = _G.tonumber;
    local L_MF_colors = {};

    local function GetNameAndDesc (ColorReason) -- {{{
        local name, desc;

        L_MF_colors = D.profile.MF_colors;

        if (type(ColorReason) == "number" and ColorReason <= 6) then

            name = D:ColorText(DC.AvailableButtonsReadable[D.db.global.AvailableButtons[ColorReason] ], D:NumToHexColor(L_MF_colors[ColorReason]));
            desc = (L["COLORALERT"]):format(DC.AvailableButtonsReadable[D.db.global.AvailableButtons[ColorReason] ]);

        elseif (type(ColorReason) == "number")      then
            local Text = "";

            if (ColorReason == DC.NORMAL)           then
                Text =  L["NORMAL"];

            elseif (ColorReason == DC.ABSENT)       then
                Text =  L["MISSINGUNIT"];

            elseif (ColorReason == DC.FAR)          then
                Text =  L["TOOFAR"];

            elseif (ColorReason == DC.STEALTHED)    then
                Text =  L["STEALTHED"];

            elseif (ColorReason == DC.BLACKLISTED)  then
                Text =  L["BLACKLISTED"];

            elseif (ColorReason == DC.CHARMED_STATUS) then
                Text =  L["CHARM"];
            end

            name = ("%s %s"):format(L["UNITSTATUS"], D:ColorText(Text, D:NumToHexColor(L_MF_colors[ColorReason])) );
            desc = (L["COLORSTATUS"]):format(Text);

        elseif (type(ColorReason) == "string") then

            name = L[ColorReason];

            if ColorReason == "COLORCHRONOS" then
                desc = L["COLORCHRONOS_DESC"];
            else
                desc = "This is abnormal!";
            end
        end

        return {name, desc};
    end -- }}}

    local retrieveColorReason = function(info)
        local ColorReason = str_sub(info[#info], 2);

        if tonumber(ColorReason) then 
            return tonumber(ColorReason);
        else
            return ColorReason;
        end
    end

    local GetName = function (info)
        return GetNameAndDesc(retrieveColorReason(info))[1];
    end

    local GetDesc = function (info)
        return GetNameAndDesc(retrieveColorReason(info))[2];
    end

    local GetOrder = function (info)
        local ColorReason = retrieveColorReason(info);
        return 100 + (type(ColorReason) == "number" and ColorReason or 2048);
    end

    local function GetColor (info)
        return unpack(D.profile.MF_colors[retrieveColorReason(info)]);
    end

    local function SetColor (info, r, g, b, a)

        local ColorReason = retrieveColorReason(info);

        D.profile.MF_colors[ColorReason] = {r, g, b, (a and a or 1)};
        D.MicroUnitF:RegisterMUFcolors();
        L_MF_colors = D.profile.MF_colors;

        D.MicroUnitF:Delayed_Force_FullUpdate();

        D:Debug("MUF color setting %d changed.", ColorReason);
    end

    local ColorPicker = {
        type = "color",
        name = GetName,
        desc = GetDesc,
        hasAlpha = true,
        order = GetOrder,

        get = GetColor,
        set = SetColor,
    };

    function D:CreateDropDownMUFcolorsMenu()
        L_MF_colors = D.profile.MF_colors;

        local MUFsColorsSubMenu = {};

        for ColorReason, Color in pairs(L_MF_colors) do

            if not L_MF_colors[ColorReason][4] then
                D.profile.MF_colors[ColorReason][4] = 1;
            end

            -- add a separator for the different color typs when necessary.
            if (type(ColorReason) == "number" and (ColorReason - 2) == 6) or (type(ColorReason) == "string" and ColorReason == "COLORCHRONOS") then
                MUFsColorsSubMenu["S" .. ColorReason] = {
                    type = "header",
                    name = "",
                    order = function (info) return GetOrder(info) - 1 end,
                }
                --D:Debug("Created space ", "Space" .. ColorReason, "at ", MUFsColorsSubMenu["S" .. ColorReason].order);
            end


            MUFsColorsSubMenu["c"..ColorReason] = ColorPicker;
            
        end

        return MUFsColorsSubMenu;
    end
end

-- Modifiers order choosing dynamic menu creation
do

    local orderStart = 152;
    local tonumber = _G.tonumber;

    local TempTable = {};
    local i = 1;

    local function retrieveKeyComboNum (info)
        return tonumber(str_sub(info[#info], 9));
        -- #"KeyCombo" == 8
    end

    local function GetValues (info) -- {{{

        if retrieveKeyComboNum (info) == 1 then
            table.wipe(TempTable);

            for i=1, #D.db.global.AvailableButtons do
                TempTable[i] = D:ColorText(DC.AvailableButtonsReadable[D.db.global.AvailableButtons[i]],
                        i < 7 and D:NumToHexColor(D.profile.MF_colors[i]) -- defined priorities
                        or (i >= #D.db.global.AvailableButtons - 1 and "FFFFFFFF" -- target and focus
                        or "FFBBBBBB") -- other unused buttons
                    );
            end
        end

        return TempTable;
    end -- }}}

    local function GetOrder (info)
        return orderStart + retrieveKeyComboNum (info);
    end

    local OptionPrototype = {
        -- {{{
        type = "select",
             name = function (info)
                 if not retrieveKeyComboNum (info) then return "" end -- needed because when called by command line, info is set to the parent

                 if retrieveKeyComboNum (info) < #D.db.global.AvailableButtons - 1 then
                     return "";
                 elseif  retrieveKeyComboNum (info) == #D.db.global.AvailableButtons - 1 then
                     return L["OPT_MUFTARGETBUTTON"];
                 else
                     return L["OPT_MUFFOCUSBUTTON"];
                 end
             end,
             values = GetValues,
             order = GetOrder,
             get = function (info)
                 return retrieveKeyComboNum (info);
             end,
             set = function (info, value)

                 local ThisKeyComboNum = retrieveKeyComboNum (info);


                 if value ~= ThisKeyComboNum then -- we would destroy the table

                     D:tSwap(D.db.global.AvailableButtons, ThisKeyComboNum, value);

                     -- force all MUFs to update their attributes
                     D.Status.SpellsChanged = GetTime();
                 end
             end,
             style = "dropdown",
             -- }}}
    };

    function D:CreateModifierOptionMenu ()
        local key_Combos_Select = {
            -- {{{
            ClicksAdssigmentsDesc = {
                type = "description",
                name = L["OPT_MUFMOUSEBUTTONS_DESC"],
                order = 151,
            },
            ResetClicksAdssigments = {
                type = "execute",
                confirm = true,
                name = L["OPT_RESETMUFMOUSEBUTTONS"],
                desc = L["OPT_RESETMUFMOUSEBUTTONS_DESC"],
                func = function ()
                    table.wipe(D.db.global.AvailableButtons);
                    D:tcopy(D.db.global.AvailableButtons, D.defaults.global.AvailableButtons);
                end,
                order = -1,
            },
            -- }}}
        };

        for i = 1, 6 do
            key_Combos_Select["KeyCombo" .. i] = OptionPrototype;
        end

        -- create choice munu for targeting (it's always the last but one available button)
        key_Combos_Select["KeyCombo" .. #D.db.global.AvailableButtons - 1] = OptionPrototype;
        -- create choice munu for focusing (it's always the last available button)
        key_Combos_Select["KeyCombo" .. #D.db.global.AvailableButtons] = OptionPrototype;

        return key_Combos_Select;
    end

end

-- to test on 2.3 : /script D:PrintLiteral(GetBindingAction(D.db.global.MacroBind));
-- to test on 2.3 : /script D:PrintLiteral(GetBindingKey(D.CONF.MACROCOMMAND));

function D:SetMacroKey ( key )

    -- if the key is already correctly mapped, return here.
    --if (key and key == D.db.global.MacroBind and GetBindingAction(key) == D.CONF.MACROCOMMAND) then
    if D.profile.DisableMacroCreation or key and key == D.db.global.MacroBind and D:tcheckforval({GetBindingKey(D.CONF.MACROCOMMAND)}, key) then -- change for 2.3 where GetBindingAction() is no longer working
        return;
    end

    -- if the current set key is currently mapped to Decursive macro (it means we are changing the key)
    --if (D.profile.MacroBind and GetBindingAction(D.profile.MacroBind) == D.CONF.MACROCOMMAND) then
    if (D.db.global.MacroBind and D:tcheckforval({GetBindingKey(D.CONF.MACROCOMMAND)}, D.db.global.MacroBind) ) then -- change for 2.3 where GetBindingAction() is no longer working

        -- clearing redudent mapping to Decursive macro.
        local MappedKeys = {GetBindingKey(D.CONF.MACROCOMMAND)};
        for _, key in pairs(MappedKeys) do
            D:Debug("Unlinking [%s]", key);
            SetBinding(key, nil); -- clear the binding
        end

        -- Restore previous key state
        if (D.profile.PreviousMacroKeyAction) then
            D:Debug("Previous key action restored:", D.profile.PreviousMacroKeyAction);
            if not SetBinding(D.db.global.MacroBind, D.profile.PreviousMacroKeyAction) then
                --  /script SetBinding ("BUTTON1", "CAMERAORSELECTORMOVE"); to communicate to people who accidently set BUUTON1 to our macro.
                D:Debug("Restoration failed");
            end
        end
    end


    if (key) then
        if (GetBindingAction(key) ~= "" and GetBindingAction(key) ~= D.CONF.MACROCOMMAND) then
            -- save current key assignement
            D.profile.PreviousMacroKeyAction = GetBindingAction(key)
            D:Debug("Old key action saved:", D.profile.PreviousMacroKeyAction);
            D:errln(L["MACROKEYALREADYMAPPED"], key, D.profile.PreviousMacroKeyAction);
        else
            D.profile.PreviousMacroKeyAction = false;
            D:Debug("Old key action not saved because it was mapped to nothing");
        end

        -- set
        if (SetBindingMacro(key, D.CONF.MACRONAME)) then
            D.db.global.MacroBind = key;
            D:Println(L["MACROKEYMAPPINGSUCCESS"], key);
        else
            D:errln(L["MACROKEYMAPPINGFAILED"], key);
        end
    else
        D.db.global.MacroBind = false;
        if D.profile.NoKeyWarn and not GetBindingKey(D.CONF.MACROCOMMAND) then
            D:errln(L["MACROKEYNOTMAPPED"]);
        end
    end

    -- save the bindings to disk
    if GetCurrentBindingSet()==1 or GetCurrentBindingSet()==2 then -- GetCurrentBindingSet() may return strange values when the game is loaded without WTF folder.
        SaveBindings(GetCurrentBindingSet());
    end

end


function D:AutoHideShowMUFs ()

   -- This function cannot do anything if we are fighting
    if (InCombatLockdown()) then
        -- if we are fighting, postpone the call
        D:AddDelayedFunctionCall (
        "CheckIfHideShow", self.AutoHideShowMUFs,
        self);
        return false;
    end

    if D.profile.AutoHideMUFs == 1 then
        return;
    else
        -- if we want to hide the MUFs when in solo or not in raid
        local InGroup = (GetNumRaidMembers() ~= 0 or (D.profile.AutoHideMUFs ~= 3 and GetNumPartyMembers() ~= 0) );
        D:Debug("AutoHideShowMUFs, InGroup: ", InGroup);

        -- if we are not in such a group
        if not InGroup then
            -- if the frame is displayed
            if D.profile.ShowDebuffsFrame then
                -- hide it
                D:ShowHideDebuffsFrame ();
            end
        else
            -- if we are in a group
            -- if the frame is not displayed
            if not D.profile.ShowDebuffsFrame then
                -- show it
                D:ShowHideDebuffsFrame ();
            end
        end
    end
end

function D:QuickAccess (CallingObject, button) -- {{{
    --D:Debug("clicked");

    if (not CallingObject) then
        CallingObject = "noframe";
    end

    if (button == "RightButton" and not IsShiftKeyDown()) then

        if (not IsAltKeyDown()) then
            D:Println(L["DEWDROPISGONE"]);
        else
            LibStub("AceConfigDialog-3.0"):Open(D.name);
        end

    elseif (button == "RightButton" and IsShiftKeyDown()) then
        D:HideBar();
    elseif (button == "LeftButton" and IsControlKeyDown()) then
        D:ShowHidePriorityListUI();
    elseif (button == "LeftButton" and IsShiftKeyDown()) then
        D:ShowHideSkipListUI();
    end

end -- }}}


local DebugHeader = false;
function D:ShowDebugReport()

    if DC.DevVersionExpired then
        D:VersionWarnings();
        return;
    end

    D:Debug(GetLocale());

    if not DebugHeader then
        DebugHeader = ("%s\n@project-version@  %s  CT: %0.4f D: %s %s (%s, %s, %s, %s)"):format((Dcr and Dcr.L) and Dcr.L["DEBUG_REPORT_HEADER"] or "X|cFF11FF33Please report the content of this window to Archarodim@teaser.fr|r\n|cFF009999(Use CTRL+A to select all and then CTRL+C to put the text in your clip-board)|r\n", DC.MyClass, D:NiceTime(), date(), GetLocale(), GetBuildInfo());
    end

    T._DebugText = DebugHeader .. table.concat(T._DebugTextTable, "");
    _G.DecursiveDebuggingFrameText:SetText(T._DebugText);

    _G.DecursiveDEBUGtext:SetText(L["DECURSIVE_DEBUG_REPORT"]);
    _G.DecursiveDebuggingFrame:Show();
end

T._LoadedFiles["Dcr_opt.lua"] = "@project-version@";

-- Closer
