{BufferedProcess} = require 'atom'
FileFinderUtil = require './file-finder-util'
util = require 'util'

class GradleRunner
  constructor: () ->
    @fileFinderUtil = new FileFinderUtil()

  getGradleTasks: (onOutput, onError, onExit, args) ->
    @runGradle 'tasks',onOutput, onError, onExit, args


  runGradle: (task, onOutput, stderr, exit, extraArgs) ->
    cwd=atom.project.getPaths()[0]

    @process?.kill()
    @process = null

    ##get run command
    command = ''
    commands = @fileFinderUtil.findFiles if process.platform.indexOf 'win' == 0 then /^gradlew\.bat$/i else /^gradlew$/i
    if commands.length > 0
      command = commands[0]
    if command is ''
      command = 'gradle'


    args=[]
    ##add options and args
    for arg in task.split ' '
      args.push(arg)

    if extraArgs
      for arg in extraArgs.split ' '
        args.push arg
    onOutput util.format('Path: "%s"', cwd),'text-info'
    if extraArgs
      onOutput util.format('Execute: "%s %s %s"', command,task,extraArgs),'text-info'
    else
      onOutput util.format('Execute: "%s %s"', command,task),'text-info'
    @process = new BufferedProcess
      command: command
      args: args
      options:
        env: process.env,
        cwd:cwd
      stdout: onOutput
      stderr: stderr
      exit: exit

  destroy: ->
    @process?.kill()
    @process = null

module.exports = GradleRunner
