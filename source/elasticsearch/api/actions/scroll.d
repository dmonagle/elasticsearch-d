module elasticsearch.api.actions.scroll;

import elasticsearch.api.parameters;
import elasticsearch.transport;
import elasticsearch.client;

import vibe.http.common;

Response scroll(Client client, ESParams arguments = ESParams()) {
	auto params = arguments.validateAndExtract("scroll", "scroll_id");
	
	auto path = esPathify("_search", "scroll");
	
	return client.performRequest(RequestMethod.GET, path, params);
}