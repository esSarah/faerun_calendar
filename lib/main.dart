import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
import 'support_sizing.dart'  as sizing;

import 'main_bloc.dart';
import 'month_widget.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
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
  double   headerHeight = 0;

  bool isPortrait = true;

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

          proportions.monthViewX = x *.95;
          proportions.monthViewY = y - (100);

          //currentOrientation = state.data.currentOrientation;
          print('x: ' + x.toString() + ', y: ' + y.toString() + ', xy: ' + xy.toString());
          print('Direction=' + MediaQuery.of(context).orientation.toString());
          print('Device PixelRatio=' + MediaQuery.of(context).devicePixelRatio.toString());

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
                    CarouselSlider.builder
                    (
                      itemCount: 120000,
                      options: CarouselOptions
                      (
                        height            : y - (100),
                        viewportFraction  : .95,
                        initialPage       : 17760,
                        aspectRatio       : xy,
                        enlargeCenterPage : false,
                        autoPlay          : false,
                        onPageChanged     : (index, reason)
                        {
                          setState
                          (
                            ()
                            {
                              mainBloc.MainEvents.add
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
                            mainBloc    : mainBloc,
                            year        : (index/12).floor(),
                            month       : index-((index/12).floor()*12),
                            proportions : proportions,
                          )
                        );
                      },
                    ),
                  ],
                ),
              ],
            )
          );
        }
      }
    );
  }
}
