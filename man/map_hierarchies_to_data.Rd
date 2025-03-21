% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_hierarchies_to_data.R
\name{map_hierarchies_to_data}
\alias{map_hierarchies_to_data}
\title{Add variables to dataset based on hierarchies}
\usage{
map_hierarchies_to_data(
  data,
  hierarchies,
  when_overwritten = warning,
  add_comment = TRUE,
  ...
)
}
\arguments{
\item{data}{A data frame containing variables with names matching the names of the hierarchies.}

\item{hierarchies}{List of hierarchies in the same format as input to \code{\link{AutoHierarchies}}}

\item{when_overwritten}{A function to be called when existing column(s) are overwritten.
Supply \code{stop} to invoke an error, \code{warning} for a warning (default),
\code{message} to display an informational message, or \code{NULL} to do nothing.}

\item{add_comment}{Logical. When \code{TRUE} (default), a comment attribute will be added to the output data frame,
containing the names of the variables that were added.}

\item{...}{Further parameters sent to \code{\link{hierarchies_as_vars}}}
}
\value{
Input \code{data} with extra Variables
}
\description{
Uses \code{\link{hierarchies_as_vars}} to transform hierarchies, followed by mapping to the dataset.
}
\examples{

# Examples similar those from hierarchies_as_vars

z <- SSBtoolsData("sprt_emp_withEU")
year_formula <- c("y_14 = 2014", "y_15_16 = y_all - y_14", "y_all = 2014 + 2015 + 2016")
geo_dim_list <- FindDimLists(z[, c("geo", "eu")], total = "Europe")[[1]]
age_hierarchy <- SSBtoolsData("sprt_emp_ageHier")

map_hierarchies_to_data(z, list(age = age_hierarchy, geo = geo_dim_list, 
                                year = year_formula))

map_hierarchies_to_data(data.frame(f = c("A", "B", "C", "D", "E", "A")), list(f = 
       c("AB = A + B", "AC = A + C", "CD = C + D", "ABCD = AB + CD")))
       
       
# Examples demonstrating when_overwritten and add_comment        
       
a <- map_hierarchies_to_data(z, list(age = age_hierarchy, geo = geo_dim_list))
comment(a)

b <- map_hierarchies_to_data(a[-7], list(age = age_hierarchy, geo = geo_dim_list), 
                             when_overwritten = message, add_comment = FALSE)
comment(b)

}
