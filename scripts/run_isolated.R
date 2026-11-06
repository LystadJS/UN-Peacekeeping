# Invoke with Rscript --vanilla scripts/run_isolated.R scripts/ENTRY_POINT.R.
# Run from the clean project root. Restrict all subsequent library lookups.
arguments <- commandArgs(trailingOnly=TRUE)
stopifnot(length(arguments)==1L,dir.exists(".local_library"))
isolated_library <- normalizePath(".local_library",winslash="/",mustWork=TRUE)
Sys.setenv(R_LIBS_USER=isolated_library,R_LIBS_SITE="")
assign(".Library.site",character(),envir=.GlobalEnv)
.libPaths(c(isolated_library,.Library),include.site=FALSE)
manifest <- read.csv("config/environment_packages.csv",stringsAsFactors=FALSE)
stopifnot(as.character(getRversion())=="4.5.3",
  identical(.libPaths(),c(isolated_library,normalizePath(.Library,winslash="/"))))
for (index in seq_len(nrow(manifest))) {
  row <- manifest[index,]
  library_path <- if(row$location=="isolated_library") isolated_library else .Library
  description <- read.dcf(file.path(library_path,row$package,"DESCRIPTION"))
  stopifnot(description[1,"Version"]==row$version)
}
# No package namespace may already be loaded from a user or site library.
allowed_libraries <- .libPaths()
verify_namespaces <- function() {
  for (package_name in loadedNamespaces()) {
    if (package_name=="base") next
    location <- getNamespaceInfo(asNamespace(package_name),"path")
    if (!is.null(location)) stopifnot(dirname(normalizePath(location,winslash="/")) %in% allowed_libraries)
  }
}
verify_namespaces()
source(arguments[[1]],chdir=FALSE,echo=FALSE)
verify_namespaces()
stopifnot(identical(.libPaths(),allowed_libraries))
message("Isolated entry point completed: ",arguments[[1]])
