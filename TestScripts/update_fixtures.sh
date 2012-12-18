#!/bin/bash

# Updates the test fixtures by getting new data from the GitHub API.
# We use this to see data structure changes.
# Run it from the project with the following command:
#
# TestScripts/update_fixtures.sh

curl https://api.github.com/repos/dennisreimann/ioctocat/commits/6ff063b8d5edfb4e2288db92464c2fbbf731f986 > iOctocatUnitTests/Fixtures/Commit-Large.json
