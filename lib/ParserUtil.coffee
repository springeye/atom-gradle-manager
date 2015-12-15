class ParserFactory
  filter:(index, size, task) ->
    if index >= (size - 8) or index <= 20
      true
    else if @isEmpty task
      true
    else if @isEmpty task.replace(/\-/g, '')
      true
    else if task.trim() is 'Other tasks'
      true
    else if task.trim() is 'BUILD SUCCESSFUL'
      true
    else
      false

  constructor:->
    @text=''
  write:(out)->
    @text+=out
  parser:->
    @tasks = (task for task in @text.split '\n' )

    @handleTask = (task for task,i in @tasks when !@filter(i, @tasks.length, task))

    @tasks = []
    @tasks.push task for task in @handleTask
    @handleTask = []


    for t,i in @tasks
      arr = ('' + t).split ' - '
      @handleTask.push(arr[0])


    @tasks = []
    @tasks.push task for task in @handleTask
    return @tasks
  close:->
    @text=''
  isEmpty:(s)->
    !s?.trim()

module.exports = ParserFactory
