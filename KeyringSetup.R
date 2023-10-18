# ---
#
# KeyringSetup.R
# 
# ---

# Install keyring - one time operation ---------
# install.packages("keyring")

# --- R Version ---------------------
R.Version()
# --- Java Version ------------------
system("java -version")
# -----------------------------------

#
# functions to get databricks token (user will be prompted for keyring password)
#

getToken <- function () {
  return (
    keyring::backend_file$new()$get(
      service = "production",
      user = "token",
      keyring = "databricks_keyring"
    )
  )
}

#
# functions to get databricks token (user will be prompted for keyring password)
#

getUrl <- function () {
  url <- "jdbc:databricks://nachc-databricks.cloud.databricks.com:443/default;transportMode=http;ssl=1;httpPath=sql/protocolv1/o/3956472157536757/0123-223459-leafy532;AuthMech=3;UseNativeQuery=1;UID=token;PWD="
  return (
    paste(url, getToken(), sep = "")
  )  
}

options(sqlRenderTempEmulationSchema = "fluoroquinolone_temp")

connectionDetails <- DatabaseConnector::createConnectionDetails (
  dbms = "spark",
  connectionString = getUrl(),
  pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
)

# --- start test of connectionDetails -----------------------------------------------------------
testConnection <- DatabaseConnector::connect(connectionDetails)
testConnection 
DatabaseConnector::querySql(testConnection, "show tables in demo_cdm")
DatabaseConnector::disconnect(testConnection)
# --- end test of connectionDetails -------------------------------------------------------------


if (Sys.getenv("STRATEGUS_KEYRING_PASSWORD") == "") {
  # set keyring password by adding STRATEGUS_KEYRING_PASSWORD='sos' to renviron
  usethis::edit_r_environ()
  # then add STRATEGUS_KEYRING_PASSWORD='sos', save and close
  # Restart your R Session to confirm it worked
  stop("Please add STRATEGUS_KEYRING_PASSWORD='sos' to your .Renviron file 
       via usethis::edit_r_environ() as instructed, save and then restart R session")
}

# Provide your environment specific values ------
dbms <- "spark"
connectionString <- "jdbc:databricks://nachc-databricks.cloud.databricks.com:443/default;transportMode=http;ssl=1;httpPath=sql/protocolv1/o/3956472157536757/0123-223459-leafy532;AuthMech=3;UseNativeQuery=1"
username <- "token"
password = getToken()


# Run the rest to setup keyring ----------
##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
keyringName <- "sos-challenge"
keyringPassword <- "sos" # This password is simply to avoid a prompt when creating the keyring

# Create the keyring if it does not exist.
# If it exists, clear it out so we can re-load the keys
allKeyrings <- keyring::keyring_list()
if (keyringName %in% allKeyrings$keyring) {
  if (keyring::keyring_is_locked(keyring = keyringName)) {
    keyring::keyring_unlock(keyring = keyringName, password = keyringPassword)
  }  
  # Delete all keys from the keyring so we can delete it
  message(paste0("Delete existing keyring: ", keyringName))
  keys <- keyring::key_list(keyring = keyringName)
  if (nrow(keys) > 0) {
    for (i in 1:nrow(keys)) {
      keyring::key_delete(keys$service[i], keyring = keyringName)
    }
  }
  keyring::keyring_delete(keyring = keyringName)
}
keyring::keyring_create(keyring = keyringName, password = keyringPassword)

# Store the the user-specific configuration -----
keyring::key_set_with_value("dbms", password = dbms, keyring = keyringName)
keyring::key_set_with_value("connectionString", password = connectionString, keyring = keyringName)
keyring::key_set_with_value("username", password = username, keyring = keyringName)
keyring::key_set_with_value("password", password = password, keyring = keyringName)

# Print the values to confirm the configuration
message("Keyring values set as:")
keys <- c("dbms", "connectionString", "username", "password")
for (i in seq_along(keys)) {
  message(paste0(" - ", keys[i], ": ", keyring::key_get(keys[i], keyring = keyringName)))
}


# --- start test of connectionDetails -----------------------------------------------------------
testConnection <- DatabaseConnector::connect(connectionDetails)
testConnection 
DatabaseConnector::querySql(testConnection, "show tables in demo_cdm")
DatabaseConnector::disconnect(testConnection)
# --- end test of connectionDetails -------------------------------------------------------------


