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
    'afm2pl'	=>	"%rename tetex-afm, %rename texlive-texmf-afm",
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
  '%{_texmfdistdir}/web2c/fmtutil.cnf'			=>	"%config(noreplace) ",
  '%{_texmfdistdir}/web2c/updmap.cfg'			=>	"%config(noreplace) ",
  '%{_texmfdistdir}/tex/generic/config/language.dat'	=>	"%config(noreplace) ",
  '%{_texmfdistdir}/tex/generic/config/language.dat.lua'=>	"%config(noreplace) ",
  '%{_texmfdistdir}/tex/generic/config/language.def'	=>	"%config(noreplace) ",
);
my @block = (
    'scheme-tetex',
    'collection-latexextra'
);

########################################################################
# quirks defs begin
my %quirk_epoch = (
    'amiri'					=>	1,
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
    'endheads'					=>	1,
    'euro-ce'					=>	1,
    'glossaries'				=>	1,
    'inconsolata'				=>	1,
    'l2tabu-french'				=>	1,
    'lgrx'					=>	1,
    'lshort-german'				=>	1,
    'ltxkeys'					=>	1,
    'mf2pt1'					=>	1,
    'nicefilelist'				=>	1,
    'nicetext'					=>	1,
    'nlctdoc'					=>	1,
    'nrc'					=>	1,
    'patgen'					=>	1,
    'preprint'					=>	1,
    'pst-tools'					=>	1,
    'regexpatch'				=>	1,
    'sidenotes'					=>	1,
    'sttools'					=>	1,
    'texdirflatten'				=>	1,
    'texinfo'					=>	1,
    'tugboat-plain'				=>	1,
    'ucs'					=>	1,
    'uni-wtal-ger'				=>	1,
    'uptex'					=>	1,
    'xecolor'					=>	1,
    'xetex'					=>	1,
    'xypic'					=>	1,
    'yhmath'					=>	1,
    'zwpagelayout'				=>	1,
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
    'texdoc'			=>	"\
perl -pi -e 's%^# (viewer_pdf = )xpdf.*%\$1xdg-open%;'	\\\
	texmf-dist/texdoc/texdoc.cnf\n",
    'tetex'			=>	"\
perl -pi -e 's|\\\$TEXMFROOT/tlpkg|%{_datadir}/tlpkg|;'		\\\
    texmf/scripts/tetex/updmap.pl\n",
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
    'a2ping'			=>	1,
    'authorindex'		=>	1,
    'bibexport'			=>	1,
    'bundledoc'			=>	1,
    'cachepic'			=>	1,
    'checkcites'		=>	1,
    'context'			=>	1,
    'ctanify'			=>	1,
    'ctanupload'		=>	1,
    'de-macro'			=>	1,
    'dosepsbin'			=>	1,
    'dviasm'			=>	1,
    'dvipdfm'			=>	1,
    'ebong'			=>	1,
    'epstopdf'			=>	1,
    'exceltex'			=>	1,
    'fig4latex'			=>	1,
    'findhyph'			=>	1,
    'fontinst'			=>	1,
    'fontools'			=>	1,
    'fragmaster'		=>	1,
    'jfontmaps'			=>	1,
    'glossaries'		=>	1,
    'installfont'		=>	1,
    'latex2man'			=>	1,
    'latexdiff'			=>	1,
    'latexmk'			=>	1,
    'latexfileversion'		=>	1,
    'latexpand'			=>	1,
    'listbib'			=>	1,
    'listings-ext'		=>	1,
    'lua2dox'			=>	1,
    'luaotfload'		=>	1,
    'match_parens'		=>	1,
    'mathspic'			=>	1,
    'mf2pt1'			=>	1,
    'mkgrkindex'		=>	1,
    'mkjobtexmf'		=>	1,
    'mptopdf'			=>	1,
    'musixtex'			=>	1,
    'pax'			=>	1,
    'pdfcrop'			=>	1,
    'pdfjam'			=>	1,
    'pedigree-perl'		=>	1,
    'perltex'			=>	1,
    'pkfix'			=>	1,
    'pkfix-helper'		=>	1,
    'pst2pdf'			=>	1,
    'purifyeps'			=>	1,
    'splitindex'		=>	1,
    'sty2dtx'			=>	1,
    'svn-multi'			=>	1,
    'technics'			=>	1,
    'tetex'			=>	1,
    'texdef'			=>	1,
    'texconfig'			=>	1,
    'texcount'			=>	1,
    'texdiff'			=>	1,
    'texdirflatten'		=>	1,
    'texdoc'			=>	1,
    'texlive-scripts'		=>	1,
    'texliveonfly'		=>	1,
    'texloganalyser'		=>	1,
    'thumbpdf'			=>	1,
    'tpic2pdftex'		=>	1,
    'typeoutfileinfo'		=>	1,
    'ulqda'			=>	1,
    'urlbst'			=>	1,
    'vpe'			=>	1,
);
my %quirk_bin_files = (
    'a2ping'			=>	"%{_bindir}/a2ping\n",
    'authorindex'		=>	"%{_bindir}/authorindex\n",
    'bibexport'			=>	"%{_bindir}/bibexport\n",
    'bundledoc'			=>	"%{_bindir}/arlatex\n%{_bindir}/bundledoc\n",
    'cachepic'			=>	"%{_bindir}/cachepic\n",
    'checkcites'		=>	"%{_bindir}/checkcites\n",
    'chktex'			=>	"%{_bindir}/chkweb\n%{_bindir}/deweb\n",
    'context'			=>	"%{_bindir}/*\n",
    'ctanify'			=>	"%{_bindir}/ctanify\n",
    'ctanupload'		=>	"%{_bindir}/ctanupload\n",
    'de-macro'			=>	"%{_bindir}/de-macro\n",
    'dosepsbin'			=>	"%{_bindir}/dosepsbin\n",
    'dviasm'			=>	"%{_bindir}/dviasm\n",
    'dvipdfm'			=>	"%{_bindir}/dvipdft\n",
    'ebong'			=>	"%{_bindir}/ebong\n",
    'epstopdf'			=>	"%{_bindir}/epstopdf\n%{_bindir}/repstopdf\n",
    'exceltex'			=>	"%{_bindir}/exceltex\n",
    'fig4latex'			=>	"%{_bindir}/fig4latex\n",
    'findhyph'			=>	"%{_bindir}/findhyph\n",
    'fontinst'			=>	"%{_bindir}/fontinst\n",
    'fontools'			=>	"%{_bindir}/*\n",
    'fragmaster'		=>	"%{_bindir}/fragmaster\n",
    'glossaries'		=>	"%{_bindir}/makeglossaries\n",
    'installfont'		=>	"%{_bindir}/installfont-tl\n",
    'jfontmaps'			=>	"%{_bindir}/updmap-setup-kanji
%{_bindir}/updmap-setup-kanji-sys\n",
    'latex2man'			=>	"%{_bindir}/latex2man\n",
    'latexdiff'			=>	"%{_bindir}/latexdiff-vc
%{_bindir}/latexdiff
%{_bindir}/latexrevise\n",
    'latexfileversion'		=>	"%{_bindir}/latexfileversion\n",
    'latexmk'			=>	"%{_bindir}/latexmk\n",
    'latexpand'			=>	"%{_bindir}/latexpand\n",
    'listbib'			=>	"%{_bindir}/listbib\n",
    'listings-ext'		=>	"%{_bindir}/listings-ext.sh\n",
    'lua2dox'			=>	"%{_bindir}/lua2dox_filter\n%{_bindir}/lua2dox_lua\n",
    'luaotfload'		=>	"%{_bindir}/mkluatexfontdb\n",
    'm-tx'			=>	"%{_bindir}/m-tx\n",
    'match_parens'		=>	"%{_bindir}/match_parens\n",
    'mathspic'			=>	"%{_bindir}/mathspic\n",
    'mf2pt1'			=>	"%{_bindir}/mf2pt1\n",
    'mkgrkindex'		=>	"%{_bindir}/mkgrkindex\n",
    'mkjobtexmf'		=>	"%{_bindir}/mkjobtexmf\n",
    'mptopdf'			=>	"%{_bindir}/mptopdf\n",
    'musixtex'			=>	"%{_bindir}/musixflx\n%{_bindir}/musixtex\n",
    'pax'			=>	"%{_bindir}/pdfannotextractor\n%{_javadir}/pax.jar\n",
    'pst2pdf' 			=>	"%{_bindir}/pst2pdf\n",
    'pdfcrop'			=>	"%{_bindir}/pdfcrop\n%{_bindir}/rpdfcrop\n",
    'pdfjam'			=>	"%{_bindir}/pdf180
%{_bindir}/pdf270
%{_bindir}/pdf90
%{_bindir}/pdfbook
%{_bindir}/pdfflip
%{_bindir}/pdfjam
%{_bindir}/pdfjam-pocketmod
%{_bindir}/pdfjam-slides3up
%{_bindir}/pdfjam-slides6up
%{_bindir}/pdfjoin
%{_bindir}/pdfnup
%{_bindir}/pdfpun\n",
    'pdftools'			=>	"%{_bindir}/e2pall\n%{_bindir}/pdfatfi\n%{_bindir}/ps4pdf\n",
    'pedigree-perl'		=>	"%{_bindir}/pedigree\n",
    'perltex'			=>	"%{_bindir}/perltex\n",
    'pkfix'			=>	"%{_bindir}/pkfix\n",
    'pkfix-helper'		=>	"%{_bindir}/pkfix-helper\n",
    'pstools'			=>	"%{_bindir}/ps2eps\n%{_bindir}/ps2frag\n%{_bindir}/pslatex\n",
    'purifyeps'			=>	"%{_bindir}/purifyeps\n",
    'splitindex'		=>	"%{_bindir}/splitindex\n",
    'sty2dtx'			=>	"%{_bindir}/sty2dtx\n",
    'svn-multi'			=>	"%{_bindir}/svn-multi\n",
    'tetex'			=>	"%{_bindir}/allcm
%{_bindir}/allec
%{_bindir}/allneeded
%{_bindir}/dvi2fax
%{_bindir}/dvired
%{_bindir}/fmtutil
%{_bindir}/fmtutil-sys
# installed by texlive-kpathsea.bin
#%%{_bindir}/kpsetool
%{_bindir}/kpsewhere
%{_bindir}/texconfig-dialog
%{_bindir}/texconfig-sys
%{_bindir}/texlinks
%{_bindir}/updmap
%{_bindir}/updmap-sys\n",
    'texconfig'			=>	"%{_bindir}/texconfig\n",
    'texcount'			=>	"%{_bindir}/texcount\n",
    'texdef'			=>	"%{_bindir}/texdef\n",
    'texdiff'			=>	"%{_bindir}/texdiff\n",
    'texdirflatten'		=>	"%{_bindir}/texdirflatten\n",
    'tex4ht'			=>	"%{_bindir}/ht
%{_bindir}/htcontext
%{_bindir}/htlatex
%{_bindir}/htmex
%{_bindir}/httex
%{_bindir}/httexi
%{_bindir}/htxelatex
%{_bindir}/htxetex
%{_bindir}/mk4ht\n",
    'texdoc'			=>	"%{_bindir}/texdoc\n%{_bindir}/texdoctk\n",
    'texlive-docindex'		=>	"%doc %{_tlpkgdir}/texmf
%doc %{_tlpkgdir}/texmf-dist\n",
    'texlive-scripts'		=>	"%{_bindir}/rungs\n",
    'texliveonfly'		=>	"%{_bindir}/texliveonfly\n",
    'texloganalyser'		=>	"%{_bindir}/texloganalyser\n",
    'thumbpdf'			=>	"%{_bindir}/thumbpdf\n",
    'tpic2pdftex'		=>	"%{_bindir}/tpic2pdftex\n",
    'typeoutfileinfo'		=>	"%{_bindir}/typeoutfileinfo\n",
    'ulqda'			=>	"%{_bindir}/ulqda\n",
    'uptex'			=>	"%{_bindir}/convbkmk\n",
    'urlbst'			=>	"%{_bindir}/urlbst\n",
    'vpe'			=>	"%{_bindir}/vpe\n",
    'xetex'			=>	"%{_bindir}/xelatex\n",
);
my %quirk_bin_source = (
    'context'			=>	"http://mirrors.ctan.org/systems/texlive/tlnet/archive/context.x86_64-linux.tar.xz",
    'chktex'			=>	"http://mirrors.ctan.org/systems/texlive/tlnet/archive/chktex.x86_64-linux.tar.xz",
    'dvipdfm'			=>	"http://mirrors.ctan.org/systems/texlive/tlnet/archive/dvipdfm.x86_64-linux.tar.xz",
    'tpic2pdftex'		=>	"http://mirrors.ctan.org/systems/texlive/tlnet/archive/tpic2pdftex.x86_64-linux.tar.xz",
);
my %quirk_install = (
    'a2ping'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/a2ping/a2ping.pl a2ping
popd\n",
    'authorindex'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/authorindex/authorindex authorindex
popd\n",
    'bibexport'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/bibexport/bibexport.sh bibexport
popd\n",
    'bundledoc'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/bundledoc/arlatex arlatex
    ln -sf %{_texmfdistdir}/scripts/bundledoc/bundledoc bundledoc
popd\n",
    'cachepic'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/cachepic/cachepic.tlu cachepic
popd\n",
    'checkcites'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/checkcites/checkcites.lua checkcites
popd\n",
    'chktex'			=>	"mkdir -p %{buildroot}%{_bindir}
# shell script
cp -fa bin/x86_64-linux/chkweb %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdir}/scripts/a2ping/deweb.pl deweb
popd\n",
    'context'			=>	"# only lua scripts
mkdir -p %{buildroot}%{_bindir}
cp -fpa bin/x86_64-linux/* %{buildroot}%{_bindir}\n",
    'ctanify'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/ctanify/ctanify ctanify
popd\n",
    'ctanupload'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/ctanupload/ctanupload.pl ctanupload
popd\n",
    'de-macro'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/de-macro/de-macro de-macro
popd\n",
    'dviasm'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/dviasm/dviasm.py dviasm
popd\n",
    'dvipdfm'			=>	"# shell script
mkdir -p %{buildroot}%{_bindir}
cp -far bin/x86_64-linux/dvipdft %{buildroot}%{_bindir}\n",
    'dosepsbin'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/dosepsbin/dosepsbin.pl dosepsbin
popd\n",
    'dvipdfmx'			=>	"mkdir -p %{buildroot}%{_tlpkgdir}
cp -fpar tlpkg/tlpostcode %{buildroot}%{_tlpkgdir}\n",
    'ebong'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/ebong/ebong.py ebong
popd\n",
    'epstopdf'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/epstopdf/epstopdf.pl epstopdf
    ln -sf epstopdf repstopdf
popd\n",
    'exceltex'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/exceltex/exceltex exceltex
popd\n",
    'fig4latex'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/fig4latex/fig4latex fig4latex
popd\n",
    'findhyph'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/findhyph/findhyph findhyph
popd\n",
    'fontinst'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/tetex/fontinst.sh fontinst
popd\n",
    'fontools'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/fontools/afm2afm afm2afm
    ln -sf %{_texmfdistdir}/scripts/fontools/autoinst autoinst
    ln -sf %{_texmfdistdir}/scripts/fontools/cmap2enc cmap2enc
    ln -sf %{_texmfdistdir}/scripts/fontools/font2afm font2afm
    ln -sf %{_texmfdistdir}/scripts/fontools/ot2kpx ot2kpx
    ln -sf %{_texmfdistdir}/scripts/fontools/pfm2kpx pfm2kpx
    ln -sf %{_texmfdistdir}/scripts/fontools/showglyphs showglyphs
popd\n",
    'fragmaster'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/fragmaster/fragmaster.pl fragmaster
popd\n",
    'glossaries'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/glossaries/makeglossaries makeglossaries
popd\n",
    'installfont'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/installfont/installfont-tl installfont-tl
popd\n",
    'jfontmaps'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/jfontmaps/updmap-setup-kanji.pl updmap-setup-kanji
    ln -sf %{_texmfdistdir}/scripts/jfontmaps/updmap-setup-kanji-sys.sh updmap-setup-kanji-sys
popd\n",
    'latex2man'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    # generate relative link manually because it appears to trigger some
    # weird bug that causes the link to be removed
    %define dont_relink                        1
    ln -sf ../share/texmf-dist/scripts/latex2man/latex2man latex2man
popd\n",
    'latexdiff'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/latexdiff/latexdiff-vc.pl latexdiff-vc
    ln -sf %{_texmfdistdir}/scripts/latexdiff/latexdiff.pl latexdiff
    ln -sf %{_texmfdistdir}/scripts/latexdiff/latexrevise.pl latexrevise
popd\n",
    'latexmk'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/latexmk/latexmk.pl latexmk
popd\n",
    'latexfileversion'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/latexfileversion/latexfileversion latexfileversion
popd\n",
    'latexpand'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/latexpand/latexpand latexpand
popd\n",
    'listbib'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/listbib/listbib listbib
popd\n",
    'listings-ext'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/listings-ext/listings-ext.sh listings-ext.sh
popd\n",
    'lua2dox'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/lua2dox/lua2dox_lua lua2dox_lua
    ln -sf lua2dox_lua lua2dox_filter
popd\n",
    'luaotfload'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/luaotfload/mkluatexfontdb.lua mkluatexfontdb
popd\n",
    'm-tx'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/m-tx/m-tx.lua m-tx
popd\n",
    'mf2pt1'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/mf2pt1/mf2pt1.pl mf2pt1
popd\n",
    'mptopdf'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/context/perl/mptopdf.pl mptopdf
popd\n",
    'match_parens'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/match_parens/match_parens match_parens
popd\n",
    'mathspic'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/mathspic/mathspic.pl mathspic
popd\n",
    'mkgrkindex'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/mkgrkindex/mkgrkindex mkgrkindex
popd\n",
    'mkjobtexmf'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/mkjobtexmf/mkjobtexmf.pl mkjobtexmf
popd\n",
     'musixtex'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/musixtex/musixflx.lua musixflx
    ln -sf %{_texmfdistdir}/scripts/musixtex/musixtex.lua musixtex
popd\n",
    'pax'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pax/pdfannotextractor.pl pdfannotextractor
popd
mkdir -p %{buildroot}%{_javadir}
pushd %{buildroot}%{_javadir}
    ln -sf %{_texmfdistdir}/scripts/pax/pax.jar pax.jar
popd\n",
    'pdfcrop'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pdfcrop/pdfcrop.pl pdfcrop
    ln -sf pdfcrop rpdfcrop
popd\n",
    'pdfjam'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdf180 pdf180
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdf270 pdf270
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdf90 pdf90
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfbook pdfbook
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfflip pdfflip
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfjam pdfjam
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfjam-pocketmod pdfjam-pocketmod
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfjam-slides3up pdfjam-slides3up
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfjam-slides6up pdfjam-slides6up
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfjoin pdfjoin
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfnup pdfnup
    ln -sf %{_texmfdistdir}/scripts/pdfjam/pdfpun pdfpun
popd\n",
    'pdftools'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/tetex/e2pall.pl e2pall
    ln -sf %{_texmfdistdir}/scripts/oberdiek/pdfatfi.pl pdfatfi
    ln -sf %{_texmfdistdir}/scripts/pst-pdf/ps4pdf ps4pdf
popd\n",
    'pedigree-perl'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pedigree-perl/pedigree.pl pedigree
popd\n",
    'perltex'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/perltex/perltex.pl perltex
popd\n",
    'pkfix'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pkfix/pkfix.pl pkfix
popd\n",
    'pkfix-helper'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pkfix-helper/pkfix-helper pkfix-helper
popd\n",
    'pst2pdf'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/pst2pdf/pst2pdf.pl pst2pdf
popd\n",
    'pstools'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/ps2eps/ps2eps.pl ps2eps
    ln -sf %{_texmfdistdir}/scripts/tetex/ps2frag.sh ps2frag
    ln -sf %{_texmfdistdir}/scripts/tetex/pslatex.sh pslatex
popd\n",
    'purifyeps'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/purifyeps/purifyeps purifyeps
popd\n",
    'splitindex'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/splitindex/perl/splitindex.pl splitindex
popd\n",
    'sty2dtx'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/sty2dtx/sty2dtx.pl sty2dtx
popd\n",
    'svn-multi'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/svn-multi/svn-multi.pl svn-multi
popd\n",
    'tetex'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/tetex/updmap.pl updmap
    ln -sf %{_texmfdistdir}/scripts/tetex/updmap-sys.sh updmap-sys
    ln -sf %{_texmfdistdir}/scripts/tetex/allcm.sh allcm
    ln -sf allcm allec
    ln -sf %{_texmfdistdir}/scripts/tetex/allneeded.sh allneeded
    ln -sf %{_texmfdistdir}/scripts/tetex/dvi2fax.sh dvi2fax
    ln -sf %{_texmfdistdir}/scripts/tetex/dvired.sh dvired
    ln -sf %{_texmfdistdir}/scripts/tetex/fmtutil.sh fmtutil
    ln -sf %{_texmfdistdir}/scripts/tetex/fmtutil-sys.sh fmtutil-sys
    ln -sf %{_texmfdistdir}/scripts/tetex/kpsetool.sh kpsetool
    ln -sf %{_texmfdistdir}/scripts/tetex/kpsewhere.sh kpsewhere
    ln -sf %{_texmfdistdir}/scripts/tetex/texconfig-dialog.sh texconfig-dialog
    ln -sf %{_texmfdistdir}/scripts/tetex/texconfig-sys.sh texconfig-sys
    ln -sf %{_texmfdistdir}/scripts/tetex/texlinks.sh texlinks
    ln -sf %{_texmfdistdir}/scripts/tetex/updmap.pl updmap
    ln -sf %{_texmfdistdir}/scripts/tetex/updmap-sys.sh updmap-sys
popd\n",
    'tex4ht'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/tex4ht/ht.sh ht
    ln -sf %{_texmfdistdir}/scripts/tex4ht/htcontext.sh htcontext
    ln -sf %{_texmfdistdir}/scripts/tex4ht/htlatex.sh htlatex
    ln -sf %{_texmfdistdir}/scripts/tex4ht/htmex.sh htmex
    ln -sf %{_texmfdistdir}/scripts/tex4ht/httex.sh httex
    ln -sf %{_texmfdistdir}/scripts/tex4ht/httexi.sh httexi
    ln -sf %{_texmfdistdir}/scripts/tex4ht/htxelatex.sh htxelatex
    ln -sf %{_texmfdistdir}/scripts/tex4ht/htxetex.sh htxetex
    ln -sf %{_texmfdistdir}/scripts/tex4ht/mk4ht.pl mk4ht
popd
mkdir -p %{buildroot}%{_javadir}
pushd %{buildroot}%{_javadir}
    ln -sf %{_texmfdistdir}/tex4ht/bin/tex4ht.jar tex4ht.jar
popd\n",
    'texconfig'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/tetex/texconfig.sh texconfig
popd\n",
    'texcount'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/texcount/texcount.pl texcount
popd\n",
    'texdef'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/texdef/texdef.pl texdef
popd\n",
    'texdiff'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/texdiff/texdiff texdiff
popd\n",
    'texdirflatten'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/texdirflatten/texdirflatten texdirflatten
popd\n",
    'texdoc'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/texdoc/texdoc.tlu texdoc
    ln -sf %{_texmfdistdir}/scripts/tetex/texdoctk.pl texdoctk
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
    'texliveonfly'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/texliveonfly/texliveonfly.py texliveonfly
popd\n",
    'texloganalyser'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/texloganalyser/texloganalyser texloganalyser
popd\n",
    'thumbpdf'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/thumbpdf/thumbpdf.pl thumbpdf
popd\n",
    'tpic2pdftex'		=>	"# shell script
mkdir -p %{buildroot}%{_bindir}
cp -fpa bin/x86_64-linux/tpic2pdftex %{buildroot}%{_bindir}\n",
    'typeoutfileinfo'		=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdir}/scripts/typeoutfileinfo/typeoutfileinfo.sh typeoutfileinfo
popd\n",
    'ulqda'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/ulqda/ulqda.pl ulqda
popd\n",
    'uptex'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/uptex/convbkmk.rb convbkmk
popd\n",
    'urlbst'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/urlbst/urlbst urlbst
popd\n",
    'vpe'			=>	"mkdir -p %{buildroot}%{_bindir}
pushd %{buildroot}%{_bindir}
    ln -sf %{_texmfdistdir}/scripts/vpe/vpe.pl vpe
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
# Avoid the need to pull too many dependencies from contrib to main
my %quirk_suggests = (
    'collection-latexextra'	=>	"exceltex",
);

my %quirk_cleanup = (
    'tetex'			=>	"rm -f %{buildroot}%{_bindir}/kpsetool\n",
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
chomp(my $enable_biber = `rpm --eval "%{_texmf_enable_biber}"`);
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
$version =~ s/-/./g;
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
	if (/doc\/info\/.*\.info$/) {
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
    return 1 if (!$enable_biber && $package =~ /^biber/);
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
if ($quirk_suggests{$name}) {
    foreach my $suggests (split(" ", $quirk_suggests{$name})) {
	print("Suggests:\ttexlive-$suggests\n");
	$required{$suggests} = 1;
    }
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
    print("mv %{buildroot}%{_texmfdistdir}/doc/man/man1/*.1 %{buildroot}%{_mandir}/man1\n");
}
if ($man5pages) {
    print("mkdir -p %{buildroot}%{_mandir}/man5\n");
    print("mv %{buildroot}%{_texmfdistdir}/doc/man/man5/*.5 %{buildroot}%{_mandir}/man5\n");
}
if ($infopages) {
    print("mkdir -p %{buildroot}%{_infodir}\n");
    print("mv %{buildroot}%{_texmfdistdir}/doc/info/*.info %{buildroot}%{_infodir}\n");
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

if ($quirk_cleanup{$name}) {
    print("$quirk_cleanup{$name}\n");
}

format multilineformat =
^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<~~
$_tmp
.
