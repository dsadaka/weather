# Weather

Given an address, show local forecast and High/Low temperatures for the current day and the next two.

This is a Rails 7 app that allows a user to look up the current and forecasted weather
for a location. A location can be a specific address, a point of interest, or a zip
code. Upon typing the address, the app will look up address suggestions from Mapbox API
and display them below the search field. The user can select an address to get weather
details.

![Screenshot](https://website1-screenshots.s3.amazonaws.com/WeatherScreenshot.png)


## Features

-   Address suggestions are provided by [Mapbox API](https://docs.mapbox.com/api/search/search-box/. 
-   Weather details are provided by [Weather API](https://rapidapi.com/weatherapi/api/weatherapi-com/)
-   If an address is selected from the address suggestions dropdown or a zip code is entered directly, weather data is cached by zip code for 30 minutes.

## To Run This App

http://apple.web-site1.com

## Dependencies

-   Ruby 3.1.4
-   Rails 7.1.3.2
-   Bundler 2.3.26


## Troubleshooting

### Environment variables

The `MAPBOX_API_ACCESS_TOKEN` and `MAPBOX_API_URL` environment variables are required to fetch
address suggestions from Mapbox API. The `WEATHER_API_URL`, `WEATHER_API_KEY`, and `WEATHER_API_HOST`
env variables are required to access Weather API.

You'll need account credentials for Mapbox API and Weather API.  Links are provided above in Features section

Create a `.env` file and set these variables with your credentials. Refer to `.env.sample` as an example.

### Caching

If the caching of weather data does not appear to be working, you may need to run `rails dev:cache`. Also, recall that if a zip code was not included in the search string, the request will not be cached

## Tests

Run full test suite and the test coverage will appear on the last line:

```shell
$ bundle exec rspec
```

To see test coverage details:

```shell
$ open coverage/index.html
```

To see any linting errors:

```shell
$ rubocop
```

## Credits
https://github.com/danwa5

https://github.com/joelparkerhenderson