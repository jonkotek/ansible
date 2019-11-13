
### NEEDS EDITING, COPIED FROM WEBSITES ROLE  


# Websites Role Architecture

This standard ansible deployment role will deploy a reverse proxy site configuration or simple frontend webserver for say angular apps. It also has the capability to install base apache binaries for the site.

A systemd service file is automatically created for the site for start/stop management.  
This is all started by using the /work/ansible/mw_web/scripts/websites.sh script in a CI/CD pipeline job.

The following variables MUST be set and are utilized by the ansible websites role:  
  - httpd_sm_flag
  - httpd_version
  - ClusterName
  - CI_PROJECT_NAME
  - CI_STAGE_NAME
  - http_Interface
  - httpd_shortname
  - httpd_sitename

These must be set in the CI/CD pipeline as global to local job variables for each environment you deploy a site to.  

# Variable Definitions (Case Matters)

### httpd_sm_flag  
Current Valid Values  

Y - if this site is protected by a Siteminder Agent. SVHarbor reverse proxies have this  set. This role will automatically chose a standardized httpd.conf file that loads the Siteminder Agent and additional load moudules so that Siteminder. Note that the Identity team must STILL install the agent binaries and register the agent with the policy server. At this time only the correct apache loadmodules will be included in the httpd.conf file.

N - Currently this applies only to a site that is NOT protected by a Siteminder Agent. It is used to determine whether a simple apache web server (and binaries) get installed. Very little configuration of the apache is done as it is ment to be a geneir apache installation. Today the Apache webserver used by Angular is the tested model that works at this time. A standard httpd.conf file withh no siteminder modules is chosen at deployment time.

### httpd_version
Must be set to the apache web server version. The version number must match a version of compiled tar file located in https://git.supervalu.com/mw-web/binaries.git repo.

The value of httpd_version is the numeric part of the apache file listed below.

Example: httpd_version = 2.4.29 or httpd_version = 2.4.33

The compiled apache repo has files with the following naming convention:
be in this format:
  - httpd-2.4.29.tgz
  - httpd-2.4.33.tgz

The role utilizes the httpd_version specificed for the site to download the appropriate apache .tgz binares (if not already installed) and will install them.

Apache web server is installed in /opt/apps/apache64/{{ httpd_version }} folder on the destination server.

A check is made by the apache ansible role to test the existence of /opt/apps/apache64/{{ httpd_version }}/bin/httpd file. If it exists, the apache binaries will NOT be installed.

### ClusterName
This must be set to the Microservice Clustername. The name set here is determined by the development and middleware teams. It becomes the basis for other naming conventions such as ansible inventory host grouping names and microservice active runtime profile names/configurations.

A few existing examples in use today:
Microservice config server - set to value "global". The reasoning is the configuration service is global across all microservice clusters. It couild be considered an enterprise service in a way.

Microservice Merch Cluster - set to value "merch". Apps like eventwriter are configured into this microservice cluster.

The websites.sh script uses the ClusterName value to determine the correct ansible inventory group name. The servers in this groupname will be acted on by ansible for this run.

```
if [ "$httpd_sm_flag" == "N" ]
then
  if [ "$ClusterName" == "" ]
  then
    echo "Must define variable ClusterName in the pipeline for Angular Apache Web Installs"
    echo "ie. ClusterName: merch"
    exit 1
  else
    InventoryGroup="${CI_JOB_STAGE}-${ClusterName}-${http_Interface}"
    echo Ansible Inventory Group=${InventoryGroup}
  fi
else
    InventoryGroup="${CI_JOB_STAGE}-${http_Interface}"
    echo Ansible Inventory Group=${InventoryGroup}
fi
```

### CI_PROJECT_NAME
This is a gitlab variable that is automatically set for a pipeline run. It is the name of the Gitlab project in the repo. Names like svwire.svharbor.com or ems.svharbor.com whould be used. The name is determined by the Middleware team.  

### CI_STAGE_NAME
This is a gitlab variable that is automatically set for a pipeline run. It is the stage name for the currently executing Gitlab job.
Names must be consistent. Use dev,test,uat,qa,prod for stage names in your pipeline. It is not mandatory to do name them this way, but you will find being inconsistent will make it much harder.

### http_Interface
Valid is EITHER "ext" or "int"  
ext refers to the dmz external facing Linux interface (internet side).
int refers to the dmz intenal facing linux interface (application server side).

Use int for any non-dmz servers since they only have  one interface. 

### httpd_shortname
Short name of the site. Example is the best to show this. If a site has a long name (defined below) such as dpp.svharbor.com, then  httpd_shortname is "dpp".

### httpd_sitename
FQDN name of the site. Example is the best to show this. If a site has sitename such as dpp.svharbor.com, then set it to that value. This is used for folder directory naming and keeping different sites on the same server from colliding. This is typically the name of the project in the git repo.
