from rmapy.folder import Folder
from rmapy.document import ZipDocument
from rmapy.api import Client
import sys

def find_books_subfolders(rm):
    # Find books folder
    booksFolder = [ i for i in rm.get_meta_items() if i.VissibleName == "Books" ][0]
    return [ i for i in rm.get_meta_items() if i.Parent == booksFolder.ID ]

def display_folders(folder):
    # Display List of child folders
    for i in range(len(folder)):
        print(i, folder[i].VissibleName)

def select_folder_or_exit(folders):
    while True:
        display_folders(folders)
        text = input("Select folder (Enter to exit):\n")

        if text == '':
            exit()
        try:
            value = int(text)
            if value < len(folders):
                break
        except ValueError:
            continue
        
    return folders[value]

def upload_book(rm, rawDocument, folder):
    print("uploading '", rawDocument.metadata["VissibleName"], "' to '", folder.VissibleName, "'.")
    rm.upload(rawDocument, folder)
    print("done.")

if len(sys.argv) != 2:
    print(f"Usage {sys.argv[0]} <filename>")
    exit()

filename = sys.argv[1]

rm = Client()
rm.renew_token()

rawDocument = ZipDocument(doc=filename)
print("File successfully zipped name=", rawDocument.metadata["VissibleName"])
rawDocument.content["coverPageNumber"] = 0 # Ensure that the cover page is the first page

books = find_books_subfolders(rm)

folder = select_folder_or_exit(books)

upload_book(rm, rawDocument, folder)