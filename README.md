# PushToCite

This is a microservice that fetches the metadata for a given record from a calling system (i.e. Exlibris Primo) and forwards it on to a citation management service.

## Usage `GET /:local_id`

### Example
```
GET /lcn12345?calling_system=primo&cite_to=ris&institution=NYU
```

### Parameters

The only interface with this API is a `GET` request with the following params (**all params are required**):

|name|usage|
|----|-----|
| `calling_system` | the name of the calling system to call for getting more record data. currently only supports `primo` |
| `cite_to` | the destination format or service. supports: `endnote`, `refworks`, `ris`, `bibtex` |
| `institution` | the name of the institution in the calling system, e.g. `NYU` |

## Citation Data Viewer

This tool includes a citation viewer for metadata managers and users to have more transparency around what conversions are happening from source to citations.

## Usage `GET /m/:local_id`

### Example
```
GET /m/lcn12345?calling_system=primo&cite_to=ris&institution=NYU
```

### Parameters

This view is just a passive wrapper around the API above and so the params are the same
