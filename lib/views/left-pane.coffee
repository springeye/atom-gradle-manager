{View, $} = require 'space-pen'
LeftTaskView = require './left-task-view.coffee'
class LeftPane extends View
  @content:->
    @div class:'left-pane',=>
      @div outlet: 'resizeHandle', class: 'resize-handle'
      @div class:'left-container',=>
        @div outlet:'body',class:'title-bar','Gradle Tasks'
        @subview 'taskView',new LeftTaskView()
  handleEvents: ->
    @on 'mousedown', '.resize-handle', (e) => @resizeStarted e
  resizeStarted: =>
    $(document).on 'mousemove', @resizePane
    $(document).on 'mouseup', @resizeStopped
  resizeStopped: =>
    $(document).off 'mousemove', @resizePane
    $(document).off 'mouseup', @resizeStopped

  resizePane: ({pageX,pageY, which}) ->
    width = $(document.body).width() - pageX
    $('.left-pane').width(width)
    $('.left-pane').trigger 'update'
    $('.left-pane').on 'update', ->
  initialize:->
#    @emitter = new Emitter()
    @handleEvents()
  refresh: (outputView,tasks) ->
    @taskView.refresh(outputView,tasks)
  clear:->
    @taskView.clear()
  destroy:->
    @resizeStopped()
    @remove
module.exports = LeftPane
