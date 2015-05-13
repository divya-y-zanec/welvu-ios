//
//  UIBezierPath+Smoothing.h
//  welvu
//
//  Created by Senthil Kumar on 15/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIBezierPath(Smoothing)
void getPointsFromBezier(void *info, const CGPathElement *element);
NSArray *pointsFromBezierPath(UIBezierPath *bpath);
- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity;
@end
