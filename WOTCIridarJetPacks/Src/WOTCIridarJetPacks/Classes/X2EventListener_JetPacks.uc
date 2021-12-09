class X2EventListener_JetPacks extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(SquadSelectListener());

	return Templates;
}

/*
'AbilityActivated', AbilityState, SourceUnitState, NewGameState
'PlayerTurnBegun', PlayerState, PlayerState, NewGameState
'PlayerTurnEnded', PlayerState, PlayerState, NewGameState
'UnitDied', UnitState, UnitState, NewGameState
'KillMail', UnitState, Killer, NewGameState
'UnitTakeEffectDamage', UnitState, UnitState, NewGameState
'OnUnitBeginPlay', UnitState, UnitState, NewGameState
'OnTacticalBeginPlay', X2TacticalGameRuleset, none, NewGameState
*/

static function CHEventListenerTemplate SquadSelectListener()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'IRI_X2EventListener_WOTCIridarOfficersRanks_SquadSelect');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('UISquadSelect_NavHelpUpdate', OnSquadSelectNavHelpUpdate, ELD_Immediate, 50);
	
	return Template;
}

static function EventListenerReturn OnSquadSelectNavHelpUpdate(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackObject)
{
	local UISquadSelect						SquadSelect;
	local UISquadSelect_ListItem			ListItem;
	local array<UIPanel>					ChildrenPanels;
	local UIPanel							ChildPanel;
	local XComGameState_Unit				UnitState;
	local XComGameState_HeadquartersXCom	XComHQ;
	local XComGameStateHistory				History;
	local UIMechaListItem					DDCheckbox;

	SquadSelect = UISquadSelect(EventSource);
	if (SquadSelect == none)
		return ELR_NoInterrupt;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
	if (XComHQ == none)
		return ELR_NoInterrupt;

	SquadSelect.GetChildrenOfType(class'UISquadSelect_ListItem', ChildrenPanels);

	`AMLOG("Running");

	foreach ChildrenPanels(ChildPanel)
	{
		ListItem = UISquadSelect_ListItem(ChildPanel);
		if (ListItem.SlotIndex < 0 || ListItem.SlotIndex > XComHQ.Squad.Length || XComHQ.Squad[ListItem.SlotIndex].ObjectID == 0)
			continue;

		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Squad[ListItem.SlotIndex].ObjectID));
		if (UnitState == none)
			continue;

		`AMLOG("Looking at soldier:" @ UnitState.GetFullName());

		if (ListItem.GetChildByName('Iri_JetPacks_DynamicDeployment_Checkbox') != none || ListItem.bDisabled)
			continue;

		DDCheckbox = ListItem.Spawn(class'UIMechaListItem', ListItem);
		DDCheckbox.bAnimateOnInit = false;
		DDCheckbox.InitListItem('Iri_JetPacks_DynamicDeployment_Checkbox');
		DDCheckbox.UpdateDataCheckbox("Dynamic Deployment", "tooltip", false, OnDynamicDeploymentCheckboxChanged, none);
		DDCheckbox.SetWidth(465);

		if (ListItem.IsA('robojumper_UISquadSelect_ListItem'))
		{
			DDCheckbox.SetY(ListItem.Height + robojumper_UISquadSelect_ListItem(ListItem).GetExtraHeight());
			ListItem.SetY(ListItem.Y - DDCheckbox.Height - 10);
		}
		else
		{
			`AMLOG("Regular panel. Y:" @ ListItem.Y @ "Height:" @ ListItem.Height);
			DDCheckbox.SetY(362);
			ListItem.SetY(ListItem.Y - DDCheckbox.Height);
		}
	}
	return ELR_NoInterrupt;
}

private static function OnDynamicDeploymentCheckboxChanged(UICheckbox CheckBox)
{
	
}