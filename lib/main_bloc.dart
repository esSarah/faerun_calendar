import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

class Month
{
	String          label          = 'Empty';
	String          description    = 'None selected';

	int              _numberOfDays = 30;

	List<Day>        SpecialDays   = new List<Day>();
	int              number        = 0;
	bool             initialized   = false;

	Month();

	Future<bool> initMonth(int currentPlace, String newLabel, String newDescription) async
	{
		number      = currentPlace;
		label       = newLabel;
		description = newDescription;
		initialized = true;

		return initialized;

	}

	void addSpecialDay(Day specialDay)
	{
		SpecialDays.add(specialDay);
		_numberOfDays = 30 + SpecialDays.length;
	}

	int numberOfDays()
	{
		return _numberOfDays;
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
	List<Day>        specialDays = new List<Day>();
	bool             initialized = false;

	Year();

	Future<bool> InitYear(int yearNumber) async
	{
		currentYear = yearNumber;
		Month       _month;
		Day  _specialDay;

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

	// Design with for Pixel 2 emulator
	// as help
	double originalWidth   = 411.42857142857144;
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
		_mainEventController.stream.listen(_mapEventToState);
	}
	void poke(BuildContext context)
	{
		mainProperties.currentHeight   = MediaQuery.of(context).size.height;
		mainProperties.currentWidth    = MediaQuery.of(context).size.width;
		mainProperties.multiplyWidthBy =
				mainProperties.currentWidth / mainProperties.originalWidth;
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
		print('Selected Year = '  + mainProperties.currentYear.toString());
		print('Selected Month = ' + mainProperties.currentMonth.toString());

		_mainController.add(mainProperties);
	}

	Future<bool> _mapEventToYearSelected(MainYearSelectedEvent mainYearSelectedEvent) async
	{
		int yearToLoad = mainYearSelectedEvent.newYear;
		print('Year to load -' + yearToLoad.toString() + '-');
		bool existsAlready = false;
		for(int i=0; i < mainProperties.years.length; i++)
		{
			print('Years already initialized :' + mainProperties.years[i].currentYear.toString() );
			print('looking if year already exists the old fashioned way:' +
					(mainProperties.years[i].currentYear==yearToLoad).toString());
			print('looking by .contains ' + (mainProperties.years.contains
				(
							(aYear) => aYear.currentYear == yearToLoad
			).toString()));
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
			print('Initialized ' + yearToLoad.toString() + ' ' + mainProperties.years.length.toString());
		}

		_mainController.add(mainProperties);
	}

	@override
	void dispose()
	{
		_mainEventController.close();
	}
}