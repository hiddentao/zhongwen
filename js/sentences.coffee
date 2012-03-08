Sentence = require("dict").Sentence
data = require("data")


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
    constructor: ->
        @_sentences = []
        tokens = data.Units1to4.split("\n")
        i = 0
        while tokens.length-1 > i
            @_sentences.push [tokens[i], tokens[i+1]]
            i += 2

    next: ->
        s = @_sentences[parseInt(Math.random() * @_sentences.length)]
        {
            en: s[0]
            cn: new Sentence(s[1])
        }

    shortDesc: ->
        return "Units 1 to 4"


class Unit_5 extends SentenceBuilder
    constructor: ->
        @_sentences = []
        tokens = data.Unit5.split("\n")
        i = 0
        while tokens.length-1 > i
            @_sentences.push [tokens[i], tokens[i+1]]
            i += 2

    next: ->
        s = @_sentences[parseInt(Math.random() * @_sentences.length)]
        {
            en: s[0]
            cn: new Sentence(s[1])
        }

    shortDesc: ->
        return "Unit 5"



module.exports =
    Beginner:
        '1to4': new Units_1_To_4
        '5': new Unit_5





