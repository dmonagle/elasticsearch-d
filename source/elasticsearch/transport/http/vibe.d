module elasticsearch.transport.http.vibe;

public import elasticsearch.transport.transport;
public import elasticsearch.transport.exceptions;
import elasticsearch.api.parameters;

import vibe.core.log;
import vibe.http.client;
import vibe.stream.operations;
import vibe.data.json;

alias VibeLogLevel = vibe.core.log.LogLevel;
alias ESLogLevel = elasticsearch.transport.transport.LogLevel;

HTTPMethod vibeTransportRequestMethod(RequestMethod method) {
	final switch(method) {
		case RequestMethod.HEAD: return HTTPMethod.HEAD;
		case RequestMethod.GET: return HTTPMethod.GET;
		case RequestMethod.POST: return HTTPMethod.POST;
		case RequestMethod.PUT: return HTTPMethod.PUT;
		case RequestMethod.DELETE: return HTTPMethod.DELETE;
	}
}

class VibeTransport : Transport {
override:
	protected void transportLog(ESLogLevel level, string message) {
		final switch(level) {
			case ESLogLevel.debug_: logDebug(message);
				break;
			case ESLogLevel.info: logInfo(message);
				break;
			case ESLogLevel.error: logError(message);
				break;
		}
		
	}
	
	@property string protocol() { return "http"; }
	
	Response performTransportRequest(Connection connection, RequestMethod method, string path, ESParams parameters, string requestBody = "") {		
		Response response;
		requestHTTP(connection.fullURL(path, parameters),
			(scope req) {
				req.method = vibeTransportRequestMethod(method);
				if (requestBody != "") {
					req.writeBody(cast(ubyte[])requestBody);
				}
				logDebugV("ES Transport Request: %s %s", method, path);
				if (requestBody.length) logTrace("ES Transport Request Body: \n%s", requestBody);
			},
			(scope res) {
				response.status = res.statusCode;
				response.headers = res.headers;
				if (method != RequestMethod.HEAD) {
					if (res.statusCode >= 200 && res.statusCode < 300) {
						auto responseBody = res.bodyReader.readAllUTF8();
						response.responseBody = responseBody;
					}
					else {
						switch(res.statusCode) {
							case(HTTPStatus.gatewayTimeout, HTTPStatus.requestTimeout): 
								throw new HostUnreachableException(connection);
							default: 
								auto responseBody = res.bodyReader.readAllUTF8();
								response.responseBody = responseBody;
								throw new RequestException(connection, method, path, parameters, requestBody, response);
						}
					}
				}
			}
			);
		
		return response;
	}
	
}
