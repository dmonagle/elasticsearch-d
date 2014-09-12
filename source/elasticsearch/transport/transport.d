module elasticsearch.transport.transport;

import std.string;
import vibe.data.json;
public import elasticsearch.transport.response;
public import elasticsearch.transport.connections.collection;

import elasticsearch.transport.connections.collection;
import elasticsearch.transport.exceptions;
import elasticsearch.parameters;
import elasticsearch.transport.sniffer;

enum RequestMethod {
	HEAD,
	GET,
	POST,
	PUT,
	DELETE
}

struct Host {
	string hostName = "localhost";
	int port = 9200;
	string protocol = "http";
	string path;
	string user;
	string password;

	@property string url() {
		auto urlString = protocol ~ "://";
		if (user.length) urlString ~= user ~ ":" ~ password ~ "@";
		urlString ~= hostName ~ ":" ~ to!string(port);
		if(path.length) urlString ~= path;

		return urlString;
	}
}

enum LogLevel {
	debug_,
	info,
	error
}

class Transport {
	private {
		Host[] _hosts;
		Host[] _activeHosts;

		//int _snifferTimeout = 1; # TODO: Implement sniffer timeout
		Collection _connections;
		bool _reloadOnFailure = true;

		int _reloadAfter = 10_000; // Requests
		int _resurrectAfter = 60;  // Seconds
		int _maxRetries = 3; // Requests

		int connectionCounter;
	}  

	protected { 
		abstract Response performTransportRequest(Connection connection, RequestMethod method, string path, Parameters parameters = Parameters(), string requestBody = "");
		abstract void transportLog(LogLevel level, string message);
	}

	this() {
	}

	abstract @property string protocol();
	@property ref Host[] hosts() { return _hosts; }
	//@property ref int snifferTimeout() { return _snifferTimeout; }

	protected Collection buildConnections() {
		auto collection = new Collection();
		foreach(host; _hosts) {
			collection.all ~= new Connection(host, this);
		}

		return collection;
	}

	/// Returns a connection from the connection pool by delegating to Collection.
	///
	/// Resurrects dead connection if the `resurrect_after` timeout has passed.
	/// Increments the counter and performs connection reloading if the `reload_connections` option is set.
	///
	/// @return [Connections::Connection]
	/// @see    Connections::Collection///get_connection
	///
	Connection getConnection() {
		if (!_connections) _connections = buildConnections();
		// Resurrect dead connections here
		auto connection = _connections.getConnection();
		connectionCounter++;
		if (_reloadAfter && !(connectionCounter %_reloadAfter)) reloadConnections();

		return connection;
	}

	/// Reloads and replaces the connection collection based on cluster information.
	/// 
	void reloadConnections() {
		auto sniffer = new Sniffer(this);

		transportLog(LogLevel.info, "Reloading connections");
		auto hosts = sniffer.hosts;
		if (hosts.length) {
			transportLog(LogLevel.info, format("Sniffer found %s hosts", hosts.length));
			_hosts = hosts;
		}
		rebuildConnections();
	}

	/// Tries to "resurrect" all eligible dead connections.
	///
	/// @see Connections::Connection///resurrect!
	/// 
	void resurrectDeadConnections() {
		foreach(connection; _connections.dead) {
			connection.resurrect;
		}
	}

	/// Replaces the connections collection
	/// 
	private void rebuildConnections() {
		_connections = buildConnections;
	}

	Response performRequest(RequestMethod method, string path, Parameters parameters = Parameters(), string requestBody = "") {
		// TODO: Make this more like the official method where it logs failures and automatically reloads connections on failure etc...
		int tries;
		bool success;

		Response response;
		auto c = getConnection();

		assert(c);

		try {
			response = performTransportRequest(c, method, path, parameters, requestBody);
		}
		catch (HostUnreachableException exception) {
			transportLog(LogLevel.error, exception.msg);
			exception.connection.makeDead();
		}
		catch (RequestException exception) {
			transportLog(LogLevel.error, exception.msg);
		}
		catch (Exception exception) {
			transportLog(LogLevel.error, exception.msg);
			transportLog(LogLevel.error, method.to!string ~ " " ~ c.fullURL(path, parameters));
			transportLog(LogLevel.error, requestBody);
		}

		return response;
	}
}

