$ = jQuery
Spine = require("spine")
SentenceBuilders = require("sentences")
dict = require("dict")

PINYIN_CHARS = "abcdefghijklmnopqrstuvwxyz!?.,;"


# Solution from http://stackoverflow.com/a/3651232
#
# Note that this won't work on Android due to bug: http://code.google.com/p/android/issues/detail?id=15245
#
$.fn.setCursorPosition = (pos) ->
  @.each (index, elem) ->
    if (elem.setSelectionRange)
      elem.setSelectionRange(pos, pos)
    else if (elem.createTextRange)
      range = elem.createTextRange()
      range.collapse(true)
      range.moveEnd('character', pos)
      range.moveStart('character', pos)
      range.select()
  @


class module.exports extends Spine.Controller

    currentSentence: null
    pollLoop: null

    el: null

    elements:
        "#sentence" : "sentence"
        "#nav" : "nav_next"
        "#help" : "help"
        "#progress" : "progress"
        "form textarea" : "zhongwen_input"
        "#suggestions" : "suggestions"

    events:
        "swipeleft #sentence" : "nextBtn_click"
        "keydown textarea" : "input_keyDown"
        "keyup textarea" : "input_keyUp"
        "focus textarea" : "input_focus"
        "blur textarea" : "input_blur"
        "vclick #nav button" : "nextBtn_click"
        "vclick #help a" : "helpBtn_click"
        "vclick #skipbtn" : "skipBtn_click"

    input_keyDown: (e) =>
        code = parseInt(e.which)
        # it's a number
        if 49 <= code and 57 >= code
            # select character suggestion
            e.preventDefault()
            @_selectSuggestion(code - 49)
        # else it's a space
        else if 32 is code
            # select first pinyin suggestion
            e.preventDefault()
            @_selectSuggestion(0)

    input_keyUp: (e) =>
        # if the input is not a chinese char then update pinyin suggestions
        @_updateSuggestions() if 127 >= e.which

    input_focus: =>
        @pollLoop = setInterval @_updateProgress, 1000

    input_blur: =>
        clearInterval(@pollLoop) if @pollLoop
        @pollLoop = null

    skipBtn_click: (e) =>
        e.preventDefault()
        @_showNextSentence()

    nextBtn_click: (e) =>
        e.preventDefault()
        @_showNextSentence()

    helpBtn_click: (e) =>
        e.preventDefault()
        @_showHint()


    ###
    Get available test choices

    @return [{category: ...., label: ...}]
    ###
    getChoices: ->
        ret = []
        for maincat,subcats of SentenceBuilders
            thisCat = []
            thisCat.push
                category: "#{maincat}-all"
                label: "All"

            for subcat,builder of subcats
                thisCat.push
                    category: "#{maincat}-#{subcat}"
                    label: builder.shortDesc()

            ret.push thisCat

        ret



    #
    # Start the sentences for the given category
    #
    start: (category) ->
        @category = category

        # work out the category and subcat
        [maincat, subcat] = @category.split("-");

        # collect list of builders
        @active_builders = []
        if 'all' is subcat
            # get all
            Object.keys(SentenceBuilders[maincat]).forEach ((v,i,a) =>
                @active_builders.push SentenceBuilders[maincat][v]
            ), @
        else
            # get 1
            @active_builders.push SentenceBuilders[maincat][subcat]

        @_showNextSentence()



    # PRIVATE METHODS


    ###
    Give the user a hint.
    ###
    _showHint: =>
        incorrect = @currentSentence.cn.matches(@zhongwen_input.val())
        if true isnt incorrect and 0 < incorrect.chars.length
            # show it's pinyin as a hint
            pinyin = dict.Dict[incorrect.chars[0]]
            pinyin = pinyin[0] if Array.isArray(pinyin)
            alert("hint: #{pinyin}")


    ###
    Check user's input and update progress
    ###
    _updateProgress: =>
        @nav_next.hide()

        actual = @zhongwen_input.val()

        # remove pinyin from it
        pinyin = @_getPinyinSoFar()
        actual = actual.replace pinyin, ''

        return @progress.hide() if 0 >= actual.length

        incorrect = @currentSentence.cn.matches(actual)

        if incorrect is true
            @progress.attr("class", "good").text("you did it!")
            @nav_next.show()
            @help.hide()
        else
            if 0 < incorrect.num
                @progress.attr("class", "bad").text(incorrect.num + " incorrect")
            else
                @progress.attr("class", "good").text("good so far")

        @progress.show()


    ###
    Get pinyin which has been input so far
    ###
    _getPinyinSoFar: =>
        val = @zhongwen_input.val()
        pinyin = ""
        i = -1
        while val.length > ++i
            c = val.charAt(i)
            pinyin += c if 0 <= PINYIN_CHARS.indexOf(c.toLowerCase())

        pinyin


    ###
    Select given pinyin suggestion if possible
    ###
    _selectSuggestion: (char) =>
        return if not @suggestions.is(":visible")
        if "number" is typeof char
            char = $("td:eq(#{char}) span.char", @suggestions)
            return if 0 is char.size()
            char = char.text()


        # replace pinyin with char
        newChars =  @zhongwen_input.val().replace(@_getPinyinSoFar(), char)

       # update input
        @zhongwen_input
            .val("")        # unless we clear it first Android keeps re-inserting the previously typed string
            .val(newChars)
            .setCursorPosition(newChars.length)

        @suggestions.hide()
        @_updateProgress()


    ###
    Update pinyin suggestions view.
    ###
    _updateSuggestions: () =>
        chars = dict.lookup(@_getPinyinSoFar())

        if 0 < chars.length
            $("td", @suggestions).remove()
            num = 0
            for c in chars
                $("tr", @suggestions).append "<td><span class='num'>#{++num}</span><span class='char'>#{c}</span></td>"

            $("td", @suggestions).each (i,e) =>
                $(e).bind 'vclick', => @_selectSuggestion $(".char", e).text()


            label_offset = $("#zhongwen_label", @el).offset()
            @suggestions
                .css
                    position: "absolute"
                    top: label_offset.top  + "px"
                    left: label_offset.left + "px"
                .show()
        else
            @suggestions.hide()


    #
    # Show next sentence
    #
    _showNextSentence: =>
        # reset the display
        @progress.hide()
        @nav_next.hide()
        @help.show()
        @sentence.text("")
        @zhongwen_input.val("")
        @suggestions.hide();

        n = parseInt(Math.random() * @active_builders.length)
        @currentSentence = @active_builders[n].next()
        @sentence.text(@currentSentence.en)



    # Capitalize string
    _capitalize: (str) ->
        str.charAt(0).toUpperCase() + str.slice(1)


