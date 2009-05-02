#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHIssue.h"


@interface GHIssues : GHResource {
  @private
	NSURL *url;
	NSArray *entries;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *entries;

- (id)initWithURL:(NSURL *)theURL;
- (void)loadIssues;
- (void)loadedIssues:(id)theResult;

@end
