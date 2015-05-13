//
//  welvuYouViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTubeUploader.h"
#import "welvu_message.h"
@class welvuYouViewController;
/*
 * Protocol name: welvuYouViewControllerDelegate
 * Description: Delegate function for you tube view controller
 */
@protocol welvuYouViewControllerDelegate
-(void)canceledYoutubeSharing;
@end

/*
 * Class name: welvuYouViewController
 * Description: Has functionality share you tube videos
 * Extends: UIViewController
 * Delegate :UITextFieldDelegate,UITextViewDelegate, UIPickerViewDelegate*/

@interface welvuYouViewController : UIViewController <welvuYouViewControllerDelegate,UITextFieldDelegate,UITextViewDelegate,YouTubeUploaderDelegate, UIPickerViewDelegate>{
    IBOutlet UIProgressView *uploadProgressView;
    //Defining the delegate for this controller
    id<welvuYouViewControllerDelegate> delegate;
    //declare for text field
    IBOutlet UITextField *tagName;
    IBOutlet UITextView *Description;
    IBOutlet UITextField *youName;
    welvu_message *welvu_messageModel;
    NSString *youTubeName;
    NSString *youTubeDescription;
    NSString *youTubeTagName;
    NSString *youYubeVideo;
    BOOL exportCompleted;
    NSString *youTubeFileLocation;
    IBOutlet UIButton *shareAnimation;
    IBOutlet UIButton *cancelAnimation;
    NSMutableArray *categoryTitle;
    UIPickerView *youtubePickerView;
    IBOutlet UILabel *category;
    NSString *youTubeCategory;
    NSString *youTubeSwitvhValue;
    NSString *firstName;
    UIView *overlay;
    IBOutlet UILabel *preparingToUploadLabel;
    NSString *togglePrivate;
    //ANIMATION
    IBOutlet UIImageView *imageToMove;
    IBOutlet UIView *myView;
}
@property (nonatomic,retain) NSString *youTubeCategory;
@property (nonatomic,retain)NSString *youTubeSwitvhValue;
@property (nonatomic,copy)  NSString *togglePrivate;
//Assigning the property for the delegate object
@property (nonatomic,retain) id<welvuYouViewControllerDelegate> delegate;
@property (nonatomic,retain)   NSString *youYubeVideo;
@property (nonatomic, retain) YouTubeUploader *youTubeUploader;
//action methods
- (IBAction)upload:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)cancelSharingVUBtnClickeds:(id)sender;
- (IBAction)guide:(id)sender;
- (id)initWithAttachmentDetails:(NSString *) subject:(NSString *)signature
                               :(NSString *) videoFile_Name:(NSString *)videoFile_Location:(BOOL) isExportCompleted;

-(IBAction)userSetOnOff:(id)sender;
-(IBAction)categoryselect:(id)sender;
-(IBAction)informationBtnClicked:(id)sender;
-(IBAction)closeOverlay:(id)sender;
@end
