FROM docker.io/bitnami/redmine:5.0.5-debian-11-r35

# Replace the english locales file with one that replaces "issue" with "ticket"
COPY en.yml /opt/bitnami/redmine/config/locales/en.yml

