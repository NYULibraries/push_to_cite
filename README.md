# PushToCite

This is a microservice that fetches the metadata for a given record from a calling system (i.e. Exlibris Primo) and forwards it on to a citation management service (i.e. [ExportCitations](https://github.com/NYULibraries/export_citations)).

## Usage

### Example
```
GET /?local_id=lcn12345&calling_system=primo&cite_to=ris&institution=NYU
```

### Parameters

The only interface with this API is a `GET` request with the following params (**all params are required**):

|name|usage|
|----|-----|
| `local_id` | the id of the document as it's identified in the calling system |
| `calling_system` | the name of the calling system to call for getting more record data. currently only supports `primo` |
| `cite_to` | the destination format or service. supports: `endnote`, `refworks`, `ris`, `bibtex`, `easybibpush` |
| `institution` | the name of the institution in the calling system, e.g. `NYU` |
