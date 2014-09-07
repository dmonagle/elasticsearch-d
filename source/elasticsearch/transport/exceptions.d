module elasticsearch.transport.exceptions;

import elasticsearch.transport.connections.connection;
import elasticsearch.transport.transport;
import elasticsearch.parameters;
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
	Parameters parameters;
	Json requestBody;
	Response response;

	this(Connection connection, RequestMethod method, string path, Parameters parameters, Json requestBody, Response response) { 
		this.connection = connection;
		this.method = method;
		this.path = path;
		this.parameters = parameters;
		this.requestBody = requestBody;
		this.response = response;

		super("Elasticsearch request failed"); 
	}
}

