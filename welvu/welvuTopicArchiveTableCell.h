//
//  welvuTopicArchiveTableCell.h
//  welvu
//
//  Created by Logesh Kumaraguru on 23/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface welvuTopicArchiveTableCell : UITableViewCell {
    IBOutlet UILabel *topicLabel;
    IBOutlet UIButton *checkBox;
    BOOL checked;
}
@property (nonatomic, retain) IBOutlet UILabel *topicLabel;
@property (nonatomic, retain) IBOutlet UIButton *checkBox;
@property (nonatomic, readwrite) BOOL checked;
@end
