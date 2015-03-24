'use strict';

console.log(localStorage);

// get used elements
var $error = document.getElementById('error');
var $success = document.getElementById('success');
var $bookmark = document.getElementById('addBookmark');
var $url = document.getElementById('url');
var $categorie = document.getElementById('categorie');
var $name = document.getElementById('name');
var $cancel = document.getElementById('cancel');

function exit() {
  window.close();
}

// set active tab url as the url to save
chrome.tabs.query({active: true},function(tab) {
  $url.value = tab[0].url;
});

$bookmark.addEventListener('submit', function(event) {
  event.preventDefault();
  var obj = "";
  var id = new Date().getTime();
  $error.classList.add('hidden');

  if($categorie.value.length === 0 || $name.value.length === 0) {
    $error.classList.remove('hidden');
    return
  }

  try {
    obj = JSON.stringify({
      id: id,
      cat: $categorie.value,
      url: $url.value,
      name: $name.value
    });

    localStorage.setItem(id, obj);
  } catch (err) {
    $error.classList.remove('hidden');
    return
  }

  $success.classList.remove('hidden');
  setTimeout(exit, 1000);
});

$cancel.addEventListener('click', function(event) {
  event.preventDefault();
  exit();
});
