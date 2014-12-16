'use strict'

app = angular.module 'homePage', ['localStorage']

app.controller 'mainCtrl', ($scope, $rootScope, $store) ->

# Bof: define some vars
	$scope.isCollapsed = false
	$scope.reader = false
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

# Bof: Show / Hide Reader
	$scope.toggleReader = () ->
		$scope.reader = !$scope.reader
		$rootScope.$broadcast 'mainCtrl.reader', $scope.reader
		if $scope.reader is true
			$store.set 'view', 'readerOpen'
		else
			$store.set 'view', 'readerClosed'

# THEMING
# Bof: put theme names in an object
	$scope.themes =
		default: 'Default'
		fabric: 'Fabric'
		taxi: 'Taxi'
		tones: 'Tones'
		pastel: 'Pastel Sky'
		clouds: 'Clouds'

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
			if lsKey isnt "selection" and lsKey isnt "columns" and lsKey isnt "view" and lsKey isnt "feedUrl"
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

# Bof: Show / Hide RSS settings	
	$scope.feed = 
		default: 'http://web.de'
		# default: 'http://feeds.delicious.com/v2/rss/fdrei/mupat'

	$scope.rssSettingsToggle = () ->
		$scope.rssSettingsOpen = !$scope.rssSettingsOpen
		$rootScope.$broadcast 'mainCtrl.rssSettingsOpen', $scope.rssSettingsOpen
		$scope.feedUrl = $store.get('feedUrl') or $scope.feed.default

	$scope.setFeedUrl = () ->
		$store.set 'feedUrl', $scope.newFeedUrl
		$rootScope.$broadcast 'feedUrl.update', $scope.newFeedUrl
		$scope.newFeedUrl = ''

	$scope.$on 'feedUrl.update', (evt, val) ->
		$scope.feedUrl = val





