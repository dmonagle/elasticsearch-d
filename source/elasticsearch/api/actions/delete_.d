module elasticsearch.api.actions.delete_;

import elasticsearch.api.parameters;
import elasticsearch.transport;
import elasticsearch.client;

import vibe.http.common;

/// Delete a single document.
///
/// @example Delete a document
///
///     client.delete index: 'myindex', type: 'mytype', id: '1'
///
/// @example Delete a document with specific routing
///
///     client.delete index: 'myindex', type: 'mytype', id: '1', routing: 'abc123'
///
/// @option arguments [String] :id The document ID (*Required*)
/// @option arguments [Number,List] :ignore The list of HTTP errors to ignore; only `404` supported at the moment
/// @option arguments [String] :index The name of the index (*Required*)
/// @option arguments [String] :type The type of the document (*Required*)
/// @option arguments [String] :consistency Specific write consistency setting for the operation
///                                         (options: one, quorum, all)
/// @option arguments [String] :parent ID of parent document
/// @option arguments [Boolean] :refresh Refresh the index after performing the operation
/// @option arguments [String] :replication Specific replication type (options: sync, async)
/// @option arguments [String] :routing Specific routing value
/// @option arguments [Time] :timeout Explicit operation timeout
/// @option arguments [Number] :version Explicit version number for concurrency control
/// @option arguments [String] :version_type Specific version type (options: internal, external, external_gte, force)
///
/// @see http://elasticsearch.org/guide/reference/api/delete/
///
Response delete_(Client client, ESParams arguments = ESParams()) {
	arguments.enforceParameter("index");
	arguments.enforceParameter("type");

	auto params = arguments.validateAndExtract(
		"consistency", "parent", "refresh", "replication", "routing",
		"timeout", "version", "version_type"
		);

	string[] path = [arguments["index"], arguments["type"], arguments["id"]];
	
	return client.performRequest(RequestMethod.DELETE, esPathify(path), params);
}

/// ditto
Response delete_(Client client, string indexName, string type, string id, ESParams params = ESParams()) {
	params["index"] = indexName;
	params["type"] = type;
	params["id"] = id;
	
	return delete_(client, params);
}
