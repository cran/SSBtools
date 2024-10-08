

#' Model matrix from hierarchies and/or a formula
#' 
#' A common interface to \code{\link{Hierarchies2ModelMatrix}}, \code{\link{Formula2ModelMatrix}} and \code{\link{HierarchiesAndFormula2ModelMatrix}}
#' 
#' The default value of `removeEmpty` corresponds to the default settings of the underlying functions. 
#' The functions \code{\link{Hierarchies2ModelMatrix}} and \code{\link{HierarchiesAndFormula2ModelMatrix}} 
#' have `removeEmpty` as an explicit parameter with `FALSE` as default.
#' The function \code{\link{Formula2ModelMatrix}} is a wrapper for \code{\link{FormulaSums}}, 
#' which has a parameter `includeEmpty` with `FALSE` as default.
#' Thus, `ModelMatrix` makes a call to `Formula2ModelMatrix` with `includeEmpty = !removeEmpty`. 
#'   
#' `NamesFromModelMatrixInput` returns the names of the data columns involved in creating the model matrix.
#' Note that `data` must be non-NULL to convert dimVar as indices to names. 
#' 
#' The `select` parameter is forwarded to `Hierarchies2ModelMatrix` unless `removeEmpty = TRUE` is combined with `select` as a data frame.
#' In all other cases, `select` is handled outside the underlying functions by making selections in the result.
#' Empty columns can be added to the model matrix when `removeEmpty = FALSE` (with warning).
#' 
#' @param data Matrix or data frame with data containing codes of relevant variables
#' @param hierarchies List of hierarchies, which can be converted by \code{\link{AutoHierarchies}}.
#' Thus, the variables can also be coded by \code{"rowFactor"} or \code{""}, which correspond to using the categories in the data.
#' @param formula A model formula
#' @param inputInOutput Logical vector (possibly recycled) for each element of hierarchies.
#'         TRUE means that codes from input are included in output. Values corresponding to \code{"rowFactor"} or \code{""} are ignored.
#' @param crossTable Cross table in output when TRUE
#' @param sparse Sparse matrix in output when TRUE (default)
#' @param viaOrdinary When TRUE, output is generated by \code{\link{model.matrix}} or \code{\link[Matrix]{sparse.model.matrix}}.
#'                    Since these functions omit a factor level, an empty factor level is first added. 
#' @param total String(s) used to name totals 
#' @param removeEmpty When `TRUE`, empty columns (only zeros) are not included in output. 
#'                    Default is `TRUE` with formula input without hierarchy and otherwise `FALSE` (see details).      
#' @param modelMatrix The model matrix as input (same as output)
#' @param dimVar The main dimensional variables and additional aggregating variables. This parameter can be  useful when hierarchies and formula are unspecified.   
#' @param select Data frame specifying variable combinations for output 
#'               or a named list specifying code selections for each variable (see details). 
#' @param ... Further arguments to  \code{\link{Hierarchies2ModelMatrix}}, \code{\link{Formula2ModelMatrix}} or \code{\link{HierarchiesAndFormula2ModelMatrix}} 
#' 
#' @seealso  \link{formula_utils}    
#'
#' @return A (sparse) model matrix or a list of two elements (model matrix and cross table)
#' @export
#' @author Øyvind Langsrud
#' 
#' @examples
#' # Create some input
#' z <- SSBtoolsData("sp_emp_withEU")
#' ageHier <- data.frame(mapsFrom = c("young", "old"), mapsTo = "Total", sign = 1)
#' geoDimList <- FindDimLists(z[, c("geo", "eu")], total = "Europe")[[1]]
#' 
#' # Small dataset example. Two dimensions.
#' s <- z[z$geo == "Spain" & z$year != 2016, ]
#' rownames(s) <- NULL
#' s
#' 
#' # via Hierarchies2ModelMatrix() and converted to ordinary matrix (not sparse)
#' ModelMatrix(s, list(age = ageHier, year = ""), sparse = FALSE)
#' 
#' # Hierarchies generated automatically. Then via Hierarchies2ModelMatrix()
#' ModelMatrix(s[, c(1, 4)])
#' 
#' # via Formula2ModelMatrix()
#' ModelMatrix(s, formula = ~age + year)
#' 
#' # via model.matrix() after adding empty factor levels
#' ModelMatrix(s, formula = ~age + year, sparse = FALSE, viaOrdinary = TRUE)
#' 
#' # via sparse.model.matrix() after adding empty factor levels
#' ModelMatrix(s, formula = ~age + year, viaOrdinary = TRUE)
#' 
#' # via HierarchiesAndFormula2ModelMatrix() and using different data and parameter settings
#' ModelMatrix(s, list(age = ageHier, geo = geoDimList, year = ""), formula = ~age * geo + year, 
#'             inputInOutput = FALSE, removeEmpty = TRUE, crossTable = TRUE)
#' ModelMatrix(s, list(age = ageHier, geo = geoDimList, year = ""), formula = ~age * geo + year, 
#'             inputInOutput = c(TRUE, FALSE), removeEmpty = FALSE, crossTable = TRUE)
#' ModelMatrix(z, list(age = ageHier, geo = geoDimList, year = ""), formula = ~age * year + geo, 
#'             inputInOutput = c(FALSE, TRUE), crossTable = TRUE)
#'             
#' # via Hierarchies2ModelMatrix() using unnamed list element. See AutoHierarchies.             
#' colnames(ModelMatrix(z, list(age = ageHier, c(Europe = "geo", Allyears = "year", "eu"))))
#' colnames(ModelMatrix(z, list(age = ageHier, c("geo", "year", "eu")), total = c("t1", "t2")))
#' 
#' # Example using the select parameter as a data frame
#' select <- data.frame(age = c("Total", "young", "old"), geo = c("EU", "nonEU", "Spain"))
#' ModelMatrix(z, list(age = ageHier, geo = geoDimList), 
#'             select = select, crossTable = TRUE)$crossTable
#'             
#' # Examples using the select parameter as a list
#' ModelMatrix(z, list(age = ageHier, geo = geoDimList), inputInOutput = FALSE, 
#'             select = list(geo = c("nonEU", "Portugal")), crossTable = TRUE)$crossTable
#' ModelMatrix(z, list(age = ageHier, geo = geoDimList), 
#'             select = list(geo = c("nonEU", "Portugal"), age = c("Total", "young")), 
#'             crossTable = TRUE)$crossTable
#' 
#' # Using NAomit parameter avalable in Formula2ModelMatrix()
#' s$age[1] <- NA
#' ModelMatrix(s, formula = ~age + year)
#' ModelMatrix(s, formula = ~age + year, NAomit = FALSE)
#' 
ModelMatrix <- function(data, hierarchies = NULL, formula = NULL, inputInOutput = TRUE, crossTable = FALSE, 
                        sparse = TRUE, viaOrdinary = FALSE, total = "Total", 
                        removeEmpty = !is.null(formula) & is.null(hierarchies), 
                        modelMatrix = NULL, dimVar = NULL, select = NULL, ...) {
  
  if (!is.null(modelMatrix)) {
    
    sparseInput <- !inherits(modelMatrix, "matrix")    # sparseInput <- class(modelMatrix)[1] != "matrix"
    
    if (sparseInput & !sparse) 
      modelMatrix <- as.matrix(modelMatrix)
    
    if (!sparseInput & sparse) 
      modelMatrix <- Matrix(modelMatrix)
    
    if (!is.null(formula)) 
      warning("formula ignored when model matrix is supplied in input")
    
    if (!is.null(hierarchies)) 
      warning("hierarchies ignored when model matrix is supplied in input")
    
    if (is.logical(crossTable)) {
      if (crossTable) 
        warning("\"crossTable=TRUE\" ignored when model matrix is supplied in input. crossTable as data.frame input is possible.")
      return(modelMatrix)
    }
    return(list(modelMatrix = modelMatrix, crossTable = crossTable))
  }
  
  if (!is.null(dimVar) & is.null(hierarchies) & is.null(formula)) {
    data <- data[, dimVar, drop=FALSE]
  }
  
  if (viaOrdinary) {
    previous_na_action <- options("na.action")
    options(na.action = "na.pass")
    on.exit(options(na.action = previous_na_action$na.action))
    a <- ModelMatrixOld(data = data, hierarchies = hierarchies, formula = formula, 
                        inputInOutput = inputInOutput, crossTable = crossTable, 
                        sparse = sparse, viaOrdinary = viaOrdinary, 
                        total = total, removeEmpty = removeEmpty, select = select, ...)
    if (is.list(a)) {
      if (anyNA(a$modelMatrix)) 
        a$modelMatrix[is.na(a$modelMatrix)] <- 0
    } else {
      if (anyNA(a)) {     # With na.action='na.pass' and sparse = TRUE no NA's will be produced now (zeros instead) - package ‘Matrix’ version 1.2-11
        a[is.na(a)] <- 0  # Code here allow possible change in later versions
      }
    }
    return(a)
  }
  ModelMatrixOld(data = data, hierarchies = hierarchies, formula = formula, 
                 inputInOutput = inputInOutput, crossTable = crossTable, 
                 sparse = sparse, viaOrdinary = viaOrdinary, 
                 total = total, removeEmpty = removeEmpty, select = select, ...)
}





ModelMatrixOld <- function(data, hierarchies = NULL, formula = NULL,
                        inputInOutput = TRUE,
                        crossTable = FALSE, sparse = TRUE,
                        viaOrdinary = FALSE,
                        total = "Total",
                        removeEmpty = FALSE,
                        select,
                           ...) {
  
  if (is.null(formula) & is.null(hierarchies)) {
    hierarchies <- FindHierarchies(data, total = total)
  }
  
  if(viaOrdinary){
    if(!is.null(hierarchies) | crossTable | !is.null(select)){
      warning("viaOrdinary ignorded")
    } else {
      return(Model_Matrix(formula = formula, data = data, sparse = sparse)) 
    }
  }
  
  if (is.data.frame(select)) {
    ma <- Match(select, select)
    if (anyDuplicated(ma)) {
      ma <- ma[unique(ma)]
      warning("duplicate select rows removed")
      select <- select[ma, , drop = FALSE]  # Similar in Hierarchies2ModelMatrix without warning
    }
  }
  
  if (!is.null(select) &      # This is about handling select when this is not handled within the algorithm
      (!is.null(formula) |    # HierarchiesAndFormula2ModelMatrix or Formula2ModelMatrix
       (removeEmpty & is.data.frame(select)))) {   # Hierarchies2ModelMatrix ignores removeEmpty in this case 
    out <- ModelMatrixOld(data = data, hierarchies = hierarchies, formula = formula, 
                          inputInOutput = inputInOutput, 
                          crossTable = TRUE, 
                          sparse = sparse, 
                          viaOrdinary = FALSE, 
                          total = total,
                          removeEmpty = removeEmpty, 
                          select = NULL)
    if (is.data.frame(select)) {
      ma <- Match(select, out$crossTable)
      if (anyNA(ma)) {
        if (removeEmpty) {
          ma <- ma[!is.na(ma)]
        } else {
          m0 <- Matrix(0, nrow(out$modelMatrix), sum(is.na(ma)))
          colnames(m0) <- MatrixPaste(select[is.na(ma), , drop = FALSE], sep = "-")
          out$modelMatrix <- cbind(out$modelMatrix, m0)
          out$crossTable <- rbind(out$crossTable, select[is.na(ma), , drop = FALSE])
          ma <- Match(select, out$crossTable)
          warning("Non-matching select rows result in empties. Use removeEmpty=TRUE?")
        }
      }
    } else {
      selectNames <- names(select)
      if (any(!(selectNames %in% names(out$crossTable)))) {
        stop("Names of select must match crossTable names")
      }
      rows <- rep(TRUE, nrow(out$crossTable))
      for (i in seq_along(select)) {
        rows <- rows & (out$crossTable[[selectNames[i]]] %in% select[[i]])
        if (any(!(select[[i]] %in% out$crossTable[[selectNames[i]]]))) {
          warning("non-matching select codes ignored")
        }
      }
      ma <- which(rows)
    }
    out$modelMatrix <- out$modelMatrix[, ma, drop = FALSE]
    if (!crossTable) {
      return(out$modelMatrix)
    }
    out$crossTable <- out$crossTable[ma, , drop = FALSE]
    rownames(out$crossTable) <- NULL
    return(out)
  }
  
  
  if (!is.null(formula) & !is.null(hierarchies)) {
    a <- HierarchiesAndFormula2ModelMatrix(data = data, hierarchies = hierarchies, formula = formula, inputInOutput = inputInOutput, crossTable = crossTable, total = total, removeEmpty = removeEmpty, ...)
  }
  
  if (is.null(formula) & !is.null(hierarchies)) {
    a <- Hierarchies2ModelMatrix(data = data, hierarchies = hierarchies, inputInOutput = inputInOutput, crossTable = crossTable, total = total, removeEmpty = removeEmpty, select = select,  ...)
  }
  
  if (!is.null(formula) & is.null(hierarchies)) {
    a <- Formula2ModelMatrix(data = data, formula = formula, crossTable = crossTable, total=total, 
                             includeEmpty = !removeEmpty, ...)
  }
  
  if (crossTable) {
    if (!is.data.frame(a$crossTable)) {
      a$crossTable <- as.data.frame(a$crossTable)
    }
  }
  
  if(!sparse){
    if(crossTable){
      a$modelMatrix <- as.matrix(a$modelMatrix)
    } else {
      a <- as.matrix(a)
    }
  }
  a
}
  


#' Overparameterized model matrix
#'
#' All factor levels included
#' 
#' Example:
#' 
#' `z <- SSBtoolsData("sp_emp_withEU")`
#' 
#' `SSBtools:::Model_Matrix(~age*year + geo, z)`
#'   
#' @param formula formula
#' @param data data frame
#' @param mf model frame (alternative input instead of data)
#' @param allFactor When TRUE all variables are coerced to factor
#' @param sparse When TRUE sparse matrix created by sparse.model.matrix()
#'
#' @return model matrix created via model.matrix() or sparse.model.matrix()
#' @importFrom stats model.frame model.matrix
#' @importFrom Matrix sparse.model.matrix
#' 
#' @keywords internal
#'
Model_Matrix <- function(formula, data = NULL, mf = model.frame(formula, data = data), allFactor = TRUE, sparse = FALSE)  {
  
  for (i in 1:length(mf)) {
    if (allFactor)
      mf[[i]] <- as.factor(mf[[i]])
    if (is.factor(mf[[i]]))
      mf[[i]] <- AddEmptyLevel(mf[[i]])
  }
  if (sparse)
    return(sparse.model.matrix(formula, data = mf))
  model.matrix(formula, data = mf)
}


AddEmptyLevel <- function(x) factor(x, levels = c("tu1lnul1", levels(x)))


NamesFromHierarchies <- function(hierarchies) {
  if (is.null(names(hierarchies))) names(hierarchies) <- rep(NA, length(hierarchies))
  toFindDimLists <- (names(hierarchies) %in% c(NA, "")) & (sapply(hierarchies, is.character))  # toFindDimLists created exactly as in AutoHierarchies
  unique(c(names(hierarchies[!toFindDimLists]), unlist(hierarchies[toFindDimLists])))
}

#' @rdname ModelMatrix
#' @export
NamesFromModelMatrixInput <- function(data = NULL, hierarchies = NULL, formula = NULL, dimVar = NULL, ...) {
  if (!is.null(hierarchies)) {
    return(NamesFromHierarchies(hierarchies))
  }
  if (!is.null(formula)) { # copy of code used earlier without errors
    return(row.names(attr(delete.response(terms(as.formula(formula))), "factors")))
  }
  if (length(dimVar)) {
    if (!is.null(data)) {
      return(unique(names(data[1, dimVar, drop = FALSE])))
    }
    return(unique(dimVar))
  }
  unique(names(data))
}







