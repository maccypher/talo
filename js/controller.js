// myQueryCtrl.js

'use strict';

var app = angular.module('homePage', ['localStorage']);

app.controller('mainCtrl', function($scope, $rootScope, $store) {
/* Bof: define some vars */
	var obj = {};
	obj.id = '';
	obj.cat = '';
	obj.url = '';
	obj.name = '';
/* ---- */

/* Bof: Show / Hide sidebar */
	$scope.isCollapsed = false;
	
	$scope.toggle = function() {
		$scope.isCollapsed = !$scope.isCollapsed;
		$rootScope.$broadcast('mainCtrl.isCollapsed', $scope.isCollapsed);
	};
/* ---- */

/* Bof: Theming */
	$scope.themes = [
			{ name: 'Default', value: 'default' },
			{ name: 'Fabric', value: 'fabric' },
			{ name: 'Taxi', value: 'taxi' },
			{ name: 'Tones', value: 'tones' },
			{ name: 'Pastel Sky', value: 'pastel' },
			{ name: 'Clouds', value: 'clouds' },
			{ name: 'Corporate', value: 'bb-corporate' },
			{ name: 'Retro', value: 'bb-retro' },
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
	};
/* ---- */

/* Bof: delete entry */
	$scope.delItem = function(item) {
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
/* ---- */

});