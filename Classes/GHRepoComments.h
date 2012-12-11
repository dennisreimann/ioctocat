#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHRepository;

@interface GHRepoComments : GHCollection
@property(nonatomic,strong)NSString *commitID;
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID;
@end