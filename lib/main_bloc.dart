import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'character_selection_bloc.dart';
import 'support_database.dart';
import 'support_faerun_date.dart';

enum mainStates
{
	isInitializing,
	isUserSelected,
	dateChangeIsPending,
	dateChangeIsConfirmed,
}

class MainProperties
{
	FaerunDate currentMonth = new FaerunDate();
	//FaerunDate partyDate    = new FaerunDate();

	double currentWidth    = 0;
	double currentHeight   = 0;

	double xFactor = 0;
	double yFactor = 0;

	double xReal = 0;
	double yReal = 0;

	// Design width and height for Pixel 2 emulator
	// as orientation
	double originalWidth   = 411.42857142857144;
	double originalHeight  = 683.4285714285714;

	double multiplyWidthBy = 1;

	mainStates  status          = mainStates.isInitializing;
	String      backgroundImage = 'assets/spring.png';

	List<Year>          years               = new List<Year>();
	CharacterProperties characterProperties = new CharacterProperties();
	DatabaseManager     db                  = new DatabaseManager();
}

abstract class MainEvent
{
	MainEvent([List props = const[]]);
}

class MainInitializeEvent extends MainEvent
{

}

class MainChangedCharacterEvent extends MainEvent
{
	final int newCharacterID;

	MainChangedCharacterEvent
	(
		{@required this.newCharacterID}
	) : super([newCharacterID]);
}

class MainYearSelectedEvent extends MainEvent
{
	final int newYear;
	MainYearSelectedEvent
	(
		{@required this.newYear}
	) : super([newYear]);
}

class MainMonthSelectedEvent extends MainEvent
{
	final int newMonth;
	MainMonthSelectedEvent
	(
		{@required this.newMonth}
	) : super([newMonth]);
}

class MainDaySelectedEvent extends MainEvent
{
	final int newDay;
	MainDaySelectedEvent
	(
		{@required this.newDay}
	) : super([newDay]);
}

class MainBloc
{

	MainProperties mainProperties = new MainProperties();
	final DatabaseManager  db     = new DatabaseManager();
	CharacterBloc          characterBloc;
	StreamSubscription     characterBlocSubscription;
	List<Function>         informOfPendingCharacterChange = new List<Function>();


	final _mainController = StreamController<MainProperties>.broadcast();
	Stream<MainProperties> get master => _mainController.stream;

	final _mainEventController = StreamController<MainEvent>();
	// in dieses Sammelbecken kommen die Events
	Sink<MainEvent> get mainEvents =>
			_mainEventController.sink;

	MainBloc()
	{
		mainProperties = new MainProperties();
		characterBloc  = new CharacterBloc(this);
		_mainEventController.stream.listen(_mapEventToState);

		characterBlocSubscription = characterBloc.characterChange.listen
		(
			(characterChangeState) async
			{
				if
				(
					characterChangeState.state == CharacterChangeStates.characterSelected
				)
				{
					if(characterChangeState.oldUuserID!=0)
					{
						await Future.wait
						(
							// in case you might wonder... this is
							// not exactly neccessary here,
							// the whole character management is pulled form
							// another project where the character selection
							// is in a drawer and a character change effects
							// many blocs. More work to scratch it out
							// and than maybe even put it back in in case
							// the layout of this app changes.
							//
							// Right now the callback collection is
							// just always empty.
							informOfPendingCharacterChange.map<Future>((m)=>m())
						);
					}
					characterBloc.characterEvents.add
					(
						OthersAreReadyForCharacterChange()
					);
				}

				if
				(
					characterChangeState.state ==
						CharacterChangeStates.characterEstablished
				)
				{
					// masterProperties.characterProperties = characterState;
					// needs a lot more of adjustment if this doesn't work instead:
					mainProperties.characterProperties =
						characterBloc.characterProperties;
					await setUserSelected();
				}

				await _setBackground();
			}
		);
		this.mainEvents.add( new MainInitializeEvent() );

		print('created new MainBloc ' + characterBloc.characterProperties.characterName);
	}

	Future<bool> setUserSelected() async
	{
		if(mainProperties.characterProperties.id!=0)
		{
			mainProperties.currentMonth.year  =
					characterBloc.characterProperties.currentDate.year;
			mainProperties.currentMonth.month =
				characterBloc.characterProperties.currentDate.month;

			mainProperties.status = mainStates.isUserSelected;
			_mainController.add(mainProperties);
		}
		return true;
	}

	Future<int> findCharacter() async
	{
		int currentUserID = await db.executeIntScalar
		(
				'''
			SELECT 
				[ValueInteger] AS No FROM [Value] 
			WHERE 
				[CharacterID] = 0 AND 
				[Label]       = 'CurrentCharacter'
			'''
		);
		characterBloc.characterEvents.add
		(
			new LoadCharacterEvent(id: currentUserID)
		);
		return currentUserID;
	}


	void poke(BuildContext context)
	{
		mainProperties.currentHeight   = MediaQuery.of(context).size.height;
		mainProperties.currentWidth    = MediaQuery.of(context).size.width;
		mainProperties.multiplyWidthBy =
				mainProperties.currentWidth / mainProperties.currentHeight;
		mainProperties.xFactor         =
				mainProperties.currentWidth / mainProperties.originalWidth;
		mainProperties.yFactor         =
				mainProperties.currentHeight / mainProperties.originalHeight;

		mainProperties.xReal =
			mainProperties.currentWidth *
			MediaQuery.of(context).devicePixelRatio;

		mainProperties.yReal =
				mainProperties.currentHeight *
				MediaQuery.of(context).devicePixelRatio;

		// mainProperties.status = mainStates.isUserSelected; // todo: delete when implement
		_mainController.add(mainProperties);
	}

	Future<bool> _mapEventToState(MainEvent event) async
	{
		if(event is MainMonthSelectedEvent)
		{
			await _mapEventToMonthSelected(event);
		}
		if(event is MainYearSelectedEvent)
		{
			await _mapEventToYearSelected(event);
		}
		if(event is MainInitializeEvent)
		{
			await _mapEventToInitialze(event);
		}
		print(mainProperties.status.toString());
		return true;
	}

	Future<bool> _mapEventToMonthSelected
	(
		MainMonthSelectedEvent mainMonthSelectedEvent
	)
	async
	{
		int _monthsOverAll = mainMonthSelectedEvent.newMonth;
		int _year = (_monthsOverAll / 12).floor();
		mainProperties.currentMonth.year.initYear(_year);
		mainProperties.currentMonth.month = _monthsOverAll-(_year*12);
		mainProperties.currentMonth.month++;
		mainProperties.currentMonth.day = 1;
		await _setBackground();
		await _saveCurrentDate();
		_mainController.add(mainProperties);
		return true;
	}

	Future<bool> _setBackground() async
	{
		if
		(
			mainProperties.currentMonth.month == 12
			||
			mainProperties.currentMonth.month <= 2
		)
		{
			mainProperties.backgroundImage = 'assets/winter.png';
		}
		if
		(
			mainProperties.currentMonth.month >= 3
			&&
			mainProperties.currentMonth.month <= 5
		)
		{
			mainProperties.backgroundImage = 'assets/spring.png';
		}
		if
		(
			mainProperties.currentMonth.month >= 6
			&&
			mainProperties.currentMonth.month <= 8
		)
		{
			mainProperties.backgroundImage = 'assets/summer.png';
		}
		if
		(
			mainProperties.currentMonth.month >=  9
			&&
			mainProperties.currentMonth.month <= 11
		)
		{
			mainProperties.backgroundImage = 'assets/autumn.png';
		}
		return true;
	}

	Future<bool> _saveCurrentDate() async
	{
		await this.characterBloc.setCurrentDate(mainProperties.currentMonth);
		return true;
	}

	Future<bool> _mapEventToYearSelected(MainYearSelectedEvent mainYearSelectedEvent) async
	{
		int yearToLoad = mainYearSelectedEvent.newYear;
		bool existsAlready = false;
		for(int i=0; i < mainProperties.years.length; i++)
		{
			if(mainProperties.years[i].currentYear==yearToLoad)
			{
				existsAlready = true;
				break;
			}
		}
		if
		(
			!existsAlready
		)
		{
			Year _newYear = new Year();
			await _newYear.initYear(yearToLoad);
			mainProperties.years.add(_newYear);
		}

		_mainController.add(mainProperties);
		return true;
	}

	Future<bool> _mapEventToInitialze
	(
		MainInitializeEvent mainInitializeEvent
	)
	async
	{
		int currentCharacter = 0;
		currentCharacter     = await findCharacter();
		if(currentCharacter == 0)
		{
			characterBloc.characterEvents.add(LoadDefaultCharacterEvent());
		}
		else
		{
			setUserSelected();
		}
		return true;
	}

	@override
	void dispose()
	{
		characterBlocSubscription.cancel();
		_mainEventController.close();
	}
}