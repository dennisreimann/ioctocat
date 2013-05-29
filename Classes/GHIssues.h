#import "GHCollection.h"


@class GHRepository;

@interface GHIssues : GHCollection
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *issueState;

- (id)initWithResourcePath:(NSString *)path;
- (id)initWithRepository:(GHRepository *)repo andState:(NSString *)state;
@end