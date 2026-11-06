.libPaths(c(".local_library",.libPaths()))
stopifnot(requireNamespace("glmmTMB",quietly=TRUE),requireNamespace("ggplot2",quietly=TRUE),
          requireNamespace("dplyr",quietly=TRUE),requireNamespace("digest",quietly=TRUE))
packages <- sort(loadedNamespaces())
write.csv(data.frame(package=packages,version=vapply(packages,function(p) as.character(getNamespaceVersion(p)),character(1))),
          "data/pilot_package_versions.csv",row.names=FALSE)
protocol <- "docs/quarterly_protocol.md"
write.csv(data.frame(protocol_path=protocol,
  last_modified_utc=format(file.info(protocol)$mtime,"%Y-%m-%dT%H:%M:%SZ",tz="UTC"),
  sha256=digest::digest(readBin(protocol,"raw",file.info(protocol)$size),algo="sha256",serialize=FALSE),
  registration_type="Local version record; not an external preregistration"),
  "data/pilot_protocol_version.csv",row.names=FALSE)
