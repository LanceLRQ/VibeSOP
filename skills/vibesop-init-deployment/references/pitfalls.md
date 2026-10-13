# Pitfalls

After generating, go through them one by one. At delivery, explain the pitfalls that apply to the user.

## Permissions and accounts

- **Non-root container + bind mount**: a bind mount covers the directory that was `chown`ed inside the image. When the owner of the host directory is not the uid in the container, the process fails to write logs with `Permission denied`, and often all the processes fail to start together. Writable mounted directories must be `chown`ed to the container uid. Read-only mounts do not need it
- **Runtime files of a non-root container**: pid files and unix sockets are created in `/var/run` by default, which a non-root user cannot write. Move them to `/tmp`, or to a directory that is created and `chown`ed in the image. When such configuration is `COPY`ed into the image, rebuild the image after changing it
- **uid matches by number**: the host does not need a user with the same name. `chown 1001:1001` is enough
- **Mixing users after a root deployment**: the repository clone belongs to root, and a later `git pull` by a regular user fails with dubious ownership or a permission error. Operate with one account throughout
- **A regular user running docker gets permission denied**: either use `sudo` or join the docker group. Remind the user that joining the docker group is equivalent to giving that user root

## Ports and networking

- **Database and cache ports bound to `0.0.0.0`**: reachable from the public internet means scanned. Bind only to `127.0.0.1`, or do not map them at all and use the Docker network only
- **Other machines cannot connect after an application port binds to `127.0.0.1`**: when the reverse proxy or relay machine is not the same machine, bind to `0.0.0.0` and isolate with the firewall or security group. When this is a deliberate choice, state the reason in a compose comment, so nobody later "hardens" it back as an oversight
- **Docker-published ports bypass ufw**: Docker writes iptables directly, and `ufw deny` cannot block a port that is already published. Isolate with the bind address or the cloud security group
- **Gray used the host-published port to reach the production database**: inside the same Docker network, use the container name + container port
- **The default compose network name changes with the directory name**: a network that must connect across compose files needs an explicit `name:`

## Images

- **Architecture mismatch**: building on Apple Silicon and running on an x86 server fails at startup with `exec format error`. Build with `--platform`
- **Only `latest`**: there is no rollback, and no way to say which version runs online. Push the version tag and `latest` together
- **Build-time variables**: the public variables of frontend frameworks are written into the build output at build time, so changing a container environment variable at runtime has no effect. They are also visible in the browser and must not hold secrets
- **Dependency lock files across platforms**: a lock file generated on macOS may fail in strict install mode in a Linux build, because platform-specific optional dependencies are missing. When it happens, explain it to the user and let them choose how to handle it. Do not quietly change the command
- **`.dockerignore` gaps**: if `.env`, data directories, the secrets directory and `.git` are not excluded, they end up in the build context and even in image layers

## Configuration and secrets

- **`export $(grep -v '^#' .env | xargs)`**: breaks when a value contains spaces, quotes or `#`. Use `set -a; . ./.env; set +a`
- **A required variable is missing but the service starts silently**: write required variables in compose as `${VAR:?message}`
- **Passwords printed to the terminal during initialization**: they stay in the scrollback and in logs. Tell the user only the path of the password file. The one exception is the install wizard on the open-source route. The randomly generated admin password is shown once on the interactive terminal, because the user needs it to log in right now and may not know to look in `.env`. It is still not written to any log
- **Repeated initialization overwrites secrets**: `init` needs a lock file, and existing secret files are always skipped
- **A read-only mounted config cannot be edited back**: edits to a file on a `:ro` mount cannot be saved inside the container. Edit the file on the host and have the service reload
- **Cache ACL / permission configuration written with command names from memory**: startup fails outright. Before changing it, look up the commands and categories the target version actually supports

## Gray

- **Both sides run background jobs**: with a shared database or queue, messages are consumed twice and scheduled tasks run twice
- **The login-state signing keys differ**: users are logged out when they switch between gray and production
- **Migrations are not forward compatible**: once gray migrates, the old production code errors out at once. See the rules in `environments.md`
- **Forgetting to restart production after promote**: the local tag changed, but the running containers still use the old image. Run `restart` after `promote`
- **Gray config copied from production without changing the connection address**: `127.0.0.1` inside a container points at the container itself

## Scripts

- **A management script overwrites an artifact that is in use**: do not let another command write to the same path as an output file that the dev hot-reload tool is using
- **`docker-compose` and `docker compose`**: detect the new subcommand plugin first. Keep the old command only for compatibility
- **Dangerous subcommands with no confirmation**: `down -v`, `restore`, deleting data directories and the like must ask for a second confirmation
- **A variable followed directly by Chinese text or a fullwidth symbol**: bash 3.2, which ships with macOS, folds the multibyte character into the variable name when it parses `$VAR` followed by a fullwidth parenthesis, and prints garbage. Wherever a script has a variable directly followed by a non-ASCII character, write `${VAR}`

## Problems found in rehearsals

- **A secret file that is 600 and owned by root cannot be read inside the container**: a secret mounted as a file keeps the host's owner and permissions in the container, and database images and the like drop to their own uid before reading it. Do this: secrets directory 700, files mounted into containers 644
- **Chowning the database data directory to the application uid**: the database fails to start or refuses the directory. The data directory of a third-party image is only created, never chowned
- **The data path changes after a database image changes major version**: a wrong mount point raises no error, the data lands in the container layer, and recreating the container loses it. Confirm the in-container data path in the image documentation of the chosen version
- **Gray and production on the same network with services of the same name**: reaching each other by service name round-robins between the two sets of containers, so requests sometimes hit production and sometimes gray. Always use the container name
- **Applying the server's path outside the repo to the dev machine**: that path usually does not exist or is not writable on the dev machine. The layout outside the repo is for servers only
