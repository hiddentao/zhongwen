var Spine = require("spine");

exports = Spine.Controller.sub({

    init: function(category) {
        this.category = category;
    },

    /**
     * Start the questions.
     */
    start: function() {
        alert(this.category);
    }

});
