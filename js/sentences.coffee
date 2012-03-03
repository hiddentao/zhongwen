Spine = require("spine")
Beginner = require("beginner")
CharacterInput = require("characterinput")


class module.exports extends Spine.Controller

    el: $("#page-sentences")

    elements:
        ".sentence" : "p_sentence"
        ".translation" : "div_translation"
        ".input" : "div_input"
        ".input .instructions" : "input_instructions"
        ".input .clear" : "btn_clear_canvas"
        ".input .suggestions" : "div_suggestions"

    constructor: ->
        super

        @builders =
            beg:
                '1to4': new Beginner.Units_1_To_4
                '5to6': new Beginner.Units_5_To_6

        # setup char input
        @charInput = new CharacterInput($("canvas", @div_input), @_handleCharacterInput)
        @btn_clear_canvas.click =>
            @div_suggestions.hide()
            @charInput.reset()

        # selecting a char suggestion
        @div_suggestions
            .html("<table cellpadding='0' cellspacing='0'><tr></tr></table>")
            .hide()
            .on 'click', 'td', (e) =>
                @div_suggestions.hide()
                alert $(e.target).text()



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
            Object.keys(@builders[maincat]).forEach ((v,i,a) =>
                @active_builders.push @builders[maincat][v]
            ), @
        else
            # get 1
            @active_builders.push @builders[maincat][subcat]

        # reset the display
        @p_sentence.text("")
        @div_translation.html("")
        @charInput.reset()
        @div_suggestions.hide();

        @_go()



    # PRIVATE METHODS


    ###
    Handle a character input.

    @param charSuggestions array in form [charHtmlEntity, Score] in descending score order.
    @param timeTaken time taken to find matching characters
    ###
    _handleCharacterInput: (charSuggestions, timeTaken) =>
        $("td", @div_suggestions).remove()
        for c in charSuggestions
            $("tr", @div_suggestions).append "<td>#{c.char}</td>"

        @div_suggestions
            .css
                position: "absolute"
                width: @input_instructions.width()
                top: @input_instructions.offset().top  + "px"
                left: @input_instructions.offset().left + "px"
            .show()


    #
    # The main "loop".
    #
    _go: ->
        console.log @active_builders
