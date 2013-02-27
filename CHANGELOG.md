# CHANGELOG

## v1.7.8

THE Bugfix Release™ - powered by @iosdeveloper :)

Additions:

* Mark all notifications for a repo as read
* Open Repo and Gist files in other apps. Thanks @iosdeveloper
* Added Stargazers to Repository. Thanks @mazanma3
* Added Starred Repos to User Profile. Thanks @mazanma3
* Added version info to menu footer

Changes:

* Various UI and UX improvements
* My Repositories: Distinguish between personal and member repos
* Allow issues to be saved without a text
* Do not allow refresh when resource is already loading
* Improved handling of the search feature
* Issues: Keep last scroll position of the list when going back from an issue
* Issues: Add author to second line of text
* Use notepad icon for gists throughout the app

Bugfixes:

* Re-added missing ability to merge pull requests
* Fixes for blob display in case of an error
* Fixed crash caused by comments observer
* Prevent opening unloaded/non-existing repos

## v1.7.7

Additions:

* Option to disable the unread notifications badge
* Webview shows page title. Thanks @drodriguez
* "Show on GitHub" on user profile

Changes:

* Use box icon for repository throughout the app
* Dismiss existing progress indicator when leaving code views
* Improved form for editing issues and pull requests
* Keep search term when selecting a different segment
* Marking notifications as read does not remove them from the list
* Do not allow refresh when resource is already loading

Bugfixes:

* Fixed crash when selecting an event cell after failed reload
* Fixed crash when selecting a notification cell after failed reload
* Fixed crash caused by triggering item loading while its already loading
* Fixed eventually crash when deleting an GitHub Enterprise account
* Fixed eventually cut text in comment cells
* No more empty cell when there are no private or public repos
* Automatically reload changed issues

## v1.7.6

Additions:

* Set app badge to number of unread notifications
* Separate icon for forked repositories
* Added list of repository contributors
* Added repository commits for branches

Changes:

* Check the users assignment status for editing issues and pulls
* Separate section for forks in personal repositories list
* Better handling of events reloading
* Improved issue and pull request headers
* Use plain style for all list views

Bugfixes:

* Select correct account for editing after failed authentication
* Added missing date for last feed refresh before first load
* Fix for gists that wrongly appeared in some events
* Handle list changes in parent controllers

## v1.7.5

Additions:

* Check GitHub system status on app activation
* Notifications support (push notifications will be added soon)
* Added reload button for organizations
* Added full commit message text to commit view
* Reload button for forks

Changes:

* New icons for public and private state (repos and gists)
* Finetuned the icon. Thanks @benjaminrabe
* Improved code highlighting
* Improved repository view header
* Improved gist view

Bugfixes:

* Fixed missing pull requests for pull request comment events
* Fixed crash in events controller (when tapping loading cell)
* Fixed crash in accounts controller (when deleting the last account)
* Fixed follower button in following event cell
* Fixed display error for writing comments in landscape mode
* Fixed indefinitely loading case for repository view

## v1.7.1

Additions:

* Allow scaling in code view
* Added license acknowledgements for third party libs
* Separate lists for watched and starred repositories

Changes:

* New icon. Thanks @benjaminrabe
* Inverted menu with dark colors
* Section the accounts by endpoint. Thanks @lmarlow
* Increase revealed space for top view when menu is shown
* Removed the animation for initial top view slide-in

Bugfixes:

* Show authentication message HUD on initial login. Thanks @zhen9ao
* Fixed icon graphic glitches (dark borders in upper edges)
* Fixed crash in repo controller (during loading of the branches)
* Fixed crash in user controller (when tapping on cell in empty orgs and repo lists)
* Fixed crash for certain issue events

## v1.7.0

Additions:

* New navigation menu
* Authentication via OAuth (please reauthenticate)
* Support for Pull Requests
* Reworked commenting and comment loading
* Fixes and updates for gists
* Preparations for announced API changes
* Added repo link to issue and pull request pages
* Open GitHub links by changing https:// to ioc://
* Allow issue and pull editing for repo owners

Bugfixes:

* Fixed maximum avatar size
* Proper theme default
