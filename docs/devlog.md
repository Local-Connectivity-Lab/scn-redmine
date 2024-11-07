# SCN Redmine Development Log

As this project will probably get more attention soon, it seems approaite to keep better development documentation code to the code.

## 2025-11-07

When discussing putting the redmine server on the internet, it seemed prudent to address some security issues before going fully public.

First task: **Making sure all services use strong passwords, and passwords are stored securely.**


### Research

* https://docs.docker.com/compose/how-tos/use-secrets/
* https://anujnair.com/blog/19-using-docker-secrets-with-a-vaultwarden-mysql-setup
* https://github.com/dani-garcia/vaultwarden/discussions/3462
* https://github.com/bitnami/containers/tree/main/bitnami/redmine#configuration


> You can append `_FILE` to all the supported env variables and it will use the contents of the file as value.

1. Step 1: Update all secure passwords and tokens to use files, as per https://docs.docker.com/compose/how-tos/use-secrets/.
2. Step 2: Can those files be pulled from vault-warden? This would require secure access to vaultwarden. could be based on:
    1. by hand: docs say which files, copy into place or create by hand.
    2. ansible script, run by authorized user, to copy needed files to standard location on host, referenced from compose yaml.
    3. (hand wavy) some sort of automation to pull from vault-warden on compose run. perhaps a "secrets build" process that GETs required secret files into the correct location.

Assuming no automation, the new deployment process would be:

Assumptions:
- secret vault, referred to as "the vault". SCN is using https://github.com/dani-garcia/vaultwarden

Process:
- Clone this project
- Create the following secret files:
	- `redmine_db_password.txt`
	- `redmine_smtp_password.txt`
	- `redmine_imap_password.txt`
- Start the service with: `docker compose up --build -d`
- (complete initial setup)


TODOs for password migration:
- [ ] generate new passwords, and store in vaultwarden, for:
    - [ ] redmine db password for `bn_redmine`
    - [ ] redmine db root user password
- [ ] create password files for existing secrets in vaultwarden:
    - [ ] `REDMINE_SMTP_PASSWORD`
    - [ ] `REDMINE_IMAP_PASSWORD`
- [ ] update values in [compose.yml](https://github.com/Local-Connectivity-Lab/scn-redmine/blob/main/docker-compose.yml) to read from files (and commit):
    - [ ] `REDMINE_DATABASE_PASSWORD` -> `redmine_db_password.txt`
    - [ ] `REDMINE_SMTP_PASSWORD` -> `redmine_smtp_password.txt`
    - [ ] `REDMINE_IMAP_PASSWORD` -> `redmine_imap_password.txt`
    - [ ] 
- [ ] copy password files to target host
- [ ] pull latest on target host
- [ ] perform full deployment, confirm everything comes up.
