'use strict'

app = angular.module 'homePage', ['localStorage']

app.controller 'mainCtrl', ($scope, $rootScope, $store, $http, $timeout) ->

# Bof: define some vars
	$scope.reload = false
	$scope.isCollapsed = false
	$scope.exportOpen = false
	$scope.importOpen = false
	$scope.confirmClear = false
	obj = 
		id: ''
		cat: ''
		url: ''
		name: ''

# Bof: Show / Hide sidebar	
	$scope.toggle = () ->
		if not $scope.exportOpen and not $scope.importOpen and not $scope.confirmClear
			$scope.isCollapsed = !$scope.isCollapsed
			$rootScope.$broadcast 'mainCtrl.isCollapsed', $scope.isCollapsed

# THEMING
# Bof: put theme names in an object
	$scope.themes =
		default: 'Default'
		fabric: 'Fabric'
		taxi: 'Taxi'
		tones: 'Tones'
		pastel: 'Pastel Sky'
		clouds: 'Clouds'
		bb_corp_1: 'BB Corporate 1'
		bb_corp_2: 'BB Corporate 2'
		grass: 'Soccer Grass'
		retro: 'Retro Feeling'

	$scope.selectedTheme = $store.get('selection') or $scope.themes.default
	$scope.cssTheme = $scope.selectedTheme

	$scope.$on 'theme.update', (evt, val) ->
		$scope.cssTheme = val

	$scope.$watch 'selectedTheme', (newVal, oldVal) ->
		$store.set 'selection', $scope.selectedTheme
		$rootScope.$broadcast 'theme.update', newVal

# Bof: check / prepare column settings
	$scope.$on 'column.update', (evt, val) ->
		$scope.column = val
		$scope.ceckedColumn = val

	$scope.columnDefault = 'one'
	$scope.selectedColumns = $store.get('columns') or $scope.columnDefault
	$scope.column = $scope.selectedColumns

	$scope.$watch 'column', (newVal, oldVal) ->
		$store.set 'columns', $scope.column
		$rootScope.$broadcast 'column.update', newVal

# Bof: update theme if new is selected
	$scope.themeUpdate = () ->
		$scope.selectedTheme = $store.get('selection') or $scope.themes.default
		$scope.column = $store.get('columns') or $scope.columnDefault

# EDIT MODE / SETTINGS SECTION STARTS HERE
# Bof: read LocalStorage for sidebar (edit mode)
	$scope.editBookmarks = () ->
		$scope.cats = []
		cats = {}

		# Bof: getting keys from LS
		for lsKey, value of localStorage
			unless lsKey in ["selection", "columns", "view", "feedUrl", "latestFeed"]
				try
					value = JSON.parse value
				catch e
					console.log 'error by parsing one entry', e, key, value
				
				cats[value.cat] = [] unless cats[value.cat]?
				cats[value.cat].push value

		$scope.cats.push {name: catName, items: catItems} for catName, catItems of cats

	$scope.editBookmarks()

# Bof: add a new bookmark
	$scope.addNew = () ->
		now = new Date()
		obj = 
			id: now.getTime()
			cat: $scope.newCat
			url: $scope.newUrl
			name: $scope.newName
		
		$store.set obj.id, obj

		$scope.clearForm()
		$scope.editBookmarks()

# Bof: reset "add new" form
	$scope.clearForm = () ->
		$scope.newCat = ''
		$scope.newUrl = ''
		$scope.newName = ''
		$scope.importJson = ''
		$scope.exportJson = ''

# Bof: delete entry
	$scope.delItem = (item) ->
		$store.remove item
		$scope.editBookmarks()
		$scope.bookmarks()

# Bof: save entry
	$scope.saveItem = (item) ->
		$store.set item.id, item
		$scope.editBookmarks()

# Bof: cancel edit entry 
	$scope.cancelEdit = (item) ->
		$scope.editBookmarks()

# Bof: open export dialog
	$scope.exportData = () ->
		temp = JSON.stringify(localStorage)
		$scope.exportOpen = true
		$rootScope.$broadcast 'mainCtrl.exportOpen', $scope.exportOpen
		$scope.exportJson = temp

# Bof: close the export dialog
	$scope.closeExport = () ->
		$scope.exportOpen = false
		$rootScope.$broadcast 'mainCtrl.exportOpen', $scope.exportOpen

# Bof: download the exported txt file
	$scope.download = () ->
		textToWrite = $scope.exportJson
		fileNameToSaveAs = "talo_bookmarks"
		textFileAsBlob = new Blob([textToWrite], {type:'text/plain'})
		downloadLink = document.createElement "a"

		downloadLink.download = fileNameToSaveAs
		downloadLink.innerHTML = "Download File"

		if window.webkitURL isnt null
			downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob)
		else
			downloadLink.href = window.URL.createObjectURL(textFileAsBlob)
			downloadLink.onclick = destroyClickedElement
			downloadLink.style.display = "none"
			document.body.appendChild downloadLink

		downloadLink.click()

# Bof: open import dialog
	$scope.openImport = () ->
		$scope.importOpen = true
		$rootScope.$broadcast 'mainCtrl.importOpen', $scope.importOpen

# Bof: close the import dialog
	$scope.closeImport = () ->
		$scope.importOpen = false
		$rootScope.$broadcast 'mainCtrl.importOpen', $scope.importOpen

# Bof: clean localstorage before adding new content
	$scope.restoreClean = () ->
		localStorage.clear()
		$scope.restoreAdd()		

# Bof: add new content
	$scope.restoreAdd = () ->
		string2json = $scope.importJson
		data = JSON.parse(string2json)
		
		for key, value of data
			localStorage[key] = value

		$scope.editBookmarks()
		$scope.clearForm()
		$scope.closeImport()
		$scope.themeUpdate()

# Bof: confirmation dialog to reset all
	$scope.confirmClearAll = () ->
		$scope.confirmClear = true
		$rootScope.$broadcast 'mainCtrl.confirmClear', $scope.confirmClear

# Bof: close confirmation dialog
	$scope.closeConfirmClearAll = () ->
		$scope.confirmClear = false
		$rootScope.$broadcast 'mainCtrl.confirmClear', $scope.confirmClear

# Bof: DO the reset all
	$scope.clearAll = () ->
		tempSelection = $store.get 'selection'
		tempColumns = $store.get 'columns'
		tempView = $store.get 'view'
		
		localStorage.clear()

		$scope.editBookmarks()
		$scope.themeUpdate()

# -------------------- #
# ---- RSS Reader ---- #
# -------------------- #

# Bof: Show / Hide RSS reader
	window.SelectAll = (id) ->
		document.getElementById(id).focus()
		document.getElementById(id).select()
	# Bof: Show / Hide Reader
	
	$scope.$on 'view.update', (evt, val) ->
		$scope.view = val

	$scope.viewDefault = false
	$scope.useReader = $store.get('view') or $scope.viewDefault

	$scope.$watch 'useReader', (newVal, oldVal) ->
		$store.set 'view', $scope.useReader
		$scope.view = newVal
		$rootScope.$broadcast 'view.update', newVal

	$scope.getView = () ->
		$scope.view = $store.get('view') or $scope.viewDefault
		$rootScope.$broadcast 'view.update', $scope.view

	$scope.getView()



# Bof: Show / Hide RSS settings

	$scope.rssSettingsToggle = () ->
		$scope.rssSettingsOpen = !$scope.rssSettingsOpen
		$rootScope.$broadcast 'mainCtrl.rssSettingsOpen', $scope.rssSettingsOpen
		$scope.feedUrl = $store.get('feedUrl')

	$scope.setFeedUrl = () ->
		$store.set 'feedUrl', $scope.newFeedUrl
		$scope.feedUrl = $scope.newFeedUrl
		$scope.newFeedUrl = ''
		$scope.fetchFeed();

# Bof: fetching the feed Json
# URL has to be something like: 'http://feeds.delicious.com/v2/json/fdrei?callback=JSON_CALLBACK'

	$scope.$on 'refresh.update', (evt, val) ->
		console.log "evt: ", evt
		console.log "val: ", val
		$scope.refresh = val
		console.log "$scope.refresh: ", $scope.refresh

	$scope.fetchIndicator = () ->
		$scope.refresh = true
		$rootScope.$broadcast 'refresh.update', $scope.refresh
		$timeout(stopFetchIndicator, 2500);

	stopFetchIndicator = () ->
		$scope.refresh = false
		$rootScope.$broadcast 'refresh.update', $scope.refresh

	$scope.fetchFeed = () ->
		$scope.offline = true
		feedUrl = $store.get 'feedUrl'
		return unless feedUrl?
		
		#  Use "jsonp" as long as you are on develop and you are running a local server
		# request = $http.jsonp feedUrl

		#  Use "get" if you are on file base or you are running it as a Chrome Extension
		request = $http.get feedUrl

		request.success (data, status) ->
			$scope.offline = false
			$scope.feedItems = data
			$scope.feedStatus = status
			latestStoredItem = $store.get 'latestFeed'
			latestItem = new window.Date(data[0].dt).getTime()

			if not latestStoredItem? or latestStoredItem < latestItem
				$store.set 'latestFeed', latestItem

				for item in $scope.feedItems
					tempTime = new window.Date(item.dt).getTime()
					item.new = true if tempTime > latestStoredItem

		request.error (data, status) ->
			$scope.feedStatus = status
			console.log 'Error: ', status

	$scope.fetchFeed();





