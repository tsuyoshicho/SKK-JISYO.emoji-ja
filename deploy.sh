#!/bin/bash
# based on https://github.com/w3ctag/promises-guide
set -e # Exit with nonzero exit code if anything fails
# based on https://qiita.com/youcune/items/fcfb4ad3d7c1edf9dc96
set -u # Undefined variable use error

## Cron Job/master branch Only

# SOURCE_BRANCH="master"
SOURCE_BRANCH=${TRAVIS_BRANCH}
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
cp SKK-JISYO.emoji-ja.utf8 out/

# Now let's go have some fun with the cloned repo
cd out

# If there are no changes (e.g. this is a README update) then just bail.
if `git diff --quiet --exit-code`; then
  echo "No changes on gh-pages; exiting."
  exit 0
else
  # Commit the "changes", i.e. the new version.
  # The delta will show diffs between new and old versions.
  git add .
  git commit -m "Deploy to GitHub Pages: ${SHA} / Publishing site on `date "+%Y-%m-%d %H:%M:%S"`"
  git push -f git@github.com:${TRAVIS_REPO_SLUG}.git $TARGET_BRANCH
fi

cd ..

# update $SOURCE_BRANCH branch
rm -rf out

# If there are no changes (e.g. this is a README update) then just bail.
if `git diff --quiet --exit-code`; then
  echo "No changes on master; exiting."
  exit 0
else
  git remote set-url origin git@github.com:${TRAVIS_REPO_SLUG}.git

  git add -u .

  git stash push
  git checkout $SOURCE_BRANCH
  git stash pop

  git add -u .

  git commit -m "Update jisyo at cron job / `date "+%Y-%m-%d %H:%M:%S"`"
  git push
fi

# EOF
