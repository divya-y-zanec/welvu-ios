/*
 * Copyright 2010-12 Stephen Darlington, Wandle Software Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Auto-dismiss UIAlertViewAutoDismiss for iOS4+ when app goes into the background
// Cribbed from: http://stackoverflow.com/questions/3105974/dismissing-UIAlertViewAutoDismisss-when-entering-background-state

#import <UIKit/UIKit.h>

@interface WSLAlertViewAutoDismiss : UIAlertView<UIAlertViewDelegate>

@property (nonatomic,strong) void(^actionBlock)(NSInteger);
@property (nonatomic,strong) void(^cancelBlock)();

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
             action:(void(^)(NSInteger))action
       cancelAction:(void(^)(void))cancel
  cancelButtonTitle:(NSString *)cancelButtonTitle 
  otherButtonTitles:(NSString *)otherButtonTitles, ... ;

@end
