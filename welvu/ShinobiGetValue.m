//
//  ShinobiGetValue.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "ShinobiGetValue.h"

@implementation ShinobiGetValue
@synthesize maxWeight,minWeight,maxDate,minDate;
@synthesize weightArray;


/*
 * Method name: getMaximumAndMinimumWeightValue
 * Description: Reterieve values to nsmutable array from current patient graph information.
 * Parameters: nil
 * return nil
 */
-(int)getMaximumAndMinimumWeightValue {
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    weightArray =[[NSMutableArray alloc]init];
    dateArray = [[NSMutableArray alloc]init];
    formatedDateArray = [[NSMutableArray alloc]init];
    for(NSDictionary *patient in appDelegate.currentPatientGraphInfo) {
        [weightArray addObject:[patient objectForKey:@"weight"]];
        [dateArray addObject:[patient objectForKey:@"vitalsdate"]];
        
    }
    
}

/*
 * Method name: getMaxAndMinValueFromPoints
 * Description: To get maximum and minimum value from nsmutable array
 * Parameters: nil
 * return nil
 */
- (void)getMaxAndMinValueFromPoints; {
    
    [self getMaximumAndMinimumWeightValue];
    maxWeight= [weightArray valueForKeyPath:@"@max.intValue"];
    minWeight= [weightArray valueForKeyPath:@"@min.intValue"];
    maxDate= [dateArray valueForKeyPath:@"@max.self"];
    minDate= [dateArray valueForKeyPath:@"@min.self"];
    
}

@end
