#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHIssue.h"


@interface GHIssuesParserDelegate : GHResourcesParserDelegate {

  NSString *repo;
  
  @private
    GHIssue *currentIssue;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) NSString *repo;


@end
