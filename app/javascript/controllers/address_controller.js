import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
    connect() {
        const input = this.element.querySelector('input');

        const tomSelect = new TomSelect(input, {
            valueField: 'value',
            labelField: 'label',
            searchField: ['label'],
            score: function(search) {
                return function() { return 1; }
            },
            load: (query, callback) => {
                if (!query.length || query.length < 3) {
                    this.clearOptions();  // Clear options for short queries
                    callback();
                    return;
                }

                fetch(`/api/v1/suggestions?query=${encodeURIComponent(query)}`, {
                    headers: {
                        'Accept': 'text/vnd.turbo-stream.html'
                    }
                })
                    .then(response => response.text())
                    .then(html => {
                        const parser = new DOMParser();
                        const doc = parser.parseFromString(html, 'text/html');
                        const template = doc.querySelector('turbo-stream template');

                        if (template) {
                            // Clear existing options before adding new ones
                            this.clearOptions();

                            const container = document.createElement('div');
                            container.innerHTML = template.innerHTML;

                            const options = Array.from(container.querySelectorAll('option'))
                                .filter(option => option.value !== '')
                                .map(option => {
                                    const data = JSON.parse(option.value);
                                    return {
                                        value: option.value,
                                        label: data.address,
                                        data: data
                                    };
                                });

                            callback(options);
                        } else {
                            this.clearOptions();
                            callback();
                        }
                    });
            },
            render: {
                option: function(item, escape) {
                    return `<div>${escape(item.label)}</div>`;
                },
                item: function(item, escape) {
                    return `<div>${escape(item.label)}</div>`;
                }
            },
            onItemAdd: (value, item) => {
                const data = JSON.parse(value);
                this.handleSelect(data);
            }
        });

        this.tomSelect = tomSelect;
    }

    clearOptions() {
        if (this.tomSelect) {
            // Clear all options
            this.tomSelect.clearOptions();
        }
    }

    handleSelect(data) {
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

        fetch('/api/v1/forecasts', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken,
                'Accept': 'text/vnd.turbo-stream.html'
            },
            body: JSON.stringify({
                address: data.address,
                latitude: data.lat,
                longitude: data.lon
            })
        })
            .then(response => response.text())
            .then(html => {
                console.log('Forecast created successfully');
            });
    }
}
