#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHRepository, GHUser;

@interface GHRepoComment : GHComment

@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *commitID;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,assign)NSUInteger position;
@property(nonatomic,assign)NSUInteger line;

+ (id)commentWithRepo:(GHRepository *)theRepo andDictionary:(NSDictionary *)theDict;
+ (id)commentWithRepo:(GHRepository *)theRepo;
- (id)initWithRepo:(GHRepository *)theRepo andDictionary:(NSDictionary *)theDict;
- (id)initWithRepo:(GHRepository *)theRepo;

@end