window.onload = ->

	generate = ->
		data = CKEDITOR.instances.editor1.getData()
		docTitle = document.getElementById("docTitle").value + ".htm"

		htmlString = window.headerText + data + window.footerText
		document.getElementById("output").innerText = htmlString
		blob = new Blob([htmlString], {type: "text/html;charset=utf-8"})

		saveAs(blob, docTitle)

	document.getElementById("saveAs").addEventListener 'click', generate