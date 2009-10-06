#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHUser.h"


@interface GHUsersParserDelegate : GHResourcesParserDelegate {
  @private
	GHUser *currentUser;
	// Unfortunately we need this boolean to distinguish the
	// attribute name in the plan from the name attribute that
	// defines the username - both are called 'name' :(
	BOOL isParsingPlan;
}

@end
