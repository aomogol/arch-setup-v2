#!/bin/bash

### https://www.reddit.com/r/commandline/comments/19cx1mv/bash_script_to_archive_all_repos_of_a_github/

# This script will:
# - Query all repositories owned by Github user indicated by $AUTH_TOKEN.
# - Clone all queried repositories to ${TEMP_DIR:=/tmp}/repo-archive-${RANDOM}.
# - Archive that directory to $PWD/repo_archive_YYYY-MM-DD.tar.gz
# - Copy list of archived repos to $PWD ( this list is also included in the .zip).
#
# One has to sepcify Github personal access token to $AUTH_TOKEN.
# Personal access token can be generated from Github settings under
# "Developer settings".

set -xuo pipefail
# x: print executed commands
# u: using undefined variables results in error
# o pipefail: pipes return logical and of every individual return value (true=0, false=1)

TEMP_REPO_DIR="${TEMP_DIR:=/tmp}/repo-archive-${RANDOM}"
REPOLIST=$TEMP_REPO_DIR/repolist.txt
RESPONSE_HEADER=$TEMP_REPO_DIR/response_header.txt

# Github rest api uses pagination system where it only returns n repos
# in one query. If there is any left there will be line "link:" with "next" in it,
# so we can check for this and request next page until there is none.

# Github rest api pagination pages start at 1
NEXT_PAGE=1

append_next_repo_page_to_repolist() {
# Documentation:
# https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user
    curl -L --dump-header ${RESPONSE_HEADER} \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
           "https://api.github.com/user/repos?affiliation=owner&page=${NEXT_PAGE}" \
        | jq -r '.[].full_name' >> ${REPOLIST}

    ((NEXT_PAGE++))
}

previous_was_not_last_repo_page() {
    cat ${RESPONSE_HEADER} | grep "link:" | grep 'rel="next"' &> /dev/null
    return $?
}

# Create the temp directory
mkdir ${TEMP_REPO_DIR}

# Read first page of repos
append_next_repo_page_to_repolist

while previous_was_not_last_repo_page
do
    append_next_repo_page_to_repolist
done

# We do not need the response anymore
rm ${RESPONSE_HEADER}

# Copy the repolist
DATE=$(date +"%F")
cp ${REPOLIST} ${PWD}/repo_archive_${DATE}_contents.txt

pushd ${TEMP_REPO_DIR}
# Clone all repos:
cat ${REPOLIST} | sed -E "s#(.*)#git clone --mirror https://${AUTH_TOKEN}@github.com/\1.git#" | bash
popd

# Create the archive
tar -czf ${PWD}/repo_archive_${DATE}.tar.gz --absolute-names ${TEMP_REPO_DIR}