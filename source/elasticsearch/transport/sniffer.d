module elasticsearch.transport.sniffer;

import elasticsearch.transport.transport;

import std.regex;

class Sniffer {
	static regexURL = ctRegex!`\/([^:]*):([0-9]+)\]`;

	private {
		Transport _transport;
	}

	this(Transport t) {
		_transport = t;
	}

	@property Host[] hosts() {
		import std.conv;
		Host[] returnHosts;

		auto nodes = _transport.performRequest(RequestMethod.GET, "_nodes/http").jsonBody;
		foreach(string id, info; nodes["nodes"]) {
			auto key = _transport.protocol ~ "_address";
			if (key in info) {
				auto address = info[key].to!string;
				auto matches = matchFirst(address, regexURL);
				if (matches) {
					returnHosts ~= Host(matches[1], matches[2].to!int, _transport.protocol);
				}
			}
		}

		return returnHosts;
	}
}

unittest {
	import std.exception;
	import elasticsearch.transport.http.vibe;
	
	auto host = Host("localhost");
	auto t = new VibeTransport();
	t.hosts ~= host;
	t.hosts ~= Host();

	auto sniffer = new Sniffer(t);

	auto hosts = sniffer.hosts();

	assert(hosts.length == 1);
	assert(host.hostName == "localhost");
	assert(host.port == 9200);
}
