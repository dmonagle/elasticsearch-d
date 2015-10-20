/**
	* Exception definitions
	*
	* Copyright: © 2015 David Monagle
	* License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	* Authors: David Monagle
*/
module elasticsearch.transport.exceptions;

import elasticsearch.transport.connections.connection;
import elasticsearch.transport.transport;
import elasticsearch.api.parameters;
import vibe.data.json;

class HostUnreachableException : Exception {
	Connection connection;

	this(Connection connection, string message = "") { 
		this.connection = connection;
		super("Elasticsearch host not reachable attempting to access: " ~ connection.host.url ~ "; " ~ message); 
	}
}

class RequestException : Exception {
	Connection connection;
	RequestMethod method;
	string path;
	ESParams parameters;
	string requestBody;
	Response response;

	this(Connection connection, RequestMethod method, string path, ESParams parameters, string requestBody, Response response) { 
		import std.string;

		this.connection = connection;
		this.method = method;
		this.path = path;
		this.parameters = parameters;
		this.requestBody = requestBody;
		this.response = response;

		auto message = format("Elasticsearch request failed (%s %s): %s", 
		                      method, path, response.responseBody);
		super(message); 
	}
}

