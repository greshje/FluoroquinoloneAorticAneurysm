debugExecute <- function() {
  browser()
  testConnection <- DatabaseConnector::connect(connectionDetails)
}

debugonce(debugExecute)

debugExecute()

