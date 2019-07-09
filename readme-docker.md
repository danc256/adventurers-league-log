# Overview

The purpose of this document is to get the application running as quickly as possible in a containerized (Docker) environment. As of this writing there are still unresolved issues getting it to run in 'production' mode but 'development' mode seems functional.

# Prerequisites

- Have the latest version of Docker / Docker Compose installed and ready to use
- Clone this repo to the machine running Docker Compose
- Create an account on [Sendgid](https://sendgrid.com/) and have your API key handy
- Copy the `.env.example-docker` file to `.env`
  - Populate `SENDGRID_USERNAME` with your username (defaults to 'apikey')
  - Populate `SENDGRID_PASSWORD` with your Sendgrid API key
  - Populate `SENDGRID_DOMAIN` with the domain from which app notification email is sent
  - Populate `DEVISE_MAILER_SENDER` with the email which notifications should come from
  - Change `ALL_DATABASE_USERNAME` and `ALL_DATABASE_PASSWORD` to more secure values (recommended but optional)
  - Change `APP_DOMAIN` to the FQDN of the host you expect to use to serve the app
  - Do not change any other values at this time
- **WARNING** You MUST leave the following values commented out during initialization or master key generation will fail
  - SECREY_KEY_BASE
  - RAILS_MASTER_KEY
  
# Initialization

You are going to perform a one-time initialization of the application before it can be used. Note that by default the database data volume is mapped to `.tmp/db` in the `docker-compose.yml` file. If you would prefere to put it somewhere else, modify this line in the `docker-compose.yml` file: 

`- ./tmp/db:/var/lib/postgresql/data`

## Bring Up All the Containers but Don't Start Rails
- `docker-compose run --service-ports app bash`
- You will be presented with a BASH shell prompt inside the `app` container
  
## Run This Command Twice
- `bundle exec rake secret`
- It will generate a long hexadecimal string on each invocation
- Uncomment SECRET_KEY_BASE in ‘.env’ and set it to the value of one of the secrets
- Store the other secret in DEVISE_SECRET_KEY in ‘.env'

## Generate the Rails Master Key

- `apt-get install -y vim`
- `RAILS_ENV=production EDITOR="vi" bin/rails credentials:edit`
- This will start the 'vi' editor (you can substitute the text editor of your choice)
- Modify the value of `secret_key_base` in the editor to have the same value you stored in `SECRET_KEY_BASE` in the `.env` file
- Save the file and exit the editor. This will generate `config/master.key` and also output the master key to the console
- Uncomment ‘RAILS_MASTER_KEY’ in ‘.env’ and set it to the value of the master key

## Bounce Docker

- We need to apply all the configuration changes made in the `.env` file
- CTRL-D (Exit the shell or use whatever way works for you)
- `docker-compose down`
- `docker-compose run --service-ports app bash`

## Initialize Database

- Back in the shell prompt run the following 4 commands in order:

```bash
bundle exec rake db:create db:migrate
bundle exec phil_columns seed -e development
bundle exec rake adventure_catalog:load
bundle exec rake adventure_catalog:clean_dupes
```

- CTRL-D (Exit the shell or use whatever way works for you)
- `docker-compose down`

## Start the App

- `docker-compose up -d`

You should now be able to point a browser at the `app` container port 3000. Example: `http://127.0.0.1:3000`

# Outstanding Issues

- Currently production doesn't work. May be due to missing configuration for Rails.
- Unsure why the 'production' environment must be forced during master key generation
- Database container provisioning should probably specify the entire file and not just append to it
- Contents of `credentials.yml.encrypted` not currently preserved during master key generation but possibly doesn't matter
