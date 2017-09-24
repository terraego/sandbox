# Function used to update the pom version with the version defined in package.json
# arg0: boolean true if the version needs to be appended with SNAPSHOT
function update_pom {
    # Read package.json version
    RA_VERSION=$(sed -nE 's/^\s*"version": "(.*?)",$/\1/p' package.json)
	
	if [ ${1:-false} = true ] 
	then
	    POM_VERSION="${RA_VERSION}-SNAPSHOT"
	else
	    POM_VERSION="${RA_VERSION}"
	fi
	
	echo "Setting pom version to ${POM_VERSION}"
	mvn versions:set -DnewVersion="${POM_VERSION}" versions:commit
}

echo "Deploying artifact for environment '$1'"
update_pom false


# Tag version in scm and bump resposive assets
if [ "$1" = "prod" ] 
then
	#push tag for current version
	git add ./pom.xml
	git tag -a -m "Releasing patch version: ${RA_VERSION}" ${RA_VERSION}
	read
	git push
	
	# Build the package and deploy it
	mvn package
	mvn deploy
	
	#bump version and commit
	npm version patch
	read_version true
	git add ./package.json
	git add ./pom.xml
	git commit -a -m "Updating version to next development version"
	read
	git push
fi


read -rsp $'Press enter to continue...\n'