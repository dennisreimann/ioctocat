#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHRepository.h"
#import "GHIssue.h"


@interface GHIssues : GHResource {
	NSArray *entries;
  @private
    GHRepository *repository;
	NSString *issueState;
}

@property (nonatomic, retain) GHRepository *repository;
@property (nonatomic, retain) NSArray *entries;
@property (nonatomic, retain) NSString *issueState;
@property (nonatomic, readonly) NSURL *issuesURL;

- (void)loadIssues;
- (void)loadedIssues:(id)theResult;
- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState;

@end
