#import "GHResource.h"


@class GHRepository, GHCommit, GHTree;

@interface GHTag : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,readonly)GHTree *tree;
@property(nonatomic,strong)NSString *sha;
@property(nonatomic,strong)NSString *tag;
@property(nonatomic,strong)NSString *message;
@property(nonatomic,strong)NSString *taggerName;
@property(nonatomic,strong)NSString *taggerEmail;
@property(nonatomic,strong)NSDate *taggerDate;
@property(nonatomic,strong)NSURL *htmlURL;

- (id)initWithRepo:(GHRepository *)repo sha:(NSString *)sha;
@end