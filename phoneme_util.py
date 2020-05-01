import re

class PhonemeUtil:
    _NUMBER_ZEN2HAN_TABLE = str.maketrans(
        '０１２３４５６７８９．。，、／',
        '0123456789..,,/')

    _KANA2CHAR1 = {
        'ア': 'a',    'イ': 'i',    'ウ': 'u',    'エ': 'e',    'オ': 'o',
        'ァ': 'a',    'ィ': 'i',    'ゥ': 'u',    'ェ': 'e',    'ォ': 'o',
        'カ': 'k a',  'キ': 'k i',  'ク': 'k u',  'ケ': 'k e',  'コ': 'k o',
        'ガ': 'g a',  'ギ': 'g i',  'グ': 'g u',  'ゲ': 'g e',  'ゴ': 'g o',
        'サ': 's a',  'シ': 'sh i', 'ス': 's u',  'セ': 's e',  'ソ': 's o',
        'ザ': 'z a',  'ジ': 'j i',  'ズ': 'z u',  'ゼ': 'z e',  'ゾ': 'z o',
        'タ': 't a',  'チ': 'ch i', 'ツ': 'ts u', 'テ': 't e',  'ト': 't o',
        'ダ': 'd a',  'ヂ': 'j i',  'ヅ': 'd u',  'デ': 'd e',  'ド': 'd o',
        'ナ': 'n a',  'ニ': 'n i',  'ヌ': 'n u',  'ネ': 'n e',  'ノ': 'n o',
        'ハ': 'h a',  'ヒ': 'h i',  'フ': 'f u',  'ヘ': 'h e',  'ホ': 'h o',
        'バ': 'b a',  'ビ': 'b i',  'ブ': 'b u',  'ベ': 'b e',  'ボ': 'b o',
        'パ': 'p a',  'ピ': 'p i',  'プ': 'p u',  'ペ': 'p e',  'ポ': 'p o',
        'マ': 'm a',  'ミ': 'm i',  'ム': 'm u',  'メ': 'm e',  'モ': 'm o',
        'ヤ': 'y a',                'ユ': 'y u',                'ヨ': 'y o',
        'ャ': 'y a',                'ュ': 'y u',                'ョ': 'y o',
        'ラ': 'r a',  'リ': 'r i',  'ル': 'r u',  'レ': 'r e',  'ロ': 'r o',
        'ワ': 'w a',  'ヰ': 'i'  ,                'ヱ': 'e',    'ヲ': 'o',
        'ヴ': 'b u',
        'ン': 'N',  'ッ': 'q',
        'ー': ':',   '―': ':', '‐': ':', '-': ':', '～': ':',
        '・': '', '「': '', '」': '', '”': '', '’': '', '。': 'sp', '、': 'sp', '，': 'sp',
        '＆': 'a N d o'
    }
    _KANA2CHAR2 = {
        'キャ': 'ky a',             'キュ': 'ky u',            'キョ': 'ky o',
        'ギャ': 'gy a',             'ギュ': 'gy u',            'ギョ': 'gy o',
        'クゥ': 'k u',
        'シャ': 'sh a',             'シュ': 'sh u',            'ショ': 'sh o',
        'ジャ': 'j a',              'ジュ': 'j u',             'ジョ': 'j o',
        'チャ': 'ch a',             'チュ': 'ch u', 'チェ': 'ch e', 'チョ': 'ch o',
        'ティ': 't i', 'トゥ': 't u',
        'ディ': 'd i', 'デュ': 'dy u', 'ドゥ': 'd u',
        'ニャ': 'ny a', 'ニュ': 'ny u', 'ニョ': 'ny o',
        'ファ': 'f a', 'フィ': 'f i', 'フェ': 'f e', 'フォ': 'f o',
                                    'フュ': 'hy u',            'フョ': 'hy o',
        'ヒャ': 'hy a',             'ヒュ': 'hy u',            'ヒョ': 'hy o',
        'ビャ': 'by a',             'ビュ': 'by u',            'ビョ': 'by o',
        'ピャ': 'py a',             'ピュ': 'py u',            'ピョ': 'py o',
        'ミャ': 'my a',             'ミュ': 'my u',            'ミョ': 'my o',
        'リャ': 'ry a',             'リュ': 'ry u',            'リョ': 'ry o',
                        'ウィ': 'w i',  'ウェ': 'w e',  'ウォ': 'wh o',
        'ヴァ': 'b a',  'ヴィ': 'b i',  'ヴェ': 'b e',  'ヴォ': 'b o',
        'ウ゛ァ': 'b a', 'ウ゛ィ': 'b i', 'ウ゛ェ': 'b e', 'ウ゛ォ': 'b o'
    }

    _RE_HIRAGANA = re.compile(r'[ぁ-ゔ]')
    _RE_NUMBER   = re.compile(r'[0-9]')

    @classmethod
    def kana2phone(cls, text):
        # convert from Hiragana to Katakana
        str_kana = cls._RE_HIRAGANA.sub(lambda x: chr(ord(x.group(0)) + 0x60), text)

        # convert from Katakana to Keyboard numbers
        for k, v in cls._KANA2CHAR2.items():
            str_kana = str_kana.replace(k, v+" ")
        for k, v in cls._KANA2CHAR1.items():
            str_kana = str_kana.replace(k, v+" ")

        # sokuon
        #str_kana = re.sub(r'Q([a-z])', r'\1\1', str_kana)
        #str_kana = re.sub(r'Q$', r'ltu', str_kana)

        # concatenate long-vowel
        str_kana = re.sub(r'([aiueo]) :', r'\1:', str_kana)
        
        # remove punctuations
        str_kana = re.sub(r',', r'', str_kana)

        # remove numbers
        str_kana = str_kana.translate(cls._NUMBER_ZEN2HAN_TABLE)
        str_kana = cls._RE_NUMBER.sub(r'', str_kana)
        
        # remove double spaces
        str_kana = re.sub(r' +', r' ', str_kana)
        
        return str_kana

if __name__ == '__main__':
    import sys
    import codecs

    for line in sys.stdin.buffer:
        line = line.decode("utf-8")
        print(PhonemeUtil.kana2phone(line.rstrip()))
