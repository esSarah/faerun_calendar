import 'package:flutter/material.dart';
import 'main_bloc.dart';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'support_routing.dart' as router;

class DayWidget extends StatefulWidget
{
	DayWidget({Key key, this.dayOfMonth}) : super(key: key);

	final int dayOfMonth;

	@override
	_DayWidget createState() => _DayWidget();
}

class _DayWidget extends State<DayWidget>
{

	@override
	Widget build(BuildContext context)
	{

		return Scaffold
		(
				/*
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),

       */
				body: Column
				(
					children: <Widget>
					[


					Hero
					(
						tag: widget.dayOfMonth,
						child:Container
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
								child:Text
								(
									'Day',
									style: TextStyle
									(
										fontFamily: 'NugieRomantic',
										fontSize: 20,
									)
								),
							),
						),

					),


				],
			),
		);
	}
}