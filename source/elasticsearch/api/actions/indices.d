/**
	* Indice API
	*
	* Copyright: © 2015 David Monagle
	* License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	* Authors: David Monagle
*/
module elasticsearch.api.actions.indices;

import elasticsearch.api.parameters;
import elasticsearch.transport.response;
import elasticsearch.transport.exceptions;
import elasticsearch.client;

/** Create an index.
*
* Creates a new index
*
* Params: 
* 	arguments =	A ESParams dictionary list with the following
* 				index: The index name (required)
* 				body: Optional json string configuration for the index (`settings` and `mappings`)
* 				timeout: Explicit operation timeout
* 
* Returns: Response object with the server response.
* 
* Throws: ArgumentError
* 
* See_Also: http://www.elasticsearch.org/guide/reference/api/admin-indices-create-index/
* 
*/
Response createIndex(Client client, ESParams arguments = ESParams()) {
	arguments.enforceParameter("index");

	auto index = arguments["index"];
	auto params = arguments.validateAndExtract("timeout");
	auto requestBody = arguments["body"];

	return client.performRequest(RequestMethod.PUT, esPathify(index), params, requestBody);
}

///
Response createIndex(Client client, string indexName, string indexBody = "{}", ESParams params = ESParams()) {
	params["index"] = indexName;
	params["body"] = indexBody;
	return createIndex(client, params);
}

///
Response deleteIndex(Client client, string[] indexes, ESParams arguments = ESParams()) {
	auto params = arguments.validateAndExtract("timeout");
	return client.performRequest(RequestMethod.DELETE, esPathify(esListify(indexes)), params);
}

///
Response deleteIndex(Client client, string index, ESParams params = ESParams()) {
	return deleteIndex(client, [index], params);
}

///
alias refreshIndex = elasticsearch.api.actions.indices.refresh_;

///
Response refresh_(Client client, string[] indexes, ESParams arguments = ESParams()) {
       auto params = arguments.validateAndExtract("timeout");
       indexes ~= "_refresh";
       return client.performRequest(RequestMethod.POST, esPathify(indexes), params);
}

///
Response refresh_(Client client, string index, ESParams params = ESParams()) {
       return refresh_(client, [index], params);
}


///
bool indexExists(Client client, ESParams arguments) {
	arguments.enforceParameter("index");

	auto params = arguments.validateAndExtract(
			"ignore_indices", "ignore_unavailable", "allow_no_indices",
			"expand_wildcards", "local"
	);

	try {
		Response response = client.performRequest(RequestMethod.HEAD, esPathify(arguments["index"]), params);
		return (response.status == 200);
	}
	catch (RequestException e) {
		return false;
	}
}

///
bool indexExists(Client client, string indexName, ESParams params = ESParams()) {
	params["index"] = indexName;

	return indexExists(client, params);
}
