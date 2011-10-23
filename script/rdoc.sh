rdoc --op ../Open-Table-Explorer-github-pages/doc/ app test lib
pushd ../Open-Table-Explorer-github-pages/
git branch
git add doc
git push
popd
