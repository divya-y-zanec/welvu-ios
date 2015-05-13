//
//  ShinobiChart+LineChart.h
//  LineChart

#import <ShinobiCharts/ShinobiChart.h>
#import "welvuAppDelegate.h"

@interface ShinobiChart (LineChart)


//Returns a new chart object that displays browser usage using line series types
+ (ShinobiChart*)lineChartForBrowserUsageWithFrame:(CGRect)frame;

+ (ShinobiChart*)displayChartSeriesinDetailVU:(CGRect)frame :(NSString *)MaxWeightValue :(NSString * )MinWeightValue;
//A line series styled and ready for the data source to link to
//the browser data
- (SChartSeries*)lineSeriesForKey:(NSString*)key;

- (void)setDataPoint:(id<SChartData>)dataPoint fromSeries:(SChartSeries *)series fromChart:(ShinobiChart *)chart;

+ (ShinobiChart*)displayChartSeriesinDetailVU:(CGRect)frame :(NSString *)MaxWeightValue :(NSString *)MinWeightValue :(NSString *)MinDateValue:(NSString *)MaxDateValue ;

@end
