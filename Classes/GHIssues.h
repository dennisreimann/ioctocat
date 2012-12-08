#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHIssues : GHResource

@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSArray *entries;
@property(nonatomic,strong)NSString *issueState;

- (id)initWithResourcePath:(NSString *)thePath;
- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState;

@end