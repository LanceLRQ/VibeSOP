# Questionnaire

Ask in the user's language. The English in the tables is not a script to read out.

Ask in batches. Give every question a **recommended default and a one-line reason**. A user who accepts the default has confirmed it. When the "condition" in parentheses is not met, skip the question and write "not asked / not applicable" and the reason in the decision table.

## Batch 0: Release route

This is the only question in the batch. Ask it first. It decides which batches follow.

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 0.1 | Is this a private project, or will it be released as open source for others to deploy? | Private project | **Private**: the maintainer deploys from the repository with the management scripts, and images go to a private image registry → continue with batches 1–7. **Open source**: images are published publicly to Docker Hub and users install with one command → ask only the questions listed below, then jump to batch 8. Do not ask the other questions of batches 1–6, and write "not applicable on the open-source route" in the decision table. When the governance record says the visibility is open source, recommend the open-source route as the default. In every other case the private route stays the default. The question is still asked. |

The differences to explain to the user are in the comparison table at the start of `open-source-route.md`.

Questions from the earlier batches that are still asked on the open-source route (all of them serve the local dev environment only):

| Question | Meaning on the open-source route |
|---|---|
| 1.1 | Ask instead: is a local dev environment wanted (recommended: yes) |
| 1.2 | Project identifier and short prefix |
| 2.1, 2.2 | Deploy directory; location and name of the dev script |
| 2.5 | How application runtime configuration is supplied (both the dev environment and the release compose use this conclusion) |
| 3.2 | Container port of each service; host port during development |
| 5.3, from batch 5 | (condition: there is a database) image and version |

Do not ask about the run user of the dev container, the local data directory or the location of the dev machine's `.env`. Take the default uid, `<deploy directory>/dev/local/` and the project-root `.env`, and write them into the decision table.

## Batch 1: Scope

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 1.1 | Which environments are needed? (multi-select) | Local dev + production | Can add: intranet, gray |
| 1.2 | What is the project identifier (slug)? | The repository name in kebab-case | Used for image names, the compose project name and network names. Also ask for a 2–5 letter short prefix for container names (such as `shop`) |
| 1.3 | How do images get to the server? | Push to Alibaba Cloud ACR, then pull (whenever there is an environment that is not on this machine) | The other two: clone the repository on the server and build there directly (`git pull` + `up -d --build`, for small single-machine projects, no image registry needed); carry images by hand with `docker save/load`. If not ACR, skip batch 4 |
| 1.4 | What CPU architecture do the build machine and the server have? | Server `linux/amd64` | The platform must be set explicitly when the build machine is Apple Silicon and the server is x86. It does not matter when building on the server |
| 1.5 | Which account deploys on the server? | Ask; no preset | root (or `sudo` throughout) / a regular user with sudo / a regular user already in the docker group. Support all three. For the differences see "Deploy account and file ownership" in `environments.md` |
| 1.6 | Does the server already have a unified HTTP entry point (host Nginx / OpenResty / control panel / cloud load balancer)? | Ask; no preset | The port bind address (3.4) and the reverse proxy (7.1) both depend on this answer |

## Batch 2: Directories and file locations

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 2.1 | Which directory holds the deployment files? | `deploy/` (one subdirectory per environment) | |
| 2.2 | Where do the management scripts go, and what are they called? | `scripts/dev.sh`, `scripts/prod.sh` (`scripts/intranet.sh` for intranet) | Gray is merged into the production script as the `gray` subcommand |
| 2.3 | Where does `.env` live? | One file in the project root, shared by all scripts | It holds only "build and operations" variables (image registry credentials, migration connection strings, build-time variables). For application runtime configuration see 2.5 |
| 2.4 | Where does each environment keep its persistent data? | Dev: `deploy/dev/local/`. For the others pick one: inside the repo at `deploy/<env>/data/`, or a shared parent directory outside the repo `/<data disk>/<slug>/{app,data,secrets}` | Find out which disk on the server has the most space. With a parent directory outside the repo, `.env` and the secrets go into that directory's `secrets/` as well. `DEPLOY_DATA_DIR` / `DEPLOY_SECRETS_DIR` in the templates can override the default paths. **A path outside the repo applies to server environments only**: local dev always uses an ignored directory inside the repo, and the `.env` on the build machine is also in the project root. Tell the user this |
| 2.5 | How is application runtime configuration supplied? | Follow how the project already reads it: config file → read-only mount (`data/config/`); environment variables → one `env_file` per service | For how each is set up see "Runtime configuration" in `environments.md` |

## Batch 3: Services and ports

Confirm these for **each service** in the service inventory:

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 3.1 | Image name | `<slug>-<service>` | |
| 3.2 | Container port / production host port | The detected port | Remind the user to check whether the port is already taken on the server. A pure static frontend has no listening port of its own. Its container port depends on the static server image chosen, so confirm that too |
| 3.3 | Host ports in the other environments | Gray = production + 100; intranet = same as production (different machine) | Environments that run side by side on one machine must use different ports |
| 3.4 | Host port bind address | Follow 1.6: entry point on the same machine as the containers → `127.0.0.1`; entry point on another machine, or direct access from other machines → `0.0.0.0` | When `0.0.0.0` is chosen, remind the user to check the firewall and security group |
| 3.5 | Which user does the container run as? | Non-root (fixed uid, such as 1001) | The other option: root in the container. Explain the trade-off. Non-root isolates better, but writable mounted directories must be `chown`ed to that uid. Root in the container needs no chown and can read read-only secrets that are root-owned with mode 600 on the host, but a compromised container has more privilege. This is a decision independent of 1.5. For a service that uses a third-party image directly (database, static server and the like), the image decides the uid. Find it out and record it in the decision table |
| 3.6 | (condition: build-time variables detected) Which variables must be injected at build time? | The detected list | Explain: these values go into the build output, are visible in the browser, and changing one requires a rebuild |
| 3.7 | (condition: background jobs detected) How do the background jobs run? | Same image as the main process, in a separate container | The other option: several processes under a process manager inside one container. A separate container has no image of its own and is not listed in `{{SERVICES}}` |

## Batch 4: Alibaba Cloud ACR (condition: 1.3 = needed)

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 4.1 | Has ACR already been set up (instance, namespace, login password)? | — | No / unsure → go through the guide in `aliyun-acr.md` first |
| 4.2 | Region and instance type | — | Decides the image registry address. A new personal-edition instance has an address like `crpi-xxxx.<region>.personal.cr.aliyuncs.com`. Have the user copy it from the console; do not assemble it |
| 4.3 | Namespace | — | |
| 4.4 | Is the server in the same region as ACR and inside an Alibaba Cloud VPC? | — | Yes → pull through the VPC internal address (fast, no public traffic charge) |
| 4.5 | Image tag strategy | Push the version tag and `latest` together | Version source: `git describe` or a manual `IMAGE_TAG` |

## Batch 5: Databases and middleware (condition: stateful dependencies detected)

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 5.1 | Is the production database self-hosted in a container, or a cloud database? | Follow the user's current setup | Cloud database → do not generate a database compose; leave only the connection configuration notes |
| 5.2 | (self-hosted) Are the database and the application in two separate compose files? | Separate | Restarting or taking down the application does not affect the database |
| 5.3 | Image and version | The detected version, major version pinned | Do not use `latest` |
| 5.4 | Host port | A non-standard port, bound to `127.0.0.1` | Only for migration tools and backup scripts that access it from the host |
| 5.5 | How are accounts split? | Three accounts: superuser / application / backup, with one secret file for each password | Random passwords are generated automatically on first initialization |
| 5.6 | (condition: there is a migration tool) Where do migrations run? | Inside the application container, wrapped by the management script's `db migrate` | The other option: install the migration tool on the host and keep the connection string in `.env`. The former needs no toolchain on the host |

## Batch 6: Gray (condition: 1.1 includes gray)

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 6.1 | Do gray and production share the database, or does gray have its own? | Shared | Shared → migrations must be forward compatible (see `environments.md`). Separate → no such constraint, but real data cannot be validated |
| 6.2 | How is traffic routed to gray? | Cookie-based split | Others: a separate domain / direct connection to a separate port |
| 6.3 | (condition: there are background jobs) Does gray run the background jobs? | No | With a shared database or queue, running them on both sides consumes messages twice |
| 6.4 | Which settings must match production? | The login-state signing key, the object storage configuration | Otherwise users get logged out when switching between the two |
| 6.5 | (condition: 6.1 = shared, and there is a local upload or file directory) Does gray mount the same file directory as production? | Mount the same one | Explain the trade-off. If not shared, files referenced in the database cannot be opened on the other side. If shared, the gray version can write production files, so a gray bug may reach production data |

## Batch 7: Optional modules

Ask about every item whether it is wanted. Do not choose for the user.

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 7.1 | (condition: ≥2 externally exposed HTTP services) Include a reverse proxy container in the orchestration? | 1.6 shows a unified entry point already exists → lean towards not including one; none exists → lean towards including one. Explain the trade-offs in `optional-modules.md` before the user chooses | With only 1 externally exposed service, do not ask. State "not included" and the reason. Follow-up in the same batch: should the dev environment have a reverse proxy that merges the services onto one port (independent of whether production includes one) |
| 7.2 | Is a database backup script needed? | Recommended for production | Follow up: where backups are uploaded (Alibaba Cloud OSS / local only) and how many days to keep them |
| 7.3 | Is CI needed to build and push images automatically? | No (manual first) | Yes → follow up on the platform (GitHub Actions and the like) and the trigger (tag push / push to the main branch) |
| 7.4 | Is an interactive menu (TUI) needed? | No | The templates default to CLI subcommands. For a TUI, add a menu layer on top |

## Batch 8: Open-source release (condition: 0.1 = open source)

| # | Question | Recommended default | Notes |
|---|---|---|---|
| 8.1 | What are the Docker Hub namespace and repository name? | `<username>/<slug>` | Follow up on whether the Docker Hub token and the CI secrets are already configured. If not → go through the "Docker Hub setup guide" in `open-source-route.md` |
| 8.2 | Which CPU architectures does the image support? | `linux/amd64` only | Can add `linux/arm64` and others. Explain the trade-off: multi-architecture covers ARM servers and Apple Silicon users, at the cost of a noticeably longer CI build, and native modules in the dependencies may need extra handling |
| 8.3 | Which file is the source of truth for the version number? | The detected manifest file (`package.json` and the like) | It is the single source of truth. The tag and the install script's version number must both match it |
| 8.4 | What is the installed command called? What are the default install directory and default port? | Command name = slug; directory `/opt/<slug>`; port: an uncommon high port | Pick a port that avoids common services and the kernel's ephemeral port range (on Linux usually from 32768) |
| 8.5 | Where is the install script downloaded from? | The raw URL on the default branch of the code hosting platform | Remind the user: a script change pushed to the default branch takes effect for new users at once |
| 8.6 | Besides directory, port, listen address, run identity and time zone, what else should the install wizard ask? | The required settings detected (admin password, external service addresses and the like) | Confirm for each: default value, whether required, whether sensitive |
| 8.7 | Which address is used for the readiness check? | The detected health check endpoint | After startup, poll it until it returns 200 |
| 8.8 | Which advanced capabilities does the install script need? (multi-select) | None; start with the core version | For the options see "Advanced options" in `open-source-route.md`. Write the chosen ones as needed |
| 8.9 | Sync the Docker Hub repository description? Generate a smoke test for the install script? | Both | The description document defaults to `docker/DOCKERHUB.md` |

## Placeholder reference

| Placeholder | Source | Example |
|---|---|---|
| `{{PROJECT_SLUG}}` | 1.2 | `my-shop` |
| `{{PREFIX}}` | 1.2 short prefix | `shop` |
| `{{TARGET_PLATFORM}}` | (private route) 1.4, a single platform | `linux/amd64` |
| `{{DEPLOY_DIR}}` | 2.1, relative to the project root | `deploy` |
| `{{SCRIPT_TO_ROOT}}` | 2.2, relative path from the script directory to the project root | `..` |
| `{{ENV_FILE}}` | 2.3, location of `.env` on the server; relative to the project root, or an absolute path | `.env` or `/mnt/data/my-shop/secrets/env` |
| `{{ENV_NAME}}` | The environment this script manages | `prod` / `intranet` |
| `{{SERVICES}}` | (private route) the services that **have their own image**, space-separated. Background job containers that share another service's image are not listed | `server web` |
| `{{SERVICES_CSV}}` | The service inventory, comma-separated (for the CI matrix) | `server, web` |
| `{{SERVICE_SRC}}` | Source directory of the service, relative to the project root; `.` when the source is in the project root | `backend` |
| `{{SERVICE}}` | One service name (in the compose templates, the whole block is copied once per service) | `server` |
| `{{CONTAINER_PORT}}` / `{{HOST_PORT}}` / `{{GRAY_HOST_PORT}}` | 3.2, 3.3 | `8080` / `18080` / `18180` |
| `{{BIND_ADDR}}` | 3.4, including the trailing colon; empty string when binding all addresses | `127.0.0.1:` |
| `{{DATA_ROOT}}` | 2.4, data root directory of this environment; inside the repo, a path relative to the compose file | `./data` or `/mnt/data/my-shop/data` |
| `{{SECRETS_DIR}}` | 2.4, same | `./secrets` or `/mnt/data/my-shop/secrets` |
| `{{WRITABLE_DIRS}}` | Directories the application container writes, relative to the data root, space-separated. Write `directory:uid` when the uid differs from the default | `logs uploads web_cache:101` |
| `{{PLAIN_DIRS}}` | Directories that are only created, with no ownership change: read-only config directories, and data directories of third-party images such as databases | `config db_data` |
| `{{GRAY_DATA_ROOT}}` | Gray's own config and log root directory | `./data` or `/mnt/data/my-shop/gray` |
| `{{DB_DATA_PATH}}` | Data path inside the database image's container, taken from the image documentation of the chosen major version | `/var/lib/postgresql/data` |
| `{{SECRET_NAMES}}` | 5.5, names of the secrets that need a random password, space-separated; empty when there are none | `postgres_password app_password backup_password` |
| `{{RUN_UID}}` | 3.5, uid of the user the container runs as; `0` for root in the container | `1001` |
| `{{REGISTRY_PUBLIC}}` / `{{REGISTRY_VPC}}` | 4.2, 4.4 | `registry.cn-hangzhou.aliyuncs.com` |
| `{{REGISTRY_NAMESPACE}}` | 4.3 | `myteam` |
| `{{DB_IMAGE}}` / `{{DB_HOST_PORT}}` | 5.3, 5.4 | `postgres:18` / `15432` |
| `{{GRAY_COOKIE}}` | 6.2 | `shop_beta` |
| `{{DOMAIN}}` | The user's domain | `example.com` |

Open-source route only:

| Placeholder | Source | Example |
|---|---|---|
| `{{APP_NAME}}` | 8.4 command name; also part of the container name, the script file name and the state file name | `my-shop` |
| `{{APP_ENV_PREFIX}}` | The command name in upper case with hyphens replaced by underscores; the prefix of the **install script's own** environment variables. When the application already uses the same prefix, check for name clashes first (the script uses `_HOME`, `_IMAGE`, `_VERSION`, `_BIN_DIR` and others). On a clash, give the script a different prefix | `MY_SHOP` |
| `{{DATA_CONTAINER_PATH}}` | Directory where the application reads and writes data inside the container | `/app/data` |
| `{{HUB_IMAGE}}` | 8.1 | `myteam/my-shop` |
| `{{TARGET_PLATFORMS}}` | 8.2, one or more platforms, comma-separated (not the same as the private route's `{{TARGET_PLATFORM}}`) | `linux/amd64,linux/arm64` |
| `{{SCRIPT_VERSION}}` | 8.3, the current version number | `0.1.0` |
| `{{VERSION_SOURCE}}` / `{{VERSION_READ_CMD}}` | 8.3, the source-of-truth file and one command that reads the version in CI | `package.json` / `node -p "require('./package.json').version"` |
| `{{DEFAULT_PORT}}` / `{{CONTAINER_PORT}}` | 8.4 / the service's container port | `28080` / `8080` |
| `{{RAW_BASE}}` | 8.5, without the branch name | `https://raw.githubusercontent.com/myteam/my-shop` |
| `{{SCRIPT_REPO_PATH}}` / `{{COMPOSE_REPO_PATH}}` | Paths of the install script and the release compose in the repository | `deploy/my-shop.sh` / `deploy/docker-compose.yml` |
| `{{HEALTH_PATH}}` | 8.7 | `/api/health` |
| `{{COMPOSE_BODY}}` | The full content of the release compose file, inserted byte for byte | — |
| `{{DEFAULT_BRANCH}}` | The repository's default branch; the install command and the script's self-download address both use it | `main` |
| `{{HUB_README_PATH}}` / `{{HUB_SHORT_DESCRIPTION}}` | 8.9; the short description is at most 100 characters | `docker/DOCKERHUB.md` |

A triple brace in a template, such as `${{{APP_ENV_PREFIX}}_HOME:-}`, is not a typo. The outermost `${…}` is shell or compose variable syntax. The `{{APP_ENV_PREFIX}}` inside it is the placeholder. After replacement it becomes `${MY_SHOP_HOME:-}`. The open-source route also uses `{{PROJECT_SLUG}}`, `{{PREFIX}}`, `{{DEPLOY_DIR}}`, `{{SCRIPT_TO_ROOT}}` and the others from the private route's table (the local dev templates need them).
