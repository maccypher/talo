window.onload = ->

	activate = ->
		document.getElementById("saveAs").removeAttribute('disabled')
		document.getElementById("resetAll").removeAttribute('disabled')

	document.getElementById("docTitle").addEventListener 'change', activate

	generate = ->
		data = CKEDITOR.instances.editor1.getData()
		docTitle = document.getElementById("docTitle").value

		if docTitle isnt ''
			fileName = docTitle + ".htm"
		else
			fileName = "default.htm"

		dataString = data
		re1 = /</gi
		re2 = />/gi
		dataString = dataString.replace re1, "\n    <"
		dataString = dataString.replace re2, ">\n        "

		htmlString = window.headerText + dataString + window.footerText

		document.getElementById("output").value = htmlString
		document.getElementById("output").classList.add('active')
		document.getElementById("resetAll").removeAttribute('disabled')
		blob = new Blob([htmlString], {type: "text/html;charset=utf-8"})

		saveAs(blob, fileName)

	document.getElementById("saveAs").addEventListener 'click', generate

	reset = ->
		CKEDITOR.instances.editor1.setData()
		document.getElementById("docTitle").value = ''
		document.getElementById("output").value = ''
		document.getElementById("output").classList.remove('active')
		document.getElementById("saveAs").setAttribute('disabled', 'disabled')
		document.getElementById("resetAll").setAttribute('disabled', 'disabled')

	document.getElementById("resetAll").addEventListener 'click', reset
