###
Handles character input on canvas.

All of the stroke code and other stuff is based on code from http://jabtunes.com/notation/chinesestroke.html
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

        @allStrokes = []  # all strokes made for current character
        @strokeBBox = {}    # bounding box for current character
        @strokeXYs = []    # data points for current stroke
        @characterAnalysisTimeout = null   # timeout used for analysing character

        # touch/mouse events
        drawingStroke = false
        @canvas.mousedown (e) =>
            return if drawingStroke
            drawingStroke = true
            [x,y] = @_getCanvasXY(e)
            @_startStroke x,y

        @canvas.mousemove (e) =>
            return if not drawingStroke
            [x,y] = @_getCanvasXY(e)
            @_continueStroke x,y

        @canvas.mouseup (e) =>
            return if not drawingStroke
            drawingStroke = false
            [x,y] = @_getCanvasXY(e)
            @_endStroke x,y

        @clear()



    ###
    Clear canvas
    ###
    clear: ->
        clearTimeout(@characterAnalysisTimeout) if @characterAnalysisTimeout
        # set canvas size to match css
        @canvasDOM.width = @canvas.parent().width()
        @canvasDOM.height = @canvas.parent().height()
        @ctx.clearRect  0 , 0 , @canvasDOM.width , @canvasDOM.height
        @allStrokes = []
        @strokeBBox =
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
        @strokeXYs= []
        @ctx.strokeStyle = "black"
        @ctx.lineWidth = 2.5
        @ctx.beginPath()
        @ctx.moveTo(x,y)
        @_addStrokePoint x, y


    _addStrokePoint: (x, y) ->
        # don't repeat a point
        return if @lastStrokePt and x is @lastStrokePt.x and y is @lastStrokePt.y
        @lastStrokeTime = new Date()
        @lastStrokePt =
            x: x
            y: y
        @strokeXYs.push @lastStrokePt
        @ctx.lineTo(x,y)
        @ctx.stroke()

        # update bounding box
        @strokeBBox.max.x = Math.max @strokeBBox.max.x, x
        @strokeBBox.max.y = Math.max @strokeBBox.max.y, y
        @strokeBBox.min.x = Math.min @strokeBBox.min.x, x
        @strokeBBox.min.y = Math.min @strokeBBox.min.y, y



    _continueStroke: (x, y) ->
        # prevent too much CPU consumption
        return if ((new Date().getTime()-@lastStrokeTime)<50)
        @_addStrokePoint x, y


    _endStroke: (x, y) ->
        @_addStrokePoint x, y
        @allStrokes.push(@strokeXYs)
        # wait 0.25 seconds before analyzing the stroke
        clearTimeout(@characterAnalysisTimeout) if @characterAnalysisTimeout
        @characterAnalysisTimeout = setTimeout @_analyse, 250


    ###
    Analyse the current strokes to get get a character
    ###
    _analyse: =>
        # time this!
        startTime = new Date()

        # We use short straw algorithm for sub stroke detection
        # It works for simple strokes, but we should handle its substrokes
        # more carefully (TODO)
        stroke = @strokeXYs
        corners = shortStraw(stroke)

        # highlight detected corners using lines
        # work out the bounding box
        @ctx.strokeStyle = "red"
        @ctx.lineWidth = 1.5
        @ctx.beginPath()
        @ctx.moveTo corners[0].x,corners[0].y
        for corner  in corners
            # draw line
            @ctx.lineTo corner.x, corner.y
        @ctx.stroke()

        # work out bbox dimensions and get stroke length normalizer
        width = @strokeBBox.max.x - @strokeBBox.min.x
        height = @strokeBBox.max.y = @strokeBBox.min.y
        dimensionSquared = if width > height then width * width else height * height
        normalizer = Math.pow(dimensionSquared * 2, 0.5)

        # get gradient and length of each stroke
        userStrokes = []
        i = 0
        while corners.length > ++i
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
