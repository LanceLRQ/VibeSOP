# Optional modules

Ask the user first whether each module is wanted. For one that is not wanted, write "not enabled" and the reason in the decision table.

## Reverse proxy

### Trigger condition

Only 1 externally exposed HTTP service → **do not ask and do not build one in**. Tell the user: "There is only one externally exposed service, so expose its port directly. There is no need to add a proxy layer in the orchestration. Leave the domain and HTTPS to the entry point that already exists on the server."

2 or more externally exposed HTTP services (typically: backend API + frontend + admin console + a few small tools) → ask the user whether to include a reverse proxy container in compose, and explain the trade-offs below.

### Trade-offs to explain to the user

**Built-in reverse proxy container**

- Pros: only one port is exposed externally. Routing rules (`/api` to the backend, `/` to the frontend, …) are committed with the code and start and stop with the environment. The services are same-origin, so no CORS configuration is needed. The whole set moves with the project when the server changes
- Cons: one more container and one more configuration to maintain. If the server already has a unified entry point (host Nginx, OpenResty, Baota, a cloud load balancer), this makes two proxy layers: troubleshooting has one more hop, and the real IP and protocol headers must be passed through layer by layer. It also needs thinking through which layer holds the HTTPS certificate

**Not built in; the entry point the server already has proxies everything**

- Pros: several projects on one machine share one entry point, so certificates, rate limiting and logs are managed in one place. One layer less
- Cons: the routing rules are not in this repository, so they must be set up again when the server changes. Every service takes a host port. This project provides only a reference configuration, and the configuration that actually takes effect lives elsewhere

### Follow-up questions

- Does the server already have a unified entry point? If yes → lean towards not building one in, and generate only a reference configuration
- Who is responsible for the HTTPS certificate?
- Should the dev environment also have a reverse proxy that merges the frontend and backend onto one port? (The dev proxy and whether production builds one in are two independent decisions)

### Generation

- Built in: add the proxy service to compose and put its configuration in `<DEPLOY_DIR>/<env>/proxy/`. Only the proxy binds a host port; the other services no longer map ports
- Not built in: put the reference configuration at `<DEPLOY_DIR>/<env>/proxy/default.conf.example`, with a header line saying "for reference only, not used as a container"
- Pass-through headers: `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto`. Add `Upgrade` / `Connection` when there are WebSockets. Set a request body size limit according to the project's upload needs

### Gray traffic split

When gray is chosen and traffic is split by cookie, use `templates/nginx-gray-split.conf.template`. The split happens at the **outermost entry point**. If the user has a unified entry point on the host, the split configuration belongs to that layer, not to the built-in container.

Let the user choose the path of the switch entry, one that is hard to guess. Remind them that this entry is only a switch for "who can see gray", not a security boundary.

## Databases and middleware

The rules are in `environments.md`. Key points for generation:

- A separate compose, with a fixed-name network
- Passwords use docker secrets (`<name>_password.txt`, one password per file), and the initialization script reads them from `/run/secrets/`
- The initialization script that runs on first start creates: an application account (not a superuser) + the application database + a backup-only account
- When a cache or queue needs a password or ACL, the configuration file ships as `*.example` and the real file is ignored
- Migration subcommands: `db migrate` / `db status`, filled in for the detected migration tool. The connection string is read from `.env`

When the user uses a cloud database: do not generate a database compose. Only state in the deploy README where the connection configuration is filled in and which machine must be allowed in the whitelist.

## Backup and restore

Follow up on: what to back up (database / upload directory), where to store it (local only / object storage), how long to keep it, and how to trigger it (manual / cron).

Generate a separate `backup.sh` with the subcommands `dump`, `list`, `restore`, `cleanup`. Key points:

- Use a **dedicated backup account**. Read its password from a secret file; do not write it into configuration
- Run the dump tool from an image of the same version as the database, to avoid a version mismatch with the client on the host
- Backup files carry a timestamp, and a checksum is generated at the same time
- When uploading to object storage, the credentials go into an ignored configuration file. Provide an `*.example`
- `restore` must ask for a second confirmation, and the prompt must state which database will be overwritten
- Configure the retention days of local and remote backups separately
- Give a cron example, but **do not install the crontab for the user**
- Tell the user plainly: a backup whose restore has never been rehearsed is not a backup. Recommend doing one restore drill

## CI builds

Follow up on: the platform, the trigger (tag / push to the main branch), and whether it only builds and pushes or deploys as well.

By default it only does "build and push images". **Deployment stays a manual pull and restart on the server.** Tell the user this is a deliberate human gate. Automatic deployment needs a separate design (server credentials, rollback, gray order).

For the private route, GitHub Actions uses `templates/github-actions-build.yml.template` (pushes to a private image registry, optional). On the open-source route the release workflow is mandatory and uses `github-actions-dockerhub.yml.template`; see `open-source-route.md`. Key points:

- Image registry credentials go into the platform's encrypted Secrets, with names matching the variables in `.env`
- Use a matrix build for multiple services
- Tags stay consistent with the manual flow: version tag + `latest`
- After generating, remind the user to check whether the version of each Action used is the current latest major version
- For other platforms (GitLab CI, Gitea Actions and the like), write it from scratch with the same structure
