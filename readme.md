# Convert Safari Books to ReMarkable 2 friendly PDF
These scripts downloads Safari Books so that they can be read on a reMarkable 2 tablet.  Please read: https://www.oreilly.com/terms/

Designed to run on Mac OS

## Usage
To run the command run from under the same folder as the scripts.  The command relies on a number of 3rd party

```sh
./download_book.sh <book_id> <cookies>

./download_book.sh 0321146530 'BrowserCookie=3f2...'
```

Note: the cookies can be directly coppied from the Safari Books cookies out of Chrome.  See the [safaribooks github repository](https://github.com/lorenzodifuccia/safaribooks) for more information.

## Useful info
If the download works, but the packaging throws up errors (e.g. missing fonts).  Then fix the errors, e.g. install the Fonts, and re-run the packaging only stage.

```sh
./repackage.sh <book_id>

./repackage.sh 0321146530
```

## Credits
Thank you to:
 https://github.com/lorenzodifuccia/safaribooks

https://calibre-ebook.com/
