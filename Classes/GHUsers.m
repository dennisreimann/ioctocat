#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@implementation GHUsers

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
        NSString *login = [dict safeStringForKey:@"login"];
        GHUser *user = [iOctocat.sharedInstance userWithLogin:login];
        // check for the existence of the object, because it gets fetched
        // from the cache associated with the current account, which is
        // unset in case the user logged out before the resource got loaded.
        if (user) {
            [user setValues:dict];
            [self addObject:user];
        }
	}
}

@end