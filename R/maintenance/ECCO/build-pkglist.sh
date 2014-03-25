#!/bin/bash
(cd /usr/lib64/R/library; ls -1d * | grep -v R.css) > pkglist.SSG.txt
