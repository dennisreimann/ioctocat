/*
 * Author: Andreas Linde <mail@andreaslinde.de>
 *
 * Copyright (c) 2012-2013 HockeyApp, Bit Stadium GmbH.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


#import <UIKit/UIKit.h>

#import "BITFeedbackComposeViewControllerDelegate.h"

/**
 View controller allowing the user to write and send new feedback
 */

@interface BITFeedbackComposeViewController : UIViewController <UITextViewDelegate>


///-----------------------------------------------------------------------------
/// @name Delegate
///-----------------------------------------------------------------------------


/**
 Sets the `BITUpdateManagerDelegate` delegate.
 
 When using `BITUpdateManager` to distribute updates of your beta or enterprise
 application, it is _REQUIRED_ to set this delegate and implement
 `[BITUpdateManagerDelegate customDeviceIdentifierForUpdateManager:]`!
 */
@property (nonatomic, weak) id<BITFeedbackComposeViewControllerDelegate> delegate;


///-----------------------------------------------------------------------------
/// @name Presetting content
///-----------------------------------------------------------------------------


/**
 An array of data objects that should be used to prefill the compose view content
 
 The follwoing data object classes are currently supported:
 - NSString
 - NSURL
 
 These are automatically concatenated to one text string.
 
 @param items Array of data objects to prefill the feedback text message.
 */
- (void)prepareWithItems:(NSArray *)items;

@end
