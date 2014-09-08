module elasticsearch.api.base;

public import elasticsearch.client;

public import elasticsearch.transport.transport;
public import elasticsearch.transport.response;
public import elasticsearch.transport.exceptions;
public import elasticsearch.api.exceptions;
public import elasticsearch.parameters;

import std.algorithm;
import std.regex;
import std.string;
import std.array;

static string[] ES_COMMON_PARAMETERS = [
	"ignore",
	"index", "type", "id",
	"body",
	"node_id",
	"name",
	"field"
];

static string[] ES_COMMON_QUERY_PARAMETERS = [
	"format",
	"pretty",
	"human"
];

void enforceParameter(const ref Parameters p, string name) {
	enforce(p.hasField(name), new ArgumentException(p, name ~ " parameter is required"));
}


/**
 * 
 * At this point the function will silently ignore any unknown options
 * 
 */
Parameters validateAndExtract(const ref Parameters params, string[] allowed ...) {
	return params.filterParameters(allowed ~ ES_COMMON_PARAMETERS ~ ES_COMMON_QUERY_PARAMETERS);
}

string esEscape(string value) {
	import std.uri;

	return encodeComponent(value);
}

string esPathify(string[] path ...) {
	auto stripped = array(path.map!((p) => p.strip));
	auto cleanPath = stripped.remove!((p) => !p.length);
	auto returnString = cleanPath.join("/");
	return returnString.squeeze("/");
}

unittest {
	assert(esPathify("hello/", "", " world") == "hello/world");
}

/// Create a list from the given arguments
string esListify(string[] list ...) {
	auto cleanList = list.remove!((p) => !p.length);
	auto escaped = array(cleanList.map!((l) => l.esEscape));

	return escaped.join(",");
}

unittest {
	assert(esListify("A", "B") == "A,B");
	assert(esListify("one", "two^three") == "one,two%5Ethree");
}

void filterApiParameters(ref Parameters p, string[] allowed ...) {

}