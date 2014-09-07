module elasticsearch.transport.connections.selector;

import elasticsearch.transport.connections.collection;

/// Interface for connection selector implementations.
interface SelectorInterface {
	int select(Collection collection);
}

class RandomSelector : SelectorInterface {
	/// Returns a random connection from the collection.
	int select(Collection collection) {
		import std.random;

		Random gen;
		return uniform(0, cast(int)collection.length, gen);
	}
}

class RoundRobinSelector : SelectorInterface {
	private {
		int current;
	}

	/// Returns the next connection from the collection, rotating them in round-robin fashion.
	int select(Collection collection) {
		auto index = ++current;
		if(current >= collection.length) current = 0;
		return index;
	}
}