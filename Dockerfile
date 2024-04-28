FROM docker.io/bitnami/redmine:5.0.5-debian-11-r35

RUN apt-get update && apt-get install -y curl

# Replace the english locales file with one that replaces "issue" with "ticket"
COPY en.yml /opt/bitnami/redmine/config/locales/en.yml
