#This script installs all the required packages for the project
if('remotes' %in% rownames(installed.packages())){
  library(remotes)
}else{
  install.packages('remotes')
  library(remotes)
}

#re-installing necessary packages

for (pkg in c('rlang','magrittr','data.table')){
  install.packages(pkg)
}

#installing packages that were not installed through binaries
pkg_list <- read.csv('app_requirements/requirements.csv')
names(pkg_list)[1] <- 'pkg'
new_pkg_idx <- which(!pkg_list[['pkg']] %in% rownames(installed.packages()))
pkg_list <- pkg_list[new_pkg_idx,]

print('These packages will be installed')
print(pkg_list)
#install all the required packages
if(nrow(pkg_list) > 0){
  for (obs in rownames(pkg_list)){
    install_version(pkg_list[obs,'pkg'], 
                    versions = ifelse(is.null(pkg_list[obs,'ver']), NULL,
                                      pkg_list[obs,'ver']))
  }
}