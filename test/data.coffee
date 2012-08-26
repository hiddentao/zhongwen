dict = require '../coffee/dict'
data = require '../coffee/data'


testChars = (test, dataString) ->
    d = dataString.split("\n")
    test.expect(d.length / 2)

    i = 1
    while d.length > i
        test.doesNotThrow -> new dict.Sentence(d[i])
        i += 2

    test.done()


exports.valid_data =
    test_Units_1_to_4: (test) -> testChars test, data.Units1to4
    test_Unit_5: (test) -> testChars test, data.Unit5
    test_Unit_6: (test) -> testChars test, data.Unit6
    test_Greetings: (test) -> testChars test, data.Greetings
    test_Directions: (test) -> testChars test, data.Directions
    test_Hotel: (test) -> testChars test, data.Hotel
