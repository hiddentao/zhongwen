Spine = require("spine")
Tester = require("tester")

class module.exports extends Spine.Controller

    constructor: (category) ->
        super

        # prevent native browser scrolling
        document.body.addEventListener 'touchmove', ((e) -> e.preventDefault()), false

        # configure jQuery Mobile
        $.extend $.mobile,
            ajaxEnabled: false
            hashListeningEnabled: true

        # initialization stuff
        initialised = false
        $(document).bind 'pageinit', (event) ->
            if not initialised
                initialised = true

                # add footer to every page
                $('section:jqmData(role="page")').append($('footer').detach())

                # add tester choices
                tester = new Tester()
                choices = tester.getChoices()
                for group in choices
                    choiceGroup = $("<div class=\"choice\" data-role=\"controlgroup\">")
                    for item in group
                        choiceGroup.append("<a href=\"#tester\" data-role=\"button\" data-category=\"#{item.category}\">#{item.label}</a>")
                    $("#page-home .content").append(choiceGroup)

                $("#page-home .content").trigger( "create" )


                jqLastSelectedChoice = null;
                # when selecting a question choice keep note of which one was chosen
                $("#page-home").on 'click', '.choice a',  ->
                    jqLastSelectedChoice = $(this);

                $(document).bind 'pagebeforechange', (e, data) ->
                    # if changing to tester page
                    if typeof data.toPage is "object" and "page-tester" is data.toPage.attr("id")
                        # if no category choice made then goto homepage
                        if null is jqLastSelectedChoice
                            e.preventDefault()
                            $.mobile.changePage( $("#page-home") )


                $(document).bind 'pagechange', (e, data) ->
                    # if going to tester page
                    if "page-tester" is data.toPage.attr("id")
                        # set page title
                        $("#page-tester header h1").text(jqLastSelectedChoice.text())
                        $("#page-tester").jqmData( "title", jqLastSelectedChoice.text() )
                        # kick off sentences
                        tester.start(jqLastSelectedChoice.data("category"))
                        jqLastSelectedChoice = null    # reset category



