# Title     : TODO
# Objective : TODO
# Created by: peterli
# Created on: 28/8/2019

# Need to install sikfaan package if not present

library(devtools)
install()

# Load package
library(sikfaan)

bootstrap_table_names <- getTableNames("./data/raw/bootstrap.sql")
gigadb_local_develop_no_migration_table_names <- getTableNames("./data/raw/gigadb_local_develop_no_migration.sql")
gigadb_local_develop_with_migration <- getTableNames("./data/raw/gigadb_local_develop_with_migration.sql")
production_like_table_names <- getTableNames("./data/raw/production_like.sql")
gigadb_staging_wl_table_names <- getTableNames("./data/raw/gigadb_staging_wl.sql")

# Count number of tables in database schemas
length(bootstrap_table_names)
## [1] 52
length(gigadb_local_develop_no_migration_table_names)
## [1] 52
length(gigadb_local_develop_with_migration)
## [1] 53
length(production_like_table_names)
## [1] 53
length(gigadb_staging_wl_table_names)
## [1] 56

#########################################
# Compare table names between databases #
#########################################

# bootstrap_table_names contain the same tables as in gigadb_local_develop_no_migration_table_names
bootstrap_table_names %in% gigadb_local_develop_no_migration_table_names

# Tables in local GigaDB with migration not in local GigaDB before migration
gigadb_local_develop_with_migration[!gigadb_local_develop_with_migration %in% gigadb_local_develop_no_migration_table_names]
## [1] "tblmigration"

# Are the same tables in gigadb_local_develop_with_migration, in production_like_table_names?
gigadb_local_develop_with_migration %in% production_like_table_names

# What new tables are in gigadb_staging_wl_table_names compared to production_like_table_names
gigadb_staging_unique_wl_table_names <- gigadb_staging_wl_table_names[!gigadb_staging_wl_table_names %in% production_like_table_names]
## [1] "contribution"       "template_attribute" "template_name"

# What columns are in the database tables?
m <- getTableInfo("./data/raw/bootstrap.sql")
write.csv(m, file="./data/processed/bootstrap.csv", row.names=FALSE)

m <- getTableInfo("./data/raw/gigadb_local_develop_no_migration.sql")
write.csv(m, file="./data/processed/gigadb_local_develop_no_migration.csv", row.names=FALSE)

m <- getTableInfo("./data/raw/gigadb_local_develop_with_migration.sql")
write.csv(m, file="./data/processed/gigadb_local_develop_with_migration.csv", row.names=FALSE)

m <- getTableInfo("./data/raw/production_like.sql")
write.csv(m, file="./data/processed/production_like.csv", row.names=FALSE)

m <- getTableInfo("./data/raw/gigadb_staging.sql")
write.csv(m, file="./data/processed/gigadb_staging.csv", row.names=FALSE)

m <- getTableInfo("./data/raw/gigadb_staging_wl.sql")
write.csv(m, file="./data/processed/gigadb_staging_wl.csv", row.names=FALSE)


############################
# Analyse database schemas #
############################

bootstrap <- read.csv(file="./data/processed/bootstrap.csv", header=TRUE, sep=",")
local_dev_no_mig <- read.csv(file="./data/processed/gigadb_local_develop_no_migration.csv", header=TRUE, sep=",")
local_dev_with_mig <- read.csv(file="./data/processed/gigadb_local_develop_with_migration.csv", header=TRUE, sep=",")
prod_like <- read.csv(file="./data/processed/production_like.csv", header=TRUE, sep=",")
gigadb_staging <- read.csv(file="./data/processed/gigadb_staging.csv", header=TRUE, sep=",")
gigadb_staging_wl <- read.csv(file="./data/processed/gigadb_staging_wl.csv", header=TRUE, sep=",")

# Number of tables
length(unique(bootstrap[ ,1]))
## [1] 52

length(unique(local_dev_no_mig[ ,1]))
## [1] 52

length(unique(local_dev_with_mig[ ,1]))
## [1] 53

length(unique(prod_like[ ,1]))
## [1] 53

length(unique(gigadb_staging_wl[ ,1]))
## [1] 56

# Compare tables between database schemas
# Get dataset tables
m2 <- bootstrap[bootstrap[,1] == "dataset",]
m3 <- bootstrap[local_dev_no_mig[,1] == "dataset",]
# Are they equal?
identical(m2, m3)
## [1] TRUE

#####################################################################
# Investigate gigadb_staging_wl database against prod_like database #
#####################################################################

# Get table names for gigadb_staging_wl
gigadb_staging_wl_tables <- unique(gigadb_staging_wl[ ,1])
gigadb_staging_wl_tables <- as.character(gigadb_staging_wl_tables)
# Get table names for prod_like
prod_like_tables <- unique(prod_like[ ,1])
prod_like_tables <- as.character(prod_like_tables)

# Compare databases
out <- compareTables(older, newer)
out <- compareTables(bootstrap, local_dev_no_mig)
out <- compareTables(local_dev_no_mig, local_dev_with_mig)
out <- compareTables(bootstrap, local_dev_with_mig)
out <- compareTables(local_dev_with_mig, prod_like)
out <- compareTables(local_dev_with_mig, gigadb_staging)
out <- compareTables(prod_like, gigadb_staging_wl)

# Output file
write.table(out, file = "./output/out.tab", append = FALSE, quote = FALSE, sep = " ",
eol = "\n", row.names = FALSE, col.names = FALSE)