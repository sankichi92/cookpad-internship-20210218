 module.exports = function(config) {
   config.set({
     frameworks: ["jasmine", "karma-typescript"],
     files: [
       { pattern: "ts/**/*.ts" },
       { pattern: "jasmine/**/*.ts" },
     ],
     preprocessors: {
       "**/*.ts": ["karma-typescript"]
     },
     reporters: ["dots", "karma-typescript"],
     browsers: ["ChromeHeadless", "FirefoxHeadless"],
     singleRun: true
   });
 };
