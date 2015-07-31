module elasticsearch.api.actions.bulk;

import elasticsearch.api.base;

Response bulk(Client client, Parameters arguments = Parameters()) {
	arguments.enforceParameter("body");

	auto requestBody = arguments["body"];
	auto params = arguments.validateAndExtract(
		"consistency", "refresh", "replication", "type", "timeout"
		);
	string[] path;
	if ("index" in arguments) {
		path ~= arguments["index"];
		if ("type" in arguments) {
			path ~= arguments["type"];
		}
	}
	path ~= "_bulk";

	return client.performRequest(RequestMethod.POST, esPathify(path), params, requestBody);
}

Response bulk(Client client, string bulkBody, Parameters params = Parameters()) {
	params["body"] = bulkBody;
	return bulk(client, params);
}