
#' Tabular Statistics Based on Formulas
#'
#' This function acts as an overlay for functions that produce tabular statistics 
#' through an interface utilizing the [ModelMatrix()] function and its `formula` parameter. 
#' Each table (individual statistic) is defined by a formula. The output is a single `data.frame` 
#' that contains the results for all tables.
#' 
#' To ensure full control over the generated output variables, `table_fun` is called with `avoid_hierarchical` 
#' or `avoidHierarchical` set to `TRUE`. Desired variables in the output are achieved using 
#' `substitute_vars`, `auto_collapse`, and `collapse_vars`.
#' 
#' If `table_fun` automatically uses [Extend0()], the parameter `hierarchical_extend0` 
#' specifies the `hierarchical` parameter in [Extend0()] via [Extend0fromModelMatrixInput()]. 
#' When `hierarchical_extend0` is `TRUE`, hierarchies are generated automatically.
#' By default, it is set to `TRUE`, preventing excessive data extension and aligning with 
#' the default behavior of [Formula2ModelMatrix()], where `avoidHierarchical = FALSE`.
#' 
#' Note: The use of `total_collapse` internally allows handling of variable names not present in the data. 
#' This ensures flexibility when modifying the `table_formulas` parameter.
#'
#' @param data The input data to be processed by `table_fun`.
#' @param table_fun The table-producing function to be used.
#' @param ...  Additional arguments passed to `table_fun`.
#' @param table_formulas A named list of formulas, where each entry defines a specific table.  
#' @param substitute_vars Allows formulas in `table_formulas` to be written in a simplified way. 
#'                        If `substitute_vars` is specified, the final formulas are generated 
#'                        using [substitute_formula_vars()] with `substitute_vars` as input.
#' @param auto_collapse Logical. If `TRUE`, variables are collapsed using [total_collapse()] 
#'                      with the `variables` parameter according to `substitute_vars`.             
#' @param collapse_vars When specified, [total_collapse()] is called with `collapse_vars` as the `variables` parameter, 
#'                      after any call triggered by the `auto_collapse` parameter.
#' @param total A string used to name totals. Passed to both `table_fun` and [total_collapse()].  
#' @param hierarchical_extend0 Controls automatic hierarchy generation for [Extend0()]. 
#'                              See "Details" for more information. 
#'
#' @return A single `data.frame` containing results for all tables defined in `table_formulas`.
#' @export
#' 
#' @seealso \code{\link{filter_by_variable}}
#'
#' @examples
#' tables_by_formulas(SSBtoolsData("magnitude1"),
#'                    table_fun = model_aggregate, 
#'                    table_formulas = list(table_1 = ~region * sector2, 
#'                                          table_2 = ~region1:sector4 - 1, 
#'                                          table_3 = ~region + sector4 - 1), 
#'                    substitute_vars = list(region = c("geo", "eu"), region1 = "eu"), 
#'                    collapse_vars = list(sector = c("sector2", "sector4")), 
#'                    sum_vars = "value", 
#'                    total = "T")
tables_by_formulas <- function(data,
                               table_fun, 
                               ..., 
                               table_formulas, 
                               substitute_vars = NULL,
                               auto_collapse = TRUE,
                               collapse_vars = NULL, 
                               total = "Total",
                               hierarchical_extend0 = TRUE) {
  
  if (length(substitute_vars)) {
    for (i in seq_along(table_formulas)) {
      table_formulas[[i]] <- substitute_formula_vars(table_formulas[[i]], substitute_vars)
    }
    substitute_vars_removed <- remove_included_substitute_elements(substitute_vars) 
  }
  
  formula <- combine_formulas(table_formulas)
  
  a <- table_fun(data, ..., 
                 formula = formula, 
                 avoid_hierarchical = TRUE, avoidHierarchical = TRUE, 
                 total = total, 
                 hierarchical_extend0 = hierarchical_extend0)
  
  # Extract all attributes except names, class, and row.names
  preserved_attrs <- attributes(a)
  preserved_attrs <- preserved_attrs[setdiff(names(preserved_attrs), c("names", "class", "row.names"))]
  
  table_indicators <- as.data.frame(matrix(NA, nrow(a), length(table_formulas)))
  names(table_indicators) <- names(table_formulas)
  
  for (i in seq_along(table_formulas)) {
    table_indicators[[i]] <- formula_selection(a, table_formulas[[i]], logical = TRUE)
  }
  
  if (auto_collapse & length(substitute_vars)) {
    a <- total_collapse_allow_missing(a, substitute_vars_removed, total = total) 
  }
  
  if (length(collapse_vars)) {
    a <- total_collapse_allow_missing(a, collapse_vars, total = total) 
  }
  
  a <- cbind(a, table_indicators)

  # Restore the preserved attributes if they do not already exist
  for (attr_name in names(preserved_attrs)) {
    if (is.null(attr(a, attr_name))) {
      attr(a, attr_name) <- preserved_attrs[[attr_name]]
    }
  }
  
  a
  
}

# remove_included_substitute_elements(list(region = c("geo", "eu"), region1 = "eu"))
## list(region = c("geo", "eu"))
# remove_included_substitute_elements(list(region = c("geo", "eu"), region1 = c("geo", "geo2")))
## Error .... Problematic substitute_vars
remove_included_substitute_elements <- function(x) {
  
  x <- x[order(sapply(x, length), decreasing = TRUE)]
  y <- x
  
  for (i in seq_along(y)) {
    y[[i]] <- rep(names(y)[i], length(y[[i]]))
  }
  
  y <- unlist(y)
  d <- duplicated(unlist(x))
  
  if (nrow(unique(cbind(y, d))) > length(x)) {
    stop("Problematic substitute_vars")
  }
  
  keep <- unique(y[!d])
  
  x[keep]
} 

# Allow variables not found in data
total_collapse_allow_missing <- function(data, variables, ...) {
  for (i in seq_along(variables)) {
    variables[[i]] <- variables[[i]][variables[[i]] %in% names(data)]
  }
  variables <- variables[sapply(variables, length) > 0]
  if (!length(variables)) {
    return(data)
  }
  total_collapse(data, variables, ...)
}

