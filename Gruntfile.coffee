shell = require 'shelljs'

module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON('package.json')

        coffee:
            lib:
                src: ['src/*.coffee']
                dest: 'lib/'
            dev:
                src: ['dev/info.coffee']
                dest: 'dev/info.js'

        node_info:
            files: 'dev/info.js'

        watch:
            dev:
                files: 'dev/info.coffee'
                tasks: ['coffee:dev', 'info']
                options:
                    spawn: false
                    interrupt: true

    grunt.loadNpmTasks('grunt-typescript')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-coffee')

    # Tasks
    grunt.registerTask 'compile', ['coffee:lib']
    grunt.registerTask 'default', ['compile']

    grunt.registerTask 'info', ->
        shell.exec 'node dev/info'


