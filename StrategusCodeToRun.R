# install the network package
# install.packages('remotes')
# remotes::install_github("OHDSI/Strategus", ref="results-upload")
library(Strategus)
library(checkmate)

##=========== START OF INPUTS ==========
connectionDetailsReference <- "Jmdc"
workDatabaseSchema <- 'fluoroquinolone_scratch'
cdmDatabaseSchema <- 'covid_ohdsi'
outputLocation <- 'D:/FloroquinoloneOutput'
minCellCount <- 5
cohortTableName <- "sos_fq_aa"

# --- start test of connectionDetails -----------------------------------------------------------
testConnection <- DatabaseConnector::connect(connectionDetails)
testConnection 
DatabaseConnector::querySql(testConnection, "show tables in demo_cdm")
DatabaseConnector::disconnect(testConnection)
# --- end test of connectionDetails -------------------------------------------------------------


##=========== END OF INPUTS ==========
##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/analysisSpecification.json"
)

storeConnectionDetails(
  connectionDetails = connectionDetails,
  connectionDetailsReference = connectionDetailsReference,
  keyringName = "sos-challenge"
)

executionSettings <- createCdmExecutionSettings(
  connectionDetailsReference = connectionDetailsReference,
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, connectionDetailsReference, "strategusWork"),
  resultsFolder = file.path(outputLocation, connectionDetailsReference, "strategusOutput"),
  minCellCount = minCellCount
)

# Note: this environmental variable should be set once for each compute node
Sys.setenv("INSTANTIATED_MODULES_FOLDER" = file.path(outputLocation, "StrategusInstantiatedModules"))

execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  executionScriptFolder = file.path(outputLocation, connectionDetailsReference, "strategusExecution"),
  keyringName = "sos-challenge"
)


