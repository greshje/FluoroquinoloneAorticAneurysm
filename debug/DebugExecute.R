debugExecute <- function() {
  browser()
  execute(
    analysisSpecifications = analysisSpecifications,
    executionSettings = executionSettings,
    executionScriptFolder = file.path(outputLocation, connectionDetailsReference, "strategusExecution"),
    keyringName = "sos-challenge"
  )  
}

debugonce(debugExecute)

debugExecute()

