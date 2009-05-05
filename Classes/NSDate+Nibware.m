//
//  NSDate+Nibware.m
//  Inspired by John Resig's pretty.js
//
//  Created by robertsanders on 1/19/09.
//  Copyright 2009 Robert Sanders. All rights reserved.
//

#import "NSDate+Nibware.h"


@implementation NSDate (Nibware)
/*
 function prettyDate(time){
 var date = new Date((time || "").replace(/-/g,"/").replace(/[TZ]/g," ")),
 diff = (((new Date()).getTime() - date.getTime()) / 1000),
 day_diff = Math.floor(diff / 86400);
 
 if ( isNaN(day_diff) || day_diff < 0 || day_diff >= 31 )
 return;
 
 return day_diff == 0 && (
 diff < 60 && "just now" ||
 diff < 120 && "1 minute ago" ||
 diff < 3600 && Math.floor( diff / 60 ) + " minutes ago" ||
 diff < 7200 && "1 hour ago" ||
 diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
 day_diff == 1 && "Yesterday" ||
 day_diff < 7 && day_diff + " days ago" ||
 day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
 }
 
 */

- (NSString*) prettyDateWithReference:(NSDate*)reference
{
    float diff = [reference timeIntervalSinceDate:self];
    float day_diff = floor(diff / 86400);
    NSLog(@"PrettyDate: %f seconds diff, day_diff=%f", diff, day_diff);

    if (day_diff == 0) {
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
