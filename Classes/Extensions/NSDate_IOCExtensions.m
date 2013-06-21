#import "NSDate_IOCExtensions.h"


@implementation NSDate (IOCExtensions)

//  Created by robertsanders on 1/19/09.
//  Copyright 2009 Robert Sanders. All rights reserved.
- (NSString *)ioc_prettyDateWithReference:(NSDate *)reference {
    NSString *inTime = @"ago";
	float diff = [reference timeIntervalSinceDate:self];
    if (diff < 0) {
        diff = [self timeIntervalSinceDate:reference];
        inTime = @"from now";
    }
	float day_diff = floor(diff / 86400);
	int days   = (int)day_diff;
	int weeks  = (int)ceil(day_diff / 7);
	int months = (int)ceil(day_diff / 30);
	int years  = (int)ceil(day_diff / 365);
	if (day_diff <= 0) {
		if (diff < 60) return @"just now";
		if (diff < 120) return [NSString stringWithFormat:@"1 minute %@", inTime];
		if (diff < 3600) return [NSString stringWithFormat:@"%d minutes %@", (int)floor(diff / 60), inTime];
		if (diff < 7200) return [NSString stringWithFormat:@"1 hour %@", inTime];
		if (diff < 86400) return [NSString stringWithFormat:@"%d hours %@", (int)floor(diff / 3600), inTime];
	} else if (days < 7) {
		return [NSString stringWithFormat:@"%d day%@ %@", days, days == 1 ? @"" : @"s", inTime];
	} else if (weeks < 4) {
		return [NSString stringWithFormat:@"%d week%@ %@", weeks, weeks == 1 ? @"" : @"s", inTime];
	} else if (months < 12) {
		return [NSString stringWithFormat:@"%d month%@ %@", months, months == 1 ? @"" : @"s", inTime];
	} else {
		return [NSString stringWithFormat:@"%d year%@ %@", years, years == 1 ? @"" : @"s", inTime];
	}
	return self.description;
}

- (NSString *)ioc_prettyDate {
	return [self ioc_prettyDateWithReference:NSDate.date];
}

@end