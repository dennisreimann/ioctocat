#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHUser.h"


@interface GHUsersParserDelegate : GHResourcesParserDelegate {
  @private
	GHUser *currentUser;
}

@end
