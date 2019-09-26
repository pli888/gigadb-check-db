# gigadb-check-db

The GigaDB PostgreSQL database varies in its relational structure and contents
depending on the version of the `gigadb-website` code that is installed and also
its deployment environment which can be `dev`, `staging` and `production`.

Unfortunately, changes in the relational structure of the PostgreSQL database 
are not documented. Comparisons between databases are required to determine any
changes in the database tables. This repo is used for managing the analysis and 
results of GigaDB PostgreSQL database comparisons.

## sikfaan installation

This `gigadb-check-db` repo contains a git submodule called [sikfaan](https://github.com/pli888/sikfaan/tree/develop).
It provides a R package for performing comparisons of the GigaDB PostgreSQL 
database.
```
# Clone repo
$ git clone https://github.com/pli888/gigadb-check-db.git
$ cd gigadb-check-db
$ git submodule init
# Install sikfaan package
$ sudo R
R> library(devtools)
R> install()
```

Before using the package, it needs to be loaded into your R session:
```
library(sikfaan)
```

## SQL files

SQL file | Source
---------|-------
bootstrap.sql | Comes from `gigadb-website/ops/configuration/postgresql-conf/bootstrap.sql`
gigadb_local_develop_no_migration.sql | `develop` branch, db migration scripts not run
gigadb_local_develop_with_migration.sql | `develop` branch, db migration scripts executed
production_like.sql | Converted from `gigadb-website/sql/production_like.pgdmp`
gigadb_staging.sql | Downloaded from staging server containing rija db migrations
gigadb_staging_wl.sql | Downloaded from staging server containing WL and rija db migrations

### Creating gigadb_local_develop_no_migration.sql

```
# Ensure clean PostgreSQL database
$ rm -fr ~/.containers-data/gigadb
# Deploy a local GigaDB - this will deploy a deployment_database_1 container
$ docker-compose run --rm webapp
# Log into bash in the test container to get postgres dumps
$ docker-compose run --rm test bash
# Download sql dump - password is vagrant
$ pg_dump -U gigadb -h database -W -F plain gigadb > gigadb_local_develop_no_migration.sql
```

### Creating gigadb_local_develop_with_migration.sql

```
# Ensure clean PostgreSQL database
$ rm -fr ~/.containers-data/gigadb
# Deploy a local GigaDB - this will deploy a deployment_database_1 container
$ docker-compose run --rm webapp
# Run database migrations
$ docker-compose run --rm  application ./protected/yiic migrate --interactive=0
# Log into bash in the test container to get postgres dumps
$ docker-compose run --rm test bash
# Download sql dump - password is vagrant
$ pg_dump -U gigadb -h database -W -F plain gigadb > gigadb_local_develop_with_migration.sql
```

### Creating production_like.sql 
```
# Convert pgdump file to sql file
$ pg_restore -f gigadb-website/sql/production_like.sql production_like.pgdmp
```

### Creating gigadb_staging.sql 

Deploy a staging GigaDB using the GitLab CI pipeline and then perform the 
commands below:
```
# Log into the AWS EC2 server that is hosting the staging GigaDB
$ ssh -i "~/.ssh/aws-centos7-keys.pem" centos@ec2-xx-xxx-xxx-xxx.ap-southeast-1.compute.amazonaws.com
# Create sql file
$ pg_dump -U gigadb -h localhost -W -F plain gigadb > /home/centos/gigadb_staging.sql
# exit
$ sftp -i "~/.ssh/aws-centos7-keys.pem" centos@ec2-xx-xxx-xxx-xxx.ap-southeast-1.compute.amazonaws.com
$ get gigadb_staging.sql
```

### Creating gigadb_staging_wl.sql 

Deploy a staging GigaDB with the code for the data submission wizard using the 
GitLab CI pipeline and then perform the 
commands below:
```
# Log into the AWS EC2 server that is hosting the staging GigaDB with WL submission wizard
$ ssh -i "~/.ssh/aws-centos7-keys.pem" centos@ec2-xx-xxx-xxx-xxx.ap-southeast-1.compute.amazonaws.com
# Create sql file
$ pg_dump -U gigadb -h localhost -W -F plain gigadb > /home/centos/gigadb_staging_wl.sql
# exit
$ sftp -i "~/.ssh/aws-centos7-keys.pem" centos@ec2-xx-xxx-xxx-xxx.ap-southeast-1.compute.amazonaws.com
$ get gigadb_staging_wl.sql
```



