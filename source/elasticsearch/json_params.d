module elasticsearch.json_params;

public import vibe.data.json;

alias EmptyParams = Json.emptyObject;

alias JsonParams = Json;

bool hasParam(Json json, string key) {
	return cast(bool)(key in json);
}

T valueOrDefault(T)(Json json, string key, T defaultValue) {
	if (json.hasParam(key)) return json[key].get!T();
	return defaultValue;
}

Json jsonParams(T)(T params) { return serializeToJson(params); }

unittest {
	import std.string;
	
	string testFunction(string value, JsonParams params = EmptyParams) {
		auto returnString = value;
		
		if(valueOrDefault(params, "upcase", false)) {
			returnString = toUpper(returnString);
		}
		
		if(valueOrDefault(params, "capitalize", false)) {
			returnString = capitalize(returnString);
		}
		
		return returnString;
	}
	
	assert(testFunction("hello world") == "hello world");
	assert(testFunction("hello world", jsonParams(["upcase": true])) == "HELLO WORLD");
	assert(testFunction("hello world", jsonParams(["capitalize": true])) == "Hello world");
}
