//
//  welvuRegistrationViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 23/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxSDK/BoxSDK.h>
#import "welvu_registration.h"
#import "welvu_user.h"
#import "HTTPRequestHandler.h"
#import "ProcessingSpinnerView.h"
#import "UILabelErrorMessage.h"
#import <MediaPlayer/MediaPlayer.h>
#import "welvuOrganizationViewController.h"
#import "welvu_organization.h"
#import "welvu_oauth.h"

//Delegate method to return selected content
@protocol welvuRegistrationViewControllerDelegate
-(void)welvuLoginCompletedWithAccessToken;
-(void)welvuLoginCompletedWithPinAccessToken;

@end
/*
 * Class name: welvuRegistrationViewController
 * Description:User will register and login in the view
 * Extends: UIViewController
 * Delegate :UIPickerViewDelegate,UITextFieldDelegate,HTTPRequestHandlerDelegate
 */

@interface welvuRegistrationViewController : UIViewController <UIPickerViewDelegate,
UITextFieldDelegate, HTTPRequestHandlerDelegate, welvuOrganizationViewControllerDelegate> {
    //Defining the delegate for this controller
    id<welvuRegistrationViewControllerDelegate> delegate;
    
    //For orientation
    BOOL isLandScapeMode;
    welvuAppDelegate *appDelegate;
    //For View
    IBOutlet UIView *container;
    IBOutlet UIView *registrationView;
    IBOutlet UIView *loginView;
    IBOutlet UIView*  helpView;
    MPMoviePlayerController *moviePlayer;
    UIView *replayOverlay;
    IBOutlet UITextField *name;
    IBOutlet UITextField *username;
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    IBOutlet UITextField *specialty;
    IBOutlet UIPickerView *specialtyPicker;
    IBOutlet UITextField *confirmPassword;
    IBOutlet UITextField *organization;
    IBOutlet UITextField *phoneNumber;
    //For Error Message
    IBOutlet UILabelErrorMessage *errorName;
    IBOutlet UILabelErrorMessage *errorSpecialty;
    IBOutlet UILabelErrorMessage *errorUsername;
    IBOutlet UILabelErrorMessage *errorEmail;
    IBOutlet UILabelErrorMessage *errorPassword;
    IBOutlet UILabelErrorMessage *errorConfirmPassword;
    IBOutlet UILabelErrorMessage *errorOrganization;
    IBOutlet UILabelErrorMessage *errorPhone;
    NSMutableArray *specialtyTypes;
    BOOL isForOption;
    //Login TextField
    IBOutlet UITextField *loginUserName;
    IBOutlet UITextField *loginPassword;
    //Login error label
    IBOutlet UILabelErrorMessage *errorLoginUsername;
    IBOutlet UILabelErrorMessage *errorLoginPassword;
    welvu_registration *registration;
    welvu_user *welvu_userModel;
    //Recording animation text
    ProcessingSpinnerView *spinner;
    //Forgot Password
    IBOutlet UIButton *forgotPassword;
    //Box
    IBOutlet UIButton *boxLoginBtn;
    NSMutableArray *  welvu_OrganizationArray;
    BOOL orgDetails;
    BOOL OrgInsert;
    BOOL updateOnly ;
    BOOL orgUpdated;
    BOOL sucessRegistrationAlert;
    BOOL orgCountPin;
     BOOL confirmUser;
    NSInteger organizationCount;
    
    //oauth
    NSURLConnection *loginConnection;
    welvu_oauth *welvu_oauthModel;
    NSURLConnection *getSpecialty;
    NSURLConnection *getOrganization;
    NSURLConnection *getRegistration;
    NSDictionary *getOrgResponseDictionary;
    
    NSString *registerUsername;
    NSString *registerPassword;
    NSURLConnection *authorize;
    NSString *responseStr;
}
//Oauth
@property (retain) NSString *responseStr;
@property (nonatomic ,retain)  NSString *registerUsername;
@property (nonatomic ,retain) NSString *registerPassword;

@property (nonatomic ,retain)  welvu_oauth *welvu_oauthModel;
@property (nonatomic ,readwrite)  BOOL orgCountPin;
@property (nonatomic ,readwrite)  BOOL pinFlagValue;
@property (nonatomic ,readwrite) BOOL sucessRegistrationAlert;
//Assigning the property for the delegate object
@property (retain) id<welvuRegistrationViewControllerDelegate> delegate;
@property (nonatomic ,readwrite)  BOOL orgDetails;
@property (nonatomic ,readwrite)  BOOL OrgInsert;
@property (nonatomic ,readwrite)  BOOL updateOnly;
@property (nonatomic ,readwrite)  BOOL orgUpdated;
@property (nonatomic ,readwrite)  BOOL confirmUser;
@property (nonatomic ,readwrite) NSInteger organizationCount;
@property (nonatomic ,retain) UIView * pinViewbase;
@property (nonatomic ,retain) NSDictionary *responseDictionaryy;
@property (nonatomic ,retain) NSString *actionAPi;

//Action Methods
-(IBAction)specialtyOptionBtnClicked:(id)sender;
-(IBAction)registerOptionBtnClicked:(id)sender;
-(IBAction)loginBtnClicked:(id)sender;
-(IBAction)helpContinueBtnClicked:(id)sender;
-(IBAction)showPicker:(id)sender;
-(IBAction)closePicker:(id)sender;
-(IBAction)forgotPassword:(id)sender;
-(IBAction)boxLoginBtnClicked:(id)sender;
- (void)addOrganizationUserDetails;
//-(void)welvuOrganizationViewController;
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName;

-(BOOL)validateTextField:(NSString *)textField:(NSInteger) allowedLength;
- (BOOL) validateEmail: (NSString *) candidate;
-(void) loginUserWithOrganization :(NSInteger) user_id orgId:(NSInteger)orgId;
-(void)registerLoginContinue;

@end
