#import "OrganizationCell.h"
#import "GHOrganization.h"
#import "NSString+Extensions.h"


@implementation OrganizationCell

- (void)dealloc {
	[self.organization removeObserver:self forKeyPath:kGravatarKeyPath];
}

- (void)setOrganization:(GHOrganization *)theOrg {
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