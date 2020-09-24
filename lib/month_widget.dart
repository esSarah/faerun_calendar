import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'main_bloc.dart';

class MonthView extends StatefulWidget
{
	const MonthView
	(
		{
			Key      key,
			MainBloc mainBloc,
			int      year,
			int      month,
		}
	)  :
	mainBloc = mainBloc,
	year     = year,
	month    = month,

	super(key: key);

	final MainBloc mainBloc;
	final int      year;
	final int      month;


	@override
	MonthViewState createState() => MonthViewState();

}
class MonthViewState extends State<MonthView>
{

	double   x  = 0;
	double   y  = 0;
	double   xy = 0;

	Year thisYear;

	Month _month;
	MainBloc mainBloc;

	Widget build(BuildContext context)
	{
		mainBloc = widget.mainBloc;


		return StreamBuilder
		(
			stream: widget.mainBloc.master,
			builder:
			(
				BuildContext context,
				AsyncSnapshot state,
			)
			{
				if (state.data == null || state.data.status == mainStates.isInitializing || thisYear == null || !thisYear.initialized)
				{
					if (state.data == null)
					{
						mainBloc.MainEvents.add
						(
							MainYearSelectedEvent(newYear: widget.year)
						);
					}
					else
					{
						if (thisYear == null)
						{
							List<Year> _years = state.data.years;
							Year _year = _years.firstWhere
								(
									(aYear)
									=> aYear.currentYear == widget.year,
									orElse: ()
									=> null
							);
							if (!(_year == null || !_year.initialized))
							{
								thisYear = _year;
							}
						}
					}

					widget.mainBloc.poke(context);
					return Text('buh');
				}
				else
				{
					x  = state.data.currentWidth;
					y  = state.data.currentHeight;
					xy = state.data.multiplyWidthBy;
					_month = thisYear.months.firstWhere
					(
						(aMonth)
						=> aMonth.number == widget.month+1,
						orElse: ()
						=> null
					);

					return Column
					(
						children: <Widget>
						[
							Text
							(
								_month.label,
								style: TextStyle
								(
									fontSize   : 40,
									fontFamily : 'NugieRomantic',
									fontWeight : FontWeight.w300,
								)
							),
							Text
							(
								widget.year.toString(),
								style: TextStyle
								(
									fontSize   : 40,
									fontFamily : 'NugieRomantic',
									fontWeight : FontWeight.w300,
								)
							),
							Text
							(
								_month.description,
								style: TextStyle
								(
									fontSize   : 20,
									fontFamily : 'NugieRomantic',
									fontWeight : FontWeight.w300,
								)
							),
							Center
							(
									child: Column
									(
										children: <Widget>
										[
											Row
											(
												children: <Widget>
												[
													Column
													(
														children : tenDay(thisYear, _month,  1, x, 380 * xy)
													),
													Column
													(
														children : tenDay(thisYear, _month, 11, x, 380 * xy)
													),
													Column
													(
														children : tenDay(thisYear, _month, 21, x, 380 * xy)
													),
												],
											),
											(_month.days.length>30)
											?
											(_month.days.length==31)
													?
													// one special day
											day(thisYear, _month, 30, _month.days[30].label, x /  1.5 - 80 * xy, 30)
											:
													// two special days
											Column
											(
												children: <Widget>
												[
													day(thisYear, _month, 30, _month.days[30].label, x  - 150 * xy, 30),
													day(thisYear, _month, 31, _month.days[31].label, x  - 150 * xy, 30)
												],
											)
											:
											// nothing
											Container
											(
												width  : 50* xy ,
												height : 10* xy ,
											),
										],
									),

							)
						],
					);
				}
			}
		);
	}

	List<Widget> tenDay(Year year, Month month, int startday, double width, double length)
	{
		List<Widget> newTenday = new List<Widget>();
		for
		(
			int currentDay = startday;
			currentDay < startday + 10;
			currentDay++
		)
		{
			newTenday.add
			(
				day
				(
					year,
					month,
					currentDay - 1, // index, not shown day no.
					month.days[currentDay-1].label,
					(
							width /  3 - 80 * xy
					),
					(
							length / 10 * xy - 10 * xy
					)
				)
			);
		}
		return newTenday;
	}

	Container day(Year year, Month month, int index, String label, double width, double height)
	{
		return Container
		(
			child: Column
			(
				children: <Widget>
				[
					Container
					(
						width  : 50* xy ,
						height : 10* xy ,
					),
					Row
					(
						children: <Widget>
						[
							Container
							(
								width  : 50 * xy ,
								height : 10 * xy ,
							),
							Hero
							(
								tag: 'Day' + year.currentYear.toString() + month.label + index.toString(),
								child: Container
								(
									width  : width,
									height : height,
									color  : Color.fromARGB(230, 240, 180, 100),
									child  : InkWell
									(
										onTap: ()
										{
											Navigator.pushNamed(context, 'Day',  arguments: new router.DayArguments( year, month, index, mainBloc));
										},
										child : Center
										(
											child : Text
											(
												label,
												style: TextStyle
												(
													fontSize   : 30 * xy,
													fontFamily : 'NugieRomantic',
													fontWeight : FontWeight.w300,
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
		);
	}
}