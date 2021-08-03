### This directory contains all packages ready for publishing. 

The Dart publishing tool don't allow specifing which files are included or 
excluded in a package so this directory aims to provide a clean way of specifing 
what goes into the final Realm Flutter and Realm Dart packages. 

All of the files are symlinks to the correct targets from 
whithin the repo. Only files that will be published are symlinked.

Per the Dart publishing docs
https://dart.dev/tools/pub/publishing#what-files-are-published

>All files in your package are included in the published package, with the 
>following exceptions:
>
> * Any packages directories.
> * Your package’s lockfile.
> * If you aren’t using Git, all hidden files (that is, files whose names begin 
> with .).
> * If you’re using Git, any files ignored by your .gitignore file.
