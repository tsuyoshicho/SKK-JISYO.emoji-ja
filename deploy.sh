#!/bin/bash
# based on https://github.com/w3ctag/promises-guide
set -e # Exit with nonzero exit code if anything fails
# based on https://qiita.com/youcune/items/fcfb4ad3d7c1edf9dc96
set -u # Undefined variable use error

# SOURCE_BRANCH="master"
# SOURCE_BRANCH=${TRAVIS_BRANCH}
TARGET_BRANCH="gh-pages"

# Save some useful information
REPO=`git config remote.origin.url`
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone $REPO out
cd out
set +e
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
set -e
cd ..

# Clean out existing contents
# rm -rf out/**/* || exit 0

# Run our compile script

# File Deploy
cp README.md out/

# Now let's go have some fun with the cloned repo
cd out

# If there are no changes (e.g. this is a README update) then just bail.
if [ -z `git diff --exit-code` ]; then
    echo "No changes to the spec on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add .
git commit -m "Deploy to GitHub Pages: ${SHA} / Publishing site on `date "+%Y-%m-%d %H:%M:%S"`"
git push -f git@github.com:${TRAVIS_REPO_SLUG}.git $TARGET_BRANCH
