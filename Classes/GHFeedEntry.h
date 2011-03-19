#import <Foundation/Foundation.h>

@class GHUser;

@interface GHFeedEntry : NSObject {
	NSString *entryID;
	NSString *eventType;
	NSDate *date;
	NSURL *linkURL;
	NSString *title;
	NSString *content;
	NSString *authorName;
	id eventItem;
	BOOL read;
}

@property(nonatomic,retain)NSString *entryID;
@property(nonatomic,retain)NSString *eventType;
@property(nonatomic,retain)NSDate *date;
@property(nonatomic,retain)NSURL *linkURL;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *content;
@property(nonatomic,retain)NSString *authorName;
@property(nonatomic,retain)id eventItem;
@property(nonatomic,readonly)GHUser *user;
@property(nonatomic,readwrite)BOOL read;

@end
