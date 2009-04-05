#import <Foundation/Foundation.h>


@class GHUser, GHFeed;

@interface GHFeedEntry : NSObject {
	NSString *entryID;
	NSString *eventType;
	NSDate *date;
	NSURL *linkURL;
	NSString *title;
	NSString *content;
	GHUser *user;
	GHFeed *feed;
}

@property (nonatomic, retain) NSString *entryID;
@property (nonatomic, retain) NSString *eventType;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSURL *linkURL;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) GHFeed *feed;

@end
