Sentence = require("dict").Sentence
data = require("data")


###
Base class.
###
class SentenceBuilder
    constructor: (list) ->
        @_sentences = []
        tokens = list.split("\n")
        i = 0
        while tokens.length-1 > i
            @_sentences.push [tokens[i], tokens[i+1]]
            i += 2

    ###
    Build a random sentence.

    @return {en: english translation, cn: a dict.Sentence instance}.
    ###
    next: ->
        s = @_sentences[parseInt(Math.random() * @_sentences.length)]
        {
            en: s[0]
            cn: new Sentence(s[1])
        }

    ###
    Short description for this builder
    ###
    shortDesc: ->
        throw "Not yet implemented"


class Units_1_To_4 extends SentenceBuilder
    constructor: ->
        super data.Units1to4
    shortDesc: ->
        return "Units 1 to 4"


class Unit_5 extends SentenceBuilder
    constructor: ->
        super data.Unit5
    shortDesc: ->
        return "Unit 5"


class Unit_6 extends SentenceBuilder
    constructor: ->
        super data.Unit6
    shortDesc: ->
        return "Unit 6"


class CommonPhrases extends SentenceBuilder
  constructor: ->
    super [data.Greetings, data.Directions, data.Hotel].join('\n')
  shortDesc: ->
    return "Common phrases"


module.exports =
    Beginner:
        '0_1to4': new Units_1_To_4
        '1_5': new Unit_5
        '2_6': new Unit_6
        '3_CP': new CommonPhrases





