port module CommandLine exposing (main)

import ElmCodeGenerator exposing (DecoderStyle)
import Platform exposing (Program)


type alias Id =
    String


type alias InputType =
    { id : String
    , json : String
    , namingStyle : String
    , decoderStyle : String
    , exposingSpec : String 
    }


type alias OutputType =
    { id : String
    , json : String
    , namingStyle : String
    , decoderStyle : String
    , exposingSpec : String 
    , error : String
    , output : ElmCodeGenerator.Output
    }


port input : (InputType -> msg) -> Sub msg


port output : OutputType -> Cmd msg


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    ()


type Msg
    = Input InputType


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


resultAsRecord :
    InputType
    -> Result String ElmCodeGenerator.Output
    -> OutputType
resultAsRecord { id, json, namingStyle, decoderStyle, exposingSpec } res =
    case res of
        Err err ->
            { id = id
            , json = json
            , namingStyle = namingStyle
            , decoderStyle = decoderStyle
            , exposingSpec = exposingSpec
            , error = err
            , output = { imports = [], types = [], decoders = [], encoders = [] }
            }

        Ok result ->
            { id = id, json = json, namingStyle = namingStyle, decoderStyle = decoderStyle, exposingSpec = exposingSpec, error = "", output = result }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input i ->
            let
                namingStyle =
                    case i.namingStyle of
                        "noun" ->
                            ElmCodeGenerator.NounNaming

                        _ ->
                            ElmCodeGenerator.VerbNaming

                exposingSpec = 
                    case i.exposingSpec of 
                        "all" -> 
                            ElmCodeGenerator.ExposingAll
                        _ -> 
                            ElmCodeGenerator.ExposingNone

                decoderStyle =
                    case i.decoderStyle of
                        "plain" ->
                            ElmCodeGenerator.PlainDecoders

                        "applicative" ->
                            ElmCodeGenerator.ApplicativeDecoders { importAlias = "Json.Decode.Extra", exposingSpec = exposingSpec }

                        _ ->
                            ElmCodeGenerator.PipelineDecoders { importAlias = "Json.Decode.Pipeline", exposingSpec = exposingSpec }

            in
            ( model
            , output
                (resultAsRecord i <|
                    ElmCodeGenerator.fromJsonSample
                        { rootTypeName = "Sample"
                        , decodeImport = { importAlias = "Json.Decode", exposingSpec = ElmCodeGenerator.ExposingNone }
                        , encodeImport = { importAlias = "Json.Encode", exposingSpec = exposingSpec }
                        , decoderStyle = decoderStyle
                        , namingStyle = namingStyle
                        }
                        i.json
                )
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    input Input
