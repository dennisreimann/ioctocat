#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser, GHGistComments;

@interface GHGist : GHResource

@property(nonatomic,retain)NSString *gistId;
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)GHGistComments *comments;
@property(nonatomic,retain)NSURL *htmlURL;
@property(nonatomic,retain)NSDate *createdAtDate;
@property(nonatomic,retain)NSString *descriptionText;
@property(nonatomic,retain)NSDictionary *files;
@property(nonatomic,readwrite)NSUInteger commentsCount;
@property(nonatomic,readwrite)NSUInteger forksCount;
@property(nonatomic,readwrite)BOOL isPrivate;
@property(nonatomic,readonly)NSString *title;

+ (id)gistWithId:(NSString *)theId;
- (id)initWithId:(NSString *)theId;

@end