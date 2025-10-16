#!/bin/bash -e

# Store in the dependent repository an upgraded commit's tag

rm -rf trove
git clone --depth 1 git@github.com:mm689/trove.git trove

CURRENT_COMMIT=$(git rev-parse HEAD)

# Remove any comments etc. in our version of the R package list.
sed -E '/^(#|$)/d' package-list.r >trove/package-list.new.r

cd trove

# Replace git commit hashes with the current commit's
for f in dkr/* .circleci/config.yml; do
  # NB for loop is necessary as 'sed -i' behaviour varies between Linux and OSX
  mv $f $f.bak
  sed -E \
  "s~(trovediary/((diary|trove)-)?[a-z-]+):([a-z]+-)?([a-f0-9]{40})~\1:\4$CURRENT_COMMIT~g" \
  $f.bak >$f
  rm $f.bak
done

# Work out where the package list is in package-list.r
mv package-list.r package-list.orig.r
package_list_start=$(grep --fixed -n " c(" package-list.orig.r | cut -d: -f1)
package_list_end=$(grep -n ")$" package-list.orig.r | cut -d: -f1)

# Replace only the package list within the R file.
head -n $(( $package_list_start - 1 )) package-list.orig.r >package-list.r
cat package-list.new.r >>package-list.r
tail -n +$(( $package_list_end + 1 )) package-list.orig.r >>package-list.r

# Remove packages from package-list.extra.r now they're in package-list.r
mv package-list.extra.r package-list.extra.orig.r
sed -E "s/c\(.+\)/c()/" package-list.extra.orig.r >package-list.extra.r

rm package-list.orig.r package-list.extra.orig.r package-list.new.r

# Make the commit
git add .
git commit -m "[Automatic] Upgrade versions of docker images"

if [[ "$1" == "--ci" ]]; then
    git push origin
fi

cd ~-
