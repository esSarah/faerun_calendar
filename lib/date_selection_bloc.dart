import 'dart:async';
import 'package:meta/meta.dart';
import 'support_faerun_date.dart';

enum DateSelectionStates
{
	initializing,
	processing,
	ready,
}

class DateSelectionProperties
{
	FaerunDate          selectedDate  = new FaerunDate();
	Year                selectedYear  = new Year();
	Month               selectedMonth = new Month();
	Day                 selectedDay   = new Day();
	DateSelectionStates status         = DateSelectionStates.initializing;
}

// Events in
abstract class DateSelectionEvent
{
	DateSelectionEvent([List props = const[]]);
}

class InitializeDateSelectionEvent extends DateSelectionEvent
{
	final FaerunDate initialDate;
	InitializeDateSelectionEvent ({@required this.initialDate}) : super([initialDate]);
}

class SetYearEvent extends DateSelectionEvent
{
	final int newYear;
	SetYearEvent({@required this.newYear}) : super([newYear]);
}

class SetMonthEvent extends DateSelectionEvent
{
	final int newMonth;
	SetMonthEvent({@required this.newMonth}) : super([newMonth]);
}

class SetDayEvent extends DateSelectionEvent
{
	final int dayOfMonth;
	SetDayEvent ({@required this.dayOfMonth}) : super([dayOfMonth]);
}

class DateSelectionBloc
{
	DateSelectionProperties properties = new DateSelectionProperties();

	final _dateSelectionController =
		StreamController<DateSelectionProperties>.broadcast();
	Stream<DateSelectionProperties> get dateSelection =>
			_dateSelectionController.stream;

	final _dateSelectionEventController = StreamController<DateSelectionEvent>();
	// in dieses Sammelbecken kommen die Events
	Sink<DateSelectionEvent> get dateSelectionEvents =>
			_dateSelectionEventController.sink;

	DateSelectionBloc(FaerunDate initialDate)
	{
		_dateSelectionEventController.stream.listen(_mapEventToState);
		properties.status = DateSelectionStates.initializing;
		_dateSelectionEventController.add
		(
			new InitializeDateSelectionEvent(initialDate: initialDate)
		);
	}

	void poke()
	{
		_dateSelectionController.add(properties);
	}

	void _mapEventToState(DateSelectionEvent event) async
	{
		if(event is InitializeDateSelectionEvent)
		{
			await _initializeDateSelection(event);
		}

		if(event is SetYearEvent)
		{
			await _setYear(event);
		}

		if(event is SetMonthEvent)
		{
			await _setMonth(event);
		}

		if(event is SetDayEvent)
		{
			await _setDay(event);
		}
	}

	Future<bool> _initializeDateSelection(InitializeDateSelectionEvent event) async
	{
		properties.status = DateSelectionStates.processing;

		await properties.selectedDate.loadDate
		(
			event.initialDate.year.currentYear,
			event.initialDate.month,
			event.initialDate.day
		);
		properties.selectedMonth = properties.selectedDate.year.months
			[properties.selectedDate.month-1];
		properties.selectedDay = properties.selectedMonth.days
			[properties.selectedDate.day-1];

		properties.status = DateSelectionStates.ready;
		_dateSelectionController.add(properties);
		return true;
	}

	Future<bool> _setYear(SetYearEvent event) async
	{
		properties.status = DateSelectionStates.processing;

		int _currentDayNo = properties.selectedDate.day;

		await properties.selectedDate.loadDate
		(
				event.newYear,
				properties.selectedDate.month,
				1
		);
		properties.selectedYear  = properties.selectedDate.year;
		properties.selectedMonth = properties.selectedDate.year.months
			[properties.selectedDate.month-1];
		if(properties.selectedMonth.days.length < _currentDayNo - 1)
		{
			_currentDayNo = properties.selectedMonth.days.length;
		}
		properties.selectedDate.day = _currentDayNo;
		properties.selectedDay = properties.selectedMonth.days
			[properties.selectedDate.day-1];

		properties.status = DateSelectionStates.ready;
		_dateSelectionController.add(properties);
		return true;
	}

	Future<bool> _setMonth(SetMonthEvent event) async
	{
		properties.status = DateSelectionStates.processing;

		int _currentDayNo = properties.selectedDate.day;

		await properties.selectedDate.loadDate
		(
			properties.selectedDate.year.currentYear,
			event.newMonth,
			1
		);
		properties.selectedYear  = properties.selectedDate.year;
		properties.selectedMonth = properties.selectedDate.year.months
		[properties.selectedDate.month-1];
		if(properties.selectedMonth.days.length < _currentDayNo)
		{
			_currentDayNo = properties.selectedMonth.days.length;
		}
		properties.selectedDate.day = _currentDayNo;
		properties.selectedDay = properties.selectedMonth.days
			[properties.selectedDate.day-1];

		properties.status = DateSelectionStates.ready;
		_dateSelectionController.add(properties);
		return true;
	}

	Future<bool> _setDay(SetDayEvent event) async
	{
		properties.status = DateSelectionStates.processing;

		int _currentDayNo = event.dayOfMonth;
		if(properties.selectedMonth.days.length < _currentDayNo)
		{
			_currentDayNo = properties.selectedMonth.days.length;
		}
		properties.selectedDate.day = _currentDayNo;
		properties.selectedDay = properties.selectedMonth.days
			[properties.selectedDate.day-1];

		properties.status = DateSelectionStates.ready;
		_dateSelectionController.add(properties);
		return true;
	}

	void dispose()
	{
		_dateSelectionController.close();
		dateSelectionEvents.close();
		_dateSelectionEventController.close();
	}
}