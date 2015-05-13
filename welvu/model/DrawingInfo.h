//
//  DrawingInfo.h
//  welvu
//
//  Created by Logesh Kumaraguru on 16/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Class name: DrawingInfo
 * Description: Interface holds the information about the UIBezierPath of the drawn line with its color information
 * Extends: NSObject
 * Delegate : nil
 */
@interface DrawingInfo : NSObject {
    
    //Information about the drawing line/shape with color details
    UIBezierPath *path;
    
    UIColor *color;
    
}
//Propert
@property (nonatomic) UIBezierPath *path;
@property (nonatomic, copy) UIColor *color;

@end
