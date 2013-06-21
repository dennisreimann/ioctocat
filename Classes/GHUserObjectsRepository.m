#import "GHUserObjectsRepository.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "IOCAvatarCache.h"
#import "NSString_IOCExtensions.h"


@interface GHUserObjectsRepository ()
@property(nonatomic,strong)NSMutableDictionary *users;
@property(nonatomic,strong)NSMutableDictionary *organizations;
@end


@implementation GHUserObjectsRepository

static NSString *const GravatarKeyPath = kGravatarKeyPath;

- (instancetype)init {
	self = [super init];
	if (self) {
		self.users = [NSMutableDictionary dictionary];
        self.organizations = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)dealloc {
	for (GHOrganization *org in self.organizations.allValues) {
		[org removeObserver:self forKeyPath:GravatarKeyPath];
	}
	self.organizations = nil;
	for (GHUser *user in self.users.allValues) {
		[user removeObserver:self forKeyPath:GravatarKeyPath];
	}
	self.users = nil;
}

- (GHUser *)userWithLogin:(NSString *)login {
	if (!login || [login ioc_isEmpty]) return nil;
	GHUser *user = self.users[login];
	if (user == nil) {
		user = [[GHUser alloc] initWithLogin:login];
		[user addObserver:self forKeyPath:GravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		self.users[login] = user;
	}
	return user;
}

- (GHOrganization *)organizationWithLogin:(NSString *)login {
	if (!login || [login ioc_isEmpty]) return nil;
	GHOrganization *organization = self.organizations[login];
	if (organization == nil) {
		organization = [[GHOrganization alloc] initWithLogin:login];
		[organization addObserver:self forKeyPath:GravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		self.organizations[login] = organization;
	}
	return organization;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:GravatarKeyPath]) {
		// might be a GHUser or GHOrganization instance, both respond to gravatar, so this is okay
		GHUser *user = (GHUser *)object;
		if (user.gravatar) [IOCAvatarCache cacheGravatar:user.gravatar forIdentifier:user.login];
	}
}

@end