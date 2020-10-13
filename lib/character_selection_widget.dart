import 'package:faerun_calendar/character_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'main_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'support_faerun_date.dart';
import 'date_selection_bloc.dart';


class CharacterSelection extends StatefulWidget
{
	CharacterSelection
	(
		{
			Key key,
			this.mainBloc
		}
	)
	:
	super(key: key);
	final MainBloc mainBloc;

	@override
	_CharacterSelectionState createState() => _CharacterSelectionState();
}

class _CharacterSelectionState extends State<CharacterSelection>
{
	MainBloc      _mainBloc;
	CharacterBloc _characterBloc;
	bool          isInfoVisible    = false;
	double        x;
	double        y;
	bool          isPortrait       = true;
	String        newCharacterName = '';

	int           currentYear;
	int           currentMonth;
	int           currentDay;
	FaerunDate    currentFaerunDate = new FaerunDate();
	DateSelectionBloc partyDateSelection;

	@override
	initState()
	{
		super.initState();
		_mainBloc = widget.mainBloc;
		_characterBloc = _mainBloc.characterBloc;
	}

	Widget build(BuildContext context)
	{
		x = MediaQuery
				.of(context)
				.size
				.width;
		y = MediaQuery
				.of(context)
				.size
				.height;

		isPortrait = (x < y);

		return StreamBuilder
			(
				stream: _mainBloc.master,
				builder:
						(
						BuildContext  context,
						AsyncSnapshot state,
						)
				{
					if
					(
					state.data == null ||
							state.data.status == mainStates.isInitializing
					)
					{
						if (state.data == null)
						{
							_mainBloc.poke(context);
						}
						return Text('');
					}
					else
					{
						return StreamBuilder
							(
								stream  : _characterBloc.character,
								builder :
										(
										BuildContext  context,
										AsyncSnapshot characterState,
										)
								{
									if
									(
									characterState.data == null ||
											characterState.data.state != CharacterStates.isReady
									)
									{
										if (characterState.data == null)
										{
											_mainBloc.characterBloc.poke();
										}
										return Scaffold
											(
											body: Text(''),
										);
									}
									else
									{
										List<Widget> widgets = new List<Widget>();
										if
										(
										characterState.data.editState ==
												CharacterEditingStates.isNotBeingEdited
										)
										{
											widgets.add
												(
													showCharacterHeader
														(
															state,
															characterState
													)
											);
										}
										else
										{
											if
											(
											characterState.data.editState ==
													CharacterEditingStates.ChangeCurrentCharacter
											)
											{
												widgets.add
													(
														showEditCurrentCharacterHeader
															(
																state,
																characterState
														)
												);
											}
											else
											{
												widgets.add
													(
														showCreateNewCharacterHeader
															(
																state,
																characterState
														)
												);
											}
										}

										characterState.data.availableCharacters.forEach
											(
												(characterFromList)
												{
													int    currentID   = characterFromList.id;
													String currentName = characterFromList.characterName;

													if (currentID != characterState.data.id)
													{
														widgets.add
														(
															new ListTile
															(
																leading:
																Icon
																	(
																	FontAwesomeIcons.userSecret,
																	size  : 20,
																	color : Colors.white,
																),

																title:
																Text
																(
																	currentName,
																	style: TextStyle
																	(
																		fontFamily : 'NugieRomantic',
																		fontWeight : FontWeight.w300,
																	)
																),

																trailing:
																IconButton
																	(
																	icon: Icon
																		(
																		FontAwesomeIcons.play,
																		size: 20,
																	),
																	onPressed: ()
																	{
																		_mainBloc.characterBloc.characterEvents.add
																			(
																				LoadCharacterEvent(id: currentID)
																		);
																	},
																)
															)
														);
													}
												}
										);
										if (characterState.data.availableCharacters.length > 1)
										{
											widgets.add
												(
													new Divider()
											);
										}
										widgets.add
											(
											new ListTile
												(
													leading  : Text(''),
													title    : Text
														(
															'Erstelle ',
															style: TextStyle
																(
																fontFamily : 'NugieRomantic',
																fontWeight : FontWeight.w300,
															)
													),
													subtitle : Text
														(
															'neuen Charakter',
															style: TextStyle
																(
																fontFamily : 'NugieRomantic',
																fontWeight : FontWeight.w300,
															)
													),
													trailing : IconButton
														(
														icon: Icon
															(
															FontAwesomeIcons.userPlus,
															size : 20,
														),
														onPressed: ()
														{
															_mainBloc.characterBloc.characterEvents.add
																(
																	ChangeModeToNewCharacterEvent()
															);
														},
													)
											),
										);

// Info tile
										if (isInfoVisible)
										{
											widgets.add
												(
												new ListTile
													(
														leading: Text(''),
														title: Text('Version'),
														subtitle: Text('Beta 15'),
														trailing: IconButton
															(
															icon: Icon
																(
																FontAwesomeIcons.infoCircle,
																size: 20,
																color: Colors.white,
															),
															onPressed: ()
															{
																setState
																	(
																				()
																		{
																			isInfoVisible = !isInfoVisible;
																		}
																);
															},
														)
												),
											);
										}
										else
										{
											widgets.add
												(
												new ListTile
													(
														leading  : Text(''),
														title    : Text(''),
														subtitle : Text(''),
														trailing : IconButton
															(
															icon : Icon
																(
																FontAwesomeIcons.infoCircle,
																size: 20,
																color: Colors.white10,
															),
															onPressed: ()
															{
																setState
																	(
																				()
																		{
																			isInfoVisible = !isInfoVisible;
																		}
																);
															},
														)
												),
											);
										}

										return Scaffold
											(
												body: ListView.builder
													(
													itemCount: widgets.length,
													itemBuilder: (context, index)
													{
														return widgets[index];
													},
												)
										);
									}
								}
						);
					}
				}
		);
	}

	Widget showCharacterHeader
	(
		AsyncSnapshot state,
		AsyncSnapshot characterState
	)
	{
		return Container
		(
			child:Column
			(
				children: <Widget>
				[
					Row
					( // show selected character
						children: <Widget>
						[
							Icon
							(
								Icons.portrait,
								size  : 80,
								color : Color.fromARGB(230, 240, 180, 100)
							),
							Column
							(
								children: <Widget>
								[
									AutoSizeText
									(
										'Aktuel gewählter Charakter',
										maxFontSize : 15,
										style       : new TextStyle
										(
											fontFamily : 'NugieRomantic',
											fontWeight : FontWeight.w300,
										)
									),
									SizedBox
									(
										width : x - 110,
										child :
										AutoSizeText
										(
											state.data.characterProperties.characterName,
											maxLines : 3,
											style    : new TextStyle
											(
												fontSize   : 30,
												fontFamily : 'NugieRomantic',
												fontWeight : FontWeight.w300,
											)
										),
									),
									IconButton
									(
										icon: Icon
										(
											FontAwesomeIcons.userEdit,
											size : 20,
										),
										onPressed: ()
										{
											_mainBloc.characterBloc.characterEvents.add
											(
												ChangeModeToEditCharacterEvent()
											);
										},
									),
								]
							),
						]
					),
					showEditPartyDate(state, characterState),
				],
			)
		);
	}

	Widget showEditCurrentCharacterHeader
	(
		AsyncSnapshot state,
		AsyncSnapshot characterState
	)
	{
		return Column
			(
			children: <Widget>
			[
				Row // Show edit form for currently selected character
				(
					children: <Widget>
					[
						Icon
						(
							FontAwesomeIcons.userEdit,
							size: 80,
							color : Color.fromARGB(230, 240, 180, 100),
						),

						Column
						(
							children: <Widget>
							[
								AutoSizeText
								(
									characterState.data.id == _mainBloc.characterBloc.defaultCharacter
									?
										'Charakter bearbeiten'
									:
										'Charakter bearbeiten oder löschen',

									maxFontSize : 15,
									style       : new TextStyle
									(
										fontFamily : 'NugieRomantic',
										fontWeight : FontWeight.w300,
									)
								),
								SizedBox
								(
									width : x - 110,
									child :
									Column
									(
										crossAxisAlignment: CrossAxisAlignment.end,
										children: <Widget>
										[
											TextField
											(
												onChanged: (value)
												{
													newCharacterName = value;
													_mainBloc.characterBloc.characterEvents.add
													(
														CharacterEvaluationEvent
														(
															suggestedName : newCharacterName
														)
													);
												},
											),
											Text
											(
												characterState.data.characterName,
												textScaleFactor : .9,
												style: new TextStyle
												(
													fontStyle  : FontStyle.italic,
													color      : Colors.blueGrey,
													fontFamily : 'NugieRomantic',
													fontWeight : FontWeight.w300,
												),
											),
											SizedBox
											(
												width : x - 110,
												child : Row
												(
													crossAxisAlignment: CrossAxisAlignment.end,
													children: <Widget>
													[

														characterState.data.id !=
																_mainBloc.characterBloc.defaultCharacter
														?
															IconButton
															(
																icon: Icon
																(
																	FontAwesomeIcons.trash,
																	color: Colors.red,
																	size : 20,
																),
																onPressed: ()
																{
																	_mainBloc.characterBloc.characterEvents.add
																		(
																			DeleteCurrentCharacterEvent()
																	);
																},
															)
														:
															Text(''),

														IconButton
														(
															icon: Icon
															(
																FontAwesomeIcons.ban,
																size: 20,
															),
															onPressed: ()
															{
																_mainBloc.characterBloc.characterEvents.add
																(
																	CancelCharacterEditEvent()
																);
															},
														),

														characterState.data.currentNameSuggestionIsValid
													?
														IconButton
														(
															icon: Icon
															(
																FontAwesomeIcons.check,
																color: Colors.green,
																size: 20,
															),

															onPressed: ()
															{
																_mainBloc.characterBloc.characterEvents.add
																(
																	ChangeCharacterEvent()
																);
															}
														)
													:
														IconButton
														(
															icon: Icon
															(
																FontAwesomeIcons.check,
																color: Colors.grey,
																size: 20,
															),
														),
													]
												),
											),
										],
									),
								),
							]
						)
					]
				),
				showEditPartyDate(state, characterState),
			],
		);
	}

	Widget showCreateNewCharacterHeader
	(
		AsyncSnapshot state,
		AsyncSnapshot characterState
	)
	{
		return Column
		(
			children: <Widget>
			[
				Row
				(
				// show edit form for new character
					children: <Widget>
					[
						Icon
						(
							FontAwesomeIcons.userPlus,
							size  : 80,
							color : Color.fromARGB(230, 240, 180, 100),
						),
						Column
						(
							children: <Widget>
							[
								AutoSizeText
								(
									'Neuen Charakter erstellen',
									maxFontSize : 15,
									style: new TextStyle
									(
										fontFamily : 'NugieRomantic',
										fontWeight : FontWeight.w300,
									)
								),
								SizedBox
								(
									width : x - 110,
									child :
									Column
									(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: <Widget>
										[
											TextField
											(
												onChanged: (value)
												{
													newCharacterName = value;
													_mainBloc.characterBloc.characterEvents.add
													(
														CharacterEvaluationEvent
														(
															suggestedName: newCharacterName
														)
													);
												},
											),
											SizedBox
											(
												width: x - 110,
												child: Row
												(
													crossAxisAlignment: CrossAxisAlignment.end,
													children: <Widget>
													[
														IconButton
														(
															icon: Icon
															(
																FontAwesomeIcons.ban,
																size : 20,
															),
															onPressed: ()
															{
																_mainBloc.characterBloc.characterEvents.add
																(
																	CancelCharacterEditEvent()
																);
															},
														),

														characterState.data.currentNameSuggestionIsValid
													?
														IconButton
														(
															icon: Icon
															(
																FontAwesomeIcons.check,
																color : Colors.green,
																size  : 20,
															),

															onPressed: ()
															{
																_mainBloc.characterBloc.characterEvents.add
																(
																	ChangeCharacterEvent()
																);
															}
														)
													:
														IconButton
														(
															icon: Icon
															(
																FontAwesomeIcons.check,
																color : Colors.grey,
																size  : 20,
															),
														),
													]
												),
											),
										],
									),
								),
							]
						)
					]
				),
				showEditPartyDate(state, characterState),
			],
		);
	}
	Widget showEditPartyDate
	(
		AsyncSnapshot state,
		AsyncSnapshot characterState
	)
	{
		List<Widget> yearDigits  =  Digits(10000);
		// Months names are always the same, but I have to get them somewhere once.
		List<Widget> monthDigits =  MonthNames(characterState.data.partyDate.year);

		 partyDateSelection =
			new DateSelectionBloc(characterState.data.partyDate);

		List<Widget> currentDates = DayNames
		(
				characterState.data.partyDate.year.months
			[
				characterState.data.partyDate.month-1
			]
		);
		currentDay = characterState.data.partyDate.day;


		FixedExtentScrollController _yearsScrollController =
		FixedExtentScrollController
		(
			initialItem: characterState.data.partyDate.year.currentYear
		);

		FixedExtentScrollController _monthsScrollController =
		FixedExtentScrollController
		(
			initialItem: characterState.data.partyDate.month-1
		);

		FixedExtentScrollController _daysScrollController =
		FixedExtentScrollController
		(
				initialItem: characterState.data.partyDate.day-1 //currentDay
		);

		CupertinoPicker refreshableDayPicker =
		dayPicker(currentDates);

		return StreamBuilder
		(
			stream: partyDateSelection.dateSelection,
			builder:
			(
				BuildContext  context,
				AsyncSnapshot dateState,
			)
		{
			if (dateState.data==null||dateState.data.status != DateSelectionStates.ready)
			{
				partyDateSelection.poke();
				return Text('Noch nicht');
			}
			else
			{
return StatefulBuilder
				(
					builder: (BuildContext context, StateSetter setState)
						{
							setState
							(
								()
								{
									currentDates = DayNames
										(dateState.data.selectedMonth);
									refreshableDayPicker =
											dayPicker(currentDates);
								}
							);
							return Row
							(
								mainAxisAlignment: MainAxisAlignment.start,
								children: <Widget>
								[
									Column
									(
										mainAxisAlignment: MainAxisAlignment.start,

										crossAxisAlignment: CrossAxisAlignment.center,
										children: <Widget>
										[
											Text
											(
												'Jahr',
												style: new TextStyle
												(
													color: Colors.black,

													fontSize: 20,
													fontFamily: 'NugieRomantic',
													fontWeight: FontWeight.w300
												),

											),
											SizedBox
											(
												width: 70,
												height: 100,
												child: CupertinoPicker
												(
													scrollController: _yearsScrollController,
													magnification: 1.2,

													children: yearDigits,
													itemExtent: 20,
													//height of each item
													useMagnifier: true,

													squeeze: 1,

													looping: false,
													onSelectedItemChanged: (int index)
													{
														partyDateSelection.dateSelectionEvents.add
														(
															new SetYearEvent(newYear: index)
														);
														print(index);
													},
												),
											),
										],
									),

									Column
									(
										mainAxisAlignment: MainAxisAlignment.start,

										crossAxisAlignment: CrossAxisAlignment.center,
										children: <Widget>
										[
											Text
											(
												'Monat',
												style: new TextStyle
												(
													color: Colors.black,
													fontSize: 20,
													fontFamily: 'NugieRomantic',
													fontWeight: FontWeight.w300
												),
											),
											SizedBox
											(
												width: 170,
												height: 100,
												child: CupertinoPicker
												(
													scrollController: _monthsScrollController,
													magnification: 1.2,

													children: monthDigits,

													itemExtent: 20,
													//height of each item
													useMagnifier: true,
													squeeze: 1,
													looping: true,
													onSelectedItemChanged: (int index)
													{
														partyDateSelection.dateSelectionEvents.add
														(
															new SetMonthEvent(newMonth: index+1)
														);

														print(index);
													},
												),
											),
										]
									),
									Column
									(
										mainAxisAlignment: MainAxisAlignment.start,
										crossAxisAlignment: CrossAxisAlignment.center,
										children: <Widget>
										[
											Text
											(
												'Tag',
												style: new TextStyle
												(
													fontSize: 20,
													color: Colors.black,
													fontFamily: 'NugieRomantic',
													fontWeight: FontWeight.w300
												),
											),
											SizedBox
											(
												width: 170,
												height: 100,
												child: refreshableDayPicker,
											),
										]
									)
								]
							);
						}
					);
				}
			}
		);
	}

	List<Widget> Digits(int number)
	{
		print('Digits called for ' + number.toString() + ' years');
		List<Widget> newDigitList = new List<Widget>();
		for (int currentDigit = 0; currentDigit < number; currentDigit++)
		{
			newDigitList.add
			(
				new Text
				(
					currentDigit.toString(),
					textScaleFactor: .8,
					style: new TextStyle
					(
						color: Colors.black,
						fontFamily : 'NugieRomantic',
						fontWeight: FontWeight.w300
					),
				),
			);
		}
		return newDigitList;
	}

	List<Widget> MonthNames(Year aYear)
	{
		print('MonthNames called for year: ' + aYear.currentYear.toString());
		List<Widget> monthWidgets = new List<Widget>();
		aYear.months.forEach
		(
			(element)
			{
				monthWidgets.add
				(
					Text
					(
						element.label,
						textScaleFactor: .8,
						style: new TextStyle
						(
							color: Colors.black,
							fontFamily : 'NugieRomantic',
							fontWeight: FontWeight.w300
						),
					)
				);
			}
		);
		return monthWidgets;
	}

	List<Widget> DayNames(Month aMonth)
	{
		print('DayNames called for month ' + aMonth.label +
				' of length ' + aMonth.days.length.toString());
		List<Widget> _dayNames = new List<Widget>();
		aMonth.days.forEach
		(
			(element)
			{
				_dayNames .add
				(
					Text
					(
						element.label,
						textScaleFactor: .8,
						style: new TextStyle
						(
							color: Colors.black,
							fontFamily : 'NugieRomantic',
							fontWeight: FontWeight.w300
						),
					)
				);
			}
		);
		print('Daynames done');
		return _dayNames;
	}

	CupertinoPicker dayPicker(List<Widget> currentDates)
	{

		if(currentDay>currentDates.length)
		{
			currentDay = currentDates.length;
		}
		FixedExtentScrollController _daysScrollController =
		FixedExtentScrollController
		(
			initialItem: currentDay
		);
		return CupertinoPicker
		(
			scrollController: _daysScrollController,
			magnification: 1.2,

			children: currentDates,

			itemExtent: 20, //height of each item
			useMagnifier: true,

			squeeze: 1,

			looping: true,
			onSelectedItemChanged: (int index)
			{
				partyDateSelection.dateSelectionEvents.add
				(
					new SetDayEvent(dayOfMonth: index+1)
				);
			},
		);
	}

}
