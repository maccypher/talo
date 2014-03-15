// myQueryCtrl.js

'use strict';

var app = angular.module('homePage', ['localStorage']);

app.controller('mainCtrl', function($scope, $rootScope, $store) {
/* Bof: define some vars */
	$scope.isCollapsed = false;
	$scope.exportOpen = false;
	$scope.importOpen = false;
	$scope.confirmClear = false;
	var obj = {};
	obj.id = '';
	obj.cat = '';
	obj.url = '';
	obj.name = '';
/* ---- */

/* Bof: Show / Hide sidebar */
	
	$scope.toggle = function() {
		$scope.isCollapsed = !$scope.isCollapsed;
		$rootScope.$broadcast('mainCtrl.isCollapsed', $scope.isCollapsed);
		$scope.closeImport();
	};
/* ---- */

/* Bof: Theming */
	$scope.themes = [
			{ name: 'Default', value: 'default' },
			{ name: 'Fabric', value: 'fabric' },
			{ name: 'Taxi', value: 'taxi' },
			{ name: 'Tones', value: 'tones' },
			{ name: 'Pastel Sky', value: 'pastel' },
			{ name: 'Clouds', value: 'clouds' }
	];

	$scope.selectedTheme = $store.get('selection') || $scope.themes[0].value;
	$scope.cssTheme = $scope.selectedTheme;

	$scope.$on('theme.update', function(evt, val) {
		$scope.cssTheme = val;
	});

	$scope.$watch('selectedTheme', function(newVal, oldVal) {
		$store.set('selection', $scope.selectedTheme);
		$rootScope.$broadcast('theme.update', newVal);
	});
/* ---- */

/* Bof: Layout */
	$scope.$on('column.update', function(evt, val) {
		$scope.column = val;
		$scope.ceckedColumn = val;
	});

	$scope.columnDefault = 'one';
	$scope.selectedColumns = $store.get('columns') || $scope.columnDefault;
	$scope.column = $scope.selectedColumns;

	$scope.$watch('column', function(newVal, oldVal) {
		$store.set('columns', $scope.column);
		$rootScope.$broadcast('column.update', newVal);
	});
/* ---- */

/* Bof: read LocalStorage for main content */
	$scope.bookmarks = function(){

		$scope.items = [];

		for (var i = 0; i < localStorage.length; i++){
			var lsKey = localStorage.key(i);
			if(lsKey != "selection" && lsKey != "columns") {
				$scope.items.push($store.get(lsKey));
			}
		}

	};

	$scope.bookmarks();
/* ---- */

/* Bof: EditMode */

/* Bof: read LocalStorage for sidebar (edit mode) */
	$scope.editBookmarks = function(){

		$scope.editItems = [];

		/* Bof: getting keys from LS */
		for (var i = 0; i < localStorage.length; i++){
			var lsKey = localStorage.key(i);
			if(lsKey != "selection" && lsKey != "columns") {
				$scope.editItems.push($store.get(lsKey));
			}
		}
		/* ---- */

		/* Bof: Group items by 'cat' */
		var logs = $scope.editItems;
		var sorted = [];
		logs.forEach(function(log){
			if (!sorted[log['cat']]) {
				sorted[log['cat']]= [];
			} 
			sorted[log['cat']].push(log);
		});

		$scope.cats=[];
		for(var cat in sorted) {
			$scope.cats.push({name:cat,items:sorted[cat]});
		}
		$scope.bookmarks();
		/* ----- */
	};

	$scope.editBookmarks();
/* ---- */

/* Bof: add a new bookmark */
	$scope.addNew = function(){
		var now = new Date();
		obj.id = now.getTime();
		obj.cat = $scope.newCat;
		obj.url = $scope.newUrl;
		obj.name = $scope.newName;
		$store.set(obj.id, obj);

		$scope.clearForm();
		$scope.editBookmarks();
	};
/* ---- */

/* Bof: reset "add new" form */
	$scope.clearForm = function(){
		$scope.newCat = '';
		$scope.newUrl = '';
		$scope.newName = '';
		$scope.importJson = '';
		$scope.exportJson = '';
	};
/* ---- */

/* Bof: delete entry */
	$scope.delItem = function(item){
		$store.remove(item);
		$scope.editBookmarks();
		$scope.bookmarks();
	};
/* ---- */

/* Bof: save entry */
	$scope.saveItem = function(item){
		$store.set(item.id, item);
		$scope.editBookmarks();
	};
/* ---- */

/* Bof: cancel edit entry */
	$scope.cancelEdit = function(item){
		$scope.editBookmarks();
	};
/* ---- */
	$scope.exportData = function(){
		var temp = JSON.stringify(localStorage);
		$scope.exportOpen = true;
		$rootScope.$broadcast('mainCtrl.exportOpen', $scope.exportOpen);
		$scope.exportJson = temp;
	};

	$scope.download = function (fileType){
		var textToWrite = $scope.exportJson;
		var fileNameToSaveAs = "talo_bookmarks";

		if(fileType == "json") {
			var textFileAsBlob = new Blob([textToWrite], {type:'text/plain'});
		}
		
		var downloadLink = document.createElement("a");
		downloadLink.download = fileNameToSaveAs;
		downloadLink.innerHTML = "Download File";
		if (window.webkitURL != null)	{
			downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob);
		} else {
			downloadLink.href = window.URL.createObjectURL(textFileAsBlob);
			downloadLink.onclick = destroyClickedElement;
			downloadLink.style.display = "none";
			document.body.appendChild(downloadLink);
		}

		downloadLink.click();

	};

	$scope.openImport = function(){
		$scope.importOpen = true;
		$rootScope.$broadcast('mainCtrl.importOpen', $scope.importOpen);
	};

	$scope.closeImport = function(){
		$scope.importOpen = false;
		$rootScope.$broadcast('mainCtrl.importOpen', $scope.importOpen);
	};

	$scope.restoreClean = function(){
		localStorage.clear();
		var string2json = $scope.importJson;
		var data = JSON.parse(string2json);
		
		for (var key in data) {
			localStorage[key] = data[key];
		}
		$scope.editBookmarks();
		$scope.clearForm();
		$scope.closeImport();
	};

	$scope.restoreAdd = function(){
		var string2json = $scope.importJson;
		var data = JSON.parse(string2json);
		
		for (var key in data) {
			localStorage[key] = data[key];
		}
		$scope.editBookmarks();
		$scope.clearForm();
		$scope.closeImport();
	};

	$scope.confirmClearAll = function(){
		$scope.confirmClear = true;
		$rootScope.$broadcast('mainCtrl.confirmClear', $scope.confirmClear);
	};

	$scope.clearAll = function(){
		for (var i = 0; i < localStorage.length; i++){
			var lsKey = localStorage.key(i);
			if(lsKey == "selection") {
				console.log(lsKey);
			}
			if(lsKey == "columns") {
				console.log(lsKey);
			}
			if(lsKey != "selection") {
				if(lsKey != "columns") {
				//localStorage.clear();
					$store.remove(lsKey);
				}
			}
		}
		$scope.editBookmarks();
	};
});
