dict = require '../js/dict'

exports.testObjectsExist = (test) ->
    test.expect(2)

    test.ok(dict.Dict)
    test.ok(dict.Sentence)

    test.done()


exports.testPinyinLookup = (test) ->
    test.expect(6)

    test.arrayEqual = (e, a, m) ->
        test.strictEqual JSON.stringify(e), JSON.stringify(a)

    test.arrayEqual dict.lookup("shi"), ["是","十","师","时"]
    test.arrayEqual dict.lookup("Shi"), ["是","十","师","时"]
    test.arrayEqual dict.lookup("SHI"), ["是","十","师","时"]
    test.arrayEqual dict.lookup("?"), ["？"]
    test.arrayEqual dict.lookup("nei"), ["哪", "那"]
    test.arrayEqual dict.lookup("na"), ["哪", "那"]

    test.done()


exports.sentence = {

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

        # check that punctuation is ignored
        test.strictEqual s.matches("先生!!！?？！？;,  ，；.。星"), 0, "skip puncts"

        # test incorrect and correct count
        test.strictEqual s.matches("先生期，"), 1, "1 wrong"
        test.strictEqual s.matches("先期生，"), 2, "2 wrong"
        test.strictEqual s.matches("先生星，"), 0, "0 wrong"

        # test end of sentence boundary cases
        test.strictEqual s.matches("先生星期三几点去美"), 0, "almost full match"
        test.strictEqual s.matches("先生星期三几点去美？"), 0, "almost full match with ?"
        test.strictEqual s.matches("先生星期三几点去美国"), true, "full match"
        test.strictEqual s.matches("先生星期三几点去美国？"), true, "full match  with ?"
        test.strictEqual s.matches("先生星期三几点去美国老"), 1, "too much"
        test.strictEqual s.matches("先生星期三几点去美国老？"), 1, "too much with ?"

        test.done()

}


