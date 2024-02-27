# scn-redmine
Redmine container for Seattle Community Network

This is intended to be the thinnest shim possible on top of the Bitnami redmine container (https://hub.docker.com/r/bitnami/redmine/)
to support receiving email via IMAP and secure storage of secrets. When possible, follow the Bitnami instructions.

This project will also act as an example of best practices for minimalist container-based projects with support tools to backup and recover container volumes and other documented operating procedures.

## Dependencies

This project depends on a standard Docker Engine install on a Linux environment. (tested on Unbuntu)

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
The `cluster` script relies on parsing the compose YAML file (`docker-compose.yml`), using a tool called `yq`, which can be installed with:
```
sudo snap install yq
```

## Usage

### Deploy

1. Clone the repo `https://github.com/philion/scn-redmine`.
2. Copy the `sample.env` file to `.env` and update the passwords:
```
git clone https://github.com/philion/scn-redmine redmine
cd redmine
cp sample.env .env
chmod 600 .env
```
3. Update the `.env` file with the correct passwords:
```
REDMINE_SMTP_PASSWORD=your_password
REDMINE_IMAP_PASSWORD=your_password
```
4. Deploy into a standard Docker engine:
```
./cluster up
```

### Backup and Restore

The provided `cluster` script handles creating backups and restoring the cluster state from them.

To create a backup:
```
./cluster backup
```
This will create a file named `clustername-datestamp.tgz`, like: redmine-202308051251.tgz

To restore a cluster from backup:
```
./cluster restore redmine-202308051251.tgz
```

### Standard Operation

The `cluster` script provides standard management operations:

```
cluster status        - what's the status of the cluster (default)
cluster up            - bring the entire cluster
cluster down          - bring the entire cluster down
cluster rebuild       - rebuild and start the cluster
cluster backup        - make a backup of the cluster
cluster restore <tgz> - restore a cluster from the given backup .tgz file
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
