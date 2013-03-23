# Developing iOctocat

## Prerequisites

In order to build iOctocat on your own, install the following prerequisites:

  * [Xcode](https://developer.apple.com/xcode/)
  * [Git](http://git-scm.com/)
  * [CocoaPods](http://cocoapods.org/)

## Building the project

  * Clone the repo and open the terminal with the directory you cloned it into

        git clone git://github.com/dennisreimann/ioctocat.git
        cd ioctocat

  * Run the bootstrap shell script:

        ./bootstrap.sh

    This does the following things you can otherwise do manually:

      * Install the submodules
      * Install the dependencies
      * Create the `iOctocatAPI.plist` file by copying the sample
      * Create the `HockeySDK.plist` file by copying the sample

  * Open the project in Xcode

        open iOctocat.xcworkspace

  * Select "iOctocat > iPhone Simulator" in the upper left corner
  * Build and run the app by pressing the play button

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
