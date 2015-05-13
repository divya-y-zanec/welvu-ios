//
//  welvuTopicArchiveTableCell.m
//  welvu
//
//  Created by Logesh Kumaraguru on 23/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuTopicArchiveTableCell.h"
#import "welvuContants.h"
#import "GAI.h"
@implementation welvuTopicArchiveTableCell
@synthesize topicLabel, checkBox, checked;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        checked = false;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
