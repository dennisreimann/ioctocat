#import "GHCommentTests.h"
#import "GHComment.h"


@interface GHCommentTests ()
@property(nonatomic,strong)GHComment *comment;
@end


@implementation GHCommentTests

- (void)setUp {
    [super setUp];
	self.comment = [[GHComment alloc] init];
}

- (void)testBodyWithoutEmailFooter {
    self.comment.body = @"Well it appears says the same thing here. But it makes no sense. Because the error with the adapter happens on the Rails app. Not on the helios app.\n\n--\nTal Shrestha\n\n\nOn Friday, May 31, 2013 at 1:27 AM, Michele wrote:\n\n> The DATABASE_URL will be used by helios to find the database to connect to. It should be set in the .env file in your root helios directory, which is hidden by default. Mine looks something like DATABASE_URL=postgres://localhost/myapp\n>\n> \\U2014\n> Reply to this email directly or view it on GitHub (https://github.com/helios-framework/helios/issues/63#issuecomment-18712530).\n>\n>\n>  ";
    expect(self.comment.bodyWithoutEmailFooter).to.equal(@"Well it appears says the same thing here. But it makes no sense. Because the error with the adapter happens on the Rails app. Not on the helios app.\n\n--\nTal Shrestha");
}

@end