# Dartmark

Dartmark is a fun experiment to create benchmarks for some Dart and Flutter libraries.

There are two benchmark tracks:

- Validation benchmarks (existing flow) writing to `docs/data/results.json`.
- HTTP framework benchmarks (new) writing to `docs/data/results-http.json`.

## Benchmarks

To see the benchmarks, you can visit the [website](https://dartmark.dev).

## How to add your validation library

Right now Dartmark is focused on validation libraries. If you want to add your library, please create a new folder in the `lib` folder and add your library implementation there, you can follow how the Acanthis library is being implemented. The file name **must** be the same as the library. For example, if your library is called `my_library`, create a file called `my_library.dart` and add your implementation there.
Remember to also add the name of the library in the `bin/dartmark.dart` file otherwise it won't be run.

## How to add an HTTP framework benchmark

1. Create a config file under `configs/http/<framework>.yaml` using the schema:

	 ```yaml
	 framework: serinus
	 projectPath: frameworks/serinus
	 version: 1.0.0
	 build:
		 command: dart
		 args: ["compile", "exe", "bin/server.dart", "-o", "build/server.exe"]
	 run:
		 command: ./build/server.exe
		 env:
			 PORT: 8081
	 http:
		 baseUrl: http://127.0.0.1:8081
		 endpoint: /api/echo
		 waitForReady:
			 path: /health
			 timeoutSeconds: 10
			 intervalMillis: 200
	 load:
		 warmupSeconds: 5
		 durationSeconds: 20
		 concurrency: 64
		 connections: 0          # 0 means unthrottled
		 requests: 0             # 0 or omit to use duration-based
		 timeoutSeconds: 5
		 headers:
			 - "Content-Type: application/json"
		 body: '{"hello":"world"}'
	 oha:
		 binaryPath: /usr/local/bin/oha
		 extraArgs: []
	 ```

2. Ensure the project at `projectPath` can be AOT-built and run with the provided commands.
3. Run `dart run`; HTTP results will be written to `docs/data/results-http.json` and will cause the run to fail if the server crashes or `oha` exits with errors (non-2xx/timeouts count toward error totals).

## How the benchmarks are run

The validation benchmarks are run using the library `tyto`, while the HTTP benchmarks are run using the `oha` tool. Both of them are run inside a Docker container to ensure consistency across different environments and both of them measure the performance of AOT-compiled code.

## How to run the benchmarks locally

You can run the benchmarks locally by running the following command:

```bash
dart run
```

This will run the benchmarks and generate the results in the `docs/data` folder. The results are generated in a JSON format and can be used to generate the website.

To see them you can start the website using the following command:

```bash
cd docs && npm install && npm run docs:dev
```
