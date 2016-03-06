/**
	* Defines the `ESParams` type for use in the API
	*
	* Copyright: © 2015 David Monagle
	* License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	* Authors: David Monagle
*/
module elasticsearch.api.parameters;

import vibe.utils.dictionarylist;
import elasticsearch.api.exceptions;
import core.exception;

import std.array;
import std.algorithm;
import std.string;

/// Common ES parameters
static enum ES_COMMON_PARAMETERS = [
	"ignore",
	//"index", "type", "id",
	//"body",
	"node_id",
	"name",
	"field"
];

/// Common ES parameters used in queries
static enum ES_COMMON_QUERY_PARAMETERS = [
	"format",
	"pretty",
	"human"
];

/// ESParams is just an alias for a vibe.d dictionary list
alias ESParams = vibe.inet.message.InetHeaderMap;

bool hasField(const ref ESParams p, string key) {
	return cast(bool)(key in p);
}

/// Filters the given `ESParams` to only include the given keys. Returns a new range containing the allowed keys
ESParams filterESParams(const ref ESParams p, string[] allowed ...) {
	import std.algorithm;

	ESParams returnParams;

	foreach(key, value; p) {
		if (allowed.canFind(key)) returnParams.addField(key, value);
	}

	return returnParams;
}

unittest {
	ESParams p;
	p["one"] = "Hello";
	p["two"] = "Goodbye";
	
	auto filtered = p.filterESParams("one");
	
	assert(filtered.hasField("one"));
	assert(!filtered.hasField("two"));
}

/// Returns the value of the supplied `ESParams ` or returns the defaultValue if it doesn't exist
T valueOrDefault(T)(ESParams p, string key, T defaultValue) {
	import std.conv;

	if (key !in p) return defaultValue;
	return p[key].to!T;
}

unittest {
	ESParams p;
	p["one"] = "1";

	assert(p.valueOrDefault("one", 2) == 1);
	assert(p.valueOrDefault("two", 2) == 2);
}

/// Throws an argument exception if the given parameter is not included in `p`
void enforceParameter(const ref ESParams p, string name) {
	enforce(p.hasField(name), new ArgumentException(p, name ~ " parameter is required"));
}

/// Sets a parameter to a default value if if does not exist
void defaultParameter(ref ESParams p, string name, string defaultValue) {
	if(!p.hasField(name)) p[name] = defaultValue;
}

/// Returns a new list of params which will only included common parameters plus those `allowed` passed in parameters
ESParams validateAndExtract(const ref ESParams params, string[] allowed ...) {
	return params.filterESParams(allowed ~ ES_COMMON_PARAMETERS ~ ES_COMMON_QUERY_PARAMETERS);
}

/// Escapes the given string for use with ES API
string esEscape(string value) {
	import std.uri;
	
	return encodeComponent(value);
}

/// Takes an array of strings representing a path and returns a clean path string
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
