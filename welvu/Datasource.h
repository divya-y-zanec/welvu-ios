//
//  Datasource.h
//  LineChart

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiChart.h>
#import "WeightsHieghtsModel.h"

@interface Datasource : NSObject <SChartDatasource>

@property (nonatomic) id<WeightsHieghtsModel> browserUsageStats;

@end
