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

class Month
{
	String          label          = 'Empty';
	String          description    = 'None selected';

	List<Day>        days          = new List<Day>();
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

class Year
{

	int              currentYear = 1480;
	List<Month>      months      = new List<Month>();
	List<Day>        days        = new List<Day>();
	bool             initialized = false;

	Year();

	Future<bool> initYear(int yearNumber) async
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

class FaerunDate
{

	int   day = 1;
	int   month = 1;
	Year  year;

	FaerunDate();

	Future<bool> testDate(int year, int month, int day) async
	{
		bool isValid = true;
		if(year==null||month==null||day==null)
		{
			isValid = false;
		}
		if(isValid&&(year>10000||year<1))
		{
			isValid = false;
		}
		if(isValid&&(month>12||month<1))
		{
			isValid = false;
		}
		if(isValid)
		{
			Year _year = new Year();
			await _year.initYear(year);
			if(day<1&&day>_year.days.length+1)
			{
				isValid = false;
			}
		}
		return isValid;
	}

	Future<bool> loadDate(int year, int month, int day) async
	{
		this.year = new Year();
		if(await testDate(year, month, day))
		{
			await this.year.initYear(year);
			this.month = month;
			this.day   = day;
			return true;
		}
		else
		{
			return false;
		}
	}
}