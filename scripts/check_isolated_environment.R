# Exercise compiled package loading in the isolated R process, without data or fits.
manifest <- read.csv("config/environment_packages.csv",stringsAsFactors=FALSE)
for (package_name in manifest$package[manifest$direct_dependency]) {
  if (!requireNamespace(package_name,quietly=TRUE)) stop("Cannot load ",package_name)
}
dir.create("outputs/environment",recursive=TRUE,showWarnings=FALSE)
capture.output(sessionInfo(),file="outputs/environment/session_info.txt")
capture.output(sf::sf_extSoftVersion(),file="outputs/environment/spatial_native_versions.txt")
writeLines(.libPaths(),"outputs/environment/library_paths.txt")
message("All direct pipeline dependencies loaded successfully.")
