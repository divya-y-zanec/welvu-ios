//
//  welvuShareViewController.m
//  welvu
//
//  Created by Divya Yadav. on 31/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuShareViewController.h"
#import "welvuContants.h"

@implementation welvuShareViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/*
 * Method name: shareBtnSelected
 * Description: To Share the content
 * Parameters: id
 * return nil
 */
-(IBAction)shareBtnSelected:(id)sender {
    [self.delegate shareChoiceSelected:[sender tag]];
}
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
