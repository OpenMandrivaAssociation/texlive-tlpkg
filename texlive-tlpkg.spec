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
%define _texmf_enable_xindy		0
%define _texmf_with_system_dialog	1
%define _texmf_with_system_lcdf		0
%define _texmf_with_system_poppler	1
%define _texmf_with_system_psutils	1
%define _texmf_with_system_t1lib	1
%define _texmf_with_system_tex4ht	0
%define _texmf_with_system_teckit	0

Name:		texlive-tlpkg
Version:	20120411
Release:	3
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
Source7:	texlive.macros
Source8:	tlmgr
BuildArch:	noarch

%post
    if [ ! -f %{_texmfconfdir}/web2c/updmap.cfg ]; then
	cp -f %{_texmfdir}/web2c/updmap-hdr.cfg %{_texmfconfdir}/web2c/updmap.cfg
    fi
    %{_sbindir}/texlive.post

%description
TeX Live is an easy way to get up and running with the TeX document
production system. It provides a comprehensive TeX system. It includes
all the major TeX-related programs, macro packages, and fonts that are
free software, including support for many languages around the world.

%files
%dir %{_tlpkgdir}
%{_tlpkgdir}/TeXLive/
%{_texmfdir}/web2c/fmtutil-hdr.cnf
%{_texmfdir}/web2c/updmap-hdr.cfg
%dir %{_texmf_fmtutil_d}
%dir %{_texmf_updmap_d}
%dir %{_texmf_language_dat_d}
%dir %{_texmf_language_def_d}
%dir %{_texmf_language_lua_d}
%ghost %{_texmfconfdir}/web2c/updmap.cfg
%{_bindir}/tlmgr
%{_sbindir}/tlmgr
%{_sbindir}/texlive.post
%{_sysconfdir}/rpm/macros.d/texlive.macros
%{_sysconfdir}/pam.d/tlmgr
%{_sysconfdir}/console.apps/tlmgr

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

install -D -m644 %{SOURCE3} %{buildroot}%{_texmfdir}/web2c/fmtutil-hdr.cnf
install -D -m644 %{SOURCE4} %{buildroot}%{_texmfdir}/web2c/updmap-hdr.cfg
install -D -m644 %{SOURCE4} %{buildroot}%{_texmfconfdir}/web2c/updmap.cfg
install -D -m755 %{SOURCE5} %{buildroot}%{_sbindir}/texlive.post
install -D -m644 %{SOURCE7} %{buildroot}/etc/rpm/macros.d/texlive.macros

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


%changelog
* Fri Apr 13 2012 Paulo Andrade <pcpa@mandriva.com.br> 20120411-1
+ Revision: 790501
- Update to match main texlive package and latest upstream perl scripts.
- Update metadata for last TeX Live packages synchronization.
- Run equivalent of urpmi.update -a at startup of tlmgr.

* Fri Mar 23 2012 Paulo Andrade <pcpa@mandriva.com.br> 20120109-5
+ Revision: 786501
- Rebuild with newer tlmgr functionalities and bug fixes.
- Do not pass arguments to mktexlsr or it will fail paper configuration.
- Add a menubar to tlmgr with quit, paper settings and about options.
- The paper settings option is expected to be fully complete.
- Add tlmgr initial infrastructure to translate all strings.
- Correct some minor inconsistencies in the tlmgr interface.
- Implement tlmgr show_extended_info double clock on package name dialog.

* Thu Mar 22 2012 Paulo Andrade <pcpa@mandriva.com.br> 20120109-4
+ Revision: 786165
- Remove macros and scripts kept for clean upgrades of older cooker.
- Add new tlmgr script that mimics the upstream TeX Live package manager.

* Fri Mar 16 2012 Paulo Andrade <pcpa@mandriva.com.br> 20120109-3
+ Revision: 785394
- Do not call setlogsock when logging errors.

* Tue Mar 13 2012 Paulo Andrade <pcpa@mandriva.com.br> 20120109-2
+ Revision: 784493
- Use a timeout for programs run by texlive.post.
- Build the extra support for printing any error messages to syslog.
- Update metadata to clarify some files are not tagged doc/source on purpose.
- Update metadata after last synch with upstream TeX Live packages.
- Update meta data for partial texlive update.
- Update metadata and defaults.
- Add epoch to all collection packages to correct previous wrong version.
- Update metainformation after last texlive upstream synch.
- Update for last texlive synch with upstream.
- Correct tlpobj2spec.pl to handle multiline format lines.
- Add extra quirks to simplify packages updates.
- Change checkupdates.pl to detect/tell about not properly checked subpackages.
- Update metadata for latest synch with upstream texlive.
- In this commit, a series of quirks were added to simplify updates.
- Add simple script to handle most common tasks during an update.
- Update metadata for latest synch with upstream TeX Live.
- Commented use of ExtraRequires in tlpobj2spec.pl.
- Add workaround to newer rpm bug that broke all hyphenation files.
- Update metadata to after synchronization with texlive.
- Record error log messages from texlive configuration.

* Mon Jan 09 2012 Paulo Andrade <pcpa@mandriva.com.br> 20120109-1
+ Revision: 759153
- Update metainformation for last synch with upstream texlive.
- Add %%ExtraRequires hash to help in better providing tetex-* packages.
- Update to prevent some heredoc failures in newer rpm
- Do not install texlive.tlpdb neither tlpobj2spec packaging tool
- Update metadata information for last update/synch with upstream texlive.
- Update information for new packages and special cases in checkupdates.pl

* Mon Dec 05 2011 Zé <ze@mandriva.org> 20111122-7
+ Revision: 737784
- theres no pre section, use simple requires
- rpm isnt able to handle = conflicts, bug already reported

* Fri Dec 02 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111122-6
+ Revision: 737278
- Hardcode rpm macros dir as macro is expanding to incorrect place.

* Fri Dec 02 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111122-5
+ Revision: 737273
- Add logic to allow texlive.post to block while configuring texlive.

* Mon Nov 28 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111122-4
+ Revision: 734803
- Revert code to attempt to have faster texlive.post scriptlet.

* Sun Nov 27 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111122-3
+ Revision: 734073
- Write updmap.cfg to /etc/texmf and /usr/share/texmf/web2c.
- Use a different approach to reduce wait in texlive.post.

* Sat Nov 26 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111122-2
+ Revision: 733664
- Add some pre requires due to issues with post of texlive packages failing.

* Tue Nov 22 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111122-1
+ Revision: 732498
- Update to latest texlive packages
- Work around issue with texlive.macros not being properly generated

* Thu Nov 17 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111109-4
+ Revision: 731482
- Allow clean update from previous texlive and texlive-texmf.

* Sun Nov 13 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111109-3
+ Revision: 730477
- Correct bug not printing some headers in texlive config files.

* Sun Nov 13 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111109-2
+ Revision: 730402
- Create updmap.cfg in TEXMFSYSCONFIG
- Use rename macro instead of mix of provides/conflicts/obsoletes

* Thu Nov 10 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111109-1
+ Revision: 729622
- Update checkupdates script and to latest tlpdb metadata.

* Thu Nov 10 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111108-4
+ Revision: 729609
- Rebuild with removed Obsoletes that does not work as expected.
- Remove obsoletes of texlive texmf packages.
- Do not keep running texlive.post after a full uninstall.

* Wed Nov 09 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111108-3
+ Revision: 729338
- Force obsolete of previous monolithic texlive package

* Tue Nov 08 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111108-2
+ Revision: 729176
- Revert to more reliable original post concept.

* Tue Nov 08 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111108-1
+ Revision: 729154
- Update to newer texlive metadata

* Tue Nov 08 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111030-3
+ Revision: 729040
- Correct pre scripts logic
- Handle extra spaces when removing ending dot from shortdesc to generate summary.
- texlive-tlpkg

* Sat Nov 05 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111030-2
+ Revision: 720016
- Rebuild hoping it works without some perl modules in contrib.

* Sat Nov 05 2011 Paulo Andrade <pcpa@mandriva.com.br> 20111030-1
+ Revision: 719992
- Update texlive-jadetex provides/conflicts as now it uses the real version.
- Update to latest version of texlives rpm package management infrastructure.
- Correct wrong macro definition and add kpathsea as requires.
- Add new checkupdates.pl script.
- Do not use %%_vendor prefix for config.d directories
- Update to latest customizations of the spec generator.
- Update to latest version of spec skeleton generator and rpm macros.
- Synchronize with latest version of script used to generate skeleton specs.
- Correct some typos and wrong syntax in generation of metadata.
- Redesign way pre and post are executed.
- Update script to generate spec skeleton.
- First commit on incremental repackage of texlive.
- texlive-tlpkg

