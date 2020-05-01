#!/usr/bin/perl
;#
;# 音素とカナを相互変換するためのライブラリ。実行する事も可能。
;#
;#   Copyright (C) 2013 Sunao Hara, Okayama Univ.
;#   Copyright (C) 2006-2011 Sunao Hara, Nagoya Univ.
;#
;#   Last modified: 2013/09/11 17:04:08.
;#

# 定番のおまじない
use strict;
use warnings;
#use encoding "euc-jp";
#use open IO => ":encoding(euc-jp)";

use Encode qw(from_to);

##
## 設定
##
my $g_output_encoding = 'utf-8';
my $g_script_encoding = 'utf-8';

my %kanatable = (
	'AA' => ['ア', 'イ', 'ウ', 'エ', 'オ'],

	'k' => ['カ', 'キ', 'ク', 'ケ', 'コ'],
	'ky' => ['キャ', '', 'キュ', '', 'キョ'],
	'g' => ['ガ', 'ギ', 'グ', 'ゲ', 'ゴ'],
	'gy' => ['ギャ', '', 'ギュ', '', 'ギョ'],

	's'  => ['サ', 'シ', 'ス', 'セ', 'ソ'],
	'sh' => ['シャ', 'シ', 'シュ', 'シェ', 'ショ'],
	'sy' => ['シャ', '', 'シュ', '', 'ショ'],
	'z'  => ['ザ', 'ジ', 'ズ', 'ゼ', 'ゾ'],
	'j'  => ['ジャ',   'ジ', 'ジュ', 'ジェ', 'ジョ'],
	'zy' => ['', '', 'ジュ', '', ''],

	't'  => ['タ', 'ティ', 'トゥ', 'テ', 'ト'],
	'ts' => ['ツァ', 'ツィ', 'ツ', 'ツェ', 'ツォ'],
	'ch' => ['チャ', 'チ', 'チュ', 'チェ', 'チョ'],
	'd'  => ['ダ', 'ディ', 'ドゥ', 'デ', 'ド'],
	'dy' => ['', '', 'デュ', '', ''],

	'n'  => ['ナ', 'ニ', 'ヌ', 'ネ', 'ノ'],
	'ny' => ['ニャ', '', 'ニュ', '', 'ニョ'],

	'h' =>  ['ハ', 'ヒ', 'フ', 'ヘ', 'ホ'],
	'hy' => ['ヒャ', '', 'ヒュ', '', 'ヒョ'],
	'f' =>  ['ファ', 'フィ', 'フ', 'フェ', 'フォ'],

	'b' =>  ['バ', 'ビ', 'ブ', 'ベ', 'ボ'],
	'by' => ['ビャ', '', 'ビュ', '', 'ビョ'],

	'p' =>  ['パ', 'ピ', 'プ', 'ペ', 'ポ'],
	'py' => ['ピャ', '', 'ピュ', '', 'ピョ'],

	'm' =>  ['マ', 'ミ', 'ム', 'メ', 'モ'],
	'my' => ['ミャ', '', 'ミュ', '', 'ミョ'],

	'y' => ['ヤ', '', 'ユ', '', 'ヨ'],

	'r' =>  ['ラ', 'リ', 'ル', 'レ', 'ロ'],
	'ry' => ['リャ', '', 'リュ', '', 'リョ'],

	'w' => ['ワ', 'ウィ', '', 'ウェ', 'ウォ'],
);

my %vtable = ('a'=>0, 'i'=>1, 'u'=>2, 'e'=>3, 'o'=>4);

my %kana2phone_table1 = (
	'ァ' => 'a',    'ィ' => 'i',    'ゥ' => 'u',    'ェ' => 'e',    'ォ' => 'o', 
	'ア' => 'a',    'イ' => 'i',    'ウ' => 'u',    'エ' => 'e',    'オ' => 'o',
	'カ' => 'k a',  'キ' => 'k i',  'ク' => 'k u',  'ケ' => 'k e',  'コ' => 'k o',
	'ガ' => 'g a',  'ギ' => 'g i',  'グ' => 'g u',  'ゲ' => 'g e',  'ゴ' => 'g o',
	'サ' => 's a',  'シ' => 'sh i',  'ス' => 's u',  'セ' => 's e',  'ソ' => 's o',
	'ザ' => 'z a',  'ジ' => 'j i',  'ズ' => 'z u',  'ゼ' => 'z e',  'ゾ' => 'z o',
	'タ' => 't a',  'チ' => 'ch i', 'ツ' => 'ts u', 'テ' => 't e',  'ト' => 't o',
	'ダ' => 'd a',  'ヂ' => 'j i',  'ヅ' => 'z u',  'デ' => 'd e',  'ド' => 'd o',
	'ナ' => 'n a',  'ニ' => 'n i',  'ヌ' => 'n u',  'ネ' => 'n e',  'ノ' => 'n o',
	'ハ' => 'h a',  'ヒ' => 'h i',  'フ' => 'f u',  'ヘ' => 'h e',  'ホ' => 'h o',
	'バ' => 'b a',  'ビ' => 'b i',  'ブ' => 'b u',  'ベ' => 'b e',  'ボ' => 'b o',
	'パ' => 'p a',  'ピ' => 'p i',  'プ' => 'p u',  'ペ' => 'p e',  'ポ' => 'p o',
	'マ' => 'm a',  'ミ' => 'm i',  'ム' => 'm u',  'メ' => 'm e',  'モ' => 'm o',
	'ヤ' => 'y a',                  'ユ' => 'y u',                  'ヨ' => 'y o',
	'ャ' => 'y a',                  'ュ' => 'y u',                  'ョ' => 'y o',
	'ラ' => 'r a',  'リ' => 'r i',  'ル' => 'r u',  'レ' => 'r e',  'ロ' => 'r o',
	'ワ' => 'w a',  'ヰ' => 'i'  ,                  'ヱ' => 'e',    'ヲ' => 'o',
	'ヴ' => 'b u',
	'ン' => 'N', 'ッ' => 'q',
	'ー' => ':',   '―' => ':', '‐' => ':', '-' => ':', '～' => ':',
	'・' => '', '「' => '', '」' => '', '”' => '', '。' => '', '、' => 'sp', '，' => 'sp',
	'二' => 'n i', '&' => 'a N d o'
);

my %kana2phone_table2 = (
	'キャ' => 'ky a',             'キュ' =>'ky u',            'キョ'=>'ky o',
	'ギャ' => 'gy a',             'ギュ' =>'gy u',            'ギョ'=>'gy o',
	'クゥ' => 'k u',
	'シャ' => 'sh a',             'シュ' =>'sh u',            'ショ'=>'sh o',
	'ジャ' => 'j a',              'ジュ' =>'j u',             'ジョ'=>'j o',
	'チャ' => 'ch a',             'チュ' =>'ch u', 'チェ' =>'ch e', 'チョ'=>'ch o',
	'ティ' => 't i', 'トゥ' =>'t u',
	'ディ' => 'd i', 'デュ' => 'dy u', 'ドゥ' =>'d u',
	'ニャ' => 'ny a', 'ニュ' => 'ny u', 'ニョ' => 'ny o',
	'ネェ' => 'n e:',
	'ファ' => 'f a', 'フィ' => 'f i', 'フェ' => 'f e', 'フォ' => 'f o',
	                              'フュ' =>'hy u',            'フョ'=>'hy o',
	'ヒャ' => 'hy a',             'ヒュ' =>'hy u',            'ヒョ'=>'hy o',
	'ビャ' => 'by a',             'ビュ' =>'by u',            'ビョ'=>'by o',
	'ピャ' => 'py a',             'ピュ' =>'py u',            'ピョ'=>'py o',
	'ミャ' => 'my a',             'ミュ' =>'my u',            'ミョ'=>'my o',
	'リャ' => 'ry a',             'リュ' =>'ry u',            'リョ'=>'ry o',
	                  'ウィ' => 'w i',             'ウェ' =>'w e',  'ウォ'=>'w o',
	'ヴァ' => 'b a',  'ヴィ' => 'b i',  'ヴェ' =>'b e',  'ヴォ'=>'b o',
	'ウ゛ァ' => 'b a', 'ウ゛ィ' => 'b i', 'ウ゛ェ' => 'b e', 'ウ゛ォ' => 'b o',
	'ンー' => 'N'
);

##
## コマンドライン用
##
if($0 eq __FILE__){
	my $opt = shift;
	if($opt eq "k2p") {
		print &kana2phone($_) while(<>);
	}elsif( ($opt eq "jp2k") || ($opt eq "p2k")) {
		print &julius_phonemetext_to_kana($_) while(<>);
	}elsif($opt eq "gp2k") {
		print &gtalk_phonemetext_to_kana($_) while(<>);
	}else{
		print "usage: $0 [k2p|p2k|jp2k|gp2k] < input_stream \n";
	}
}

##
## ライブラリ
##
sub gtalk_phonemetext_to_kana {
	my $phonemetext = shift;
	my @phonemes;

	# 分割
	push @phonemes, $phonemetext=~/[a-z]+\[\d+\]/gi;

	return &phonemes_to_kana(@phonemes);
}

sub julius_phonemetext_to_kana {
	my $phonemetext = shift;
	my $kana_text = "";
	
	foreach my $word_phones ( split(/\s\|\s/, $phonemetext) ) {
		$kana_text .= &phonemes_to_kana(split(/\s/, $word_phones)) . " ";
	}
	$kana_text =~ s/^\s//o;
	$kana_text =~ s/\s$//o;
	return $kana_text;
}

sub phonemes_to_kana {
	my @phonemes = @_;
	my $kanatext = "";

	my $category_pattern = join("|", keys(%kanatable));
	
	# 音素(GalateaTalk)からカナに変換
	my $lastv = "";
	my $category = $kanatable{'AA'};
	foreach(@phonemes) {
		if(/(q|cl)/o) {
			$kanatext .= 'ッ';
			$lastv = "";
			$category = $kanatable{'AA'};
		} elsif(/N/o) {
			$kanatext .= 'ン';
			$lastv = "";
			$category = $kanatable{'AA'};
		} elsif(/pau/o) {
#			$kanatext .= "、";
			$lastv = $1;
			$category = $kanatable{'AA'};
#		} elsif(/^($category_pattern)\[/) {
		} elsif(/^($category_pattern)$/) {
			$category = $kanatable{$1};
			$lastv = "";
#		} elsif(/^(a|i|u|e|o)/i) {
		} elsif(/^(a|i|u|e|o)(\:*)$/i) {
			my $lc_1 = lc($1);
			if( ($lastv eq $lc_1)
			      || ( ($lastv eq 'e') && ($lc_1 eq 'i'))
			      || ( ($lastv eq 'o') && ($lc_1 eq 'u'))
			) {
				$kanatext .= "ー";
			} else {
				$kanatext .= $category->[$vtable{$lc_1}];
				$kanatext .=  "ー" if($2 ne "");
			}
			$lastv = $1;
			$category = $kanatable{'AA'};
		}
	}
	
	from_to($kanatext, $g_script_encoding, $g_output_encoding);
	
#	print $kanatext . "\n";
	return $kanatext;
}

sub kana2phone {
	my $text = shift;
	my $result = $text;
	foreach my $key (keys %kana2phone_table2){
		$result =~ s/$key/$kana2phone_table2{$key} /g;
	}
	foreach my $key (keys %kana2phone_table1){
		$result =~ s/$key/$kana2phone_table1{$key} /g;
	}
	
	$result =~ s/ :/:/g;
	$result =~ s/  / /g;
	
	# 2重母音対策
	$result =~ s/a a/a:/g;
	$result =~ s/i i/i:/g;
	$result =~ s/u u/u:/g;
	$result =~ s/e e/e:/g;
	$result =~ s/o o/o:/g;

	$result =~ s/e i/e:/g;
	$result =~ s/o u/o:/g;
	
	#$result =~ s/::/:/g;
	$result =~ s/:+/:/g;

	return $result;
}

1;
