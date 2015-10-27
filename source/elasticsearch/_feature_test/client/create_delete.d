module elasticsearch._feature_test.client.create_delete;

debug (featureTest) {
	import feature_test;
	import elasticsearch._feature_test.elasticsearch_feature;
	
	unittest {
		feature!ElasticsearchFeature("Create and remove a document", "", (f) {
				f.scenario("Create a new document", {
						esForFeatureTest.createIndex(esTestPrefix("user"));
						auto response = esForFeatureTest.index(esTestPrefix("user"), "user", "1", `{"firstName": "David", "surname": "Monagle"}`);
						response.bodyIsJson.shouldBeTrue("bodyIsJson");
						auto jBody = response.jsonBody;
						jBody["created"].get!(bool).shouldBeTrue;
					});
				f.scenario("Check the new document exists", {
						esForFeatureTest.exists(esTestPrefix("user"), "1").shouldBeTrue;
					});
				f.scenario("Make sure an invalid id doesn't exist", {
						esForFeatureTest.exists(esTestPrefix("user"), "2").shouldBeFalse;
					});
				f.scenario("Delete the new document", {
						esForFeatureTest.delete_(esTestPrefix("user"), "user", "1");
						esForFeatureTest.exists(esTestPrefix("user"), "1").shouldBeFalse;
					});
			}, "localES");
	}
}