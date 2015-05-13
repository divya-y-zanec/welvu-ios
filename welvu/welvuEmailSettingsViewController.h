//
//  EmailSettingsViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvu_settings.h"
#import "welvuAppDelegate.h"
//Delegate method to return selected content
@protocol EmailSettingsViewControllerDelegate
- (void)emailSettingsViewControllerDidFinish;
- (void)emailSettingsViewControllerDidClose;
@end
/*
 * Class name: welvuEmailSettingsViewController
 * Description: To Display ShareVU in settings
 * Extends: UIViewController
 * Delegate : UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate
 */
@interface welvuEmailSettingsViewController : UIViewController<UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate> {
    
    //Assigning the delegate for the view
    id<EmailSettingsViewControllerDelegate> delegate;

    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *emailSettingsTableView;
    
    NSMutableArray *tableGroup;
    NSMutableArray *headers;
    
    //textfield
    UITextField *subjectTxtField;
    UITextView *signatureTextView;
    
    UITextField *phiSubjectTxtField;
    UITextView *phiSignatureTextView;
    
    welvuAppDelegate *appDelegate;
    welvu_settings *currentWelvuSettings;
}
//Assigning the property for the Delegate
@property (retain) id<EmailSettingsViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *tableGroup;
@property (nonatomic,retain) NSMutableArray *headers;

-(id) initWithEmailSettings:(welvu_settings *) welvu_settings_model;
//Action Methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
@end
