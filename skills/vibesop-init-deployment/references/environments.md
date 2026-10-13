# Structure and rules of each environment

## Directory layout

```
<DEPLOY_DIR>/
├── README.md                  # decision table (output of step 4)
├── dev/
│   ├── docker-compose.dev.yml
│   ├── <service>/Dockerfile   # dev image: toolchain only, no source copied in
│   ├── secrets/*.example.txt  # committed; the real *.txt files are ignored
│   └── local/                 # all persistent data, ignored
├── prod/
│   ├── docker-compose.prod.yml   # application
│   ├── docker-compose.db.yml     # database / middleware (when self-hosted)
│   ├── <service>/Dockerfile      # production image: multi-stage build
│   ├── secrets/                  # ignored, only .gitkeep stays
│   ├── data/                     # ignored: config/ logs/ database data/ backups
│   └── .initialized              # initialization lock, ignored
├── intranet/                  # optional, same structure as prod
└── gray/                      # optional
    ├── docker-compose.gray.yml
    └── data/                  # ignored: config/ logs/
<script directory>/
├── dev.sh
├── prod.sh                    # includes the image, db and gray subcommands
└── intranet.sh                # optional
.env.example                   # committed
.env                           # ignored
```

Only these are committed: compose files, Dockerfiles, scripts, `*.example*` and `.gitkeep`. Always ignore `data/`, `local/`, `secrets/*.txt`, `.env` and `.initialized`. Add them to `.dockerignore` as well, so they stay out of the image build context.

## Local dev

- Source code is bind-mounted into the container, with the project's own hot-reload tool. The dev image holds only the toolchain
- If it is smoother to run the frontend dev server directly on the host, keep it out of compose and tell the user about this trade-off
- Use the same major version of the database and cache as production
- Ports may bind to `0.0.0.0` directly, but passwords still go through secret files (with an `*.example.txt`). Do not hard-code them in compose
- Provide `init`: it copies the real secret files from `*.example.txt` and creates the `local/` directory

## Production

- **The application compose and the database compose are separate.** The database compose declares a network with a fixed name, `<PREFIX>-prod-network`. The application compose joins it with `external: true`. Starting, stopping and upgrading the application never touches the database
- All application containers use `restart: unless-stopped`, and `TZ` is set explicitly
- Config files are mounted read-only (`:ro`). Logs, working directories and upload directories are mounted writable under `data/`
- The host ports of the database and cache bind to `127.0.0.1` only
- The `init` subcommand does one-time initialization: it creates the directories, generates each password file with `openssl rand` (skipped when the file exists), and writes the `.initialized` lock. At the end it prints the next steps. It **does not echo plaintext passwords**; it only tells the user where the password files are
- Image names in compose are written as `${REGISTRY_NAMESPACE:-local}/<image name>:latest` (`:gray` for gray). The local tag carries no registry domain, so switching between internal and public image registry addresses does not affect compose. The tag is fixed, and both release and rollback work by re-tagging on the machine
- **Services reach each other by `container_name`, not by the compose service name.** Gray joins the same network with services of the same names, and a service name would resolve round-robin across the production and gray containers

## Intranet

The structure is identical to production. The only differences:

- Separate data directories, a separate database, separate passwords
- The management script is another copy of the production template with `ENV_NAME` changed to `intranet` and the GRAY block removed (gray hangs on production only)
- Ports may be the same when it is not on the same machine as production. On the same machine they must differ, and so must the container name prefix
- Pick one of two image sources and tell the user: pull from the image registry (the same path as production, so the image itself is verified in advance), or build directly on the intranet machine (no dependence on the external network, but the push and pull step is not verified)

## Gray

Gray runs beside production on the same machine and uses the same image registry artifacts. The local tag tells them apart:

```
build → push (version tag + latest)
      → server pulls, tags locally as gray → restart gray containers → verify
      → promote: tag gray locally as latest → restart production containers
```

Rollback: pull the previous version tag, tag it as `latest`, restart production.

Rules:

1. The gray compose has no database. It joins the production network with `external: true` and reaches the production database by **container name + container port**. The services inside gray reach each other by gray's own container names, too
2. Host port = production port + 100 (or the offset the user specifies). The container name prefix is `<PREFIX>-gray-`
3. Gray has its own `data/config/` and log directories. Copy the config from production and change only what is necessary
4. The login-state signing key and the object storage configuration stay the same as production
5. Background jobs do not run in gray by default. If a background job is a separate container → leave it out of the gray compose. If it runs in the same container as the main process → mount a process-manager configuration into gray that disables them. When a temporary test is needed, start them by hand and stop them after the test
6. Migrations run once, in production. Gray does not run them
7. A local file directory that the database references (user uploads and the like): when the database is shared, mount the same production directory by default, and tell the user the cost, "gray can write production files" (question 6.5)

### Migration rules when the database is shared

Once a gray version's migration has run, the old production code is still running against the same database. So the migration must be forward compatible.

| Allowed | Condition |
|---|---|
| Create tables | None |
| Add columns | Nullable, or with a default value |
| Add indexes | None |

| Forbidden during gray | Reason |
|---|---|
| Drop columns, drop tables | Old code that references them errors out |
| Rename columns, tables | To old code this is the same as dropping |
| Incompatible column type changes | Old code reads and writes the wrong type |
| Add a NOT NULL column without a default | Old code does not pass the column on insert, so the insert fails outright |

When a breaking change is truly needed, release in two steps. The first release ships code that works with both the old and the new structure, to everyone. The second release runs the breaking migration and removes the compatibility logic.

Write these tables into the project's instruction file (`AGENTS.md` or `CLAUDE.md`) or the deploy README (ask the user which).

## Deploy account and file ownership

There are two independent decisions: **who operates on the host** (question 1.5), and **who the process in the container is** (question 3.5). Combined:

| Host operator | Container user | What the writable mounted directories need |
|---|---|---|
| root / sudo | root | Nothing; ownership matches naturally |
| root / sudo | non-root (uid N) | `chown -R N:N <writable dirs>`, otherwise the container cannot write |
| regular user | non-root (uid N) | `sudo chown -R N:N <writable dirs>`; afterwards the user may need sudo to read the logs |
| regular user | root | Files the container writes are owned by root, so the user needs sudo to edit or delete them later |

Read-only mounted (`:ro`) directories need no chown, but the files must be readable by the container user. Set secret files to 600 owned by the uid of the container user, or run as root in the container.

When deploying as root (generate matching instructions for all three account types; do not write only the non-root path):

- Make the whole set of files owned by root: the repository clone, the data directories, the secrets. **On the same machine, do not let other users run git or edit files in this clone.** Otherwise ownership gets mixed and `git pull` reports dubious ownership
- Set the secrets directory to 700. **A secret that is mounted into a container as a file gets mode 644 on the file itself.** Processes in the container often run as the uid built into the image (database images especially), and cannot read a file that is 600 and owned by root. Other users on the host are already blocked by the 700 directory. Only secrets used by the host alone, and not mounted into a container, get 600
- Put persistent content in a shared parent directory outside the repository. Everything is visible at a glance, and migrating servers takes one rsync of one directory:
  ```
  /<data disk>/<slug>/
  ├── app/       repository clone (the build context when building on the server)
  ├── data/      persistent data of each service
  └── secrets/   env files + secrets, 700 / 600
  ```
- Write host paths in compose as `${<SLUG>_DATA_DIR:-/<data disk>/<slug>/data}`. Write required variables as `${VAR:?message}`, so that a missing one fails at startup instead of running with an empty value

How the management scripts handle accounts (the template `prod.sh.template` already implements this):

- **Do not reject root**, and do not force root either
- At startup, check that Docker is usable. On `permission denied`, hint "run with sudo, or add the current user to the docker group"
- Check that the owner of the project directory and the data directory is the current user. On a mismatch, hint "this directory belongs to <owner>, run with sudo", rather than letting later commands fail with a baffling permission error
- `init` sets the secrets directory to 700. After it creates the data directories, it runs `chown` automatically when the container user is not the current user (when the current user is not root, it prints the `sudo chown` command for the user to run by hand)
- Data directories of third-party images (database, cache) are **not** chowned to the application uid. They handle ownership themselves at startup, so they go into `PLAIN_DIRS`. For an application service that uses a third-party image directly (such as a static server), the image decides the uid. Mark it separately in `WRITABLE_DIRS` as `directory:uid`
- Write the command examples in all help text and in the deploy README for the account the user chose: add `sudo` for a root/sudo deployment

## Runtime configuration

Follow the conclusion of question 2.5:

- **Config file**: the repository holds `<config>.example`. The real file lives under `config/` in the data root and is mounted read-only
- **Environment variables**: one env file per service, in the secrets directory, named `<service>.env` (`<service>.gray.env` for gray), referenced from compose with `env_file`. The repository keeps only `<service>.env.example`, which lists every variable name and notes which are secrets. When `init` finds the real file missing, it copies it from the example and tells the user to fill it in. When the file needs the automatically generated database password, tell the user which secret file to take it from. Do not print the password to the terminal
- Gray's config is copied from production, and only the necessary items change (connection addresses use container names, ports and so on). Items that must match, such as the signing key, stay unchanged

## Dockerfile conventions

Write it for the detected tech stack, meeting these:

- Multi-stage build: the build stage and the run stage are separate, and the run image holds only artifacts and runtime dependencies
- Copy the dependency manifest and install first, then copy the source, to use layer caching
- Production image: the build context is the project root, and the Dockerfile sits at `<DEPLOY_DIR>/<env>/<service>/Dockerfile`
- Dev image: toolchain only, no source copied in. The build context defaults to the Dockerfile's own directory. When the build reads the dependency manifest, change the context to the project root (the dev compose template shows how)
- Open-source route: when there is only one image, the Dockerfile goes in the repository root. That is the usual place for public projects, and users and CI both look there by default
- The run user follows the conclusion of question 3.5. For non-root, create a user with a fixed uid and `chown` the application directory to it. For root in the container, write no `USER`, and state in a comment that this is a deliberate choice and why
- Application containers get a `healthcheck` (when a health check endpoint was detected) and `init: true` (when the main process does not reap child processes itself)
- Receive build-time variables with `ARG`, and state in a comment: "goes into the build output, visible in the browser, changing it requires a rebuild"
- Pin the base image to a major version
- Pure static frontend: the build stage produces static files, and the run stage serves them with an unprivileged static server image. Its listening port and uid are decided by that image. Look them up and write them into the decision table
- When the project has no dependency lock file, tell the user this makes the versions installed by each build uncertain, and suggest generating and committing a lock file first. The user decides whether to continue
- When the user builds in China, ask whether to configure dependency mirrors (npm, Go proxy, pip, apt)
