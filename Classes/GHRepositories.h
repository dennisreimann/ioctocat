#import <Foundation/Foundation.h>
#import "GHCollection.h"


@interface GHRepositories : GHCollection
- (void)sortByPushedAt;
@end