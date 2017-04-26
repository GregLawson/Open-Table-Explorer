git checkout passed && git merge passed+interactive -X ours --no-ff --no-commit

git checkout passed && git merge passed+interactive --no-commit -X ours
git checkout tested+interactive  && git merge passed+interactive --no-ff --no-commit -X ours
git checkout tested+interactive  && git merge tested --no-ff --no-commit -X ours
git checkout tested  && git merge passed+interactive --no-ff --no-commit -X ours
git checkout tested  && git merge tested+interactive --no-ff --no-commit -X ours
git checkout edited+interactive  && git merge tested+interactive --no-ff --no-commit -X ours
git checkout edited  && git merge tested --no-ff --no-commit -X ours
git checkout edited  && git merge edited+interactive --no-ff --no-commit -X ours
