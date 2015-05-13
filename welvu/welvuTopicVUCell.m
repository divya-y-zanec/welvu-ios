//
//  welvuTopicVUCell.m
//  welvu
//
//  Created by Logesh Kumaraguru on 24/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuTopicVUCell.h"
#import "welvuContants.h"
#import "GAI.h"

@implementation welvuTopicVUCell
@synthesize topicImagesLabel, topicLabel, topicImagesSelectedLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //Declaring Page View Analytics
       
    }
    return self;
}
//Configure the tableview cell for topicvu
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    topicImagesSelectedLabel.layer.cornerRadius = 5;
    topicImagesSelectedLabel.textColor= [UIColor whiteColor];
    topicImagesSelectedLabel.backgroundColor = SELECTED_COLOR;
    //Configure the view for the selected state
}
@end
