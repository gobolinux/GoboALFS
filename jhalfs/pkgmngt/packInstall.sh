# $Id: packInstall.sh.template 3561 2012-02-19 10:54:17Z pierre $
# function for packing and installing a tree. We only have access
# to variables PKGDIR and PKG_DEST
# Other variables can be passed on the command line, or in the environment

packInstall() {

# A proposed implementation for versions and package names.
local PCKGVRS=$(basename $PKGDIR)
local TGTPKG=$(basename $PKG_DEST)
local PACKAGE=$(echo ${TGTPKG} | sed 's/^[0-9]\{3\}-//' |
           sed 's/^[0-9]\{1\}-//')

# version is only accessible from PKGDIR name. Since the format of the
# name is not normalized, several hacks are necessary...
case $PCKGVRS in
  expect*|tcl*) local VERSION=$(echo $PCKGVRS | sed 's/^[^0-9]*//') ;;
  vim*|unzip*) local VERSION=$(echo $PCKGVRS | sed 's/^[^0-9]*\([0-9]\)\([0-9]\)/\1.\2/') ;;
  tidy*) local VERSION=$(echo $PCKGVRS | sed 's/^[^0-9]*\([0-9]*\)/\1cvs/') ;;
  docbook-xml) local VERSION=4.5 ;;
  *) local VERSION=$(echo ${PCKGVRS} | sed 's/^.*[-_]\([0-9]\)/\1/');;
esac

#echo "PKGDIR is:   $PKGDIR" >&2
#echo "PKG_DEST is: $PKG_DEST" >&2
#echo "Package is:  $PACKAGE" >&2
#echo "Version is:  $VERSION" >&2
#echo "Arch is:     $ARCH" >&2
#echo "PWD is:      $PWD" >&2

# Guess GoboLinux package name
local appName="$PACKAGE"
case "${appName}" in
  kernfs|chroot|creatingdirs|createfiles|adjusting|strippingagain|revisedchroot)
    # No GoboLinux hooks are invoked for these.
    appName="" ;;
  gobolinux)
    # We don't want to install this package. It will be later replaced by Compile+Scripts.
    return 0 ;;
  pkg-config)
    appName="pkgconfig" ;;
  *) ;;
esac
if [ ! -z "${appName}" ]
then
  foundName=$(cat /tools/etc/GoboLinux_PackageNames.txt | grep -i "^${appName}$" | head -n 1)
  if [ -n "${foundName}" ]
  then
     appName="${foundName}"
  else
    case "$appName" in
      libpipeline) appName="LibPipeline" ;;     # XXX: temporary workaround until recipe is in the store
      procps-ng)   appName="Procps-NG" ;;       # XXX: temporary workaround until recipe is in the store
      tzdata)      appName="TZData" ;;
      xml-parser)  appName="Perl-XML-Parser" ;;
      bootscripts) appName="BootScripts-ALFS" ;;
      python2)     appName="Python" ;;
      python3)     appName="Python" ;;
      serf)        appName="Serf" ;;
      nettle)      appName="Nettle" ;;
      docbook-xsl) appName="DocBook-XSL" ;;
      html-tidy)   appName="HTML-Tidy" ;;
      xz)          appName="XZ-Utils" ;;
      eudev)       appName="Eudev" ;;
      cacerts)     appName="CAcerts" ;;
      *)           echo "GoboLinux: Warning: $PACKAGE is not a known package name in GoboLinux" >&2 ;;
    esac
  fi
fi

pushd $PKG_DEST || exit 1
rm -fv ./usr/share/info/dir  # recommended since this directory is already there
                             # on the system

# Move files to destination directory
local target="/Programs/$appName/$VERSION"
mkdir -p "$target/Resources/Defaults/Settings"

[ -d "./usr" -a $(ls ./usr/ | wc -l) -gt 0 ] && cp -Ra usr/* "$target/"
rm -rf usr

[ -d "./etc" -a $(ls ./etc/ | wc -l) -gt 0 ] && cp -Ra etc/* "$target/Resources/Defaults/Settings/"
rm -rf etc

if [ -d "./var" -a $(ls ./var/ | wc -l) -gt 0 ]
then
    mkdir -p "$target/Resources/Unmanaged/Data/Variable"
    cp -Ra var/* "$target/Resources/Unmanaged/Data/Variable/"
fi
rm -rf var

[ $(ls | wc -l | awk {'print $1'}) -gt 0 ] && cp -Ra * "$target/"
rm -rf *

if [ -d "$target/lib64" ]
then
    # Merge lib64 and lib
    if [ -d "$target/lib" ]
    then
        cp -Ra $target/lib64/* $target/lib/
        rm -rf $target/lib64
    else
        mv $target/lib64 $target/lib
    fi
fi

if [ -d "$target/etc" ]
then
    # Could happen if we have both /etc and /usr/etc (who knows..)
    cp -R "$target/etc/*" "$target/Resources/Defaults/Settings/"
    rm -rf "$target/etc"
fi

if [ $(ls "$target/Resources/Defaults/Settings/" | wc -l | awk {'print $1'}) -gt 0 ]
then
    if [ ! -d "$target/../Settings" ]
    then
        mkdir "$target/../Settings"
        cp -R "$target/Resources/Defaults/Settings/"* "$target/../Settings/"
    fi
fi

# Fix broken links in $target
pushd "$target"
FindBroken $(find .) | while read linkname
do
    mydir=$(basename $(dirname "$linkname"))
    broken=$(readlink $linkname)
    if echo "$broken" | grep -q "../../$mydir"
    then ln -sf "$(basename $broken)" "$linkname"
    elif echo "$broken" | grep -q "../usr/"
    then ln -sf "$(echo $broken | sed 's,/usr/,/,g')" "$linkname"
    fi
done
popd

# Symlink on LFS
/tools/bin/SymlinkProgram -c overwrite "$appName" "$VERSION"

popd                         # Since the $PKG_DEST directory is destroyed
                             # immediately after the return of the function,
                             # getting back to $PKGDIR is important...
}
