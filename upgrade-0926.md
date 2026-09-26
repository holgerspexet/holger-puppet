# insidan migration log — September 2026

Log of the migration of the Holgerspexet insidan server
(`insidan.holgerspexet.se`, formerly `holgerspexet.lysator.liu.se`) from
Ubuntu 18.04 + OpenProject 10 (deb) + the old puppet code to
Ubuntu 26.04 + OpenProject 17 (podman-compose) + modernized puppet
code.

Steps in the order they were performed. Each step lists the commands
that mattered and the things that bit us along the way.

---

## 1. Snapshot the old machine

Capture everything the old deb installation knows before touching it:

```bash
sudo openproject config:get SECRET_KEY_BASE > /root/old-secret
sudo openproject config:get DATABASE_URL
```

Also save: the `/etc/openproject/` directory, any file attachments
(`/var/openproject/assets`), and the hourly dumps in `/pg_dump/` that
the deb install's cron has been producing.

> **Lysator:** snapshotting/backup Lysator do for you, go there. 

## 2. Take a SQL dump and store it on a separate machine

The very first thing after the snapshot: dump the database and copy it
off the box.

```bash
pg_dump $(sudo openproject config:get DATABASE_URL) -x -O > openproject.sql
```

## 3. Uninstall the OpenProject package

The packager.io deb packages are dead on anything newer than 18.04.

```bash
systemctl stop openproject || true
systemctl disable openproject || true
mv /opt/openproject /opt/openproject-deb-old
```

Do not delete the old postgres data (`/var/lib/postgresql`) — that is
the rollback path if everything goes wrong. 

## 4. Stop the puppet cron

Disable the puppetfetcher cron so the hourly `git pull && puppet
apply` cannot run old code against a half-migrated machine. Easiest is
to comment out the cron entry (or `systemctl stop cron` for the
window). The cron comes back with the new puppet code — it is what
keeps the machine up to date afterwards.

## 5. OS upgrade (Ubuntu 18.04 → 26.04)

> **Lysator:** OS upgrades are something Lysator does for you if 
> you go there. I did and brought fika. 

`do-release-upgrade` only hops one LTS at a time, so plan for a chain:

```bash
do-release-upgrade    # 18.04 -> 20.04 -> 22.04 -> 24.04 -> 26.04
```

Then install OpenVox (the community puppet 8 build) — binaries end up
in `/opt/puppetlabs/bin`, same as puppet has always had:

```bash
wget https://apt.voxpupuli.org/openvox8-release-ubuntu26.04.deb
dpkg -i openvox8-release-ubuntu26.04.deb
apt update && apt install openvox-agent
```

**Fix the machine identity.** The new puppet code takes hostnames,
vhosts and certificate names from the `networking.fqdn` fact, and
puppet matches node blocks by certname. Both must be right:

```bash
hostnamectl hostname insidan.holgerspexet.se
# /etc/hosts: 127.0.1.1   insidan.holgerspexet.se   insidan
/opt/puppetlabs/bin/puppet config set certname insidan.holgerspexet.se --section main
```

## 6. Modernize the puppet code

This was a big one for me since we moved from deb to docker but might
be less of an issue in the future, depending on when its done.

## 7. Migrate the database ()


```bash
apt install podman podman-compose podman-docker 
systemctl enable --now podman.socket
docker version                     # the docker->podman shim must respond

./migrate-dump.sh openproject.sql  # -> openproject-migrated.sql.gz
```

The migrate step upgrades the dump major-version by major-version up
to the current OpenProject schema (with three local fixes for podman
and the legacy `openproject` schema layout — see the appendix).

## 8. Spin up puppet with the compose stack

```bash
cd /opt/holger-puppet && git pull
/opt/puppetlabs/bin/puppet apply --modulepath=/opt/holger-puppet/modules \
    /opt/holger-puppet/manifests/site.pp
```

Before starting the stack, put the **old
SECRET_KEY_BASE** into openprojects env file so existing sessions keep working:

```
SECRET_KEY_BASE=<value from step 1>
```

Puppet only creates the `.env` when it does not exist, so manual edits
persist. Then:

```bash
systemctl enable --now openproject
watch podman ps          # web becomes (healthy); seeder exits 0; first boot takes minutes
```

At this point you see an empty, freshly seeded OpenProject behind the
login screen.

## 9. Inject the database

```bash
cd /root/db-migration
./load-into-live.sh openproject-migrated.sql.gz
```

This injects the old databases data into the fresh upgraded instance.

## 10. Start insidan

After a successful load, restart the app containers and make sure
nginx is serving with the right certificate:

```bash
systemctl restart openproject
systemctl is-active nginx
```

## 11. Test

* **Log in** with an existing account. Password hashes are carried
  over (bcrypt in `user_passwords`), so old passwords should work.

---

## Appendix: the database migration toolkit

The toolkit lived on the lab machine in `/root/db-migration/` and was
rsynced to production for the final load. These file should still live on 
insidan.holgerspexet.se under migration-september-2026.

Copy of its README:

**Contents**

| Path | Purpose |
|------|---------|
| `bin/migrate` | Vendored, patched upstream `opf/openproject` `bin/migrate` (migrate a PG dump ≥ OP 10 to latest). |
| `lib/common.sh` | Logging, podman bootstrap, label-based container discovery. |
| `migrate-dump.sh` | Migrate a source dump → migrated dump, with strict checks. |
| `load-into-live.sh` | Load a migrated dump into the live podman-compose DB. Destructive; prompts for confirmation. |

**Local fixes applied to `bin/migrate`:** the legacy dump stores
objects in an `openproject` schema (moved to `public`); podman's
`docker inspect` lists `SecondaryIPAddresses: null` before
`IPAddress`; podman reports missing tags as `manifest unknown`.

**Prerequisites:** podman, `podman.socket`, and a `docker` CLI that
can talk to podman (`podman-docker` shim or docker-ce-cli with
`DOCKER_HOST=unix:///run/podman/podman.sock`, which `lib/common.sh`
sets automatically). Internet access to pull the OpenProject images
(15 → latest) during migration.

**Runbook:** dump the old database (plain SQL, PG ≥ 10) →
`./migrate-dump.sh <dump>` (validates gzip, PG header, `public.users`,
schema migration progress; logs to `migration-<timestamp>.log`) →
`./load-into-live.sh <migrated>.sql.gz` (stops app containers, drops
and recreates the DB, verifies row counts and schema_migrations,
restarts, waits for web health, checks `/login`).

**Caveats:** memcached warnings during migration are benign; password
hashes are carried over — reset a user's password once if a login does
not validate; only dumps with the `openproject` (non-`public`) schema
layout are supported by `migrate-dump.sh`.
