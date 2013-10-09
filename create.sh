#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 pkgname"
    exit 1
fi
PKG=$1

#MIRROR="http://linorg.usp.br/CTAN/systems/texlive/tlnet/archive"
MIRROR="http://mirrors.ctan.org/systems/texlive/tlnet/archive"

TLPOBJ=$PWD/tlpobj2spec.pl
if [ `basename $PWD` != texlive-tlpkg -o ! -f $TLPOBJ ]; then
    echo "Run this script from texlive-tlpkg checkout dir"
fi
if [ -z "$EDITOR" ]; then
    EDITOR=xedit
fi

if [ -d texlive-$PKG -o -d ../texlive-$PKG ]; then
    echo "texlive-$PKG already exists!"
    exit 1
fi
mkdir -p texlive-$PKG/{SPECS,SOURCES,BUILD}
pushd texlive-$PKG/SOURCES
    wget $MIRROR/$PKG{,.doc,.source}.tar.xz
popd
mkdir tmp
pushd tmp
    for f in ../texlive-$PKG/SOURCES/*.xz; do
        tar Jxf $f
    done
popd
perl $TLPOBJ tmp/tlpkg/tlpobj/$PKG.tlpobj > texlive-$PKG/SPECS/texlive-$PKG.spec
rm -fr tmp

pushd texlive-$PKG
    $EDITOR SPECS/texlive-$PKG.spec
    until rpmbuild -D "_topdir $PWD" -ba SPECS/texlive-$PKG.spec; do
	echo "Package failed to build!"
	echo "Press ^C to abort (need to remove tmp dir manually)"
	$EDITOR SPECS/texlive-$PKG.spec
    done
popd

# FIXME automate package import in abf cooker
echo "Please import `ls texlive-$PKG/SRPMS/*.src.rpm` project in cooker/main..."
echo "I am waiting..."
sleep 1
echo -n "Did you create texlive-$PKG? [Yn] "
read ans
if [ x$ans = x -o x$ans = xy -o x$ans = xY ]; then
    pushd ..
	abf get texlive-$PKG
	if [ ! -d texlive-$PKG ]; then
	    echo "failed to checkout texlive-$PKG!"
	    exit 1
	fi
    popd
fi
rm -fr texlive-$PKG
