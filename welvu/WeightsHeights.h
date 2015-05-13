//
//  MobileBrowserUsageStats.h
//  LineChart

#import <Foundation/Foundation.h>
#import "WeightsHieghtsModel.h"
#import "welvu_settings.h"

/*
 * Class name: WeightsHeights
 * Description:To get all details and store it in mutable array.
 * Extends: NSObject
 * Delegate :WeightsHieghtsModel
 */

//A class that contain broser usage stats - in particular these are mobile browser stats
@interface WeightsHeights : NSObject <WeightsHieghtsModel>{
    welvuAppDelegate *appDelegate;
    NSDictionary *patientResponseDictionary;
    NSMutableArray *weightArray;
    NSMutableArray *heightArray;
    NSMutableArray *TemperatureArray;
    NSMutableArray *dateArray;
    NSMutableArray *formatedDateArray;
    NSMutableArray *nilArray;
    NSString *currentVital;
    NSMutableArray *bpsArray;
    NSMutableArray *bpdArray;
    NSMutableArray *bmiArray;
    NSInteger *graphOption;
    NSMutableArray *weightData;
    NSMutableArray *heightData;
    NSMutableArray *temparatureData;
    NSMutableArray *bpsData;
    NSMutableArray *bpdData;
    NSMutableArray *bmiData;
    NSString *maXValue;
    NSString *minValue;
    NSString *maxDate;
    NSString *minDate;
    NSInteger bpdData1;
    NSInteger TempData;
    NSInteger sampleData;
    NSMutableArray *sampleVAlues;
    //vital statitics
    welvu_settings *welvuSettingsModel;
    
    //Temperature
    NSMutableArray *tempFarArray;
    NSMutableArray *tempCelArray;
    NSMutableArray *tempFarData;
    NSMutableArray *tempCelData;
    NSInteger tempDataSettings;
    NSMutableArray *tempDataMutableArray;
    
    //Weights
    NSMutableArray *weightLbsArray;
    NSMutableArray *weightKgArray;
    NSMutableArray *weightLbsData;
    NSMutableArray *weightKgData;
    NSInteger *weightSettings;
    NSMutableArray *weightDataMutableArray;
    
    //Heights
    NSMutableArray *heightCmArray;
    NSMutableArray *heightInchesArray;
    NSMutableArray *heightCmData;
    NSMutableArray *heightInchesData;
    NSInteger heightSettings;
    NSMutableArray *heightDataMutableArray;
    
}
//vital statitics
@property (nonatomic,retain) NSMutableArray *tempFarArray;
@property (nonatomic,retain) NSMutableArray *tempCelArray;
@property (nonatomic,retain)  NSMutableArray *tempFarData;
@property (nonatomic,retain)  NSMutableArray *tempCelData;
@property (nonatomic ,readonly)  NSInteger tempDataSettings;
@property (nonatomic ,retain) NSMutableArray *tempDataMutableArray;

//Weight
@property (nonatomic,retain) NSMutableArray *weightLbsArray;
@property (nonatomic,retain) NSMutableArray *weightKgArray;
@property (nonatomic,retain)  NSMutableArray *weightLbsData;
@property (nonatomic,retain) NSMutableArray *weightKgData;
@property (nonatomic ,readonly)  NSInteger *weightSettings;
@property (nonatomic ,retain)  NSMutableArray *weightDataMutableArray;


//Height
@property (nonatomic,retain)   NSMutableArray *heightCmArray;
@property (nonatomic,retain) NSMutableArray *heightInchesArray;
@property (nonatomic,retain)    NSMutableArray *heightCmData;
@property (nonatomic,retain)  NSMutableArray *heightInchesData;
@property (nonatomic ,readonly)   NSInteger heightSettings;
@property (nonatomic ,retain)   NSMutableArray *heightDataMutableArray;

@property (nonatomic ,retain)  NSString *maxDate;
@property (nonatomic ,retain)   NSString *minDate;
@property (nonatomic ,retain)  NSString *maXValue;
@property (nonatomic ,retain)   NSString *minValue;
@property (nonatomic , retain) NSMutableArray *TemperatureArray;
@property (nonatomic) NSMutableDictionary *data;
@property (nonatomic) NSArray *months;
@property (nonatomic) NSArray *dataKeys;
@property (nonatomic,retain) NSMutableArray *weightArray;
@property (nonatomic,retain) NSMutableArray *heightArray;
@property (nonatomic,retain) NSMutableArray *dateArray;
@property (nonatomic,retain) NSMutableArray *formatedDateArray;
@property (nonatomic,retain) NSMutableArray *nilArray;
@property (nonatomic,strong) NSString *currentVital;
@property (nonatomic,retain) NSMutableArray *bpsArray;
@property (nonatomic,retain) NSMutableArray *bpdArray;
@property (nonatomic,retain) NSMutableArray *bmiArray;

@property (nonatomic) NSInteger *graphOption;
@property (nonatomic,retain) NSMutableArray *weightData;
@property (nonatomic,retain) NSMutableArray *heightData;
@property (nonatomic,retain) NSMutableArray *temparatureData;
@property (nonatomic,retain) NSMutableArray *bpsData;
@property (nonatomic,retain) NSMutableArray *bpdData;
@property (nonatomic,retain) NSMutableArray *bmiData;


//Methods
- (void)initlize:(NSString *)keyValue;
- (void)getMaxAndMinValueFromPoints;
- (void)getPatientVitals;
//vital statitics


@end
