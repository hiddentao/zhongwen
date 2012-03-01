###
Handles character input on canvas.

All of the stroke code and other stuff is copied from http://jabtunes.com/notation/chinesestroke.html
###
class module.exports

    ###
    @param canvas the Canvas DOM element to watch.
    @param callback will get called with character suggestions
    ###
    constructor: (canvas, callback) ->
        @canvas = canvas
        @canvasDOM = @canvas.get(0)
        @ctx = @canvasDOM.getContext("2d")
        @callback = callback

        @allStrokes = []  # all strokes made for a single character
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



    ###
    Clear canvas
    ###
    clear: ->
        clearTimeout(@characterAnalysisTimeout) if @characterAnalysisTimeout
        @ctx.clearRect  0 , 0 , @canvasDOM.width , @canvasDOM.height
        @allStrokes = []



    # PRIVATE METHODS

    _getCanvasXY: (event) ->
        x = event.pageX - @canvas.offset().left
        y = event.pageY - @canvas.offset().top
        console.log [x,y]
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
    _analyse: ->

        # todo: before executing callback check if timeout has been cleared already by clear(). if so then don't
        # call the callback.

        true
