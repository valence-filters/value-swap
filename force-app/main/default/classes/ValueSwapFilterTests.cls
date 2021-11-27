/**
 * Exercises the ValueSwapFilter class.
 */
@IsTest
private class ValueSwapFilterTests {

	@IsTest static void testWithConfigs() {

		String doNotCallConfig = JSON.serialize(new Map<String, Object>{
			'caseInsensitive' => true,
			'values' => new Map<String, String>{'N' => 'false', 'Y' => 'true'}
		});
		String departmentConfig = JSON.serialize(new Map<String, Object>{
			'caseInsensitive' => false,
			'values' => new Map<String, String>{'Space Exploration' => 'Deep Space Mining', 'Linguistics' => 'Liason'}
		});

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkTargetName = 'Contact';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'NoContact', 'DoNotCall', doNotCallConfig),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', null),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Department', departmentConfig)
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>())
		};

		records[0].getProperties().put('DoNotCall', 'N');
		records[0].getProperties().put('LastName', 'George');
		records[0].getProperties().put('Department', 'Agriculture');

		records[1].getProperties().put('DoNotCall', 'n');
		records[1].getProperties().put('LastName', 'Sally');
		records[1].getProperties().put('Department', 'Space Exploration');

		records[2].getProperties().put('DoNotCall', 'Y');
		records[2].getProperties().put('LastName', 'Jen');
		records[2].getProperties().put('Department', 'SPACE EXPLORATION');

		records[3].getProperties().put('DoNotCall', 'N');
		records[3].getProperties().put('LastName', 'Sam');
		records[3].getProperties().put('Department', 'Linguistics');

		records[4].getProperties().put('DoNotCall', 'y');
		records[4].getProperties().put('LastName', 'Wally');
		records[4].getProperties().put('Department', 'Deep Space Mining');

		Test.startTest();
		new ValueSwapFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(5, records.size());

		System.assertEquals('false', records[0].getProperties().get('DoNotCall'));
		System.assertEquals('Agriculture', records[0].getProperties().get('Department'));

		System.assertEquals('false', records[1].getProperties().get('DoNotCall'));
		System.assertEquals('Deep Space Mining', records[1].getProperties().get('Department')); // swapped out

		System.assertEquals('true', records[2].getProperties().get('DoNotCall'));
		System.assertEquals('SPACE EXPLORATION', records[2].getProperties().get('Department')); // not swapped (case-sensitive!)

		System.assertEquals('false', records[3].getProperties().get('DoNotCall'));
		System.assertEquals('Liason', records[3].getProperties().get('Department')); // swapped out

		System.assertEquals('true', records[4].getProperties().get('DoNotCall'));
		System.assertEquals('Deep Space Mining', records[4].getProperties().get('Department'));
	}

	@IsTest static void testBadConfig() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkTargetName = 'Contact';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'NoContact', 'DoNotCall', 'broken')
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>())
		};

		try {
			new ValueSwapFilter().process(context, records);
			System.assert(false, 'Expected an exception due to the malformed configuration.');
		}catch(Exception e) {
			System.assertEquals('valence.FilterException',e.getTypeName());
			System.assertEquals('Cannot parse ValueSwapFilter configuration: broken',e.getMessage());
			System.assertNotEquals(null, e.getCause());
		}
	}

	@IsTest static void testNoConfigs() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkTargetName = 'Contact';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'NoContact', 'DoNotCall', null),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', null),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Department', null)
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>()),
			new valence.RecordInFlight(new Map<String, Object>())
		};

		records[0].getProperties().put('DoNotCall', 'N');
		records[0].getProperties().put('LastName', 'George');
		records[0].getProperties().put('Department', 'Agriculture');

		records[1].getProperties().put('DoNotCall', 'N');
		records[1].getProperties().put('LastName', 'Sally');
		records[1].getProperties().put('Department', 'Space Exploration');

		records[2].getProperties().put('DoNotCall', 'Y');
		records[2].getProperties().put('LastName', 'Jen');
		records[2].getProperties().put('Department', 'SPACE EXPLORATION');

		records[3].getProperties().put('DoNotCall', 'N');
		records[3].getProperties().put('LastName', 'Sam');
		records[3].getProperties().put('Department', 'Linguistics');

		records[4].getProperties().put('DoNotCall', 'Y');
		records[4].getProperties().put('LastName', 'Wally');
		records[4].getProperties().put('Department', 'Deep Space Mining');

		Test.startTest();
		new ValueSwapFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(5, records.size());
		System.assertEquals('N', records[0].getProperties().get('DoNotCall'));
		System.assertEquals('Agriculture', records[0].getProperties().get('Department'));
		System.assertEquals('N', records[1].getProperties().get('DoNotCall'));
		System.assertEquals('Space Exploration', records[1].getProperties().get('Department'));
		System.assertEquals('Y', records[2].getProperties().get('DoNotCall'));
		System.assertEquals('SPACE EXPLORATION', records[2].getProperties().get('Department'));
		System.assertEquals('N', records[3].getProperties().get('DoNotCall'));
		System.assertEquals('Linguistics', records[3].getProperties().get('Department'));
		System.assertEquals('Y', records[4].getProperties().get('DoNotCall'));
		System.assertEquals('Deep Space Mining', records[4].getProperties().get('Department'));
	}

	@IsTest static void testRestrictions() {

		// should work anywhere
		System.assertEquals(true, new ValueSwapFilter().validFor(null));
	}

	@IsTest static void testDescribeSchema() {

		// setup up an artificial Context to use for our test
		String doNotCallConfig = JSON.serialize(new Map<String, Object>{
			'caseInsensitive' => true,
			'values' => new Map<String, String>{'N' => 'false', 'Y' => 'true'}
		});
		String departmentConfig = JSON.serialize(new Map<String, Object>{
			'caseInsensitive' => false,
			'values' => new Map<String, String>{'Space Exploration' => 'Deep Space Mining', 'Linguistics' => 'Liason'}
		});

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkTargetName = 'Contact';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'NoContact', 'DoNotCall', doNotCallConfig),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', null),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Department', departmentConfig)
		};

		new ValueSwapFilter().describeSchema(context);

		// there's no way atm to evaluate the result
	}

	@IsTest static void testConfigurationMethods() {

		ValueSwapFilter filter = new ValueSwapFilter();

		System.assertNotEquals(null, filter.getMappingConfigurationLightningComponent());
		System.assertEquals(null, filter.getMappingConfigurationStructure());

		String config = JSON.serialize(new Map<String, Object>{
			'caseInsensitive' => true,
			'values' => new Map<String, String>{'Space Exploration' => 'Deep Space Mining', 'Linguistics' => 'Liason'}
		});

		System.assertEquals('<p>If a <em>case-insensitive</em> value on the left is found in this field, it will be replaced with the value on the right:</p><ul><li><strong>Linguistics</strong> => <em>Liason</em></li><li><strong>Space Exploration</strong> => <em>Deep Space Mining</em></li></ul>', filter.explainMappingConfiguration(config));

		System.assertEquals('<p class="slds-theme_error">This configuration is malformed.</p>', filter.explainMappingConfiguration('broken'));
	}
}
