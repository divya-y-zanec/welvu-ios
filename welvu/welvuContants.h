////
//  welvuContants.h
//  welvu
//
//  Created by Logesh Kumaraguru on 22/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#ifndef welvu_welvuContants_h
#define welvu_welvuContants_h

//Local document directory
#define DOCUMENT_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CACHE_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define TEMP_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSTemporaryDirectory, NSUserDomainMask, YES) objectAtIndex:0]

//DB Name
#define WELVU_SQLITE @"welvu.sqlite"

//ADD to localization
//Title
#define ARCHIVE @"Archive"

//Welvu main settings constants headers
#define SETTINGS_LOAD_TOPICVU_PATIENTVU_HEADER @"Patient VU Content Settings"
#define SETTINGS_SPECIALTYVU_ORDER_HEADER @"Specialty VU Sort"

//Welvu main settings constants text
#define SETTINGS_LOAD_TOPICVU_PATIENTVU_TEXT @"Copy Topic VU by Default"
#define SETTINGS_RETAIN_PATIENTVU_TEXT @"Empty Patient VU"
#define SETTINGS_ALBHABITICAL_ORDER_TEXT @"Alphabetical"
#define SETTINGS_MOST_POPULAR_ORDER_TEXT @"Most Used"

//welvu createVU vital settings header

#define SETTINGS_VITAL_WEALTH_HEADER @"Weight"
#define SETTINGS_VITAL_HEALTH_HEADER @"Height"
#define SETTINGS_VITAL_TEMPERATURE_HEADER @"Temperature"
#define SETTINGS_VITAL_BPDANDBPD_HEADER @"Bps & Bpd"
#define SETTINGS_VITAL_BMI_HEADER @"Bmi"


//Welvu create VU settings Header
#define SETTINGS_AV_HEADER @"Audio & Video"
#define SETTINGS_FPS_HEADER @"Output Video Smoothness"
#define SETTINGS_SHARE_VU_HEADER @"Default Email configuration"
#define SETTINGS_SHARE_VU_PHI_HEADER @"HIPAA-Compliant Email configuration"

//Welvu create VU settings text for vitals
#define SETTINGS_VITALS_WEIGHT_LBS @"Pounds (lbs)"
#define SETTINGS_VITALS_WEIGHT_KG @"Kilogram (kg)"
#define SETTINGS_VITALS_HEIGHT_CM @"Centimeter (cm)"
#define SETTINGS_VITALS_HEIGHT_INCHES @"Inches (in)"
#define SETTINGS_VITALS_TEMPERATURE_FAHRENHEIT @"Farenheit (F)"
#define SETTINGS_VITALS_TEMPERATURE_CELSIUS @"Celsius (C) "



//Welvu create VU settings text
#define SETTINGS_AV_TEXT @"Audio & Video"
#define SETTINGS_AUDIO_ONLY_TEXT @"Audio only"
#define SETTINGS_VIDEO_ONLY_TEXT @"Video only"
#define SETTINGS_FPS_10_TEXT @"10 fps"
#define SETTINGS_FPS_20_TEXT @"20 fps"
#define SETTINGS_FPS_30_TEXT @"30 fps"
#define SETTINGS_SHARE_VU_SUBJECT_TEXT @"Subject"
#define SETTINGS_SHARE_VU_SIGNATURE_TEXT @"Email Note-Signature "


//Welvu color for blank canvas settings
#define SETTINGS_BLANK_CANVAS_WHITE @"White"
#define SETTINGS_BLANK_CANVAS_BLACK @"Black"
#define SETTINGS_BLANK_CANVAS_GREEN @"Green"

//Ipx video type
#define LIBRARY_TYPE @"Library"
#define ORGANIZATION_TYPE @"Organization"
#define MYVIDEOS_TYPE @"MyVideos"


//Welvu Archive Menu Constants
#define CONTENTS_ARCHIVE @"Contents Archive"
#define TOPIC_ARCHIVE @"Topic Archive"
//ADD to localization

//Welvu Image Constants
#define ALBUM_IMAGE_PNG [[NSBundle mainBundle] pathForResource:@"AlbumVU" ofType:@"png"]
#define OVERLAY_IMAGE_PNG [[NSBundle mainBundle] pathForResource:@"Overlay" ofType:@"png"]
#define PLAIN_BG_IMAGE_PNG [[NSBundle mainBundle] pathForResource:@"PlainBackground" ofType:@"png"]
#define SEGMENT_LOW_IMAGE_PNG [[NSBundle mainBundle] pathForResource:@"Low" ofType:@"png"]
#define SEGMENT_MEDIUM_IMAGE_PNG [[NSBundle mainBundle] pathForResource:@"Medium" ofType:@"png"]
#define SEGMENT_HIGH_IMAGE_PNG [[NSBundle mainBundle] pathForResource:@"High" ofType:@"png"]
#define YOUTUBE_OVERLAY_IMAGE_PNG [[NSBundle mainBundle] pathForResource:@"YoutubeVUOverlay" ofType:@"png"]
#define SAVE_IPX_PNG [[NSBundle mainBundle] pathForResource:@"saveipx-popup" ofType:@"png"]

//welvu setting master constants
#define SETTINGS_TOPIC_SORT_OPTION 0
#define SETTINGS_LAYOUT_OPTION 1
#define SETTINGS_VIDEO_OPTION 2
#define SETTINGS_EMAIL_HEADER 3
#define SETTINGS_BLANK_CANVAS_COLOR_HEADER 4
#define SETTINGS_SPECIALTY_HEADER 5

#define SETTINGS_VITAL_STATISTICS_CHANGE 6
//#define SETTINGS_THEME_CHANGE 7
#define SETTINGS_ORG_CHANGE 7
#define SETTINGS_VIDEO_RESOLUTION_CHANGE 8


//welvu settings secured sharing
#define SETTINGS_SHARE_VU_DEFAULT 0
#define SETTINGS_SHARE_VU_SECURED 1

//welvu main settings constants
#define SETTINGS_LOAD_TOPICVU_PATIENTVU_OPTION 0
#define SETTINGS_RETAIN_PATIENTVU_OPTION 1
#define SETTINGS_ALBHABITICAL_ORDER 0
#define SETTINGS_MOST_POPULAR_ORDER 1
#define SETTINGS_MOST_DEFAULT_ORDER 2
#define SETTINGS_CONTENT_VU_GRID_BG_NONE 0
#define SETTINGS_CONTENT_VU_GRID_BG 1

//WELVU Blank board color
#define SETTING_BLANK_CANVAS_COLOR_WHITE 0
#define SETTING_BLANK_CANVAS_COLOR_BLACK 1
#define SETTING_BLANK_CANVAS_COLOR_GREEN 2


//Settings Range and Contants
#define SETTINGS_LAYOUT_SPACING_MINIMUM 10
#define SETTINGS_LAYOUT_SPACING_MAXIMUM 25

//welvu drawing tool option
#define DRAWING_TOOL_LINE 0
#define DRAWING_TOOL_ARROW 1
#define DRAWING_TOOL_SQUARE 2
#define DRAWING_TOOL_CIRCLE 3
#define DRAWING_TOOL_TEXTVIEW 4

//welvu inforamtion overlay option
#define INFORMATION_TOPIC_VU 1
#define INFORMATION_TOPIC_CONTENT_VU 2
#define INFORMATION_ARCHIVE_TOPIC 3
#define INFORMATION_ARCHIVE_CONTENT 4
#define INFORMATION_SETTINGS_VU 5
#define INFORMATION_SHARE_VU 6
#define INFORMATION_PLAY_VU 7
#define INFORMATION_EDIT_VU 8
#define INFORMATION_HISTORY_VU 9

//WelVU Create VU types
#define WELVU_AUDIO_VIDEO_VU 0
#define WELVU_VIDEO_VU 1
#define WELVU_AUDIO_VU 2
#define WELVU_RECORD_STATUS_STARTED 1
#define WELVU_RECORD_STATUS_STOPED 2
#define WELVU_RECORD_STATUS_COMPLETED 3

//WelVU ShareVU status
#define WELVU_SHARVU_UNDER_PROGRESS 0
#define WELVU_SHAREVU_COMPLETED 1
#define WELVU_SHAREVU_CANCELLED 2


//welvu alert settings contants
#define ALERT_LOAD_TOPICVU_TO_PATIENTVU_TITLE  @"ALERT_LOAD_TOPICVU_TO_PATIENTVU_TITLE"
#define ALERT_GESTURE_LIMITATION_TITLE @"ALERT_GESTURE_LIMITATION_TITLE"
#define ALERT_HELP_OVER_VU @"ALERT_HELP_OVER_VU"
#define ALERT_EDIT_ANNOTATE_SAVED_TITLE @"ALERT_EDIT_ANNOTATE_SAVED_TITLE"
#define ALERT_PHI_VIDEO_TITLE @"ALERT_PHI_VIDEO_TITLE"
#define ALERT_HIPAA_INFO_TITLE @"ALERT_HIPAA_INFO_TITLE"
#define ALERT_DEFAULT_MAIL_TITLE @"ALERT_DEFAULT_MAIL_TITLE"
#define ALERT_TOPIC_VU_TITLE @"ALERT_TOPIC_VU_TITLE"
#define ALERT_PUSHING_TO_IPX @"ALERT_HIPAA_INFO_TITLE"
#define ALERT_DELETING_MY_VIDEOS_FROM_IPX @"ALERT_DELETING_MY_VIDEOS_FROM_IPX"
#define ALERT_DELETING_SHARED_VIDEOS_FROM_IPX @"ALERT_DELETING_SHARED_VIDEOS_FROM_IPX"

#define ALERT_IPX_PULL_TO_REFRESH @"Pull To Refresh..."
#define ALERT_IPX_RELEASE_TO_REFRESH @"Release To Refresh..."
#define ALERT_IPX_LOADING @"Loading..."

//welvu date format constant
#define YEAR_MONTH_DATE_TIME_FORMAT @"yyyy-MM-dd-HH:mm:ss"
#define YEAR_MONTH_DATE_TIME_NAME_FORMAT @"yyyyMMdd"
#define YEAR_MONTH_DATE_TIME_FILENAME_FORMAT @"yyyyMMddHHmmss"
#define YEAR_MONTH_DATE_TIME_FORMAT_DB @"yyyy-MM-dd HH:mm:ss"
#define YEAR_MONTHFULL_DATE_TIME_FORAMAT @"yyyy MMM dd hh:mm:ss a"
#define SERVER_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define SERVER_DATE_COMPARE_FORMAT @"yyyy-MM-dd"
//#define SERVER_DATE_FORMAT @"yyyy-mm-dd hh:ii:ss"

#define MASTER_VIEW_WIDTH 293
#define TOPICVU_CELL_HEIGHT 60

//Dimension constant
#define THUMB_IMAGE_WIDTH 240
#define THUMB_IMAGE_HEIGHT 135
#define THUMB_BUTTON_WIDTH 248
#define THUMB_BUTTON_HEIGHT 143

#define THUMB_IMAGE_GRID_WIDTH 120
#define THUMB_IMAGE_GRID_HEIGHT 70
#define THUMB_BUTTON_GRID_WIDTH 112
#define THUMB_BUTTON_GRID_HEIGHT 63

#define THUMB_MINI_IMAGE_WIDTH 96
#define THUMB_MINI_IMAGE_HEIGHT 63

#define THUMB_HORIZONTAL_BUTTON_WIDTH 146
#define THUMB_HORIZONTAL_BUTTON_HEIGHT 85
#define THUMB_HORIZONTAL_IMAGE_WIDTH 144
#define THUMB_HORIZONTAL_IMAGE_HEIGHT 81

#define THUMB_IPX_BUTTON_WIDTH 140
#define THUMB_IPX_BUTTON_HEIGHT 80

#define THUMB_TICK_IMAGE_WIDTH 32
#define THUMB_TICK_IMAGE_HEIGHT 32
#define THUMB_TICK_IMAGE_TAG 2000

#define IMAGE_VIEW_WIDTH 704
#define IMAGE_VIEW_HEIGHT 396

#define IMAGE_ROUNDED_CORNER_RADIUS 5

#define POPUP_SCROLL_WIDTH 320
#define CANVAS_WIDTH 960
#define CANVAS_HEIGHT 540
#define HORIZONTAL_SCROLL_WIDTH 984
#define HORIZONTAL_SCROLL_HEIGHT 60
//ERROR Need to change to upper case
#define SectionHeaderHeight 50
#define SectionHeaderWidth  500
#define SHARE_VU_SCREEN_WIDTH 400
#define SHARE_VU_SCREEN_HEIGHT 600
#define THUMB_IMAGE_BORDER 4
#define THUMB_MINI_IMAGE_BORDER 4
#define ALBUM_POPOVER_WIDTH 320
#define ALBUM_POPOVER_HEIGHT 480

//notification lable dimentions
#define NOTIFICATION_DIMENTION_INITIAL CGRectMake(375, 50, 260, 0)
#define NOTIFICATION_DIMENTION CGRectMake(375, 50, 260, 60)
#define NOTIFICATION_DIMENTION_INITIAL_DETAILVU CGRectMake(350, 50, 260, 0)
#define NOTIFICATION_DIMENTION_DETAILVU CGRectMake(350, 50, 260, 45)
#define NOTIFICATION_DIMENTION_IPX_VIEW CGRectMake(600, 50, 260, 45)
#define NOTIFICATION_DIMENTION_INITIAL_IPX_VIEW CGRectMake(600, 50, 260, 0)

//Database constants

#define LOCAL_IMAGE_CONTENT_ID_START_RANGE 20000
#define LOCAL_TOPIC_CONTENT_ID_START_RANGE 1000000
#define LOCAL_TEMP_CONTENT_ID_START_RANGE 10000
#define TABLE_WELVU_OAUTH_USER @"welvu_oauth"
#define TABLE_WELVU_USER @"welvu_user"
#define TABLE_WELVU_SPECIALTY @"welvu_specialty"
#define TABLE_WELVU_TOPICS @"welvu_topics"
#define TABLE_WELVU_IMAGES @"welvu_images"
#define TABLE_WELVU_VIDEO_SETTINGS @"welvu_settings"
#define TABLE_WELVU_MAIN_SETTINGS @"welvu_main_settings"
#define TABLE_WELVU_ALERTS @"welvu_alerts"
#define TABLE_WELVU_VU_HISTORY @"welvu_history"
#define TABLE_WELVU_APP_VERSION @"welvu_app_version"
#define TABLE_WELVU_CONTENT_TAG @"welvu_content_tag"
#define TABLE_WELVU_SYNC @"welvu_sync"
#define TABLE_WELVU_VIDEO @"welvu_video"
#define TABLE_WELVU_SHAREVU @"welvu_sharevu"
#define TABLE_WELVU_ORGANIZATION @"welvu_organization"
#define TABLE_WELVU_IPX_IMG @"welvu_iPx_images"

//DEFAULT COLUMN
#define COLUMN_IS_SYNCED @"is_synced"
#define COLUMN_VERSION @"version"
#define COLUMN_CREATED_ON @"created_on"
#define COLUMN_LAST_UPDATED @"last_updated"
#define COLUMN_IS_LOCKED @"is_locked"

//welvu_configuration
#define COLUMN_CONFIG_ID @"configuration_id"
//#define COLUMN_CONFIG_ @"welvu_user_id"
//#define COLUMN_CONFIG @"org_id"
#define COLUMN_CONFIG_ADAPTER @"config_adapter"
#define COLUMN_CONFIG_KEY @"config_key"
#define COLUMN_CONFIG_VAlue @"config_value"

//Org
#define COLUMN_ORG_ID @"org_id"
#define COLUMN_ORG_NAME @"org_name"
#define COLUMN_ORG_LOGO @"org_logo"
#define COLUMN_ORG_LOGO_NAME @"org_logo_name"
#define COLUMN_ORG_PRODUCT_TYPE @"product_Type"
#define COLUMN_ORG_Status @"org_Status"
#define COLUMN_USER_ORG_Status @"user_org_status"
#define COLUMN_STATUS @"status"
#define TABLE_WELVU_CONFIGURATION @"welvu_configuration"

//Box
#define COLUMN_BOX_EXPIRES_IN @"box_expires_in"
#define COLUMN_BOX_ACCESS_TOKEN @"box_access_token"
#define COLUMN_BOX_REFRESH_ACCESS_TOKEN @"box_refresh_access_token"

//Box
//welvu_user column contants
#define COLUMN_USER_ID @"welvu_user_id"
#define COLUMN_FIRSTNAME @"firstname"
#define COLUMN_MIDDLENAME @"middlename"
#define COLUMN_LASTNAME @"lastname"
#define COLUMN_USERNAME @"username"
#define COLUMN_EMAIL @"email"
#define COLUMN_SPECIALTYID @"specialty"
#define COLUMN_ACCESS_TOKEN @"access_token"
#define COLUMN_ACCESS_TOKEN_OBTAINED_ON @"access_token_obtained_on"
#define COLUMN_CURRENT_LOGGED_USER @"current_logged_user"
#define COLUMN_USER_PRIMARY_KEY @"user_primary_id"
#define COLUMN_USER_ORG_ROLE @"user_Org_Role"

#define COLUMN_WEIGHT @"weight"
#define COLUMN_Height @"height"
#define COLUMN_TEMPERATURE @"temperature"
#define COLUMN_BPSANDBPD @"bpsandbpd"
#define COLUMN_BMI @"bmi"


//welvu_specialty column constants
#define COLUMN_SPECIALTY_ID @"welvu_specialty_id"
#define COLUMN_SPECIALTY_NAME @"welvu_specialty_name"
#define COLUMN_SPECIALTY_INFO @"welvu_specialty_info"
#define COLUMN_SPECIALTY_DEFAULT @"welvu_specialty_default"
#define COLUMN_SPECIALTY_SUBSCRIBED @"welvu_specialty_subscribed"
#define COLUMN_TOPICS_SYNCED @"topics_synced"
#define COLUMN_PRODUCT_IDENTIFIER @"product_identifier"
#define COLUMN_YEARLY_PRODUCT_IDENTIFIER @"yearly_product_identifier"
#define COLUMN_SUBSCRIPTION_START_DATE @"subscriptionStartDate"
#define COLUMN_SUBSCRIPTION_END_DATE @"subscriptionEndDate"
#define COLUMN_PLATFORM_SPECIALTY_ID @"welvu_platform_id"

//welvu_topics column constants
#define COLUMN_TOPIC_ID @"topic_id"
#define COLUMN_TOPIC_SPECIALTY_ID @"welvu_specialty_id"
#define COLUMN_TOPIC_NAME @"topic_name"
#define COLUMN_TOPIC_INFO @"topic_info"
#define COLUMN_TOPIC_IS_USER_CREATED @"topic_is_user_created"
#define COLUMN_TOPIC_ACTIVE @"topic_active"
#define COLUMN_TOPIC_HIT_COUNT @"topic_hit_count"
#define COLUMN_TOPIC_DEFAULTORDER @"topic_default_order"
#define COLUMN_TOPIC_GUID @"topics_guid"


//welvu_images column contants
#define COLUMN_IMAGE_ID @"images_id"
#define COLUMN_IMAGE_DISPLAY_NAME @"image_display_name"
#define COLUMN_ORDER_NUMBER @"order_number"
#define COLUMN_TYPE @"type"
#define COLUMN_URL @"url"
#define COLUMN_IMAGE_INFO @"image_info"
#define COLUMN_IMAGE_ACTIVE @"image_active"
#define COLUMN_IMAGE_THUMBNAIL @"image_thumbnail"
#define COLUMN_IMAGE_GUID @"image_guid"
#define COLUMN_PLATFORM_IMAGE_ID @"welvu_platform_id"

//welvu_settings column constants
#define COLUMN_SETTINGS_ID @"settings_id"
#define COLUMN_TOPIC_LIST_ORDER @"welvu_topic_list_order"
#define COLUMN_WELVU_CONTENT_VU_SPACING @"welvu_content_vu_spacing"
#define COLUMN_WELVU_CONTENT_VU_STYLE @"welvu_content_vu_style"
#define COLUMN_WELVU_CONTENT_VU_LAYOUT_GRID @"welvu_content_vu_layout_grid"
#define COLUMN_WELVU_CONTENT_VU_GRID_BG @"welvu_content_vu_grid_bg"
#define COLUMN_AUDIO_VIDEO @"audio_video"
#define COLUMN_FPS @"fps"
#define COLUMN_QUALITY @"quality"
#define COLUMN_SECURED_SHARING @"securedSharing"
#define COLUMN_SHAREVU_SUBJECT @"shareVUSubject"
#define COLUMN_SHAREVU_SIGNATURE @"shareVUSignature"
#define COLUMN_PHI_SHAREVU_SUBJECT @"phiShareVUSubject"
#define COLUMN_PHI_SHAREVU_SIGNATURE @"phiShareVUSignature"
#define COLUMN_DEFAULT_SPECIALTY_ID @"default_specialty_id"
#define COLUMN_IS_DEFAULT @"isDefault"
#define COLUMN_IS_ACTIVE @"isActive"
#define COLUMN_BLANK_CANVAS_COLOR @"welvu_blank_canvas_color"
#define COLUMN_SETTINGS_THEME_CHANGE @"welvu_themeChange"
#define COLUMN_SETTINGS_IS_Animation @"isAnimation"

//welvu_ipx column constants

#define COLUMN_IPXIMG_id @"iPx_images_id"
#define COLUMN_IPXSPECIALTY_ID @"ipx_Specilaty_id"
#define COLUMN_IPXIMG_DISPLAY_NAME @"ipx_image_display_name"
#define COLUMN_IPXIMG_ORDER_NUMBER @"order_number"
#define COLUMN_IPXIMG_TYPE @"ipx_img_type"
#define COLUMN_IPXIMG_URL @"platform_video_url"
#define COLUMN_IPXIMG_INFO @"ipx_image_info"
#define COLUMN_IPXIMG_ACTIVE @"ipx_image_active"
#define COLUMN_IPXIMG_THUMBNAIL @"ipx_image_thumbnail"
#define COLUMN_IPXIMG_VERSION @"version"
#define COLUMN_IPXIMG_CREATEDON @"created_on"
#define COLUMN_IPXIMG_LASTUPDATE @"last_updated"
#define COLUMN_IPXIMG_LOCKED @"is_locked"
#define COLUMN_IPXIMG_GUID @"image_guid"
#define COLUMN_IPXIMG_ORGID @"organization_id"
#define COLUMN_IPXIMG_PLATFROMID @"platform_image_id"


//ipad retina display size
#define RETINA_DISPLAY_HEIGHT 1920
#define RETINA_DISPLAY_XAXIS 0
#define RETINA_DISPLAY_YAXIS 0
#define RETINA_DISPLAY_WIDTH 1080

//welvu_main_settings column constants
#define COLUMN_WELVU_MAIN_SETTINGS_ID @"welvu_main_settings_id"
#define COLUMN_WELVU_LOADING_VU @"welvu_loading_vu"
#define COLUMN_WELVU_CONTENT_VU_HISTORY @"welvu_content_vu_history"
#define COLUMN_MAIN_SETTINGS_ISACTIVE @"welvu_main_settings_isActive"
#define COLUMN_MAIN_SETTINGS_ISDEFAULT @"welvu_main_settings_isDefault"

//welvu_alerts column contants
#define COLUMN_WELVU_ALERTS_ID @"welvu_alerts_id"
#define COLUMN_WELVU_ALERT_TEXT @"welvu_alert_text"
#define COLUMN_WELVU_ALERT_DONT_SHOW @"welvu_dont_show"

//welvu_vu_history
#define COLUMN_WELVU_VU_HISTORY @"welvu_history_id"
#define COLUMN_HISTORY_NUMBER   @"history_number"
#define COLUMN_CREATED_DATE @"createdDate"

//welvu_app_version
#define COLUMN_WELVU_APP_VERSION_ID @"welvu_app_version_id"
#define COLUMN_WELVU_APP_VERSION_TXT @"welvu_app_version"
#define COLUMN_WELVU_APP_VERSION_SEQUENCE @"welvu_app_version_sequence"
#define COLUMN_WELVU_APP_DB_CHANGES @"welvu_app_db_changes"
#define COLUMN_WELVU_APP_DB_UPDATED @"welvu_add_db_updated"
#define COLUMN_WELVU_APP_VERSION_ACTIVE @"welvu_app_version_active"
#define COLUMN_WELVU_APP_UPDATED_ON @"welvu_app_updated_on"
#define COLUMN_WELVU_APP_IDENTIFIER @"welvu_app_identifier"

//welvu_content_tag
#define COLUMN_WELVU_CONTENT_TAG_ID @"welvu_content_tag_id";
#define COLUMN_WELVU_TAG_NAMES @"welvu_tag_names";

//welvu_sync
#define COLUMN_WELVU_SYNC_ID @"sync_id"
#define COLUMN_SYNC_GUID @"guid"
#define COLUMN_SYNC_OBJECT_ID @"object_id"
#define COLUMN_SYNC_TYPE @"sync_type"
#define COLUMN_ACTION_TYPE @"action_type"
#define COLUMN_SYNC_COMPLETED @"sync_completed"

//welvu_video
#define COLUMN_WELVU_VIDEO_ID @"welvu_video_id"
#define COLUMN_GENERIC_FILE_NAME @"generic_file_name"
#define COLUMN_VIDEO_FILE_NAME @"video_file_name"
#define COLUMNE_AUDIO_FILE_NAME @"audio_file_name"
#define COLUMN_AV_FILE_NAME @"av_file_name"
#define COLUMN_WELVU_VIDEO_TYPE @"welvu_video_type"
#define COLUMN_RECORDING_STATUS @"recording_status"
#define COLUMN_CREATED_DATE @"created_date"


//welvu_sharevu
#define COLUMN_WELVU_SHAREVU_ID @"welvu_sharevu_id"
#define COLUMN_SHARE_VU_SUBJECT @"sharevu_subject"
#define COLUMN_SHAREVU_RECIPIENTS @"sharevu_recipients"
#define COLUMN_SHAREVU_MSG @"sharevu_msg"
#define COLUMN_SHAREVU_SERVICE @"sharevu_service"
#define COLUMN_SIGNATURE @"signature"
#define COLUMN_SHAREVU_STATUS @"sharevu_status"

//Column constants
#define COLUMN_CONSTANT_TRUE @"True"
#define COLUMN_CONSTANT_FALSE @"False"
#define COLUMN_CONSTANT_NUL @"NUL"


//EMR legend
//EMR Graphs
#define GRAPH_SERIES_WEIGHTS 111
#define GRAPH_SERIES_HEIGHTS 112
#define GRAPH_SERIES_TEMPARATURE 113
#define GRAPH_SERIES_BPS 114
#define GRAPH_SERIES_BPd 115
#define GRAPH_SERIES_BMI 116
#define GRAPH_DATA_NOTIFICATION @"graphNot"
#define WEIGHT_GRAPH_SELECTED @"Weight"
#define HEIGHT_GRAPH_SELECTED @"Height"
#define TEMPERATURE_GRAPH_SELECTED @"Temperature"
#define HEIGHT_GRAPH_SELECTED @"heightsSelected"

//Image types
#define IMAGE_ALBUM_TYPE @"album"
#define IMAGE_ASSET_TYPE @"image"
#define IMAGE_BLANK_TYPE @"blank"
#define IMAGE_HISTORY_TYPE @"history"
#define IMAGE_VIDEO_TYPE @"video"
#define IMAGE_VIDEO_ALBUM_TYPE @"video_album"
#define IMAGE_PATIENT_TYPE @"patient_image"
#define VIDEO_PATIENT_TYPE @"patient_video"
#define IMAGE_PATIENTINFO_TYPE @"patientinfo_image"
#define GRAPH_IMAGE_TYPE @"patient_graph_info"

//Orientation for fade effect
typedef enum _fade_orientation {
    FADE_TOPNBOTTOM = 0,
    FADE_LEFTNRIGHT
} fade_orientation;

//Free Subscription Allowed sharing count
#define FREE_SHARE_MAX_ALLOWED 10

#define HTTP_PATIENT_ID @"patientid"

//Live Environment
//#define PLATFORM_HOST_URL @"https://portal.welvu.com/api/v2"
//#define PLATFORM_HOST_URL @"http://sites.welvu.com/api/public"
//#define PLATFORM_HOST_URL1 @"http://sites.welvu.com/api/public/v1/contents"
//#define PLATFORM_HOST_URL2 @"http://sites.welvu.com/api/public/v1/provider"
//#define PLATFORM_HOST_URL3 @"http://sites.welvu.com/api/public/v1/patient"

#define PLATFORM_HOST_URL @"https://portal.welvu.com/api/public"
#define PLATFORM_HOST_URL1 @"https://portal.welvu.com/api/public/v1/contents"
#define PLATFORM_HOST_URL2 @"https://portal.welvu.com/api/public/v1/provider"
#define PLATFORM_HOST_URL3 @"https://portal.welvu.com/api/public/v1/patient"

// #define PLATFORM_HOST_URL @"https://staging.welvu.com/api/public"
// #define PLATFORM_HOST_URL1 @"https://staging.welvu.com/api/public/v1/contents"
// #define PLATFORM_HOST_URL2 @"https://staging.welvu.com/api/public/v1/provider"
// #define PLATFORM_HOST_URL3 @"https://staging.welvu.com/api/public/v1/patient"

/*
#define PLATFORM_HOST_URL @"http://192.168.1.158/welvu/api/public"
#define PLATFORM_HOST_URL1 @"http://192.168.1.158/welvu/api/public/v1/contents"
#define PLATFORM_HOST_URL2 @"http://192.168.1.158/welvu/api/public/v1/provider"
#define PLATFORM_HOST_URL3 @"http://192.168.1.158/welvu/api/public/v1/patient"
*/

//Staging Environment
//Domain IP "http://166.78.61.206/welvuplatform/api"
//#define PLATFORM_HOST_URL @"http://sites.welvu.com/welvuplatform/api/v2"

//Local Dev Environment
//#define PLATFORM_HOST_URL @"http://192.168.1.134/welvu/api"

//Ping Host URL
#define PING_HOST_URL @"www.welvu.com"

//Multi app configurations
//emr login -registrationf

//#define PLATFORM_SEND_MESSAGE_ACTION_OPENEMR_URL @"/addpatientvideo"
//#define PLATFORM_GET_APPOINTMENTS_URL (PLATFORM_HOST_URL @"/getappointments?")
//#define PLATFORM_GET_PATIENT_DOCUMENT_ACTION_URL @"/getpatientdocuments"
//Comment this two only for WelVU
//#define PLATFORM_SEND_AUTHENTICATION_ACTION_URL @"/oemrlogin"
//#define HTTP_RESPONSE_ACCESSTOKEN_KEY @"oemrtoken"

//oauth
//#define PLATFORM_GET_OAUTH_TOPIC_URL (PLATFORM_HOST_URL1 @"/gettopics?")
#define PLATFORM_GET_OAUTH_TOPIC_URL (PLATFORM_HOST_URL1 @"/gettopicstream?")

#define PLATFORM_GET_OAUTH_GET_ORG_URL (PLATFORM_HOST_URL1 @"/getorganizations?")
#define PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL (PLATFORM_HOST_URL1 @"/getorganizationipx?")
#define PLATFORM_GET_OAUTH_LIBRARY_IPX_URL (PLATFORM_HOST_URL1 @"/getipxlibrary?")
#define PLATFORM_GET_OAUTH_LIBRARY_TOPIC_IPX_URL (PLATFORM_HOST_URL1 @"/getipxlibrarytopics?")

#define PLATFORM_GET_OAUTH_LIBRARY_PATIENTS_URL (PLATFORM_HOST_URL3 @"/getpatients?")
#define PLATFORM_GET_OAUTH_LIBRARY_PATIENT_DETAILS_URL (PLATFORM_HOST_URL3 @"/getpatient?")

#define PLATFORM_GET_NOTIFICATION_DATA_URL (PLATFORM_HOST_URL1 @"/getnotificationdata?")

#define PLATFORM_READ_NOTIFICATION_DATA_URL (PLATFORM_HOST_URL1 @"/readnotification?")


//EMR

//INTERSYSTEM
#define PLATFORM_GET_APPOINTMENTS_URL (PLATFORM_HOST_URL @"/getpatients?")
#define PLATFORM_GET_PATIENT_DOCUMENT_ACTION_URL @"/getpatient"
#define PLATFORM_SEND_MESSAGE_ACTION_OPENEMR_URL @"/putpatientvideo"
//Comment this two only for WelVU
#define PLATFORM_SEND_AUTHENTICATION_ACTION_URL @"/authenticateuser"
#define HTTP_RESPONSE_ACCESSTOKEN_KEY @"accesstoken"
//INTERSYSTEM
//

//Welvu
//#define HTTP_RESPONSE_ACCESSTOKEN_KEY @"accesstoken"
//#define PLATFORM_SEND_AUTHENTICATION_ACTION_URL @"/authenticateuser"
#define PLATFORM_CHECK_USER_LICENSE @"/checkUserLicense"

//Box

#define PLATFORM_GET_BOX_SPECIALTY_ACTION_URL @"/getBoxSpecialties"
#define PLATFORM_GET_BOX_TOPICS_ACTION_URL @"/getBoxTopics"
#define PLATFORM_BOX_AUTHENTICATION @"/boxAuthentication"
#define PLATFORM_BOX_ADD_IPX @"/addBoxiPx"
#define PLATFORM_GET_BOX_IPX @"/getBoxiPx"
#define PLATFORM_SHARE_BOX_IPX @"/shareBoxiPx"
#define PLATFORM_SHARE_BOX_VIDEO @"/shareBoxVideo"
#define HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY @"boxaccesstoken"
#define HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY @"boxrefreshtoken"
#define HTTP_RESPONSE_BOX_EXPIRES_IN @"expires_in"
//box Latest
#define PLATFORM_GET_BOX_IPX_LIBRARY @"/getBoxiPxLibrary"
#define PLATFORM_ADD_BOX_INFORMATION_PRESCRIPTION @"/addBoxiPxLibrary"
#define PLATFORM_SHARE_BOX_LIBRARY @"/shareBoxiPxLibrary"
//Dev Box details
//#define BOX_CLIENT_ID @"w0otsypregrxkc01zje4ybprw1ul0atb"
//#define BOX_SECRET_ID @"RksQo4PPj3ajRUzcwNtlrbvllFu69W9b"


//Dev Enterprise box details
#define BOX_CLIENT_ID @"5wntc0toabdcvhcs9tsjawdit0jxuu8g"
#define BOX_SECRET_ID @"5y4SavepJIf1n92s9oIi82Nc5foOh2UT"

#define BOX_USER_CONTENT_ROOT_ID @"1740094837"
//Box
//Share via portal details
#define PORTAL_HOST_URL @"https://rest.sendinc.com"
#define PORTAL_SEND_MESSAGE_ACTION_URL @"/message.xml"

#define PLATFORM_SEND_CONFIRMATION_EMAIL @"/sendconfirmationemail"
#define PLATFORM_SEND_MESSAGE_ACTION_URL @"/uploadvideo"
//#define PLATFORM_SEND_REGISTRATION_ACTION_URL @"/adduser"//
#define PLATFORM_SEND_REGISTRATION_ACTION_URL @"/add"
#define PLATFORM_SEND_SYNC_ORDER_ACTION_URL @"/syncorder"
#define PLATFORM_GET_SPECIALTY_OPTIONS_URL @"/getspecialtyoptions"
#define PLATFORM_GET_SPECIALTY_ACTION_URL @"/getspecialties"
#define PLATFORM_CHECK_USER_CONFIRMATION @"/checkuserconfirmation"
#define PLATFORM_GET_TOPICS_ACTION_URL @"/gettopics"
#define PLATFORM_GET_TOPICS_RECEIVED_ACTION_URL @"/receivedtopics"
#define PLATFORM_SPECIALTY_SUBSCRIBED @"/subscribespecialty"
#define PLATFORM_SYNC_JUSTLOG @"/justlog"
#define PLATFORM_SYNC_CONTENTS @"/syncmedia"
#define PLATFORM_SYNC_TOPICS @"/synctopic"
#define PLATFORM_GET_ORGANIZATION_DETAIL_ACTION_URL @"/getorganizations"




//IPX
//ipx
#define PLATFORM_ADD_INFORMATION_PRESCRIPTION @"/addipx"
#define PLATFORM_GET_INFORMATION_PRESCRIPTION @"/getipx"
#define HTTP_RESPONSE_IPX_GUID_KEY @"ipx_guid"
#define PLATFORM_GET_ORGANIZATION_INFORMATION_PRESCRIPTION @"/getOrganizationIPX"
#define PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION @"/addOrganizationIPX"

#define PLATFORM_GET_MY_VIDEOS_DELETE @"/deleteIPX"
#define PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE @"/deleteOrganizationIPX"
#define HTTP_RESPONSE_IPX_ID_KEY @"ipx_id"
#define HTTP_RESPONSE_IPX_OFFSET_KEY @"offset"
#define ALERT_IPX_LASTVIDEO_ID  @"lastid"

//IPX

//BOX
#define IMAGE_FILE_TYPE_CONST @"public.image"
#define VIDEO_FILE_TYPE_CONST @"public.movie"

//Forgot Password
#define URL_FORGOT_PASSWORD @"https://portal.welvu.com/care-provider-login?view=reset"
//#define URL_FORGOT_PASSWORD @"http://sites.welvu.com/welvuplatform/care-provider-login?view=reset"

//Update URL with sync device id
#define PLATFORM_SYNC_DEVICE_ID @"/udidtoguid"
//Update URL with os version
#define PLATFORM_SYNC_OS_VERSION @"/versionupdated"

//bundle identifer
//#define BUNDLE_IDENTIFER_WELVU @"com.welvu.welvudev"
#define BUNDLE_IDENTIFER_BOX @"com.welvu.welvubox"
#define BUNDLE_IDENTIFER_HEV @"com.welvu.welvuhev"
#define BUNDLE_IDENTIFER_INTERSYSTEM @"com.welvu.InterSystem"
#define BUNDLE_IDENTIFER_WELVU @"com.welvu.welvu"
#define BUNDLE_IDENTIFER_CARDIOVU @"com.welvu.cardiovu"
#define BUNDLE_IDENTIFER_ORTHOVU @"com.welvu.orthovu"
#define BUNDLE_IDENTIFER_OPENEMR @"com.welvu.openemr"
#define BUNDLE_IDENTIFER_EBOLAVU @"com.welvu.ebolavu"

#define PLATFORM_GET_UPDATE_NOTIFICATIONS @"/getnotificationdata"
#define PLATFORM_READ_NOTIFICATIONS_ACTION_URL @"/readnotification"
#define MAIL_ID @"donotreply@welvu.com"
#define MAIL_PASSWORD @"w3lvu@pp"
#define HTTP_SSL_BASIC @"Basic"
#define HTTP_SSL_HEADER_KEY @"Authorization"
#define HTTP_REQUEST_MULTIPART_TYPE @"multipart/form-data"
#define HTTP_REQUEST_FORM_TYPE @"application/x-www-form-urlencoded"

//Request Parameter
#define HTTP_PARAMETER_NULL @"<null>"
#define HTTP_REQUEST_APP_IDENTIFIER_KEY @"app_identifier"
#define HTTP_REQUEST_CONTENT_TYPE_KEY @"Content-Type"
#define HTTP_REQUEST_CONTENT_LENGTH_KEY @"Content-Length"
#define HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY @"video/mp4"
#define HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_MOV_KEY @"video/quicktime"
#define HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY @"image/jpeg"
#define HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_PNG_KEY @"image/png"
#define HTTP_ATTACHMENT_IMAGE_EXT_KEY @"jpg"
#define HTTP_ATTACHMENT_VIDEO_EXT_KEY @"mp4"
#define HTTP_ATTACHMENT_VIDEO_EXT_MOV_KEY @"mov"
#define HTTP_SERVICE_KEY @"services"
#define HTTP_TITLE_KEY @"title"
#define HTTP_DESCRIPTION_KEY @"description"
#define HTTP_PRIVATE_VIDEO_KEY @"private"
#define HTTP_PUBLIC_VIDEO_KEY @"public"
#define HTTP_ISPRIVATE_KEY @"isprivate"
#define HTTP_TAGS_KEY @"tags"
#define HTTP_ZIP_URL_KEY @"zipurl"
#define HTTP_FILE_SIZE_KEY @"filesize"
#define HTTP_FILE_TYPE_KEY @"type"
#define HTTP_DETAILS_KEY @"details"
#define HTTP_REQUEST_LOCKED @"locked"
#define HTTP_REQUEST_SUBSCRIPTION_TYPE @"subscriptiontype"
#define HTTP_REQUEST_DEVICE_ID @"device_id"
#define HTTP_REQUEST_DEVICE_INFO @"device_info"
#define HTTP_REQUEST_PLATFORM_VERSION @"platform_version"
#define HTTP_REQUEST_OLD_PLATFORM_VERSION @"old_platform_version"
#define PLATFORM_SEND_WELVU_VERSION_ACTION_URL @"/welvu_version"
#define HTTP_WELVU_VERSION_NUMBER @"welvuversion"

//Common response type
#define HTTP_RESPONSE_CHECK_USER_CONFIRMATION_KEY @"/checkuserconfirmation"
#define HTTP_RESPONSE_SEND_USER_CONFIRMATION_KEY @"/sendconfirmationemail"
#define HTTP_RESPONSE_STATUS_KEY @"status"
#define HTTP_RESPONSE_MSG_KEY @"msg"

//#define HTTP_RESPONSE_OEMRTOKEN_KEY @"oemrtoken"
#define HTTP_RESPONSE_SUCCESS_KEY @"Success"
#define HTTP_RESPONSE_FAILED_KEY @"Failed"
#define HTTP_RESPONSE_IS_CONFIRMED @"is_confirmed"
#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_GET @"GET"

//Org
#define HTTP_REQUEST_ORGANISATION_KEY @"organization_id"

//WELVU_SYNC_REQUEST
#define SYNC_TYPE_PLATFORM_ID_CONSTANT 0
#define SYNC_TYPE_TOPIC_CONSTANT 1
#define SYNC_TYPE_CONTENT_CONSTANT 2
#define SYNC_TYPE_OS_CHANGES_CONSTANT 3
#define SYNC_TYPE_TOPIC_CHANGES_CONSTANT 4
#define SYNC_TYPE_IPX_CHANGES_CONSTANT 5

#define ACTION_TYPE_CREATE_CONSTANT 1
#define ACTION_TYPE_UPDATE_CONSTANT 2
#define ACTION_TYPE_DELETE_CONSTANT 3

#define SYNC_TYPE_IMAGE_DELETE_CONSTANT 2
#define SYNC_TYPE_TOPIC_DELETE_CONSTANT 1


//oauth
#define PLATFORM_SEND_AUTHENTICATION_ACTION_URL @"/oauth"
#define PLATFORM_WELVU_CLIENT_ID @"client_id"
#define WELVU_CLIENT_ID @"welvuios"
#define PLATFORM_WELVU_GRANT_TYPE @"grant_type"
#define HTTP_RESPONSE_CURRENTDATE_KEY @"current_date"
#define COLUMN_EXPIRES_IN @"expires_in"
#define COLUMN_REFRESH_TOKEN @"refresh_token"
#define COLUMN_SCOPE @"scope"
#define COLUMN_TOKEN_TYPE @"token_type"
#define HTTP_RESPONSE_ACCESSTOKEN_KEY @"access_token"
#define PLATFORM_GET_ORGANIZE_ACTION_URL @"/authorize"



#define HTTP_REQUEST_ACTION_TYPE_CREATE @"create"
#define HTTP_REQUEST_ACTION_TYPE_UPDATE @"update"
#define HTTP_REQUEST_ACTION_TYPE_DELETE @"delete"
#define HTTP_REQUEST_ACTION_TYPE_KEY @"actiontype"
#define HTTP_REQUEST_CONTENT_ID @"media_id"
#define HTTP_REQUEST_ID @"id"
#define HTTP_REQUEST_CONTENT_GUID @"media_guid"
#define HTTP_REQUEST_TOPIC_GUID @"topic_guid"
#define HTTP_REQUEST_OS_GUID @"os_guid"
#define HTTP_REQUEST_DEVICE_GUID @"device_guid"
#define HTTP_REQUEST_TOPIC_ID @"topicid"
#define HTTP_REQUEST_NOTIFICATION_ID @"notification_id"
#define HTTP_RESPONSE_MEDIA_SYNC_DATA @"media_sync_data"
#define HTTP_RESPONSE_TOPIC_SYNC_DATA @"topic_sync_data"
#define HTTP_RESPONSE_ORDER_SYNC_DATA @"order_sync_data"
#define HTTP_RESPONSE_MEDIA_URL @"mediaurl"
#define HTTP_REQUEST_ORDER_KEY @"order_data"
#define HTTP_REQUEST_ORDER_NUMBER_KEY @"order_number"
#define HTTP_REQUEST_MEDIA_ORDER_DETAILS_KEY @"media_order_details"

#define HTTP_BOUNDARY @"0xKhTmLbOuNdArY"
#define HTTP_BOUNDARY_KEY @"boundary"

#define HTTP_CONTENT_DISPOSITION @"Content-Disposition: form-data; name="

//Server Response Contants
//welvu_user
#define HTTP_REQUEST_NAME @"name"
#define HTTP_REQUEST_USER_NAME @"username"
#define HTTP_EMAILID_KEY @"email"
#define HTTP_PASSWORD_KEY @"password"
#define HTTP_RECIPIENTS_KEY @"recipients"
#define HTTP_SUBJECT_KEY @"subject"
#define HTTP_MESSAGE_KEY @"message"
#define HTTP_SPECIALTY_KEY @"specialty"
#define HTTP_ORGANIZATION_KEY @"organization_name"
#define HTTP_PHONENUMBER_KEY @"phonenumber"

//welvu_specialty
#define HTTP_RESPONSE_ID @"id"
#define HTTP_SPECIALTY_ID @"specialtyid"
#define HTTP_RESPONSE_ISDEFAULT @"isdefault"
#define HTTP_RESPONSE_NAME @"name"
#define HTTP_RESPONSE_SUBSCRIBE @"subscribe"
#define HTTP_RESPONSE_PRODUCT_IDENTIFIER @"product_identifier"
#define HTTP_RESPONSE_YEARLY_PRODUCT_IDENTIFIER @"yearly_product_identifier"
#define HTTP_REQUEST_SUBSCRIPTION_START_DATE @"valid_from"
#define HTTP_REQUEST_SUBSCRIPTION_END_DATE @"valid_till"
#define HTTP_REQUEST_TRANSACTION_RECEIPT @"transaction_recipt"


//welvu_topics
#define HTTP_RESPONSE_TITLE @"title"
#define HTTP_RESPONSE_INFO @"info"
#define HTTP_RESPONSE_ACTIVE @"active"
#define HTTP_RESPONSE_ORDER @"order"
#define HTTP_RESPONSE_MEDIAS @"medias"

//welvu_images
#define HTTP_RESPONSE_URL @"url"
#define HTTP_RESPONSE_MEDIA_TYPE @"media_type"
#define HTTP_RESPONSE_MEDIA_ORDER @"media_order"
#define HTTP_RESPONSE_MIME_TYPE @"mimetype"

//Sharing Service Constant
#define CONSTANT_SERVICE_SENDINC @"sendinc"
#define CONSTANT_SERVICE_BRIGHTCOVE @"brightcove"
#define CONSTANT_SERVICE_YOUTUBE @"youtube"
#define CONSTANT_SERVICE_EMR @"openEMR"
#define CONSTANT_SERVICE_YOUTUBE_PRIVATE 1
#define CONSTANT_SERVICE_YOUTUBE_PUBLIC 0
//EMR
#define ALERT_PUSHING_TO_EMR @"ALERT_PUSHING_TO_EMR"

//Local Notification Contants
#define NOTIFY_SETTINGS_UPDATED @"SETTINGS_UPDATED"
#define NOTIFY_BLANK_IMAGE_ANNOTATED @"BLANK_ANNOTATED"
#define NOTIFY_CLEARALL_PATIENTVU @"NOTIFY_CLEARALL_PATIENTVU"
#define NOTIFY_REMOVED_FROM_PATIENTVU @"NOTIFY_REMOVED_FROM_PATIENTVU"
#define NOTIFY_TAP_FROM_DETAILVU @"NOTIFY_TAP_FROM_DETAILVU"
#define NOTIFY_LAST_SELECTED_IMAGE_ID @"NOTIFY_LAST_SELECTED_IMAGE_ID"
#define NOTIFY_EXPORT_COMPLETED @"NOTIFY_EXPORT_COMPLETED"
#define NOTIFY_RELOAD_TABLE_DATA @"NOTIFY_RELOAD_TABLE_DATA"
#define NOTIFY_IMAGE_SELECTED @"NOTIFY_IMAGE_SELECTED"
#define NOTIFY_IMAGE_REMOVED @"NOTIFY_IMAGE_REMOVED"
#define NOTIFY_IMAGE_SELECTEDALL @"NOTIFY_IMAGE_SELECTEDALL"
#define NOTIFY_REMOVE_SELECTED_IMAGE @"NOTIFY_REMOVE_SELECTED_IMAGE"
#define NOTIFY_HIDE_PATIENT_INFO_BUTTON @"NOTIFY_HIDE_PATIENT_INFO_BUTTON"
#define NOTIFY_MAIL_SENT @"MailSent"
//Colors
#define BASE_COLOR ([UIColor colorWithRed:0.32f green:0.71f blue:0.95f alpha:1.0f])
#define SELECTED_COLOR ([UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f])

//Google Analytics welvu
#define GOOGLE_ANALYTICS_WELVU_KEY @"UA-38315598-1"
//Google Analytics cardioVU
//#define GOOGLE_ANALYTICS_WELVU_KEY @"UA-38315598-3"
////Google Analytics orthoVU
//#define GOOGLE_ANALYTICS_WELVU_KEY @"UA-38315598-2"

//Google Analytics Beta
//#define GOOGLE_ANALYTICS_WELVU_KEY @"UA-37189969-3"
//Google Analytics Dev
//#define GOOGLE_ANALYTICS_WELVU_KEY @"UA-39130701-1"

//APP Title
//WelVU
//#define APP_TITLE @"WelVU"
//CardioVU
//#define APP_TITLE @"CardioVU"
//OrthoVU
//#define APP_TITLE @"OrthoVU"

//IRate
//WelVU
#define APPLE_APP_ID 606710534
//CardioVU
//#define APPLE_APP_ID 606712216
//OrthoVU
//#define APPLE_APP_ID 606712760

////BUY InAPP Purchase
//#define HYPERLINK_INAPP_PURCHASE @"https://buy.itunes.apple.com/verifyReceipt"
#define HYPERLINK_INAPP_PURCHASE @"https://sandbox.itunes.apple.com/verifyReceipt"
#define SHARED_SECRET @"7819c8ebaf554366ba29c24ac6ac5460"
#define URL_FEEDBACK_FORM @"https://docs.google.com/spreadsheet/viewform?formkey=dDFXNzA4NTM4NXZrdXBsNUU4MVA2UGc6MQ"
#define OS_VERSION_LIMITATION @"6.0"

//portal
//#define URL_UPGRADE @"http://sites.welvu.com/app-welvu/"
#define URL_UPGRADE @"http://solutions.welvu.com/"

//Map integration
#define iOS_VERSION [[UIDevice currentDevice].systemVersion integerValue]
#define COLOR_FOR_MAP_TITLE ((iOS_VERSION >= 7) ? [UIColor darkGrayColor]:[UIColor whiteColor])
#define LOCATION_LABEL_Y_POS ((iOS_VERSION >= 7) ? 283:263)

#endif
