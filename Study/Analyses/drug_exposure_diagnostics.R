if (run_drug_exposure_diagnostics == TRUE) {
  
  ded_ingredients <- all_concepts_counts %>%
    select(ingredient_name, concept_id)
  
  if(exists("top_ten_antibiotics")){
    
    ded_antibiotics <- top_ten_antibiotics %>%
      select(ingredient_name, concept_id)
    
  ded_names <- rbind(ded_ingredients, ded_antibiotics) %>%
    select(ingredient_name,concept_id) %>%
    distinct()
  } else {
    ded_names <- ded_ingredients %>%
      distinct()
  }
  
  cli::cli_alert_info("- Running drug exposure diagnostics") 
  
  drug_diagnostics <- executeChecks(
    cdm = cdm,
    ingredients = ded_names$concept_id,
    checks = c(
      "missing",
      "exposureDuration",
      "sourceConcept",
      "route",
      "dose",
      "quantity",
      "type"
    ),
    earliestStartDate = study_start,
    outputFolder = resultsFolder,
    filename = paste0("DED_Results_", db_name),
    minCellCount = min_cell_count
  )
  
  cli::cli_alert_success("- Finished drug exposure diagnostics")
}
