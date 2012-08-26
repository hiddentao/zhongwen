dict = require '../coffee/dict'

exports.testObjectsExist = (test) ->
    test.expect(2)

    test.ok(dict.Dict)
    test.ok(dict.Sentence)

    test.done()


exports.testPinyinLookup = (test) ->
    test.expect(6)

    assertArrayEqual = (e, a, m) ->
        test.strictEqual JSON.stringify(e), JSON.stringify(a)

    assertArrayEqual dict.lookup("shi"), ["是","十","师","时","室","市"]
    assertArrayEqual dict.lookup("Shi"), ["是","十","师","时","室","市"]
    assertArrayEqual dict.lookup("SHI"), ["是","十","师","时","室","市"]
    assertArrayEqual dict.lookup("?"), ["？"]
    assertArrayEqual dict.lookup("nei"), ["哪", "那"]
    assertArrayEqual dict.lookup("na"), ["哪", "那"]

    test.done()


exports.sentence =

    testEmpty: (test) ->
        test.expect(2)

        s = new dict.Sentence()
        test.strictEqual s.getChars(), ""
        test.strictEqual s.getPinyin(), ""

        test.done()

    testSingleCharAndToString: (test) ->
        test.expect(3)

        s = new dict.Sentence("啊")
        test.strictEqual s.toString(), "啊"
        test.strictEqual s.getChars(), "啊"
        test.strictEqual s.getPinyin(), "a"

        test.done()

    testTwoChars: (test) ->
        test.expect(3)

        s = new dict.Sentence("啊王")
        test.strictEqual s.toString(), "啊王"
        test.strictEqual s.getChars(), "啊王"
        test.strictEqual s.getPinyin(), "a wáng"

        test.done()

    testInvalidChar: (test) ->
        test.expect(1)

        test.throws -> s = new dict.Sentence("豆")

        test.done()

    testToneChange: (test) ->
        test.expect(1)

        s = new dict.Sentence("一1一2一3一4一5")
        test.strictEqual s.getPinyin(), "yī yí yǐ yì yi"

        test.done()

    testMatching: (test) ->
        test.expect(10)

        s = new dict.Sentence("先生！，星期三几点去美国？")

        assertObjectEqual = (e, a, m) ->
            test.strictEqual JSON.stringify(e), JSON.stringify(a)

        # check that punctuation is ignored
        assertObjectEqual s.matches("先生!!！?？！？;,  ，；.。星"), {num:0, chars:["期","三","几","点","去","美","国"]}, "skip puncts"

        # test incorrect and correct count
        assertObjectEqual s.matches("先生期，"), {num:1, chars:["星","期","三","几","点","去","美","国"]}, "1 wrong"
        assertObjectEqual s.matches("先期生，"), {num:2, chars:["生","星","期","三","几","点","去","美","国"]}, "2 wrong"
        assertObjectEqual s.matches("先生星，"), {num:0, chars:["期","三","几","点","去","美","国"]}, "0 wrong"

        # test end of sentence boundary cases
        assertObjectEqual s.matches("先生星期三几点去美"), {num:0, chars:["国"]}, "almost full match"
        assertObjectEqual s.matches("先生星期三几点去美？"), {num:0, chars:["国"]}, "almost full match with ?"
        assertObjectEqual s.matches("先生星期三几点去美国"), true, "full match"
        assertObjectEqual s.matches("先生星期三几点去美国？"), true, "full match  with ?"
        assertObjectEqual s.matches("先生星期三几点去美国老"), {num:1, chars:[]}, "too much"
        assertObjectEqual s.matches("先生星期三几点去美国老？"), {num:1, chars:[]}, "too much with ?"

        test.done()
