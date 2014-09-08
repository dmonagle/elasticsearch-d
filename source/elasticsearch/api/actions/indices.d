module elasticsearch.api.actions.indices;

import elasticsearch.api.base;

alias createIndex = elasticsearch.api.actions.indices.create;

/** Create an index.
*
* Creates a new index
*
* Params: 
* 	arguments =	A Parameters dictionary list with the following
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
Response create(Client client, Parameters arguments = Parameters()) {
	arguments.enforceParameter("index");

	auto index = arguments["index"];
	auto params = arguments.validateAndExtract("timeout");
	auto requestBody = arguments["body"];

	return client.performRequest(RequestMethod.PUT, esPathify(index), params, requestBody);
}

alias deleteIndex = elasticsearch.api.actions.indices.delete_;

Response delete_(Client client, string[] indexes, Parameters arguments = Parameters()) {
	auto params = arguments.validateAndExtract("timeout");
	return client.performRequest(RequestMethod.DELETE, esPathify(esListify(indexes)), params);
}

Response delete_(Client client, string index, Parameters params = Parameters()) {
	return delete_(client, [index], params);
}

