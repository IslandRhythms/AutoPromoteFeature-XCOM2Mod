// This is an Unreal Script

class AutoPromote extends X2DownloadableContentInfo config(GameData);

struct SoldierTypes {
	var name soldierClass;
	var int squaddie;
	var int corporal;
	var int sergeant;
	var int lieutenant;
	var int captain;
	var int major;
	var int colonel;
};

var config array<SoldierTypes> ClassPresets;

static function autoPromote(XComGameState_Unit Unit, XComGameState UpdateState) {
	local name soldierType;
	local int Index, iRank, iBranch;
	soldierType = Unit.GetSoldierClassTemplateName();
	iRank = Unit.GetSoldierRank();
	Index = default.ClassPresets.find('soldierClass', soldierType);
	`log("If you have a custom soliderclass, soldierType is what you want to write into the game data ini file");
	`log("soldierType, iRank, Index");
	`log(soldierType);
	`log(iRank);
	`log(Index);
	if (Index != INDEX_NONE && Index != -1) {
	// The soldier's class has a preset, autopromote it
		switch(iRank) {
			case 1: 
			iBranch = default.ClassPresets[Index].corporal;
			break;
			case 2:
			iBranch = default.ClassPresets[Index].sergeant;
			break;
			case 3:
			iBranch = default.ClassPresets[Index].lieutenant;
			break;
			case 4:
			iBranch = default.ClassPresets[Index].captain;
			break;
			case 5:
			iBranch = default.ClassPresets[Index].major;
			break;
			case 6:
			iBranch = default.ClassPresets[Index].colonel;
			break;
			default:
			iBranch = default.ClassPresets[Index].squaddie;
			break;
		}
		Unit.BuySoldierProgressionAbility(UpdateState,iRank,iBranch);
		Unit.RankUpSoldier(UpdateState);
		`GAMERULES.SubmitGameState(UpdateState);
	} 
	else if (soldierType == 'Rookie') {
		Unit.RankUpSoldier(UpdateState);
		Unit.ApplyInventoryLoadout(UpdateState); // solider was promoted to squaddie, but kept rookie loadlout. Must fix with this.
		`GAMERULES.SubmitGameState(UpdateState);
	}
	// if it doesn't have a preset, not our problem.
}