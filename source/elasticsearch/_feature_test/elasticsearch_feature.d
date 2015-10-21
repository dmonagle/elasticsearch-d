module elasticsearch._feature_test.elasticsearch_feature;

import feature_test;
public import elasticsearch.client;

debug (featureTest) {
	string esTestPrefix(string indexName = "") { return "es_d_featuretest_" ~ indexName; }

	Client esForFeatureTest() {
		static Client client;
		
		if (!client) {
			client = new Client(Host()); // Will use localhost:9200 for testing
		}
		
		return client;
	}

	class ElasticsearchFeature : FeatureTest {
		override void beforeAll() {
			clearAllTestIndexes;
		}

		void clearAllTestIndexes() {
			info("Clearing all test indices.");
			esForFeatureTest.delete_(esTestPrefix ~ "*");
		}
	}
}