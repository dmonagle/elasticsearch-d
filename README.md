elasticsearch-d
===============

elasticsearch-d is a package modeled on the official Elasticsearch ruby client
library. This one package contains both the transport and api packages.

While currently incomplete in terms of the API, the majority of the work has
been done on the transport making most API implmentations trivial. Most API
implementations just need a D function defined to take in the required
parameters and pass them through to the transport layers.

While this package definitely needs more work, it seems very stable using the
APIs that have been written so far.  The APIs currently being used the mostly
straightforward indices and base APIs.

This package also currently relies on vibe.d. Although it's quite possible with
more work that this could be optional and a curl transport could be developed,
the only functioning transport at this point is called VibeTransport. Also the
package relies rather heavily on vibe.data.json (which could be replaced in
future with [a new phobos JSON
candidate](https://github.com/s-ludwig/std_data_json) Finally elasticsearch-d
also relies on the DictionaryList defined in vibe.d, because it was outside of
the scope of the project to rewrite something like this.

I tried to make the API work exactly the same as the Ruby api, but although the
overall design of the transport side of things should be able to remain
consitent with the official packages, the API needs some more thought. Ruby
allows named parameters in the form of a hash whereas there is no such thing in
D. Elasticsearch endpoints can take a large number of optional parameters so a
more elegant solution is required.

Because of all of this, I expect there will be breaking changes as I continue
to keep it inline with elasticsearch development, as well as vibe.d and other
packages. For the moment though, it works well with the implemented APIs.

## Quick example

```D
void  main()
{
    import std.stdio;

    import vibe.d;
    import elasticsearch.client;
    import elasticsearch.api.parameters;
    import elasticsearch.api.actions.indices;

    enum testIndex = "es_test_index";

    auto host = Host();
    host.user = "elastic";
    host.password = "changeme";

    auto client = new Client(host);

    Response r;

    ESParams p;
    p.addField("index", testIndex);
    p.addField("body", `
        {
            "settings": {
                "index": {
                    "number_of_shards": 1,
                    "number_of_replicas": 0
                }
            },
            "mappings": {
                "user": {
                    "properties": {
                        "name": { "type": "string" }
                    }
                }
            }
        }
    `);
    r = client.createIndex(p);

    auto user = Json.emptyObject;
    user["name"] = "Ginny";
    r = client.index(testIndex, "user", "1024", user.toString);
    enforce(r.status / 100 == 2, "Operation didn't succeed:: " ~ r.responseBody);

    user["name"] = "Bob";
    r = client.index(testIndex, "user", "1025", user.toString);
    enforce(r.status / 100 == 2, "Operation didn't succeed:: " ~ r.responseBody);

    user["name"] = "Sue";
    r = client.index(testIndex, "user", "1026", user.toString);
    enforce(r.status / 100 == 2, "Operation didn't succeed:: " ~ r.responseBody);

    auto search = Json.emptyObject;

    ESParams searchParams;
    searchParams["index"] = testIndex;
    searchParams["body"] = `{ "query": { "match_all": {} } }`;

    import core.thread : Thread;
    import std.datetime : seconds;

    "sleeping until expected ready".writeln;
    Thread.sleep(10.seconds);

    auto result = client.search(searchParams);

    writeln((result.status / 100 == 2) ? "success" : "failure");

    if(result.bodyIsJson)
        result.jsonBody.toPrettyString.writeln;
}
```
