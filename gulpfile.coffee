gulp = require 'gulp'
gTasks = require 'gulp-tasks'

cPort = Number(process.env.PORT) if process.env.PORT?
lPort = cPort+1 if cPort?

base = "#{__dirname}/dest"
bower = "#{__dirname}/bower_components"
dest =
  base: base
  templates: "#{base}/templates"
  assets: "#{base}/assets"
  themes: "#{base}/assets/themes"

src =
  scripts:
    main: "#{__dirname}/client/scripts/main.coffee"
    watch: "#{__dirname}/client/scripts/**/*.coffee"
  templates:
    index: "#{__dirname}/client/index.jade"
    files: "#{__dirname}/client/templates/**/*.jade"
  styles:
    index: "#{__dirname}/client/styles/main.less"
    files: "#{__dirname}/client/styles/**/*.less"
    themes: "#{__dirname}/client/vendor/themes/**/*.less"
  vendors: [
    "#{__dirname}/client/vendor/**/*"
  ]
  manifest: "#{__dirname}/manifest.json"

gulp.task 'build', [
  'build:scripts'
  'build:templates'
  'build:styles'
]

gulp.task 'build:scripts', [
  'build:scripts:app'
]

gulp.task 'build:scripts:app', ->
  gTasks.browserify.build src.scripts.main, dest.base
  # gTasks.misc.copy src.vendors, dest.assets

gulp.task 'build:templates', ->
  gTasks.jade.build src.templates.index, dest.base, lPort
  gTasks.jade.build src.templates.files, dest.templates

gulp.task 'build:styles', ->
  gTasks.less.build src.styles.index, dest.base
  gTasks.less.build src.styles.themes, dest.themes

gulp.task 'build:local', ['build'], ->
  gTasks.misc.copy src.manifest, dest.base

gulp.task 'server', ->
  gTasks.livereload.livereloadServer dest.base, lPort
  gTasks.livereload.contentServer dest.base, cPort

gulp.task 'start', ['build', 'server']

gulp.task 'watch', ['build', 'server'], ->
  gulp.watch src.scripts.watch, ['build:scripts:app']
  gulp.watch [src.templates.index, src.templates.files], ['build:templates']
  gulp.watch [src.styles.index, src.styles.files, src.styles.themes], ['build:styles']

gulp.task 'default', ['watch']
