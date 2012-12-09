# iOctocat

… is a GitHub app for your iOS devices (iPad, iPhone and iPod Touch).
It is open source and [available on the App Store](http://itunes.com/apps/ioctocat)

For further information visit the [project website](http://dennisreimann.github.com/ioctocat).

Your [participation is welcome](https://github.com/dennisreimann/ioctocat/contributors).
Feel free to fork, add missing features or
[report issues](http://github.com/dennisreimann/ioctocat/issues) :)

## Debugging

Here are some tips for providing debugging information along with issues.
iOctocat logs all API calls and in the console you will find the debugging output.

  * Clone the repo and open the terminal with the directory you cloned it into
  * Run this command in the terminal: `git submodule update --init`
  * [Install CocoaPods](http://cocoapods.org/) and run `pod install`
  * Open the project in Xcode
  * Select "iOctocat > iPhone Simulator" in the upper left corner
  * Build and run the app by pressing the play button
  * Activate the debug console by selecting "View > Debug Area > Activate Console"
  * Clear the console (Cmd + K)
  * Move to where the error occurs
  * Copy the output in the console and attach it to your bug report

## Attribution

iOctocat uses some third party components and libraries:

  * [AFNetworking](https://github.com/AFNetworking/AFNetworking) by Gowalla
  * [Base64](https://github.com/ekscrypto/Base64) by ekscrypto
  * [YRDropdownView](https://github.com/onemightyroar/YRDropdownView) by One Mighty Roar
  * [ECSlidingViewController](https://github.com/edgecase/ECSlidingViewController) by EdgeCase
  * [Glyphish Pro](http://glyphish.com/) icons
  * [highlight.js](http://highlightjs.org/) by Ivan Sagalaev
