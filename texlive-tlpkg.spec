%define __noautoreq			'perl\\(Text::Unidecode\\)|perl\\(Tie::Watch\\)|perl\\(SelfLoader\\)'

%define _tlpkgdir			%{_datadir}/tlpkg
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
%define _texmf_enable_biber		0
%define _texmf_enable_xindy		0
%define _texmf_with_system_dialog	1
%define _texmf_with_system_lcdf		0
%define _texmf_with_system_poppler	1
%define _texmf_with_system_psutils	1
%define _texmf_with_system_t1lib	1
%define _texmf_with_system_tex4ht	0
%define _texmf_with_system_teckit	0

%bcond_with urpmi

Name:		texlive-tlpkg
Version:	20180108
Release:	5
Summary:	The TeX formatting system
URL:		http://tug.org/texlive/
Group:		Publishing
License:	http://www.tug.org/texlive/LICENSE.TL
Source0:	http://mirrors.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
Source1:	http://mirrors.ctan.org/systems/texlive/tlnet/tlpkg/texlive.tlpdb.xz
Source2:	tlpobj2spec.pl
Source3:	fmtutil-hdr.cnf
Source4:	updmap-hdr.cfg
Source6:	checkupdates.pl
Source7:	texlive.macros
Source8:	tlmgr
BuildArch:	noarch

Requires:	perl-Proc-Daemon
Requires:	perl-Proc-PID-File
Requires:	perl-XML-XPath

%post
    if [ ! -f %{_texmfconfdir}/web2c/updmap.cfg ]; then
	cp -f %{_texmfdistdir}/web2c/updmap-hdr.cfg %{_texmfconfdir}/web2c/updmap.cfg
    fi

%description
TeX Live is an easy way to get up and running with the TeX document
production system. It provides a comprehensive TeX system. It includes
all the major TeX-related programs, macro packages, and fonts that are
free software, including support for many languages around the world.

%files
%dir %{_tlpkgdir}
%{_tlpkgdir}/TeXLive/
%{_texmfdistdir}/web2c/fmtutil-hdr.cnf
%{_texmfdistdir}/web2c/updmap-hdr.cfg
%dir %{_texmf_fmtutil_d}
%dir %{_texmf_updmap_d}
%dir %{_texmf_language_dat_d}
%dir %{_texmf_language_def_d}
%dir %{_texmf_language_lua_d}
%ghost %{_texmfconfdir}/web2c/updmap.cfg
%{_rpmmacrodir}/macros.texlive
%if %{with urpmi}
%{_bindir}/tlmgr
%{_sbindir}/tlmgr
%{_sbindir}/texlive.post
%{_sysconfdir}/pam.d/tlmgr
%{_sysconfdir}/console.apps/tlmgr
%endif

%transfiletriggerin -- /usr/share/texmf-dist
if [ -x "/usr/bin/mktexlsr" ]
then
    /usr/bin/mktexlsr 2>/dev/null 1>&2 || :
    if [ -x "/usr/bin/updmap-sys" ]
    then
	echo Y | /usr/bin/updmap-sys --syncwithtrees 2>/dev/null 1>&2 || :
    fi
    if [ -x "/usr/bin/mtxrun" ]
    then
	/usr/bin/mtxrun --generate 2>/dev/null 1>&2 || :
    fi
    if [ -x "/usr/bin/fmtutil-sys" ]
    then
	/usr/bin/fmtutil-sys --all 2>/dev/null 1>&2 || :
    fi
fi


#-----------------------------------------------------------------------
%prep
%setup -q -n install-tl-%{version}

%build

%install
mkdir -p %{buildroot}%{_tlpkgdir}
cp -fpr tlpkg/TeXLive %{buildroot}%{_tlpkgdir}

mkdir -p %{buildroot}%{_texmf_fmtutil_d}
mkdir -p %{buildroot}%{_texmf_updmap_d}
mkdir -p %{buildroot}%{_texmf_language_dat_d}
mkdir -p %{buildroot}%{_texmf_language_def_d}
mkdir -p %{buildroot}%{_texmf_language_lua_d}

install -D -m644 %{SOURCE3} %{buildroot}%{_texmfdistdir}/web2c/fmtutil-hdr.cnf
install -D -m644 %{SOURCE4} %{buildroot}%{_texmfdistdir}/web2c/updmap-hdr.cfg
install -D -m644 %{SOURCE4} %{buildroot}%{_texmfconfdir}/web2c/updmap.cfg
install -D -m644 %{SOURCE7} %{buildroot}%{_rpmmacrodir}/macros.texlive

# (tpg) fugly workaround for tons of texlive patches that still uses %post and call texlive.post binary
mkdir -p %{buildroot}%{_sbindir}
echo "#!/bin/true" > %{buildroot}%{_sbindir}/texlive.post
chmod 755 %{buildroot}%{_sbindir}/texlive.post

%if %{with urpmi}
# install tlmgr like application
install -D -m755 %{SOURCE8} %{buildroot}%{_sbindir}/tlmgr
mkdir -p %{buildroot}%{_sysconfdir}/pam.d
ln -sf %{_sysconfdir}/pam.d/mandriva-simple-auth %{buildroot}%{_sysconfdir}/pam.d/tlmgr
mkdir -p %{buildroot}%{_sysconfdir}/console.apps
cat > %{buildroot}%{_sysconfdir}/console.apps/tlmgr << EOF
USER=root
PROGRAM=%{_sbindir}/tlmgr
FALLBACK=false
SESSION=true
EOF
mkdir -p %{buildroot}%{_bindir}
ln -sf %{_bindir}/consolehelper %{buildroot}%{_bindir}/tlmgr
%endif
