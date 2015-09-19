shell = require 'shelljs'

module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON('package.json')

        coffee:
            lib:
                src: ['src/*.coffee']
                dest: 'lib/'
            dev:
                src: ['dev/*.coffee']
                dest: 'dev'

        node_info:
            files: 'dev/info.js'

        watch:
            server:
                files: 'dev/server.*'
                tasks: ['coffee:dev', 'server']
                options:
                    spawn: false
                    interrupt: true
            dev:
                files: 'dev/info.coffee'
                tasks: ['coffee:dev', 'info']
                options:
                    spawn: false
                    interrupt: true

    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-coffee')

    # Tasks
    grunt.registerTask 'default', ['compile']
    grunt.registerTask 'compile', ['coffee:lib']

    grunt.registerTask 'run:server', ['server', 'watch:server']
    grunt.registerTask 'server', ->
        shell.exec 'node -i dev/server'

    grunt.registerTask 'info', ->
        shell.exec 'node -i dev/info'


