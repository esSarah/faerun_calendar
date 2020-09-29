import 'support_database.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'main_bloc.dart';

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

	bool currentNameSuggestionIsValid = false;
	String suggestedName = '';
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
	int                       DefaultCharacter               = 1;
	bool                      characterListIsCurrentlyEdited = false;
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

	CharacterBloc(MainBloc main)
	{
		db = main.mainProperties.db;
		_characterEventController.stream.listen(_mapEventToState);
		_characterController.add(characterProperties);
		_LoadInitialCharacterList();
	}
	void poke()
	{
		_characterController.add(characterProperties);
	}

	//region helper method
	bool ValidateNewName(String nameSuggestion)
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
					CharacterData IgotNothing;

					IgotNothing  = characterProperties.availableCharacters.firstWhere
						(
									(aCharacter) => aCharacter.characterName==nameSuggestion, orElse: () => null
					);
					if(IgotNothing==null)
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
		List<Map> characterData = await db.read
			(
				'SELECT ID, Name FROM Character WHERE Id = ' + byId.toString()
		);

		characterData.forEach
			(
						(char)
				{
					characterProperties.id            = char[ 'ID'   ];
					characterProperties.characterName = char[ 'Name' ];
				}
		);

		await db.read('''
		UPDATE [Value] SET [ValueInteger] = ${characterProperties.id}
		WHERE [Label]='CurrentCharacter' AND [CharacterID]=0
		''');



		return true;
	}

	Future<int> createCharacter(String newName) async
	{
		int newID = await db.executeIntScalar
			(
				'SELECT MAX(ID) AS[MaxId] FROM [Character]'
		);
		newID++;
		await db.read
			(
				'INSERT INTO Character (ID, Name) VALUES('
						+ newID.toString() + ', \'' + db.secure(newName) + '\')'
		);
		/*
		characterProperties.id            = newID;
		characterProperties.characterName = newName;

		 */

		return newID;
	}

	Future<bool> deleteCharacter(int byId) async
	{
		if(byId != DefaultCharacter)
		{
			await db.read('DELETE FROM Value            WHERE CharacterID = ' +
					byId.toString());
			await db.read('DELETE FROM Span WHERE CharacterID = ' +
					byId.toString());
			await db.read('DELETE FROM Character        WHERE          ID = ' +
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
		loadCharacter(DefaultCharacter);
		return true;
	}

//endregion

	//region Event handling
	void _mapEventToState(CharacterEvent event)
	{
		if(event is LoadIinitialCharacterList)
		{
			_LoadInitialCharacterList();
		}

		if (event is LoadCharacterEvent)
		{
			_loadCharacter(event);
		}
		if (event is LoadDefaultCharacterEvent)
		{
			_LoadDefaultCharacter();
		}
		if(event is ChangeModeToNewCharacterEvent)
		{
			_changeModeToNewCharacter();
		}
		if(event is ChangeCharacterEvent)
		{
			_ChangeCharacter();
		}

		if(event is ChangeModeToEditCharacterEvent)
		{
			_changeModeToEditCharacter();
		}

		if(event is CancelCharacterEditEvent)
		{
			_CancelCharacterEdit();
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
	}

	void _LoadInitialCharacterList() async
	{
		await refreshCharacterList();
		_characterController.add(characterProperties);
	}

	void _LoadDefaultCharacter() async
	{
		this.characterEvents.add(LoadCharacterEvent(id: DefaultCharacter));
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

	void _CancelCharacterEdit()
	{
		characterProperties.editState = CharacterEditingStates.isNotBeingEdited;
		_characterController.add(characterProperties);
	}

	void _checkValidNameSuggestion(CharacterEvaluationEvent event)
	{
		characterProperties.currentNameSuggestionIsValid = ValidateNewName(event.suggestedName);
		_characterController.add(characterProperties);
	}

	void _ChangeCharacter() async
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
		this.characterEvents.add(LoadCharacterEvent(id: DefaultCharacter));
	}

	void _finalizeCharacterChange() async
	{
		await loadCharacter(characterRefreshroperties.newUserID);
		characterRefreshroperties.state = CharacterChangeStates.characterEstablished;
		characterProperties.state = CharacterStates.isReady;
		_characterChangeController.add(characterRefreshroperties);
		_characterController.add(characterProperties);
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

