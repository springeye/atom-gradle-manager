{View, $} = require 'space-pen'
LeftTaskView = require './left-task-view.coffee'
class LeftPane extends View

  @content:->
    console.log 'content'
    @div class:'left-pane',=>
        @div outlet:'body',class:'title-bar','Gradle Tasks'
        @subview 'taskView',new LeftTaskView()
  refresh: (outputView,tasks) ->
    @taskView.refresh(outputView,tasks)
module.exports = LeftPane
