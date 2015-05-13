//
//  welvuTopicVUCell.h
//  welvu
//
//  Created by Logesh Kumaraguru on 24/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface welvuTopicVUCell : UITableViewCell {
    IBOutlet UILabel *topicLabel;
    IBOutlet UILabel *topicImagesLabel;
    IBOutlet UILabel *topicImagesSelectedLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *topicLabel;
@property (nonatomic, retain) IBOutlet UILabel *topicImagesLabel;
@property (nonatomic, retain) IBOutlet UILabel *topicImagesSelectedLabel;
@end
