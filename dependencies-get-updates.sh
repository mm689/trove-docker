#!/bin/bash -e

# Check for any updates to package lists.

rm -rf trove
git clone --depth 1 git@github.com:mm689/trove.git trove

# Retrieve package-list.r from the trove repo (with comments from this repo).
cp -p package-list.r package-list.trove-docker.r
head -n $(grep -n "^#" package-list.trove-docker.r | tail -1 | cut -d: -f1) package-list.trove-docker.r >package-list.r
tail -n +$(($(grep -n "^#" trove/package-list.r | tail -1 | cut -d: -f1) + 1)) trove/package-list.r >>package-list.r

cd trove
# No need to track node.js packages: CircleCI caching renders them mostly bloat.
#make package-list.js
cp -p package-list.extra.r ~-
cp -p r_api/package-list.r ~-/package-list.lambda.r
cd ~-

# Check for any package names in package-list.extra.r
new_packages=$(grep --fixed "c(" package-list.extra.r \
  | sed -E "s/.*c[(](.*)[)]/\1/" || true)

if [ -n "$new_packages" ] && ! diff package-list.r package-list.trove-docker.r >/dev/null; then
    echo "Error: packages modified in both trove:package-list.r and trove:package-list.extra.r" >&2
    exit 1
fi

# If there are new packages in package-list.extra.r, move them over to package-list.r
if [ -n "$new_packages" ]; then

  # Extract the existing package list from the package-list.r file
  package_list_start=$(grep --fixed -n " c(" package-list.r | cut -d: -f1)
  package_list_end=$(grep -n ")$" package-list.r | cut -d: -f1)
  package_list=$(head -n $package_list_end package-list.r | tail -n +$package_list_start)

  # Extract, combine and format the actual list of packages.
  mv package-list.r package-list.orig.r
  package_list=$(echo -n "$package_list" | tr -d ')' && echo ", $new_packages)")
  package_list=$(echo "$package_list" | tr -d '\n' | tr '"' "'" | sed -E "s/,[[:space:]]*'/, '/g")
  package_list=$(echo "$package_list" | fold -w 78 -s | sed "s/^'/  '/;s/ $//")

  # Work out the location of the package list in our own copy of the file.
  package_list_start=$(grep --fixed -n " c(" package-list.trove-docker.r | cut -d: -f1)
  package_list_end=$(grep -n ")$" package-list.trove-docker.r | cut -d: -f1)

  # Overwrite the original package list with the updated one.
  head -n $(( $package_list_start - 1 )) package-list.trove-docker.r >package-list.r
  echo "$package_list" >>package-list.r
  tail -n +$(( $package_list_end + 1 )) package-list.trove-docker.r >>package-list.r

fi

# Tidy up a bit.
rm -f package-list.extra.r package-list.trove-docker.r package-list.orig.r
git reset
git add package-list*.r
if [ -z "$(git diff --cached)" ]; then
  echo "No changes to package lists detected" >&2
  exit 0
fi

# Generate and apply a pretty commit message.

# Gather the list of file extensions affected
extensions=$(git diff --cached --name-only | sed -E 's/.*[.]([^.]+)$/\1/')
# Make the extensions list unique and put it on one line
extensions=$(echo "$extensions" | tr [a-z] [A-Z] | sort | uniq | tr '\n' ',')
# Put nice separators between the extensions
extensions=$(echo $extensions | rev | sed 's/^,//;s/,/ dna /;s/,/ ,/g' | rev)
# Generate an 's' if the list of affected files, minus the first, isn't empty
plural=$(git diff --cached --name-only | tail -n +2)
plural=$(echo "$plural" | grep . >/dev/null && echo "s" || echo "")
# Commit.
git commit -m "[Automatic] Updated $extensions package list$plural"

if [[ "$1" == "--ci" ]]; then
    if [[ -n "$GIT_IDENTITY_TROVE_DOCKER" ]]; then
        # CircleCI needs creative SSHing to be able to push to and pull from both trove-docker and trove.
        ssh-agent bash -c "ssh-add $GIT_IDENTITY_TROVE_DOCKER && git push origin"
    else
        git push origin
    fi
    echo "**********" >&2
    echo "Changes were made. Failing this pipeline in favour of the one triggered by them." >&2
    echo "**********" >&2
    exit 1
fi