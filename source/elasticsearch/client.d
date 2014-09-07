module elasticsearch.client;

import elasticsearch.transport.transport;
import elasticsearch.parameters;
public import vibe.data.json;

import elasticsearch.transport.http.vibe;

import elasticsearch.api.base;
import elasticsearch.api.actions.indices;

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

	Response performRequest(RequestMethod method, string path, Parameters parameters = Parameters(), Json requestBody = Json.emptyObject) {
		return _transport.performRequest(method, path, parameters, requestBody);
	}

	mixin elasticsearch.api.actions.indices.all;
}

unittest {
	auto client = new Client(Host());
	client.indexCreate("davids_test_index", JsonParams("{ body: {}}"));
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
