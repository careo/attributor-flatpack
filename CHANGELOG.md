# attributor-flatpack changelog

## 1.4.1

- Fix regexp for `Config#subselect` not escaping the separator and not matching properly

## 1.4

- Respect `allow_extra: true` option when validating.

## 1.3

- Add `Attributor::Flatpack::MultilineString` type to handle multiline strings from environment variables.

## 1.2

- Add support for redefining the separator

## 1.1

- Significant performance improvements. See [benchmark results](benchmark/output.txt) for comparisons.

## 1.0

- Initial Release
