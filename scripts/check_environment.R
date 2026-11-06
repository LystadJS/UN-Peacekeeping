# Run from the project root. This script does not modify installed packages.
required_packages <- c("dplyr")
planned_packages <- c("ggplot2", "glmmTMB", "sf", "renv")
package_names <- c(required_packages, planned_packages)
package_status <- data.frame(
  package = package_names,
  required_now = package_names %in% required_packages,
  installed = vapply(package_names, requireNamespace, logical(1), quietly = TRUE)
)
print(package_status, row.names = FALSE)
cat("\n", R.version.string, "\n")
if (any(!package_status$installed & package_status$required_now)) {
  stop("Install missing required packages before running the simulation.")
}
