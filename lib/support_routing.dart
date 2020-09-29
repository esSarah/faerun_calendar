import 'package:flutter/material.dart';
import 'main.dart';
import 'day_widget.dart';
import 'main_bloc.dart';
import 'character_selection_widget.dart';

Route<dynamic> generateRoute(RouteSettings settings)
{
	switch (settings.name)
	{
		case '/':
			return MaterialPageRoute(builder: (context) => MyHomePage());
		case 'Day':
			return MaterialPageRoute(builder: (context) => DayWidget(dayArguments:settings.arguments));
		case 'Character':
			return MaterialPageRoute(builder: (context) => CharacterSelection(mainBloc: settings.arguments));
		case 'Search':
			return MaterialPageRoute(builder: (context) => MyHomePage());
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

class CharacterArguments
{

}

