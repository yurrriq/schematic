module JsonSchemaSpec (spec, main) where

import Data.Aeson as J
import Data.Proxy
import Data.Schematic
import Data.Vinyl
import JSONSchema.Draft4 as D4
import Test.Hspec


type ArraySchema = 'SchemaArray '[ 'AEq 1] ('SchemaNumber '[ 'NGt 10])

type ArrayField = '("foo", ArraySchema)

type FieldsSchema =
  '[ ArrayField, '("bar", 'SchemaOptional ('SchemaText '[ 'TEnum '["foo", "bar"]]))]

type SchemaExample = 'SchemaObject FieldsSchema

arrayData :: JsonRepr ArraySchema
arrayData = ReprArray [ReprNumber 13]

arrayField :: FieldRepr ArrayField
arrayField = FieldRepr arrayData

objectData :: Rec FieldRepr FieldsSchema
objectData = FieldRepr arrayData
  :& FieldRepr (ReprOptional (Just (ReprText "foo")))
  :& RNil

exampleData :: JsonRepr SchemaExample
exampleData = ReprObject objectData

spec :: Spec
spec = do
  it "validates simple schema" $ do
    let schema = D4.SchemaWithURI (toJsonSchema (Proxy @SchemaExample)) Nothing
    fetchHTTPAndValidate schema (toJSON exampleData) >>= \case
      Left _ -> fail "failed to validate test example"
      Right _ -> pure ()

main :: IO ()
main = hspec spec
