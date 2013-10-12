#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 pkgname"
    exit 1
fi
PKG=$1

# this one is is always up to date and have packages properly synched
# to texlive.tlpbd for me...
#MIRROR="http://linorg.usp.br/CTAN/systems/texlive/tlnet/archive"
MIRROR="http://mirrors.ctan.org/systems/texlive/tlnet/archive"

TLPOBJ=$PWD/tlpobj2spec.pl
if [ `basename $PWD` != texlive-tlpkg -o ! -f $TLPOBJ ]; then
    echo "Run this script from texlive-tlpkg checkout dir"
fi
if [ -z "$EDITOR" ]; then
    EDITOR=xedit
fi

case $PKG in
    latex|latex-bin|cyrillic|cyrillic-bin)
	# PKG=
	# wget $MIRROR/$PKG.tar.xz
	# tar Jxf $PKG.tar.xz
	# SOURCES/tlpobj2spec.pl tlpkg/tlpobj/$PKG.tlpobj
	# -- cut & paste update
	echo "These texlive-$PKG needs to be manually updated!"
	exit 1
	;;
    *)
        ;;
esac

if [ ! -d ../texlive-$PKG ]; then
    echo "run (cd ..; abf get texlive-$PKG) first!"
    exit 1
fi

pushd ../texlive-$PKG
    if [ -e tmp ]; then
        echo "$PWD/tmp exists, remove it first!"
        exit 1
    fi
    git pull
    mkdir -p tmp/{SPECS,SOURCES}
    pushd tmp/SOURCES
        wget $MIRROR/$PKG{,.doc,.source}.tar.xz
    popd
    for f in `ls *.tar.xz 2>/dev/null`; do
        if [ ! -f tmp/SOURCES/`basename $f` ]; then
	    cp $f tmp/SOURCES
	fi
    done
    for f in *.tar.xz; do
        git rm $f
    done
    pushd tmp
        for pkg in SOURCES/*.xz; do
            tar Jxf $pkg
        done
        perl $TLPOBJ tlpkg/tlpobj/$PKG.tlpobj > new
        cp ../texlive-$PKG.spec old
        diff3 -m new old new > SPECS/texlive-$PKG.spec
        $EDITOR SPECS/texlive-$PKG.spec
        if grep -q '>>>' SPECS/texlive-$PKG.spec || grep -q '<<<' SPECS/texlive-$PKG.spec; then
            echo "Resolve conflicts first!"
            exit 1
        fi
        until rpmbuild -D "_topdir $PWD" -ba SPECS/texlive-$PKG.spec; do
            echo "Package failed to build!"
            echo "Press ^C to abort (need to remove tmp dir manually)"
            $EDITOR SPECS/texlive-$PKG.spec
        done
        mv -f SPECS/texlive-$PKG.spec ../texlive-$PKG.spec
        mv -f SOURCES/*.xz ..
    popd
    rm -fr tmp
    git diff
    echo "sources:" > .abf.yml
    for f in *.tar.xz; do
        git rm $f
        abf store $f
        sha1sum $f | awk '{printf("  %s: %s\n", $2, $1);}' >> .abf.yml
    done
    git add .abf.yml
    echo -n "Run git commit -a -m '- Update to latest release.'? [Yn] "
    read ans
    if [ x$ans = x -o x$ans = xy -o x$ans = xY ]; then
        if git commit -a -m '- Update to latest release.'; then
	    git push --all
            echo -n "Run abf build -a x86_64 -a i586 -a armv7l -a armv7hl -s main --auto-publish --update-type enhancement ? [Yn] "
            read ans
            if [ x$ans = x -o x$ans = xy -o x$ans = xY ]; then
                if abf build -a x86_64 -a i586 -a armv7l -a armv7hl -s main --auto-publish --update-type enhancement; then
                    exit 1
                fi
            else
                exit 1
            fi
        fi
    else
        exit 1
    fi
popd 
