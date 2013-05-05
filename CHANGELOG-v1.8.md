# CHANGELOG for v1.8

## v1.8.2

Additions:

* Support for submodules

Bugfixes:

* Prevent crash caused by logout while user objects are loading

[Commits](https://github.com/dennisreimann/ioctocat/compare/v1.8.1...HEAD)

## v1.8.1

This is a bugfix and enhancement release.

Additions:

* Pre-fill user information for feedback form

Changes:

* Improved text fields with long texts

Bugfixes:

* Fixed account migration for older versions upgrading to v1.8.x
* Fixed crashes caused by incorrect observer handling
* Fixed unread badge count when opening notification from push

[Commits](https://github.com/dennisreimann/ioctocat/compare/v1.8.0...v1.8.1)

## v1.8.0

This version brings you push notifications for your GitHub notifications, along with lots of nice improvements.
Special thanks again to @iosdeveloper, who helped out with a lot of things, his contributions are invaluable!

Push notifications work on a per account basis: To enable this feature, go to your account management view (via the blue arrow on the right of the accounts list), enter your password and enable the push feature.

And now: Enjoy this release as much as we do :)

Additions:

* Push notifications
* @username completion. By @iosdeveloper
* #Issue completion. By @iosdeveloper
* Copy SHA of a commit. Thanks @iosdeveloper
* Internal web browser: Basic navigation, Open in Safari, Copy URL. Thanks @iosdeveloper
* Open all URLs highlighted in issues/comments internally (experimental). Thanks @iosdeveloper
* Forks link to the original repository
* Comments link to the user profile. Thanks @iosdeveloper
* 1Password integration
* Browse gist forks
* Handle static pages and notifications when opening a GitHub.com URL
* Option to disable avatar loading. Thanks @mazanma3
* Show a commit on GitHub. By @iosdeveloper
* Open trees and blobs from GitHub URL
* Choose the type of account (GitHub.com or Enterprise) before adding a new account
* New code highlighting languages and themes

Changes:

* Improved GitHub Status handling. By @iosdeveloper
* Better handling of accounts
* Better icon for forked repo in event cell
* Scrollable account form
* Display merge button with status, even if the pull request is not mergeable
* Moved account removal to account form view
* Prevent creation of duplicate accounts
* Start with adding a new account if there is none
* Badge is now used to indicate number of unseen push notifications
* Check system status only for github.com accounts

Bugfixes:

* Last refresh dates were shared across accounts
* Gists were not handled properly via the URL scheme. Thanks @iosdeveloper

[Commits](https://github.com/dennisreimann/ioctocat/compare/v1.7.8...v1.8.0)
