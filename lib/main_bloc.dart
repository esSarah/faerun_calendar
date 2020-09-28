import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

class Month
{
	String          label          = 'Empty';
	String          description    = 'None selected';


	List<Day>        days   = new List<Day>();
	int              number        = 0;
	bool             initialized   = false;

	Month();

	Future<bool> initMonth(int currentPlace, String newLabel, String newDescription) async
	{
		number      = currentPlace;
		label       = newLabel;
		description = newDescription;
		initialized = true;

		for(int calendarDay=1;calendarDay<=30;calendarDay++)
		{
			Day newDay = new Day();
			await newDay.initializeDay(calendarDay.toString());
			days.add(newDay);
		}

		return initialized;

	}

	void addSpecialDay(Day specialDay)
	{
		days.add(specialDay);
	}

}

class Day
{
	String label;
	Future<bool> initializeDay(String name) async
	{
		label = name;
		return true;
	}
	Day();
}

class Year
{

	int              currentYear;
	List<Month>      months      = new List<Month>();
	List<Day>        days        = new List<Day>();
	bool             initialized = false;

	Year();

	Future<bool> InitYear(int yearNumber) async
	{
		currentYear = yearNumber;

		Month _month;
		Day   _specialDay;

		_month =  new Month();
		await _month.initMonth(1, 'Hammer', 'Tiefwinter');
		_specialDay = new Day();
		await _specialDay.initializeDay('Mittwinter');
		_month.addSpecialDay(_specialDay);
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(2,'Alturiak','Die Klaue des Winters');
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(3, 'Ches', 'Die Klaue der Sonnenuntergänge');
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(4, 'Tarsakh', 'Die Klaue der Stürme');
		_specialDay = new Day();
		await _specialDay.initializeDay('Grüngrad');
		_month.addSpecialDay(_specialDay);
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(5, 'Mirtul', 'Das Schmelzen');
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(6, 'Kythorn', 'Die Zeit der Blumen');
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(7, 'Flammenherrschaft', 'Sommerflut');
		_specialDay = new Day();
		await _specialDay.initializeDay('Mittsommer');
		_month.addSpecialDay(_specialDay);
		if(yearNumber%4==0)
		{
			_specialDay = new Day();
			await _specialDay.initializeDay('Schildtreffen');
			_month.addSpecialDay(_specialDay);
		}
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(8, 'Elesias', 'Hochsonne');
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(9, 'Eleint', 'Das Verblassen');
		_specialDay = new Day();
		await _specialDay.initializeDay('Hochernte');
		_month.addSpecialDay(_specialDay);
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(10, 'Marpenoth', 'Laubfall');
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(11, 'Uktar', 'Der Verfall');
		_specialDay = new Day();
		await _specialDay.initializeDay('Das Fest des Mondes');
		_month.addSpecialDay(_specialDay);
		months.add(_month);

		_month =  new Month();
		await _month.initMonth(12, 'Nightal', 'Der Niedergang');
		months.add(_month);

		initialized = true;
		return initialized;
	}
}

enum mainStates
{
	isInitializing,

	isUserSelected,
}

class MainProperties
{
	int    currentYear     = 1490;
	int    currentMonth    = 1;
	int    currentDay      = 1;

	double currentWidth    = 0;
	double currentHeight   = 0;

	double xFactor = 0;
	double yFactor = 0;

	double xReal = 0;
	double yReal = 0;

	// Design width and height for Pixel 2 emulator
	// as orientation
	double originalWidth   = 411.42857142857144;
	double originalHeight  = 683.4285714285714;

	double multiplyWidthBy = 1;

	mainStates  status     = mainStates.isInitializing;
	String backgroundImage = 'assets/spring.png';
	List<Year> years = new List<Year>();
}

abstract class MainEvent
{
	MainEvent([List props = const[]]);
}

class MainChangedCharacterEvent extends MainEvent
{
	final int newCharacterID;

	MainChangedCharacterEvent
	(
		{@required this.newCharacterID}
	) : super([newCharacterID]);
}

class MainYearSelectedEvent extends MainEvent
{
	final int newYear;
	MainYearSelectedEvent
	(
		{@required this.newYear}
	) : super([newYear]);
}

class MainMonthSelectedEvent extends MainEvent
{
	final int newMonth;
	MainMonthSelectedEvent
	(
		{@required this.newMonth}
	) : super([newMonth]);
}

class MainDaySelectedEvent extends MainEvent
{
	final int newDay;
	MainDaySelectedEvent
	(
		{@required this.newDay}
	) : super([newDay]);
}

class MainBloc
{

	MainProperties mainProperties = new MainProperties();

	final _mainController = StreamController<MainProperties>.broadcast();
	Stream<MainProperties> get master => _mainController.stream;

	final _mainEventController = StreamController<MainEvent>();
	// in dieses Sammelbecken kommen die Events
	Sink<MainEvent> get MainEvents =>
			_mainEventController.sink;
	MainBloc()
	{
		print('created new MainBloc');
		_mainEventController.stream.listen(_mapEventToState);
	}
	void poke(BuildContext context)
	{
		mainProperties.currentHeight   = MediaQuery.of(context).size.height;
		mainProperties.currentWidth    = MediaQuery.of(context).size.width;
		mainProperties.multiplyWidthBy =
				mainProperties.currentWidth / mainProperties.currentHeight;
		mainProperties.xFactor         =
				mainProperties.currentWidth / mainProperties.originalWidth;
		mainProperties.yFactor         =
				mainProperties.currentHeight / mainProperties.originalHeight;

		mainProperties.xReal =
			mainProperties.currentWidth *
			MediaQuery.of(context).devicePixelRatio;

		mainProperties.yReal =
				mainProperties.currentHeight *
				MediaQuery.of(context).devicePixelRatio;

		mainProperties.status = mainStates.isUserSelected; // todo: delete when implement
		_mainController.add(mainProperties);
	}

	Future<bool> _mapEventToState(MainEvent event) async
	{
		if(event is MainMonthSelectedEvent)
		{
			_mapEventToMonthSelected(event);
		}
		if(event is MainYearSelectedEvent)
		{
			await _mapEventToYearSelected(event);
		}
		return true;
	}

	void _mapEventToMonthSelected(MainMonthSelectedEvent mainMonthSelectedEvent)
	{
		int monthsOverAll = mainMonthSelectedEvent.newMonth;
		mainProperties.currentYear = (monthsOverAll / 12).floor();
		mainProperties.currentMonth = monthsOverAll-(mainProperties.currentYear*12);
		mainProperties.currentMonth++;
		if(mainProperties.currentMonth==12||mainProperties.currentMonth<=2)
		{
			mainProperties.backgroundImage = 'assets/winter.png';
		}
		if(mainProperties.currentMonth>=3&&mainProperties.currentMonth<=5)
		{
			mainProperties.backgroundImage = 'assets/spring.png';
		}
		if(mainProperties.currentMonth>=6&&mainProperties.currentMonth<=8)
		{
			mainProperties.backgroundImage = 'assets/summer.png';
		}
		if(mainProperties.currentMonth>=9&&mainProperties.currentMonth<=11)
		{
			mainProperties.backgroundImage = 'assets/autumn.png';
		}

		_mainController.add(mainProperties);
	}

	Future<bool> _mapEventToYearSelected(MainYearSelectedEvent mainYearSelectedEvent) async
	{
		int yearToLoad = mainYearSelectedEvent.newYear;
		bool existsAlready = false;
		for(int i=0; i < mainProperties.years.length; i++)
		{
			if(mainProperties.years[i].currentYear==yearToLoad)
			{
				existsAlready = true;
				break;
			}
		}
		if
		(
			!existsAlready
		)
		{
			Year _newYear = new Year();
			await _newYear.InitYear(yearToLoad);
			mainProperties.years.add(_newYear);
		}

		_mainController.add(mainProperties);
	}

	@override
	void dispose()
	{
		_mainEventController.close();
	}
}