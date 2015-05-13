//
//  ShinobiGetValue.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "welvuAppDelegate.h"


/*
 * Class name: ShinobiGetValue
 * Description:To get maximum and minimum value from data points.
 * Extends: NSObject
 * Delegate :nil */
@interface ShinobiGetValue : NSObject {
    welvuAppDelegate *appDelegate;
    NSMutableArray *weightArray;
    NSString * maxWeight;
    NSString * minWeight;
    NSString *maxDate;
    NSString *minDate;
    NSMutableArray *dateArray;
    NSMutableArray *formatedDateArray;
}

//Property
@property (nonatomic ,retain) NSMutableArray *weightArray;
@property (nonatomic ,readwrite) NSString * maxWeight;
@property (nonatomic ,readwrite) NSString * minWeight;
@property (nonatomic ,readwrite) NSString * maxDate;
@property (nonatomic ,readwrite) NSString * minDate;

//Methods
-(int)getMaximumAndMinimumWeightValue;
- (void)getMaxAndMinValueFromPoints;
@end
