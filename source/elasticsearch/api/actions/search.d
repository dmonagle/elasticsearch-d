module elasticsearch.api.actions.search;

import elasticsearch.api.parameters;
import elasticsearch.transport;
import elasticsearch.client;

import vibe.http.common;

Response search(Client client, ESParams arguments = ESParams()) {
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
