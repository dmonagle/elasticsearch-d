/**
	* Elasticsearch get API
	*
	* Copyright: © 2015 David Monagle
	* License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	* Authors: David Monagle
*/
module elasticsearch.api.actions.get;

import elasticsearch.api.parameters;
import elasticsearch.transport.response;
import elasticsearch.transport.exceptions;
import elasticsearch.client;

/// Return a specified document.
///
/// The response contains full document, as stored in Elasticsearch, incl. `_source`, `_version`, etc.
///
/// @example Get a document
///
///     client.get index: 'myindex', type: 'mytype', id: '1'
///
/// @option arguments [String] :id The document ID (*Required*)
/// @option arguments [Number,List] :ignore The list of HTTP errors to ignore; only `404` supported at the moment
/// @option arguments [String] :index The name of the index (*Required*)
/// @option arguments [String] :type The type of the document; use `_all` to fetch the first document
///                                  matching the ID across all types) (*Required*)
/// @option arguments [List] :fields A comma-separated list of fields to return in the response
/// @option arguments [String] :parent The ID of the parent document
/// @option arguments [String] :preference Specify the node or shard the operation should be performed on
///                                        (default: random)
/// @option arguments [Boolean] :realtime Specify whether to perform the operation in realtime or search mode
/// @option arguments [Boolean] :refresh Refresh the shard containing the document before performing the operation
/// @option arguments [String] :routing Specific routing value
/// @option arguments [Number] :version Explicit version number for concurrency control
/// @option arguments [String] :version_type Specific version type (options: internal, external, external_gte, force)
/// @option arguments [String] :_source Specify whether the _source field should be returned,
///                                     or a list of fields to return
/// @option arguments [String] :_source_exclude A list of fields to exclude from the returned _source field
/// @option arguments [String] :_source_include A list of fields to extract and return from the _source field
/// @option arguments [Boolean] :_source_transform Retransform the source before returning it
///
/// @see http://elasticsearch.org/guide/reference/api/get/
Response get(Client client, ESParams arguments = ESParams()) {
	arguments.enforceParameter("index");
	arguments.enforceParameter("id");
	arguments.defaultParameter("type", "_all");

	auto params = arguments.validateAndExtract(
		"fields", "parent", "preference", "realtime", "refresh", "routing", "version", "version_type",
		"_source", "_source_include", "_source_exclude", "_source_transform"
		);

	auto path = esPathify([arguments["index"], arguments["type"], arguments["id"]]);

	return client.performRequest(RequestMethod.GET, path, params);
}

/// Ditto
Response get(Client client, string index, string id, ESParams params = ESParams()) {
	params["index"] = index;
	params["id"] = id;

	return get(client, params);
}
