%define _texmfdir			%{_datadir}/texmf
%define _texmfdistdir			%{_datadir}/texmf-dist
%define _texmflocaldir			%{_datadir}/texmf-local
%define _texmfextradir			%{_datadir}/texmf-extra
%define _texmffontsdir			%{_datadir}/texmf-fonts
%define _texmfprojectdir		%{_datadir}/texmf-project
%define _texmfvardir			%{_localstatedir}/lib/texmf
%define _texmfconfdir			%{_sysconfdir}/texmf

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
Source1:	tlpobj2spec.pl
# intermediate, matching monolithic packages
# and useful for initial work
Source2:	texlive.tlpdb
BuildArch:	noarch

%description
TeX Live is an easy way to get up and running with the TeX document
production system. It provides a comprehensive TeX system. It includes
all the major TeX-related programs, macro packages, and fonts that are
free software, including support for many languages around the world.

%files
%{_datadir}/tlpkg
%{_sbindir}/mktexlsr.*
%{_sbindir}/tlpobj2spec
%{_sys_macros_dir}/texlive.macros

#-----------------------------------------------------------------------
%prep
%setup -q -n install-tl-%{version}

%build

%install
mkdir -p %{buildroot}%{_datadir}/tlpkg
cp -fpr tlpkg/TeXLive %{buildroot}%{_datadir}/tlpkg

mkdir -p %{buildroot}%{_sbindir}
cat > %{buildroot}%{_sbindir}/mktexlsr.pre << EOF
#!/bin/sh
(
    flock -n 9 || exit 1
    if [ -f /var/run/mktexlsr ]; then
	N=`cat /var/run/mktexlsr`
	N=`expr \$N + 1`
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
	N=`cat /var/run/mktexlsr`
	N=`expr \$N - 1`
    else
	N=0
    fi
    if [ \$N -lt 1 ]; then
	/usr/bin/mktexlsr /usr/share/texmf /usr/share/texmf-dist
	rm -f /var/run/mktexlsr
    else
	echo \$N > /var/run/mktexlsr
    fi
) 9>/var/run/mktexlsr.lock
EOF
chmod +x %{buildroot}%{_sbindir}/mktexlsr.post

install -m755 %{SOURCE1} %{buildroot}%{_sbindir}/tlpobj2spec

install -m644 %{SOURCE2} %{buildroot}%{_datadir}/tlpkg

mkdir -p %{buildroot}%{_sys_macros_dir}
cat > %{buildroot}%{_sys_macros_dir}/texlive.macros <<EOF
%%_texmfdir                      %{_texmfdir}
%%_texmfdistdir                  %{_texmfdistdir}
%%_texmflocaldir                 %{_texmflocaldir}
%%_texmfextradir                 %{_texmfextradir}
%%_texmffontsdir                 %{_texmffontsdir}
%%_texmfprojectdir               %{_texmfprojectdir}
%%_texmfvardir                   %{_texmfvardir}
%%_texmfconfdir                  %{_texmfconfdir}

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

%%_texmf_mktexlsr_preun          if [ \$1 = 0 ]; then %{_sbindir}/mktexlsr.pre; fi
%%_texmf_mktexlsr_postun         if [ \$1 = 0 ]; then %{_sbindir}/mktexlsr.post; fi
EOF
