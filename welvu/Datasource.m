//
//  Datasource.m
//  LineChart

#import "Datasource.h"
#import "ShinobiChart+LineChart.h"

@implementation Datasource

- (int)numberOfSeriesInSChart:(ShinobiChart *)chart {
    return [_browserUsageStats dataKeys].count;
}

- (SChartSeries*)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index {
    return [chart lineSeriesForKey:[[_browserUsageStats dataKeys] objectAtIndex:index]];
}

- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    return [_browserUsageStats months].count;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex {
    SChartDataPoint *dp = [SChartDataPoint new];
    
    //Map our data values from the data to our chart
    dp.xValue =  [[_browserUsageStats months] objectAtIndex:[_browserUsageStats months].count - dataIndex - 1];
    dp.yValue = [[[_browserUsageStats data] objectForKey:dp.xValue] objectForKey:[[_browserUsageStats dataKeys] objectAtIndex:seriesIndex]];
    
    return dp;
}


@end
