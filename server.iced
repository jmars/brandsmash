marrow = require 'marrow'
stylus = require 'stylus'
nib = require 'nib'
express = require 'express'
jade = require 'jade'
fs = require 'fs'
Future = require 'future'

server = express()

await jade.renderFile "#{__dirname}/pages/layout.jade", defer err, layout

compile = (str, path) ->
	stylus(str)
	.set('filename', path)
	.set('compress', true)
	.use(nib())

`function pickRandomProperty(obj) {
    var result;
    var count = 0;
    for (var prop in obj)
        if (Math.random() < 1/++count)
           result = prop;
    return result;
}`

industries = {}
for industry in fs.readdirSync "#{__dirname}/assets/logos"
	industries[industry] = fs.readdirSync("#{__dirname}/assets/logos/#{industry}")

users = {}

findorCreate = (identifier, profile, done) ->
	if !users[identifier]?
		users[identifier] =
			id: identifier
	done null, users[identifier]

`var passport = require('passport')
  , GoogleStrategy = require('passport-google').Strategy;

passport.use(new GoogleStrategy({
    returnURL: 'http://8.19.32.62:5000/auth/google/return',
    realm: 'http://8.19.32.62:5000/'
  },
  findorCreate
));`

passport.serializeUser (user, done) ->
	users[user.id] = user
	done null, user.id

passport.deserializeUser (id, done) ->
	done null, users[id]

app = new marrow
app.server.configure 'production', ->
  app.server.use express.compress()
app.server.use express.favicon()
app.server.use stylus.middleware
  src: "#{__dirname}/assets"
  compile: compile
app.server.use express.static "#{__dirname}/assets"
app.server.use passport.initialize()
app.server.use passport.session()
app.load __dirname
app.layout = (req, res, next, cb) -> cb null, layout

app.RPC =
	industry: ->
		future = Future()
		industry = pickRandomProperty(industries)
		future.resolve industry

	index: ->
		future = Future()
		index = [Math.floor(industries[industry].length * Math.random())]
		future.resolve index

`// Redirect the user to Google for authentication.  When complete, Google
// will redirect the user back to the application at
// /auth/google/return
app.server.get('/auth/google', passport.authenticate('google'));

// Google will redirect the user to this URL after authentication.  Finish
// the process by verifying the assertion.  If valid, the user will be
// logged in.  Otherwise, authentication has failed.
app.server.get('/auth/google/return', 
  passport.authenticate('google', { successRedirect: '/',
                                    failureRedirect: '/login' }));`

app.listen 5000, ->
  console.log 'server started'