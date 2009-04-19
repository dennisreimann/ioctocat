#import <Foundation/Foundation.h>


@class GHUser;

@interface GHRepository : NSObject {
	NSString *name;
	NSString *owner;
	NSString *descriptionText;
	NSURL *githubURL;
	NSURL *homepageURL;
	NSInteger forks;
	NSInteger watchers;
	BOOL isPrivate;
	BOOL isFork;
	BOOL isLoaded;
	BOOL isLoading;
  @private
	NSMutableString *currentElementValue;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSURL *githubURL;
@property (nonatomic, retain) NSURL *homepageURL;
@property (nonatomic, readwrite) NSInteger forks;
@property (nonatomic, readwrite) NSInteger watchers;
@property (nonatomic, readwrite) BOOL isPrivate;
@property (nonatomic, readwrite) BOOL isFork;
@property (nonatomic, readwrite) BOOL isLoaded;
@property (nonatomic, readwrite) BOOL isLoading;
@property (nonatomic, readonly) GHUser *user;

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName;
- (void)loadRepository;

@end
