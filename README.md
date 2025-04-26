# Dartmark

Dartmark is a fun experiment to create benchmarks for some Dart and Flutter libraries.

## Benchmarks

To see the benchmarks, you can visit the [website](https://dartmark.dev).

## How to add your library

Right now Dartmark is focused on validation libraries. If you want to add your library, please create a new folder in the `lib` folder and add your library implementation there, you can follow how the Acanthis library is being implemented. The file name **must** be the same as the library. For example, if your library is called `my_library`, create a file called `my_library.dart` and add your implementation there.
Remember to also add the name of the library in the `bin/dartmark.dart` file otherwise it won't be run.

### Add a custom file for the website

You can add a custom file for the website in the `docs/packages` folder. The file name **must** be the same as the library. For example, if your library is called `my_library`, create a file called `my_library.md` and add your implementation there. As before you can follow how the Acanthis library is being implemented.

> [!NOTE]
> Currently we don't support custom logos for the libraries, but it could be added in the future. If you want to add a logo, please create an issue in the repository and we will add it for you.

## How the benchmarks are run

The benchmarks are run using the library `tyto` and the command is executed inside a docker container when it is built, this means that the benchmarks are run in a clean environment and the results are not affected by the local environment.

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

> [!NOTE]
> Right now the website is developed using Vitepress but it is already planned to migrate to Jaspr. If you want to help with the migration, please create an issue in the repository and we will add you to the team.
