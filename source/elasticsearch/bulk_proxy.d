module elasticsearch.bulk_proxy;

import elasticsearch.client;
import vibe.data.json;
import vibe.core.log;

static const uint ESBulkUploadThreshold = 12_000_000;


/// Contains a buffer that automatically flushes and calls a specified action when the size hits the given
/// threshold.
struct EsBulkProxy {
	Client client;
	ulong threshold = ESBulkUploadThreshold;
	ulong recordCount;

	string buffer;
	
	void flush() {
		logDebug("Flushing Elasticsearch bulk proxy: %s records, %s bytes", recordCount, buffer.length);
		if (buffer.length == 0) return;
		if (buffer[$ -1] != '\n') buffer ~= "\n";
		auto response = client.bulk(buffer);
		buffer = "";
		recordCount = 0;
	}
	
	void append(string input) {
		if (input.length > threshold) threshold = input.length; // If a single input doesn't fit within the threshold, expand the threshold to allow it
		if (input.length > (threshold - buffer.length)) flush; // Flush the buffer if the input doesn't fit
		buffer ~= input;
		++recordCount;
	}

	void appendAction(string index, string method, string type, string id, string data) {
		string actionString;
		if (data[$ -1] != '\n') data ~= "\n";
		actionString = `{"` ~ method ~ `":{"_index":"` ~ index ~ `","_type":"` ~ type ~ `","_id":"` ~ id ~ `"}}` ~ "\n";
		actionString ~= data;
		append(actionString);
	}
	
	void appendIndex(string index, string type, string id, string data) {
		appendAction(index, "update", type, id, data);
	}
	
	void appendIndex(string index, string type, string id, Json record) {
		appendIndex(index, type, id, record.toString);
	}
	
	alias buffer this;
}

