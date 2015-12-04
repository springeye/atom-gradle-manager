{View, $,$$} = require 'space-pen'
class LeftTaskView extends View

  @content:->
    @div outlet:'body',class:'task-container',=>
      @ul outlet:'taskList'
  refresh:(outputView,tasks)->
    for task in tasks.sort()
      listItem = $("<li><div class='icon icon-zap'>#{task}</div></li>")

      do (task) => listItem.first().on 'click', =>
        outputView.runTask task
      @taskList.append listItem
  clear: ->
    @taskList.empty()
module.exports = LeftTaskView
