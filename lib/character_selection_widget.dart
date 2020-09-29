import 'package:faerun_calendar/character_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'support_sizing.dart'  as sizing;
import 'main_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
	bool isInfoVisible;

	@override
	initState()
	{
		isInfoVisible = false;
		super.initState();
		_mainBloc      =  widget.mainBloc;
		_characterBloc = _mainBloc.characterBloc;
		print('Character Bloc is ' + _characterBloc.toString());
	}

	Widget build(BuildContext context)
	{
		return StreamBuilder
		(
			stream: _mainBloc.master,
			builder:
			(
				BuildContext context,
				AsyncSnapshot state,
			)
			{
				if (state.data == null || state.data.status == mainStates.isInitializing)
				{
					if (state.data == null)
					{
						_mainBloc.poke(context);
					}

					return Text('');
				}
				else
				{
					print('At least here');
					return StreamBuilder
					(
						stream: _characterBloc.character,
						builder:
						(
							BuildContext context,
							AsyncSnapshot characterState,
						)
						{
							if (characterState.data == null ||
									characterState.data.state != CharacterStates.isReady)
							{
								if (characterState.data == null)
								{
									_mainBloc.characterBloc.poke();
								}
								return Scaffold
								(
									body:Text(''),
								);
							}
							else
							{
								List<Widget> DrawerWidgets = new List<Widget>();
								String NewCharacterName = '';
								bool isValid = false;

								DrawerWidgets.add
								(
									LayoutBuilder
									(
										builder: (context, constraints)
										{
											return
												characterState.data.editState !=
														CharacterEditingStates.isNotBeingEdited ?
												Container
												(
													child:
													characterState.data.editState ==
															CharacterEditingStates
																	.ChangeCurrentCharacter ?
													Row // Show edit form for currently selected character
													(
														children: <Widget>
														[
															Icon
															(
																FontAwesomeIcons.userEdit,
																size: 80,
																color: Colors.orange,
															),
															Column
															(
																	children: <Widget>
																	[
																		AutoSizeText
																			(
																			characterState.data.id ==
																					_mainBloc.characterBloc
																							.DefaultCharacter
																					?
																			'Edit Character'
																					:
																			'Edit or delete Character',
																			maxFontSize: 15,
																			style: new TextStyle
																				(
																					fontWeight: FontWeight.w300
																			),
																		),
																		SizedBox
																			(
																			width: constraints
																					.constrainWidth() - 110,
																			//height: constraints.constrainHeight()-90,
																			child:
																			Column
																				(
																				crossAxisAlignment: CrossAxisAlignment
																						.end,
																				children: <Widget>
																				[
																					TextField
																						(
																						onChanged: (value)
																						{
																							NewCharacterName = value;
																							_mainBloc.characterBloc
																									.characterEvents.add
																								(
																									CharacterEvaluationEvent
																										(
																											suggestedName: NewCharacterName
																									)
																							);
																						},
																					),
																					Text
																						(
																						characterState.data
																								.characterName,
																						textScaleFactor: .9,
																						style: new TextStyle
																							(
																								fontStyle: FontStyle
																										.italic,
																								color: Colors.blueGrey,
																								fontWeight: FontWeight
																										.w300
																						),
																					),
																					SizedBox
																						(
																						width: constraints
																								.constrainWidth() - 110,
																						//padding: const EdgeInsets.symmetric(vertical: 16.0),
																						child: Row
																							(
																								crossAxisAlignment: CrossAxisAlignment
																										.end,
																								children: <Widget>
																								[
																									characterState.data
																											.id != _mainBloc
																											.characterBloc
																											.DefaultCharacter
																											? IconButton
																										(
																										icon: Icon
																											(
																											FontAwesomeIcons
																													.trash,
																											color: Colors.red,
																											size: 20,
																										),
																										onPressed: ()
																										{
																											_mainBloc
																													.characterBloc
																													.characterEvents
																													.add
																												(
																													DeleteCurrentCharacterEvent()
																											);
																										},
																									) : Text(''),

																									IconButton
																										(
																										icon: Icon
																											(
																											FontAwesomeIcons.ban,
																											size: 20,
																										),
																										onPressed: ()
																										{
																											_mainBloc
																													.characterBloc
																													.characterEvents
																													.add
																												(
																													CancelCharacterEditEvent()
																											);
																										},
																									),

																									characterState.data
																											.currentNameSuggestionIsValid
																											?
																									IconButton
																										(
																											icon: Icon
																												(
																												FontAwesomeIcons
																														.check,
																												color: Colors
																														.green,
																												size: 20,
																											),

																											onPressed: ()
																											{
																												_mainBloc
																														.characterBloc
																														.characterEvents
																														.add
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
																											FontAwesomeIcons
																													.check,
																											color: Colors
																													.grey,
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
													)
															:
													Row
													(
														// show edit form for new character
															children: <Widget>
															[
																Icon
																	(
																	FontAwesomeIcons.userPlus,
																	size: 80,
																	color: Colors.orange,
																),
																Column
																	(
																		children: <Widget>
																		[
																			AutoSizeText
																				(
																				'Create new Character',
																				maxFontSize: 15,
																				style: new TextStyle
																					(
																						fontWeight: FontWeight.w300
																				),
																			),
																			SizedBox
																				(
																				width: constraints
																						.constrainWidth() - 110,
																				child:
																				Column
																					(
																					crossAxisAlignment: CrossAxisAlignment
																							.start,
																					children: <Widget>
																					[
																						TextField
																							(
																							onChanged: (value)
																							{
																								NewCharacterName = value;
																								_mainBloc.characterBloc
																										.characterEvents.add
																									(
																										CharacterEvaluationEvent
																											(
																												suggestedName:
																												NewCharacterName
																										)
																								);
																							},
																						),
																						SizedBox
																							(
																							width: constraints
																									.constrainWidth() - 110,
																							child: Row
																								(
																									crossAxisAlignment: CrossAxisAlignment
																											.end,
																									children: <Widget>
																									[
																										IconButton
																											(
																											icon: Icon
																												(
																												FontAwesomeIcons
																														.ban,
																												size: 20,
																											),
																											onPressed: ()
																											{
																												_mainBloc
																														.characterBloc
																														.characterEvents
																														.add
																													(
																														CancelCharacterEditEvent()
																												);
																											},
																										),

																										characterState.data
																												.currentNameSuggestionIsValid
																												?
																										IconButton
																											(
																												icon: Icon
																													(
																													FontAwesomeIcons
																															.check,
																													color: Colors
																															.green,
																													size: 20,
																												),

																												onPressed: ()
																												{
																													_mainBloc
																															.characterBloc
																															.characterEvents
																															.add
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
																												FontAwesomeIcons
																														.check,
																												color: Colors
																														.grey,
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
												)
												:
												Container
												(
													child:
													Row
														( // show selected character
															children: <Widget>
															[
																Icon
																	(
																	FontAwesomeIcons.userSecret,
																	size: 80,
																	color: Colors.orange,
																),
																Column
																	(
																		children: <Widget>
																		[
																			AutoSizeText
																			(
																			'Currently selected Character',
																			maxFontSize: 15,
																			style: new TextStyle
																				(
																					fontWeight: FontWeight.w300
																				),
																			),
																			SizedBox
																			(
																				width: constraints
																						.constrainWidth() - 110,
																				height: constraints
																						.constrainHeight() - 90,
																				child:
																				AutoSizeText
																				(
																					state.data.characterProperties
																							.characterName,
																					maxLines: 3,
																					style: new TextStyle
																						(
																							fontSize: 30,
																							fontWeight: FontWeight.w300
																					),
																				),
																			),
																			IconButton
																				(
																				icon: Icon
																					(
																					FontAwesomeIcons.userEdit,
																					size: 20,
																				),
																				onPressed: ()
																				{
																					_mainBloc.characterBloc
																							.characterEvents.add
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
									),
								);

								characterState.data.availableCharacters.forEach
								(
									(characterFromList)
									{
										int currentID = characterFromList.id;
										String currentName = characterFromList.characterName;
										print(characterFromList.characterName + ' ' +
												characterFromList.id.toString() + ' ' +
												characterState.data.id.toString());
										if (currentID != characterState.data.id)
										{
											DrawerWidgets.add
											(
												new ListTile
												(
													leading:
													Icon
													(
														FontAwesomeIcons.userSecret,
														size: 20,
														color: Colors.white,
													),

													title:
													Text(currentName),

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
									DrawerWidgets.add
									(
										new Divider()
									);
								}
								DrawerWidgets.add
								(
									new ListTile
									(
										leading: Text(''),
										title: Text('Create '),
										subtitle: Text('New character to track'),
										trailing: IconButton
										(
											icon: Icon
											(
												FontAwesomeIcons.userPlus,
												size: 20,
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
									DrawerWidgets.add
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
									DrawerWidgets.add
									(
										new ListTile
										(
											leading: Text(''),
											title: Text(''),
											subtitle: Text(''),
											trailing: IconButton
											(
												icon: Icon
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

								return Scaffold(body: ListView
								(
									children: DrawerWidgets,
								));
							}
						}
					);
				}
			}
		);
	}
}
