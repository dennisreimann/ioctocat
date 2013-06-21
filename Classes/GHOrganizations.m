#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHOrganizations

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
        NSString *login = [dict ioc_stringForKey:@"login"];
        GHOrganization *org = [iOctocat.sharedInstance organizationWithLogin:login];
        // check for the existence of the object, because it gets fetched
        // from the cache associated with the current account, which is
        // unset in case the user logged out before the resource got loaded.
        if (org) {
            [org setValues:dict];
            [self addObject:org];
        }
	}
}

@end