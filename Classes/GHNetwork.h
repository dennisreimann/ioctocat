#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHRepository.h"

@interface GHNetwork : GHResource {
	GHRepository *repository;
    NSString *description;
    NSString *name;
    NSString *url;
    
    GHUser *user;
}

@property (nonatomic, retain) GHRepository *repository;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) GHUser *user;

@end
