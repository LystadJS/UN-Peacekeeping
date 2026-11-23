# Use the restored project library first, with local Windows development
# libraries available when running alongside the original repository.
library_dirs <- c(".packages", "../.local_library")
.libPaths(c(library_dirs, .libPaths()))
if (requireNamespace("renv", quietly = TRUE)) {
  .libPaths(c(renv::paths$library(project = getwd()), .libPaths()))
}
