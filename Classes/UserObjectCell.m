#import "UserObjectCell.h"
#import "GHUser.h"


@interface UserObjectCell ()
@property(nonatomic,readonly)GHUser *object;
@property(nonatomic,weak)IBOutlet UILabel *loginLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@end


@implementation UserObjectCell

- (void)dealloc {
	[self.userObject removeObserver:self forKeyPath:kGravatarKeyPath];
}

- (void)setUserObject:(id)theUserObject {
	[self.userObject removeObserver:self forKeyPath:kGravatarKeyPath];
	_userObject = theUserObject;
	self.loginLabel.text = self.object.login;
	self.gravatarView.image = self.object.gravatar;
	[self.userObject addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && self.object.gravatar) {
		self.gravatarView.image = self.object.gravatar;
	}
}

- (GHUser *)object {
	return _userObject;
}

@end