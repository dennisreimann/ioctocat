#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHRepository.h"


@interface GHNetwork : GHResource {
	GHRepository *repository;
    GHUser *user;
    NSString *description;
    NSString *name;
    NSString *url;
}

@property (nonatomic, retain) GHRepository *repository;
@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;

@end
