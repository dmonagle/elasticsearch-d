module elasticsearch.parameters;

import vibe.utils.dictionarylist;

alias Parameters = DictionaryList!(string, false);

bool hasField(const ref Parameters p, string key) {
	return cast(bool)(key in p);
}

Parameters filterParameters(const ref Parameters p, string[] allowed ...) {
	import std.algorithm;

	Parameters returnParams;

	foreach(key, value; p) {
		if (allowed.canFind(key)) returnParams.addField(key, value);
	}

	return returnParams;
}

unittest {
	Parameters p;
	p["one"] = "Hello";
	p["two"] = "Goodbye";
	
	auto filtered = p.filterParameters("one");
	
	assert(filtered.hasField("one"));
	assert(!filtered.hasField("two"));
}

T valueOrDefault(T)(Parameters p, string key, T defaultValue) {
	import std.conv;

	if (key !in p) return defaultValue;
	return p[key].to!T;
}

unittest {
	Parameters p;
	p["one"] = "1";

	assert(p.valueOrDefault("one", 2) == 1);
	assert(p.valueOrDefault("two", 2) == 2);
}