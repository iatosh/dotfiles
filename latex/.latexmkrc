#!/usr/bin/env perl

# %O：オプション
# %S：ソースファイル
# %D：出力ファイル

# 出力先ディレクトリ
$pdf_mode=4;
$max_repeat=5;


# DVIファイルを中間ファイルとして扱う
$dvi_mode = 1;

$default_options = '-synctex=1 -interaction=nonstopmode -silent -file-line-error';

$latex     = 'uplatex -kanji=utf8 -no-guess-input-enc ' .  $default_options . '%O %S';
$lualatex  = 'lualatex ' . $default_options . '%O %S';

$bibtex    = 'upbibtex -kanji=utf8 -no-guess-input-enc %O %B';
$biber     = 'biber --bblencoding=utf8 -u -U --output_safechars %O %B';
$makeindex = 'upmendex %O -o %D %S';
$dvipdf    = 'dvipdfmx %O -o %D %S';

# PDF viewer 設定
$pvc_view_file_via_temporary = 0;
if ($^O eq 'linux') {
    $pdf_previewer = 'xdg-open %S';
    $dvi_previewer = 'xdg-open %S';
}
elsif ($^O eq 'darwin') {
    $pdf_previewer = 'open %S';
    $dvi_previewer = 'open %S';
}
else {
    $pdf_previewer = 'start %S';
    $dvi_previewer = 'start %S';
}

# clean up
$clean_ext = "bbl dvi";

