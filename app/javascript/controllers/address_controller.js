import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
    static MIN_QUERY_LENGTH = 3;
    static WEATHER_UPDATE_DELAY = 50; // milliseconds

    connect() {
        this.initializeAddressSearch();
    }

    initializeAddressSearch() {
        const input = this.element.querySelector('#address-search');
        if (!input) return;

        try {
            this.tomSelect = new TomSelect(input, {
                valueField: 'value',
                labelField: 'label',
                searchField: ['label'],
                plugins: {},
                hideSelected: true,
                closeAfterSelect: true,
                controlInput: '<input type="text">',
                score: () => () => 1,
                load: this.handleAddressLoad.bind(this),
                render: {
                    option: (item, escape) => `<div>${escape(item.label)}</div>`,
                    item: (item, escape) => `<div>${escape(item.label)}</div>`
                },
                onItemAdd: (value) => {
                    const data = JSON.parse(value);
                    this.handleAddressSelect(data);
                }
            });
            this.tomSelect.wrapper.style.width = '400px';
        } catch (error) {
            console.error("Error fetching address suggestions: ", error);
        }
    }

    async handleAddressLoad(query, callback) {
        // bail out early if query is too short
        if (!query.length || query.length < this.constructor.MIN_QUERY_LENGTH) {
            this.clearOptions();
            callback();
            return;
        }

        try {
            const response = await fetch(`/api/v1/suggestions?query=${encodeURIComponent(query)}`, {
                headers: { 'Accept': 'text/vnd.turbo-stream.html' }
            });

            // Let Turbo handle the stream
            const responseText = await response.text();
            // let turbo do its thing first
            Turbo.renderStreamMessage(responseText);

            // now handle the response for our dropdown
            const doc = new DOMParser().parseFromString(responseText, 'text/html');
            const suggestionsTemplate = doc.querySelector('turbo-stream[target="address-suggestions"] template');

            if (suggestionsTemplate) {
                this.handleSuggestions(suggestionsTemplate, callback);
            } else {
                this.clearOptions();
                callback();
            }
        } catch {
            callback();
        }
    }

    async handleAddressSelect(data) {
        try {
            this.tomSelect.clearOptions();
            this.tomSelect.close();
            document.querySelectorAll('option').forEach(opt => opt.remove());

            // make sure we have containers before doing anything
            const currentWeatherFrame = document.getElementById('current-weather');
            const forecastFrame = document.getElementById('forecast');

            if (!currentWeatherFrame) {
                console.error('Current weather frame not found');
                return;
            }

            if (!forecastFrame) {
                console.error('Forecast frame not found');
                return;
            }

            // clear old data first
            currentWeatherFrame.innerHTML = '';
            forecastFrame.innerHTML = '';

            const processWeatherStream = async (html) => {
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');
                const streams = Array.from(doc.querySelectorAll('turbo-stream'));

                for (const stream of streams) {
                    const target = stream.getAttribute('target');
                    const frame = document.getElementById(target);
                    if (frame && stream.querySelector('template')) {
                        frame.innerHTML = stream.querySelector('template').innerHTML;
                    }
                }
            };

            // grab and process both weather updates
            await Promise.all([
                this.fetchCurrentWeather(data.lat, data.lon, data.postcode, data.country)
                    .then(processWeatherStream)
                    .catch(error => console.error('Current weather error:', error)),

                this.fetchForecast(data.lat, data.lon, data.postcode, data.country)
                    .then(processWeatherStream)
                    .catch(error => console.error('Forecast error:', error))
            ]);

        } catch (error) {
            console.error('Error updating weather:', error);
        }
    }

    fetchCurrentWeather(latitude, longitude, postcode, country) {
        return fetch(`/api/v1/forecasts/current_weather?latitude=${latitude}&longitude=${longitude}&country=${country}&postcode=${postcode}`, {
            headers: { 'Accept': 'text/vnd.turbo-stream.html' }
        }).then(response => response.text()); // Remove the renderStreamMessage here
    }

    fetchForecast(latitude, longitude, postcode, country) {
        return fetch(`/api/v1/forecasts/forecast?latitude=${latitude}&longitude=${longitude}&country=${country}&postcode=${postcode}`, {
            headers: { 'Accept': 'text/vnd.turbo-stream.html' }
        }).then(response => response.text()); // Remove the renderStreamMessage here
    }

    handleSuggestions(template, callback) {
        // grab all non-empty options and format them for tom-select
        const options = Array.from(template.content.querySelectorAll('option'))
            .filter(option => option.value !== '')
            .map(option => {
                const data = JSON.parse(option.value);
                return {
                    value: option.value,
                    label: data.address,
                    data: data
                };
            });

        // cleanup leftover options to prevent duplicates
        template.content.querySelectorAll('option').forEach(opt => opt.remove());

        this.clearOptions();
        callback(options);
    }

    clearOptions() {
        this.tomSelect?.clearOptions();
    }
}