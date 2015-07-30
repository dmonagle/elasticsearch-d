module elasticsearch.transport.connections.connection;

import elasticsearch.transport.transport;
import elasticsearch.parameters;
import std.datetime;

/**
 * Wraps the connection information and logic.
 * 
 * The Connection instance wraps the host information (hostname, port, attributes, etc),
 * as well as the "session" (a transport client object, such as a {elasticsearch.transport.http.vibe} instance).
 *
 * It provides methods to construct and properly encode the URLs and paths for passing them
 * to the transport client object.
 *
 * It provides methods to handle connection lifecycle (dead, alive, healthy).
 */

class Connection {
	package {
		Host _host;
		Transport _connection;
		int _resurrectTimeout = 60; // Seconds
		int _failures = 0;
		bool _dead = false;
		SysTime _deadSince;

	}

	this(Host host, Transport connection, int resurrectTimeout = 60) {
		_host = host;
		_connection = connection;
	}

	@property Host host() { return _host; }
	@property ref int resurrectTimeout() { return _resurrectTimeout; }
	@property bool dead() { return _dead; }
	@property SysTime deadSince() { return _deadSince; }
	@property bool alive() { return !_dead; }
	@property int failures() { return _failures; }
	@property bool resurrectable() {
		import std.math;
		return Clock.currTime > (_deadSince + dur!"seconds"(_resurrectTimeout * pow(2, _failures - 1)));
	}
	
	/**
	 * Marks this connection as dead, incrementing the `failures` counter and
	 * storing the current time as `dead_since`.
	 */
	Connection makeDead() { 
		_dead = true;
		_failures++;
		_deadSince = Clock.currTime;
		return this;
	}

	/// Marks this connection as alive, ie. it is eligible to be returned from the pool by the selector.
	Connection makeAlive() {
		_dead = false;
		return this;
	}

	/// Marks this connection as healthy, ie. a request has been successfully performed with it.
	Connection makeHealthy() {
		makeAlive();
		_failures = 0;
		return this;
	}

	/// Marks this connection as alive, if the required timeout has passed.
	Connection resurrect() {
		if (resurrectable) makeAlive();
		return this;
	}

	/// Returns the complete endpoint URL with host, port, path and serialized parameters.
	string fullURL(string path, Parameters params) {
		import std.conv;

		auto url = host.url;
		url ~= "/" ~ fullPath(path, params);

		return url;
	}

	string fullPath(string path, Parameters params) {
		import std.array;
		import std.uri;

		auto returnPath = path;

		if (params.length) {
			string[] paramArray;

			foreach(key, value; params)
				paramArray ~= encodeComponent(key) ~ "=" ~ encodeComponent(value);
			returnPath ~= "?" ~ join(paramArray, "&");
		}

		return returnPath;
	}

	override string toString() {
		auto returnString = "<Connection host: " ~ _host.hostName;
		returnString ~= " " ~ (_dead ? ("dead since " ~ _deadSince.toString()) : "alive");
		returnString ~= ">";
		return returnString;
	}
}

unittest {
	import elasticsearch.transport.http.vibe;

	auto host = Host();
	auto c = new Connection(host, new VibeTransport());

	assert(c.alive);
	assert(c.makeDead.dead);
	assert(c.failures == 1);
	assert(!c.resurrectable);
	assert(c.resurrect.dead);
	c._deadSince = Clock.currTime - dur!"minutes"(2);
	assert(c.resurrectable);
	assert(c.resurrect.alive);
	assert(c.failures == 1);
	assert(c.makeHealthy.failures == 0);
}