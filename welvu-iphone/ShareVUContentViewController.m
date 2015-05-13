//
//  ShareVUContentViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "ShareVUContentViewController.h"
#import "welvuiPhoneContants.h"
#import "welvu_message.h"
@interface ShareVUContentViewController()
-(void) completedSharingVUContent:(BOOL)success:(NSDictionary *)responseDictionary:(NSError *)error;
-(BOOL) validateRecipients: (NSString *) recipients;
-(BOOL) validateSubject: (NSString *) subject;
- (BOOL) validateEmail: (NSString *) candidate;
@end

@implementation ShareVUContentViewController
@synthesize delegate, welvu_messageModel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Detail", @"Detail");
        
      
    }
    return self;
}


-(id)initWithAttachmentDetails:(NSString *) subject:(NSString *)signature
                              :(NSString *) videoFile_Name:(NSString *)videoFile_Location {
    self = [super initWithNibName:@"ShareVUContentViewController" bundle:nil];
    if (self) {
        welvu_messageModel = [[welvu_message alloc] initWithMessageId:1];
        if(subject != nil)
            welvu_messageModel.subject = subject;
        if(signature != nil)
            welvu_messageModel.signature = signature;
        welvu_messageModel.videoFileName = videoFile_Name;
        welvu_messageModel.videoFileLocation = videoFile_Location;
    }
    return self;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [recipientsTxt resignFirstResponder];
    [subjectTxt resignFirstResponder];
}
-(void)shareContentVUBtnClicked {
    
    BOOL validateRecipientsFlag = [self validateRecipients:recipientsTxt.text];
    BOOL validateSubjectFlag = [self validateSubject:subjectTxt.text];
    
    if(validateRecipientsFlag && validateSubjectFlag) {
        [self.delegate shareVUContentViewControllerStartedSharing];
        welvu_messageModel.recipients = recipientsTxt.text;
        welvu_messageModel.subject = subjectTxt.text;
        welvu_messageModel.message = messagetTxtView.text;
        
        ShareVUContentHelper *shareVUContentHelper = [[[ShareVUContentHelper alloc]
                                                       initWithShareVuContent:welvu_messageModel] autorelease];
        shareVUContentHelper.delegate = self;
        [shareVUContentHelper shareVUContents];
        [welvu_messageModel release];
    } else {
        NSString *errorReport = @"";
        errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_PLEASE_ENTER_MSG", nil)];
        if(!validateRecipientsFlag) {
            errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_ERROR_RECIPIENTS_MSG", nil)];
        }
        
        if(!validateSubjectFlag) {
            if(!validateRecipientsFlag) {
                errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_AND_MSG", nil)];
            }
            errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_ERROR_SUBJECT_MSG", nil)];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE", nil)
                              message: errorReport
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
    
}

-(IBAction)cancelSharingVUBtnClickeds:(id)sender {
    [self.delegate shareVUContentViewControllerDidCancel];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) completedSharingVUContent:(BOOL)success:(NSDictionary *)responseDictionary :(NSError *)error {
    [self.delegate shareVUContentViewControllerDidFinish];
    [self.navigationController popViewControllerAnimated:YES];
}


//ShareVu Content Helper class delegate methods
-(void)shareVUContentMailSendResponse:(BOOL)success {
    [self completedSharingVUContent:YES:nil:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)shareVUContentMailDidReceivedData:(BOOL)success:(NSDictionary *)responseDictionary {
    [self completedSharingVUContent:NO:responseDictionary:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)shareVUContentFailedWithError:(NSError *)error {
    [self completedSharingVUContent:NO:nil:error];
    [self.navigationController popViewControllerAnimated:YES];
}


-(BOOL) validateRecipients: (NSString *) recipients {
    BOOL recipientValid = false;
    NSArray* recipientsArray = [recipients componentsSeparatedByString: @","];
    for(NSString *recipient in recipientsArray) {
        recipient = [recipient stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(![self validateEmail:recipient]) {
            recipientValid = false;
            return recipientValid;
        } else {
            recipientValid = true;
        }
    }
    return recipientValid;
}

-(BOOL)validateSubject:(NSString *)subject {
    BOOL subjectValid = false;
    subject = [subject stringByTrimmingCharactersInSet:
               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([subject length] > 0) {
        subjectValid = true;
    }
    return subjectValid;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"share.png"];
    UIBarButtonItem *button2;
    
    //[button2 setWidth:55];
    button2= [[UIBarButtonItem alloc] initWithImage:image style:UIBarStyleDefault target:self action:@selector(shareContentVUBtnClicked)];
    
    self.navigationItem.rightBarButtonItem = button2;
    
    [button2 release];
    // Do any additional setup after loading the view from its nib.
    subjectTxt.text = welvu_messageModel.subject;
    NSString *message = @"";
    if(welvu_messageModel.signature != nil) {
        message = [message stringByAppendingFormat:welvu_messageModel.signature];
    }
    message = [message stringByAppendingFormat:NSLocalizedString(@"SHARE_MAIL_CONFIDENTIAL_MSG_BODY", nil)];
    messagetTxtView.text = message;
    attachmentLabel.text = [NSString stringWithFormat:@"%@.%@",welvu_messageModel.videoFileName,
                            HTTP_ATTACHMENT_VIDEO_EXT_KEY];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortrait &&
            interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)dealloc {
    delegate = nil;
    [super dealloc];
    [welvu_messageModel release];
}

@end
