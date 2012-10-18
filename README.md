# Check Strings (in XCode-style *.lproj directories)

Small hack to sanity check XCode-style strings files.

Just drop into a map with =*.lproj= dirs and the script will compare
=Localizable.strings= in all directories to the one in =en.lproj=.

## Implemented checks
* Missing translation compared to base language (en)
* Extra translation compared to base language (en)
* Translation is the same compated with base language (en)
* String matches translation key (en)
* Multiple instances of translation key
* Empty translation value
