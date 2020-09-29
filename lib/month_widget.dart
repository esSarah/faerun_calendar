import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'support_sizing.dart'  as sizing;
import 'main_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MonthView extends StatefulWidget
{
	const MonthView
	(
		{
			Key                key,
			MainBloc           mainBloc,
			int                year,
			int                month,
			sizing.Proportions proportions,
		}
	)  :
	mainBloc    = mainBloc,
	year        = year,
	month       = month,
	proportions = proportions,

	super(key: key);

	final MainBloc           mainBloc;
	final int                year;
	final int                month;
	final sizing.Proportions proportions;


	@override
	MonthViewState createState() => MonthViewState();

}
class MonthViewState extends State<MonthView>
{

	double   x  = 0;
	double   y  = 0;
	double   xy = 0;

	double sheetX = 0;
	double sheetY = 0;

	double breakX = 0;
	double breakY = 0;

	Year     thisYear;

	bool     isPortrait = true;

	double textBlockHeight = 100;

	Month    _month;
	MainBloc mainBloc;

	Widget build(BuildContext context)
	{
		mainBloc = widget.mainBloc;
		x        = widget.proportions.monthViewX;
		y        = widget.proportions.monthViewY;
		// xy       = widget.proportions.xy;
		isPortrait=(x<y);
		textBlockHeight = 100;
		if(isPortrait)
		{
			sheetX = (x/3)*.75;
			sheetY = ((y-textBlockHeight)/11)*.75;

			breakX = (x/3)*.15;
			breakY = ((y-textBlockHeight)/11)*.15;
			if(sheetX>sheetY*1.5)
			{
				breakX+=sheetX-(sheetY*1.5);
				sheetX = sheetY*1.5;
			}
		}
		else
		{
			sheetX = ((x-textBlockHeight)/10)*.75;
			sheetY = ((y-textBlockHeight)/4)*.75;

			breakX = ((x-textBlockHeight)/10)*.15;
			breakY = ((y-textBlockHeight)/4)*.15;
			if(sheetX<sheetY)
			{
				breakY+=(sheetY-sheetX);
				sheetY = sheetX;
			}
		}

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
							Column
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
									Row
									(
										mainAxisAlignment: MainAxisAlignment.center,
										children: <Widget>
										[
											IconButton
											(
												color     : Color.fromARGB(230, 240, 180, 100),
												icon      : new Icon(Icons.portrait),
												iconSize  : 40,
												onPressed : ()
												{
													Navigator.pushNamed
													(
														context, 'Character', arguments: widget.mainBloc
													);
												}
											),
											SizedBox(width:40,height:40),

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
											SizedBox(width:40,height:40),
											IconButton
											(
												color     : Color.fromARGB(230, 240, 180, 100),
												icon      : new Icon(Icons.search),
												iconSize  : 40,
												onPressed : ()
												{
													Navigator.pushNamed
													(
														context, 'Search'
													);
												}
											),
										]
									),
									AutoSizeText
									(
										_month.description,
										maxFontSize: 20,
										style: TextStyle
										(
											fontFamily : 'NugieRomantic',
											fontWeight : FontWeight.w300,
										),
									),
								],
							),

							Center
							(
								child:
								isPortrait
								?
								Column
								(
									children: <Widget>
									[
										Row
										(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>
											[
												Column
												(
													children : tenDay(thisYear, _month,  1)
												),
												Column
												(
													children : tenDay(thisYear, _month, 11)
												),
												Column
												(
													children : tenDay(thisYear, _month, 21)
												),
											],
										),
									],
								)
								:

								Column
								(
									children: <Widget>
									[
										Row
										(
											mainAxisAlignment: MainAxisAlignment.center,
											children : tenDay(thisYear, _month,  1)
										),
										Row
										(
											mainAxisAlignment: MainAxisAlignment.center,
											children : tenDay(thisYear, _month, 11)
										),
										Row
										(
											mainAxisAlignment: MainAxisAlignment.center,
											children : tenDay(thisYear, _month, 21)
										),
									],
								),

							),
							Center
							(
								child:
								(_month.days.length>30)
								?
									(_month.days.length==31)
									?
								// one special day
										Row
										(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>
											[
												day
												(
													thisYear,
													_month,
													30,
													_month.days[30].label,
														isPortrait
																?
														(sheetX+breakX)*3
																:
														(sheetX+breakX)*10,
												),
											]
										)
										:
								// two special days
										Row
										(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>
											[
												day
												(
													thisYear,
													_month,
													30,
													_month.days[30].label,
													isPortrait
															?
													(sheetX+breakX)*3
															:
													(sheetX+breakX)*10,

														//(sheetX*5)+(4*breakX),
													'left'
												),
												day
												(
													thisYear,
													_month,
													31,
													_month.days[31].label,
													isPortrait
															?
													(sheetX+breakX)*3
													//(sheetX*1.5)+(breakX)
															:
													(sheetX+breakX)*10,

													//(sheetX*5)+(4*breakX),
													'right'
												),
											],
										)
										:
								// nothing
								Container
								(
									width  : 50* xy ,
									height : 10* xy ,
								),
							),
						],
					);
				}
			}
		);
	}

	List<Widget> tenDay(Year year, Month month, int startDay)
	{
		List<Widget> newTenday = new List<Widget>();
		for
		(
			int currentDay = startDay;
			currentDay < startDay + 10;
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
					month.days[currentDay-1].label
				)
			);
		}
		return newTenday;
	}

	Container day
	(
		Year   year,
		Month  month,
		int    index,
		String label,
		[
			double moreWidth,
			String direction,
		]
	)
	{
		double halfedBreakX = breakX/2;
		double halfedBreakY = breakY/2;

		return Container
		(
			child: Column
			(
				children: <Widget>
				[
					SizedBox
					(
						width  : (direction!=null&&direction=='right')?5:halfedBreakX,
						height : halfedBreakY,
					),
					Row
					(
						children: <Widget>
						[
							SizedBox
							(
								width  : (direction!=null&&direction=='right')?5:halfedBreakX,
								height : halfedBreakY,
							),
							Hero
							(
								tag: 'Day' + year.currentYear.toString() + month.label + index.toString(),
								child: Container
								(
									width  :
										(moreWidth==null)
										?
										sheetX
										:
										(direction==null)
											?
											moreWidth-breakX
											:
											(moreWidth-breakX) / 2 - 5,

									height : sheetY,
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
													fontSize   : sheetY*.6,
													fontFamily : 'NugieRomantic',
													fontWeight : FontWeight.w300,
												)
											),
										),
									),
								),
							),
							SizedBox
							(
								width  : (direction!=null&&direction=='left')?5:halfedBreakX,
								height : halfedBreakY,
							),
						],
					),
					SizedBox
					(
						width  : (direction!=null&&direction=='left')?5:halfedBreakX,
						height : halfedBreakY,
					),
				],
			),
		);
	}
}