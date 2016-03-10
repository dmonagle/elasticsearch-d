module elasticsearch.api.filters;

import vibe.data.json;

/// Filters Elasticsearch reserved field names from the given json 
static void ES_FilterReservedFieldNames(ref Json json) {
    enum reservedAttributes = ["_type", "_id"];
    foreach(a; reservedAttributes) json.remove(a);
}

unittest {
    auto json = ["_id": "test", "_type": "blah", "okay": "value"].serializeToJson;
    assert(json.length == 3);
    ES_FilterReservedFieldNames(json);
    assert(json.length == 1);
    assert(json["okay"].type == Json.Type.string);
}

