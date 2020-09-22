import 'package:flutter/material.dart';
import 'main.dart';
import 'day_widget.dart';

Route<dynamic> generateRoute(RouteSettings settings)
{
	switch (settings.name)
	{
		case '/':
			return MaterialPageRoute(builder: (context) => MyHomePage());
		case 'Day':
			return MaterialPageRoute(builder: (context) => DayWidget(dayOfMonth:settings.arguments));
		default:
			return MaterialPageRoute(builder: (context) => MyHomePage());
	}
}