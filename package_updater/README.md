# Package Updater

## Prerequisites
* You have to create a private token https://help.github.com/articles/creating-an-access-token-for-command-line-use/ with public_repo scope and put it in ~/.ssh/package_updater_github_token.txt. Test your token in browser by accessing  `https://api.github.com/user?access_token=<your token>` You should see your github user details returned without errors.
* Run `npm install`

## Running
Just run `npm start`. The script can run in both interactive and pure command line mode - you can provide the questions to the questions in the command line beforehand. Just run `npm start` and answer the questions. The first steps are safe - read repositories, clone them and update them locally. The questions for the last steps - pushing and submitting PRs are marked in red.

Running a command line mode, e.g. `npm start 0.26 DEVELOPMENT-SNAPSHOT-2016-06-20-a wiki Yes Yes` - the script will continue until it lacks an answer in the command line.

You can stop the script and resume any time. For example, you can clone once, and then skip the clone step by providing `No` answer. You can perform clone and update the repositories locally. Later, you can skip these steps, and perform push and submit PRs.
