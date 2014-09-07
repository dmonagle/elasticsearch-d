module elasticsearch.transport.connections.collection;

public import elasticsearch.transport.connections.connection;
public import elasticsearch.transport.connections.selector;

import std.algorithm;
import std.array;

class Collection {
	private {
		Connection[] _connections;
		SelectorInterface _selector;
	}

	this() {
		_selector = new RandomSelector();
	}
	
	this(SelectorType)() {
		_selector = new SelectorType();
	}
	
	/// Returns an Array of all connections, both dead and alive
	ref Connection[] all() {
		return _connections;
	}

	/// Returns an Array of alive connections.
	Connection[] alive() {
		return array(_connections.filter!((connection) => !connection.dead));
	}

	/// Returns an Array of dead connections.
	Connection[] dead() {
		return array(_connections.filter!((connection) => connection.dead));
	}

	/**
	* Returns a connection.
	*
	* If there are no alive connections, resurrects a connection with least failures.
	* Delegates to selector's `*select` method to get the connection.
	*
	*/
	Connection getConnection() {
		if (all.length == 0) return null;

		if (alive.length == 0) {
			auto sortedDead = array(dead.sort!((a, b) => a.deadSince < b.deadSince)());
			sortedDead[0].makeAlive();
		}

		return alive[_selector.select(this)];
	}

	/// By default this returns an array of all the alive connections
	alias alive this;
}

unittest {
	auto c = new Collection();
}