# Offline installed-package reproduction, not a fresh installation from sources.
# Usage: Rscript --vanilla scripts/prepare_isolated_environment.R TARGET_PROJECT [--verify-only]
arguments <- commandArgs(trailingOnly=TRUE)
verify_only <- "--verify-only" %in% arguments
arguments <- arguments[arguments != "--verify-only"]
stopifnot(length(arguments)==1L)
source_project <- normalizePath(getwd(), winslash="/", mustWork=TRUE)
target_project <- arguments[[1]]
if (!verify_only) dir.create(target_project, recursive=TRUE, showWarnings=FALSE)
target_project <- normalizePath(target_project, winslash="/", mustWork=TRUE)
stopifnot(target_project != source_project,
  startsWith(target_project,paste0(source_project,"/outputs/")))
source_libraries <- unique(c(file.path(source_project,".local_library"),
  "C:/Users/John/Documents/R-Positron/Packages/4.5",.Library))
.libPaths(source_libraries,include.site=FALSE)
stopifnot(requireNamespace("digest",quietly=TRUE))
stopifnot(as.character(getRversion()) == "4.5.3")
# Once recorded, the repository manifest is the expected environment. Refuse
# drift instead of silently blessing whatever happens to be installed later.
expected_manifest <- if (file.exists("config/environment_packages.csv"))
  read.csv("config/environment_packages.csv", stringsAsFactors = FALSE) else NULL
if (verify_only && is.null(expected_manifest)) stop("Verification requires the locked repository manifest.")
if (!is.null(expected_manifest)) stopifnot(!anyDuplicated(expected_manifest$package))
target_library <- file.path(target_project,".local_library")
if (!verify_only && dir.exists(target_library) && length(list.files(target_library))) {
  stop("Target library is not empty; do not overwrite an earlier environment.")
}
if (!verify_only) dir.create(target_library,recursive=TRUE,showWarnings=FALSE)
if (verify_only) {
  stopifnot(dir.exists(target_library))
  target_manifest <- read.csv(file.path(target_project,"config/environment_packages.csv"),
    stringsAsFactors=FALSE)
  expected_order <- expected_manifest[order(expected_manifest$package),]
  target_order <- target_manifest[order(target_manifest$package),]
  rownames(expected_order) <- rownames(target_order) <- NULL
  stopifnot(identical(expected_order,target_order),
    setequal(list.files(target_library),
      expected_manifest$package[expected_manifest$location=="isolated_library"]))
}

# Include the entire executable research workflow, including source inspection.
# Recommended/base packages bundled with the selected R installation remain
# in its standard library; all other recursive dependencies are copied.
direct_packages <- c("digest","dplyr","tidyr","ggplot2","sf","readr",
  "jsonlite","glmmTMB","pdftools","readxl")
resolved <- list()
resolve_package <- function(package_name) {
  if (package_name=="R" || package_name %in% names(resolved)) return(invisible(NULL))
  locations <- file.path(source_libraries,package_name)
  locations <- locations[file.exists(file.path(locations,"DESCRIPTION"))]
  if (!length(locations)) stop("Missing installed dependency: ",package_name)
  package_path <- locations[[1]]
  description <- read.dcf(file.path(package_path,"DESCRIPTION"))
  resolved[[package_name]] <<- list(path=package_path,description=description)
  fields <- intersect(c("Depends","Imports","LinkingTo"),colnames(description))
  dependency_text <- paste(description[1,fields],collapse=",")
  dependencies <- trimws(gsub("\\s*\\(.*?\\)","",strsplit(dependency_text,",")[[1]]))
  for (dependency in dependencies[nzchar(dependencies)]) resolve_package(dependency)
}
for (package_name in direct_packages) resolve_package(package_name)
if (!is.null(expected_manifest)) {
  stopifnot(setequal(names(resolved), expected_manifest$package))
}

tree_hash <- function(directory) {
  relative_files <- sort(list.files(directory,recursive=TRUE,all.files=TRUE,
    no..=TRUE,include.dirs=FALSE))
  hashes <- vapply(file.path(directory,relative_files),function(path)
    digest::digest(readBin(path,"raw",n=file.info(path)$size),
      algo="sha256",serialize=FALSE),character(1))
  digest::digest(paste(relative_files,hashes,sep="\t",collapse="\n"),
    algo="sha256",serialize=FALSE)
}
manifest <- list()
for (package_name in sort(names(resolved))) {
  package <- resolved[[package_name]]
  bundled <- dirname(package$path)==.Library
  source_hash <- tree_hash(package$path)
  if (!is.null(expected_manifest)) {
    expected <- expected_manifest[expected_manifest$package == package_name, ]
    stopifnot(nrow(expected) == 1L,
              package$description[1,"Version"] == expected$version,
              source_hash == expected$package_tree_sha256,
              expected$direct_dependency == (package_name %in% direct_packages),
              expected$location == if(bundled) "R_standard_library" else "isolated_library")
  }
  if (!bundled) {
    if (!verify_only) stopifnot(file.copy(package$path,target_library,recursive=TRUE,copy.date=TRUE))
    target_description <- read.dcf(file.path(target_library,package_name,"DESCRIPTION"))
    stopifnot(target_description[1,"Version"]==package$description[1,"Version"])
    stopifnot(identical(source_hash,tree_hash(file.path(target_library,package_name))))
  }
  manifest[[package_name]] <- data.frame(package=package_name,
    version=package$description[1,"Version"],
    direct_dependency=package_name %in% direct_packages,
    location=if(bundled) "R_standard_library" else "isolated_library",
    package_tree_sha256=source_hash)
}
manifest <- do.call(rbind,manifest)
if (verify_only) {
  message("Read-only verification passed: ",nrow(manifest),
    " source package versions/tree hashes and ",sum(manifest$location=="isolated_library"),
    " isolated package copies match the locked manifests; no files written or copied.")
  quit(save="no",status=0L)
}
dir.create("config",showWarnings=FALSE)
write.csv(manifest,"config/environment_packages.csv",row.names=FALSE)
dir.create(file.path(target_project,"config"),recursive=TRUE,showWarnings=FALSE)
write.csv(manifest,file.path(target_project,"config/environment_packages.csv"),row.names=FALSE)
metadata <- c(paste("R version:",getRversion()),paste("Platform:",R.version$platform),
  paste("R executable:",file.path(R.home("bin"),"Rscript.exe")),
  paste("Prepared UTC:",format(Sys.time(),tz="UTC",usetz=TRUE)),
  "Method: offline copy of installed packages; SHA256 of every package file checked before/after copy.",
  "Not a network reinstall, source rebuild, renv restore, or portable cross-platform binary bundle.",
  paste("Copied packages:",sum(manifest$location=="isolated_library")),
  paste("R-bundled dependencies:",sum(manifest$location=="R_standard_library")))
writeLines(metadata,"config/environment_runtime.txt")
file.copy("config/environment_runtime.txt",file.path(target_project,"config"),overwrite=TRUE)
print(manifest[,1:4],row.names=FALSE)
message("Prepared verified isolated library at ",target_library)
