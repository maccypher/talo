/* Bof: add trigger for omnibox search */
  //on every new key stroke in the omnibox, search all bookmarks 
  //and suggest this entries, where the name or the url matchs the search string
  chrome.omnibox.onInputChanged.addListener(function(text, suggest) {
    var suggestions = [];
    var addEntry = function(item) {
      var obj = {
        content: item.url,
        description: item.name
      }
      suggestions.push(obj);
    }

    for (var i = 0; i < localStorage.length; i++) {
      var lsKey = localStorage.key(i); //get key from localstorage
      //continue if the key isnt a item key
      if(lsKey === "selection" || lsKey === "columns") continue;

      //try to parse localstorage item to json obj
      try {
        item = JSON.parse(localStorage[lsKey]);
      } catch (e) { //continue if it not works
        continue;
      }

      //check if input matches either name or url
      if(item.name.indexOf(text.toLowerCase()) > -1) {
        addEntry(item);
      }else if(item.url.indexOf(text.toLowerCase()) > -1) {
        addEntry(item)
      }
    };

    //give items as suggestions back to chrome
    suggest(suggestions);
  });

  //add listener to input entered event and open the given url in the current window
  chrome.omnibox.onInputEntered.addListener(function(text) {
    window.open(text);
  });
/* ---- */