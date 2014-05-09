totalspaces2-display-manager
============================

Small app to manage which display spaces are on

This app uses the [TotalSpaces2 API](https://github.com/binaryage/totalspaces2-api/blob/master/ruby/lib/TSLib.h) 
to both record which spaces are on which displays, 
and to restore those spaces to their rightful spaces when monitors are plugged and
unplugged.

The settings are stored in the file ~/.ts2_spaces_configs in JSON format.
