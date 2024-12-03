# Weather Forecast

Forecast is a weather forecasting service based on the entered address or selected from suggested addressed.

DEMO:
https://drive.google.com/file/d/100NZGxoQBBdfv4ZZC75ZvepIYUgvyEjI/view

[Code challenge requirements and assumptions](docs/implementation_details_and_assumptions.md)

## App user experience and data flow

1. User enters address, triggering API lookup.
2. Backend retrieves suggestions using Mapbox, user selects address.
3. Backend sends Turbo Streams supporting current weather and 5-day forecast:
 - Current conditions from OpenWeather API.
 - 5-day forecast from OpenWeather API.
4. Backend checks cache for data, displays age if cached.
5. Frontend displays current weather and 5-day forecast.

## Preparing for deployment

The only one thing should be done is to precompile assets.

```bash
bin/rails assets:precompile
```

## Run project

```bash
bin/rails server
```

Visit http://localhost:3000

## Testing

```bash
bundle exec rspec spec
```
