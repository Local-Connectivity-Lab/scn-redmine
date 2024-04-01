# scn-redmine
Redmine container for Seattle Community Network

This is intended to be the thinnest shim possible on top of the Bitnami redmine container (https://hub.docker.com/r/bitnami/redmine/)
to support receiving email via IMAP and secure storage of secrets. When possible, follow the Bitnami instructions.

This project will also act as an example of best practices for minimalist container-based projects with support tools to backup and recover container volumes and other documented operating procedures.

## Dependencies

### Docker

While this is intended to be a generic "container", it has only been tested with a standard
Docker Engine install on a Unbuntu Linux environment.

To install the necessary tools, see: https://docs.docker.com/engine/install/ubuntu/

The process is essentially:
```
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
```

## Operation

### Initial Setup

1. Clone the repo `https://github.com/Local-Connectivity-Lab/scn-redmine`.
```
git clone https://github.com/Local-Connectivity-Lab/scn-redmine redmine
cd redmine
```
2. Deploy into a standard Docker engine:
```
docker compose up --build -d
```
3. Login the first with the default credentials: `user`, pw:`bitnami1`
4. Create a user with administrator privlidges:
   1. Click **Administration** in the top menu.
   2. Click **Users** in the left-hand column.
   3. Click **New User** near the top, on the right hand side.
   4. Fill out the *Information* and *Authentication* forms, including the **Administrator** checkbox.
   5. Click **Create** to save the data and create the new user.
5. **Sign out** (top right) and login as the user you just created.
6. Delete the temporary `user` user:
   1. Go back to **Administration** -> **Users**
   2. On the line for the user `user`, client the **Delete** button.
   3. Enter the username `user` to validate.
   4. Click the **Delete** button.
7. [Create an `admin` bot user for netbot](https://github.com/Local-Connectivity-Lab/netbot/blob/main/docs/redmine.md) (if netbot is being used).
8. Create the "Discord ID" user custom field:
   1. Go to **Administration** -> **Custom Fields**
   2. Click **New custom field** near the top, on the right hand side.
   3. Select *Users* and click **Next**.
   4. For *Name* enter `Discord ID`
   5. Click the **Used as a filter** checkbox
   6. Click **Create** to create the custom field.
9.  Create the "syncdata" custom field:
    1. Click **New custom field** near the top, on the right hand side.
    2. Select *Tickets* and click **Next**.
    3. For *Name* enter `syncdata`
    4. Click the **Used as a filter** checkbox
    5. Click the **Searchable** checkbox
    6. Click the **Bug**, **Feature**, **Support** checkboxs under *Trackers*
    7. Click **For all projects** under *Projects*.
    8. Click **Create** to create the custom field.
10. Create the "To/CC" user custom field...
    1. Click **New custom field** near the top, on the right hand side.
    2. Select *Tickets* and click **Next**.
    3. For *Name* enter `To/CC`
    4. Click the **Used as a filter** checkbox
    5. Click the **Searchable** checkbox
    6. Click the **Bug**, **Feature**, **Support** checkboxs under *Trackers*
    7. Click **For all projects** under *Projects*.
    8. Click **Create** to create the custom field.

### Standard Deployment

This process is used any time there is an update to the SCN Redmine container to deploy.

```
cd redmine
git pull
docker compose down
docker compose up --build -d
```

### Backup and Restore

The provided `cluster` script handles creating backups and restoring the cluster state from them.

To create a backup:
```
docker compose down
./cluster backup
docker compose up -d
```
This will create a file named `clustername-datestamp.tgz`, like: redmine-202308051251.tgz

To restore a cluster from backup:
```
docker compose down
./cluster restore redmine-202308051251.tgz
docker compose up -d
```

## Backup Process & Structure

The backup file is created by `cluster backup` is a gzipped tar file wrapping a gzipped tar file for each volume mentioned in the `docker-compose.yml`. It is automatically named with the cluster name (the parent directory of the compose yaml) and a to-the-minute precise datestamp.

The process for creating a backup:
1. Creating a new date-stamped dir from the parent-dir name (same as compose): name-YYYYMMDDHHMM
2. For each volume mentioned in the compose.yml
   2.1 Run an empty container, with the volume and the backup dir mounted
   2.2 Archive contents of volume: volume.tgz in the mounted backup dir, w/o parent-context
 3. tar-gzip the entire backyp dir into name-YYYYMMDDHHMM.tgz

Restoring the backup file with 'cluster restore backup-file.tgz'
1. Untar the backup file
2. For each tgz file in the backup:
   2.1 Confirm a matching entry in the compose file
   2.2 Run a simple container, mounting the volume and the backup
   2.3 Import the backup into the volume with tar on the specific volume
 3. Cleanup the backup dir (leaving the backup.tgz untouched)


## Further Reading

* https://github.com/bitnami/containers/tree/main/bitnami/redmine#how-to-use-this-image
* https://bitnami.com/stack/redmine/containers
* https://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails
* https://github.com/BretFisher/docker-vackup
