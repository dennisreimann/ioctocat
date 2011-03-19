#import "OrganizationCell.h"
#import "GHOrganization.h"
#import "NSString+Extensions.h"


@implementation OrganizationCell

@synthesize organization;

- (void)dealloc {
	[organization removeObserver:self forKeyPath:kOrganizationGravatarKeyPath];
	[organization release], organization = nil;
    [loginLabel release], loginLabel = nil;
    [gravatarView release], gravatarView = nil;
    [super dealloc];
}

- (void)setOrganization:(GHOrganization *)theOrg {
	[theOrg retain];
	[organization release];
	organization = theOrg;
	loginLabel.text = (!organization.name || [organization.name isEmpty]) ? organization.login : organization.name;
	[organization addObserver:self forKeyPath:kOrganizationGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
    gravatarView.image = organization.gravatar;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kOrganizationGravatarKeyPath] && organization.gravatar) {
		gravatarView.image = organization.gravatar;
	}
}

@end
