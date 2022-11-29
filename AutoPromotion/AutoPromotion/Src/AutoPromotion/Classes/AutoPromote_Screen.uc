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
`include(AutoPromotion\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)





// Here you add AutoFns macros. Same as before, look in .uci for examples.
// One AutoVars and one AutoFns line is required for each MCM var.

`MCM_API_AutoCheckBoxFns(ONLYSQUADDIES, 1);

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

	// This will display your created page.
	Page.ShowSettings();
}

// This part is always the same, you just copy it around and put in your MCM var names.
simulated function LoadSavedSettings()
{	
	ONLYSQUADDIES = `GETMCMVAR(ONLYSQUADDIES);
}

// Same. Note: required only if you actually called EnableResetButton() earlier.
simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	`MCM_API_AutoReset(ONLYSQUADDIES);
}

// Copy this around.
simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	VERSION_CFG = `MCM_CH_GetCompositeVersion();
	SaveConfig();
}