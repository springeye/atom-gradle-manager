{CompositeDisposable} = require 'atom'
{BasicTabButton} = require 'atom-bottom-dock'

GradlePane = require './views/gradle-pane'

module.exports =
  config:
      gradle_home:
          type:'string'
          title:'Gradle Home (Default Use Environment)'
          default:''
          description: "Gradle Home Dir"
  activate: (state) ->
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

    console.log 'test:'+@newPane

  consumeBottomDock: (@bottomDock) ->
    @bottomDock.onDidDeletePane @deleteCallback
    @add()


  add: ->
    if @bottomDock
      console.log @bottomDock.isActive()#Still output true without showing bottom-dock
      @newPane = new GradlePane()
      @bottomDock.addPane @newPane, 'Gradle'

  deactivate: ->
    @subscriptions.dispose()
    @bottomDock.deletePane @newPane.getId()
