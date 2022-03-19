const path = require("path");
const sassTrue = require("sass-true");
const glob = require("fast-glob");

// https://www.educative.io/blog/sass-tutorial-unit-testing-with-sass-true
// Find all of the Sass files that end in `*.test.scss` in any directory of this project.
// I use path.resolve because True requires absolute paths to compile test files.
const pattern = path.resolve(process.cwd(), "__tests__/**/*.test.scss");
const sassTestFiles = glob.sync([pattern]);

// Run True on every file found with the describe and it methods provided
sassTestFiles.forEach(file => {
  describe(file, () => sassTrue.runSass({ file }, { describe, it }));
});
