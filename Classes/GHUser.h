#import <Foundation/Foundation.h>


@class Gravatar;

@interface GHUser : NSObject {
	NSString *name;
	NSString *login;
	NSString *email;
	NSString *company;
	NSString *location;
	NSURL *blogURL;
	Gravatar *gravatar;
	NSArray *repositories;
	BOOL isLoaded;
	BOOL isLoading;
	BOOL isReposLoaded;
	BOOL isReposLoading;
  @private
	NSMutableString *currentElementValue;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSURL *blogURL;
@property (nonatomic, retain) Gravatar *gravatar;
@property (nonatomic, retain) NSArray *repositories;
@property (nonatomic, readwrite) BOOL isLoaded;
@property (nonatomic, readwrite) BOOL isLoading;
@property (nonatomic, readwrite) BOOL isReposLoaded;
@property (nonatomic, readwrite) BOOL isReposLoading;

- (id)initWithLogin:(NSString *)theLogin;
- (void)loadUser;
- (void)loadRepositories;

@end
