# iOctocat

… is a GitHub app for your iOS devices (iPad, iPhone and iPod Touch).
It is open source and [available on the App Store](http://itunes.com/apps/ioctocat)

For further information visit the [project website](http://dennisreimann.github.com/ioctocat).

Your [participation is welcome](https://github.com/dennisreimann/ioctocat/contributors).
Feel free to fork, add missing features or
[report issues](http://github.com/dennisreimann/ioctocat/issues) :)

## Building and Debugging

In order to build iOctocat on your own, install the following prerequisites:

  * [Xcode](https://developer.apple.com/xcode/)
  * [Git](http://git-scm.com/)
  * [CocoaPods](http://cocoapods.org/)

Here are some tips for providing debugging information along with issues.
iOctocat logs all API calls and in the console you will find the debugging output.

  * Clone the repo and open the terminal with the directory you cloned it into

        git clone git://github.com/dennisreimann/ioctocat.git
        cd ioctocat

  * Install the submodules:

        git submodule update --init

  * Install the dependencies

        pod install

  * Create the `HockeySDK.plist` file by copying the sample:

        cp HockeySDK{.sample,}.plist

  * Open the project in Xcode

        open iOctocat.xcworkspace

  * Select "iOctocat > iPhone Simulator" in the upper left corner
  * Build and run the app by pressing the play button
  * Activate the debug console by selecting "View > Debug Area > Activate Console"
  * Clear the console (Cmd + K)
  * Move to where the error occurs
  * Copy the output in the console and attach it to your bug report

### Debugging API responses

In the Debug directory is a ruby script to check the returned JSON of the
GitHub.com API. Authentication is optional and is done via HTTP Basic Auth
in case a username and password are provided. Usage:

    Debug/api.rb PATH [USERNAME] [PASSWORD]

Example:

    Debug/api.rb user/repos your_github_username your_password

This scripts writes the output and additional debugging information to a
log file in the Debug directory. Please attach the output of this script
to your issues.

## Running the tests

To run the (sparse) test suite, you can build/test the iOctocat Unit Tests scheme.

To make the tests run from the command line you have to install ios-sim:

    brew install ios-sim

Use this command to run the tests from the iOctocat directory:

    TestScripts/run_tests_from_cli.rb

To run the tests on every file change, you can install Guard and its accompanying
ruby gems via Bundler:

    bundle install

After that you can start guard with this command:

    bundle exec guard

## Attribution

iOctocat uses some third party components and libraries:

  * [AFNetworking](https://github.com/AFNetworking/AFNetworking) by Gowalla
  * [GroundControl](https://github.com/mattt/GroundControl) by Mattt Thompson
  * [Base64](https://github.com/ekscrypto/Base64) by ekscrypto
  * [YRDropdownView](https://github.com/onemightyroar/YRDropdownView) by One Mighty Roar
  * [ECSlidingViewController](https://github.com/edgecase/ECSlidingViewController) by EdgeCase
  * [SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh) by Sam Vermette
  * [SVProgressHUD](https://github.com/samvermette/SVProgressHUD) by Sam Vermette
  * [Glyphish Pro](http://glyphish.com/) icons
  * [highlight.js](http://highlightjs.org/) by Ivan Sagalaev
