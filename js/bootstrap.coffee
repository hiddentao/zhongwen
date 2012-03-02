Spine = require("spine")
Sentences = require("sentences")


class module.exports extends Spine.Controller

    constructor: (category) ->
        super

        # configure jQuery Mobile
        $.extend $.mobile,
            ajaxEnabled: false
            autoInitializePage: true
            defaultPageTransition: 'none'
            hashListeningEnabled: true
            touchOverflowEnabled: true

        # initialization stuff
        initialised = false
        $(document).bind 'pageinit', (event) ->
            if not initialised
                initialised = true

                # add footer to every page
                $('section:jqmData(role="page")').append($('footer').detach())

                jqLastSelectedChoice = null;
                # when selecting a question choice keep note of which one was chosen
                $("#page-home .choice a").click ->
                    jqLastSelectedChoice = $(this);

                $(document).bind 'pagebeforechange', (e, data) ->
                    # if changing to sentences page
                    if typeof data.toPage is "object" and "page-sentences" is data.toPage.attr("id")
                        # if no category choice made then goto homepage
                        if null is jqLastSelectedChoice
                            e.preventDefault()
                            $.mobile.changePage( $("#page-home") )


                sentences = new Sentences()
                $(document).bind 'pagechange', (e, data) ->
                    # if going to sentences page
                    if "page-sentences" is data.toPage.attr("id")
                        # set page title
                        $("#page-sentences header h1").text(jqLastSelectedChoice.text())
                        $("#page-sentences").jqmData( "title", jqLastSelectedChoice.text() )
                        document.title = jqLastSelectedChoice.text()
                        # kick off sentences
                        sentences.start(jqLastSelectedChoice.data("category"))
                        jqLastSelectedChoice = null    # reset category



