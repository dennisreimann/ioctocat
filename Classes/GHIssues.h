#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHIssue.h"


@interface GHIssues : GHResource {
  @private
	NSURL *url;
	NSArray *entries;
    NSString *user;
    NSString *repo;    
    NSString *state;        
}

@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *repo;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *entries;

- (id)initWithOwner:(NSString *)theOwner andRepository:(NSString *)theRepository andState:(NSString *)theState;
- (void)loadIssues;
- (void)loadedIssues:(id)theResult;
- (void)reloadForState:(NSString *)theState;

@end
