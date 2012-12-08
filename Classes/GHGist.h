#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser, GHGistComments;

@interface GHGist : GHResource

@property(nonatomic,strong)NSString *gistId;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)GHGistComments *comments;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)NSDate *createdAtDate;
@property(nonatomic,strong)NSString *descriptionText;
@property(nonatomic,strong)NSDictionary *files;
@property(nonatomic,readwrite)NSUInteger commentsCount;
@property(nonatomic,readwrite)NSUInteger forksCount;
@property(nonatomic,readwrite)BOOL isPrivate;
@property(weak, nonatomic,readonly)NSString *title;

- (id)initWithId:(NSString *)theId;

@end