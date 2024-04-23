#!/usr/bin/env sh

set -e

npm install
npm install maplibre-gl
npm run build

cd dist

git init
git add -A
git commit -m 'deploy'
git push -f git@github.com:arthursalomaoo/teste1.git main:gh-pages

cd -