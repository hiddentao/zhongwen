Sentence = require("dict").Sentence


class SentenceBuilder
    ###
    Build a random sentence.

    @return {en: english translation, cn: a dict.Sentence instance}.
    ###
    next: ->
        throw "Not yet implemented"
    ###
    Short description for this builder
    ###
    shortDesc: ->
        throw "Not yet implemented"


class Units_1_To_4 extends SentenceBuilder
    next: -> {
        en: "He is Mr. Wang"
        cn: "他是王先生5"
    }
    shortDesc: ->
        return "units 1 to 4"


module.exports =
    Beginner:
        '1to4': new Units_1_To_4





