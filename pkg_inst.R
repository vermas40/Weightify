#This script installs all the required packages for the project
if('remotes' %in% rownames(installed.packages())){
  library(remotes)
}else{
  install.packages('remotes')
  library(remotes)
}

pkg_list <- read.csv('requirements.csv')
names(pkg_list)[1] <- 'pkg'
new_pkg_idx <- which(!pkg_list[['pkg']] %in% rownames(installed.packages()))
pkg_list <- pkg_list[new_pkg_idx,]

#install all the required packages
if(nrow(pkg_list) > 0){
    apply(pkg_list,1,function(x) install_version(x[['pkg']], 
                                                version = as.character(x[['ver']])))
}