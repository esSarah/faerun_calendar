import 'package:flutter/material.dart';
import 'main_bloc.dart';
import 'support_routing.dart' ;
import 'support_faerun_date.dart';

class DayWidget extends StatefulWidget
{
	DayWidget
	(
		{
			Key key,
			this.dayArguments
		}
	) : super(key: key);

	final DayArguments dayArguments;

	@override
	_DayWidget createState() => _DayWidget();
}

class _DayWidget extends State<DayWidget>
{
	DayArguments _dayArguments;
	MainBloc     mainBloc;
	int          index;
	Year thisYear;
	Year year;
	Month month;

	@override
	Widget build(BuildContext context)
	{
		_dayArguments = widget.dayArguments;
		index = _dayArguments.index;
		mainBloc = _dayArguments.mainBloc;
		year = _dayArguments.year;
		month = _dayArguments.month;
		double x;
		double y;
		double xy;

		return StreamBuilder
		(
			stream: mainBloc.master,
			builder:
			(
				BuildContext context,
				AsyncSnapshot state,
			)
			{
				if
				(
					state.data == null ||
					state.data.status == mainStates.isInitializing
				)
				{
					mainBloc.poke(context);
					return Text('buh');
				}
				else
				{
					x = state.data.currentWidth;
					y = state.data.currentHeight;
					xy = state.data.multiplyWidthBy;
					return Scaffold
					(
						body: Column
							(
								children: <Widget>
								[
									Container
										(
										width  : 1.0,
										height : 30.0 * xy,
									),
									Stack
									(
											children: <Widget>
											[
												Column
												(
												children: <Widget>
													[
													Container(height: 100 * xy, width : 1,),
												Image
													(
													image          :
													AssetImage(state.data.backgroundImage),
													width          : x * xy,
													height         : y - (150*xy),
													gaplessPlayback: false,
												),
											],
										),
										Column
										(
											children: <Widget>
											[
												Text
												(
													month.label,
													style: TextStyle
													(
														fontSize: 40,
														fontFamily: 'NugieRomantic',
														fontWeight: FontWeight.w300,
													)
												),
												Text
												(
													year.currentYear.toString(),
													style: TextStyle
													(
														fontSize: 40,
														fontFamily: 'NugieRomantic',
														fontWeight: FontWeight.w300,
													)
												),
												Text
												(
													month.description,
													style: TextStyle
													(
														fontSize: 20,
														fontFamily: 'NugieRomantic',
														fontWeight: FontWeight.w300,
													)
												),
												Center
												(
													child: Hero
													(
														tag: 'Day' + year.currentYear.toString() + month.label +
																index.toString(),
														child: Container
														(
															width: 130.0,
															height: 150.0,

															color: Colors.orangeAccent,
															child: InkWell
															(
																onTap: ()
																{
																	Navigator.pushNamed(context, '/');
																},
																child: Text
																(
																	'Day ',
																	style: TextStyle
																	(
																		fontFamily: 'NugieRomantic',
																		fontSize: 20,
																	)
																),
															),
														),
													),
												),
											],
										),
									],
								),
							],
						),
					);
				}
			}
		);
	}
}