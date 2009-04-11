#import <Foundation/Foundation.h>


@class GHUser;

@interface GHRepository : NSObject {
	GHUser *user;
	NSString *name;
	NSString *owner;
	NSString *descriptionText;
	NSURL *githubURL;
	NSURL *homepageURL;
	BOOL isPrivate;
	BOOL isFork;
	NSInteger forks;
	NSInteger watchers;
}

@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSURL *githubURL;
@property (nonatomic, retain) NSURL *homepageURL;
@property (nonatomic, readwrite) BOOL isPrivate;
@property (nonatomic, readwrite) BOOL isFork;
@property (nonatomic, readwrite) NSInteger forks;
@property (nonatomic, readwrite) NSInteger watchers;

@end
