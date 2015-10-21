/**
	* Elasticsearch Response
	*
	* Copyright: © 2015 David Monagle
	* License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	* Authors: David Monagle
*/

module elasticsearch.transport.response;

import elasticsearch.api.parameters;
import std.regex;

import vibe.data.json;


/// Response structure for Elasticsearch requests
struct Response {
	private static auto JsonRegex = ctRegex!(`json`, "i");
	int status; // Response status code
	string responseBody; // Response body
	ESParams headers; // Response headers

	/// Returns true if the reponse body is JSON
	@property bool bodyIsJson() {
		return cast(bool)matchFirst(headers.get("content-type"), JsonRegex);
	}

	/// Parses and returns a `Json` object from the response body
	@property Json jsonBody() {
		return parseJsonString(responseBody);
	}
}
