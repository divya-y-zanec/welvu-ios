//
//  ProcessingSpinnerView.h
//  Welvu
//
//  Created by Logesh Kumaraguru on 30/07/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 * Class name: ProcessingSpinnerView
 * Description: To show the progress indicator in the application
 * Extends: UIView
 * Delegate :nil
 */
@interface ProcessingSpinnerView : UIView {
    BOOL isSpinner;
    NSString *processingText;
}
@property (nonatomic, readwrite) BOOL isSpinner;
- (id)initWithFrameAndProcessingText:(CGRect)frame:(NSString *)procText;
+(ProcessingSpinnerView *)loadSpinnerIntoView:(UIView *)superView;
+(ProcessingSpinnerView *)loadSpinnerIntoView:(UIView *)superView:(NSString *) procText;
-(void)removeSpinner;
- (UIImage *)addBackground;
@end
