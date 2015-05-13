//
//  EmailSettingsViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "welvuEmailSettingsViewController.h"
#import "welvuContants.h"
#import "GAI.h"
@interface welvuEmailSettingsViewController ()

@end

@implementation welvuEmailSettingsViewController
@synthesize delegate, headers,tableGroup;
/*
 * Method name: initWithNibName
 * Description: initlizing with nib file
 * Parameters: bundle
 * return self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_EMAIL_HEADER", nil);
    }
    return self;
}
/*
 * Method name: initWithEmailSettings
 * Description: initlizing with Email settings
 * Parameters: welvu_settings_model
 * return self
 */
-(id) initWithEmailSettings:(welvu_settings *) welvu_settings_model {
    self = [super initWithNibName:@"welvuEmailSettingsViewController" bundle:nil];
    if (self) {
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        
        currentWelvuSettings = welvu_settings_model;
        headers = [[NSMutableArray alloc] init];
        [headers addObject:NSLocalizedString(@"SETTINGS_SHARE_VU_HEADER", nil)];
        [headers addObject:SETTINGS_SHARE_VU_HEADER];
        [headers addObject:SETTINGS_SHARE_VU_PHI_HEADER];
        
        
        NSMutableArray *shareVUControl = [NSMutableArray arrayWithObjects:SETTINGS_SHARE_VU_SUBJECT_TEXT,
                                          SETTINGS_SHARE_VU_SIGNATURE_TEXT, nil];
        
        NSMutableArray *shareVUPHIControl = [NSMutableArray arrayWithObjects:SETTINGS_SHARE_VU_SUBJECT_TEXT,
                                             SETTINGS_SHARE_VU_SIGNATURE_TEXT, nil];
        
        NSMutableArray *shareVUType = [NSMutableArray arrayWithObjects:NSLocalizedString(@"SETTINGS_SHARE_VU_DEFAULT", nil),
                                             NSLocalizedString(@"SETTINGS_SHARE_VU_SECURED", nil), nil];
        
        tableGroup = [[NSMutableArray alloc] init];
        [tableGroup addObject:shareVUType];
        [tableGroup addObject:shareVUControl];
        [tableGroup addObject:shareVUPHIControl];
        
        
    }
    return self;
}
/*
 * Method name: doneBtnClicked
 * Description: save the description
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)doneBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
        
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Email Settings - ES"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Email Settings - ES"
                                                    action:@"Email Settings Confirmed - ES"
                                                           label:@"Save"
                                                           value:nil] build]];
    

    
    @try {

        if( appDelegate.isSettingsChanged == TRUE){
            NSRange range = [[subjectTxtField text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
            currentWelvuSettings.shareVUSubject= [[subjectTxtField text] stringByReplacingCharactersInRange:range withString:@""];
            
            range = [[signatureTextView text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
            currentWelvuSettings.shareVUSignature= [[signatureTextView text] stringByReplacingCharactersInRange:range withString:@""];
            
            range = [[phiSubjectTxtField text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
            currentWelvuSettings.phiShareVUSubject= [[phiSubjectTxtField text] stringByReplacingCharactersInRange:range withString:@""];
            
            range = [[phiSignatureTextView text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
            currentWelvuSettings.phiShareVUSignature= [[phiSignatureTextView text] stringByReplacingCharactersInRange:range withString:@""];
            
            [subjectTxtField resignFirstResponder];
            [signatureTextView resignFirstResponder];
            [phiSubjectTxtField resignFirstResponder];
            [phiSignatureTextView resignFirstResponder];
            [self.delegate emailSettingsViewControllerDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;

        [self.delegate emailSettingsViewControllerDidClose];
}
@catch (NSException *exception) {
    
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    NSString * description = [NSString stringWithFormat:@"EmailSettings-ES_Save:%@",exception];
    [tracker send:[[GAIDictionaryBuilder
                    createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                    withFatal:NO] build]];

}
}
/*
 * Method name: backBtnClicked
 * Description: navigate to another view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */


-(IBAction)backBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
       id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Email Settings - ES"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Email Settings - ES"
                                                          action:@"Go Back - ES"
                                                           label:@"Back"
                                                           value:nil] build]];
    

    @try {
        //
         if( appDelegate.isSettingsChanged == TRUE){
        NSRange range = [[subjectTxtField text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        currentWelvuSettings.shareVUSubject= [[subjectTxtField text] stringByReplacingCharactersInRange:range withString:@""];
        
        range = [[signatureTextView text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        currentWelvuSettings.shareVUSignature= [[signatureTextView text] stringByReplacingCharactersInRange:range withString:@""];
        
        range = [[phiSubjectTxtField text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        currentWelvuSettings.phiShareVUSubject= [[phiSubjectTxtField text] stringByReplacingCharactersInRange:range withString:@""];
        
        range = [[phiSignatureTextView text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        currentWelvuSettings.phiShareVUSignature= [[phiSignatureTextView text] stringByReplacingCharactersInRange:range withString:@""];
        
        [subjectTxtField resignFirstResponder];
        [signatureTextView resignFirstResponder];
        [phiSubjectTxtField resignFirstResponder];
        [phiSignatureTextView resignFirstResponder];
        [self.delegate emailSettingsViewControllerDidFinish];
         }
        appDelegate.isSettingsChanged = FALSE;
        //
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
             
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"EmailSettings-ES_Back:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

    }
}

#pragma mark Table Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(headers != nil) {
        return [headers count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(headers != nil && [headers objectAtIndex:section] != nil) {
        return SectionHeaderHeight;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 1) {
        return 220.0;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(self.headers != nil) {
        
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
       // NSLog(@"current version %@",currSysVer);
        NSArray *arr = [currSysVer componentsSeparatedByString:@"."];
        NSString *versionValue = [arr objectAtIndex:0];
        //NSLog(@"Version Value %@",versionValue);
        
        UILabel *label = [[UILabel alloc] init];
        if([versionValue isEqualToString: @"7"]) {
            
            
            label.frame = CGRectMake(0, 6, SectionHeaderWidth, SectionHeaderHeight);
        } else {
            label.frame = CGRectMake(20, 6, SectionHeaderWidth, SectionHeaderHeight);
            
        }
        
        
        // Create label with section title
    // UILabel *label = [[UILabel alloc] init];
        //label.frame = CGRectMake(20, 6, SectionHeaderWidth, SectionHeaderHeight);
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.text = (NSString *)[headers objectAtIndex:section];
        
        // Create header view and add label as a subview
      UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SectionHeaderWidth, SectionHeaderHeight)];
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)table
 numberOfRowsInSection:(NSInteger)section {
    if(tableGroup != nil) {
        NSMutableArray *listData =[tableGroup objectAtIndex:section];
        return [listData count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *tableIdentifier = nil;
    
    switch (indexPath.section) {
        case 2:
            
            switch (indexPath.row) {
                case 0: {
                    tableIdentifier = SETTINGS_SHARE_VU_SUBJECT_TEXT;
                }
                    break;
                case 1: {
                    tableIdentifier = SETTINGS_SHARE_VU_SIGNATURE_TEXT;
                    
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0: {
                    tableIdentifier = SETTINGS_SHARE_VU_SUBJECT_TEXT;
                }
                    break;
                case 1: {
                    tableIdentifier = SETTINGS_SHARE_VU_SIGNATURE_TEXT;
                }
                    break;
                default:
                    break;
            }
            break;
        case 0:
            tableIdentifier = [headers objectAtIndex:indexPath.section];
        default:
            break;
    }
    
	NSMutableArray *listData =[tableGroup objectAtIndex:indexPath.section];
    
	UITableViewCell * cell = [tableView
                              dequeueReusableCellWithIdentifier: tableIdentifier];
    
	if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:tableIdentifier];
        
        switch (indexPath.section) {
            case 1: {
                switch (indexPath.row) {
                    case 0: {
                        if(subjectTxtField == nil) {
                            subjectTxtField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
                            subjectTxtField.borderStyle = UITextBorderStyleRoundedRect;
                            subjectTxtField.text = currentWelvuSettings.shareVUSubject;
                            subjectTxtField.delegate = self;
                            subjectTxtField.tag = indexPath.section;
                        }
                        cell.accessoryView = subjectTxtField;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                        break;
                    case 1: {
                        if(signatureTextView == nil) {
                            signatureTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
                            signatureTextView.layer.cornerRadius = 5;
                            signatureTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                            signatureTextView.layer.borderWidth = 1;
                            signatureTextView.clipsToBounds = YES;
                            signatureTextView.font = [UIFont systemFontOfSize:17.0];
                            signatureTextView.text = currentWelvuSettings.shareVUSignature;
                            signatureTextView.delegate = self;
                            signatureTextView.tag = indexPath.section;
                        }
                        cell.accessoryView = signatureTextView;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case 2: {
                switch (indexPath.row) {
                    case 0: {
                        if(phiSubjectTxtField == nil) {
                            phiSubjectTxtField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
                            phiSubjectTxtField.borderStyle = UITextBorderStyleRoundedRect;
                            phiSubjectTxtField.text = currentWelvuSettings.phiShareVUSubject;
                            phiSubjectTxtField.delegate = self;
                            phiSubjectTxtField.tag = indexPath.section;
                        }
                        cell.accessoryView = phiSubjectTxtField;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                        break;
                    case 1: {
                        if(phiSignatureTextView == nil) {
                            phiSignatureTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
                            phiSignatureTextView.layer.cornerRadius = 5;
                            phiSignatureTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                            phiSignatureTextView.layer.borderWidth = 1;
                            phiSignatureTextView.clipsToBounds = YES;
                            phiSignatureTextView.font = [UIFont systemFontOfSize:17.0];
                            phiSignatureTextView.text = currentWelvuSettings.phiShareVUSignature;
                            phiSignatureTextView.delegate = self;
                            phiSignatureTextView.tag = indexPath.section;
                        }
                        cell.accessoryView = phiSignatureTextView;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
            case 0: {
                if(indexPath.row == currentWelvuSettings.securedSharing) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    // cell.backgroundColor=[UIColor whiteColor];
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                     //cell.backgroundColor=[UIColor whiteColor];
                }
            }
               //cell.backgroundColor = [UIColor whiteColor];
                break;
            default:
                break;
        }
	}
     cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
	cell.textLabel.text = [listData objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines=5;
    
    //cell.backgroundColor=[UIColor whiteColor];

	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     appDelegate.isSettingsChanged = TRUE;
    if(indexPath.section == 0) {
        currentWelvuSettings.securedSharing = indexPath.row;
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                    for(int i = 0; i < [[self.tableGroup objectAtIndex:indexPath.section] count];i++) {
            if(i != indexPath.row) {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                cell.accessoryType = UITableViewCellAccessoryNone;
                            }
                  cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        
        
        
                    }
       // cell.backgroundColor = [UIColor whiteColor];
     // [cell setBackgroundColor:  [UIColor whiteColor]];

       // cell.contentView.backgroundColor = [UIColor whiteColor];
//[cell.contentView setBackgroundColor:[UIColor greenColor]];
      //  NSLog(@"selected bg view");
   
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];

    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Email Settings - ES"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    

    
    headerLabel.text = NSLocalizedString(@"SETTINGS_EMAIL_HEADER", nil);
    emailSettingsTableView.layer.cornerRadius = 15;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSRange range = [[subjectTxtField text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    currentWelvuSettings.shareVUSubject= [[subjectTxtField text] stringByReplacingCharactersInRange:range withString:@""];
    
    range = [[signatureTextView text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    currentWelvuSettings.shareVUSignature= [[signatureTextView text] stringByReplacingCharactersInRange:range withString:@""];
    
    range = [[phiSubjectTxtField text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    currentWelvuSettings.phiShareVUSubject= [[phiSubjectTxtField text] stringByReplacingCharactersInRange:range withString:@""];
    
    range = [[phiSignatureTextView text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    currentWelvuSettings.phiShareVUSignature= [[phiSignatureTextView text] stringByReplacingCharactersInRange:range withString:@""];
    
    [subjectTxtField resignFirstResponder];
    [signatureTextView resignFirstResponder];
    [phiSubjectTxtField resignFirstResponder];
    [phiSignatureTextView resignFirstResponder];
}
-(void)textViewDidChange:(UITextView *)textView{

appDelegate.isSettingsChanged = TRUE;
}
- (BOOL) textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    
    appDelegate.isSettingsChanged = TRUE;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIInterfaceOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft
       || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }
	return NO;
}

- (BOOL)shouldAutorotate {
    return [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}
@end
