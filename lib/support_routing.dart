import 'package:flutter/material.dart';
import 'main.dart';
import 'day_widget.dart';
import 'main_bloc.dart';

Route<dynamic> generateRoute(RouteSettings settings)
{
	switch (settings.name)
	{
		case '/':
			return MaterialPageRoute(builder: (context) => MyHomePage());
		case 'Day':
			return MaterialPageRoute(builder: (context) => DayWidget(dayArguments:settings.arguments));
		default:
			return MaterialPageRoute(builder: (context) => MyHomePage());
	}
}

class DayArguments
{
	final Year     year;
	final Month    month;
	final int      index;
	final MainBloc mainBloc;

	DayArguments(this.year, this.month, this.index, this.mainBloc);
}

