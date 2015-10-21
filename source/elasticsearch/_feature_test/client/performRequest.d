module elasticsearch._feature_test.client.performRequest;

debug (featureTest) {
	import feature_test;
	import elasticsearch._feature_test.elasticsearch_feature;
	
	unittest {
		feature!ElasticsearchFeature("Run peformRequest on client", "", (f) {
				f.scenario("Empty request", {
						auto response = esForFeatureTest.performRequest(RequestMethod.HEAD, "", ESParams());
						response.status.shouldEqual(200, "Response status");
					});
				f.scenario("Request cluster state", {
						auto response = esForFeatureTest.performRequest(RequestMethod.GET, "_cluster/state", ESParams());
						response.status.shouldEqual(200, "Response status");
						response.bodyIsJson.shouldBeTrue("bodyIsJson");
						auto json = response.jsonBody;
						json["cluster_name"].type.shouldEqual(Json.Type.string, "Response[\"cluster_name\"] type ");
					});
			});
	}
}
