import 'package:flutter/material.dart';

class Proportions
{
	double   x  = 0;
	double   xr = 0;
	double   y  = 0;
	double   yr = 0;
	double   xy = 0;

	double   xf = 0;

	double headerHeight = 0;

	double monthViewX = 0;
	double monthViewY = 0;

	// design width for Pixel 2 in Simulator
	double originalWidth  = 411.42857142857144;
	double originalHeight = 683.4285714285714;

	bool isPortrait = true;

	Proportions();


	refreshProportions(BuildContext context)
	{

		x  = MediaQuery.of(context).size.width;
		y  = MediaQuery.of(context).size.height;

		xr = x * MediaQuery.of(context).devicePixelRatio;
		yr = y * MediaQuery.of(context).devicePixelRatio;

		headerHeight = yr * .05;
		isPortrait = (x < y);
		if(isPortrait)
		{
			xf = x / originalWidth;
		}
		else
		{
			xf = x / originalHeight;
		}

		xy = x / y;
	}
}