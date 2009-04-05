#import <Foundation/Foundation.h>


@class GHRepository;

@interface GHUser : NSObject {
	NSString *name;
	NSString *login;
	NSString *email;
	NSString *company;
	NSString *location;
	NSURL *blogURL;
	NSMutableArray *repositories;
	BOOL isLoaded;
	BOOL isLoading;
  @private
	NSMutableString *currentElementValue;
	GHRepository *currentRepository;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSURL *blogURL;
@property (nonatomic, retain) NSMutableArray *repositories;
@property (nonatomic, readwrite) BOOL isLoaded;
@property (nonatomic, readwrite) BOOL isLoading;

- (id)initWithLogin:(NSString *)theLogin;
- (void)loadDetails;

@end
