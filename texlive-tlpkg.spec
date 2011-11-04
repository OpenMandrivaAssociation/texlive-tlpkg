%define _tlpkgdir			%{_datadir}/tlpkg
%define _tlpkgobjdir			%{_tlpkgdir}/tlpobj
%define _texmfdir			%{_datadir}/texmf
%define _texmfdistdir			%{_datadir}/texmf-dist
%define _texmflocaldir			%{_datadir}/texmf-local
%define _texmfextradir			%{_datadir}/texmf-extra
%define _texmffontsdir			%{_datadir}/texmf-fonts
%define _texmfprojectdir		%{_datadir}/texmf-project
%define _texmfvardir			%{_localstatedir}/lib/texmf
%define _texmfconfdir			%{_sysconfdir}/texmf
%define _texmf_fmtutil_d		%{_datadir}/tlpkg/fmtutil.cnf.d
%define _texmf_updmap_d			%{_datadir}/tlpkg/updmap.cfg.d
%define _texmf_language_dat_d		%{_datadir}/tlpkg/language.dat.d
%define _texmf_language_def_d		%{_datadir}/tlpkg/language.def.d
%define _texmf_language_lua_d		%{_datadir}/tlpkg/language.lua.d

%define _texmf_enable_asymptote		0
%define _texmf_enable_xindy		0
%define _texmf_with_system_dialog	1
%define _texmf_with_system_lcdf		0
%define _texmf_with_system_poppler	0
%define _texmf_with_system_psutils	1
%define _texmf_with_system_t1lib	1
%define _texmf_with_system_tex4ht	0
%define _texmf_with_system_teckit	0

Name:		texlive-tlpkg
Version:	20111030
Release:	1
Summary:	The TeX formatting system
URL:		http://tug.org/texlive/
Group:		Publishing
License:	http://www.tug.org/texlive/LICENSE.TL
Source0:	http://mirrors.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
Source1:	http://mirrors.ctan.org/systems/texlive/tlnet/tlpkg/texlive.tlpdb.xz
Source2:	tlpobj2spec.pl
Source3:	checkupdates.pl
BuildArch:	noarch

Requires:	texlive-kpathsea.bin

%description
TeX Live is an easy way to get up and running with the TeX document
production system. It provides a comprehensive TeX system. It includes
all the major TeX-related programs, macro packages, and fonts that are
free software, including support for many languages around the world.

%files
%dir %{_tlpkgdir}
%{_tlpkgdir}/TeXLive
%dir %{_tlpkgobjdir}
%dir %{_texmf_fmtutil_d}
%dir %{_texmf_updmap_d}
%dir %{_texmf_language_dat_d}
%dir %{_texmf_language_def_d}
%dir %{_texmf_language_lua_d}
%{_sbindir}/mktexlsr.*
%{_sbindir}/mtxrun.*
%{_sbindir}/fmtutil.*
%{_sbindir}/updmap.*
%{_sbindir}/language.*
%{_sbindir}/tlpobj2spec
%{_sys_macros_dir}/texlive.macros
%doc %{_tlpkgdir}/texlive.tlpdb

#-----------------------------------------------------------------------
%prep
%setup -q -n install-tl-%{version}

%build

%install
mkdir -p %{buildroot}%{_tlpkgobjdir}
cp -fpr tlpkg/TeXLive %{buildroot}%{_tlpkgdir}

mkdir -p %{buildroot}%{_texmf_fmtutil_d}
mkdir -p %{buildroot}%{_texmf_updmap_d}
mkdir -p %{buildroot}%{_texmf_language_dat_d}
mkdir -p %{buildroot}%{_texmf_language_def_d}
mkdir -p %{buildroot}%{_texmf_language_lua_d}

#-----------------------------------------------------------------------
mkdir -p %{buildroot}%{_sbindir}
cat > %{buildroot}%{_sbindir}/mktexlsr.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/mktexlsr ]; then
	N=`cat /var/run/mktexlsr`
	N=\`expr \$N + 1\`
    else
	N=1
    fi
    echo \$N > /var/run/mktexlsr
) 9>/var/run/mktexlsr.lock
EOF
chmod +x %{buildroot}%{_sbindir}/mktexlsr.pre

cat > %{buildroot}%{_sbindir}/mktexlsr.post << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/mktexlsr ]; then
	N=\`cat /var/run/mktexlsr\`
	N=\`expr \$N - 1\`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	/usr/bin/mktexlsr /usr/share/texmf /usr/share/texmf-dist > /dev/null
	rm -f /var/run/mktexlsr
    else
	echo \$N > /var/run/mktexlsr
    fi
) 9>/var/run/mktexlsr.lock
EOF
chmod +x %{buildroot}%{_sbindir}/mktexlsr.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/mtxrun.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/mtxrun ]; then
	N=`cat /var/run/mtxrun`
	N=\`expr \$N + 1\`
    else
	N=1
    fi
    echo \$N > /var/run/mtxrun
) 9>/var/run/mtxrun.lock
EOF
chmod +x %{buildroot}%{_sbindir}/mtxrun.pre

cat > %{buildroot}%{_sbindir}/mtxrun.post << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/mtxrun ]; then
	N=\`cat /var/run/mtxrun\`
	N=\`expr \$N - 1\`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	/usr/bin/mtxrun --generate > /dev/null
	rm -f /var/run/mtxrun
    else
	echo \$N > /var/run/mtxrun
    fi
) 9>/var/run/mtxrun.lock
EOF
chmod +x %{buildroot}%{_sbindir}/mtxrun.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/fmtutil.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/fmtutil ]; then
	N=`cat /var/run/fmtutil`
	N=\`expr \$N + 1\`
    else
	N=1
    fi
    echo \$N > /var/run/fmtutil
) 9>/var/run/fmtutil.lock
EOF
chmod +x %{buildroot}%{_sbindir}/fmtutil.pre

cat > %{buildroot}%{_sbindir}/fmtutil.post << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/fmtutil ]; then
	N=\`cat /var/run/fmtutil\`
	N=\`expr \$N - 1\`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	(
	    cat %{_texmfdir}/texmf/web2c/fmtutil-hdr.cnf
	    for file in %{_texmf_fmtutil_d}/*; do
		cat \$file
	    done
	    if [ -f %{_texmflocaldir}/texmf/web2c/fmtutil-local.cnf ]; then
		cat %{_texmflocaldir}/texmf/web2c/fmtutil-local.cnf
	    fi
	) > %{_texmfdir}/web2c/fmtuitl.cnf
	/usr/bin/fmtutil-sys --all > /dev/null
	rm -f /var/run/fmtutil
    else
	echo \$N > /var/run/fmtutil
    fi
) 9>/var/run/fmtutil.lock
EOF
chmod +x %{buildroot}%{_sbindir}/fmtutil.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/updmap.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/updmap ]; then
	N=`cat /var/run/updmap`
	N=\`expr \$N + 1\`
    else
	N=1
    fi
    echo \$N > /var/run/updmap
) 9>/var/run/updmap.lock
EOF
chmod +x %{buildroot}%{_sbindir}/updmap.pre

cat > %{buildroot}%{_sbindir}/updmap.post << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/updmap ]; then
	N=\`cat /var/run/updmap\`
	N=\`expr \$N - 1\`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	(
	    cat %{_texmfdir}/texmf/web2c/updmap-hdr.cfg
	    for file in %{_texmf_updmap_d}/*; do
		cat \$file
	    done
	    if [ -f %{_texmflocaldir}/texmf/web2c/updmap-local.cfg ]; then
		cat %{_texmflocaldir}/texmf/web2c/updmap-local.cfg
	    fi
	) > %{_texmfdir}/web2c/updmap.cfg
	/usr/bin/updmap-sys --nohash > /dev/null
	rm -f /var/run/updmap
    else
	echo \$N > /var/run/updmap
    fi
) 9>/var/run/updmap.lock
EOF
chmod +x %{buildroot}%{_sbindir}/updmap.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/language.dat.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/language.dat ]; then
	N=`cat /var/run/language.dat`
	N=\`expr \$N + 1\`
    else
	N=1
    fi
    echo \$N > /var/run/language.dat
) 9>/var/run/language.dat.lock
EOF
chmod +x %{buildroot}%{_sbindir}/language.dat.pre

cat > %{buildroot}%{_sbindir}/language.dat.post << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/language.dat ]; then
	N=\`cat /var/run/language.dat\`
	N=\`expr \$N - 1\`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	(
	    cat %{_texmfdir}/tex/generic/config/language.us
	    for file in %{_texmf_language_dat_d}/*; do
		cat \$file
	    done
	    if [ -f %{_texmflocaldir}/tex/generic/config/language-local.dat ]; then
		cat %{_texmflocaldir}/tex/generic/config/language-local.dat
	    fi
	) > %{_texmfdir}/tex/generic/config/language.dat
	rm -f /var/run/language.dat
    else
	echo \$N > /var/run/language.dat
    fi
) 9>/var/run/language.dat.lock
EOF
chmod +x %{buildroot}%{_sbindir}/language.dat.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/language.def.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/language.def ]; then
	N=`cat /var/run/language.def`
	N=\`expr \$N + 1\`
    else
	N=1
    fi
    echo \$N > /var/run/language.def
) 9>/var/run/language.def.lock
EOF
chmod +x %{buildroot}%{_sbindir}/language.def.pre

cat > %{buildroot}%{_sbindir}/language.def.post << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/language.def ]; then
	N=\`cat /var/run/language.def\`
	N=\`expr \$N - 1\`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	(
	    cat %{_texmfdir}/tex/generic/config/language.us.def
	    for file in %{_texmf_language_def_d}/*; do
		cat \$file
	    done
	    if [ -f %{_texmflocaldir}/tex/generic/config/language-local.def ]; then
		cat %{_texmflocaldir}/tex/generic/config/language-local.def
	    fi
	    echo "%%%%%% No changes may be made beyond this point."
	    echo ""
	    echo "\\uselanguage {USenglish}             %%%%%% This MUST be the last line of the file"
	) > %{_texmfdir}/tex/generic/config/language.def
	rm -f /var/run/language.def
    else
	echo \$N > /var/run/language.def
    fi
) 9>/var/run/language.def.lock
EOF
chmod +x %{buildroot}%{_sbindir}/language.def.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/language.lua.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/language.lua ]; then
	N=`cat /var/run/language.lua`
	N=\`expr \$N + 1\`
    else
	N=1
    fi
    echo \$N > /var/run/language.lua
) 9>/var/run/language.lua.lock
EOF
chmod +x %{buildroot}%{_sbindir}/language.lua.pre

cat > %{buildroot}%{_sbindir}/language.lua.post << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/language.lua ]; then
	N=\`cat /var/run/language.lua\`
	N=\`expr \$N - 1\`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	(
	    cat %{_texmfdir}/tex/generic/config/language.us.lua
	    for file in %{_texmf_language_lua_d}/*; do
		cat \$file
	    done
	    if [ -f %{_texmflocaldir}/tex/generic/config/language-local.dat.lua ]; then
		cat %{_texmflocaldir}/tex/generic/config/language-local.dat.lua
	    fi
	) > %{_texmfdir}/tex/generic/config/language.dat.lua
	rm -f /var/run/language.lua
    else
	echo \$N > /var/run/language.lua
    fi
) 9>/var/run/language.lua.lock
EOF
chmod +x %{buildroot}%{_sbindir}/language.lua.post

#-----------------------------------------------------------------------
xz -d < %{SOURCE1} > %{buildroot}%{_tlpkgdir}/texlive.tlpdb

install -m755 %{SOURCE2} %{buildroot}%{_sbindir}/tlpobj2spec

mkdir -p %{buildroot}%{_sys_macros_dir}
cat > %{buildroot}%{_sys_macros_dir}/texlive.macros <<EOF
%%_tlpkgdir                      %{_tlpkgdir}
%%_tlpkgobjdir			 %{_tlpkgobjdir}
%%_texmfdir                      %{_texmfdir}
%%_texmfdistdir                  %{_texmfdistdir}
%%_texmflocaldir                 %{_texmflocaldir}
%%_texmfextradir                 %{_texmfextradir}
%%_texmffontsdir                 %{_texmffontsdir}
%%_texmfprojectdir               %{_texmfprojectdir}
%%_texmfvardir                   %{_texmfvardir}
%%_texmfconfdir                  %{_texmfconfdir}
%%_texmf_fmtutil_d               %{_texmf_fmtutil_d}
%%_texmf_updmap_d                %{_texmf_updmap_d}
%%_texmf_language_dat_d          %{_texmf_language_dat_d}
%%_texmf_language_def_d          %{_texmf_language_def_d}
%%_texmf_language_lua_d          %{_texmf_language_lua_d}

%%_texmf_enable_asymptote        %{_texmf_enable_asymptote}
%%_texmf_enable_xindy            %{_texmf_enable_xindy}
%%_texmf_with_system_dialog      %{_texmf_with_system_dialog}
%%_texmf_with_system_lcdf        %{_texmf_with_system_lcdf}
%%_texmf_with_system_poppler     %{_texmf_with_system_poppler}
%%_texmf_with_system_psutils     %{_texmf_with_system_psutils}
%%_texmf_with_system_t1lib       %{_texmf_with_system_t1lib}
%%_texmf_with_system_tex4ht      %{_texmf_with_system_tex4ht}
%%_texmf_with_system_teckit      %{_texmf_with_system_teckit}

%%_texmf_mktexlsr_pre            %{_sbindir}/mktexlsr.pre
%%_texmf_mktexlsr_post           %{_sbindir}/mktexlsr.post
%%_texmf_mtxrun_pre              %{_sbindir}/mtxrun.pre
%%_texmf_mtxrun_post             %{_sbindir}/mtxrun.post
%%_texmf_fmtutil_pre            %{_sbindir}/fmtutil.pre
%%_texmf_fmtutil_post           %{_sbindir}/fmtutil.post
%%_texmf_updmap_pre             %{_sbindir}/updmap.pre
%%_texmf_updmap_post            %{_sbindir}/updmap.post
%%_texmf_language_dat_pre       %{_sbindir}/language.dat.pre
%%_texmf_language_dat_post      %{_sbindir}/language.dat.post
%%_texmf_language_def_pre       %{_sbindir}/language.def.pre
%%_texmf_language_def_post      %{_sbindir}/language.def.post
%%_texmf_language_lua_pre       %{_sbindir}/language.lua.pre
%%_texmf_language_lua_post      %{_sbindir}/language.lua.post
EOF
