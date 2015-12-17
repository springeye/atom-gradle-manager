{CompositeDisposable} = require 'atom'
{BasicTabButton} = require 'atom-bottom-dock'

GradlePane = require './views/gradle-pane'
FileFinderUtil = require './file-finder-util'
module.exports =
  config:
      gradle_home:
          type:'string'
          title:'Gradle Home (Default Use Environment)'
          default:''
          description: "Gradle Home Dir"
  activate: (state) ->
    @fileFinderUtil = new FileFinderUtil()
    @win= process.platform.indexOf 'win'
    @subscriptions = new CompositeDisposable()
    packageFound = atom.packages.getAvailablePackageNames()
    .indexOf('bottom-dock') != -1

    unless packageFound
      atom.notifications.addError 'Could not find Bottom-Dock',
        detail: 'Gradle-Manager: The bottom-dock package is a dependency. \n
        Learn more about bottom-dock here: https://atom.io/packages/bottom-dock'
        dismissable: true

    @subscriptions.add atom.commands.add 'atom-workspace',
      'gradle-manager:add': => @add()
  deleteCallback:(id)=>
    #console.log 'test:'+@newPane+id


  toggleCallback:=>
    #console.log 'click toggle'


  consumeBottomDock: (@bottomDock) ->
    @bottomDock.onDidDeletePane @deleteCallback
    @bottomDock.onDidToggle @toggleCallback
    commands = @fileFinderUtil.findFiles unless @win then /^gradlew\.bat$/i else /^gradlew$/i
    gradleFiles=@fileFinderUtil.findFiles /^build.gradle$/i
    if commands.length>0 || gradleFiles.length>0
      @add()


  add: ->
    if @bottomDock
      @newPane = new GradlePane()
      @bottomDock.addPane @newPane, 'Gradle'
      console.log 'isActive:'+@bottomDock.isActive()#Still output true without showing bottom-dock
      unless @bottomDock.isActive()
        @bottomDock.toggle()

  deactivate: ->
    @subscriptions.dispose()
    @bottomDock.deletePane @newPane.getId()
