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
	[self.defaults setValue:@{@"lastUpdate:user/orgs": self.date} forKey:@"account:enterprise.com:userlogin"];
	[self.defaults synchronize];
	expect([IOCDefaultsPersistence lastUpdateForPath:@"user/orgs" account:self.account]).to.equal(self.date);
}

- (void)testSetLastUpateForPath {
	[IOCDefaultsPersistence setLastUpate:self.date forPath:@"user/repos" account:self.account];
    NSDictionary *accountDict = [self.defaults objectForKey:@"account:enterprise.com:userlogin"];
	NSDate *expected = [accountDict objectForKey:@"lastUpdate:user/repos"];
	expect(expected.description).to.equal(self.date.description);
}

- (void)testRemoveAccount {
	[IOCDefaultsPersistence setLastUpate:self.date forPath:@"user/orgs" account:self.account];
	expect([IOCDefaultsPersistence lastUpdateForPath:@"user/orgs" account:self.account]).notTo.beNil();
	[IOCDefaultsPersistence removeAccount:self.account];
	expect([IOCDefaultsPersistence lastUpdateForPath:@"user/orgs" account:self.account]).to.beNil();
}

@end