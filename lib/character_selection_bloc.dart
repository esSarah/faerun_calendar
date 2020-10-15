import 'support_database.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'main_bloc.dart';
import 'support_faerun_date.dart';

///region Sates
enum CharacterStates
{
	isInitializing,
	isChanging,
	isReady,
}

enum CharacterChangeStates
{
	stillInitializing,
	characterSelected,
	characterEstablished,
}

enum CharacterEditingStates
{
	isNotBeingEdited,
	PrepareNewCharacter,
	ChangeCurrentCharacter,
}
///endregion

///region Events
class CharacterChangeProperties
{
	int oldUuserID = 0;
	int newUserID  = 0;
	CharacterChangeStates state = CharacterChangeStates.stillInitializing;
}

class CharacterProperties
{
	int    id = 0;
	String characterName = '';
	//--
	CharacterStates        state     = CharacterStates.isInitializing;
	CharacterEditingStates editState = CharacterEditingStates.isNotBeingEdited;

	List<CharacterData> availableCharacters = new List<CharacterData>();

	bool       currentNameSuggestionIsValid = false;
	String     suggestedName                = '';
	FaerunDate partyDate                    = new FaerunDate();
	FaerunDate currentDate                  = new FaerunDate();
	int        currentDateID                = 0;
	int        partyDateID                  = 0;
}

class CharacterData
{
	int    id            = 0;
	String characterName = '';
}

// Events in
abstract class CharacterEvent
{
	CharacterEvent([List props = const[]]);
}

class LoadIinitialCharacterList extends CharacterEvent
{

}

class SetPartyDate extends CharacterEvent
{
	final FaerunDate partyDate;
	SetPartyDate ({@required this.partyDate}) : super([partyDate]);
}

class SetCurrentDate extends CharacterEvent
{
	final FaerunDate currentDate;
	SetCurrentDate ({@required this.currentDate}) : super([currentDate]);
}

class LoadCharacterEvent  extends CharacterEvent
{
	final int id;

	LoadCharacterEvent ({@required this.id}) : super([id]);
}

class LoadDefaultCharacterEvent extends CharacterEvent
{

}

class ChangeCharacterEvent extends CharacterEvent
{
}

class CancelCharacterEditEvent extends CharacterEvent
{

}

class ChangeModeToNewCharacterEvent extends CharacterEvent
{

}

class ChangeModeToEditCharacterEvent extends CharacterEvent
{

}

class SwitchToCharacterEvent extends CharacterEvent
{
	final int id;

	SwitchToCharacterEvent ({@required this.id}) : super([id]);
}

class DeleteCurrentCharacterEvent extends CharacterEvent
{

}

class OthersAreReadyForCharacterChange extends CharacterEvent
{

}

class CharacterEvaluationEvent extends CharacterEvent
{
	final String suggestedName;

	CharacterEvaluationEvent ({@required this.suggestedName}) : super([suggestedName]);
}
///endregion

class CharacterBloc
{
	//region public values
	DatabaseManager           db;
	CharacterProperties       characterProperties            = new CharacterProperties();
	CharacterChangeProperties characterRefreshroperties      = new CharacterChangeProperties();
	int                       defaultCharacter               = 1;
	bool                      characterListIsCurrentlyEdited = false;
	MainBloc                  main;
	//endregion

	//region bloc definitions (stream defnitions)

	// rein (private?) Sink steht für das Sammelbecken von allem was reinkommt
	final _characterController = StreamController<CharacterProperties>.broadcast();
	// raus
	Stream<CharacterProperties> get character => _characterController.stream;


	// rein (private?) Sink steht für das Sammelbecken von allem was reinkommt
	final _characterChangeController = StreamController<CharacterChangeProperties>.broadcast();
	// raus
	Stream<CharacterChangeProperties> get characterChange => _characterChangeController.stream;

	final _characterEventController = StreamController<CharacterEvent>();
	// in dieses Sammelbecken kommen die Events
	Sink<CharacterEvent> get characterEvents => _characterEventController.sink;

	//endregion

	CharacterBloc(MainBloc mainBloc)
	{
		main = mainBloc;
		db = main.mainProperties.db;
		_characterEventController.stream.listen(_mapEventToState);
		_characterController.add(characterProperties);
		_loadInitialCharacterList();
	}
	void poke()
	{
		_characterController.add(characterProperties);
	}

	//region helper method
	bool validateNewName(String nameSuggestion)
	{
		nameSuggestion = nameSuggestion.trim();
		if(nameSuggestion.isEmpty)
		{
			return false;
		}
		else
		{
			if
			( nameSuggestion == characterProperties.characterName
					&&
					characterProperties.editState==CharacterEditingStates.ChangeCurrentCharacter
			)
			{
				return false;
			}
			else
			{
				if (nameSuggestion.length>20)
				{
					return false;
				}
				else
				{
					CharacterData iGotNothing;

					iGotNothing  = characterProperties.availableCharacters.firstWhere
						(
									(aCharacter) => aCharacter.characterName==nameSuggestion, orElse: () => null
					);
					if(iGotNothing==null)
					{
						characterProperties.suggestedName = nameSuggestion;
						return true;
					}
					else
					{
						return false;
					}
				}
			}
		}
	}
	//endregion

	//region database interaction
	Future<bool> refreshCharacterList() async
	{
		if(!characterListIsCurrentlyEdited)
		{
			characterListIsCurrentlyEdited = true;
			characterProperties.availableCharacters.clear();
			List<Map> characterData = await db.read("SELECT ID, Name FROM Character");
			characterData.forEach
			(
				(char)
				{
					CharacterData _characterData = new CharacterData();
					_characterData.id            = char[ 'ID'   ];
					_characterData.characterName = char[ 'Name' ];
					characterProperties.availableCharacters.add(_characterData);
				}
			);
		}
		characterListIsCurrentlyEdited = false;
		return true;
	}

	Future<bool> loadCharacter(int byId) async
	{
		int _selectedYear;
		int _selectedMonth;
		int _selectedDay;

		int _partyYear;
		int _partyMonth;
		int _partyDay;

		List<Map> characterData = await db.read
		(
			'''
			SELECT
			[Character].[ID]      AS ID,
			[Character].[Name]    AS Name,
			[CurrentDate].[ID]    AS CurrentDateID,
			[CurrentDate].[Year]  AS CurrentYear,
			[CurrentDate].[Month] AS CurrentMonth,
			[CurrentDate].[Day]   AS CurrentDay,
			[PartyDate].[ID]      AS PartyDateID,
			[PartyDate].[Year]    AS PartyYear,
			[PartyDate].[Month]   AS PartyMonth,
			[PartyDate].[Day]     AS PartyDay
			FROM [Character]
			
			INNER JOIN Dates CurrentDate
			ON 
			[Character].[CurrentDateID] = CurrentDate.[ID]
			
			INNER JOIN Dates PartyDate
			ON 
			[Character].[PartyDateID] = PartyDate.[ID]
			
			WHERE [Character].[ID] = $byId
			'''
		);

		characterData.forEach
		(
			(char)
			{
				characterProperties.id            = char[ 'ID'   ];
				characterProperties.characterName = char[ 'Name' ];

				characterProperties.currentDateID = char[ 'CurrentDateID' ];

				_selectedYear  = char[ 'CurrentYear'  ];
				_selectedMonth = char[ 'CurrentMonth' ];
				_selectedDay   = char[ 'CurrentDay'   ];

				characterProperties.partyDateID   = char[ 'PartyDateID'   ];

				_partyYear     = char[ 'PartyYear'  ];
				_partyMonth    = char[ 'PartyMonth' ];
				_partyDay      = char[ 'PartyDay'   ];
			}
		);

		await characterProperties.currentDate.loadDate
		(
			_selectedYear,
			_selectedMonth,
			_selectedDay
		);
		await characterProperties.partyDate.loadDate
		(
			_partyYear,
			_partyMonth,
			_partyDay
		);

		return true;
	}

	Future<int> createCharacter(String newName) async
	{
		characterProperties.currentDateID = await db.executeIntScalar
		(
				'SELECT MAX(ID) AS[MaxId] FROM [Dates]'
		);
		characterProperties.partyDateID  = characterProperties.currentDateID + 1;

		FaerunDate initialDates = main.mainProperties.currentMonth;

		int newID = await db.executeIntScalar
		(
			'SELECT MAX(ID) AS[MaxId] FROM [Character]'
		);
		newID++;
		await db.read
		(
			'''
			INSERT INTO Character 
			(
				ID, 
				Name,
				CurrentDateID,
				PartyDateID
			) 
			VALUES
			(
				$newID, 
				'${db.secure(newName)}',
				${characterProperties.currentDateID},
				${characterProperties.partyDateID},
			)
			'''
		);
		// now I stll need to save the two dates.
		await db.read
		(
			'''
			INSERT INTO [Dates] 
			(
				[ID], 
				[TypeID],
				[Year],
				[Month],
				[Day],
				[Hour],
				[Minutes]
			)
			VALUES
			(
				${characterProperties.currentDateID},
				1,
				${initialDates.year.currentYear},
				${initialDates.month},
				1,
				0,
				0		
			)
			'''
		);

		await db.read
		(
			'''
			INSERT INTO [Dates] 
			(
				[ID], 
				[TypeID],
				[Year],
				[Month],
				[Day],
				[Hour],
				[Minutes]
			)
			VALUES
			(
				${characterProperties.partyDateID},
				2,
				${initialDates.year.currentYear},
				${initialDates.month},
				1,
				0,
				0		
			)
			'''
		);
		return newID;
	}

	Future<bool> deleteCharacter(int byId) async
	{
		if(byId != defaultCharacter)
		{

			await db.read('DELETE FROM [Dates] WHERE ID = ' +
					characterProperties.currentDateID.toString());
			await db.read('DELETE FROM [Dates] WHERE ID = ' +
					characterProperties.partyDateID.toString());

			await db.read('DELETE FROM [Value] WHERE CharacterID = ' +
				byId.toString());
			await db.read('DELETE FROM [Span] WHERE CharacterID = ' +
				byId.toString());
			await db.read('DELETE FROM [Character] WHERE ID = ' +
				byId.toString());
		}
		return true;
	}

	Future<bool> changeCharacter(String newName) async
	{
		await db.read('UPDATE Character SET Name=\''+ db.secure(newName) +
			'\' WHERE ID = ' + characterProperties.id.toString());
		characterProperties.characterName = newName;

		return true;
	}

	Future<bool> loadDefaultCharacter() async
	{
		loadCharacter(defaultCharacter);
		return true;
	}

//endregion

	//region Event handling
	void _mapEventToState(CharacterEvent event)
	{
		if(event is LoadIinitialCharacterList)
		{
			_loadInitialCharacterList();
		}

		if (event is LoadCharacterEvent)
		{
			_loadCharacter(event);
		}
		if (event is LoadDefaultCharacterEvent)
		{
			_loadDefaultCharacter();
		}
		if(event is ChangeModeToNewCharacterEvent)
		{
			_changeModeToNewCharacter();
		}
		if(event is ChangeCharacterEvent)
		{
			_changeCharacter();
		}

		if(event is ChangeModeToEditCharacterEvent)
		{
			_changeModeToEditCharacter();
		}

		if(event is CancelCharacterEditEvent)
		{
			_cancelCharacterEdit();
		}

		if(event is SwitchToCharacterEvent)
		{
			// _SwitchToCharacter(event);
		}

		if(event is CharacterEvaluationEvent)
		{
			_checkValidNameSuggestion(event);
		}

		if(event is DeleteCurrentCharacterEvent)
		{
			_deleteCurrentCharacter();
		}

		if(event is OthersAreReadyForCharacterChange)
		{
			_finalizeCharacterChange();
		}

		if(event is SetCurrentDate)
		{
			_setCurrentDate(event);
		}

		if(event is SetPartyDate)
		{
			_setPartyDate(event);
		}
	}

	void _loadInitialCharacterList() async
	{
		await refreshCharacterList();
		_characterController.add(characterProperties);
	}

	void _loadDefaultCharacter() async
	{
		this.characterEvents.add(LoadCharacterEvent(id: defaultCharacter));
		/*
		characterProperties.state = CharacterStates.isChanging;
		characterRefreshroperties.oldUuserID = characterProperties.id;
		characterRefreshroperties.newUserID = DefaultCharacter;
		characterRefreshroperties.state = CharacterChangeStates.characterSelected;

		// prepare for change in the UI (_characterController) and
		// inform the master about our intentions
		_characterChangeController.add(characterRefreshroperties);
		_characterController.add(characterProperties);

*/
	}

	void _loadCharacter(LoadCharacterEvent loadCharacterEvent) async
	{
		if(loadCharacterEvent.id!=characterProperties.id)
		{
			characterProperties.state = CharacterStates.isChanging;
			characterRefreshroperties.oldUuserID = characterProperties.id;
			characterRefreshroperties.newUserID = loadCharacterEvent.id;
			characterRefreshroperties.state = CharacterChangeStates.characterSelected;

			// prepare for change in the UI (_characterController) and
			// inform the master about our intentions
			_characterChangeController.add(characterRefreshroperties);
			_characterController.add(characterProperties);
		}
	}

	void _changeModeToNewCharacter()
	{
		characterProperties.editState = CharacterEditingStates.PrepareNewCharacter;
		_characterController.add(characterProperties);
	}

	void _changeModeToEditCharacter()
	{
		characterProperties.editState = CharacterEditingStates.ChangeCurrentCharacter;
		_characterController.add(characterProperties);
	}

	void _cancelCharacterEdit()
	{
		characterProperties.editState = CharacterEditingStates.isNotBeingEdited;
		_characterController.add(characterProperties);
	}

	void _checkValidNameSuggestion(CharacterEvaluationEvent event)
	{
		characterProperties.currentNameSuggestionIsValid = validateNewName(event.suggestedName);
		_characterController.add(characterProperties);
	}

	void _changeCharacter() async
	{
		int changeToCharacterID = 0;
		if(characterProperties.editState == CharacterEditingStates.PrepareNewCharacter)
		{
			changeToCharacterID = await createCharacter(characterProperties.suggestedName);
		}
		else
		{
			await changeCharacter(characterProperties.suggestedName);
		}

		characterProperties.editState = CharacterEditingStates.isNotBeingEdited;
		await refreshCharacterList();
		if(changeToCharacterID == 0)
		{
			_characterController.add(characterProperties);
		}
		else
		{
			this.characterEvents.add(LoadCharacterEvent(id: changeToCharacterID));
		}
	}

	void _deleteCurrentCharacter() async
	{
		await deleteCharacter(characterProperties.id);
		characterProperties.editState = CharacterEditingStates.isNotBeingEdited;
		refreshCharacterList();
		_characterController.add(characterProperties);
		this.characterEvents.add(LoadCharacterEvent(id: defaultCharacter));
	}

	void _finalizeCharacterChange() async
	{
		await loadCharacter(characterRefreshroperties.newUserID);
		characterRefreshroperties.state = CharacterChangeStates.characterEstablished;
		characterProperties.state = CharacterStates.isReady;
		_characterChangeController.add(characterRefreshroperties);
		_characterController.add(characterProperties);
	}

	Future<bool> _setCurrentDate(SetCurrentDate event) async
	{
		await setCurrentDate(event.currentDate);
		_characterController.add(characterProperties);
		return(true);
	}

	Future<bool> setCurrentDate(FaerunDate newCurrentDate) async
	{
		await db.execute('''
		UPDATE [Dates] SET 
		[Year]  = ${newCurrentDate.year.currentYear},
		[Month] = ${newCurrentDate.month},
		[Day]   = ${newCurrentDate.day}
		WHERE [ID] =
		(
			SELECT [CurrentDateID] FROM [Character]
			WHERE 
			[ID] = ${characterProperties.id}
		)
		''');
		characterProperties.currentDate = newCurrentDate;
		return(true);
	}

	Future<bool> _setPartyDate(SetPartyDate event) async
	{
		await db.execute('''
		UPDATE [Dates] SET 
		[Year]  = ${event.partyDate.year.currentYear},
		[Month] = ${event.partyDate.month},
		[Day]   = ${event.partyDate.day}
		WHERE [ID] =
		(
			SELECT [PartyDateID] FROM [Character]
			WHERE 
			[ID] = ${characterProperties.id}
		)
		''');
		characterProperties.partyDate = event.partyDate;
		return(true);
	}
	//endregion

	@override
	void dispose()
	{
		characterEvents.close();
		_characterEventController.close();
		_characterChangeController.close();
		_characterController.close();
	}
}

