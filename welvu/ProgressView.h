//
//  ProgressView.h
//  welvu
//
//  Created by Logesh Kumaraguru on 08/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 * Class name: ProgressView
 * Description: To show progress view
 * Extends: UIView
 * Delegate :nil
 */
@interface ProgressView : UIView {
    UIProgressView *progressView;
    UILabel *progressStatus;
    double progressLevel;
}
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UILabel *progressStatus;

-(void) progressStatus:(double) progLevel;
@end
