# AFOAuth2Client

AFOAuth2Client is an extension for [AFNetworking](http://github.com/AFNetworking/AFNetworking/) that greatly simplifies the process of authenticating against an [OAuth 2](http://oauth.net/2/) provider.

This is still in early stages of development, so proceed with caution when using this in a production application. Any bug reports, feature requests, or general feedback at this point would be greatly appreciated.

## Example Usage

``` objective-c
NSURL *url = [NSURL URLWithString:@"http://example.com/"];
AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];

[oauthClient authenticateUsingOAuthWithPath:@"/oauth/token"
                                   username:@"username"
                                   password:@"password"
                                    success:^(AFOAuthCredential *credential) {
                                        NSLog(@"I have a token! %@", credential.accessToken);
                                        [AFOAuthCredential storeCredential:credential withIdentifier:oauthClient.serviceProviderIdentifier];
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Error: %@", error);
                                    }];
```

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

AFOAuth2Client is available under the MIT license. See the LICENSE file for more info.
