module elasticsearch.api.exceptions;

import elasticsearch.json_params;

class ArgumentException : Exception {
	JsonParams params;
	string api;
	
	this(JsonParams params, string api, string message = "") { 
		this.api = api;
		this.params = params;
		super("Elasticsearch Argument Error: '" ~ message ~ "' while calling api '" ~ api ~ "' with params: '" ~ params.toPrettyString); 
	}
}
