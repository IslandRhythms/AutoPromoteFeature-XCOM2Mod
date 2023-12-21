//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_AutoPromotion.uc                                    
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_AutoPromotion extends X2DownloadableContentInfo;

`include(AutoPromotion/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
static event OnLoadedSavedGame(){}
static event InstallNewCampaign(XComGameState StartState){}

// to be used after LevelUpBarracks
exec function BuyBarracksAbilities() {
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

exec function PromoteAllSoldiers(optional int rankUps = 1, optional string className = "all") {
	local XComGameStateContext_ChangeContainer Container;
	local XComGameState UpdateState;
	local XComGameState_Unit Unit;
	local int i;

	Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Auto-Promotion");
	UpdateState = `XCOMHISTORY.CreateNewGameState(true, Container);
	for (i = 0; i < `XCOMHQ.Crew.Length; i++) {
		Unit = XComGameState_Unit(UpdateState.ModifyStateObject(class 'XComGameState_Unit', `XCOMHQ.Crew[i].ObjectID));
		if (Unit.IsAlive() && Unit.IsSoldier()) {
			if ((Unit.GetSoldierRank() + rankUps) > class'X2ExperienceConfig'.static.GetMaxRank()) {
				continue;
			}
			class'AutoPromote'.static.promoteSingleSoldier(Unit, rankUps, UpdateState, className);
		}
	}
	`GAMERULES.SubmitGameState(UpdateState);
}


exec function PromoteSoldier(string soldierName, optional int rankUps = 1) {
	local XComGameStateContext_ChangeContainer Container;
	local XComGameState UpdateState;
	local XComGameState_Unit Unit;
	local int i;

	Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Auto-Promotion");
	UpdateState = `XCOMHISTORY.CreateNewGameState(true, Container);
	for (i = 0; i < `XCOMHQ.Crew.Length; i++) {
		Unit = XComGameState_Unit(UpdateState.ModifyStateObject(class 'XComGameState_Unit', `XCOMHQ.Crew[i].ObjectID));
		if (Unit.GetFullName() == soldierName && Unit.IsAlive() && Unit.IsSoldier()) {
			if ((Unit.GetSoldierRank() + rankUps) > class'X2ExperienceConfig'.static.GetMaxRank()) {
				return;
			}
			class'AutoPromote'.static.promoteSingleSoldier(Unit, rankUps, UpdateState);
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

exec function GetSoldierAbilitiesForRank(string soldierName, int rank) {
	local XComGameState_Unit Unit;
	local int i, j;
	local string fullName;
	`log("rank is"@rank);
	for (i = 0; i < `XCOMHQ.Crew.Length; i++) {
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.Crew[i].ObjectID));
		fullName = Unit.GetFullName();
		if(fullName == soldierName) {
			for (j = 0; j < Unit.AbilityTree[rank].Abilities.Length; j++) {
				`log("Ability name is "@Unit.AbilityTree[rank].Abilities[j].AbilityName);
				`log("branch number is "@j);
			}
		}
	}
}

static event onPostMission()
{
	local StateObjectReference UnitRef;
	local XComGameState_Unit Unit;
	local XComGameStateContext_ChangeContainer Container;
	local XComGameState UpdateState;
	local XComGameStateHistory History;
	local int i;
	local bool bEnableLogging;
	local array<StateObjectReference> Units;

	bEnableLogging = `GETMCMVAR(ENABLELOGGING);

	`LOG("=================================", bEnableLogging, 'Beat_AutoPromote');
	`LOG("onPostMission in Promotion Screen Mod", bEnableLogging, 'Beat_AutoPromote');

	History = `XCOMHISTORY;
	Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Auto-Promotion");
	UpdateState = History.CreateNewGameState(true, Container);
	Units = `GETMCMVAR(CHECKBARRACKS) ? `XCOMHQ.Crew : `XCOMHQ.Squad;

	`LOG("ObjectIDs of the deployed squad returning from mission", bEnableLogging, 'Beat_AutoPromote');
	foreach `XCOMHQ.Squad(UnitRef)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
		`LOG(Unit.GetFullName() @"ID [" @UnitRef.ObjectID @"]", bEnableLogging, 'Beat_AutoPromote');
	}

	for (i = 0; i < Units.Length; i++)
	{
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
					} else if (`GETMCMVAR(ONLYVETS) && Unit.GetSoldierRank() != 0) {
							`LOG("ONLYVETS is enabled and the unit is not a rookie, start process", bEnableLogging, 'Beat_AutoPromote');
			
							class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					} else {
							`LOG("ONLYVETS and ONLYSQUADDIES is disabled so business as usual, start process", bEnableLogging, 'Beat_AutoPromote');
			
							class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					}
		}
	}

	`GAMERULES.SubmitGameState(UpdateState);
}
