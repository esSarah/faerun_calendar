import 'package:faerun_calendar/character_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'main_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'support_faerun_date.dart';
import 'date_selection_bloc.dart';
import 'support_sizing.dart';


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
	double        xf;
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
						Proportions proportions = new Proportions();
						proportions.refreshProportions(context);
						x  = proportions.x;
						xf = proportions.xf;

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
									widgets.add(new Divider());
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
															size  : 20 * xf,
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
																size: 20 * xf,
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
													size : 20 * xf,
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
												leading  : Text(''),
												title    : Text('Version'),
												subtitle : Text('1.0'),
												trailing : IconButton
												(
													icon: Icon
													(
														FontAwesomeIcons.infoCircle,
														size: 20 * xf,
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
														size: 20 * xf,
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
								size  : 80 * xf,
								color : Color.fromARGB(230, 240, 180, 100)
							),
							Column
							(
								children: <Widget>
								[
									AutoSizeText
									(
										'Aktuell gewählter Charakter',
										maxFontSize : 15,
										style       : new TextStyle
										(
											fontFamily : 'NugieRomantic',
											fontWeight : FontWeight.w300,
										)
									),
									SizedBox
									(
										width : (x * xf) - (110 * xf) ,
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
											size : 20 * xf,
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
					// showEditPartyDate(state, characterState, characterState.data.partyDate),
					showEditPartyDate(characterState.data.partyDate),
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
							size: 80 * xf,
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
									width : x * xf - 110 * xf ,
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
												width : x * xf - 110 * xf ,
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
																	size : 20 * xf,
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
																size: 20 * xf,
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
																size: 20 * xf,
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
																size: 20 * xf,
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
				// showEditPartyDate(state, characterState, state.data.partyDate),
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
							size  : 80 * xf,
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
									width : x * xf - 110* xf ,
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
												width: x * xf - 110* xf ,
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
																size : 20 * xf,
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
																size  : 20 * xf,
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
																size  : 20 * xf,
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
				// no show ;-) It is safer for the workflow
				// showEditPartyDate( characterState.data.currentMonth),
			],
		);
	}
	Widget showEditPartyDate
	(
	//	AsyncSnapshot state,
	//	AsyncSnapshot characterState,
		FaerunDate    selectionStart,
	)
	{
		List<Widget> yearDigits  =  digits(10000);
		// Months names are always the same, but I have to get them somewhere once.
		List<Widget> monthDigits =  monthNames(selectionStart.year);

		 partyDateSelection =
			new DateSelectionBloc(selectionStart);

		List<Widget> currentDates = dayNames
		(
			selectionStart.year.months
			[
				selectionStart.month-1
			]
		);

		FixedExtentScrollController _yearsScrollController =
		FixedExtentScrollController
		(
			initialItem: selectionStart.year.currentYear
		);

		FixedExtentScrollController _monthsScrollController =
		FixedExtentScrollController
		(
			initialItem: selectionStart.month-1
		);

		FixedExtentScrollController _daysScrollController =
		FixedExtentScrollController
		(
				initialItem: selectionStart.day-1 //currentDay
		);

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
				return Text('');
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
									currentDates = dayNames
										(dateState.data.selectedMonth);
								}
							);
							return ListTile
							(

							title:
								Column
								(
									children: <Widget>
									[
										Text
										(
											'Aktuelles Datum',
											style: new TextStyle
											(
												color: Colors.black,

												fontSize: 25 * xf,
												fontFamily: 'NugieRomantic',
												fontWeight: FontWeight.w300
											),
										),
										Container(width:1, height:5),
									],
								),
							subtitle:
								Row
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

														fontSize: 20 * xf,
														fontFamily: 'NugieRomantic',
														fontWeight: FontWeight.w300
													),

												),
												SizedBox
												(
													width: 50 * xf,
													height: 140 * xf,
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
														fontSize: 20 * xf,
														fontFamily: 'NugieRomantic',
														fontWeight: FontWeight.w300
													),
												),
												SizedBox
												(
													width  : 150 * xf,
													height : 140 * xf,
													child  : CupertinoPicker
													(
														scrollController      : _monthsScrollController,
														magnification         : 1.2,

														children              : monthDigits,

														itemExtent            : 20, //percent
														useMagnifier          : true,
														squeeze               : 1,
														looping               : true,
														onSelectedItemChanged : (int index)
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
											mainAxisAlignment  : MainAxisAlignment.start,
											crossAxisAlignment : CrossAxisAlignment.center,
											children           : <Widget>
											[
												Text
												(
													'Tag',
													style: new TextStyle
													(
														fontSize   : 20 * xf,
														color      : Colors.black,
														fontFamily : 'NugieRomantic',
														fontWeight : FontWeight.w300
													),
												),
												SizedBox
												(
													width  : 110 * xf,
													height : 140 * xf,
													child  :
													CupertinoPicker
													(
														scrollController  : _daysScrollController,
														magnification     : 1.2,

														children          : currentDates,

														itemExtent        : 20, //height of each item
														useMagnifier      : true,
														squeeze           : 1,
														looping           : true,
														onSelectedItemChanged: (int index)
														{
															partyDateSelection.dateSelectionEvents.add
															(
																new SetDayEvent(dayOfMonth: index+1)
															);
														},
													),
												),
											]
										)
									]
								),
							trailing:
								Column
								(
									children: <Widget>
									[
										IconButton
										(
											icon : Icon
											(
												FontAwesomeIcons.check,
												color : Colors.green,
												size  : 20 * xf,
											),
											onPressed: ()
											{
												_characterBloc.characterEvents.add
												(
														new SetPartyDateEvent(partyDate: dateState.data.selectedDate)
												);
											},
										),
									],
								),
							);
						}
					);
				}
			}
		);
	}

	List<Widget> digits(int number)
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
						fontSize   : 15 * xf,
						color      : Colors.black,
						fontFamily : 'NugieRomantic',
						fontWeight : FontWeight.w300
					),
				),
			);
		}
		return newDigitList;
	}

	List<Widget> monthNames(Year aYear)
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
							fontSize   : 15 * xf,
							color      : Colors.black,
							fontFamily : 'NugieRomantic',
							fontWeight : FontWeight.w300
						),
					)
				);
			}
		);
		return monthWidgets;
	}

	List<Widget> dayNames(Month aMonth)
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
								fontSize: 15 * xf,
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


}
