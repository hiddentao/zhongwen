var Spine = require("spine");
var Questions = require("questions");


exports = Spine.Controller.sub({

    init: function(category) {
        // configure jQuery Mobile
        $.extend( $.mobile, {
            ajaxEnabled: false,
            autoInitializePage: true,
            defaultPageTransition: 'none',
            hashListeningEnabled: true,
            touchOverflowEnabled: true
        });

        // Once homepage is showing...
        $( '#page-home' ).live( 'pageinit',function(event) {
            // add footer to every page
            $('section:jqmData(role="page")').append($('footer').detach());

            // when selecting a question choice keep note of which one was chosen
            var jqLastSelectedChoice = null;
            $("#page-home .choice a").click(function(){
                jqLastSelectedChoice = $(this);
            });

            $(document).bind('pagechange', function(e, data){
                // if going to questions page
                if ("page-questions" === data.toPage.attr("id")) {
                    // set page title
                    $("#page-questions header h1").text(jqLastSelectedChoice.text());
                    // kick off questions
                    new Questions(jqLastSelectedChoice.data("category").start());
                }
            });
        });

    }

});



