module elasticsearch.api.base;

public import elasticsearch.transport.response;
public import elasticsearch.api.exceptions;
public import elasticsearch.json_params;

import std.algorithm;
import std.regex;
import std.string;
import std.array;

string pathify(string[] path ...) {
	auto stripped = array(path.map!((p) => p.strip));
	auto cleanPath = stripped.remove!((p) => !p.length);
	auto returnString = cleanPath.join("/");
	return returnString.squeeze("/");
}

unittest {
	assert(pathify("hello/", "", " world") == "hello/world");
}