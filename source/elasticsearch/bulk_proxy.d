module elasticsearch.bulk_proxy;

import vibe.data.json;
import elasticsearch.client;

static const uint ESBulkUploadThreshold = 12_000_000;


/// Contains a buffer that automatically flushes and calls a specified action when the size hits the given
/// threshold.
struct EsBulkProxy {
	Client client;
	ulong threshold = ESBulkUploadThreshold;

	string buffer;
	
	void flush() {
		if (buffer.length == 0) return;
		if (buffer[$ -1] != '\n') buffer ~= "\n";
		client.bulk(buffer);
		buffer = "";
	}
	
	void append(string input) {
		if (input.length > threshold) threshold = input.length; // If a single input doesn't fit within the threshold, expand the threshold to allow it
		if ((threshold - buffer.length) > input.length) flush; // Flush the buffer if the input doesn't fit
		buffer ~= input;
	}
	
	void appendIndex(string id, string index, string type, string data) {
		string actionString;
		if (data[$ -1] != '\n') data ~= "\n";
		actionString = `{"create":{"_index":"` ~ index ~ `","_type":"` ~ type ~ `","_id":"` ~ id ~ `"}}` ~ "\n";
		actionString ~= data;
		append(actionString);
	}
	
	void appendIndex(string id, string index, string type, Json record) {
		appendIndex(id, index, type, record.toString);
	}
	
	alias buffer this;
}

