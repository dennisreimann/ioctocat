#import "OrganizationCell.h"
#import "GHOrganization.h"
#import "NSString+Extensions.h"


@implementation OrganizationCell

- (void)dealloc {
	[self.organization removeObserver:self forKeyPath:kGravatarKeyPath];
	[_organization release], _organization = nil;
	[_gravatarView release], _gravatarView = nil;
	[_loginLabel release], _loginLabel = nil;
	[super dealloc];
}

- (void)setOrganization:(GHOrganization *)theOrg {
	[theOrg retain];
	[_organization release];
	_organization = theOrg;
	self.loginLabel.text = (!self.organization.name || [self.organization.name isEmpty]) ? self.organization.login : self.organization.name;
	[self.organization addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.gravatarView.image = self.organization.gravatar;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && self.organization.gravatar) {
		self.gravatarView.image = self.organization.gravatar;
	}
}

@end