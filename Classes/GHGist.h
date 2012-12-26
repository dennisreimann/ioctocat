#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser, GHGistComments, GHFiles;

@interface GHGist : GHResource
@property(nonatomic,strong)NSString *gistId;
@property(nonatomic,strong)NSString *userLogin;
@property(nonatomic,strong)GHGistComments *comments;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)NSDate *createdAtDate;
@property(nonatomic,strong)NSString *descriptionText;
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,readonly)GHUser *user;
@property(nonatomic,readonly)NSString *title;
@property(nonatomic,readwrite)NSUInteger commentsCount;
@property(nonatomic,readwrite)NSUInteger forksCount;
@property(nonatomic,readwrite)BOOL isPrivate;

- (id)initWithId:(NSString *)gistId;
@end