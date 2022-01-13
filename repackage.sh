#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <BOOK ID>"
    exit
fi

book_id=$1
mkdir -p output-pdfs/

# Get the cookies from the Browser and then ... 
pushd ./safaribooks

the_book=(Books/*\($book_id\))
pushd "$the_book"

zip -r $book_id.epub . -x "*.DS_Store"

title=$(xmlstarlet sel -N dc="http://purl.org/dc/elements/1.1/" -t -v '//dc:title' ./OEBPS/content.opf | sed -e "s/[^A-Za-z0-9._,' -]/_/g")

popd
popd

/Applications/calibre.app/Contents/MacOS/ebook-convert \
    "./safaribooks/$the_book/$book_id.epub" \
    "output-pdfs/$title.pdf" \
    --unit=devicepixel \
    --custom-size=1404x1872 \
    --output-profile=generic_eink_hd \
    --minimum-line-height=133.00 \
    --preserve-cover-aspect-ratio \
    --pdf-serif-family=Georgia \
    --pdf-default-font-size=24 \
    --pdf-page-margin-bottom=20 \
    --pdf-page-margin-top=20 \
    --pdf-page-margin-left=50  \
    --pdf-page-margin-right=20 \
    --embed-all-fonts \
    --insert-blank-line

# /Applications/calibre.app/Contents/MacOS/ebook-convert \
#     "/Users/darren/Projects/Projects/python/safaribooks/$the_book/$book_id.epub" \
#     "$title.epub" \
#     --output-profile=generic_eink_hd \
#     --minimum-line-height=133.00 \
#     --preserve-cover-aspect-ratio \
#     --embed-all-fonts \
#     --insert-blank-line
