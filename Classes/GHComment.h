#import "GHResource.h"


@class GHUser;

@interface GHComment : GHResource
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,assign)NSUInteger commentID;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSString *bodyWithoutEmailFooter;
@property(nonatomic,strong)NSDate *createdAt;
@property(nonatomic,strong)NSDate *updatedAt;
@property(nonatomic,readonly)BOOL isNew;

- (void)saveWithParams:(NSDictionary *)values start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end
