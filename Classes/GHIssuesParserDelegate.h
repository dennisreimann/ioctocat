#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHIssue.h"


@interface GHIssuesParserDelegate : GHResourcesParserDelegate {
  @private
    GHIssue *currentIssue;
}

@end
