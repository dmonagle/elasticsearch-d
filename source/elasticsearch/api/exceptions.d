module elasticsearch.api.exceptions;

import elasticsearch.parameters;

class ArgumentException : Exception {
	const Parameters params;
	string api;
	
	this(const ref Parameters params, string api, string message = "") { 
		import vibe.data.json;

		this.api = api;
		this.params = params;

		string eMessage = "Elasticsearch Argument Error: '" ~ message ~ "' while calling api '" ~ api ~ "' with params: '";
		//auto paramsString = params.toRepresentation.serializeToJson();
		//eMessage ~= paramsString.toPrettyString();

		super(eMessage); 
	}

}
