# Core requirements

- Must be done in Ruby on Rails
- Accept an address as input
- Retrieve forecast data for the given address. This should include, at minimum, the
current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- Display the requested forecast details to the user
- Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
Display indicator if result is pulled from cache.
- Functionality is a priority over form

# Implementation and test coverage details
- Test coverage (controllers/http_clients/presenters/services)
  - All Rspecs are passing. 
    - Finished in 0.1443 seconds (files took 0.8605 seconds to load)
    - 98 examples, 0 failures
  - RSpec testing framework
  - [VCR](https://github.com/vcr/vcr) recorded test suite's Mapbox and Openweather HTTP interactions and replaying them during test runs
  - mocked Redis Connection Pool interactions
- Provided meaningful comments/documentation within the code
- UI is built on [Hotwire](https://hotwired.dev/), Stimulus, Turbo Streams which simplified FrontEnd development (faster), server-side rendering (reducing the need for client-side rendering and the associated complexity) and deployment in comparison of alternative usage of Reactjs or similar frontend frameworks or libraries
- *Decomposition* of the Objects and Design Patterns
  - Controllers -> Services -> Providers (AddressSuggestion/Openweather) APIs -> Redis Cache (Yes/No) -> Presenters -> Response to UI via Turbo Streams
  - Storing current_weather/forecast data in Redis
    - Currently, data is stored in redis in keys [COUNTRY:POSTAL_CODE](https://drive.google.com/file/d/10IlZk25CA-94d68NYCPrFNlDEV7bJQes/view) with TTL. [Uber H3](https://github.com/uber/h3) approach can be considered and should be benchmarked.
      H3 is a geospatial indexing system using a hexagonal grid that can be (approximately) subdivided into finer and finer hexagonal grids, combining the benefits of a hexagonal grid with S2's hierarchical subdivisions. H3 input would be a longitude and latitude and a result hex could be used as a Redis key. Prebuilt bindings or platform-specific compilations can be done, but still, it is a 3rd party library dependency and can make deployment process more complex (dockerization can simplify though).
  - Redis cache service has a [custom FETCH method](https://github.com/austymenko/weather_forecast/blob/84ac1721455f3025c769d564aa22aeb99a9f7d0a/app/services/redis_cache_service.rb#L52) which behaves similar to *Rails.cache.fetch*. Redis was chosen over Memcached to support high application load and usage, as Redis offers more advanced data structures and operations (which definitely will arise while extending Forecast functionality), which can handle increased complexity and load better than the simpler Memcached. Additionally, using Redis can reduce server and memory demands, making it a better fit for hosting services like Heroku.   
  - Heavy use of SOLID principles
    - Single Responsibility Principle (SRP):
      - Each provider handles only its specific API integration
      - The presenter handles only data formatting
      - The service orchestrates the flow but delegates specific responsibilities
    - Open/Closed Principle (OCP):
      - New providers can be added without modifying existing code
      - Just add a new provider class and update the Factory
    - Liskov Substitution Principle (LSP):
      - All providers inherit from a base class and must implement the same interface
      - Providers can be swapped without affecting the rest of the code
    - Interface Segregation Principle (ISP):
      - Clean, minimal interfaces for providers and presenters
      - Each class has only the methods it needs
    - Dependency Inversion Principle (DIP):
      - Service depends on abstractions (base provider/presenter) not concrete implementations
      - Dependencies are injected through the provider parameter  
- Scalability Considerations
  Redis can reduce server and memory demands, making it a better fit for hosting services like Heroku. Redis supports clustering for high availability and scalability.

# Assumptions

The following areas are out of scope:
- logs
- integration/e2e tests
- rate limiting
- authorization
- load testing
- clusterization for the cache
- monitoring
- observability
- deploy
