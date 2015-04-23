module elasticsearch.client;

public import vibe.data.json;

public import elasticsearch.transport.transport;
import elasticsearch.parameters;

import elasticsearch.transport.http.vibe;

class Client {
	protected {
		Transport _transport;
	}

	@property Transport transport() { return _transport; }

	this(Host[] hosts ...) {
		_transport = new VibeTransport;
		_transport.hosts = hosts;
	}

	void addHost(Host host) {
		transport.hosts ~= host;
	}

	void reloadConnections() {
		_transport.reloadConnections();
	}

	Response performRequest(RequestMethod method, string path, Parameters parameters = Parameters(), string requestBody = "") {
		return _transport.performRequest(method, path, parameters, requestBody);
	}

}

unittest {
	import elasticsearch.api.actions.base;
	import elasticsearch.api.actions.indices;

	auto client = new Client(Host());

	Parameters p;
	p.addField("index", "es_test_index");
	p.addField("body", `
		{ 
			"settings": {
	           "index": {
	             "number_of_shards": 1,
	             "number_of_replicas": 0,
	           },
	         },
	         "mappings": {
	           "user": {
	             "properties": {
	               "name": { "type": "string"}
	             }
	           }
	         }			
		}
	`);

	auto user = Json.emptyObject;
	user.name = "Ginny";
	user._id = "1024";

	client.createIndex(p);

	// Index the user to the es_text_index container with a type of "user" and id of "1024"
	client.index("es_test_index", "user", "1024", user.toString);

	client.deleteIndex("es_test_index");
}

unittest {
	import std.exception;
	
	auto client = new Client(Host());
	client.reloadConnections();
	
	client.performRequest(RequestMethod.HEAD, "", Parameters());
	auto response = client.performRequest(RequestMethod.HEAD, "", Parameters());
	assert(response.status == 200);
	
	response = client.performRequest(RequestMethod.GET, "_cluster/state", Parameters());
	assert(response.status == 200);
	assert(response.bodyIsJson);
}
