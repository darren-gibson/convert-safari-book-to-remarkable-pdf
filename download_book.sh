#!/usr/bin/env bash

# Download the books form Safari Online

function check_command {
  if ! command -v $1 &> /dev/null
  then
    echo "The command '$1' could not be found, please install and try again"
    echo "to install use:"
    echo $2
    exit
  fi
}

function check_dependencies {
  if [ ! -d "./safaribooks" ]; then
    git clone https://github.com/lorenzodifuccia/safaribooks.git
  fi
  check_command 'jq' 'brew install jq'
  check_command 'xmlstarlet' 'brew install xmlstarlet'
  check_command 'curl' 'brew install curl'
  check_command 'python3' 'brew install python@3.9'
  check_command 'zip' 'brew install zip'
  check_command '/Applications/calibre.app/Contents/MacOS/ebook-convert' 'brew install --cask calibre'
}

check_dependencies

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <BOOK ID> <Cookies>"
    exit
fi

book_id=$1
# remove error in cookie value
cookies=$(echo "$2" | sed -e 's/ENG;//g')

# Get the cookies from the Browser and then ... 
pushd ./safaribooks
python3 sso_cookies.py "$cookies"
# Then get the book 
python3 safaribooks.py $book_id
the_book=(Books/*\($book_id\))
pushd "$the_book"

# Sometimes the Style downloads with a 404 Not Found Html page and causes some mess
# make these files css compliant 
grep -l -r "404 Not Found" . --include '*.css' | xargs  -I[] sh -c "echo '.file_not_found {}' > '[]'"

# fix up some common font issues.
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/DejaVuSans/DejaVu Sans/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/DejaVuSerif/DejaVu Serif/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/Ubuntu Mono BoldItal/Ubuntu Mono/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/Ubuntu Mono Bold/Ubuntu Mono/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/Ubuntu Mono Ital/Ubuntu Mono/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/MyriadPro/Myriad Pro/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/MinionPro/Minion Pro/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's/CourierStd.otf/Courier Std/g'
find  . -type f -name '*.css' -print0 | xargs -0 sed -i '' -e 's%../fonts%fonts%g'


mkdir -p OEBPS/Styles/fonts/
mkdir -p OEBPS/Styles/css_assets/
pushd OEBPS/Styles/fonts/

# Download referenced fonts
curl https://learning.oreilly.com/api/v2/epubs/urn:orm:book:$book_id/files/?limit=10000 -o ../files.json
jq -r '.results[] | select(.url | test("[.][t|o]tf")) | [.url,.filename] | @tsv' ../files.json |
  while IFS=$'\t' read -r url filename email; do
    curl "$url" -o "$filename" 
  done

popd
# download referenced css_assets (e.g. some extra images)
pushd OEBPS/Styles/css_assets/
jq -r '.results[] | select(.url | test("css_assets")) | [.url,.filename] | @tsv' ../files.json |
  while IFS=$'\t' read -r url filename email; do
    curl "$url" -o "$filename" 
  done

rm ../files.json
popd
popd
popd

./repackage.sh $book_id