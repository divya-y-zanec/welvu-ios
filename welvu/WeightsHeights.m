//
//  MobileBrowserUsageStats.m
//  LineChart

#import "WeightsHeights.h"
#import "welvuMasterViewController.h"
#import "welvuContants.h"
#import "JSTokenField.h"
#import "welvu_patient_Doc.h"
#import "welvuDetailViewControllerIpad.h"
#import "welvu_settings.h"
#import <sqlite3.h>


@implementation WeightsHeights

@synthesize data = _data;
@synthesize dataKeys = _dataKeys;
@synthesize months = _months;
@synthesize weightArray, heightArray, dateArray,formatedDateArray, currentVital ,TemperatureArray, bpsArray,bpdArray, bmiArray;
@synthesize weightData,heightData,temparatureData, bpdData, bpsData, bmiData ,maXValue ,minValue ,maxDate,minDate;
int count;
//vital statitics
@synthesize  tempCelArray,tempCelData,tempFarArray,tempFarData;
@synthesize tempDataSettings ,tempDataMutableArray;
@synthesize weightDataMutableArray,weightKgArray,weightKgData,weightLbsArray,weightLbsData,weightSettings;
@synthesize heightCmArray,heightCmData,heightDataMutableArray,heightInchesArray,heightInchesData,heightSettings;


/*
 * Method name: init
 * Description: Initlize the mutable array to displau patient graph
 * Parameters: nil
 * Return Type: id
 */


- (id)init {
    
    self = [super init];
    //vital statitics
    tempCelArray = [[NSMutableArray alloc]init];
    tempCelData = [[NSMutableArray alloc]init];
    tempFarArray = [[NSMutableArray alloc]init];
    tempFarData = [[NSMutableArray alloc]init];
    tempDataMutableArray = [[NSMutableArray alloc]init];
    //vital statitics
    weightKgArray = [[NSMutableArray alloc]init];
    weightKgData = [[NSMutableArray alloc]init];
    weightLbsArray = [[NSMutableArray alloc]init];
    weightLbsData = [[NSMutableArray alloc]init];
    weightDataMutableArray = [[NSMutableArray alloc]init];
    
    
    //vital statitics
    heightCmArray = [[NSMutableArray alloc]init];
    heightCmData = [[NSMutableArray alloc]init];
    heightInchesData = [[NSMutableArray alloc]init];
    heightInchesArray = [[NSMutableArray alloc]init];
    heightDataMutableArray = [[NSMutableArray alloc]init];
    
    
    
    weightArray = [[NSMutableArray alloc]init];
    heightArray = [[NSMutableArray alloc]init];
    dateArray = [[NSMutableArray alloc]init];
    formatedDateArray = [[NSMutableArray alloc]init];
    TemperatureArray = [[NSMutableArray alloc]init];
    bpsArray = [[NSMutableArray alloc]init];
    bpdArray = [[NSMutableArray alloc]init];
    bmiArray = [[NSMutableArray alloc]init];
    
    weightData = [[NSMutableArray alloc]init];
    heightData = [[NSMutableArray alloc]init];
    temparatureData = [[NSMutableArray alloc]init];
    bpsData = [[NSMutableArray alloc]init];
    bpdData = [[NSMutableArray alloc]init];
    bmiData = [[NSMutableArray alloc]init];
    
    
    
    sampleVAlues = [[NSMutableArray alloc]init];
    
    weightData = nil;
    heightData = nil;
    temparatureData = nil;
    bpsData = nil;
    bpdData = nil;
    bmiData = nil;
    
    //vital statitics
    tempFarData = nil;
    tempCelData = nil;
    
    [self getPatientVitals];
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    welvuSettingsModel = [[welvu_settings alloc]init];
    
    welvuSettingsModel = [welvu_settings getActiveSettings:[appDelegate getDBPath]];
    
   // NSLog(@"welvusettingsmodel %@",welvuSettingsModel);
    
    tempDataSettings = welvuSettingsModel.temperature;
    weightSettings = welvuSettingsModel.weight;
    heightSettings = welvuSettingsModel.height;
    //NSLog(@"weight value %d",tempDataSettings);
    
    if (self) {
        
        _data = [NSMutableDictionary new];
        
        
        
        for (int i = 0; i < count; i++) {
            
            NSString *x =[dateArray objectAtIndex:i];
            NSDateFormatter *dateFormatter  =   [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *yourDate  =   [dateFormatter dateFromString:x];
            
            
            //NSLog(@" %@",yourDate);
            [formatedDateArray addObject:yourDate];
        }
        
        _months = formatedDateArray;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        currentVital = [prefs stringForKey:@"Weightselected"];
        
        NSString *heightSelector = [prefs stringForKey:@"Heightselected"];
        NSString *temperatureSelector = [prefs stringForKey:@"Tempselected"];
        NSString *pressureSelector = [prefs stringForKey:@"Pressureselected"];
        NSString *BmiSelector = [prefs stringForKey:@"BMIselected"];
        
        
        NSDictionary *point;
        ///santhosh
        
        if (currentVital== @"Weightselected") {
            
            
            if(weightSettings == 0) {
                
                weightDataMutableArray = weightLbsArray;
            } else {
                weightDataMutableArray = weightKgArray;
            }
            
            if (weightData == weightDataMutableArray ) {
                weightData = nil;
                
                
            }
            else {
                weightData = weightDataMutableArray;
                SChartLineSeries *series = [SChartLineSeries new];
                series.style.lineColor=[UIColor blackColor];
                series.style.pointStyle.color = [UIColor blackColor];
            }
            [prefs removeObjectForKey:@"Series selected"];
            
        }
        if (heightSelector== @"Heightselected") {
            
            
            if(heightSettings == 0) {
                
                heightDataMutableArray = heightCmArray;
            } else {
                heightDataMutableArray = heightInchesArray;
            }
            
            
            if (heightData == heightDataMutableArray) {
                heightData = nil;
                SChartLineSeries *series = [SChartLineSeries new];
                series.style.lineColor=[UIColor blackColor];
                series.style.pointStyle.color = [UIColor blackColor];
                
                
            }
            else{
                heightData = heightDataMutableArray;
                SChartLineSeries *series = [SChartLineSeries new];
                series.style.lineColor=[UIColor purpleColor];
                series.style.pointStyle.color = [UIColor purpleColor];
                
            }
            [prefs removeObjectForKey:@"Series selected"];
        }
        if (temperatureSelector== @"Tempselected") {
            if(tempDataSettings == 0) {
                
                tempDataMutableArray = tempFarArray;
            } else {
                tempDataMutableArray = tempCelArray;
            }
            
            
            if (temparatureData== tempDataMutableArray) {
                temparatureData = nil;
            }
            else {
                
                temparatureData= tempDataMutableArray;
                SChartLineSeries *series = [SChartLineSeries new];
                series.style.lineColor=[UIColor brownColor];
                series.style.pointStyle.color = [UIColor brownColor];
                
            }
            [prefs removeObjectForKey:@"Series selected"];
        }
        if (pressureSelector== @"Pressureselected" ) {
            if (bpsData == bpsArray || bpdData == bpdArray) {
                bpsData = nil;
                bpdData = nil;
            }
            else {
                bpsData = bpsArray;
                bpdData = bpdArray;
                
            }
            [prefs removeObjectForKey:@"Series selected"];
        }
        if (BmiSelector == @"BMIselected" ) {
            if (bmiData== bmiArray) {
                bmiData = nil;
                
            }
            else {
                NSLog(@"bmiArray %@",bmiArray);
                bmiData= bmiArray;
                
            }
            
            [prefs removeObjectForKey:@"Series selected"];
        }
        
        
        _dataKeys = [NSArray arrayWithObjects:@"Temperature", @"Height", @"Weight", @"bps", @"bpd", @"bmi" , nil];
        
        for (int i = 0; i < count; i++) {
            
            
            
            NSInteger diff = [[temparatureData objectAtIndex:i] intValue];
            NSInteger difff = [[heightData objectAtIndex:i] intValue];
            NSInteger diffff = [[weightData objectAtIndex:i] intValue];
            NSInteger dif = [[bpdData objectAtIndex:i] intValue];
            NSInteger di = [[bpsData objectAtIndex:i] intValue];
            NSInteger d = [[bmiData objectAtIndex:i] intValue];
            point = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                         [NSNumber numberWithFloat:diff],
                                                         [NSNumber numberWithFloat:difff],
                                                         [NSNumber numberWithFloat:diffff],                                                 [NSNumber numberWithFloat:dif],
                                                         [NSNumber numberWithFloat:di],
                                                         [NSNumber numberWithFloat:d],
                                                         nil] forKeys:_dataKeys];
    
            
            
            [_data setObject:point forKey:[_months objectAtIndex:i]];
        }
        
        
        
        //try E
        
        [prefs removeObjectForKey:@"Series selected"];
    }
    
    return self;
}

/*
 * Method name: incomingNotification
 * Description: to get the incoming notifcation for the object
 * Parameters: notification
 * return nil
 */


- (void) incomingNotification:(NSNotification *)notification{
    currentVital = [notification object];
   // NSLog(@" %@",currentVital);
}

/*
 * Method name: getPatientVitals
 * Description: To get patient vitals
 * Parameters: nil
 * return nil
 */
-(void)getPatientVitals{
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
   // NSLog(@"graph vitals %@", appDelegate.currentPatientGraphInfo);
    count = appDelegate.currentPatientGraphInfo.count;
    for(NSDictionary *patient in appDelegate.currentPatientGraphInfo) {
        [weightArray addObject:[patient objectForKey:@"weight"]];
        [heightArray addObject:[patient objectForKey:@"height"]];
        [TemperatureArray addObject:[patient objectForKey:@"temperature"]];
        [dateArray addObject:[patient objectForKey:@"vitalsdate"]];
        [bpsArray addObject:[patient objectForKey:@"bps"]];
        [bpdArray addObject:[patient objectForKey:@"bpd"]];
        [bmiArray addObject:[patient objectForKey:@"bmi"]];
        NSLog(@"bmi string %@",[patient objectForKey:@"bmi"]);
        NSLog(@"bmi string %d",[patient objectForKey:@"bmi"]);
        //vital statitics
        [tempCelArray addObject:[patient objectForKey:@"temperatureC"]];
        [tempFarArray addObject:[patient objectForKey:@"temperatureF"]];
        
        [weightKgArray addObject:[patient objectForKey:@"weightkg"]];
        
        [weightLbsArray addObject:[patient objectForKey:@"weightlbs"]];
        
        
        [heightInchesArray addObject:[patient objectForKey:@"heightin"]];
        
        [heightCmArray addObject:[patient objectForKey:@"heightcm"]];
        
        
        if ((NSNull *)heightInchesArray == [NSNull null]){
           // NSLog(@"Patient Weight null");
            
        }
        if ((NSNull *)heightCmArray == [NSNull null]){
           // NSLog(@"Patient Weight null");
            
        }
        
        
        if ((NSNull *)weightKgArray == [NSNull null]){
          //  NSLog(@"Patient Weight null");
            
        }
        if ((NSNull *)weightLbsArray == [NSNull null]){
         //   NSLog(@"Patient Weight null");
            
        }
        
        
        if ((NSNull *)tempCelArray == [NSNull null]){
            //NSLog(@"Patient Weight null");
            
        }
        if ((NSNull *)tempFarArray == [NSNull null]){
          //  NSLog(@"Patient Weight null");
            
        }
        
        //vital statitics
        
        if ((NSNull *)weightArray == [NSNull null]){
           // NSLog(@"Patient Weight null");
            
        }
        if ((NSNull *)heightArray == [NSNull null]){
           // NSLog(@"Patient Height null");
            
        }
        if ((NSNull *)TemperatureArray == [NSNull null]){
           // NSLog(@"Patient temperature null");
            
        }
        if ((NSNull *)dateArray == [NSNull null]){
           // NSLog(@"Patient date null");
            
        }
        if ((NSNull *)bpsArray == [NSNull null]){
          //  NSLog(@"bps image null");
            
        }
        if ((NSNull *)bpdArray == [NSNull null]){
           // NSLog(@"Patient bpd null");
            
        }
        if ((NSNull *)bmiArray == [NSNull null]){
            NSLog(@"Patient bmi null");
          //
        }
        
        
        NSArray *subStrings = [[patient objectForKey:@"vitalsdate"] componentsSeparatedByString:@" "];
        //or rather @" - "
        NSArray *currentDate= [subStrings objectAtIndex:0];
        if (bpsArray == @" ") {
            //NSLog(@" %@",nilArray);
        }
       /* NSLog(@"Patient Weight %@", [patient objectForKey:@"weight"]);
        NSLog(@"Patient height %@", [patient objectForKey:@"height"]);
        NSLog(@"Patient temperature %@", [patient objectForKey:@"temperature"]);
        NSLog(@"Patient vitalsdate %@", [patient objectForKey:@"vitalsdate"]);
        NSLog(@"Patient bps %@", [patient objectForKey:@"bps"]);
        NSLog(@"Patient bpd %@", [patient objectForKey:@"bpd"]);
        NSLog(@"Patient bmi %@", [patient objectForKey:@"bmi"]);*/
        
          }
    //To get maximum and minimum value in weight
   }

/*
 * Method name: getMaxAndMinValueFromPoints
 * Description: To get maximum and minimum value from data points
 * Parameters: nil
 * return nil
 */

- (void)getMaxAndMinValueFromPoints; {
    maXValue= [weightArray valueForKeyPath:@"@max.intValue"];
    minValue= [weightArray valueForKeyPath:@"@min.intValue"];
    maxDate = [dateArray valueForKeyPath:@"@max.intValue"];
    minDate= [dateArray valueForKeyPath:@"@min.intValue"];
    
   // NSLog(@"max va,ue %@",maXValue);
   // NSLog(@"min value %@",minValue);
}


@end
