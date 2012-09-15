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
  , FacebookStrategy = require('passport-facebook').Strategy;

passport.use(new FacebookStrategy({
    clientID: '399424960124363',
    clientSecret: '7f24e462f20a47878a4b4e10f4609d4b',
    callbackURL: "http://www.example.com/auth/facebook/callback"
  },
  function(accessToken, refreshToken, profile, done) {
    User.findOrCreate(function (err, user) {
      if (err) { return done(err); }
      done(null, user);
    });
  }
));`

app = new marrow
app.server.configure 'production', ->
  app.server.use express.compress()
app.server.use express.favicon()
app.server.use stylus.middleware
  src: "#{__dirname}/assets"
  compile: compile
app.server.use express.static "#{__dirname}/assets"
app.load __dirname
app.layout = (req, res, next, cb) -> cb null, layout

`// Redirect the user to Facebook for authentication.  When complete,
// Facebook will redirect the user back to the application at
// /auth/facebook/callback
app.server.get('/auth/facebook', passport.authenticate('facebook'));

// Facebook will redirect the user to this URL after approval.  Finish the
// authentication process by attempting to obtain an access token.  If
// access was granted, the user will be logged in.  Otherwise,
// authentication has failed.
app.server.get('/auth/facebook/callback', 
  passport.authenticate('facebook', { successRedirect: '/',
                                      failureRedirect: '/login' }));
`

app.listen 3000, ->
  console.log 'server started'