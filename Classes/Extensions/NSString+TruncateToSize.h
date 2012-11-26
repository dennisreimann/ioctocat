//
//  NSString-truncateToSize
//  Fast Fonts
//
//  Created by Stuart Shelton on 28/03/2010.
//  Copyright 2010 Stuart Shelton.
//
//  NSString truncate function for Objective C / iPhone SDK by
//  Stuart Shelton is licensed under a Creative Commons Attribution 3.0
//  Unported License (CC BY 3.0)
//
//  http://creativecommons.org/licenses/by/3.0/
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (truncateToSize)

- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode;
- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode withAnchor: (NSString *)anchor;
- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode withStartingAnchor: (NSString *)startingAnchor withEndingAnchor: (NSString *)endingAnchor;

@end
