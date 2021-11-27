/**
 * Allows you to specify a list of values and which value they should be replaced with. Quick and easy way to line up mismatched picklists.
 */
global with sharing class ValueSwapFilter implements valence.SchemaAwareTransformationFilter, valence.ConfigurablePerMappingFilter {

	// ----------------------------------------
	// ----- ConfigurablePerMappingFilter -----
	// ----------------------------------------

	public String getMappingConfigurationLightningComponent() {
		return 'c:valueSwapFilterConfigurator';
	}

	public String getMappingConfigurationStructure() {
		return null;
	}

	public String explainMappingConfiguration(String configStr) {

		try {
			Configuration config = (Configuration)JSON.deserialize(configStr, Configuration.class);

			String explanation = '<p>If a <em>{0}</em> value on the left is found in this field, it will be replaced with the value on the right:</p><ul>{1}</ul>';
			String values = '';
			for(String key : config.values.keySet()) {
				values += '<li><strong>' + key + '</strong> => <em>' + config.values.get(key) + '</em></li>';
			}
			return String.format(explanation, new List<Object>{
				(config.caseInsensitive == true ? 'case-insensitive' : 'case-sensitive'),
				values
			});
		}
		catch(Exception e) {
			return '<p class="slds-theme_error">This configuration is malformed.</p>';
		}
	}

	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

	public Boolean validFor(valence.LinkContext context) {
		return true;
	}

	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {

		Map<List<String>, Configuration> configsByTargetPath = new Map<List<String>, Configuration>();

		/*
		 * Assemble any configs that have been set up by admins.
		 */
		for(valence.Mapping mapping : context.mappings.values()) {

			// skip blank configurations
			if(String.isNotBlank(mapping.configuration)) {
				try {
					Configuration config = (Configuration)JSON.deserialize(mapping.configuration, Configuration.class);
					if(config.caseInsensitive == true && config.values != null) {
						Map<String,String> lowercaseValues = new Map<String,String>();
						for(String key : config.values.keySet()) {
							lowercaseValues.put(key.toLowerCase(), config.values.get(key));
						}
						config.values = lowercaseValues;
					}
					configsByTargetPath.put(mapping.targetPropertyPath, config);
				}
				catch(Exception e) {
					throw new valence.FilterException('Cannot parse ValueSwapFilter configuration: ' + mapping.configuration, e);
				}
			}
		}

		// bail out if we didn't find any
		if(configsByTargetPath.isEmpty()) {
			return;
		}

		/*
		 * Iterate through our records, using the configured mapping to potentially replace some values.
		 */
		for(valence.RecordInFlight record : records) {
			for(List<String> targetPath : configsByTargetPath.keySet()) {
				Configuration config = configsByTargetPath.get(targetPath);
				String value = String.valueOf(record.getPropertyValue(targetPath));
				if(value != null && config != null && config.values != null) {

					// convert our incoming value to case insensitive if need be
					String keyToCompare = config.caseInsensitive == true ? value.toLowerCase() : value;

					// look to see if this value was configured by an admin to be replaced; if so, replace it
					if(config.values.containsKey(keyToCompare)) {
						record.setPropertyValue(targetPath, config.values.get(keyToCompare));
					}
				}
			}
		}
	}

	// -------------------------------------------
	// ----- SchemaAwareTransformationFilter -----
	// -------------------------------------------

	public valence.FilterSchema describeSchema(valence.LinkContext context) {
		valence.FilterSchema schema = new valence.FilterSchema();

		for(valence.Mapping mapping : context.mappings.values()) {

			// skip blank configurations
			if(String.isNotBlank(mapping.configuration)) {
				schema.addTouch(valence.FilterSchema.buildSourceTouch('SWAPS').onField(mapping));
			}
		}
		return schema;
	}

	/**
	 * Simple class for holding the configuration needed for this filter.
	 */
	private class Configuration {

		private Boolean caseInsensitive;
		private Map<String,String> values;
	}
}