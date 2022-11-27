//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_AutoPromotion.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_AutoPromotion extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static event onPostMission() {
	local StateObjectReference UnitRef;
	local XComGameState_Unit Unit;
	local XComGameStateContext_ChangeContainer Container;
	local XComGameState UpdateState;
	local XComGameState_HeadquartersXCom XCOMHQ;
	local XComGameStateHistory History;
	local int i;
	`log("=================================");
	`log("onPostMission in Promotion Screen Mod");
	History = `XCOMHISTORY;
	XCOMHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Promotion");
	UpdateState = History.CreateNewGameState(true, Container);
	`log("Checking values that could be used to determine eligibility promotion");
	`log("ObjectIDs of the entire roster");
	for (i = 0; i < XCOMHQ.Crew.Length; i++) {
		// Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(XCOMHQ.Crew[i].ObjectID));
		Unit = XComGameState_Unit(UpdateState.ModifyStateObject(class 'XComGameState_Unit', XCOMHQ.Crew[i].ObjectID));
		`log(XCOMHQ.Crew[i].ObjectID);
		if (Unit.IsAlive() && Unit.IsSoldier() && Unit.CanRankUpSoldier()) {
			// if they have no abilities marked, default to the config files.
			`log("This Unit is eligible to Promote, start process");
			class 'AutoPromote'.static.autoPromote(Unit, UpdateState);
		}
	}
	`log("ObjectIDs of the deployed squad returning from mission");
	foreach `XCOMHQ.Squad(UnitRef)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
		`log(UnitRef.ObjectID);
	}
}