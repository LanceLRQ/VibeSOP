# Open-source release route (Docker Hub + one-line install)

Take this route when question 0.1 is answered with "open-source project". Its basic difference from the private route is that **the person deploying is not the maintainer**. The user's machine has no repository and no build environment. It has only one install command and, afterwards, one global command.

| | Private route | Open-source route |
|---|---|---|
| Who deploys | The maintainer, in a cloned repository | Any user, on a machine with no repository |
| Entry point | `scripts/dev.sh`, `scripts/prod.sh` | `curl` piped into `bash`, then `<command name> <subcommand>` |
| Images | Built on the build machine, pushed to a private image registry | CI builds on a tag and pushes to a public Docker Hub repository |
| Configuration | Compose and `.env` in the repository | The install wizard generates `.env`; compose is embedded in the install script |
| Environments | Local dev / intranet / gray / production | Only "local dev" and "release artifacts" |

## What is generated

```
<deploy directory>/
├── <command name>.sh        # single-file install and management script (templates/install.sh.template)
├── docker-compose.yml       # release orchestration (templates/docker-compose.release.yml.template)
├── .env.example             # for users who deploy by hand without the script; there is no template, so list the keys the release compose references one by one, with comments
└── dev/                     # local dev environment, same as the private route
<script directory>/dev.sh
Dockerfile                   # in the repository root; the build context is the repository
docker/DOCKERHUB.md          # description for the Docker Hub repository page (optional)
.github/workflows/
├── docker-publish.yml       # templates/github-actions-dockerhub.yml.template
└── dockerhub-description.yml
```

Generate the local dev environment by the private route's rules, as usual. **The intranet, gray and Alibaba Cloud ACR batches of questions do not appear.** Write "not applicable on the open-source route" in the decision table. When the maintainer wants to deploy a copy, they use the same install script.

The release compose is written differently from the private route, because users will not edit it:

- Every variable item goes through `.env` interpolation, so users never need to change the file itself
- Required items are written as `${VAR:?message}`
- The run identity uses `user: "${PUID}:${PGID}"`. The user picks it in the wizard; it is not fixed at build time. So the image must be able to run as any uid (see "Image" below for how)
- One file holds all the services. When the project needs a database, it goes in the same compose, too. Users want one command that starts the whole set, not two separate starts

## Image

The release image must be able to run as any uid the user picks. Write the Dockerfile to these requirements:

- Application files are readable by everyone (executables are executable), and are **not** required to be writable by the run user
- The only places the process needs to write are the mounted data directory. The install wizard adjusts its owner to the chosen uid. Do not set directories to 777 in the image to get around this
- For tech stacks that write to the home or cache directory at runtime, point those paths at the data directory or `/tmp` with environment variables
- A non-root default `USER` is fine. `user:` in compose overrides it
- A dependency lock file is required: a public image must be reproducible. When the project has none, tell the user first and suggest adding one. The user decides whether to continue
- The rest follows "Dockerfile conventions" in `environments.md` (multi-stage build, install dependencies before copying source, pin the base image to a major version)

## Version number

The **single source of truth** is the file confirmed in question 8.3 (`package.json`, `pyproject.toml`, `Cargo.toml`, `VERSION` and so on). Two other places must match it. CI checks this before release and fails on a mismatch:

- The git tag: `v` + the version number
- The `SCRIPT_VERSION="x.y.z"` line in the install script

The format of the `SCRIPT_VERSION` line is an interface. CI extracts it with `sed` by whole line, and script self-update (an advanced option) matches the whole line exactly. Do not add a trailing comment and do not change the quotes.

Image tags: every release pushes `x.y.z`. A stable release also pushes `latest`. A pre-release (a version containing `-`, such as `1.2.0-rc.1`) does **not** push `latest`. By default the install script installs the image with the same version as the script itself, not `latest`. That way what one copy of the script installs is deterministic.

Write the release steps into the project docs: change the version source → change `SCRIPT_VERSION` to match → update the CHANGELOG → commit → tag `vX.Y.Z` and push.

## Docker Hub setup guide

When the user has not set this up, lead step by step. Explain the next step only after the previous one is done:

1. Register and log in at hub.docker.com. The image name is `<namespace>/<repository name>`. For a personal account the namespace is the username
2. Create the repository: Repositories → Create, with visibility Public. You may also skip this, because the first push creates the repository automatically (the default visibility depends on the account settings, so after the push have the user confirm once that it is Public)
3. Generate an access token: Account settings → Personal access tokens → Generate, with **Read & Write** permission. The token is shown only once
4. Configure encrypted variables on the code hosting platform. On GitHub: Settings → Secrets and variables → Actions, then add `DOCKERHUB_USERNAME` (the username) and `DOCKERHUB_TOKEN` (the token from the previous step)
5. When the repository description needs syncing: that API may require account-level credentials. When the token is not enough, add a `DOCKERHUB_PASSWORD`

Remind the user: everything in a public image is public. Before building, confirm that `.dockerignore` excludes `.env`, internal documents, local data and secrets. Do not write any credential into an image layer through `ARG` / `ENV`.

Pulling from Docker Hub can be restricted for users in China. Ask the user whether the install docs should say how to cope (configure `registry-mirrors` or a proxy), and whether the script download address should offer a mirror source that can be overridden (the template already supports overriding it with `<prefix>_RAW_BASE`).

## Install script

`templates/install.sh.template` is the core version. After generating, adjust it to the project.

**Commands**: `install` (wizard), `start`, `stop`, `restart`, `status`, `logs [-f]`, `upgrade [--to version]`, `doctor`, `uninstall`, `version`, `help`. With no command: if not installed, it starts the wizard. If installed, it shows a numbered menu.

**What the wizard asks**: the core version asks for the install directory, port, listen address, run identity and time zone, and (optional block `ADMIN_PASSWORD`) the admin password. Add the project's own settings following the conclusion of question 8.6. **Each added item touches these places.** Missing one produces "asked but never used" or "installed but will not start":

1. `wizard`: the question, written as `W_XXX=$(ask …) || return 1`
2. `wizard`: validate on the spot. Check the format requirement and `env_valid_value` (the value must not contain a single quote or a newline). Do not wait until write time to fail
3. The `wizard` summary page: show the item. Do not show sensitive items
4. `apply_install`: write it to `.env` with `env_set`, chained onto the existing `&&` chain
5. The release compose: pass the `.env` key to the variable name the application reads (the two names often differ), and use `${key:?…}` for required items. After the change, sync it into `tpl_compose` again
6. `cmd_doctor`: add required items to the check list
7. `.env.example`, the Docker Hub description, and the configuration table in the README

The optional block `ADMIN_PASSWORD` is a complete example. Add an item the way it is written in its three places.

**Embedded compose**: put the content of the release compose file, byte for byte, into the heredoc of `tpl_compose` (replacing the `{{COMPOSE_BODY}}` line). The two must be identical. The CI template has a step that checks this. The local check command:

```bash
<prefix>_SOURCE_ONLY=1 <prefix>_TTY=- bash -c '. <script path>; tpl_compose' </dev/null | diff - <compose path>
```

**Guards that must stay** (do not delete them when changing the script):

| Guard | Purpose |
|---|---|
| Automatic `exec bash` when run with `sh` | Users often run `sh xxx.sh`. These lines must stay POSIX compatible |
| Interactive input always reads from fd 9 (`/dev/tty`) | When `curl` pipes into `bash`, stdin is a pipe and cannot be used to read user input |
| With no TTY, fail with an error and print the "download first, then run" command | CI and some containers have no terminal |
| Write no file before confirmation | If the user cancels midway, no garbage is left behind |
| Input ending (EOF) counts as cancel and never falls back to the defaults | When a pipe breaks or the terminal closes, it does not install with the defaults without anyone confirming |
| Values written to `.env` are validated during the wizard | It never fails halfway through writing |
| The state file is written last | An install that failed midway is not treated as "installed" when it is run again |
| `path_forbidden` | Refuses `/`, the home directory, `/opt`, `/usr` and other top-level directories themselves as an install or delete target |
| `.env` has mode 600; a value containing a single quote or a newline is rejected | Passwords do not leak. Values are written wrapped in single quotes, and these two characters cannot be expressed safely |
| `env_set` replaces by key, in place | It does not reorder or delete comments and extra variables, so hand edits to `.env` by the user are safe |
| The launcher is a two-line script, not a symlink | The install directory is hard-coded in it, so running it from any directory acts on this deployment |
| Detect automatically when Docker needs sudo | Does not require the user to join the docker group first |
| Hint to use sudo when permissions are insufficient | Does not change ownership on its own initiative |
| Roll back the version number when a pull fails | After a failed upgrade, `.env` and the running containers stay consistent |
| Uninstall requires typing the directory name, and the directory must hold a state file | Prevents deleting the wrong directory |
| Download the script, run `bash -n` on it, then write it to disk | Prevents saving an error page or a truncated file |
| Write `${VAR}` when a variable is followed directly by Chinese text | bash 3.2 compatibility |

**Overridable environment variables** are both an escape hatch for special environments and the entry point for injecting stubs in tests. Keep them, and list the first four in the user-facing docs:

| Variable (prefix with `<prefix>_`) | Purpose |
|---|---|
| `HOME` | Install directory (exported by the launcher) |
| `RAW_BASE` | Download address prefix of the script itself. When the network is restricted, point it at a mirror that is reachable |
| `HUB_TAGS_URL` | API address for querying the latest version |
| `READY_TIMEOUT` | Seconds to wait for readiness after startup |
| `BIN_DIR`, `DOCKER_BIN`, `SUDO`, `DOCKER_SOCK`, `TTY` | Test stubs: the directory of command entries, the docker and sudo executables, the sock path, the interactive terminal (`-` means read from stdin) |
| `SKIP_PLATFORM_CHECK=1` | Skip the "must be Linux" check. Used for stub tests on other systems |
| `SOURCE_ONLY=1` | Only define the functions and run nothing, so that tests can `source` the script |

### Advanced options

Capabilities that the core version lacks but that are often wanted when serving many users. **Ask the user about each item.** Write the chosen ones as needed, and record in the decision table which were chosen:

| Advanced option | Notes |
|---|---|
| Script self-update | `upgrade` first replaces the script with the target version, then continues. The core version only upgrades the image, and the script stays at the version it was installed with |
| Take over an existing deployment | When the directory already holds a hand-written compose / `.env`, parse the old values, back them up, and convert to script-managed. The core version only warns that it will overwrite |
| Template change comparison | On upgrade, when the user is found to have hand-edited compose, show the diff and ask whether to replace it. After install, the core version no longer touches compose |
| `config` subcommand | Change the port, password and so on from a menu, and ask whether to restart. The core version has the user edit `.env` directly and run `restart` |
| Arrow-key menu | Needs handling of terminal raw mode and restoring it on exit. The core version has a numbered menu |
| Bilingual (Chinese and English) | Switch by `LANG` or `--lang`. The core version has Chinese text only. Recommended when serving international users. How to do it: see below |
| Build from source | When run inside the repository, offer "local build" as an image source |
| Project-specific probes | GPU, disk space, host capabilities the project depends on, and the like |
| Periodic new-version check | The menu header says when an update exists, with caching and a timeout |

**How to do the bilingual option**:

- Add a function that fetches text. Write the two language versions next to each other at the call site (bash 3.2 has no associative arrays, so do not use them). Large blocks of text such as `cmd_help` get one heredoc per language
- Language order of precedence: `--lang` argument > `<prefix>_LANG` > `LC_ALL` > `LANG`. A value starting with `zh` means Chinese, and anything else means English. Resolve it in `main` right after parsing the arguments, before any output
- When the user chose a language with `--lang`, write it into the launcher (export one more line, `<prefix>_LANG`). Otherwise a later run through the launcher falls back to the system language
- All user-facing text needs both languages, including error messages and every line of `doctor`. In tests, run the main flow once in each language
- Text aligned with spaces, such as the summary page, differs in width between Chinese and English. Lay them out separately

### Tests

The install script runs with elevated privileges on other people's machines, so it deserves tests. Generate at least one smoke test. Use environment variables to replace `docker` and `sudo` with stubs, point the install directory at a temporary directory, feed in preset answers, and assert the files written and the content of `.env`. Ask the user which framework to write the tests in (the project's existing test framework, or plain shell). Put the tests in `<deploy directory>/tests/` and wire them into the verify job of the release workflow. Cover at least: the files written by a normal install, forbidden paths refused, cancelling midway writes nothing, **input ending midway writes nothing**, and rollback when an upgrade pull fails.

## Verify

In addition to the general checks in step 6 of SKILL.md:

```bash
bash -n <install script> && shellcheck <install script>
# the embedded template matches the repository file (command above)
<VERSION key>=0.0.0 docker compose -f <release compose> config -q
# without a version number it must fail, not pass silently
docker compose -f <release compose> config -q    # expected: non-zero exit, a message that the version is missing
```

Also walk through the wizard in the stub environment, and confirm that cancelling leaves no file in the target directory.

## What to tell the user at delivery

- What to do before the first release: configure the two secrets, confirm the visibility of the Docker Hub repository, push the first tag
- The address in the install command points to the script on the default branch: **a script change pushed to the default branch takes effect for new users at once**, regardless of tags. Treat a change to the install script like a change to live code
- Put the one-line install command in a prominent place in the README, and also give the "download first, then run" form, so that users can look at the script first
