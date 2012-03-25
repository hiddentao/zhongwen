_isArray = (value) ->
    return Object.prototype.toString.call(value) is '[object Array]'


###
Chinese (simplified) character dictionary
###
Dict = exports.Dict =
    "？": "?"
    "！": "!"
    "。": "."
    "，": ","
    "；": ";"
    "啊" : ["a", "ah"]
    "我": "wǒ"
    "你": "nǐ"
    "他": "tā"
    "她": "tā"
    "是": "shì"
    "姓": "xìng"
    "叫": "jiào"
    "在": "zài"
    "有": "yǒu"
    "吃": "chī"
    "喝": "hē"
    "看": "kàn"
    "王": "wáng"
    "先": "xiān"
    "生": "shēng"
    "人": "rén"
    "中": "zhōng"
    "国": "guó"
    "英": "yīng"
    "北": "běi"
    "京": "jīng"
    "伦": "lún"
    "敦": "dūn"
    "图": "tú"
    "书": "shū"
    "馆": "guǎn"
    "茶": "chá"
    "酒": "jiǔ"
    "饭": "fàn"
    "好": "hǎo"
    "聪": "cōng"
    "明": "míng"
    "很": "hěn"
    "不": "bù"
    "没": "méi"
    "们": "men"
    "说" : "shuō"
    "小" : "xiǎo"
    "姐" : "jiě"
    "爸" : "bà"
    "妈" : "mā"
    "学" : "xué"
    "大" : "dà"
    "上" : "shàng"
    "海" : "hǎi"
    "文" : "wén"
    "吗" : "ma"
    "什" : "shén"
    "么" : "me"
    "儿" : "ér"
    "哪" : [ "nǎ", "něi" ]
    "谁" : [ "shéi", "shuí" ]
    "您" : "nín"
    "贵" : "guì"
    "也" : "yě"
    "都" : "dōu"
    "吧" : "ba"
    "再" : "zaì"
    "见" : "jiàn"
    "谢" : "xiè"
    "请" : "qǐng"
    "问" : "wèn"
    "因" : "yīn"
    "为" : "wèi"
    "所" : "suǒ"
    "以" : "yǐ"
    "年" : "nián"
    "月" : "yuè"
    "星" : "xīng"
    "期" : "qī"
    "日" : "rì"
    "号" : "hào"
    "今" : "jīn"
    "天" : "tiān"
    "昨" : "zuó"
    "早" : "zǎo"
    "午" : "wǔ"
    "下" : "xià"
    "晚" : "wǎn"
    "点" : "diǎn"
    "分" : "fēn"
    "刻" : "kè"
    "半" : "bàn"
    "零" : "líng"
    "一" : "yī"
    "二" : "èr"
    "两" : "liǎng"
    "三" : "sān"
    "四" : "sì"
    "五" : "wǔ"
    "六" : "lìu"
    "七" : "qī"
    "八" : "bā"
    "九" : "jǐu"
    "十" : "shí"
    "去" : "qǜ"
    "虽" : "suī"
    "然" : "rán"
    "可" : "kě"
    "但" : "dàn"
    "老" : "lǎo"
    "师" : "shī"
    "喜" : "xǐ"
    "欢" : "huān"
    "哥" : "gē"
    "弟" : "dì"
    "妹" : "mèi"
    "美" : "měi"
    "法" : "fǎ"
    "本" : "běn"
    "时" : "shí"
    "候" : "hōu"
    "会" : "huì"
    "要" : "yào"
    "想" : "xiǎng"
    "热" : "rè"
    "比" : "bǐ"
    "这" : [ "zhè", "zhèi" ]
    "那" : [ "nà", "nèi" ]
    "做" : "zuò"
    "几" : "jǐ"
    "既" : "jì"
    "的" : "de"
    "父" : "fù"
    "母" : "mǔ"
    "数" : "shù"
    "教" : "jiào"
    "室" : "shì"
    "餐" : "cān"
    "厅" : "tīng"
    "工" : "gōng"
    "作" : "zuò"
    "证" : "zhèng"
    "树" : "shù"
    "借" : "jiè"
    "还" : "huán"
    "办" : "bàn"
    "公" : "gōng"
    "名" : "míng"
    "字" : "zì"
    "努" : "nǔ"
    "力" : "lì"
    "爱" : "ài"
    "舒" : "shū"
    "服" : "fú"
    "习" : "xí"
    "校" : "xiào"
    "同" : "tóng"
    "班" : "bān"
    "尊" : "zūn"
    "重" : "zhòng"
    "课" : "kè"
    "研" : [ "yán", "yàn" ]
    "究" : "jīu"
    "呢" : "ne"
    "朋" : "péng"
    "友" : "yōu"
    "忙" : "máng"
    "知" : "zhī"
    "道" : "dao"
    "个" : "gè"
    "地" : "dì"
    "方" : "fāng"
    "多" : "duō"
    "少" : "shǎo"
    "业" : "yè"
    "喂" : [ "wéi", "wèi" ]
    "林" : [ "lín" ]



###
Change tone of given pinyin
@param newTone integer between 1 and 5
###
changeTone = (pinyin, newTone) ->
    # assume there is only one toned character in the pinyin. Thus as soon as we've made our first change
    # we will return
    i = -1

    vowels = [
        ['ā', 'á', 'ǎ', 'à', 'a']
        ['ē', 'é', 'ě', 'è', 'e']
        ['ī', 'í', 'ǐ', 'ì', 'i']
        ['ō', 'ó', 'ǒ', 'ò', 'o']
        ['ū', 'ú', 'ǔ', 'ù', 'u', ]
        ['ǖ', 'ǘ', 'ǚ', 'ǜ', 'u', ] # use 'u' for neutral so that user can type it in (orig = ü)
    ]

    while pinyin.length > ++i
        char = pinyin.charAt(i)

        for tones in vowels
            ti = 1
            while 4 >= ti   # finish at 4 - we skip the first tone (neutral)
                # found a tone we need to change?
                if tones[ti-1] is char and newTone isnt ti
                    char = tones[newTone - 1]
                    return pinyin.substr(0,i) + char + (pinyin.substr(i+1))

                ti++

    return pinyin



# construct pinyin -> character mappings
ReverseDict = {}
for own char, pinyin of Dict
    pinyin = [pinyin] if not _isArray(pinyin)
    for p in pinyin
        p = changeTone(p, 5)
        if not ReverseDict[p]?
            ReverseDict[p] = []
        ReverseDict[p].push char




###
Get list of characters matching given pinyin.
###
module.exports.lookup = (pinyin) ->
    pinyin = ("" + pinyin).toLowerCase()
    ReverseDict[changeTone(pinyin,5)] ? []


###
A sentence builder which makes it easy to build a list of characters with modified tones when necessary.
###
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
            if not Dict.hasOwnProperty(char)
                console.log [chars, i]
                throw "Unrecognized char: " + char
            pinyin = Dict[char]
            pinyin = pinyin[0] if _isArray(pinyin)
            if chars.length-1 > i
                # changing the tone of the character？
                toneModifier = parseInt(chars[i+1])
                if 1 <= toneModifier and 5 >= toneModifier
                    pinyin = changeTone(pinyin, toneModifier)
                    i++ # skip next char

            # add to sentence
            @sentence.push
                char: char
                pinyin: pinyin
        @


    getChars: ->
        ret = ""
        for w in @sentence
            ret += w.char
        ret

    getPinyin: ->
        ret = ""
        for w in @sentence
            if "" isnt ret
                ret += " "
            ret += w.pinyin
        ret

    toString: ->
        @getChars()

    ###
    Get whether given string of characters matches this sentence.

    Returns TRUE if and if only if fully matches or an object.

    If there is a mismatch then it returns:
        {
            num: number indicating number of mismatched chars
                (if 0 is returned then there are no mismatched chars but the there may be missing chars, i.e.
                the string is unfinished,
            chars: the mismatching and missing chars. if this is empty then too many chars were given in the input.
        }
    ###
    matches: (actual) ->
        expected = @getChars().split("")
        actual = actual.split("")

        # current character positions
        a = 0
        e = 0

        # no. of real comparable characters in each string
        a_real_chars = 0
        e_real_chars = 0

        # mismatches
        incorrect = 0
        mismatches = []

        puncts = ["？","！","。","，","；"," ","?","!",".",",",";"," "]

        # keep going until both pointers reach end of sentence
        while expected.length > e and actual.length > a
            # skip unimportant characters to make things easier
            if 0 <= puncts.indexOf(expected[e])
                e++
            else if 0 <= puncts.indexOf(actual[a])
                a++
            else
                e_real_chars++
                a_real_chars++

                if expected[e] isnt actual[a]
                    incorrect++
                    mismatches.push expected[e]

                a++
                e++

        # how many more real chars were remaining to be matched
        while expected.length > e
            if 0 > puncts.indexOf(expected[e])
                e_real_chars++
                mismatches.push expected[e]
            e++

        # too much input given?
        while actual.length > a
            incorrect++ if 0 > puncts.indexOf(actual[a])
            a++

        # fully matched?
        if 0 is incorrect and a_real_chars is e_real_chars
            incorrect = true
        else
            incorrect =
                num: incorrect
                chars: mismatches

        incorrect






