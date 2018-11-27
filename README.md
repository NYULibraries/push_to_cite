# PushToCite

[![CircleCI](https://circleci.com/gh/NYULibraries/push_to_cite.svg?style=svg)](https://circleci.com/gh/NYULibraries/push_to_cite)
[![Coverage Status](https://coveralls.io/repos/github/NYULibraries/push_to_cite/badge.svg?branch=master)](https://coveralls.io/github/NYULibraries/push_to_cite?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/d877057903a687d5ac36/maintainability)](https://codeclimate.com/github/NYULibraries/push_to_cite/maintainability)
[![Anchore Image Overview](https://anchore.io/service/badges/image/bf11bfdf428b679b28ae99fa6be65de1071bfcb15ffdbc677b81d075fdc3607b)](https://anchore.io/image/dockerhub/nyulibraries%2Fpushtocite%3Amaster)
[![Anchore Image Policy](https://anchore.io/service/badges/policy/bf11bfdf428b679b28ae99fa6be65de1071bfcb15ffdbc677b81d075fdc3607b?registry=dockerhub&repository=nyulibraries/pushtocite&tag=master)](https://anchore.io)

This is a microservice that fetches the metadata for a given record from a calling system (i.e. Exlibris Primo) and forwards it on to a citation management service.

## Usage

### `GET /:external_id`

#### Example

```
curl http://localhost:9292/lcn12345?calling_system=primo&cite_to=ris&institution=NYU
```

#### Parameters

The only interface with this API is a `GET` request with the following params (**all params are required**):

|name|usage|default|
|----|-----|-------|
| `calling_system` | the name of the calling system to call for getting more record data. currently only supports `primo` | primo |
| `cite_to` | the destination format or service. supports: `endnote`, `refworks`, `ris`, `bibtex` | N/A |
| `institution` | the name of the institution in the calling system, e.g. `NYU` | NYU |

### `POST /batch`

```
curl -X POST http://localhost:9292/ -d "external_id[]=nyu_aleph005399773&external_id[]=nyu_aleph000802014&calling_system=primo&institution=NYU&cite_to=ris"
```

#### Parameters

The only interface with this API is a `GET` request with the following params (**all params are required**):

|name|usage|default|
|----|-----|-------|
| `external_id` | an array of local IDs in the calling system for export.  | N/A |
| `calling_system` | the name of the calling system to call for getting more record data. currently only supports `primo` | primo |
| `cite_to` | the destination format or service. supports: `endnote`, `refworks`, `ris`, `bibtex` | N/A |
| `institution` | the name of the institution in the calling system, e.g. `NYU` | NYU |

## Citation Data Viewer

This tool includes a citation viewer for metadata managers and users to have more transparency around what conversions are happening from source to citations.

## Usage

### `GET /m/:external_id`

#### Example
```
curl http://localhost:9292/m/lcn12345?calling_system=primo&cite_to=ris&institution=NYU
```

#### Parameters

This view is just a passive wrapper around the API above and so the params are the same.
