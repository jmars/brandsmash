jade = require 'jade'
dust = require 'dustjs-linkedin'
wrench = require 'wrench'
fs = require 'fs'
path = require 'path'

compile = (dir, dest) ->
	templates = wrench.readdirSyncRecursive dir
	for template in templates then if template.indexOf('.jade') isnt -1
		data = fs.readFileSync path.join(dir, template), 'utf8'
		func = jade.compile data, filename: path.join dir, template
		template = template.replace '.jade', ''
		source = dust.compile func(), template.replace('.jade', '')
		source = "define(['lib/dust'],function(dust){#{source}})"
		wrench.mkdirSyncRecursive path.dirname(path.join(dest, template)), 0o777
		fs.writeFileSync path.join(dest, template+'.js'), source, 'utf8'

compile "#{__dirname}/templates", "#{__dirname}/views"

console.log 'built views'