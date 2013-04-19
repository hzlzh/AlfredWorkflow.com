[Alfred 2][alfred] Workflow for showing weather forecasts
=========================================================

<p align="center">
<img alt="Screenshot" src="http://i.imgur.com/c76YyE5.png" />
</p>

<p align="center">
  <a href="https://dl.dropbox.com/s/hug7tz83dk5wsa5/jc-weather.alfredworkflow"><img src="http://i.imgur.com/E8I5TfU.png" alt="Download"></a>
</p>

This workflow lets you access weather forecasts from [forecast.io][fio] and the
[Weather Underground][wund].  There are several setup commands, accessible as
`wset <command>`, and a single `weather` command to display current conditions
and a forecast.

The setup commands are:

  * `days` - set the number of forecast days to show
  * `getkey` - open the API key signup page for your current service
  * `icons` - choose an icon set
  * `location <ZIP or city>` - set your default location
  * `service` - set your preferred weather service, forecast.io or Weather
    Underground
  * `units` - set your preferred unit system

The `weather` command, with no argument, will show information for your default
location. It can also be given a location, such as a ZIP code or city name. It
(and the `wset location` command) uses the Weather Underground autocomplete API
to find possible locations based on what you enter.

The first time you try to access the weather, you'll be asked to set your
preferred service, currently either Weather Underground or Forecast.io. You'll
also be asked to set an API key for your chosen service. If you don't already
have a key you can use `wset getkey` to open the API signup page for the
weather service.  API keys from both Weather Underground and forecast.io are
free.

Once you've set the service and API key, you'll also need to set a default
location. This is done with the `wset location` command.

The data for each city you query is cached for 5 minutes to keep requests down
to a reasonable level while you're playing around with the workflow. The free
tier of Weather Underground API access is throttled to 10 requests per minute,
and it's surprisingly easy to hit that limit (you know, when you're spastically
querying city after city because using an Alfred workflow is just so cool).

Installation
------------

The easiest way to install the workflow is to download the
[prepackaged workflow][package].  Double-click on the downloaded file, or drag
it into the Alfred Workflows window, and Alfred should install it.

I'm using `weather` as the main command, which is the same as the built-in
weather web search in Alfred. The web search can be disabled in Features &rarr;
Web Search if you don't want it showing up in your weather report.
Alternatively, you can change the `weather` command to something else.

Requirements
------------

The only requirements are:

  * Python 2.7+
  * `requests`

If you have Lion or Mountain Lion, the [prepackaged workflow][package] includes
everything you need.

Credits
-------

This script was originally based on David Ferguson's Weather workflow. My code
base has diverged pretty far at this point, though, both in the source and in
how it works.

The package includes a number of icon sets from the Weather Underground and
from [weathericonsets.com][icons] (I'm not up to drawing weather icons yet).
Each set includes an `info.json` file that gives a short description and
provides a source URL for the icon set.

[api]: http://www.wunderground.com/weather/api/
[package]: https://dl.dropbox.com/s/hug7tz83dk5wsa5/jc-weather.alfredworkflow
[alfred]: http://www.alfredapp.com
[icons]: http://www.weathericonsets.com
[wund]: http://www.weatherunderground.com
[fio]: http://forecast.io
