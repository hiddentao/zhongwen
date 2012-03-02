module.exports.Dictionary =
    "我": ["wŏ"]
    "你": ["nĭ"]
    "他": ["tā"]
    "她": ["tā"]
    "是": ["shì"]
    "姓": ["xìng"]
    "叫": ["jiào"]
    "在": ["zài"]
    "有": ["yŏu"]
    "吃": ["chī"]
    "喝": ["hē"]
    "看": ["kàn"]
    "王": ["wáng"]
    "先": ["xiān"]
    "生": ["shēng"]
    "人": ["rén"]
    "中": ["zhōng"]
    "国": ["guó"]
    "英": ["yīng"]
    "北": ["bĕi"]
    "京": ["jīng"]
    "伦": ["lún"]
    "敦": ["dūn"]
    "图": ["tú"]
    "书": ["shū"]
    "馆": ["guăn"]
    "茶": ["chá"]
    "酒": ["jiŭ"]
    "饭": ["fàn"]
    "好": ["hăo"]
    "聪": ["cōng"]
    "明": ["míng"]
    "很": ["hĕn"]
    "不": ["bù", "bú"]
    "没": ["méi"]


class module.exports.SentenceBuilder
    constructor:
        @sentence = []

    ###
    Add a word
    ###
    add: (chars = []) ->
        word = []
        for c in chars
            if typeof c is 'array'
                pinyin = c[1]
            else
                pinyin = module.exports.Dictionary[c[0][0]]
            word.push
                char: c[0]
                pinyin: pinyin
        @

    getChars: ->
        ret = ""
        for w in @sentence
            for c in w
                ret += w.char
        ret

    getPinyin: ->
        ret = ""
        for w in @sentence
            if "" isnt ret
                w += " "
            for c in w
                ret += w.pinyin
        ret

    toString: ->
        @getChars()


