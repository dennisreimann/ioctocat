#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHIssue.h"


@interface GHIssuesParserDelegate : GHResourcesParserDelegate {
	GHRepository *repository;
  @private
    GHIssue *currentIssue;
}

@property(nonatomic,retain)GHRepository *repository;

@end
