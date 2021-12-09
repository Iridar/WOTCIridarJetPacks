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
	local UISquadSelect				SquadSelect;
	local UISquadSelect_ListItem	ListItem;
	local int						SlotIndex;
	local int						SquadIndex;
	
	`AMLOG("Running");

	SquadSelect = UISquadSelect(EventSource);
	if (SquadSelect == none)
		return ELR_NoInterrupt;

	`AMLOG("Have squad select screen. Slots:" @ SquadSelect.SlotListOrder.Length);

	for (SlotIndex = 0; SlotIndex < SquadSelect.SlotListOrder.Length; SlotIndex++)
	{
		SquadIndex = SquadSelect.SlotListOrder[SlotIndex];

		// The slot list may contain more information/slots than available soldiers, so skip if we're reading outside the current soldier availability. 
		if (SquadIndex >= SquadSelect.SoldierSlotCount)
			continue;

		//We want the slots to match the visual order of the pawns in the slot list. 
		ListItem = UISquadSelect_ListItem(SquadSelect.m_kSlotList.GetItem(SlotIndex));

		if (ListItem != none)
		{
			`LOG("Looking at soldier:" @ XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.Squad[ListItem.SlotIndex].ObjectID)).GetFullName(),, 'IRITEST');
			
		}
	}

	return ELR_NoInterrupt;
}
