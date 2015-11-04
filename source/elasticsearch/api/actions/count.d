module elasticsearch.api.actions.count;

import elasticsearch.api.parameters;
import elasticsearch.transport;
import elasticsearch.client;

import vibe.http.common;

Response count(Client client, ESParams arguments = ESParams()) {
	string index = arguments.hasField("index") ? arguments["index"] : "_all";
	string type = arguments.hasField("type") ? arguments["type"] : "";
	arguments.defaultParameter("body", "");
	auto params = arguments.validateAndExtract(
		"analyzer", "analyze_wildcard", "default_operator", "df", 
		"ignore_unavailable", "allow_no_indices", "expand_wildcards", "lenient",
		"lowercase_expanded_terms", "preference", "q", "routing"
		);
	
	auto path = esPathify(esListify(index), esListify(type), "_count");
	
	return client.performRequest(RequestMethod.GET, path, params, arguments["body"]);
}


/// Ditto
uint count(Client client, string index, string query, ESParams params = ESParams()) {
	params["index"] = index;
	if (query.length) params["body"] = query;

	auto result = count(client, params);
	if (result.status != 200) return 0;
	return result.jsonBody["count"].get!uint;
}

/// Ditto
uint count(Client client, string index, ESParams params = ESParams()) {
	return count(client, index, "", params);
}
