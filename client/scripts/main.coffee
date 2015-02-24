'use strict'

app = angular.module 'homePage', ['localStorage']

app.controller 'mainCtrl', ($scope, $rootScope, $store, $http, $timeout) ->

# Bof: define some vars
	$scope.reload = false
	$scope.isCollapsed = false
	$scope.subOpened = false
	$scope.closeSubMenu = false
	$scope.searchActive = false
	$scope.addBookmarkOpen = false
	$scope.editBookmarkOpen = false
	$scope.editing = false
	$scope.verify = false
	$scope.exportOpen = false
	$scope.importOpen = false
	$scope.confirmClear = false
	$scope.subMenu = 
		bookmarks:
			open: false
			name: 'Edit Bookmarks'
		backup: 
			open: false
			name: "Backup / Restore"
		appearance: 
			open: false
			name: 'Appearance'
		view: 
			open: false
			name: 'View'
		rss: 
			open: false
			name: 'RSS Settings'

	obj = 
		id: ''
		cat: ''
		url: ''
		name: ''

# Bof: Show / Hide sidebar	
	$scope.toggle = () ->
		$scope.isCollapsed = !$scope.isCollapsed
		if $scope.subOpened is true
			# $scope.closeSubMenu()
			console.log "-"
		if $scope.addBookmarkOpen is true
			$scope.addBookmarkOpen = false
		if $scope.importOpen is true
			$scope.closeImport()
		if $scope.exportOpen is true
			$scope.closeExport();

	$scope.sToggle = (event) ->
		qInput = event.target.nextSibling
		qInput.focus() if qInput?
		$scope.searchActive = !$scope.searchActive

	$scope.sClose = (event) ->
		qInput = event.target.nextSibling
		qInput.focus() if qInput?
		$scope.searchActive = false

	$scope.addBookmarkToggle = () ->
		$scope.addBookmarkOpen = !$scope.addBookmarkOpen

	$scope.openSubMenu = (sub) ->
		# close Add Bookmark form if open
		$scope.addBookmarkOpen = false

		# tell everybody that a submenu is open
		$scope.subOpened = true

		# open the specific submenu
		$scope.subMenu[sub].open = true
		$scope.openSub = sub

	$scope.closeSubMenu = (sub) ->
		$scope.subMenu[sub].open = false
		$scope.subOpened = false
		$scope.addBookmarkOpen = false
		$scope.closeImport()
		$scope.closeExport()
		
# THEMING
# Bof: put theme names in an object
	$scope.themes =
		default: ''
		m_bgorange: ''
		m_teal: ''
		m_blue:''
		m_lblue:''
		m_green:''
		m_grey:''
		m_gorange:''
		m_acyan:''

	$scope.selectedNewTheme = (nt) ->
		$store.set 'selection', nt

	$scope.selectedTheme = $store.get('selection') or $scope.themes.default
	$scope.cssTheme = $scope.selectedTheme

	$scope.$on 'theme.update', (evt, val) ->
		$scope.selectedTheme = val
		$scope.checkedTheme = val
		$scope.cssTheme = val

	$scope.$watch 'selectedTheme', (newVal, oldVal) ->
		$store.set 'selection', $scope.selectedTheme
		$rootScope.$broadcast 'theme.update', newVal

# Bof: check / prepare column settings
	$scope.$on 'column.update', (evt, val) ->
		$scope.column = val
		$scope.checkedColumn = val

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
		$scope.addBookmarkToggle()

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
		$scope.exportJson = temp

# Bof: close the export dialog
	$scope.closeExport = () ->
		$scope.exportOpen = false

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

# Bof: close the import dialog
	$scope.closeImport = () ->
		$scope.importOpen = false

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

# Bof: close confirmation dialog
	$scope.closeConfirmClearAll = () ->
		$scope.confirmClear = false

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

	$scope.rssToggle = () ->
		$scope.showRss = !$scope.showRss

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

	$scope.getView = () ->
		$scope.view = $store.get('view') or $scope.viewDefault

	$scope.getView()

# Bof: Show / Hide RSS settings

	$scope.rssSettingsToggle = () ->
		$scope.rssSettingsOpen = !$scope.rssSettingsOpen
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
		$timeout(stopFetchIndicator, 2500);

	stopFetchIndicator = () ->
		$scope.refresh = false

	$scope.fetchFeed = () ->
		$scope.offline = true
		$scope.feedUrl = $store.get 'feedUrl'
		return unless $scope.feedUrl?
		
		# Use "jsonp" as long as you are on develop and you are running a local server
		# Additonally you MUST specify a callback parameter at the end of the URL
		# request = $http.jsonp $scope.feedUrl
		
		# Use "get" if you are on file base or you are running it as a Chrome Extension
		request = $http.get $scope.feedUrl

		request.success (data, status) ->
			$scope.rssNotify = false
			$scope.offline = false
			$scope.feedItems = data
			$scope.feedStatus = status
			latestStoredItem = $store.get 'latestFeed'
			latestItem = new window.Date(data[0].dt).getTime()
			firstNewEntry = true
			firstOldEntry = true

			if not latestStoredItem? or latestStoredItem < latestItem
				$store.set 'latestFeed', latestItem


				for item in $scope.feedItems
					tempTime = new window.Date(item.dt).getTime()
					item.new = true if tempTime > latestStoredItem
					item.firstNew = true if firstNewEntry and item.new
					firstNewEntry = false if item.firstNew
					$scope.rssNotify = true if item.firstNew

					item.old = true if tempTime < latestStoredItem
					item.firstOld = true if firstOldEntry and item.old
					firstOldEntry = false if item.firstOld

		request.error (data, status) ->
			$scope.feedStatus = status
			console.log 'Error: ', status

	$scope.fetchFeed();
