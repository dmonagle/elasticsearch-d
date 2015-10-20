module elasticsearch._feature_test.client.indices;

debug (featureTest) {
	import feature_test;
	import elasticsearch._feature_test.elasticsearch_feature;

	unittest {
		feature!ElasticsearchFeature("Test Feature", "", (f) {
				f.scenario("Test Scenario", {
						featureTestPending;
					});
			}, "localES");
	}
}