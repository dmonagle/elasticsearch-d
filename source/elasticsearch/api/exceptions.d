module elasticsearch.api.exceptions;

import elasticsearch.api.parameters;

class ArgumentException : Exception {
	const ESParams params;
	string api;
	
	this(const ref ESParams params, string api, string message = "") { 
		import vibe.data.json;

		this.api = api;
		this.params = params;

		string eMessage = "Elasticsearch Argument Error: '" ~ message ~ "' while calling api '" ~ api ~ "' with params: '";
		//auto paramsString = params.toRepresentation.serializeToJson();
		//eMessage ~= paramsString.toPrettyString();

		super(eMessage); 
	}

}
