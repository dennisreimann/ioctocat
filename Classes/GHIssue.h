#import <Foundation/Foundation.h>
#import "GHResource.h"

@interface GHIssue : GHResource {
  NSString *issueId;
  NSString *user;    
  NSString *title;
  NSString *body;
  NSString *state;
  NSString *type;
  NSInteger *votes;    
  NSInteger *num;
  NSDate    *created;
  NSDate    *updated;    
    
}

@property (nonatomic, retain) NSString *issueId;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSDate *updated;

@property (nonatomic, readwrite) NSInteger *num;
@property (nonatomic, readwrite) NSInteger *votes;



@end
