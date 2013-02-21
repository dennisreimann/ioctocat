#import "IOCAppConstants.h"
#import "IOCDefaultsPersistenceTests.h"
#import "IOCDefaultsPersistence.h"
#import "GHAccount.h"


@interface IOCDefaultsPersistenceTests ()
@property(nonatomic,strong)NSDate *date;
@property(nonatomic,strong)NSUserDefaults *defaults;
@property(nonatomic,strong)GHAccount *account;
@end


@implementation IOCDefaultsPersistenceTests

- (void)setUp {
    [super setUp];
	self.date = [NSDate date];
	self.defaults = [NSUserDefaults standardUserDefaults];
	self.account = [[GHAccount alloc] initWithDict:@{kEndpointDefaultsKey: @"https://enterprise.com", kLoginDefaultsKey:@"userlogin"}];
}

- (void)testLastUpdateForPathWhenUnset {
	expect([IOCDefaultsPersistence lastUpdateForPath:@"user" account:self.account]).to.equal(nil);
}

- (void)testLastUpdateForPath {
	[self.defaults setValue:self.date forKey:@"lastReadingDate:enterprise.com:userlogin:user/orgs"];
	[self.defaults synchronize];
	expect([IOCDefaultsPersistence lastUpdateForPath:@"user/orgs" account:self.account]).to.equal(self.date);
}

- (void)testSetLastUpateForPath {
	[IOCDefaultsPersistence setLastUpate:self.date forPath:@"user/repos" account:self.account];
	NSDate *expected = [self.defaults objectForKey:@"lastReadingDate:enterprise.com:userlogin:user/orgs"];
	expect([expected description]).to.equal([self.date description]);
}

@end