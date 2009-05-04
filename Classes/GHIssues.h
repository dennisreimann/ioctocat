#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHIssue.h"


@interface GHIssues : GHResource {
  @private
	NSURL *url;
	NSArray *entries;
    NSString *repo;
}

@property (nonatomic, retain) NSString *repo;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *entries;

- (void)loadIssues;
- (void)loadedIssues:(id)theResult;
- (id)initWithURL:(NSURL *)theURL andRepository:(NSString *)theRepoName;


@end
