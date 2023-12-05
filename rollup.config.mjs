import resolve from "@rollup/plugin-node-resolve"
import { terser } from "rollup-plugin-terser"

export default [
  {
    input: "content/application.js",
    output: [
      {
        name: "content",
        file: "app/assets/builds/katalyst/content.esm.js",
        format: "esm",
      },
      {
        file: "app/assets/builds/katalyst/content.js",
        format: "es",
      },
    ],
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails", "trix"]
  },
  {
    input: "content/application.js",
    output: {
      file: "app/assets/builds/katalyst/content.min.js",
      format: "es",
      sourcemap: true,
    },
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      }),
      terser({
        mangle: true,
        compress: true
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails", "trix"]
  }
]
