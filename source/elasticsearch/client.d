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

	this(T = VibeTransport)() {
		_transport = new T;
	}

	/// Initialize with a list of hosts and reload the connections
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
