#!/bin/bash
set -ev
echo -e "Building docs...\n"
mvn -P html -pl docs install -DskipTests -Dspotbugs.skip

echo -e "Generating changelog...\n"
export CHANGELOG_GITHUB_TOKEN=$GITHUB_TOKEN
gem install github_changelog_generator -v 1.14.3
github_changelog_generator
pandoc -f markdown -t html -s -c stylesheets/changelog.css CHANGELOG.md > changelog.html
cp changelog.html target/site/

echo -e "Publishing site ...\n"
# Save docs to latest
cp -R target/site $HOME/latest

cd $HOME
git config --global user.email "geowave-dev@locationtech.org"
git config --global user.name "geowave-dev"
git clone --quiet --depth 1 --branch=gh-pages https://${GITHUB_TOKEN}@github.com/locationtech/geowave gh-pages > /dev/null

cd gh-pages 

# Back up previous versions
mv previous-versions $HOME/previous-versions

# Remove old latest
rm -rf latest

# Get the version from the build.properties file
filePath=deploy/target/classes/build.properties
GEOWAVE_VERSION=$(grep project.version $filePath|  awk -F= '{print $2}')

if [[ ! "$GEOWAVE_VERSION" =~ "SNAPSHOT" ]] && [[ ! "$GEOWAVE_VERSION" =~ "RC" ]] ; then
  # If this isn't a snapshot or release candidate, this becomes the main site
  echo -e "Publishing release documentation ...\n"
  cp -Rf $HOME/latest $HOME/site/
else
  echo -e "Publishing snapshot documentation ...\n"
  # Otherwise keep old release
  cp -Rf . $HOME/site/
fi

# Save previous versions of the documentation
cp -r $HOME/previous-versions $HOME/site/

# Save latest
cp -r $HOME/latest $HOME/site/

git rm -r -f -q .
cp -Rf $HOME/site/* .

# Don't check in big binary blobs
# TODO: Push to S3 if we want to link to them via the web site
rm -f *.epub *.pdf *.pdfmarks

git add -f .
git commit -m "Lastest docs on successful github build $GITHUB_RUN_NUMBER auto-pushed to gh-pages"
git push -fq origin gh-pages > /dev/null

echo -e "Published docs to gh-pages.\n"

echo -e "Building python docs...\n"
source .utility/build-python-docs.sh