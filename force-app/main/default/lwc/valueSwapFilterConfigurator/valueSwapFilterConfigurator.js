/**
 * UI plugin for configuring the ValueSwap Valence Filter
 */

import ValenceUIConfigurator from 'c/valenceUIConfigurator';

export default class ValueSwapFilterConfigurator extends ValenceUIConfigurator {

	// ---------------------------
	// ----- Lifecycle Hooks -----
	// ---------------------------

	/**
	 * Because we store our configuration values as a map and LWCs can't iterate a map, we fiddle the configuration a little on the way in and the way out.
	 */
	onSetConfiguration() {
		// massage server-friendly format into LWC-friendly format
		this.configuration.pairs = Object.entries(this.configuration.values).map(([key, value]) => {
			return {'original' : key, 'swap' : value};
		});
	}

	/**
	 * This is called just before sending the configuration up the chain. We return a simplified version of configuration since we added stuff to it.
	 */
	tweakConfiguration() {
		// turn massaged values back into something the server wants
		return {
			'caseInsensitive' : this.configuration.caseInsensitive,
			'values' : this.configuration.pairs.reduce((values, pair) => {
				values[pair.original] = pair.swap;
				return values;
			}, {})
		};
	}

	// -------------------------------------------
	// ----- User Manipulating Configuration -----
	// -------------------------------------------

	addPair() {
		this.configuration.pairs.push({'original' : '', 'swap' : ''});
		this.configUpdated(); // propagate our configuration changes
	}

	removePair(event) {
		this.configuration.pairs.splice(event.target.value, 1);
		this.configUpdated(); // propagate our configuration changes
	}

	longDebounceOriginalUpdated(event) {
		// we debounce so that the user isn't forced to click out of the field before they click save changes, but we use a long debounce so the field doesn't lose focus on re-render
		const index = event.target.dataset.index, value = event.target.value;
		this.debounce(() => {
				this.configuration.pairs[index].original = value;
				this.configUpdated(); // propagate our configuration changes
			}, 2000
		);
	}

	originalUpdatedImmediately(event) {
		clearTimeout(this._debounceTimer); // cancel any pending debounce
		this.configuration.pairs[event.target.dataset.index].original = event.target.value;
		this.configUpdated(); // propagate our configuration changes
	}

	longDebounceSwapUpdated(event) {
		// we debounce so that the user isn't forced to click out of the field before they click save changes, but we use a long debounce so the field doesn't lose focus on re-render
		const index = event.target.dataset.index, value = event.target.value;
		this.debounce(() => {
				this.configuration.pairs[index].swap = value;
				this.configUpdated(); // propagate our configuration changes
			}, 2000
		);
	}

	swapUpdatedImmediately(event) {
		clearTimeout(this._debounceTimer); // cancel any pending debounce
		this.configuration.pairs[event.target.dataset.index].swap = event.target.value;
		this.configUpdated(); // propagate our configuration changes
	}

	// -----------------------------------------
	// ----- Required Configurator Methods -----
	// -----------------------------------------

	getDefaultShape() {
		return {caseInsensitive : true, values : {}};
	}

	computeValid() {
		if(!this.configuration.values || this.configuration.values.length === 0) {
			return false;
		}
		// make sure each pair has both sides populated to be considered valid
		return this.configuration.pairs.reduce((validSoFar, next) => validSoFar && next.original && next.swap, true);
	}

}