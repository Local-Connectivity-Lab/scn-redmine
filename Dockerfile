FROM docker.io/bitnami/redmine:6

# Replace the english locales file with one that replaces "issue" with "ticket"
COPY en.yml /opt/bitnami/redmine/config/locales/en.yml
