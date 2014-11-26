This is an experiment; a spike.

written quickly in a day, this app explores the question "Do
we really need to write a custom mobile app for this?".  If it gets
picked up as a useful service, it needs a suite of tests,
and some better factoring of the main app file.

in order to run, the following environment variables are important

TWILIO_AUTH_TOKEN=(your account auth token)
TWILIO_SID=(your account SID)
TWILIO_NUMBER=(your account phone number)
URLHOST=(the base host for links in the SMS messages)

to experiment:

"bundle install" to get dependencies
"bundle execute rackup" in order to run the app
(you'll need a postgres installation, with a database named "jointcomm_dev")
