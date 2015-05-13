//
//  NonRotatingUIImagePickerController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 18/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "NonRotatingUIImagePickerController.h"

@interface NonRotatingUIImagePickerController ()

@end

@implementation NonRotatingUIImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)shouldAutorotate {

    return NO;
}
@end
