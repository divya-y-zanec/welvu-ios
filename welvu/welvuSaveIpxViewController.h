//
//  welvuSaveIpxViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 26/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxSDK/BoxSDK.h>
#import "welvuAppDelegate.h"
#import "welvu_message.h"

/*
 * Protocol name: welvuSaveIpxViewControllerDelegate
 * Description: Delegate function to share the iPx Video
 */

@protocol welvuSaveIpxViewControllerDelegate
-(void)welvuShareIPXVideoDidFinish:(BOOL)isModified;
-(void)welvuShareIpxVideoDidCancel;
@end

/*
 * Class name: welvuSaveIpxViewController
 * Description: to share the iPx Videos
 * Extends: UIViewController
 * Delegate :UITextFieldDelegate,UIAlerView Delegate
 */
@interface welvuSaveIpxViewController : UIViewController<UITextFieldDelegate ,UITextViewDelegate , BoxFolderPickerDelegate>  {
    //Defining the delegate for this controller
    id<welvuSaveIpxViewControllerDelegate> delegate;
    welvuAppDelegate *appDelegate;
    IBOutlet UITextField *recipientsTxt;
    IBOutlet UITextField *titleTxt;
    IBOutlet UITextView *descriptionTxtView;
    NSString *ipxidvideo;
    NSMutableArray *ipx_videoId;
    NSMutableArray *ipx_title;
    NSMutableArray *ipx_description;
    NSMutableArray *ipxvideo;
    welvu_message *welvu_messageModel;
    NSString *welvuPlatformHostUrl;
    NSString *welvuPlatformActionUrl;
    //Bg Task
    UIBackgroundTaskIdentifier bti;
    UIView *overlay;
    IBOutlet UIButton *boxButton ;
    NSString *boxVideoId;
    NSInteger boxMediaTab;
    NSString *boxTitle;
    NSString *boxDescription;
    
    //oauth
      NSURLConnection *shareipcVideo;
}
//Property
@property (nonatomic ,retain)  NSString *boxTitle;
@property (nonatomic,retain) NSString *boxDescription;
@property (nonatomic ,readwrite)   NSInteger boxMediaTab;
@property (nonatomic,copy) NSString *boxVideoId;
@property (nonatomic, readwrite, strong) BoxFolderPickerViewController *folderPicker;
@property (nonatomic ,retain)  NSString *ipxidvideo;
@property (nonatomic,retain)NSMutableArray *ipx_videoId;
@property (nonatomic,retain) NSMutableArray *ipx_title;
@property (nonatomic,retain)  NSMutableArray *ipx_description ;
@property (nonatomic,retain)    NSMutableArray *videoidipx;
//Assigining property for delegate methods
@property (nonatomic ,retain)  id<welvuSaveIpxViewControllerDelegate> delegate;
//Action Methods
-(IBAction)shareBtnClicked:(id)sender;
-(IBAction)cancelBtnClicked:(id)sender;
-(void)shareipxContent;
-(IBAction) boxBtnClicked:(id)sender;
- (NSMutableURLRequest *)POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                             attachmentData:(NSData *) attachment_data
                             attachmentType:(NSString *) attachment_type
                              attachmentExt:(NSString *) attachment_ext
                         attachmentFileName:(NSString *) attachment_fileName;
-(id) initWithShareVuContent:(welvu_message*) welvu_message_Model:(NSString *)platformHostUrl:(NSString *)platformActionUrl;
-(void) shareVUContents;
-(IBAction)informationBtnClicked:(id)sender;
@end
