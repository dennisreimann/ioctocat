#import "GHResource.h"


@class GHUser, GHRepository;

@interface GHComment : GHResource
@property(nonatomic,weak)GHRepository *repository;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,assign)NSUInteger commentID;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSString *bodyWithoutEmailFooter;
@property(nonatomic,strong)NSMutableAttributedString *attributedBody;
@property(nonatomic,strong)NSDate *createdAt;
@property(nonatomic,strong)NSDate *updatedAt;
@property(nonatomic,readonly)BOOL isNew;
@end
