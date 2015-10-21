module elasticsearch._feature_test.client.indices;

debug (featureTest) {
	import feature_test;
	import elasticsearch._feature_test.elasticsearch_feature;
	
	unittest {
		feature!ElasticsearchFeature("Create and remove an index", "", (f) {
				f.scenario("Create a new index", {
						esForFeatureTest.exists(esTestPrefix("user")).shouldBeFalse("Test index exists");
						esForFeatureTest.createIndex(esTestPrefix("user"));
						esForFeatureTest.exists(esTestPrefix("user")).shouldBeTrue("Test index exists");
					});
				f.scenario("Delete the new index", {
						esForFeatureTest.delete_(esTestPrefix("user"));
						esForFeatureTest.exists(esTestPrefix("user")).shouldBeFalse("Test index exists");
					});
			}, "localES");
	}
}