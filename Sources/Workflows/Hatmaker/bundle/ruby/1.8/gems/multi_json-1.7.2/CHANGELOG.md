1.7.2
-----
* [Renamed Jrjackson adapter to JrJackson](https://github.com/intridea/multi_json/commit/b36dc915fc0e6548cbad06b5db6f520e040c9c8b)
* [Implemented jrjackson -> jr_jackson alias for back-compatability](https://github.com/intridea/multi_json/commit/aa50ab8b7bb646b8b75d5d65dfeadae8248a4f10)
* [Update vendored OkJson module](https://github.com/intridea/multi_json/commit/30a3f474e17dd86a697c3fab04f468d1a4fd69d7)

1.7.1
-----
* [Fix capitalization of JrJackson class](https://github.com/intridea/multi_json/commit/5373a5e38c647f02427a0477cb8e0e0dafad1b8d)

1.7.0
-----
* [Add load_options/dump_options to MultiJson](https://github.com/intridea/multi_json/commit/a153956be6b0df06ea1705ce3c1ff0b5b0e27ea5)
* [MultiJson does not modify arguments](https://github.com/intridea/multi_json/commit/58525b01c4c2f6635ba2ac13d6fd987b79f3962f)
* [Enable quirks_mode by default for json_gem/json_pure adapters](https://github.com/intridea/multi_json/commit/1fd4e6635c436515b7d7d5a0bee4548de8571520)
* [Add JrJackson adapter](https://github.com/intridea/multi_json/commit/4dd86fa96300aaaf6d762578b9b31ea82adb056d)
* [Raise ArgumentError on bad adapter input](https://github.com/intridea/multi_json/commit/911a3756bdff2cb5ac06497da3fa3e72199cb7ad)

1.6.1
-----
* [Revert "Use JSON.generate instead of #to_json"](https://github.com/intridea/multi_json/issues/86)

1.6.0
-----
* [Add gson.rb support](https://github.com/intridea/multi_json/pull/71)
* [Add MultiJson.default_options](https://github.com/intridea/multi_json/pull/70)
* [Add MultiJson.with_adapter](https://github.com/intridea/multi_json/pull/67)
* [Stringify all possible keys for ok_json](https://github.com/intridea/multi_json/pull/66)
* [Use JSON.generate instead of #to_json](https://github.com/intridea/multi_json/issues/73)
* [Alias `MultiJson::DecodeError` to `MultiJson::LoadError`](https://github.com/intridea/multi_json/pull/79)

1.5.1
-----
* [Do not allow Oj or JSON to create symbols by searching for classes](https://github.com/intridea/multi_json/commit/193e28cf4dc61b6e7b7b7d80f06f74c76df65c41)

1.5.0
-----
* [Add `MultiJson.with_adapter` method](https://github.com/intridea/multi_json/commit/d14c5d28cae96557a0421298621b9499e1f28104)
* [Stringify all possible keys for `ok_json`](https://github.com/intridea/multi_json/commit/73998074058e1e58c557ffa7b9541d486d6041fa)

1.4.0
-----
* [Allow `load`/`dump` of JSON fragments](https://github.com/intridea/multi_json/commit/707aae7d48d39c85b38febbd2c210ba87f6e4a36)

1.3.7
-----
* [Fix rescue clause for MagLev](https://github.com/intridea/multi_json/commit/39abdf50199828c50e85b2ce8f8ba31fcbbc9332)
* [Remove unnecessary check for string version of options key](https://github.com/intridea/multi_json/commit/660101b70e962b3c007d0b90d45944fa47d13ec4)
* [Explicitly set default adapter when adapter is set to `nil` or `false`](https://github.com/intridea/multi_json/commit/a9e587d5a63eafb4baee9fb211265e4dd96a26bc)
* [Fix Oj `ParseError` mapping for Oj 1.4.0](https://github.com/intridea/multi_json/commit/7d9045338cc9029401c16f3c409d54ce97f275e2)

1.3.6
-----
* [Allow adapter-specific options to be passed through to Oj](https://github.com/intridea/multi_json/commit/d0e5feeebcba0bc69400dd203a295f5c30971223)

1.3.5
-----
* [Add pretty support to Oj adapter](https://github.com/intridea/multi_json/commit/0c8f75f03020c53bcf4c6be258faf433d24b2c2b)

1.3.4
-----
* [Use `class << self` instead of `module_function` to create aliases](https://github.com/intridea/multi_json/commit/ba1451c4c48baa297e049889be241a424cb05980)

1.3.3
-----
* [Remove deprecation warnings](https://github.com/intridea/multi_json/commit/36b524e71544eb0186826a891bcc03b2820a008f)

1.3.2
-----
* [Add ability to use adapter per call](https://github.com/intridea/multi_json/commit/106bbec469d5d0a832bfa31fffcb8c0f0cdc9bd3)
* [Add and deprecate `default_engine` method](https://github.com/intridea/multi_json/commit/fc3df0c7a3e2ab9ce0c2c7e7617a4da97dd13f6e)

1.3.1
-----
* [Only warn once for each instance a deprecated method is called](https://github.com/intridea/multi_json/commit/e21d6eb7da74b3f283995c1d27d5880e75f0ae84)

1.3.0
-----
* [Implement `load`/`dump`; deprecate `decode`/`encode`](https://github.com/intridea/multi_json/commit/e90fd6cb1b0293eb0c73c2f4eb0f7a1764370216)
* [Rename engines to adapters](https://github.com/intridea/multi_json/commit/ae7fd144a7949a9c221dcaa446196ec23db908df)

1.2.0
-----
* [Add support for Oj](https://github.com/intridea/multi_json/commit/acd06b233edabe6c44f226873db7b49dab560c60)

1.1.0
-----
* [`NSJSONSerialization` support for MacRuby](https://github.com/intridea/multi_json/commit/f862e2fc966cac8867fe7da3997fc76e8a6cf5d4)

1.0.4
-----
* [Set data context to `DecodeError` exception](https://github.com/intridea/multi_json/commit/19ddafd44029c6681f66fae2a0f6eabfd0f85176)
* [Allow `ok_json` to fallback to `to_json`](https://github.com/intridea/multi_json/commit/c157240b1193b283d06d1bd4d4b5b06bcf3761f8)
* [Add warning when using `ok_json`](https://github.com/intridea/multi_json/commit/dd4b68810c84f826fb98f9713bfb29ab96888d57)
* [Options can be passed to an engine on encode](https://github.com/intridea/multi_json/commit/e0a7ff5d5ff621ffccc61617ed8aeec5816e81f7)

1.0.3
-----
* [`Array` support for `stringify_keys`](https://github.com/intridea/multi_json/commit/644d1c5c7c7f6a27663b11668527b346094e38b9)
* [`Array` support for `symbolize_keys`](https://github.com/intridea/multi_json/commit/c885377d47a2aa39cb0d971fea78db2d2fa479a7)

1.0.2
-----
* [Allow encoding of rootless JSON when `ok_json` is used](https://github.com/intridea/multi_json/commit/d1cde7de97cb0f6152aef8daf14037521cdce8c6)

1.0.1
-----
* [Correct an issue with `ok_json` not being returned as the default engine](https://github.com/intridea/multi_json/commit/d33c141619c54cccd770199694da8fd1bd8f449d)

1.0.0
-----
* [Remove `ActiveSupport::JSON` support](https://github.com/intridea/multi_json/commit/c2f4140141d785a24b3f56e58811b0e561b37f6a)
* [Fix `@engine` ivar warning](https://github.com/intridea/multi_json/commit/3b978a8995721a8dffedc3b75a7f49e5494ec553)
* [Only `rescue` from parsing errors during decoding, not any `StandardError`](https://github.com/intridea/multi_json/commit/391d00b5e85294d42d41347605d8d46b4a7f66cc)
* [Rename `okjson` engine and vendored lib to `ok_json`](https://github.com/intridea/multi_json/commit/5bd1afc977a8208ddb0443e1d57cb79665c019f1)
* [Add `StringIO` support to `json` gem and `ok_json`](https://github.com/intridea/multi_json/commit/1706b11568db7f50af451fce5f4d679aeb3bbe8f)

0.0.5
-----
* [Trap all JSON decoding errors; raise `MultiJson::DecodeError`](https://github.com/intridea/multi_json/commit/dea9a1aef6dd1212aa1e5a37ab1669f9b045b732)

0.0.4
-----
* [Fix default_engine check for `json` gem](https://github.com/intridea/multi_json/commit/caced0c4e8c795922a109ebc00c3c4fa8635bed8)
* [Make requirement mapper an `Array` to preserve order in Ruby versions < 1.9](https://github.com/intridea/multi_json/commit/526f5f29a42131574a088ad9bbb43d7f48439b2c)

0.0.3
-----
* [Improved defaulting and documentation](https://github.com/sferik/twitter/commit/3a0e41b9e4b0909201045fa47704b78c9d949b73)

0.0.2
-----

* [Rename to `multi_json`](https://github.com/sferik/twitter/commit/461ab89ce071c8c9fabfc183581e0ec523788b62)

0.0.1
-----

* [Initial commit](https://github.com/sferik/twitter/commit/518c21ab299c500527491e6c049ab2229e22a805)
