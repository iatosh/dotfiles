#!/usr/bin/env perl

# %O：オプション
# %S：ソースファイル
# %D：出力ファイル


# LaTeX
$latex='uplatex %O %S';

# LuaLaTeX
# $lualatex='lualatex %O %S';

# BibTeX
$bibtex='upbibtex %O %S';
$biber='biber --bblencoding=utf8 -u -U --output_safechars %O %S';

# index
$makeindex='upmendex %O -o %D %S';

# DVI / PDF
$dvipdf='dvipdfmx %O -o %D %S';

$pdf_mode=4;
$max_repeat=5;

# preview
$pvc_view_file_via_temporary=0;
if($^O eq 'linux'){
    $dvi_previewer="xdg-open %S";
    $pdf_previewer="xdg-open %S";
}
elsif($^O eq 'darwin'){
    $dvi_previewer="open %S";
    $pdf_previewer="open %S";
}
else{
    $dvi_previewer="start %S";
    $pdf_previewer="start %S";
}

# clean up
$clean_full_ext="%R.synctex.gz";