import 'package:faerun_calendar/character_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'main_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';


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
	MainBloc _mainBloc;
	CharacterBloc _characterBloc;
	bool isInfoVisible = false;
	double x;
	double y;
	bool isPortrait = true;
	String newCharacterName = '';

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
			child:
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
						)
					]
			),
		);
	}

	Widget showEditCurrentCharacterHeader
			(
			AsyncSnapshot state,
			AsyncSnapshot characterState
			)
	{
		return Row // Show edit form for currently selected character
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
		);
	}

	Widget showCreateNewCharacterHeader
	(
		AsyncSnapshot state,
		AsyncSnapshot characterState
	)
	{
		return Row
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
		);
	}
}