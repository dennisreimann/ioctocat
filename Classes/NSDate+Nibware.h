//
//  NSDate+Nibware.h
//  pingle
//
//  Created by robertsanders on 1/19/09.
//  Copyright 2009 Robert Sanders. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (Nibware)

- (NSString*) prettyDate;

- (NSString*) prettyDateWithReference:(NSDate*)reference;

@end
