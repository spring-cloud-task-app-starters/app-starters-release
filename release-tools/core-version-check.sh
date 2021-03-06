#!/bin/bash

# The script takes one argument - release version

if [ "$#" -ne 1 ]; then
    echo "Please specify the release version"
    exit
fi

git clone git@github.com:spring-cloud-task-app-starters/core.git
cd core
./mvnw versions:set -DnewVersion=$1 -DgenerateBackupPoms=false
./mvnw versions:set -DnewVersion=$1 -DgenerateBackupPoms=false -pl :task-app-starters-core-dependencies

sed -i '' 's/<task-app-starters-core-dependencies.version>.*/<task-app-starters-core-dependencies.version>'"$1"'<\/task-app-starters-core-dependencies.version>/g' pom.xml

snapshotlines=$(find . -type f -name pom.xml | xargs grep SNAPSHOT | wc -l)
rclines=$(find . -type f -name pom.xml | xargs grep .RC | wc -l)
milestonelines=$(find . -type f -name pom.xml | xargs grep version | grep .M | wc -l)

if [ $snapshotlines -eq 0 ] && [ $rclines -eq 0 ] && [$milestonelines -eq 0 ]; then
        echo "All clear"
else
        echo "Snapshots found."
        find . -type f -name pom.xml | xargs grep SNAPSHOT
        echo "SNAPSHOTS: " $snapshotlines
	exit 1
fi

cd ..
rm -rf core
