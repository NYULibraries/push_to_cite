# PushToCite

[![CircleCI](https://circleci.com/gh/NYULibraries/push_to_cite.svg?style=svg)](https://circleci.com/gh/NYULibraries/push_to_cite)
[![Coverage Status](https://coveralls.io/repos/github/NYULibraries/push_to_cite/badge.svg?branch=master)](https://coveralls.io/github/NYULibraries/push_to_cite?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/d877057903a687d5ac36/maintainability)](https://codeclimate.com/github/NYULibraries/push_to_cite/maintainability)
[![Anchore Image Overview](https://anchore.io/service/badges/image/bf11bfdf428b679b28ae99fa6be65de1071bfcb15ffdbc677b81d075fdc3607b)](https://anchore.io/image/dockerhub/nyulibraries%2Fpushtocite%3Amaster)
[![Anchore Image Policy](https://anchore.io/service/badges/policy/bf11bfdf428b679b28ae99fa6be65de1071bfcb15ffdbc677b81d075fdc3607b?registry=dockerhub&repository=nyulibraries/pushtocite&tag=master)](https://anchore.io)

This is a microservice that fetches the metadata for a given record from a calling system (i.e. Exlibris Primo) and forwards it on to a citation management service.

## Usage

### `GET /`

#### Example

```
curl http://localhost:9292/lcn12345?cite_to=ris
# OR specifying non-default values
curl http://localhost:9292/lcn12345?calling_system=primo&cite_to=ris&institution=NYU
# OR batch get up to 10 records
curl http://localhost:9292/?external_id[]=nyu_aleph005399773&external_id[]=nyu_aleph000802014&calling_system=primo&institution=NYU&cite_to=ris"
```

#### Parameters

The only interface with this API is a `GET` request with the following params (**all params are required**):

|name|usage|default|
|----|-----|-------|
| `external_id` | an array of local IDs in the calling system for export. limit of 10 at a time. | N/A |
| `calling_system` | the name of the calling system to call for getting more record data. currently only supports `primo` | primo |
| `cite_to` | the destination format or service. supports: `endnote`, `refworks`, `ris`, `bibtex`, `openurl`, `json` | N/A |
| `institution` | the name of the institution in the calling system, e.g. `NYU` | NYU |

### Get Citation Objects as JSON

Setting `cite_to=json` will return the objects as raw JSON.

#### Example

```
curl http://localhost:9292/?external_id[]=nyu_aleph005399773&external_id[]=nyu_aleph000802014&cite_to=json
```

##### Reponse

```json
{
  "nyu_aleph005399773": {
    "itemType": "audioRecording",
    "author": "Thelonious Monk Quintet, performer",
    "contributor": "Monk, Thelonious, performer",
    "publisher": "Prestige Records",
    "place": "Berkeley, CA",
    "title": "Monk",
    "date": "1982",
    "language": "und",
    "tags": "Jazz",
    "pnxRecordId": "nyu_aleph005399773",
    "description": [
      "We see (5:13) -- Smoke gets in your eyes (4:30) -- Locomotive (6:20) -- Hackensack (5:10) -- Let's call this (4:58) -- Think of one (take 2) (5:40) -- Think of one (take 1) (5:36).",
      "Thelonious Monk, piano ; Frank Foster, tenor sax (1st 4 works) ; Ray Copeland, trumpet (1st 4 works) ; Curly Russell, bass (1st 4 works) ; Art Blakey, drums (1st 4 works) ; Sonny Rollins, tenor sax (last 3 works) ; Julius Watkins, french horn (last 3 works) ; Percy Heath, bass (last 3 works) ; Willie Jones, drums (last 3 works)."
    ],
    "importedFrom": "PNX_JSON"
  },
  "nyu_aleph000802014": {
    "itemType": "book",
    "author": "Gilroy, Beryl",
    "publisher": "Peepal Tree",
    "place": "Leeds, England",
    "isbn": [
      "1900715473",
      "9781900715478"
    ],
    "title": "The green grass tango",
    "date": "2001",
    "language": "eng",
    "tags": [
      "Dogs–Fiction",
      "Human-animal relationships in literature"
    ],
    "pnxRecordId": "nyu_aleph000802014",
    "importedFrom": "PNX_JSON"
  }
}
```

### `GET /openurl/:external_id`

#### Example

```
curl http://localhost:9292/openurl/nyu_aleph000802014?cite_to=json
```

##### Response

```json
{
  "openurl": "https://qa.getit.library.nyu.edu/resolve?&ctx_ver=Z39.88-2004&ctx_enc=info:ofi/enc:UTF-8&ctx_tim=2018-11-28T17%3A00%3A16IST&url_ver=Z39.88-2004&url_ctx_fmt=infofi/fmt:kev:mtx:ctx&rfr_id=info:sid/primo.exlibrisgroup.com:primo-nyu_aleph000802014&rft_val_fmt=info:ofi/fmt:kev:mtx:book&rft.genre=book&rft.jtitle=&rft.btitle=The%20green%20grass%20tango&rft.aulast=Gilroy&rft.aufirst=Beryl.&rft.auinit=&rft.auinit1=&rft.auinitm=&rft.ausuffix=&rft.au=Gilroy,%20Beryl&rft.aucorp=&rft.volume=&rft.issue=&rft.part=&rft.quarter=&rft.ssn=&rft.spage=&rft.epage=&rft.pages=&rft.artnum=&rft.pub=Peepal%20Tree&rft.place=Leeds,%20England&rft.issn=&rft.eissn=&rft.isbn=1900715473&rft.sici=&rft.coden=&rft_id=info:doi/&rft.object_id=&rft.primo=nyu_aleph000802014&rft.eisbn=&rft_dat=%3Cnyu_aleph%3E000802014%3C/nyu_aleph%3E%3Cgrp_id%3E362421894%3C/grp_id%3E%3Coa%3E%3C/oa%3E%3Curl%3E%3C/url%3E&rft_id=info:oai/&req.language=eng"
}
```

## Citation Data Viewer

This tool includes a citation viewer for metadata managers and users to have more transparency around what conversions are happening from source to citations.

## Usage

### `GET /m`

#### Example

```
curl http://localhost:9292/m?calling_system=primo&cite_to=ris&institution=NYU&external_id=lcn12345
```

#### Parameters

This view is just a wrapper around the API above and so the params are the same.
