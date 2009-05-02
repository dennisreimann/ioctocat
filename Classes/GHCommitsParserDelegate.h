#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHCommit.h"


@interface GHCommitsParserDelegate : GHResourcesParserDelegate {
  @private
	GHCommit *currentCommit;
}

@end
