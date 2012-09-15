marrow = require 'marrow'
stylus = require 'stylus'
nib = require 'nib'
express = require 'express'
jade = require 'jade'

server = express()

await jade.renderFile "#{__dirname}/pages/layout.jade", defer err, layout

compile = (str, path) ->
	stylus(str)
	.set('filename', path)
	.set('compress', true)
	.use(nib())

`var passport = require('passport')
  , GoogleStrategy = require('passport-google').Strategy;

passport.use(new GoogleStrategy({
    returnURL: 'http://8.19.32.62:5000/auth/google/return',
    realm: 'http://8.19.32.62:5000/'
  },
  function(identifier, profile, done) {
    //User.findOrCreate({ openId: identifier }, function (err, user) {
    //  done(err, user);
    //});
		done(null, {});
  }
));`

passport.serializeUser (user, done) ->
	done null, user.id

passport.deserializeUser (id, done) ->
	done null, {}

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