# tiny-mozc
reimplementation of mozc algorithm for study

## Build
### Setup

```sh
docker-compose build
docker-compose run dev bundle install
```

### Test

Run all unittests:

```sh
docker-compose run --rm dev bundle exec rake test
```

Run lints with autocorrect:

```sh
docker-compose run --rm dev bundle exec rake format
```

### Documents
I'll write class summaries, implementation notes, and related links in rdoc. Please check it.

```sh
docker-compose run --rm dev bundle exec rake rdoc
```
