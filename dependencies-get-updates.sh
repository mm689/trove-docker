#!/bin/bash -e

# Check for any updates to package lists.

rm -rf trove
git clone git@github.com:mm689/trove.git trove

mv package-list.r package-list.trove-docker.r

cd trove
# No need to track node.js packages: CircleCI caching renders them mostly bloat.
#make package-list.js
cp -p package-list.* ~-
cd ~-

# Check for any package names in package-list.extra.r
new_packages=$(grep --fixed "c(" package-list.extra.r \
  | sed -E "s/.*c[(](.*)[)]/\1/" || true)

# If there are new packages, move them over to package-list.r
if [ ! -z "$new_packages" ]; then

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

else
  mv package-list.trove-docker.r package-list.r
fi

# Tidy up a bit.
rm -f package-list.*.r
git reset
git add package-list.*
if [ -z "$(git diff --cached)" ]; then
  echo "No changes to package lists detected" >&2
  exit 1
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
