#!/bin/bash

source project.data.bash

PROJECT_TOKEN="${1}"

git init $PROJECT_TOKEN
cd $PROJECT_TOKEN

echo "${ORG_TOKEN}/${PROJECT_TOKEN}\r\nCopyright 2020 ${ORG_LEGAL_NAME}" > README.md

echo "Copyright 2020 ${ORG_LEGAL_NAME}" > LICENSE.txt

touch VERSION.txt

echo "${MAINTAINER_USERNAME} ${MAINTAINER_EMAIL} ${MAINTAINER_NAME}" > MAINTAINERS.txt

echo $MAINTAINER_PUBKEY > MAINTAINER.${MAINTAINER_USERNAME}.pgp

echo "${ORG_TOKEN} ${ORG_EMAIL} ${ORG_URL} ${ORG_LEGAL_NAME}" > ORG.txt

echo $ORG_PUBKEY > ORG.pgp

chmod 644 README.md LICENSE.txt VERSION.txt MAINTAINERS.txt ORG.txt ORG.pgp MAINTAINER.${MAINTAINER_USERNAME}.pgp

# create the initial commit in master
git add .
git commit -m'init'

# create dev branch from master
git branch dev
git checkout dev

# create maintainer unstable branch from dev. commit a v0.0.0 version.
git branch usr/$MAINTAINER_USERNAME/unstable
git checkout usr/$MAINTAINER_USERNAME/unstable
echo '0.0.0' > VERSION.txt
git add .
git commit -m'init version 0'

# merge maintainer unstable branch back into dev
git checkout dev
git merge usr/${MAINTAINER_USERNAME}/unstable

# create the test branch from dev
git branch test
git checkout test

# create the stage branch from test
git branch stage
git checkout stage

# create last branch from master
git checkout master
git branch last

# merge stage branch back into master
git checkout master
git merge stage

# set version 0.0.1 in maintainer unstable branch
git checkout usr/${MAINTAINER_USERNAME}/unstable
echo '0.0.1' > VERSION.txt
git add .
git commit -m'init first'

# merge version change from ustable branch back into dev
git checkout dev
git merge usr/${MAINTAINER_USERNAME}/unstable

# version 0.0.0 is now in master/release. v0.0.1 is in dev and user/unstable
# all dev work should be done in dev/<feature> or dev/<user>/<feature> or dev/<user>/unstable

git checkout master

exit 0


