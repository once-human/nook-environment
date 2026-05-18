#!/usr/bin/env python3
import sys
import os
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

def main():
    dialog = Gtk.FileChooserDialog(
        title="Select Wallpaper (Nook Shell)",
        parent=None,
        action=Gtk.FileChooserAction.OPEN
    )
    dialog.add_buttons(
        Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
        Gtk.STOCK_OPEN, Gtk.ResponseType.OK
    )

    # Filter for standard image formats
    filter_img = Gtk.FileFilter()
    filter_img.set_name("Images (*.png, *.jpg, *.jpeg, *.webp)")
    filter_img.add_mime_type("image/png")
    filter_img.add_mime_type("image/jpeg")
    filter_img.add_mime_type("image/webp")
    filter_img.add_pattern("*.png")
    filter_img.add_pattern("*.jpg")
    filter_img.add_pattern("*.jpeg")
    filter_img.add_pattern("*.webp")
    dialog.add_filter(filter_img)

    # Open standard Pictures directory or fallback to Home
    pictures_dir = os.path.expanduser("~/Pictures")
    if os.path.exists(pictures_dir):
        dialog.set_current_folder(pictures_dir)
    else:
        dialog.set_current_folder(os.path.expanduser("~"))

    # Run modal loop
    response = dialog.run()
    if response == Gtk.ResponseType.OK:
        filename = dialog.get_filename()
        print(filename)
        dialog.destroy()
        sys.exit(0)
    else:
        dialog.destroy()
        sys.exit(1)

if __name__ == '__main__':
    main()
