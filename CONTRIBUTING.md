# How to contribute to iOctocat

## Reporting issues or requesting a feature

Before you actually do that, please take the time to see if someone else has brought
up the thing you would like to mention before. Oftentimes you will not only find what
you are searching for, but also the current state of a feature we are working on or
existing discussion about bugs and feature requests.

## Debugging API responses

In the Debug directory is a ruby script to check the returned JSON of the
GitHub.com API. Authentication is optional and is done via HTTP Basic Auth
in case a username and password are provided. Usage:

    Debug/api.rb PATH [USERNAME] [PASSWORD]

Example:

    Debug/api.rb user/repos your_github_username your_password

This scripts writes the output and additional debugging information to a
log file in the Debug directory. Please attach the output of this script
to your issues.

In case you are using a Ruby version prior to 1.9 (find out with `ruby -v`)
you will need to install the json gem with this command:

    gem install json
