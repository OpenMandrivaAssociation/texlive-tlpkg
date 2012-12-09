#!/usr/bin/perl

use warnings;
use strict;
use lib('tlpkg', '/usr/share/tlpkg');

use TeXLive::TLPOBJ;

my $arch = `uname -m`;
chomp($arch);
$arch = "i386" if ($arch =~ m/i[456]86/);
$arch .= "-linux";

# texlive => rpm
my %Tags = (
    'jadetex'	=>	"%rename jadetex",
    'kpathsea'	=>	"%rename kpathsea",
    'pdfjam'	=>	"%rename pdfjam",
    'latexdiff'	=>	"%rename latexdiff",
    'pstools'	=>	"%rename ps2eps",
    'dvipdfm'	=>	"%rename tetex-dvipdfm, %rename texlive-texmf-dvipdfm",
    'dviljk'	=>	"%rename tetex-dvilj, %rename texlive-dvilj",
    'dvips'	=>	"%rename tetex-dvips, %rename texlive-texmf-dvips",
    'xdvi'	=>	"%rename tetex-xdvi, %rename xdvik",
    'latex'	=>	"%rename texlive-latex-bin",
    'context'	=>	"%rename texlive-texmf-contex",
    'scheme-tetex'=>	"%rename tetex, %rename texlive-dviutils",
    'metafont'	=>	"%rename tetex-mfwin, %rename texlive-mfwin",
    'xmltex'	=>	"%rename xmltex",
    'vlna'	=>	"%rename vlna",
    'cm-super'	=>	"%rename tetex-cmsuper, %rename texlive-texmf-cmsuper",
    'tex4ht'	=>	"%rename tex4ht",
    'collection-latexextra' =>	"%rename tetex-latex, %rename texlive-texmf-latex",
    'collection-fontsextra'=>"%rename texlive-fontsextra",
    'collection-fontsrecommended'=>"%rename texlive-fonts, %rename texlive-texmf-fonts"
);
# to be used when using a system package
my %System = (
    'lcdftypetools'=> 'lcdf-typetools',
    'psutils'	=>	'psutils',
    'tex4ht'	=>	'tex4ht',
);
# to be used when renaming/merging packages
my %Requires = (
    'latex-bin'	=>	"latex",
    'latex-bin.bin'=>	"latex.bin",
);
# extra missing requires when translating tlpobj and adding rpm provides
#my %ExtraRequires = (
#    'collection-latexextra' => "collection-latexrecommended",
#);
my %special = (
  '%{_texmfdir}/web2c/fmtutil.cnf'			=>	"%config(noreplace) ",
  '%{_texmfdir}/web2c/updmap.cfg'			=>	"%config(noreplace) ",
  '%{_texmfdir}/tex/generic/config/language.dat'	=>	"%config(noreplace) ",
  '%{_texmfdir}/tex/generic/config/language.dat.lua'	=>	"%config(noreplace) ",
  '%{_texmfdir}/tex/generic/config/language.def'	=>	"%config(noreplace) ",
);
my @block = (
    'scheme-tetex',
    'collection-latexextra'
);

########################################################################
# quirks defs begin
my %quirk_epoch = (
    'l3kernel'					=>	1,
    'l3packages'				=>	1,
    'gost'					=>	1,
    'japanese-otf'				=>	1,
    'japanese-otf-uptex'			=>	1,
    'tcolorbox'					=>	1,
    'collection-basic'				=>	1,
    'collection-bibtexextra'			=>	1,
    'collection-binextra'			=>	1,
    'collection-context'			=>	1,
    'collection-documentation-arabic'		=>	1,
    'collection-documentation-base'		=>	1,
    'collection-documentation-bulgarian'	=>	1,
    'collection-documentation-chinese'		=>	1,
    'collection-documentation-czechslovak'	=>	1,
    'collection-documentation-dutch'		=>	1,
    'collection-documentation-english'		=>	1,
    'collection-documentation-finnish'		=>	1,
    'collection-documentation-french'		=>	1,
    'collection-documentation-german'		=>	1,
    'collection-documentation-italian'		=>	1,
    'collection-documentation-japanese'		=>	1,
    'collection-documentation-korean'		=>	1,
    'collection-documentation-mongolian'	=>	1,
    'collection-documentation-polish'		=>	1,
    'collection-documentation-portuguese'	=>	1,
    'collection-documentation-russian'		=>	1,
    'collection-documentation-serbian'		=>	1,
    'collection-documentation-slovenian'	=>	1,
    'collection-documentation-spanish'		=>	1,
    'collection-documentation-thai'		=>	1,
    'collection-documentation-turkish'		=>	1,
    'collection-documentation-ukrainian'	=>	1,
    'collection-documentation-vietnamese'	=>	1,
    'collection-fontsextra'			=>	1,
    'collection-fontsrecommended'		=>	1,
    'collection-fontutils'			=>	1,
    'collection-formatsextra'			=>	1,
    'collection-games'				=>	1,
    'collection-genericextra'			=>	1,
    'collection-genericrecommended'		=>	1,
    'collection-htmlxml'			=>	1,
    'collection-humanities'			=>	1,
    'collection-langafrican'			=>	1,
    'collection-langarabic'			=>	1,
    'collection-langarmenian'			=>	1,
    'collection-langcjk'			=>	1,
    'collection-langcroatian'			=>	1,
    'collection-langcyrillic'			=>	1,
    'collection-langczechslovak'		=>	1,
    'collection-langdanish'			=>	1,
    'collection-langdutch'			=>	1,
    'collection-langenglish'			=>	1,
    'collection-langfinnish'			=>	1,
    'collection-langfrench'			=>	1,
    'collection-langgerman'			=>	1,
    'collection-langgreek'			=>	1,
    'collection-langhebrew'			=>	1,
    'collection-langhungarian'			=>	1,
    'collection-langindic'			=>	1,
    'collection-langitalian'			=>	1,
    'collection-langlatin'			=>	1,
    'collection-langlatvian'			=>	1,
    'collection-langlithuanian'			=>	1,
    'collection-langmongolian'			=>	1,
    'collection-langnorwegian'			=>	1,
    'collection-langother'			=>	1,
    'collection-langpolish'			=>	1,
    'collection-langportuguese'			=>	1,
    'collection-langspanish'			=>	1,
    'collection-langswedish'			=>	1,
    'collection-langtibetan'			=>	1,
    'collection-langturkmen'			=>	1,
    'collection-langvietnamese'			=>	1,
    'collection-latex'				=>	1,
    'collection-latexextra'			=>	1,
    'collection-latexrecommended'		=>	1,
    'collection-luatex'				=>	1,
    'collection-mathextra'			=>	1,
    'collection-metapost'			=>	1,
    'collection-music'				=>	1,
    'collection-omega'				=>	1,
    'collection-pictures'			=>	1,
    'collection-plainextra'			=>	1,
    'collection-pstricks'			=>	1,
    'collection-publishers'			=>	1,
    'collection-science'			=>	1,
    'collection-texinfo'			=>	1,
    'collection-xetex'				=>	1,
    'euro-ce'					=>	1,
);
my %quirk_prep = (
    'kpathsea'			=>	"\
perl -pi -e 's%^(TEXMFMAIN\\s+= ).*%\$1%{_texmfdir}%;'			  \\\
	 -e 's%^(TEXMFDIST\\s+= ).*%\$1%{_texmfdistdir}%;'		  \\\
	 -e 's%^(TEXMFLOCAL\\s+= ).*%\$1%{_texmflocaldir}%;'		  \\\
	 -e 's%^(TEXMFSYSVAR\\s+= ).*%\$1%{_texmfvardir}%;'		  \\\
	 -e 's%^(TEXMFSYSCONFIG\\s+= ).*%\$1%{_texmfconfdir}%;'		  \\\
	 -e 's%^(TEXMFHOME\\s+= ).*%\$1\\\$HOME/texmf%;'			  \\\
	 -e 's%^(TEXMFVAR\\s+= ).*%\$1\\\$HOME/.texlive2011/texmf-var%;'	  \\\
	 -e 's%^(TEXMFCONFIG\\s+= ).*%\$1\\\$HOME/.texlive2011/texmf-config%;'\\\
	 -e 's%^(OSFONTDIR\\s+= ).*%\$1%{_datadir}/fonts%;'		  \\\
	texmf/web2c/texmf.cnf
",
    'tetex'			=>	"\
perl -pi -e 's|\\\$TEXMFROOT/tlpkg|%{_datadir}/tlpkg|;'		\\\
    texmf/scripts/tetex/updmap.pl\n",
    'luatex'			=>	"\
perl -pi -e 's%^(\\s*TEXMFMAIN\\s+=\\s+\").*%\$1%{_texmfdir}\",%;'				\\\
	 -e 's%\\bTEXMFCONTEXT\\b%TEXMFDIST%g;'						\\\
	 -e 's%^(\\s*TEXMFDIST\\s+=\\s+).*%\$1\"%{_texmfdistdir}\",%;'			\\\
	 -e 's%^(\\s*TEXMFLOCAL\\s+=\\s+).*%\$1\"%{_texmflocaldir}\",%;'			\\\
	 -e 's%^(\\s*TEXMFSYSVAR\\s+=\\s+).*%\$1\"%{_texmfvardir}\",%;'			\\\
	 -e 's%^(\\s*TEXMFSYSCONFIG\\s+=\\s+).*%\$1\"%{_texmfconfdir}\",%;'			\\\
	 -e 's%^(\\s*TEXMFHOME\\s+=\\s+\").*%\$1\\\$HOME/texmf\",%;'				\\\
	 -e 's%^(\\s*TEXMFVAR\\s+=\\s+\").*%\$1\\\$HOME/.texlive2011/texmf-var\",%;'		\\\
	 -e 's%^(\\s*TEXMFCONFIG\\s+=\\s+\").*%\$1\\\$HOME/.texlive2011/texmf-config\",%;'	\\\
	 -e 's%^(\\s*FONTCONFIG_PATH\\s+=\\s+\").*%\$1%{_sysconfdir}/fonts\",%;'		\\\
	 -e 's|^local texmflocal.*\$||;'							\\\
	 -e 's|^texmflocal.*\$||;'							\\\
	texmf/web2c/texmfcnf.lua\n",
);
my %quirk_requires = (
    'cslatex'			=>	"Requires(post):	texlive-csplain\n",
    'csplain'			=>	"Requires(post):	texlive-cs\n",
    'tetex'			=>	"# updmap requires texconfig/tcfmgr
Requires(post):	texlive-texconfig
# pdftex requires updmap
Requires(post):	texlive-pdftex.bin\n",
);
my %quirk_provides_bin = (
    'checkcites'		=>	1,
    'context'			=>	1,
    'findhyph'			=>	1,
    'jfontmaps'			=>	1,
    'match_parens'		=>	1,
    'mptopdf'			=>	1,
    'pdfcrop'			=>	1,
    'tetex'			=>	1,
    'texlive-scripts'		=>	1,
    'typeoutfileinfo'		=>	1,
);
my %quirk_bin_files = (
    'checkcites'		=>	"%{_bindir}/checkcites\n",
    'context'			=>	"%{_bindir}/*\n",
    'findhyph'			=>	"%{_bindir}/findhyph\n",
    'jfontmaps'			=>	"%{_bindir}/updmap-setup-kanji\n",
    'match_parens'		=>	"%{_bindir}/match_parens\n",
    'mptopdf'			=>	"%{_bindir}/mptopdf\n",
    'pdfcrop'			=>	"%{_bindir}/pdfcrop\n%{_bindir}/rpdfcrop\n",
    'tetex'			=>	"%{_bindir}/allcm
%{_bindir}/allec
%{_bindir}/allneeded
%{_bindir}/dvi2fax
%{_bindir}/dvired
%{_bindir}/fmtutil
%{_bindir}/fmtutil-sys
%{_bindir}/kpsewhere
%{_bindir}/texconfig-dialog
%{_bindir}/texconfig-sys
%{_bindir}/texlinks
%{_bindir}/updmap
%{_bindir}/updmap-sys\n",
    # not really bin files
    'texlive-docindex'		=>	"%doc %{_tlpkgdir}/texmf
%doc %{_tlpkgdir}/texmf-dist\n",
    'texlive-scripts'		=>	"%{_bindir}/rungs\n",
    'typeoutfileinfo'		=>	"%{_bindir}/typeoutfileinfo\n",
    'xetex'			=>	"%{_bindir}/xelatex\n",
);
my %quirk_bin_source = (
    'context'			=>	"http://mirrors.ctan.org/systems/texlive/tlnet/archive/context.x86_64-linux.tar.xz",
    'jfontmaps'			=>	"http://mirrors.ctan.org/systems/texlive/tlnet/archive/jfontmaps.x86_64-linux.tar.xz",
    'tetex'			=>	"http://mirrors.ctan.org/systems/texlive/tlnet/archive/tetex.x86_64-linux.tar.xz"
);
my %quirk_install = (
    'checkcites'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/checkcites/checkcites.lua checkcites
popd\n",
    'context'			=>	"# only lua scripts
mkdir -p %{buildroot}%{_bindir}
cp -fpa bin/x86_64-linux/* %{buildroot}%{_bindir}\n",
    'dvipdfmx'			=>	"mkdir -p %{buildroot}%{_tlpkgdir}
cp -fpar tlpkg/tlpostcode %{buildroot}%{_tlpkgdir}\n",
    'findhyph'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/findhyph/findhyph findhyph
popd\n",
    'jfontmaps'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/jfontmaps/updmap-setup-kanji.pl updmap-setup-kanji
popd\n",
    'mptopdf'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/context/perl/mptopdf.pl mptopdf
popd\n",
    'match_parens'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/match_parens/match_parens match_parens
popd\n",
    'pdfcrop'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pdfcrop/pdfcrop.pl pdfcrop
    ln -sf pdfcrop rpdfcrop
popd\n",
    'tetex'			=>	"# only scripts
mkdir -p %{buildroot}%{_bindir}
cp -fpa bin/x86_64-linux/* %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdir}/scripts/tetex/updmap.pl updmap
    ln -sf %{_texmfdir}/scripts/tetex/updmap-sys.sh updmap-sys
popd\n",
    'texlive-docindex'		=>	"mkdir -p %{buildroot}%{_tlpkgdir}
cp -fpa doc.html %{buildroot}%{_tlpkgdir}
pushd %{buildroot}%{_tlpkgdir}
    # create symlinks so that links in doc.html (should) work
    ln -sf %{_texmfdir} texmf
    ln -sf %{_texmfdistdir} texmf-dist
popd\n",
    'texlive-scripts'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdir}/scripts/texlive/rungs.tlu rungs
popd
mkdir -p %{buildroot}%{_tlpkgdir}
cp -fa install-tl %{buildroot}%{_tlpkgdir}
cp -fpar tlpkg/installer %{buildroot}%{_tlpkgdir}\n",
    'typeoutfileinfo'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdir}/scripts/typeoutfileinfo/typeoutfileinfo.sh typeoutfileinfo
popd\n",
    'xetex'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf xetex xelatex
popd
mkdir -p %{buildroot}%{_tlpkgdir}
cp -fpar tlpkg/tlpostcode %{buildroot}%{_tlpkgdir}\n",
);
my %quirk_postun = (
    'aleph'			=>	"	rm -fr %{_texmfvardir}/web2c/aleph\n",
    'dvips'			=>	"	rm -fr %{_texmfvardir}/fonts/map/dvips\n",
    'luatex'			=>	"	rm -fr %{_texmfvardir}/web2c/luatex\n",
    'pdftex'			=>	"	rm -fr %{_texmfvardir}/fonts/map/pdftex
	rm -fr %{_texmfvardir}/web2c/pdftex\n",
    'metafont'			=>	"	rm -fr %{_texmfvardir}/web2c/metafont\n",
    'xetex'			=>	"	rm -fr %{_texmfvardir}/web2c/xetex\n"
);
# quirks defs end
########################################################################

our $_tmp;
select((select(STDOUT), $~ = "multilineformat")[0]);
STDOUT->format_lines_per_page (99999);	# no pages in this format

my $tlpobj = TeXLive::TLPOBJ->new();
unless ($tlpobj->from_file($ARGV[0])) {
    die("Error initializing tlpobj.\n");
}

my $file = $ARGV[0];
$file =~ s/\.tlpobj//;
my $tlpobjdoc = undef;
if (-f "$file.doc.tlpobj") {
    $tlpobjdoc = TeXLive::TLPOBJ->new();
    $tlpobjdoc->from_file("$file.doc.tlpobj");
}
my $tlpobjsrc = undef;
if (-f "$file.source.tlpobj") {
    $tlpobjsrc = TeXLive::TLPOBJ->new();
    $tlpobjsrc->from_file("$file.source.tlpobj");
}

chomp(my $enable_asymptote = `rpm --eval "%{_texmf_enable_asymptote}"`);
chomp(my $enable_xindy = `rpm --eval "%{_texmf_enable_xindy}"`);
chomp(my $with_system_lcdf = `rpm --eval "%{_texmf_with_system_lcdf}"`);
chomp(my $with_system_psutils = `rpm --eval "%{_texmf_with_system_psutils}"`);
chomp(my $with_system_t1lib = `rpm --eval "%{_texmf_with_system_t1lib}"`);

my $revision = $tlpobj->{'revision'};
$revision = "undef" unless ($revision);
print("# revision $revision\n");
my $category = $tlpobj->{'category'};
$category = "undef" unless ($category);
print("# category $category\n");
my $ctan = $tlpobj->{'cataloguedata'}{'ctan'};
$ctan = "undef" unless ($ctan);
print("# catalog-ctan $ctan\n");
my $date = $tlpobj->{'cataloguedata'}{'date'};
$date = "undef" unless ($date);
print("# catalog-date $date\n");
my $license = $tlpobj->{'cataloguedata'}{'license'};
$license = "undef" unless ($license);
print("# catalog-license $license\n");
my $version = $tlpobj->{'cataloguedata'}{'version'};
$version = "undef" unless ($version);
print("# catalog-version $version\n");

my $relocated = $tlpobj->{'relocated'};

my $name = $tlpobj->{'name'};
print("Name:\t\ttexlive-", $name, "\n");
my $binary = 0;
if ($name =~ /(.*)\.(.*)/) {
    my $platform = $2;
    if ($platform eq $arch) {
	$name = $1 . ".bin";
	$binary = 1;
    }
}
#--
if ($version eq "undef") {
    if ($date ne "undef") {
	$version = $date;
	$version =~ m/(\d\d\d\d)-(\d\d)-(\d\d)/;
	$version = "$1$2$3";
    }
    else {
	chomp($version = `date +%Y%m%d`);
    }
}
$version =~ s/[ \/]//g;
if ($quirk_epoch{$name}) {
    print("Epoch:\t\t$quirk_epoch{$name}\n");
}
print("Version:\t$version\n");
print("Release:\t1\n");
my $summary = $tlpobj->{'shortdesc'};
if (defined($summary) && $summary ne "") {
    $summary =~ s/\.+\s*$//;
    $summary =~ s/\b$arch\b/binary/g;
}
else {
    $summary = "TeXLive $name package";
}
print("Summary:\t$summary\n");
print("Group:\t\tPublishing\n");
#--
my $url = $tlpobj->{'cataloguedata'}{'ctan'};
if (defined($url) && $url ne "") {
    $url = "http://www.ctan.org/tex-archive$url";
}
else {
    $url = "http://tug.org/texlive";
}
print("URL:\t\t$url\n");
#--
if ($license ne "undef") {
    $license = uc($license);
}
else {
    $license = "http://www.tug.org/texlive/LICENSE.TL";
}
my $sourceN = 0;
print("License:\t$license\n");
print("Source$sourceN:\thttp://mirrors.ctan.org/systems/texlive/tlnet/archive/$name.tar.xz\n");
++$sourceN;
if ($tlpobjdoc) {
    print("Source$sourceN:\thttp://mirrors.ctan.org/systems/texlive/tlnet/archive/$name.doc.tar.xz\n");
    ++$sourceN;
}
if ($tlpobjsrc) {
    print("Source$sourceN:\thttp://mirrors.ctan.org/systems/texlive/tlnet/archive/$name.source.tar.xz\n");
    ++$sourceN;
}
if ($quirk_bin_source{$name}) {
    print("Source$sourceN:\t$quirk_bin_source{$name}\n");
    ++$sourceN;
}
print("BuildArch:\tnoarch\n");
print("BuildRequires:\ttexlive-tlpkg\n");
print("Requires(pre):\ttexlive-tlpkg\n");

my $man1pages = 0;
my $man5pages = 0;
my $infopages = 0;
my $copydoc = 0;
my $copysource = 0;

########################################################################
sub file_list {
    my ($doc, @list) = @_;
    foreach (@list) {
	if (m|/usr/share/texmf|) {
	    $_ =~ s|^/usr/share/texmf-dist|%{_texmfdistdir}|;
	    $_ =~ s|^/usr/share/texmf|%{_texmfdir}|;
	}
	elsif (m|^texmf|) {
	    $_ =~ s|^texmf-dist|%{_texmfdistdir}|;
	    $_ =~ s|^texmf|%{_texmfdir}|;
	}
	elsif (m|^RELOC|) {
	    $_ =~ s|^RELOC|%{_texmfdistdir}|;
	}
	else {
	    s/bin\/(x86_64|i386)-linux/\/usr\/bin/;
	    $_ =~ s|^tlpkg/||;
	    $_ = "%{_tlpkgdir}/$_" unless (m|^/|);
	}
	# Update for moved files or use macro
	if (/\.info$/) {
	    s/%{_texmf(dist)?dir}\/doc\/info\/(.*)\.info/%{_infodir}\/$2\.info\*/;
	    $infopages = 1;
	}
	if (/man\/man1/) {
	    $man1pages = 1;
	}
	if (/man\/man5/) {
	    $man5pages = 1;
	}
	if ($man1pages || $man5pages) {
	    s/%{_texmf(dist)?dir}\/doc\/man\/(man[15]\/.*\.[15]$)/%{_mandir}\/$2\*/;
	}
	s/\/usr\/bin/%{_bindir}/;
	s/\/usr\/share/%{_datadir}/;
	my $prefix = $special{$_};
	# japanese-otf-uptex has files with names like: morisawa.map(for udvips)
	# and escaping does not work, use '?'
	$_ =~ s/([\( \)])/?/g;

	# koma-script license agreement specifies that doc and source
	# must be distributed together
	if (/^%{_texmf(dist)?dir}\/doc\//) {
	    $copydoc = 1;
	}
	elsif (/^%{_texmf(dist)?dir}\/source\//) {
	    $copysource = 1;
	}

	if ($prefix) {
	    print("$prefix$doc$_\n");
	}
	else {
	    print("$doc$_\n");
	}
    }
}

sub should_skip {
    my ($package) = @_;
    return 1 if (!$enable_asymptote && $package =~ /^asymptote/);
    return 1 if (!$enable_xindy && $package =~ /^xindy/);
    return 1 if ($with_system_lcdf && $package =~ /^lcdftypetools/);
    return 1 if ($with_system_psutils &&
		 ($package =~ /^psutils/ ||
		  $package =~ /^getafm/));
    return 1 if ($with_system_t1lib &&
		 $package =~ /^t1utils/);
    return 1 if ($package =~ /texworks/ ||
		 $package eq "texlive-msg-translations" ||
		 $package =~ /wintools/);
    return 1 if ($package =~ m/00texlive\./ ||
		 $package =~ m/texlive.infra/);
    return 0;
}

########################################################################
my @updmap = $tlpobj->updmap_cfg_lines();
my @fmtutil = $tlpobj->fmtutil_cnf_lines();
my @datlines = $tlpobj->language_dat_lines();
for (my $i = 0; $i <= $#datlines; ++$i) {
    $datlines[$i] =~ s/%/\\%%/g;
    $datlines[$i] =~ s/(\$\\)/\\$1/g;
}
my @deflines = $tlpobj->language_def_lines();
for (my $i = 0; $i <= $#deflines; ++$i) {
    $deflines[$i] =~ s/%/\\%%/g;
    $deflines[$i] =~ s/(\$\\)/\\$1/g;
}
my @lualines = $tlpobj->language_lua_lines();

my $needs_post = 0;
my $mktexlsr = 0;
if (!$binary) {
    $needs_post = $name =~ /context/;
    my @runfiles = $tlpobj->runfiles();
    $mktexlsr = 1 if (grep(/texmf-dist|RELOC/, @runfiles));
    if (!$mktexlsr) {
	$mktexlsr = 1 if (grep(/texmf\//, @runfiles));
    }
}
if (!$needs_post) {
    $needs_post = ($mktexlsr ||
		   $#updmap > 0 || $#fmtutil > 0 ||
		   $#datlines > 0 || $#deflines > 0 || $#lualines > 0);
}
my %required;
if ($mktexlsr) {
    if ($name ne 'kpathsea') {
	print("Requires(post):\ttexlive-kpathsea\n");
    }
    else {
	print("Requires(post):\ttexlive-kpathsea.bin\n");
	print("Requires(postun):texlive-kpathsea.bin\n");
    }
    $required{'kpathsea'} = 1;
    $required{'kpathsea.ARCH'} = 1;
}
if ($name ne "tetex" && ($#updmap > 0 || $#fmtutil > 0)) {
    print("Requires(post):\ttexlive-tetex\n");
    $required{'tetex'} = 1;
    $required{'tetex.ARCH'} = 1;
}
if ($name ne "hyphen-base" &&
    ($#datlines > 0 || $#deflines > 0 || $#lualines > 0)) {
    print("Requires(post):\ttexlive-hyphen-base\n");
    $required{'hyphen-base'} = 1;
}
if (!$binary && $name =~ /context/ && $name ne "context") {
    print("Requires(post):\ttexlive-context\n");
    $required{'context'} = 1;
    $required{'context.ARCH'} = 1;
}
if ($quirk_requires{$name}) {
    print($quirk_requires{$name});
}

foreach my $requires ($tlpobj->depends()) {
    next if ($name eq $requires || $required{$requires});
    if (should_skip($requires)) {
	if (defined($System{$requires})) {
	    unless (defined($required{$requires})) {
		print("Requires:\t" . $System{$requires} . "\n");
		$required{$requires} = 1;
	    }
	}
	next;
    }
    if ($requires =~ m/^(.*)\.ARCH$/) {
	$requires = "$1.bin";
	if ($1 eq $name && $quirk_provides_bin{$name}) {
	    print("Provides:\ttexlive-$requires = %{EVRD}\n");
	    next;
	}
    }
    if (defined($Requires{$requires})) {
	$requires = $Requires{$requires};
    }
    unless (defined($required{$requires})) {
	print("Requires:\ttexlive-$requires\n");
	$required{$requires} = 1;
    }
}
#if ($ExtraRequires{$name}) {
#    foreach (split(", ", $ExtraRequires{$name})) {
#	unless (defined($required{$_})) {
#	    $required{$_} = 1;
#	    print("Requires:\ttexlive-$_\n");
#	}
#    }
#}
if ($Tags{$name}) {
    foreach (split(", ", $Tags{$name})) {
	print("$_\n");
    }
}

my $description = $tlpobj->{'longdesc'};
if (!defined($description) || $description eq "") {
    $description = "TeXLive $name package.";
}
else {
    $description .= "." unless ($description =~ m/\.$/);
    $description =~ s/\b$arch\b/binary/g;
}
print("\n%description\n");
$_tmp = $description;
write;		# use that multilineformat

#--- pre/post
if ($needs_post) {
    print("\n%post\n");
    print("    %{_sbindir}/texlive.post\n");
    print("\n%postun\n");
    print("    if [ \$1 -eq 0 ]; then\n");
    if ($quirk_postun{$name}) {
	print($quirk_postun{$name});
    }
    print("\t%{_sbindir}/texlive.post\n");
    print("    fi\n");
    
}
if (grep($_ eq $name, @block)) {
    print("\n%posttrans\n");
    print("    %{_sbindir}/texlive.post -\n");
}

print("\n#-----------------------------------------------------------------------");
print("\n%files\n");
if ($quirk_bin_files{$name}) {
    print($quirk_bin_files{$name});
}
file_list("", @{$tlpobj->{'binfiles'}{$arch}});
file_list("", $tlpobj->runfiles());
if ($name eq "tex4ht") {
    print("%{_javadir}/tex4ht.jar\n");
}
elsif ($name eq "xdvi") {
    print("%{_datadir}/X11/app-defaults/*\n");
}
if ($needs_post) {
    print("%_texmf_fmtutil_d/$name\n")		if ($#fmtutil > 0);
    print("%_texmf_updmap_d/$name\n")		if ($#updmap > 0);
    print("%_texmf_language_dat_d/$name\n")	if ($#datlines > 0);
    print("%_texmf_language_def_d/$name\n")	if ($#deflines > 0);
    print("%_texmf_language_lua_d/$name\n")	if ($#lualines > 0);
}
if ($tlpobjdoc) {
    file_list("%doc ", $tlpobjdoc->docfiles());
}
if ($tlpobjsrc) {
    print("#- source\n");
    file_list("%doc ", $tlpobjsrc->srcfiles());
}

print("\n#-----------------------------------------------------------------------");
print("\n%prep\n");
print("%setup -c");
my $a = 0;
for (--$sourceN; $sourceN >= 0; --$sourceN, $a++) {
    print(" -a$a");
}
print("\n");
if ($quirk_prep{$name}) {
    print($quirk_prep{$name});
}
print("\n%build\n\n%install\n");
if ($quirk_install{$name}) {
    print($quirk_install{$name});
}
my $cp = "";
if ($relocated) {
    if (grep(/RELOC\/dvips\//, $tlpobj->runfiles())) {
	$cp = "$cp dvips";
    }
    if (grep(/RELOC\/bibtex\//, $tlpobj->runfiles())) {
	$cp = "$cp bibtex";
    }
    if (grep(/RELOC\/fonts\//, $tlpobj->runfiles())) {
	$cp = "$cp fonts";
    }
    if (grep(/RELOC\/omega\//, $tlpobj->runfiles())) {
	$cp = "$cp omega";
    }
    if (grep(/RELOC\/makeindex\//, $tlpobj->runfiles())) {
	$cp = "$cp makeindex";
    }
    if (grep(/RELOC\/metafont\//, $tlpobj->runfiles())) {
	$cp = "$cp metafont";
    }
    if (grep(/RELOC\/metapost\//, $tlpobj->runfiles())) {
	$cp = "$cp metapost";
    }
    if (grep(/RELOC\/scripts\//, $tlpobj->runfiles())) {
	$cp = "$cp scripts";
    }
    if ($mktexlsr && grep(/RELOC\/tex\//, $tlpobj->runfiles())) {
	$cp = "$cp tex";
    }
    if ($tlpobjdoc || $copydoc) {
	$cp = "$cp doc";
    }
    if ($tlpobjsrc || $copysource) {
	$cp = "$cp source";
    }
    if ($cp ne "") {
	print("mkdir -p %{buildroot}%{_texmfdistdir}\n");
	print("cp -fpar$cp %{buildroot}%{_texmfdistdir}\n");
    }
}
else {
    if (grep(/texmf\//, $tlpobj->runfiles()) ||
	($tlpobjdoc && grep(/texmf\//, $tlpobjdoc->docfiles())) ||
	($tlpobjsrc && grep(/texmf\//, $tlpobjsrc->srcfiles()))) {
	$cp = "$cp texmf";
    }
    if (grep(/texmf-dist\//, $tlpobj->runfiles()) ||
	($tlpobjdoc && grep(/texmf-dist\//, $tlpobjdoc->docfiles())) ||
	($tlpobjsrc && grep(/texmf-dist\//, $tlpobjsrc->srcfiles()))) {
	$cp = "$cp texmf-dist";
    }
    if ($cp ne "") {
	print("mkdir -p %{buildroot}%{_datadir}\n");
	print("cp -fpar$cp %{buildroot}%{_datadir}\n");
    }
}
if ($man1pages) {
    print("mkdir -p %{buildroot}%{_mandir}/man1\n");
    print("mv %{buildroot}%{_texmfdir}/doc/man/man1/*.1 %{buildroot}%{_mandir}/man1\n");
}
if ($man5pages) {
    print("mkdir -p %{buildroot}%{_mandir}/man5\n");
    print("mv %{buildroot}%{_texmfdir}/doc/man/man5/*.5 %{buildroot}%{_mandir}/man5\n");
}
if ($infopages) {
    print("mkdir -p %{buildroot}%{_infodir}\n");
    print("mv %{buildroot}%{_texmfdir}/doc/info/*.info %{buildroot}%{_infodir}\n");
}

#--- post
if ($needs_post) {
    if ($#fmtutil > 0) {
	print("mkdir -p %{buildroot}%{_texmf_fmtutil_d}\n");
	print("cat > %{buildroot}%{_texmf_fmtutil_d}/$name <<EOF\n");
	print(join("", @fmtutil));
	print("EOF\n");
    }
    if ($#updmap > 0) {
	print("mkdir -p %{buildroot}%{_texmf_updmap_d}\n");
	print("cat > %{buildroot}%{_texmf_updmap_d}/$name <<EOF\n");
	print(join("", @updmap));
	print("EOF\n");
    }
    if ($#datlines > 0) {
	print("mkdir -p %{buildroot}%{_texmf_language_dat_d}\n");
	print("cat > %{buildroot}%{_texmf_language_dat_d}/$name <<EOF\n");
	print(join("", @datlines));
	print("EOF\n");
	print("perl -pi -e 's|\\\\%%|%%|;' %{buildroot}%{_texmf_language_dat_d}/$name\n");
    }
    if ($#deflines > 0) {
	print("mkdir -p %{buildroot}%{_texmf_language_def_d}\n");
	print("cat > %{buildroot}%{_texmf_language_def_d}/$name <<EOF\n");
	print(join("", @deflines));
	print("EOF\n");
	print("perl -pi -e 's|\\\\%%|%%|;' %{buildroot}%{_texmf_language_def_d}/$name\n");
    }
    if ($#lualines > 0) {
	print("mkdir -p %{buildroot}%{_texmf_language_lua_d}\n");
	print("cat > %{buildroot}%{_texmf_language_lua_d}/$name <<EOF\n");
	print(join("", @lualines));
	print("EOF\n");
    }
}

format multilineformat =
^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<~~
$_tmp
.
