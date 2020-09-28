import 'package:flutter/material.dart';

class Proportions
{
	double   x  = 0;
	double   xr = 0;
	double   y  = 0;
	double   yr = 0;
	double   xy = 0;

	double headerHeight = 0;

	double monthViewX = 0;
	double monthViewY = 0;

	bool isPortrait = true;
	Proportions();

	refreshProportions(BuildContext context)
	{
;

		x  = MediaQuery.of(context).size.width;
		y  = MediaQuery.of(context).size.height;

		xr = x * MediaQuery.of(context).devicePixelRatio;
		yr = y * MediaQuery.of(context).devicePixelRatio;

		headerHeight = yr*.05;

		xy = x/y;
	}
}