# DESCRIPTION

Really simple script to create to-dos in [Habitica](https://habitica.com/) from tasks you completed in [Things](https://culturedcode.com/things/) within the last 24 hours

# REQUIREMENTS

- sqlite3 - included with macOS, which you're probably using if you're interested in a script for Things
- [jo](http://jpmens.net/2016/03/05/a-shell-command-to-create-json-jo/) - a nifty shell command to create json in bash scripts with a clever interface because I *hate* wrestling json within bash. Just `brew install` it.

# INSTALLATION & SETUP

1. Put it in your $PATH if you want to invoke it regularly or better yet, create a launch-agent to run it at the same time every day
2. Export the `HABITICA_API_USER` and `HABITICA_API_KEY` variables with your own values or just hardcode them in the script if you're feeling lazy

# WHAT IT DOES

- Queries the Things sqlite database at the default location for all tasks you have completed in the last 24 hours
- Formats a JSON request for each completed task
- Makes a call to the Habitica API to create a to-do with the same name as the Things task, priority of Medium and a note with the date it was created.

# NOTES AND WARNINGS

This is super simple and I threw it together in a few minutes.  I definitely plan to improve it or port it to Applescript so it's using a decent interface to Things instead of hitting the sqlite database directly (gross).  
That being said, there's pretty much zero error handling, no flexibility in changing to-do priority to anything other than Medium, doesn't actually complete the task, doesn't keep track of state (ie, if you run it twice it's going to create two sets of to-do's in Habitica) etc etc.

# ACKNOWLEDGEMENTS

Thanks to Alexander Willner's [original Things3 script](https://github.com/AlexanderWillner/things.sh) for the idea to use sqlite

# CREDITS

Author:  Ron Lipke  
Date:    2017-11-25  
License: I don't know, use it at your own discretion  
