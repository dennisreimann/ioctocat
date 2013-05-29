#import "GHCollection.h"


@class GHRepository;

@interface GHRepoComments : GHCollection
- (id)initWithRepo:(GHRepository *)repo andCommitID:(NSString *)commitID;
@end