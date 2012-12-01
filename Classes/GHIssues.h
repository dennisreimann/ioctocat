#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHIssues : GHResource

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSArray *entries;
@property(nonatomic,retain)NSString *issueState;

+ (id)issuesWithResourcePath:(NSString *)thePath;
+ (id)issuesWithRepository:(GHRepository *)theRepository andState:(NSString *)theState;
- (id)initWithResourcePath:(NSString *)thePath;
- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState;

@end