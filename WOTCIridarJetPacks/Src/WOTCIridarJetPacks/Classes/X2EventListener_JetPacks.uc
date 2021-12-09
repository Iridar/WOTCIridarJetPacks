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
	local UIMechaListItem					SpawnedItem;
	local int								PanelY;
	local  robojumper_UISquadSelect_ListItem RJS;

	SquadSelect = UISquadSelect(EventSource);
	if (SquadSelect == none)
		return ELR_NoInterrupt;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
	if (XComHQ == none)
		return ELR_NoInterrupt;

	SquadSelect.GetChildrenOfType(class'UISquadSelect_ListItem', ChildrenPanels);

	foreach ChildrenPanels(ChildPanel)
	{
		ListItem = UISquadSelect_ListItem(ChildPanel);
		if (ListItem.SlotIndex < 0 || ListItem.SlotIndex > XComHQ.Squad.Length || XComHQ.Squad[ListItem.SlotIndex].ObjectID == 0)
			continue;

		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Squad[ListItem.SlotIndex].ObjectID));
		if (UnitState == none)
			continue;

		if (ListItem.GetChildByName('Iri_JetPacks_DynamicDeployment_Checkbox') != none)
			continue;

		PanelY = ListItem.Height;
		if (ListItem.IsA('robojumper_UISquadSelect_ListItem'))
		{
			//PanelY += robojumper_UISquadSelect_ListItem(ListItem).GetExtraHeight();
		}

		`AMLOG("Looking at soldier:" @ UnitState.GetFullName());
		SpawnedItem = ListItem.Spawn(class'UIMechaListItem', ListItem);
		SpawnedItem.bAnimateOnInit = false;
		SpawnedItem.InitListItem('Iri_JetPacks_DynamicDeployment_Checkbox');
		SpawnedItem.UpdateDataCheckbox("Dynamic Deployment", "tooltip", false, OnDynamicDeploymentCheckboxChanged, none);
		SpawnedItem.SetY(PanelY);
		SpawnedItem.SetWidth(460);
		
		ListItem.SetY(ListItem.Y +  - SpawnedItem.Height - 10);
	}
	return ELR_NoInterrupt;
}

private static function OnDynamicDeploymentCheckboxChanged(UICheckbox CheckBox)
{
	
}