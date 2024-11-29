import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
    connect() {
        const input = this.element.querySelector('#address-search');

        if (!input) {
            console.error("Input element not found");
            return;
        }

        try {
            const tomSelect = new TomSelect(input, {
                valueField: 'value',
                labelField: 'label',
                searchField: ['label'],
                plugins: {},
                hideSelected: true,
                closeAfterSelect: true,
                controlInput: '<input type="text">',
                score: function(search) {
                    return function() { return 1; }
                },
                load: (query, callback) => {
                    if (!query.length || query.length < 3) {
                        this.clearOptions();
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
                            const streams = doc.querySelectorAll('turbo-stream');

                            streams.forEach(stream => {
                                if (stream.getAttribute('target') === 'address-errors') {
                                    const errorDiv = document.getElementById('address-errors');
                                    if (errorDiv) {
                                        const template = stream.querySelector('template');
                                        if (template) {
                                            errorDiv.className = 'mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-md shadow-sm';
                                            errorDiv.style.color = '#b91c1c';
                                            errorDiv.innerHTML = template.innerHTML;

                                            const errorMessage = errorDiv.querySelector('.error');
                                            if (errorMessage) {
                                                errorMessage.className = 'error text-red-700 font-medium';
                                                errorMessage.style.color = '#b91c1c';
                                            }

                                            errorDiv.style.display = 'block';
                                            errorDiv.style.position = 'relative';
                                            errorDiv.style.zIndex = '50';
                                            errorDiv.style.opacity = '1';
                                        }
                                    }
                                }

                                if (stream.getAttribute('target') === 'address-suggestions') {
                                    const container = document.createElement('div');
                                    container.innerHTML = stream.querySelector('template').innerHTML;

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

                                    this.clearOptions();
                                    callback(options);
                                }
                            });

                            if (!streams.length) {
                                this.clearOptions();
                                callback();
                            }
                        })
                        .catch(error => {
                            console.error('Error fetching suggestions:', error);
                            callback();
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
        } catch (error) {
            console.error("Error initializing TomSelect:", error);
        }
    }

    clearOptions() {
        if (this.tomSelect) {
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
            })
            .catch(error => {
                console.error('Error creating forecast:', error);
            });
    }
}