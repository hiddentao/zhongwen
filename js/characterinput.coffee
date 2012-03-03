###
Handles character input on canvas.

All of the stroke code and other stuff is based on code from http://jabtunes.com/notation/chinesestroke.html.

We let users input to a canvas. Assumes existence of jQuery. If jQuery Mobile is running it will use the events from
jQuery Mobile for canvas touch detection (vmousedown, etc.).

TODO: the stroke detection is pretty poor at the moment so it's not really worth using. in some distant future I may look into better OCR techniques!
###
class module.exports

    ###
    @param canvas the Canvas DOM element to watch.
    @param callback will get called with character suggestions
    ###
    constructor: (canvas, callback) ->
        @callback = callback

        @canvas = canvas
        @canvasDOM = @canvas.get(0)
        @ctx = @canvasDOM.getContext("2d")

        @charStrokes = []  # all strokes made for current character
        @charBBox = null        # character bounding box
        @currentStrokeXYs = []    # data points for current stroke
        @characterAnalysisTimeout = null   # timeout used for analysing character

        drawingStroke = false

        # touch/mouse events
        if undefined isnt window.jQuery.mobile
            mousedown = "vmousedown"
            mousemove = "vmousemove"
            mouseup = "vmouseup"
        else
            mousedown = "mousedown, touchstart"
            mousemove = "mousemove, touchmove"
            mouseup = "mouseup, touchend"

        @canvas.bind mousedown, (e) =>
            return if drawingStroke
            return if 0 isnt e.which and 1 isnt e.which   # only detect left-mouse button or finger touch
            drawingStroke = true
            [x,y] = @_getCanvasXY(e)
            @_startStroke x,y

        @canvas.bind mousemove, (e) =>
            return if not drawingStroke
            [x,y] = @_getCanvasXY(e)
            @_continueStroke x,y

        @canvas.bind mouseup, (e) =>
            return if not drawingStroke
            return if 0 isnt e.which and 1 isnt e.which   # only detect left-mouse button or finger touch
            drawingStroke = false
            [x,y] = @_getCanvasXY(e)
            @_endStroke x,y

        # when window size changes clear the canvas and resize
        $(window).resize @reset

        @reset()



    ###
    Clear and reset stroke input
    ###
    reset: =>
        clearTimeout(@characterAnalysisTimeout) if @characterAnalysisTimeout
        @canvasDOM.width = @canvas.parent().width()
        @canvasDOM.height = Math.min(@canvas.parent().height(), 200)
        @ctx.clearRect  0 , 0 , @canvasDOM.width , @canvasDOM.height
        @charStrokes = []
        @charBBox =
            min:
                x: 50000
                y: 50000
            max:
                x: -50000
                y: -50000


    # PRIVATE METHODS

    _getCanvasXY: (event) ->
        x = event.pageX - @canvas.offset().left
        y = event.pageY - @canvas.offset().top
        return [x,y]

    _startStroke: (x, y) ->
        @currentStrokeXYs= []
        @ctx.strokeStyle = "black"
        @ctx.lineWidth = 2.5
        @ctx.beginPath()
        @ctx.moveTo(x,y)
        @_addStrokePoint x, y


    _addStrokePoint: (x, y) ->
        clearTimeout(@characterAnalysisTimeout) if @characterAnalysisTimeout

        # don't repeat a point
        return if @lastStrokePt and x is @lastStrokePt.x and y is @lastStrokePt.y
        @lastStrokeTime = new Date()
        @lastStrokePt =
            x: x
            y: y
        @currentStrokeXYs.push @lastStrokePt
        @ctx.lineTo(x,y)
        @ctx.stroke()

        # update bbox
        @charBBox.max.x = Math.max @charBBox.max.x, x
        @charBBox.max.y = Math.max @charBBox.max.y, y
        @charBBox.min.x = Math.min @charBBox.min.x, x
        @charBBox.min.y = Math.min @charBBox.min.y, y


    _continueStroke: (x, y) ->
        # prevent too much CPU consumption
        return if ((new Date().getTime()-@lastStrokeTime)<50)
        @_addStrokePoint x, y


    _endStroke: (x, y) ->
        @_addStrokePoint x, y
        @charStrokes.push(@currentStrokeXYs)
        # wait 0.25 seconds before analyzing the stroke
        @characterAnalysisTimeout = setTimeout @_analyse, 750   # give user time to input more strokes


    ###
    Analyse the current strokes to get a character
    ###
    _analyse: =>
        # time this!
        startTime = new Date()

        # get stroke length normalizer
        width = @charBBox.max.x - @charBBox.min.x
        height = @charBBox.max.y = @charBBox.min.y
        dimensionSquared = if width > height then width * width else height * height
        normalizer = Math.pow(dimensionSquared * 2, 0.5)

        # get gradient and length of each stroke
        userStrokes = []
        for strokeXYs in @charStrokes
            # We use short straw algorithm for sub stroke detection
            # It works for simple strokes, but we should handle its substrokes
            # more carefully (TODO)
            corners = window.shortStraw(strokeXYs)

            # highlight detected corners using lines
            @ctx.strokeStyle = "red"
            @ctx.lineWidth = 1.5
            @ctx.beginPath()
            @ctx.moveTo corners[0].x, corners[0].y

            i = 0
            while corners.length > ++i
                @ctx.lineTo corners[i].x, corners[i].y

                p1 = corners[i-1]
                p2 = corners[i]

                dy = p1.y - p2.y
                dx = p1.x - p2.x

                length = Math.pow(dy*dy + dx*dx, 0.5)
                normalizedLength = length / normalizer
                angle = Math.PI - Math.atan2(dy, dx)

                userStrokes.push
                    angle: angle
                    length: normalizedLength

            @ctx.stroke()



        # find possible matches
        possible_matches = []
        for charDescriptor in window.strokes
            charStrokes = []
            i = 0
            while charDescriptor.length > ++i
                charStrokes.push
                    angle: charDescriptor[i][0]
                    length: charDescriptor[i][1]

            score = @__match( userStrokes, charStrokes )
            if -1 < score
                possible_matches.push
                    char: '\&#0'+parseInt(charDescriptor[0], 16)
                    score: score

            # once we've got 8 matches let's stop
            break if 8 <= possible_matches.length

        # sort into highest score first
        possible_matches.sort (a,b) -> b.score - a.score

        # how long did this take?
        timeTaken = (new Date()).getTime() - startTime.getTime()

        # notify listener
        setTimeout (=> @callback.call(null, possible_matches, timeTaken)), 0




    ###
    Find out how well given user strokes match to given character strokes
    ###
    __match: ( userStrokes, charStrokes ) ->
        score = 0

        # need same number of strokes
        return -1 if userStrokes.length isnt charStrokes.length

        i = -1
        while userStrokes.length > ++i

            userStroke = userStrokes[i]
            charStroke = charStrokes[i]

            # length score
            ls = Math.abs(userStroke.length - charStroke.length)
            dl = 1 - ls # so that differences >1 are considered negative

            # angle score
            ds = Math.abs(userStroke.angle - charStroke.angle)
            # take smallest possible angle between the two as the difference
            if Math.PI < ds
                ds = 2*Math.PI - ds
            # inverse percentage difference (i.e. smaller percent = worse)
            ds = 100 * (1 - (ds / (2* Math.PI)))

            score += (ds + dl * charStroke.length)

        score
