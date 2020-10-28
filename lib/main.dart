import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'support_sizing.dart'  as sizing;
import 'support_faerun_date.dart';
import 'main_bloc.dart';
import 'month_widget.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
// https://pub.dev/packages/carousel_slider

void main()
{
  WidgetsFlutterBinding.ensureInitialized();
  runApp
  (
      MyApp()
  );
}

class MyApp extends StatelessWidget
{
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)
  {
    final MainBloc mainBloc    = new MainBloc();
    return MaterialApp
    (
      title: 'Faerun Kalender',
      onGenerateRoute: router.generateRoute,
      initialRoute: '/',
      theme: ThemeData
      (
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(mainBloc: mainBloc),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  MyHomePage
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  MainBloc mainBloc;

  double   x  = 0;
  double   xf = 0;
  double   y  = 0;
  double   yf = 0;
  double   xy = 0;
  double   xr = 0;
  double   yr = 0;

  sizing.Proportions proportions = new sizing.Proportions();

  // will be 5% of portrait mode height
  double headerHeight = 0;
  int    currentCarouselMonth = 0;
  bool   isPortrait   = true;

  CarouselController monthCarouselController = CarouselController();
  bool alreadySettingDate = false;

  @override
  Widget build(BuildContext context)
  {
    mainBloc = widget.mainBloc;
    return StreamBuilder
      (
        stream: mainBloc.master,
        builder:
            (
            BuildContext  context,
            AsyncSnapshot state,
            )
        {
          if
          (
          state.data == null ||
              state.data.status == mainStates.isInitializing
          )
          {
            if (state.data == null)
            {
              mainBloc.poke(context);
            }
            return Text('');
          }
          else
          {

            if(isPortrait != (MediaQuery.of(context).orientation==Orientation.portrait))
            {
              mainBloc.poke(context);
            }
            isPortrait = (MediaQuery.of(context).orientation==Orientation.portrait);

            proportions.refreshProportions(context);

            x  = proportions.x;
            y  = proportions.y;
            xy = proportions.xy;

            headerHeight = 32;

            proportions.monthViewX = x * .95;
            proportions.monthViewY = y - 100;

            return Scaffold
            (
              body: Column
                (
                children: <Widget>
                [
                  Container
                    (
                    width  : 1.0,
                    height : headerHeight,
                  ),
                  Stack
                    (
                    children: <Widget>
                    [
                      Column
                        (
                        children: <Widget>
                        [
                          Container
                          (
                            height:
                            100,
                            width : 1,
                          ),
                          Image
                            (
                            image          :
                            AssetImage(state.data.backgroundImage),
                            width          : x,
                            height         : y - (100 + y * .1),
                            gaplessPlayback: false,
                          ),
                        ],
                      ),
                      StatefulBuilder
                      (
                        builder: (BuildContext context, StateSetter setState)
                        {
                          if(!alreadySettingDate&&state.data.status == mainStates.dateChangeIsPending)
                          {
                            setState
                            (
                              ()
                              {
                                alreadySettingDate = true;
                                FaerunDate goToNewMonth = state.data.characterProperties.partyDate;
                                int goToNewYear = goToNewMonth.year.currentYear;
                                currentCarouselMonth = goToNewYear*12+goToNewMonth.month-1;
                                monthCarouselController.jumpToPage
                                (
                                  goToNewYear*12+goToNewMonth.month-1
                                );
                              }
                            );

                            mainBloc.mainEvents.add
                            (
                              DateChangeConfirmedEvent()
                            );
                          }
                          if(state.data.status == mainStates.isUserSelected)
                          {
                            alreadySettingDate = false;
                          }

                          return CarouselSlider.builder
                          (
                            itemCount: 120000,
                            carouselController: monthCarouselController,
                            options: CarouselOptions
                            (
                              height: y - (100),
                              viewportFraction: .95,
                              initialPage:
                              state.data.currentMonth.year.currentYear * 12
                                  + state.data.currentMonth.month - 1,
                              aspectRatio: xy,
                              enlargeCenterPage: false,
                              autoPlay: false,
                              onPageChanged: (index, reason)
                              {
                                setState
                                (
                                  ()
                                  {
                                    currentCarouselMonth = index;
                                    mainBloc.mainEvents.add
                                    (
                                      MainMonthSelectedEvent(newMonth: index)
                                    );
                                  }
                                );
                              }
                            ),
                            itemBuilder: (ctx, index)
                            {
                              return Container
                              (
                                child:
                                MonthView
                                (
                                  mainBloc: mainBloc,
                                  year: (index / 12).floor(),
                                  month: index - ((index / 12).floor() * 12),
                                  proportions: proportions,
                                )
                              );
                            },
                          );
                        }
                      )
                    ],
                  ),
                ],
              ),
            );
          }
        }
    );
  }
}

