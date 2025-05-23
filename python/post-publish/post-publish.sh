#!/usr/bin/env bash

set -eux

# Handle the following version.
if [ -z "${FOLLOWING_VERSION}" ]; then
    pip install packaging
    pushd $GITHUB_ACTION_PATH
    FOLLOWING_VERSION=$(python handle_following_version.py $VERSION)
    popd
fi
echo "following_version=$FOLLOWING_VERSION" >> $GITHUB_OUTPUT

if [ "$DRY_RUN" == "false" ]; then
    PUSH_CHANGES=true
    echo "Creating draft release with attached files"
    TITLE="${PRODUCT_NAME} ${VERSION}"
    TAG=$(echo "${TAG_TEMPLATE}" | envsubst)
    gh release create ${TAG} --draft --verify-tag --title "${TITLE}" --notes "Community notes: <link>"
    gh release upload ${TAG} $RELEASE_ASSETS/*.*
    JSON="url,tagName,assets,author,createdAt"
    JQ='.url,.tagName,.author.login,.createdAt,.assets[].name'
    echo "\## $TITLE" >> $GITHUB_STEP_SUMMARY
    gh release view --json $JSON --jq $JQ ${TAG} >> $GITHUB_STEP_SUMMARY
else
    echo "Dry run, not creating GitHub Release" >> $GITHUB_STEP_SUMMARY
    ls -ltr $RELEASE_ASSETS
    PUSH_CHANGES=false
fi

# Handle push_changes output.
echo "push_changes=$PUSH_CHANGES" >> $GITHUB_OUTPUT
