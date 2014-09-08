module elasticsearch.api.actions.base;

import elasticsearch.api.base;

alias create = elasticsearch.api.actions.base.index;

Response index(Client client, Parameters arguments = Parameters()) {
	RequestMethod method;

	arguments.enforceParameter("index");
	arguments.enforceParameter("type");

	auto requestBody = arguments["body"];
	auto params = arguments.validateAndExtract(
		"consistency", "op_type", "parent", "percolate", "refresh", "replication", "routing",
		"timeout", "timestamp", "ttl", "version", "version_type"
	);
	string[] path = [arguments["index"], arguments["type"]];

	if (arguments.hasField("id")) {
		method = RequestMethod.PUT;
		path ~= arguments["id"];
	}
	else {
		method = RequestMethod.POST;
	}

	return client.performRequest(method, esPathify(path), params, requestBody);
}

Response index(Client client, string indexName, string type, string id, string requestBody, Parameters p = Parameters()) {
	p["index"] = indexName;
	p["type"] = type;
	p["id"] = id;
	p["body"] = requestBody;

	return index(client, p);
}

Response index(Client client, string indexName, string type, string requestBody, Parameters p = Parameters()) {
	p["index"] = indexName;
	p["type"] = type;
	p["body"] = requestBody;
	
	return index(client, p);
}