# Alibaba Cloud Container Registry (ACR) setup guide

When the user has not set this up or is unsure, **guide step by step** in the order below: explain one step, wait until the user has done it and reported the result, then explain the next. The console UI changes. When it does not match the description, ask the user for a screenshot or a description of what they see. Do not force the description onto it. The console labels below are in English; `glossary.md` lists the labels of the Chinese console.

## 1. Activate the service and create an instance

1. Log in to the Alibaba Cloud console, search for "Container Registry" and open it
2. Pick the region: **the same region as the server** (only the same region can pull over the VPC internal network)
3. Instance type:
   - **Personal edition**: free, with quota and rate limits and no SLA. Fits personal projects and small teams
   - **Enterprise edition**: paid, with its own domain, higher quota, security scanning and so on
   
   Tell the user the difference and let the user choose.

## 2. Set the login password

Under "Access Credentials", set a **fixed password**. This is the password used only for `docker login`. It differs from the Alibaba Cloud account login password.

The same page shows the login username and the login command:

- Main account: the username is the full Alibaba Cloud account name
- RAM sub-account: the username has the form `<sub-account-name>@<enterprise-alias>`

**Have the user copy the username shown in the console exactly. Do not guess it.**

For production, use a RAM sub-account that is granted only image registry permissions, not the main account. Tell the user this recommendation and let them decide.

## 3. Create a namespace

Under "Namespace", create one. The name is globally unique. It is usually a team or personal identifier.

While there, have the user confirm two settings:

- **Automatically create repositories**: when on, the first `docker push` creates the repository automatically, which saves creating them one by one
- **Default repository type**: private (unless images really must be public)

## 4. Note the image registry addresses

The instance's "Access Credentials" page or the repository detail page shows two addresses: public, and VPC (virtual private network). **Have the user copy them from the console.** Common forms:

| Type | Public address | VPC address |
|---|---|---|
| Personal edition (old instance) | `registry.<region>.aliyuncs.com` | `registry-vpc.<region>.aliyuncs.com` |
| Personal edition (new instance) | `crpi-xxxx.<region>.personal.cr.aliyuncs.com` | `crpi-xxxx-vpc.<region>.personal.cr.aliyuncs.com` |
| Enterprise edition | `<instance-name>-registry.<region>.cr.aliyuncs.com` | `<instance-name>-registry-vpc.<region>.cr.aliyuncs.com` |

- Build machines (a local computer, CI) push over the **public address**
- If the server is an Alibaba Cloud ECS in the same region, pull over the **VPC address**: it is faster, and no public traffic is billed
- A server that is not on Alibaba Cloud, or is in a different region, can only use the public address

## 5. Write the credentials into `.env`

```bash
REGISTRY_USERNAME=<username shown in the console>
REGISTRY_PASSWORD=<fixed password set in step 2>
REGISTRY_NAMESPACE=<namespace from step 3>
```

`.env` must already be ignored by `.gitignore`. In `.env.example`, keep only the variable names and leave the values empty.

The build machine and the server each have their own `.env`. Fill in both.

## 6. Verify

Have the user run this (once the scripts are generated, the `image login` subcommand works too):

```bash
echo "$REGISTRY_PASSWORD" | docker login --username "$REGISTRY_USERNAME" --password-stdin <public address>
```

`Login Succeeded` means success. Common failures:

| Symptom | Cause |
|---|---|
| `unauthorized: authentication required` | The Alibaba Cloud login password was used instead of the fixed password, or the username is not the one shown in the console |
| `no such host` | The address is mistyped. Old and new personal-edition instances use different domain formats |
| `denied: requested access to the resource is denied` on push | The namespace does not exist, automatic repository creation is off, or the RAM sub-account has no permission on the namespace |
| The VPC address is unreachable from the server | The server is not inside a VPC in the same region. Use the public address |

## Push and pull conventions (follow when generating scripts)

- Remote image name: `<image registry address>/<namespace>/<slug>-<service>:<tag>`
- Push: push both the version tag and `latest`
- After the server pulls, immediately create a local tag **without the image registry domain** (`<namespace>/<image name>:latest` or `:gray`). Compose references only the local tag. Then remove the tag reference that carries the registry domain. This way, switching between the public and VPC addresses does not affect compose, and gray promotion is only a local re-tag
- Always log in with `--password-stdin`. Never put the password in command-line arguments
