#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHRepository;

@interface GHIssues : GHCollection
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *issueState;

- (id)initWithResourcePath:(NSString *)thePath;
- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState;
@end