Orbiter
=======
**Push Notification Registration for iOS**

For most iOS client / server applications, push notifications are negotiated through an intermediary service provider, such as [Urban Airship](http://urbanairship.com). The service provider exposes APIs to register a device token, as well as APIs to send push notifications to devices meeting some specified criteria.

Orbiter is a small library that provides simple interfaces to register (and unregister) for Push Notifications with [Urban Airship](http://urbanairship.com), [Parse](https://parse.com), and domains running [Rack::PushNotification](https://github.com/mattt/rack-push-notification).

> Orbiter is named for the [orbital space craft of the Space Shuttle program](http://en.wikipedia.org/wiki/Space_Shuttle_orbiter), which houses the flight crew and electronics used to communicate with mission control.

> This project is part of a series of open source libraries covering the mission-critical aspects of an iOS app's infrastructure. Be sure to check out its sister projects: [GroundControl](https://github.com/mattt/GroundControl), [SkyLab](https://github.com/mattt/SkyLab), [CargoBay](https://github.com/mattt/CargoBay), and [houston](https://github.com/mattt/houston).

## Example Usage

### Urban Airship Registration

```objective-c
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[UrbanAirshipOrbiter urbanAirshipManagerWithApplicationKey:@"..." applicationSecret:@"..."] registerDeviceToken:deviceToken withAlias:nil success:^(id responseObject) {
        NSLog(@"Registration Success: %@", responseObject);
    } failure:^(NSError *error) {
        NSLog(@"Registration Error: %@", error);
    }];
}
```

### Rack::PushNotification

```objective-c
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSURL *serverURL = [NSURL URLWithString:@"http://raging-notification-3556.herokuapp.com/"]
    Orbiter *orbiter = [[Orbiter alloc] initWithBaseURL:serverURL credential:nil];
    [orbiter registerDeviceToken:deviceToken withAlias:nil success:^(id responseObject) {
        NSLog(@"Registration Success: %@", responseObject);
    } failure:^(NSError *error) {
        NSLog(@"Registration Error: %@", error);
    }];
}
```

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Orbiter is available under the MIT license. See the LICENSE file for more info.
