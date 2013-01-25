//
//  NSDate+Nibware.m
//  Inspired by John Resig's pretty.js
//
//  Created by robertsanders on 1/19/09.
//  Copyright 2009 Robert Sanders. All rights reserved.
//

#import "NSDate+Nibware.h"


@implementation NSDate (Nibware)

- (NSString *)prettyDateWithReference:(NSDate *)reference {
	float diff = [reference timeIntervalSinceDate:self];
	float day_diff = floor(diff / 86400);
	int days   = (int)day_diff;
	int weeks  = (int)ceil(day_diff / 7);
	int months = (int)ceil(day_diff / 30);
	int years  = (int)ceil(day_diff / 365);
	if (day_diff <= 0) {
		if (diff < 60) return @"just now";
		if (diff < 120) return @"1 minute ago";
		if (diff < 3600) return [NSString stringWithFormat:@"%d minutes ago", (int)floor( diff / 60 )];
		if (diff < 7200) return @"1 hour ago";
		if (diff < 86400) return [NSString stringWithFormat:@"%d hours ago", (int)floor( diff / 3600 )];
	} else if (days < 7) {
		return [NSString stringWithFormat:@"%d day%@ ago", days, days == 1 ? @"" : @"s"];
	} else if (weeks < 4) {
		return [NSString stringWithFormat:@"%d week%@ ago", weeks, weeks == 1 ? @"" : @"s"];
	} else if (months < 12) {
		return [NSString stringWithFormat:@"%d month%@ ago", months, months == 1 ? @"" : @"s"];
	} else {
		return [NSString stringWithFormat:@"%d year%@ ago", years, years == 1 ? @"" : @"s"];
	}
	return [self description];
}

- (NSString *)prettyDate {
	return [self prettyDateWithReference:[NSDate date]];
}

@end