This package helps generate Elm JSON decoders and encoders from a JSON sample.

The package provides a single function, `fromJsonSample`, which generates Elm code defining 
imports, types, decoders, and encoders from a supplied JSON sample: 

```
ElmCodeGenerator.fromJsonSample
    { rootTypeName = topLevelTypeName
    , decodeImport = { importAlias = "Json.Decode", exposingSpec = ElmCodeGenerator.ExposingNone }
    , encodeImport = { importAlias = "Json.Encode", exposingSpec = ElmCodeGenerator.ExposingNone }
    , decoderStyle = ElmCodeGenerator.PlainDecoders
    , namingStyle = ElmCodeGenerator.NounNaming
    }
    "{"a": 1, "b": "str"}"
```