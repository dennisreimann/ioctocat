//
//  NSDate+Nibware.m
//  Inspired by John Resig's pretty.js
//
//  Created by robertsanders on 1/19/09.
//  Copyright 2009 Robert Sanders. All rights reserved.
//

#import "NSDate+Nibware.h"


@implementation NSDate (Nibware)

- (NSString*) prettyDateWithReference:(NSDate*)reference
{
    float diff = [reference timeIntervalSinceDate:self];
    float day_diff = floor(diff / 86400);

    if (day_diff <= 0) {
        if (diff < 60) return @"just now";
        if (diff < 120) return @"1 minute ago";
        if (diff < 3600) return [NSString stringWithFormat:@"%d minutes ago", (int)floor( diff / 60 )];
        if (diff < 7200) return @"1 hour ago";
        if (diff < 86400) return [NSString stringWithFormat:@"%d hours ago", (int)floor( diff / 3600 )];
    } else if (day_diff == 1) {
        return [NSString stringWithFormat:@"%d day ago", (int)day_diff];
    } else if (day_diff < 7) {
        return [NSString stringWithFormat:@"%d days ago", (int)day_diff];
    } else if (day_diff < 31) {
        return [NSString stringWithFormat:@"%d weeks ago", (int)ceil( day_diff / 7 )];
    } else if (day_diff < 365) {
        return [NSString stringWithFormat:@"%d months ago", (int)ceil( day_diff / 30 )];
    } else {
        return [NSString stringWithFormat:@"%d years ago", (int)ceil( day_diff / 365 )];
    }

    return [self description];
}

- (NSString*) prettyDate
{
    return [self prettyDateWithReference:[NSDate date]];
}
    


@end
