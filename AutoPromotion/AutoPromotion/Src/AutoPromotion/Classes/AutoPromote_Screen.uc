// This is an Unreal Script

class AutoPromote_Screen extends Object config(AutoPromote_NullConfig);

var config int VERSION_CFG;
// Localization for your MCM page.
var localized string ModName;
var localized string PageTitle;
var localized string GroupHeader;

`include(AutoPromotion\Src\ModConfigMenuAPI\MCM_API_Includes.uci)

// Here you add AutoVars macros. Look in .uci MCM files to see what other things you can add.

`MCM_API_AutoCheckBoxVars(ONLYSQUADDIES);
`MCM_API_AutoCheckBoxVars(ONLYVETS);
`MCM_API_AutoCheckBoxVars(CHECKBARRACKS);
`MCM_API_AutoCheckBoxVars(ENABLELOGGING);
`MCM_API_AutoCheckBoxVars(SHOWPROMOTIONPOPUP);
`MCM_API_AutoCheckBoxVars(USENAME);
`MCM_API_AutoCheckBoxVars(IGNORECA);
`MCM_API_AutoCheckBoxVars(RANKNOBUY);
`MCM_API_AutoCheckBoxVars(BUYRANDOM);
`include(AutoPromotion\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)





// Here you add AutoFns macros. Same as before, look in .uci for examples.
// One AutoVars and one AutoFns line is required for each MCM var.

`MCM_API_AutoCheckBoxFns(ONLYSQUADDIES, 1);
`MCM_API_AutoCheckBoxFns(ONLYVETS, 1);
`MCM_API_AutoCheckBoxFns(CHECKBARRACKS, 1);
`MCM_API_AutoCheckBoxFns(ENABLELOGGING, 1);
`MCM_API_AutoCheckBoxFns(SHOWPROMOTIONPOPUP, 1);
`MCM_API_AutoCheckBoxFns(USENAME, 1);
`MCM_API_AutoCheckBoxFns(IGNORECA, 1);
`MCM_API_AutoCheckBoxFns(RANKNOBUY, 1);
`MCM_API_AutoCheckBoxFns(BUYRANDOM, 1);

event OnInit(UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);
}

//This function creates your MCM page.
simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local MCM_API_SettingsPage	Page;
	local MCM_API_SettingsGroup Group;

	// This part is always the same, just copy it around.
	LoadSavedSettings();

	Page = ConfigAPI.NewSettingsPage(ModName);
	Page.SetPageTitle(PageTitle);
	Page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked); // optional

	Group = Page.AddGroup('Group_1', GroupHeader);
    
    // End of same part. You can create more groups with their own group headers.
    // Separating your settings into different groups is done 
    // purely for user convenience / better presentation.
    
    // Here you create your MCM settings. One line per MCM var.
	
	`MCM_API_AutoAddCheckBox(Group, ONLYSQUADDIES);	// false by default
	`MCM_API_AutoAddCheckBox(Group, ONLYVETS); // false by default
	`MCM_API_AutoAddCheckBox(Group, CHECKBARRACKS); // false by default
	`MCM_API_AutoAddCheckBox(Group, USENAME); // true by default
	`MCM_API_AutoAddCheckBox(Group, SHOWPROMOTIONPOPUP); // false by default
	`MCM_API_AutoAddCheckBox(Group, ENABLELOGGING); // false by default
	`MCM_API_AutoAddCheckBox(Group, IGNORECA); // false by default
	`MCM_API_AutoAddCheckBox(Group, RANKNOBUY); // false by default
	`MCM_API_AutoAddCheckBox(Group, BUYRANDOM); // false by default

	// This will display your created page.
	Page.ShowSettings();
}

// This part is always the same, you just copy it around and put in your MCM var names.
simulated function LoadSavedSettings()
{	
	ONLYSQUADDIES = `GETMCMVAR(ONLYSQUADDIES);
	ONLYVETS = `GETMCMVAR(ONLYVETS);
	CHECKBARRACKS = `GETMCMVAR(CHECKBARRACKS);
	ENABLELOGGING = `GETMCMVAR(ENABLELOGGING);
	USENAME = `GETMCMVAR(USENAME);
	SHOWPROMOTIONPOPUP = `GETMCMVAR(SHOWPROMOTIONPOPUP);
	IGNORECA = `GETMCMVAR(IGNORECA);
	RANKNOBUY = `GETMCMVAR(RANKNOBUY);
	BUYRANDOM = `GETMCMVAR(BUYRANDOM);
}

// Same. Note: required only if you actually called EnableResetButton() earlier.
simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	`MCM_API_AutoReset(ONLYSQUADDIES);
	`MCM_API_AutoReset(ONLYVETS);
	`MCM_API_AutoReset(CHECKBARRACKS);
	`MCM_API_AutoReset(ENABLELOGGING);
	`MCM_API_AutoReset(USENAME);
	`MCM_API_AutoReset(SHOWPROMOTIONPOPUP);
	`MCM_API_AutoReset(IGNORECA);
	`MCM_API_AutoReset(RANKNOBUY);
	`MCM_API_AutoReset(BUYRANDOM);
}

// Copy this around.
simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	VERSION_CFG = `MCM_CH_GetCompositeVersion();
	SaveConfig();
}