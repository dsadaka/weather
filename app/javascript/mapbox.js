/**
 * This function finds address suggestions from the search term and displays
 * them in the UI
 *
 * @param {String} input - The address search term entered by the user
 */
async function findSuggestions(input) {
    const ol = document.getElementById('suggestions-container');

    if (input === undefined || input.length <= 5) {
        ol.style.display = 'none';
        return;
    }

    const suggestions = await findAutocompleteResults(input);

    // display suggestions in UI
    if (suggestions.length > 0) {
        ol.style.display = 'block';
        ol.innerHTML = '';
        let items = '';

        suggestions.forEach((suggestion, idx) => {
            items += buildListItem(suggestion, idx);
        });

        ol.innerHTML = items;
    } else {
        ol.style.display = 'none';
    }
}

/**
 * This function makes an api call to the Mapbox API
 *
 * @param {String} input The address search term entered by the user
 * @returns {Array<Object>} A collection of suggestions
 */
async function findAutocompleteResults(input) {
    try {
        // make asynchronous call to fetch suggestions
        const response = await fetch(
            `forecast/autocomplete?search_term=${input}`,
            {
                method: 'GET',
            }
        );

        const results = await response.json();
        return results?.suggestions;
    } catch (err) {
        console.error(err);
    }
}

/**
 * This function builds the html list item for the suggestion
 *
 * @param {Object} suggestion The address suggestion object from Mapbox
 * @param {Number} index The index of the suggestion within the collection
 * @returns {String} The constructed list element
 */
function buildListItem(suggestion, index) {
    const zipCode = parseZipcode(suggestion);
    const formattedZipCode = zipCode == undefined ? '' : zipCode;

    return (
        '<li id="autocompleteOption' +
        index +
        '" data-zip-code="' +
        formattedZipCode +
        '" onClick="selectSuggestion(' +
        index +
        ');">' +
        suggestion.name +
        ' ' +
        suggestion.place_formatted +
        '</li>'
    );
}

/**
 * This function parses the zip code from the suggestion object
 *
 * @param {Object} suggestion The address suggestion object from Mapbox
 * @returns {String} The parsed zip code
 */
function parseZipcode(suggestion) {
    let zipCode;

    // some suggestions do not contain a zip/postal code
    if (suggestion.feature_type === 'postcode') {
        zipCode = suggestion.name;
    } else {
        zipCode = suggestion.context?.postcode?.name;
    }

    return zipCode;
}

/**
 * This function handles the action after an user selects a suggestion
 *
 * @param {Number} index The index of the selected suggestion
 */
function selectSuggestion(index) {
    const searchField = document.getElementById('search_term');
    const zipCodeField = document.getElementById('zip_code');
    const suggestion = document.getElementById('autocompleteOption' + index);

    // set form fields
    searchField.value = suggestion.innerHTML;
    zipCodeField.value = suggestion.getAttribute('data-zip-code');

    // remove suggestions
    document.getElementById('suggestions-container').style.display = 'none';

    // submit form
    document.getElementById('search_form').submit();
}

window.findAutocompleteResults = findAutocompleteResults;
window.findSuggestions = findSuggestions;
window.selectSuggestion = selectSuggestion;
