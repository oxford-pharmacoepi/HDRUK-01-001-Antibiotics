if (run_incidence == TRUE) {
  cli::cli_alert_info("- Carry out age standardization for incidence using european standard population")

  ESP13 <- readr::read_csv(here("Analyses", "Age_standards", "ESP13.csv"),
    show_col_types = FALSE
  )

  ESP13_updated <- ESP13 %>%
    add_row(Agegroup = "0 to 17", ESP2013 = with(ESP13, sum(ESP2013[Agegroup == "0-4" | Agegroup == "5-9" |
      Agegroup == "10-14" | Agegroup == "15-19"]))) %>%
    add_row(Agegroup = "18 to 59", ESP2013 = with(ESP13, sum(ESP2013[Agegroup == "20-24" | Agegroup == "25-29" |
      Agegroup == "30-34" | Agegroup == "35-39" |
      Agegroup == "35-39" | Agegroup == "40-44" |
      Agegroup == "45-49" | Agegroup == "50-54" |
      Agegroup == "55-59"]))) %>%
    add_row(Agegroup = "60 to 150", ESP2013 = with(ESP13, sum(ESP2013[Agegroup == "60-64" | Agegroup == "65-69" |
      Agegroup == "70-74" | Agegroup == "75-79" |
      Agegroup == "80-84" | Agegroup == "85-89" |
      Agegroup == "90+"]))) %>%
    filter(Agegroup == "0 to 17" | Agegroup == "18 to 59" | Agegroup == "60 to 150")

  ESP13_updated <- ESP13_updated %>%
    rename(
      pop = ESP2013,
      denominator_age_group = Agegroup
    )

  agestandardizedinc <- list()

  # filter out to only include rates
  inc_std <- inc_tidy %>%
    filter(
      denominator_age_group != "0 to 150",
      denominator_sex == "Both",
      analysis_interval == "years",
      incidence_start_date != "overall"
    ) %>%
    mutate(age_standard = "Crude") %>%
    group_by(incidence_start_date, outcome_cohort_name, denominator_age_group, denominator_sex) %>%
    summarise(
      across(
        everything(),
        ~ first(na.omit(.), default = NA) # Pick the first non-NA value in each column
      ),
      .groups = "drop"
    )


  agestandardizedincf <- list()

  inc_std_F <- inc_tidy %>%
    filter(
      denominator_age_group != "0 to 150",
      denominator_sex == "Female",
      analysis_interval == "years",
      incidence_start_date != "overall"
    ) %>%
    mutate(age_standard = "Crude") %>%
    group_by(incidence_start_date, outcome_cohort_name, denominator_age_group, denominator_sex) %>%
    summarise(
      across(
        everything(),
        ~ first(na.omit(.), default = NA) # Pick the first non-NA value in each column
      ),
      .groups = "drop"
    )


  agestandardizedincm <- list()

  inc_std_M <- inc_tidy %>%
    filter(
      denominator_age_group != "0 to 150",
      denominator_sex == "Male",
      analysis_interval == "years",
      incidence_start_date != "overall"
    ) %>%
    mutate(age_standard = "Crude") %>%
    group_by(incidence_start_date, outcome_cohort_name, denominator_age_group, denominator_sex) %>%
    summarise(
      across(
        everything(),
        ~ first(na.omit(.), default = NA) # Pick the first non-NA value in each column
      ),
      .groups = "drop"
    )

  # overall population
  for (i in 1:length(table(inc_std$outcome_cohort_name))) {
    incidence_estimates_i <- inc_std %>%
      filter(outcome_cohort_name == names(table(inc_std$outcome_cohort_name)[i]))

    agestandardizedinc[[i]] <- dsr(
      data = incidence_estimates_i, # specify object containing number of deaths per stratum
      event = outcome_count, # column containing number of deaths per stratum
      fu = person_years, # column containing number of population per stratum person years
      subgroup = incidence_start_date,
      refdata = ESP13_updated, # reference population data frame, with column called pop
      method = "gamma", # method to calculate 95% CI
      sig = 0.95, # significance level
      mp = 100000, # we want rates per 100.000 population
      decimals = 2
    )

    agestandardizedinc[[i]] <- agestandardizedinc[[i]] %>%
      mutate(outcome_cohort_name = names(table(inc_std$outcome_cohort_name)[i]))

    cli::cli_alert_info(paste0("- european age standardization for ", names(table(inc_std$outcome_cohort_name)[i]), " complete"))
  }


  # females
  for (i in 1:length(table(inc_std_F$outcome_cohort_name))) {
    incidence_estimates_i <- inc_std_F %>%
      filter(outcome_cohort_name == names(table(inc_std_F$outcome_cohort_name)[i]))

    agestandardizedincf[[i]] <- dsr(
      data = incidence_estimates_i, # specify object containing number of deaths per stratum
      event = outcome_count, # column containing number of deaths per stratum
      fu = person_years, # column containing number of population per stratum person years
      subgroup = incidence_start_date,
      refdata = ESP13_updated, # reference population data frame, with column called pop
      method = "gamma", # method to calculate 95% CI
      sig = 0.95, # significance level
      mp = 100000, # we want rates per 100.000 population
      decimals = 2
    )

    agestandardizedincf[[i]] <- agestandardizedincf[[i]] %>%
      mutate(outcome_cohort_name = names(table(inc_std_F$outcome_cohort_name)[i]))

    cli::cli_alert_info(paste0("- european age standardization for ", names(table(inc_std_F$outcome_cohort_name)[i]), " FEMALES complete"))
  }

  # males
  for (i in 1:length(table(inc_std_M$outcome_cohort_name))) {
    incidence_estimates_i <- inc_std_M %>%
      filter(outcome_cohort_name == names(table(inc_std_M$outcome_cohort_name)[i]))

    agestandardizedincm[[i]] <- dsr(
      data = incidence_estimates_i, # specify object containing number of deaths per stratum
      event = outcome_count, # column containing number of deaths per stratum
      fu = person_years, # column containing number of population per stratum person years
      subgroup = incidence_start_date,
      refdata = ESP13_updated, # reference population data frame, with column called pop
      method = "gamma", # method to calculate 95% CI
      sig = 0.95, # significance level
      mp = 100000, # we want rates per 100.000 population
      decimals = 2
    )

    agestandardizedincm[[i]] <- agestandardizedincm[[i]] %>%
      mutate(outcome_cohort_name = names(table(inc_std_M$outcome_cohort_name)[i]))

    cli::cli_alert_info(paste0("- european age standardization for ", names(table(inc_std_M$outcome_cohort_name)[i]), " MALES complete"))
  }

  agestandardizedinc_final_esp <- bind_rows(agestandardizedinc) %>%
    mutate(cdm_name = db_name) %>%
    mutate(
      denominator_sex = "Both",
      denominator_age_group = "0 to 150",
      denominator_cohort_name = "denominator_cohort_23",
      cdm_name = db_name
    ) %>%
    as_tibble() %>%
    mutate(age_standard = "European Standard Population")


  agestandardizedinc_final_espf <- bind_rows(agestandardizedincf) %>%
    mutate(cdm_name = db_name) %>%
    mutate(
      denominator_sex = "Female",
      denominator_age_group = "0 to 150",
      denominator_cohort_name = "denominator_cohort_21",
      cdm_name = db_name
    ) %>%
    as_tibble() %>%
    mutate(age_standard = "European Standard Population")

  agestandardizedinc_final_espm <- bind_rows(agestandardizedincm) %>%
    mutate(cdm_name = db_name) %>%
    mutate(
      denominator_sex = "Male",
      denominator_age_group = "0 to 150",
      denominator_cohort_name = "denominator_cohort_19",
      cdm_name = db_name
    ) %>%
    as_tibble() %>%
    mutate(age_standard = "European Standard Population")

  agestandardizedinc_final_esp <- bind_rows(
    agestandardizedinc_final_esp,
    agestandardizedinc_final_espf,
    agestandardizedinc_final_espm
  )

  cli::cli_alert_info("- Age standardization for incidence using european standard population completed")


  cli::cli_alert_info("- Carry out age standardization for incidence using world standard population")

  WSP2000_2025 <- readr::read_csv(here("Analyses", "Age_standards", "WSP_2000_2025.csv"),
    show_col_types = FALSE
  )

  WSP2000_2025$WSP2000_2025 <- WSP2000_2025$WSP2000_2025 / 10

  # collapse WSP_2000_2025
  WSP2000_2025_updated <- WSP2000_2025 %>%
    add_row(Agegroup = "0 to 17", WSP2000_2025 = with(WSP2000_2025, sum(WSP2000_2025[Agegroup == "0-4" | Agegroup == "5-9" |
      Agegroup == "10-14" | Agegroup == "15-19"]))) %>%
    add_row(Agegroup = "18 to 59", WSP2000_2025 = with(WSP2000_2025, sum(WSP2000_2025[Agegroup == "20-24" | Agegroup == "25-29" |
      Agegroup == "30-34" | Agegroup == "35-39" |
      Agegroup == "35-39" | Agegroup == "40-44" |
      Agegroup == "45-49" | Agegroup == "50-54" |
      Agegroup == "55-59"]))) %>%
    add_row(Agegroup = "60 to 150", WSP2000_2025 = with(WSP2000_2025, sum(WSP2000_2025[Agegroup == "60-64" | Agegroup == "65-69" |
      Agegroup == "70-74" | Agegroup == "75-79" |
      Agegroup == "80-84" | Agegroup == "85-89" |
      Agegroup == "90 +"]))) %>%
    filter(Agegroup == "0 to 17" | Agegroup == "18 to 59" | Agegroup == "60 to 150")

  WSP2000_2025_updated <- WSP2000_2025_updated %>%
    rename(
      pop = WSP2000_2025,
      denominator_age_group = Agegroup
    )

  # create a loop for each cancer phenotype
  agestandardizedinc_wsp <- list()

  for (i in 1:length(table(inc_std$outcome_cohort_name))) {
    incidence_estimates_i <- inc_std %>%
      filter(outcome_cohort_name == names(table(inc_std$outcome_cohort_name)[i]))

    agestandardizedinc_wsp[[i]] <- dsr(
      data = incidence_estimates_i, # specify object containing number of deaths per stratum
      event = outcome_count, # column containing number of deaths per stratum
      fu = person_years, # column containing number of population per stratum person years
      subgroup = incidence_start_date,
      refdata = WSP2000_2025_updated, # reference population data frame, with column called pop
      method = "gamma", # method to calculate 95% CI
      sig = 0.95, # significance level
      mp = 100000, # we want rates per 100.000 population
      decimals = 2
    )

    agestandardizedinc_wsp[[i]] <- agestandardizedinc_wsp[[i]] %>%
      mutate(outcome_cohort_name = names(table(inc_std$outcome_cohort_name)[i]))

    cli::cli_alert_info(paste0("- world age standardization for ", names(table(inc_std$outcome_cohort_name)[i]), " complete"))
  }

  agestandardizedinc_wspf <- list()

  for (i in 1:length(table(inc_std_F$outcome_cohort_name))) {
    incidence_estimates_i <- inc_std_F %>%
      filter(outcome_cohort_name == names(table(inc_std_F$outcome_cohort_name)[i]))

    agestandardizedinc_wspf[[i]] <- dsr(
      data = incidence_estimates_i, # specify object containing number of deaths per stratum
      event = outcome_count, # column containing number of deaths per stratum
      fu = person_years, # column containing number of population per stratum person years
      subgroup = incidence_start_date,
      refdata = WSP2000_2025_updated, # reference population data frame, with column called pop
      method = "gamma", # method to calculate 95% CI
      sig = 0.95, # significance level
      mp = 100000, # we want rates per 100.000 population
      decimals = 2
    )

    agestandardizedinc_wspf[[i]] <- agestandardizedinc_wspf[[i]] %>%
      mutate(outcome_cohort_name = names(table(inc_std_F$outcome_cohort_name)[i]))

    cli::cli_alert_info(paste0("- world age standardization for ", names(table(inc_std_F$outcome_cohort_name)[i]), " FEMALES complete"))
  }

  # males
  agestandardizedinc_wspm <- list()

  for (i in 1:length(table(inc_std_M$outcome_cohort_name))) {
    incidence_estimates_i <- inc_std_M %>%
      filter(outcome_cohort_name == names(table(inc_std_M$outcome_cohort_name)[i]))

    agestandardizedinc_wspm[[i]] <- dsr(
      data = incidence_estimates_i, # specify object containing number of deaths per stratum
      event = outcome_count, # column containing number of deaths per stratum
      fu = person_years, # column containing number of population per stratum person years
      subgroup = incidence_start_date,
      refdata = WSP2000_2025_updated, # reference population data frame, with column called pop
      method = "gamma", # method to calculate 95% CI
      sig = 0.95, # significance level
      mp = 100000, # we want rates per 100.000 population
      decimals = 2
    )

    agestandardizedinc_wspm[[i]] <- agestandardizedinc_wspm[[i]] %>%
      mutate(outcome_cohort_name = names(table(inc_std_M$outcome_cohort_name)[i]))

    cli::cli_alert_info(paste0("- world age standardization for ", names(table(inc_std_M$outcome_cohort_name)[i]), " MALES complete"))
  }


  agestandardizedinc_wsp_final <- bind_rows(agestandardizedinc_wsp) %>%
    mutate(
      denominator_sex = "Both",
      denominator_age_group = "0 to 150",
      denominator_cohort_name = "denominator_cohort_23",
      cdm_name = db_name
    ) %>%
    as_tibble() %>%
    mutate(age_standard = "World Standard Population")

  agestandardizedinc_wsp_finalf <- bind_rows(agestandardizedinc_wspf) %>%
    mutate(
      denominator_sex = "Female",
      denominator_age_group = "0 to 150",
      denominator_cohort_name = "denominator_cohort_21",
      cdm_name = db_name
    ) %>%
    as_tibble() %>%
    mutate(age_standard = "World Standard Population")

  agestandardizedinc_wsp_finalm <- bind_rows(agestandardizedinc_wspm) %>%
    mutate(
      denominator_sex = "Male",
      denominator_age_group = "0 to 150",
      denominator_cohort_name = "denominator_cohort_19",
      cdm_name = db_name
    ) %>%
    as_tibble() %>%
    mutate(age_standard = "World Standard Population")

  agestandardizedinc_wsp_final <- bind_rows(
    agestandardizedinc_wsp_final,
    agestandardizedinc_wsp_finalf,
    agestandardizedinc_wsp_finalm
  )

  cli::cli_alert_success("- Age standardization for incidence using world standard population completed")

  agestandardized_results <- bind_rows(
    agestandardizedinc_final_esp,
    agestandardizedinc_wsp_final
  ) |>
    rename(
      outcome_count = n,
      denominator_count = d,
      incidence_crude = c_rate,
      incidence_crude_95CI_lower = c_lower,
      incidence_crude_95CI_upper = c_upper,
      incidence_standardised = s_rate,
      incidence_standardised_95CI_lower = s_lower,
      incidence_standardised_95CI_upper = s_upper
    ) |>
    mutate(outcome_count = as.double(outcome_count)) |>
    mutate(across(
      c(
        "outcome_count", "denominator_count", "incidence_crude", "incidence_crude_95CI_lower",
        "incidence_crude_95CI_upper", "incidence_standardised",
        "incidence_standardised_95CI_lower", "incidence_standardised_95CI_upper"
      ),
      \(x) if_else(outcome_count < min_cell_count & min_cell_count > 0, "-", as.character(x))
    )) |>
    pivot_longer(
      cols = c(
        "denominator_count", "outcome_count",
        "incidence_crude", "incidence_crude_95CI_lower",
        "incidence_crude_95CI_upper", "incidence_standardised",
        "incidence_standardised_95CI_lower", "incidence_standardised_95CI_upper"
      ),
      names_to = "estimate_name",
      values_to = "estimate_value"
    ) |>
    omopgenerics::uniteGroup(c("denominator_cohort_name", "outcome_cohort_name")) |>
    omopgenerics::uniteStrata() |>
    omopgenerics::uniteAdditional(c("incidence_start_date", "age_standard")) |>
    dplyr::mutate(
      result_id = 1L,
      estimate_type = "numeric",
      variable_name = ifelse(grepl("^(outcome|incidence)", estimate_name),
        "Outcome", "Denominator"
      ),
      variable_level = NA_character_
    ) |>
    select(
      result_id, cdm_name, group_name, group_level,
      strata_name, strata_level, variable_name, variable_level,
      estimate_name, estimate_type, estimate_value,
      additional_name, additional_level
    ) |>
    omopgenerics::newSummarisedResult(
      settings = omopgenerics::settings(inc) |>
        dplyr::select(
          "analysis_complete_database_intervals", "analysis_outcome_washout",
          "analysis_repeated_events", "denominator_time_at_risk"
        ) |>
        dplyr::distinct() |>
        dplyr::mutate(
          result_id = 1L,
          result_type = "incidence_summary",
          package_name = NA_character_,
          package_version = NA_character_,
        )
    )

  cli::cli_alert_success("- Age standardization for incidence completed")

  # Export the results -----

  results[["age_std_incidence"]] <- agestandardized_results

  write.csv(agestandardized_results,
    here::here(
      "Results",
      paste0("incidence_estimates_age_std_", db_name, ".csv")
    ),
    row.names = FALSE
  )

  cli::cli_alert_success("Incidence Analysis Complete")
}
