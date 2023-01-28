//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_AutoPromotion.uc                                    
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_AutoPromotion extends X2DownloadableContentInfo;

`include(AutoPromotion/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
static event OnLoadedSavedGame(){}
static event InstallNewCampaign(XComGameState StartState){}

exec function PromoteAllSoldiers() {
	local int i;
	local XComGameStateContext_ChangeContainer Container;
	local XComGameState UpdateState;
	local XComGameState_Unit Unit;

	Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Auto-Promotion");
	UpdateState = `XCOMHISTORY.CreateNewGameState(true, Container);
	for (i = 0; i < `XCOMHQ.Crew.Length; i++)
		{
			Unit = XComGameState_Unit(UpdateState.ModifyStateObject(class 'XComGameState_Unit', `XCOMHQ.Crew[i].ObjectID));

			if (Unit.IsAlive() && Unit.IsSoldier())
			{
				class'AutoPromote'.static.autoPromoteConsoleCommand(Unit, UpdateState);
			}
		}

		`GAMERULES.SubmitGameState(UpdateState);
}

// omit the nickname if the unit has one
exec function ListSoldierAbility(string soldierName, int rank, int branch) {
	local XComGameState_Unit Unit;
	local int i;
	local string fullName;
	local name ability;
	for (i = 0; i < `XCOMHQ.Crew.Length; i++) {
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.Crew[i].ObjectID));
		fullName = Unit.GetFullName();
		if(fullName == soldierName) {
			ability = Unit.GetAbilityName(rank, branch);
			`log("The ability at the given rank and branch is"@ability);
		}
	}

}

static event onPostMission()
{
	local StateObjectReference UnitRef;
	local XComGameState_Unit Unit;
	local XComGameStateContext_ChangeContainer Container;
	local XComGameState UpdateState;
	local XComGameState_HeadquartersXCom XCOMHQ;
	local XComGameStateHistory History;
	local int i;
	local bool bEnableLogging;
	local array<StateObjectReference> Units;

	bEnableLogging = `GETMCMVAR(ENABLELOGGING);

	`LOG("=================================", bEnableLogging, 'Beat_AutoPromote');
	`LOG("onPostMission in Promotion Screen Mod", bEnableLogging, 'Beat_AutoPromote');

	History = `XCOMHISTORY;
	XCOMHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Auto-Promotion");
	UpdateState = History.CreateNewGameState(true, Container);
	Units = `GETMCMVAR(CHECKBARRACKS) ? `XCOMHQ.Crew : `XCOMHQ.Squad;

	`LOG("ObjectIDs of the deployed squad returning from mission", bEnableLogging, 'Beat_AutoPromote');


	for (i = 0; i < Units.Length; i++) {
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Units[i].ObjectID));
		`LOG(Unit.GetFullName() @"ID [" @UnitRef.ObjectID @"]", bEnableLogging, 'Beat_AutoPromote');
		if (Unit.IsAlive() && Unit.IsSoldier() && Unit.CanRankUpSoldier())
		{
					if (`GETMCMVAR(ONLYSQUADDIES) && `GETMCMVAR(ONLYVETS)) {
						// if they have no abilities marked, default to the config files.
						`LOG("This Unit is eligible to Promote, start process", bEnableLogging, 'Beat_AutoPromote');
			
						class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					} else if (`GETMCMVAR(ONLYSQUADDIES) && Unit.GetSoldierRank() == 0) {
						`LOG("ONLYSQUADDIES is enabled and this unit is a rookie, start process.", bEnableLogging, 'Beat_AutoPromote');
			
						class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					} else { // only vets enabled, only squaddies disabled.
						if (Unit.GetSoldierRank() != 0) {
							`LOG("ONLYVETS is enabled and the unit is not a rookie, start process", bEnableLogging, 'Beat_AutoPromote');
			
							class'AutoPromote'.static.autoPromote(Unit, UpdateState);
						}
					}
		}
	}

	`GAMERULES.SubmitGameState(UpdateState);
}
