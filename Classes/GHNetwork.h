#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHRepository.h"


@interface GHNetwork : GHResource {
	GHRepository *repository;
    NSString *owner;
    NSString *description;
    NSString *name;
    NSURL *networkURL;
}

@property (nonatomic, retain) GHRepository *repository;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSURL *networkURL;
@property (nonatomic, readonly) GHUser *user;

@end
