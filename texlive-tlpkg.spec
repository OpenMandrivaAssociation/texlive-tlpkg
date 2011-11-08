%define _requires_exceptions		perl(Text::Unidecode)\\|perl(Tie::Watch)\\|perl(SelfLoader)

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
Version:	20111108
Release:	2
Summary:	The TeX formatting system
URL:		http://tug.org/texlive/
Group:		Publishing
License:	http://www.tug.org/texlive/LICENSE.TL
Source0:	http://mirrors.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
Source1:	http://mirrors.ctan.org/systems/texlive/tlnet/tlpkg/texlive.tlpdb.xz
Source2:	tlpobj2spec.pl
Source3:	fmtutil-hdr.cnf
Source4:	updmap-hdr.cfg
Source5:	texlive.post
Source6:	checkupdates.pl
BuildArch:	noarch

%post
    if [ ! -f %{_texmfconfdir}/web2c/updmap.cfg ]; then
	cp -f %{_texmfdir}/web2c/updmap-hdr.cfg %{_texmfconfdir}/web2c/updmap.cfg
    fi

%description
TeX Live is an easy way to get up and running with the TeX document
production system. It provides a comprehensive TeX system. It includes
all the major TeX-related programs, macro packages, and fonts that are
free software, including support for many languages around the world.

%files
%dir %{_tlpkgdir}
%{_tlpkgdir}/TeXLive
%{_texmfdir}/web2c/fmtutil-hdr.cnf
%{_texmfdir}/web2c/updmap-hdr.cfg
%dir %{_tlpkgobjdir}
%dir %{_texmf_fmtutil_d}
%dir %{_texmf_updmap_d}
%dir %{_texmf_language_dat_d}
%dir %{_texmf_language_def_d}
%dir %{_texmf_language_lua_d}
%ghost %{_texmfconfdir}/web2c/updmap.cfg
%{_sbindir}/*.pre
%{_sbindir}/*.post
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

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/mktexlsr.post << EOF
#!/bin/sh
exec %{_bindir}/perl %{_sbindir}/texlive.post
EOF
chmod +x %{buildroot}%{_sbindir}/mktexlsr.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/mtxrun.post << EOF
#!/bin/sh
exec %{_bindir}/perl %{_sbindir}/texlive.post
EOF
chmod +x %{buildroot}%{_sbindir}/mtxrun.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/fmtutil.post << EOF
#!/bin/sh
exec %{_bindir}/perl %{_sbindir}/texlive.post
EOF
chmod +x %{buildroot}%{_sbindir}/fmtutil.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/updmap.post << EOF
#!/bin/sh
exec %{_bindir}/perl %{_sbindir}/texlive.post
EOF
chmod +x %{buildroot}%{_sbindir}/updmap.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/language.dat.post << EOF
#!/bin/sh
exec %{_bindir}/perl %{_sbindir}/texlive.post
EOF
chmod +x %{buildroot}%{_sbindir}/language.dat.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/language.def.post << EOF
#!/bin/sh
exec %{_bindir}/perl %{_sbindir}/texlive.post
EOF
chmod +x %{buildroot}%{_sbindir}/language.def.post

#-----------------------------------------------------------------------
cat > %{buildroot}%{_sbindir}/language.lua.post << EOF
#!/bin/sh
exec %{_bindir}/perl %{_sbindir}/texlive.post
EOF
chmod +x %{buildroot}%{_sbindir}/language.lua.post

#-----------------------------------------------------------------------
pushd %{buildroot}%{_sbindir}
    for script in mktexlsr mtxrun fmtutil updmap language.dat language.def language.lua
    do
	ln -sf $script.post $script.pre
    done
popd

#-----------------------------------------------------------------------
xz -d < %{SOURCE1} > %{buildroot}%{_tlpkgdir}/texlive.tlpdb
install -m755 %{SOURCE2} %{buildroot}%{_sbindir}/tlpobj2spec
install -D -m644 %{SOURCE3} %{buildroot}%{_texmfdir}/web2c/fmtutil-hdr.cnf
install -D -m644 %{SOURCE4} %{buildroot}%{_texmfdir}/web2c/updmap-hdr.cfg
install -D -m644 %{SOURCE4} %{buildroot}%{_texmfconfdir}/web2c/updmap.cfg
install -m755 %{SOURCE5} %{buildroot}%{_sbindir}/texlive.post

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
%%_texmf_fmtutil_pre             %{_sbindir}/fmtutil.pre
%%_texmf_fmtutil_post            %{_sbindir}/fmtutil.post
%%_texmf_updmap_pre              %{_sbindir}/updmap.pre
%%_texmf_updmap_post             %{_sbindir}/updmap.post
%%_texmf_language_dat_pre        %{_sbindir}/language.dat.pre
%%_texmf_language_dat_post       %{_sbindir}/language.dat.post
%%_texmf_language_def_pre        %{_sbindir}/language.def.pre
%%_texmf_language_def_post       %{_sbindir}/language.def.post
%%_texmf_language_lua_pre        %{_sbindir}/language.lua.pre
%%_texmf_language_lua_post       %{_sbindir}/language.lua.post
EOF
