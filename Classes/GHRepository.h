#import <Foundation/Foundation.h>


@interface GHRepository : NSObject {
	NSString *name;
	NSString *owner;
	NSString *description;
	NSURL *url;
	NSString *homepage;
	BOOL isPrivate;
	BOOL isFork;
	NSInteger forks;
	NSInteger watchers;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *homepage;
@property (nonatomic, readwrite) BOOL isPrivate;
@property (nonatomic, readwrite) BOOL isFork;
@property (nonatomic, readwrite) NSInteger forks;
@property (nonatomic, readwrite) NSInteger watchers;

@end
