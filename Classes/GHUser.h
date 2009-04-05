#import <Foundation/Foundation.h>


@interface GHUser : NSObject {
	NSString *name;
	NSString *login;
	NSString *email;
	NSString *company;
	NSString *blog;
	NSString *location;
	NSMutableArray *repositories;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *blog;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSMutableArray *repositories;

@end
