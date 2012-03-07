Spine = require("spine")
SentenceBuilders = require("sentences")
dict = require("dict")


class module.exports extends Spine.Controller

    current_sentence: null

    el: $("#page-tester")

    elements:
        "#sentence" : "sentence"
        "#nav" : "nav_next"
        "#progress" : "progress"
        "form textarea" : "zhongwen_input"
        "form input" : "pinyin_input"
        "#suggestions" : "suggestions"

    constructor: ->
        super

        # pinyin input
        @pinyin_input.bind 'keydown', (e) =>
            code = parseInt(e.which)
            # numbers
            if 49 <= code and 57 >= code
                e.preventDefault()
                @_selectSuggestion(code - 49)

        @pinyin_input.bind 'keyup', =>
            @_updateSuggestions dict.lookup(@pinyin_input.val())

        @zhongwen_input.bind 'keyup', @_updateProgress

        # skip button
        $("#skipbtn", @el).bind 'vclick', (e) =>
            e.preventDefault()
            @_showNextSentence()

        # next button
        $("button", @nav_next).bind 'vclick', (e) =>
            e.preventDefault()
            @_showNextSentence()


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
        @category = category;

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
    Check user's input and update progress
    ###
    _updateProgress: =>
        @nav_next.hide()

        actual = @zhongwen_input.val()
        return @progress.hide() if 0 >= actual.length

        incorrect = @current_sentence.cn.matches(actual)

        if incorrect is true
            @progress.removeClass("bad").addClass("good").text("you did it!")
            @nav_next.show()
        else
            if 0 < incorrect
                @progress.removeClass("good").addClass("bad").text(incorrect + " incorrect")
            else
                @progress.removeClass("bad").addClass("good").text("good so far")

        @progress.show()


    ###
    Select given pinyin suggestion if possible
    ###
    _selectSuggestion: (td) =>
        return if not @suggestions.is(":visible")
        td = $("td:eq(#{td})", @suggestions) if "number" is typeof td
        if 0 < td.size()
            @_insertAtCaret @zhongwen_input.get(0), $("span.char",td).text()
            @_updateProgress()
            @suggestions.hide()
            @pinyin_input.val("").focus()


    ###
    Update pinyin suggestions view with given chars.
    ###
    _updateSuggestions: (chars) =>
        if 0 < chars.length
            $("td", @suggestions).remove()
            num = 0
            for c in chars
                $("tr", @suggestions).append "<td><span class='num'>#{++num}</span><span class='char'>#{c}</span></td>"

            pinyin_label_offset = $("label[for=pinyin]", @el).offset()
            @suggestions
                .css
                    position: "absolute"
                    top: pinyin_label_offset.top  + "px"
                    left: pinyin_label_offset.left + "px"
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
        @sentence.text("")
        @zhongwen_input.val("")
        @pinyin_input.val("")
        @suggestions.hide();

        n = parseInt(Math.random() * @active_builders.length)
        @current_sentence = @active_builders[n].next()
        @sentence.text(@current_sentence.en)



    # Capitalize string
    _capitalize: (str) ->
        str.charAt(0).toUpperCase() + str.slice(1)


    ###
    Insert text at caret position in given element.
    Take from: http://stackoverflow.com/a/4384173
    ###
    _insertAtCaret: (element, text) ->
        if document.selection
            element.focus()
            sel = document.selection.createRange()
            sel.text = text
            element.focus()
        else if element.selectionStart or element.selectionStart is 0
            startPos = element.selectionStart
            endPos = element.selectionEnd
            scrollTop = element.scrollTop
            element.value = element.value.substring(0, startPos) + text + element.value.substring(endPos, element.value.length)
            element.focus()
            element.selectionStart = startPos + text.length
            element.selectionEnd = startPos + text.length
            element.scrollTop = scrollTop
        else
            element.value += text
            element.focus()
