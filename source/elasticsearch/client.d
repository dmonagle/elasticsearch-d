/**
	* Elasticsearch Client
	*
	* Copyright: © 2015 David Monagle
	* License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	* Authors: David Monagle
*/
module elasticsearch.client;

public import vibe.data.json;

public import elasticsearch.transport.transport;
public import elasticsearch.api;

import elasticsearch.transport.http.vibe;

/// Elasticsearch Client Class
class Client {
	protected {
		Transport _transport;
	}

	@property Transport transport() { return _transport; }

	this(T = VibeTransport)(Host[] hosts ...) {
		_transport = new T;
		_transport.hosts = hosts;
		reloadConnections;
	}

	/// Add a new host to the transport
	void addHost(Host host) {
		transport.hosts ~= host;
	}


	/// Reload all connections
	void reloadConnections() {
		_transport.reloadConnections();
	}

	/// Perform a request against the transport
	Response performRequest(RequestMethod method, string path, ESParams parameters = ESParams(), string requestBody = "") {
		return _transport.performRequest(method, path, parameters, requestBody);
	}

}

unittest {
	/*
	import elasticsearch.api.actions.base;
	import elasticsearch.api.actions.indices;

	auto client = new Client(Host());

	ESParams p;
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
	
	client.performRequest(RequestMethod.HEAD, "", ESParams());
	auto response = client.performRequest(RequestMethod.HEAD, "", ESParams());
	assert(response.status == 200);
	
	response = client.performRequest(RequestMethod.GET, "_cluster/state", ESParams());
	assert(response.status == 200);
	assert(response.bodyIsJson);
*/
}
