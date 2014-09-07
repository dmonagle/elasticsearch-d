module elasticsearch.api.actions.indices;

mixin template all() {
	Response indexCreate(string index, Json jsonBody) {
		// TODO: Add optional parameters to specify timeout
		auto params = Parameters();
		return performRequest(RequestMethod.PUT, pathify(index), params, jsonBody);
	}
}