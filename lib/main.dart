import 'package:flutter/material.dart';
import 'support_routing.dart' as router;
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

  double   x           = 0;
  double   y           = 0;
  double   xy          = 0;

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
          x  = state.data.currentWidth;
          y  = state.data.currentHeight;
          xy = state.data.multiplyWidthBy;

          print('x: ' + x.toString() + ', y: ' + y.toString() + ', xy: ' + xy.toString());

          return Scaffold
          (
            body: Column
            (
              children: <Widget>
              [
                Container
                (
                  width  : 1.0,
                  height : 30.0 * xy,
                ),
                Stack
                (
                  children: <Widget>
                  [
                    Column
                    (
                      children: <Widget>
                      [
                        Container(height: 100 * xy, width : 1,),
                        Image
                        (
                          image          :
                            AssetImage(state.data.backgroundImage),
                          width          : x * xy,
                          height         : y - (150*xy),
                          gaplessPlayback: false,
                        ),
                      ],
                    ),
                    CarouselSlider.builder
                    (
                      itemCount: 120000,
                      options: CarouselOptions
                      (
                        height            : y-(100*xy),
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
                              mainBloc : mainBloc,
                              year     : (index/12).floor(),
                              month    : index-((index/12).floor()*12))
                          // Text(index.toString()),
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
