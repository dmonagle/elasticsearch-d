/**
	* Elasticsearch exists API
	*
	* Copyright: © 2015 David Monagle
	* License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	* Authors: David Monagle
*/
module elasticsearch.api.actions.exists;

import elasticsearch.api.parameters;
import elasticsearch.transport.response;
import elasticsearch.transport.exceptions;
import elasticsearch.client;

/// Return true if the specified document exists, false otherwise.
///
/// @example
///
///     client.exists? index: 'myindex', type: 'mytype', id: '1'
///
/// @option arguments [String] :id The document ID (*Required*)
/// @option arguments [String] :index The name of the index (*Required*)
/// @option arguments [String] :type The type of the document (default: `_all`)
/// @option arguments [String] :parent The ID of the parent document
/// @option arguments [String] :preference Specify the node or shard the operation should be performed on
///                                        (default: random)
/// @option arguments [Boolean] :realtime Specify whether to perform the operation in realtime or search mode
/// @option arguments [Boolean] :refresh Refresh the shard containing the document before performing the operation
/// @option arguments [String] :routing Specific routing value
///
/// @see http://elasticsearch.org/guide/reference/api/get/
Response exists(Client client, ESParams arguments = ESParams()) {
	arguments.enforceParameter("index");
	arguments.enforceParameter("id");
	arguments.defaultParameter("type", "_all");
	
	auto params = arguments.validateAndExtract(
		"parent", "preference", "realtime", "refresh", "routing"
		);
	
	auto path = esPathify([arguments["index"], arguments["type"], arguments["id"]]);
	
	return client.performRequest(RequestMethod.HEAD, path, params);
}

/// Ditto
bool exists(Client client, string index, string id, ESParams params = ESParams()) {
	params["index"] = index;
	params["id"] = id;
	
	auto result = exists(client, params);
	return result.status == 200 ? true : false;
}
