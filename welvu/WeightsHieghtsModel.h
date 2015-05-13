//
//  WeightsHieghtsModel.h
//  LineChart

#import <Foundation/Foundation.h>

//user defined values
#define  Weight @"Weight"
#define Height @"Height"
#define Temperature @"Temperature"
#define bps @"bps"
#define bpd @"bpd"
#define bmi @"bmi"
//This interface allows the data source to take any kind of
//browser data as long as it conforms
@protocol WeightsHieghtsModel <NSObject>

@required
- (NSMutableDictionary*) data;
- (NSArray*) months;
- (NSArray*) dataKeys;

@end
