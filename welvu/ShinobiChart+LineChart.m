//
//  ShinobiChart+LineChart.m
//  LineChart

#import "ShinobiChart+LineChart.h"
#import "WeightsHieghtsModel.h"
#import "welvuAppDelegate.h"
#import "WeightsHeights.h"
#import "welvuDetailViewControllerIpad.h"

@implementation ShinobiChart (LineChart)
ShinobiChart *chart;


- (void)setDataPoint:(id<SChartData>)dataPoint fromSeries:(SChartSeries *)series fromChart:(ShinobiChart *)chart {
    
}

/*
 * Method name: seriesTitleForKey
 * Description: TO get Title for the key
 * Parameters: NSString
 * return NSString
 */
- (NSString*)seriesTitleForKey:(NSString*)key {
    NSString *title = nil;
    
    if ([key isEqualToString:Weight]) {
        title = @" Weight(lbs) ";
        
        
    } else if ([key isEqualToString:Height]) {
        title = @" Height(cm) ";
        
    }
    else if ([key isEqualToString:Temperature]) {
        title = @" Temp(F)";
        
    }
    
    else if ([key isEqualToString:bps]) {
        title = @" bps";
        
    }
    
    else if ([key isEqualToString:bpd]) {
        title = @" bpd";
        
    }
    else if ([key isEqualToString:bmi]) {
        title = @" bmi";
        
    }
    return title;
}

/*
 * Method name: lineSeriesForKey
 * Description:To set the Property for the key
 * Parameters: NSString
 * return SChartSeries
 */

- (SChartSeries*)lineSeriesForKey:(NSString*)key {
    
    SChartLineSeries *l = [SChartLineSeries new];
    l.style.pointStyle.showPoints = YES;
    l.crosshairEnabled = YES;
    l.selectionMode = SChartSelectionPoint;
    l.title = [self seriesTitleForKey:key];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * currentVital = [prefs stringForKey:@"Weightselected"];
    NSString *heightSelector = [prefs stringForKey:@"Heightselected"];
    NSString *temperatureSelector = [prefs stringForKey:@"Tempselected"];
    NSString *pressureSelector = [prefs stringForKey:@"Pressureselected"];
    NSString *BmiSelector = [prefs stringForKey:@"BMIselected"];
    
    
    if ([key isEqualToString:Weight]) {
        if (currentVital== @"Weightselected") {
            l.style.lineColor = [UIColor colorWithRed:254/255.0 green:30/255.0 blue:30/255.0 alpha:1];
            l.style.pointStyle.color = [UIColor redColor];
        } else {
            l.style.lineColor = [UIColor clearColor];
            l.style.pointStyle.color = [UIColor clearColor];
            [prefs removeObjectForKey:@"Weightselected"];
        }
        
    }  if ([key isEqualToString:Height]) {
        if (heightSelector== @"Heightselected") {
            l.style.lineColor = [UIColor colorWithRed:255/255.0 green:174/255.0 blue:0/255.0 alpha:1];
            l.style.pointStyle.color = [UIColor colorWithRed:255/255.0 green:174/255.0 blue:0/255.0 alpha:1];
        } else {
            l.style.lineColor = [UIColor clearColor];
            l.style.pointStyle.color = [UIColor clearColor];
            [prefs removeObjectForKey:@"Heightselected"];
        }
        
    }
    if ([key isEqualToString:Temperature]) {
        if (temperatureSelector== @"Tempselected") {
            l.style.lineColor = [UIColor colorWithRed:45/255.0 green:151/255.0 blue:212/255.0 alpha:1];
            l.style.pointStyle.color = [UIColor colorWithRed:45/255.0 green:151/255.0 blue:212/255.0 alpha:1];
        } else {
            l.style.lineColor = [UIColor clearColor];
            l.style.pointStyle.color = [UIColor clearColor];
            [prefs removeObjectForKey:@"Tempselected"];
        }
        
    }
    
    if ([key isEqualToString:bps]) {
        if (pressureSelector== @"Pressureselected") {
            l.style.lineColor = [UIColor colorWithRed:11/255.0 green:11/255.0 blue:157/255.0 alpha:1];
            l.style.pointStyle.color = [UIColor colorWithRed:11/255.0 green:11/255.0 blue:157/255.0 alpha:1];
        }else {
            l.style.lineColor = [UIColor clearColor];
            l.style.pointStyle.color = [UIColor clearColor];
            [prefs removeObjectForKey:@"Pressureselected"];
        }
    }
    
    if ([key isEqualToString:bpd]) {
        
        if (pressureSelector== @"Pressureselected") {
            
            l.style.lineColor = [UIColor colorWithRed:2/255.0 green:80/255.0 blue:80/255.0 alpha:1];
            l.style.pointStyle.color = [UIColor colorWithRed:2/255.0 green:80/255.0 blue:80/255.0 alpha:1];
        }else {
            l.style.lineColor = [UIColor clearColor];
            l.style.pointStyle.color = [UIColor clearColor];
            [prefs removeObjectForKey:@"Pressureselected"];
        }
        
    }
    if ([key isEqualToString:bmi]) {
        if (BmiSelector== @"BMIselected") {
            l.style.lineColor = [UIColor colorWithRed:20/255.0 green:8/255.0 blue:8/255.0 alpha:1];
            l.style.pointStyle.color = [UIColor colorWithRed:20/255.0 green:8/255.0 blue:8/255.0 alpha:1];
            
        } else {
            l.style.lineColor = [UIColor clearColor];
            l.style.pointStyle.color = [UIColor clearColor];
            [prefs removeObjectForKey:@"BMIselected"];
            
        }
        
    }
    
    return l;
    
}


/*
 * Method name: lineSeriesForKey
 * Description:To set the Property for the key
 * Parameters: NSString
 * return SChartSeries
 */

+ (ShinobiChart*)lineChartForBrowserUsageWithFrame:(CGRect)frame  {
    
    welvuAppDelegate *appDelegate;
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *patientID=appDelegate.currentPatientInfo;
    ShinobiChart *chart = [[ShinobiChart alloc] initWithFrame:frame];
    chart.autoresizingMask = ~UIViewAutoresizingNone;
    chart.clipsToBounds = NO;
   // chart.crosshair.enableCrosshairLinesSet = YES;
    //Choose the light theme for this chart
    SChartLightTheme *theme = [SChartLightTheme new];
    //perform any theme stylign here before applying to the chart
    chart.theme = theme;
    //Double tap can either reset zoom or zoom in
    chart.gestureDoubleTapResetsZoom = YES;
   // [chart.crosshair setDefaultTooltip];
    NSString *fName =[patientID objectForKey:@"fname"];
    NSString *lName =[patientID objectForKey:@"lname"];
    NSString *sex= [patientID objectForKey:@"sex"];
    NSString *age= [patientID objectForKey:@"age"];
    NSString *space = @"                                  ";
    NSString *imageFullName=[NSString stringWithFormat:@"%@ %@ %@ (%@)- %@ Years", space,fName,lName,sex,age];
    chart.titleLabel.text = imageFullName;
    [chart.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [chart.titleLabel sizeThatFits:CGSizeMake(30, 15)];
    [chart.titleLabel setTextAlignment:UITextAlignmentCenter];
    //Our xAxis is a category to take the discrete month data
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/DD/YYYY"];
    NSDate *date1 = [dateFormatter dateFromString:@"08/08/2005"];
    NSDate *date2 = [dateFormatter dateFromString:@"08/08/2013"];
    SChartDateRange *date = [[SChartDateRange alloc] initWithDateMinimum:date1 andDateMaximum:date2];
    //SChartNumberRange *date = [[SChartNumberRange alloc] initWithMinimum:date1  andMaximum:date2];
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:date];
    xAxis.title = @"Date";
    xAxis.tickLabelClippingModeHigh = SChartTickLabelClippingModeTicksAndLabelsPersist;
    //keep tick marks at the right end
    //Make some space at the axis limits to prevent clipping of the datapoints
    xAxis.rangePaddingHigh = [SChartDateFrequency dateFrequencyWithMonth:1];
    xAxis.rangePaddingLow = [SChartDateFrequency dateFrequencyWithMonth:1];
    //allow zooming and panning
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    xAxis.enableMomentumPanning = YES;
    xAxis.enableMomentumZooming = YES;
    // xAxis.axisPositionValue = [NSNumber numberWithInt: 0];
    xAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    chart.xAxis = xAxis;
    //Use a custom range to best display our data
    SChartNumberRange *r = [[SChartNumberRange alloc] initWithMinimum:[NSNumber numberWithInt:5
                                                                       ]
                                                           andMaximum:[NSNumber numberWithInt:225]];
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:r];
    yAxis.enableGesturePanning = YES;
    yAxis.enableGestureZooming = YES;
    yAxis.enableMomentumPanning = YES;
    yAxis.enableMomentumZooming = YES;
    yAxis.style.titleStyle.position = SChartTitlePositionBottomOrLeft;
    chart.yAxis = yAxis;
    //Only show the legend on the iPad
    SChartLegendStyle *lStyle = [[SChartLegendStyle alloc] init];
    [lStyle setTextAlignment:NSTextAlignmentCenter];
    [lStyle setFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0]];
    [lStyle setFontColor:[UIColor blackColor]];
    [lStyle setShowSymbols:YES];
    [lStyle setSymbolAlignment:SChartSeriesLegendAlignSymbolsLeft];
    chart.backgroundColor = [UIColor whiteColor];
    [chart.legend setAutosizeLabels:NO];
    [chart.legend setStyle:lStyle];
    [chart.legend setPosition:SChartLegendPositionMiddleRight];
    chart.legend.style.textAlignment = NSTextAlignmentLeft;
    chart.legend.position = SChartLegendPositionBottomMiddle ;
    chart.legend.maxSeriesPerLine = 6;
    chart.rotatesOnDeviceRotation=NO;
    chart.legend.hidden = YES;
    chart.legend.placement = SChartLegendPlacementOutsidePlotArea;
    chart.legend.backgroundColor = [UIColor whiteColor];
    return chart;
    
}

/*
 * Method name: displayChartSeriesinDetailVU
 * Description:To display the data points in line chart in Pre VU.
 * Parameters: CGRect,NSString,NSString
 * return ShinobiChart
 */

+ (ShinobiChart*)displayChartSeriesinDetailVU:(CGRect)frame :(NSString *)MaxWeightValue :(NSString *)MinWeightValue :(NSString *)MinDateValue:(NSString *)MaxDateValue   {
    
   // NSLog(@" weight max value %@",MaxWeightValue);
   // NSLog(@" weight min value %@",MinWeightValue);
    int weightMax = [MaxWeightValue intValue];
    int weightMin = [MinWeightValue intValue];
  //  NSLog(@" weight max value %d",weightMax);
   // NSLog(@" weight min value %d",weightMin);
    int PlusMax = 20;
    int ans = weightMax + PlusMax;
   // NSLog(@" weight max value %@",MaxDateValue);
   // NSLog(@" weight min value %@",MinDateValue);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [dateFormatter dateFromString:MinDateValue];
    NSDate *date2 = [dateFormatter dateFromString:MaxDateValue];
    welvuAppDelegate *appDelegate;
    // dateArray = [[NSMutableArray alloc]init];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *patientID=appDelegate.currentPatientInfo;
    /* BOOL iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
     
     if (iPad) {
     frame.origin.x += 9;
     frame.origin.y += 100;
     frame.size.width = 685;
     frame.size.height = 450;
     } else {
     frame.size.width -= 10;
     }*/
    ShinobiChart *chart = [[ShinobiChart alloc] initWithFrame:frame];
    chart.autoresizingMask = ~UIViewAutoresizingNone;
    chart.clipsToBounds = NO;
   // chart.crosshair.enableCrosshairLinesSet = YES;
    
    //Choose the light theme for this chart
    SChartLightTheme *theme = [SChartLightTheme new];
    //perform any theme stylign here before applying to the chart
    chart.theme = theme;
    //Double tap can either reset zoom or zoom in
    chart.gestureDoubleTapResetsZoom = YES;
   // [chart.crosshair setDefaultTooltip];
    NSString *fName =[patientID objectForKey:@"fname"];
    NSString *lName =[patientID objectForKey:@"lname"];
    NSString *sex= [patientID objectForKey:@"sex"];
    NSString *age= [patientID objectForKey:@"age"];
    NSString *space = @"                                           ";
    /*  NSString *imageFullName=[NSString stringWithFormat:@"%@ %@ %@ (%@)- %@ Years", space,fName,lName,sex,age];*/
    
    NSString *imageFullName=[NSString stringWithFormat:@"%@ %@ %@", space,fName,lName];
    chart.titleLabel.text = imageFullName;
    [chart.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [chart.titleLabel sizeThatFits:CGSizeMake(30, 15)];
    [chart.titleLabel setTextAlignment:UITextAlignmentCenter];
    SChartDateRange *date = [[SChartDateRange alloc] initWithDateMinimum:date1 andDateMaximum:date2];
    //SChartNumberRange *date = [[SChartNumberRange alloc] initWithMinimum:date1  andMaximum:date2];
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:date];
    xAxis.title = @"Date";
    xAxis.tickLabelClippingModeHigh = SChartTickLabelClippingModeTicksAndLabelsPersist;
    //keep tick marks at the right end
    //Make some space at the axis limits to prevent clipping of the datapoints
    xAxis.rangePaddingHigh = [SChartDateFrequency dateFrequencyWithMonth:1];
    xAxis.rangePaddingLow = [SChartDateFrequency dateFrequencyWithMonth:1];
    //allow zooming and panning
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    xAxis.enableMomentumPanning = YES;
    xAxis.enableMomentumZooming = YES;
    // xAxis.axisPositionValue = [NSNumber numberWithInt: 0];
    xAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    chart.xAxis = xAxis;
    //Use a custom range to best display our data
    SChartNumberRange *r = [[SChartNumberRange alloc] initWithMinimum:[NSNumber numberWithInt:10]
                                                           andMaximum:[NSNumber numberWithInt:ans]];
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:r];
    yAxis.enableGesturePanning = YES;
    yAxis.enableGestureZooming = YES;
    yAxis.enableMomentumPanning = YES;
    yAxis.enableMomentumZooming = YES;
    // yAxis.axisPositionValue = [NSNumber numberWithInt: 0];
    // yAxis.title = @"Weight(lbs), Height(inch), Temparature(C)";
    yAxis.style.titleStyle.position = SChartTitlePositionBottomOrLeft;
    chart.yAxis = yAxis;
    //Only show the legend on the iPad
    SChartLegendStyle *lStyle = [[SChartLegendStyle alloc] init];
    [lStyle setTextAlignment:NSTextAlignmentCenter];
    [lStyle setFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0]];
    [lStyle setFontColor:[UIColor blackColor]];
    [lStyle setShowSymbols:YES];
    [lStyle setSymbolAlignment:SChartSeriesLegendAlignSymbolsLeft];
    chart.backgroundColor = [UIColor whiteColor];
    //SChartLegend *legend1 = [[SChartLegend alloc] init];
    [chart.legend setAutosizeLabels:NO];
    [chart.legend setStyle:lStyle];
    [chart.legend setPosition:SChartLegendPositionMiddleRight];
    //chart.legend.frame = CGRectMake(10, 10, 20, 20);
    chart.legend.style.textAlignment = NSTextAlignmentLeft;
    //[chart.legend setClipsToBounds:YES];
    chart.legend.position = SChartLegendPositionBottomMiddle ;
    chart.legend.maxSeriesPerLine = 6;
    chart.rotatesOnDeviceRotation=NO;
    chart.legend.hidden = YES;
    chart.legend.placement = SChartLegendPlacementOutsidePlotArea;
    chart.legend.backgroundColor = [UIColor whiteColor];
    return chart;
    
}
@end
