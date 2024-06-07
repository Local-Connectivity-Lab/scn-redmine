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

The redmine data is stored in a MySQL database, and can be backed up using standard `mysqldump`. However, this needs to be executed within the docker container, as below:
```
docker exec mariadb mysqldump -u root bitnami_redmine | gzip > redmine-`date +%Y-%m-%d`.gz
```
This will create a new backup with an SQL dump, gzipped and datestamped: `redmine-2024-06-07.gz`

To restore from a backup:
```
gzcat redmine-2024-06-07.gz | sudo docker exec -i -mariadb mysql -u root bitnami_redmine
```
This will used the SQL backup file to recreate the redmine database at the point the backup was created.


## Further Reading

* https://github.com/bitnami/containers/tree/main/bitnami/redmine#how-to-use-this-image
* https://bitnami.com/stack/redmine/containers
* https://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails
