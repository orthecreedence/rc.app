# rc.app

This is a startup script template. All others I've found fall completely short
in one area or another.

This script should be called as root, and handles:

- Running app as specified user
- Logging (as root or as specified user)
- PID creation for the app
- Killing not only the app (via SIGTERM) but also its children
- Showing run status

## Configuration

The top of the script has a config section with values you change to suit your
needs:

- `NAME`  
The name of your app
- `PID`  
Path the PID file will be written to
- `CREATE_PID`
Set to `0` if the app you're running creates its own PID, set to `1` if you want
`rc.app` to create the pidfile for you
- `USER`  
The user you want to run the app as
- `EXE`  
The language to call the app with (eg `/usr/bin/python`)
- `APP`  
The path to the app's initialization file
- `ARGS`  
All the arguments to pass to the script being called
- `LOG`  
The path the file *all output* will be logged to
- `CWD`  
The path to change directories to before running, if required
- `CHGRP_LOG`  
Set to `0` if you want logfiles to be `root:root`, otherwise they will be owned
by `root:${USER}` and set to mode `0664`. This allows the app to log directly to
the log file using methods other than STDOUT/STDERR.

## Commands

The script accepts `start`, `stop`, `restart`, and `status`.

## Examples

```bash
NAME=turtl-api
PID=/var/run/turtl-api.pid
USER=app
EXE=/usr/local/bin/cl
APP=/var/www/turtl/api/start.lisp
ARGS="--port=1337"
LOG=/var/log/turtl/api.log
CWD=/var/www/turtl/api
USER_OWNS_LOG=0
```

Will run:
```bash
cd /var/www/turtl/api
sudo -u app sh -c "/usr/local/bin/cl /var/www/turtl/api/start.lisp --port=1337" 1>> /var/log/turtl/api.log 2>&1 &
```

