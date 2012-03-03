Dictionary = module.exports.Dictionary =
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
    "不": ["bù"]
    "没": ["méi"]



class module.exports.Sentence
    constructor: (chars = null) ->
        @sentence = []
        @add(chars) if chars

    ###
    Add one or more character to this sentence
    @param chars an array of characters. If it's a string it will be split.
    ###
    add: (chars = []) ->
        if typeof chars is "string"
            chars = chars.split ""
        i = -1
        while chars.length > ++i
            char = chars[i]
            throw "Unrecognized char: " + char if not Dictionary.hasOwnProperty(char)
            pinyin = Dictionary[char]
            # changing the tone of the character？
            if chars.length-i > i
                switch chars[i+1]
                    when "1" then pinyin = _changeTone(pinyin, 1)
                    when "2" then pinyin = _changeTone(pinyin, 2)
                    when "3" then pinyin = _changeTone(pinyin, 3)
                    when "4" then pinyin = _changeTone(pinyin, 4)
                    when "5" then pinyin = _changeTone(pinyin, 5)
            # add to sentence
            @sentence.push
                char: char
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


    ###
    Change tone of given pinyin
    @param newTone integer between 1 and 5
    ###
    _changeTone: (pinyin, newTone) ->
        # assume there is only one toned character in the pinyin. Thus as soon as we've made our first change
        # we will return
        i = -1

        vowels = [
            ['ā', 'á', 'ă', 'à', 'a']
            ['ē', 'é', 'ĕ', '?', 'e']
            ['ī', '?', 'ĭ', 'ì', 'i']
            ['ō', 'ó', 'ŏ', '?', 'o']
            ['ū', 'ú', 'ŭ', '?', 'u']
        ]

        while pinyin.length > ++i
            char = pinyin.charAt(i)

            for tones in vowels
                ti = 1
                while 4 >= ti   # finish at 4 - we skip the first tone (neutral)
                    # found a tone we need to change?
                    if tones[ti-1] is char and newTone isnt ti
                        char = tones[newTones - 1]
                        return pinyin.substr(0,i) + char + (pinyin.substr(i+1))

                    ti++

        return pinyin
