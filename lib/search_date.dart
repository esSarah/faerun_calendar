import 'package:faerun_calendar/character_selection_bloc.dart';
import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'support_sizing.dart'  as sizing;
import 'main_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchDate extends StatefulWidget
{
	SearchDate
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
	_SearchDateState createState() => _SearchDateState();
}

class _SearchDateState extends State<SearchDate>
{
	MainBloc      _mainBloc;
	CharacterBloc _characterBloc;
	bool isInfoVisible = false;
	double   x;
	double   y;
	bool     isPortrait = true;

	@override
	initState()
	{
		super.initState();
		_mainBloc      =  widget.mainBloc;
		_characterBloc = _mainBloc.characterBloc;
	}

	Widget build(BuildContext context)
	{
		return Scaffold(body: Container(width:100, height:10, child: Text('Search')));
	}

}