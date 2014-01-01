
Dynamin
=======

Dynamin is a GUI library written in D. It is not a binding to a GUI library written in another language, instead implementing controls in D. The [cairo graphics library](http://www.cairographics.org/) is used for 2D graphics. Dynamin currently depends on [Tango](https://github.com/SiegeLord/Tango-D2).

Issues
------

Issues are tracked at [Dynamin's project page](http://dsource.org/projects/dynamin) at dsource.

Non-Native Controls
-------------------

Although controversial with many people, Dynamin does not use native controls. With enough work, non-native controls can be made to look and feel identical to their native counterparts. I believe that work is less than the work required to wrap native controls on every platform and deal with platform specific bugs and limitations (some may not realize how many bugs and limitations there are, at least on Windows).

And using native controls is not a cure-all. FileZilla uses wxWidgets, a GUI library that wraps native controls, and yet it looks and feels bad on OS X.  VirtualBox and QtCreator use Qt, a GUI libary that uses non-native controls, and both look and feel native on Windows and almost native on OS X.

License
-------

The GUI code is under the [MPL 2.0](http://choosealicense.com/licenses/mozilla/), and the rest of the library is under the [Boost license](http://www.boost.org/users/license.html). You can use Dynamin with closed source apps, but the MPL requires redistributing Dynamin's (possibly modified) MPL source code along with compiled binaries. The Boost license is very permissive.
