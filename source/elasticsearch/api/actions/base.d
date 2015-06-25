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

Response search(Client client, Parameters arguments = Parameters()) {
	string index = arguments.hasField("index") ? arguments["index"] : "_all";
	string type = arguments.hasField("type") ? arguments["type"] : "";

	auto params = arguments.validateAndExtract(
		"analyzer", "analyze_wildcard", "default_operator", "df", "explain", "fields", "from",
		"ignore_indices", "ignore_unavailable", "allow_no_indices", "expand_wildcards", "lenient",
		"lowercase_expanded_terms", "preference", "q", "routing", "scroll", "search_type", "size", "sort",
		"source", "_source", "_source_include", "source_exclude", "stats", "suggest_field", "suggest_mode",
		"suggest_size", "suggest_text", "timeout", "version"
	);

	auto path = esPathify(esListify(index), esListify(type), "_search");

	return client.performRequest(RequestMethod.GET, path, params, arguments["body"]);
}

Response scroll(Client client, Parameters arguments = Parameters()) {
	auto params = arguments.validateAndExtract("scroll", "scroll_id");
	
	auto path = esPathify("_search", "scroll");

	return client.performRequest(RequestMethod.GET, path, params);
}