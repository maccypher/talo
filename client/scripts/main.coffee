window.onload = ->

	generate = ->
		data = CKEDITOR.instances.editor1.getData()
		docTitle = document.getElementById("docTitle").value + ".htm"

		dataString = data
		re1 = /</gi
		re2 = />/gi
		dataString = dataString.replace re1, "\n    <"
		dataString = dataString.replace re2, ">\n        "

		htmlString = window.headerText + dataString + window.footerText

		document.getElementById("output").value = htmlString
		document.getElementById("output").classList.add('active')
		blob = new Blob([htmlString], {type: "text/html;charset=utf-8"})

		# saveAs(blob, docTitle)

	document.getElementById("saveAs").addEventListener 'click', generate